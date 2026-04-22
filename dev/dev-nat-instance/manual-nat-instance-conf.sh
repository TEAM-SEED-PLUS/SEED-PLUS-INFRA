cat > ~/bin/seed-sync-tf-outputs <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

# Read-only sync script:
# - Reads the current Terraform state from the configured backend (S3)
# - Does NOT run terraform plan/apply
# - Does NOT modify real infrastructure
# - Generates Ansible vars file from remote state values

: "${SEED_HOME:=$HOME/Git/SEED-PLUS/SEED-PLUS-INFRA}"
: "${TF_DIR:=$SEED_HOME/terraform/environments/dev}"
: "${ANSIBLE_DIR:=$SEED_HOME/ansible}"

OUT_DIR="$ANSIBLE_DIR/inventory/dev/group_vars/all"
OUT_FILE="$OUT_DIR/terraform_outputs.yml"
TMP_STATE="$(mktemp)"

cleanup() {
  rm -f "$TMP_STATE"
}
trap cleanup EXIT

mkdir -p "$OUT_DIR"

echo "[INFO] SEED_HOME=$SEED_HOME"
echo "[INFO] TF_DIR=$TF_DIR"
echo "[INFO] ANSIBLE_DIR=$ANSIBLE_DIR"
echo "[INFO] OUT_FILE=$OUT_FILE"

cd "$TF_DIR"

# Backend init is safe and required so Terraform knows which remote state to read.
echo "[INFO] Running terraform init..."
terraform init -input=false -no-color >/dev/null

# Read the raw state snapshot from the configured remote backend.
# This is read-only and does not change infrastructure.
echo "[INFO] Pulling remote state from backend..."
terraform state pull > "$TMP_STATE"

# Read a root output value if it already exists in state.
state_output() {
  local key="$1"
  jq -er --arg k "$key" '.outputs[$k].value // empty' "$TMP_STATE" 2>/dev/null || true
}

# Find an EC2 instance attribute by Name tag from raw state.
find_instance_attr_by_name() {
  local name="$1"
  local attr="$2"
  jq -er --arg name "$name" --arg attr "$attr" '
    [
      .resources[]
      | select(.mode == "managed" and .type == "aws_instance")
      | .instances[]?.attributes
      | select(.tags.Name? == $name)
      | .[$attr]
    ]
    | map(select(. != null and . != ""))
    | first // empty
  ' "$TMP_STATE" 2>/dev/null || true
}

# Find an EIP public IP by Name tag from raw state.
find_eip_public_ip_by_name() {
  local name="$1"
  jq -er --arg name "$name" '
    [
      .resources[]
      | select(.mode == "managed" and .type == "aws_eip")
      | .instances[]?.attributes
      | select(.tags.Name? == $name)
      | .public_ip
    ]
    | map(select(. != null and . != ""))
    | first // empty
  ' "$TMP_STATE" 2>/dev/null || true
}

require_value() {
  local key="$1"
  local value="$2"
  if [ -z "$value" ]; then
    echo "[ERROR] Failed to resolve required value: $key" >&2
    exit 1
  fi
}

# Prefer root outputs if they exist in state.
# Fall back to raw resource attributes from the remote state snapshot.
web_eip="$(state_output "web_public_ip")"
[ -n "$web_eip" ] || web_eip="$(find_eip_public_ip_by_name "seed-plus-dev-web")"
[ -n "$web_eip" ] || web_eip="$(find_instance_attr_by_name "seed-plus-dev-web" "public_ip")"

nat_eip="$(state_output "nat_public_ip")"
[ -n "$nat_eip" ] || nat_eip="$(state_output "nat_eip")"
[ -n "$nat_eip" ] || nat_eip="$(find_eip_public_ip_by_name "seed-plus-dev-nat")"
[ -n "$nat_eip" ] || nat_eip="$(find_instance_attr_by_name "seed-plus-dev-nat" "public_ip")"

app_private_ip="$(state_output "app_private_ip")"
[ -n "$app_private_ip" ] || app_private_ip="$(find_instance_attr_by_name "seed-plus-dev-app" "private_ip")"

db_private_ip="$(state_output "db_private_ip")"
[ -n "$db_private_ip" ] || db_private_ip="$(find_instance_attr_by_name "seed-plus-dev-db" "private_ip")"

require_value "web_eip" "$web_eip"
require_value "nat_eip" "$nat_eip"
require_value "app_private_ip" "$app_private_ip"
require_value "db_private_ip" "$db_private_ip"

cat > "$OUT_FILE" <<EOF2
---
# Auto-generated from Terraform remote state.
# Read-only sync source: terraform state pull
# Do not edit manually.
# Re-generate with: seed-sync-tf-outputs
#
# Mapping note:
# - web_eip       comes from root output web_public_ip or matching state resource
# - nat_eip       comes from root output nat_public_ip/nat_eip or matching state resource
# - app_private_ip comes from root output app_private_ip or matching state resource
# - db_private_ip comes from root output db_private_ip or matching state resource

web_eip: "$web_eip"
nat_eip: "$nat_eip"
app_private_ip: "$app_private_ip"
db_private_ip: "$db_private_ip"
EOF2

chmod 600 "$OUT_FILE"

echo "[INFO] Generated: $OUT_FILE"
echo "[INFO] Resolved keys:"
echo "  web_eip=$web_eip"
echo "  nat_eip=$nat_eip"
echo "  app_private_ip=$app_private_ip"
echo "  db_private_ip=$db_private_ip"
EOF

chmod +x ~/bin/seed-sync-tf-outputs
hash -r