cat > ~/bin/seed-sync-tf-outputs <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

: "${SEED_HOME:=$HOME/Git/SEED-PLUS/SEED-PLUS-INFRA}"
: "${TF_DIR:=$SEED_HOME/terraform/environments/dev}"
: "${ANSIBLE_DIR:=$SEED_HOME/ansible}"

OUT_DIR="$ANSIBLE_DIR/inventory/dev/group_vars/all"
OUT_FILE="$OUT_DIR/terraform_outputs.yml"
TMP_JSON="$(mktemp)"

cleanup() {
  rm -f "$TMP_JSON"
}
trap cleanup EXIT

mkdir -p "$OUT_DIR"

echo "[INFO] SEED_HOME=$SEED_HOME"
echo "[INFO] TF_DIR=$TF_DIR"
echo "[INFO] ANSIBLE_DIR=$ANSIBLE_DIR"
echo "[INFO] OUT_FILE=$OUT_FILE"

cd "$TF_DIR"

echo "[INFO] Running terraform init..."
terraform init -input=false -no-color >/dev/null

echo "[INFO] Reading terraform outputs..."
terraform output -json -no-color > "$TMP_JSON"

echo "[INFO] Available terraform output keys:"
jq -r 'keys[]' "$TMP_JSON"

has_tf_output() {
  local key="$1"
  jq -e --arg k "$key" '.[$k].value' "$TMP_JSON" >/dev/null 2>&1
}

tf_value() {
  local key="$1"
  jq -r --arg k "$key" '.[$k].value' "$TMP_JSON"
}

require_tf_output() {
  local key="$1"
  local hint="${2:-}"
  if ! has_tf_output "$key"; then
    echo "[ERROR] Required terraform output is missing: $key" >&2
    if [ -n "$hint" ]; then
      echo "[ERROR] Hint: $hint" >&2
    fi
    exit 1
  fi
}

# Required by current hosts.yml
require_tf_output "web_public_ip" "hosts.yml uses web_eip, so this script maps web_public_ip -> web_eip."
require_tf_output "app_private_ip" "hosts.yml uses app_private_ip directly."
require_tf_output "db_private_ip" "hosts.yml uses db_private_ip, but outputs.tf does not currently expose it."
require_tf_output "nat_eip" "hosts.yml uses nat_eip, but outputs.tf does not currently expose it."

cat > "$OUT_FILE" <<EOF2
---
# Auto-generated from Terraform root outputs.
# Do not edit manually. Re-generate with: seed-sync-tf-outputs

web_eip: "$(tf_value "web_public_ip")"
app_private_ip: "$(tf_value "app_private_ip")"
db_private_ip: "$(tf_value "db_private_ip")"
nat_eip: "$(tf_value "nat_eip")"
EOF2

chmod 600 "$OUT_FILE"

echo "[INFO] Generated: $OUT_FILE"
ls -l "$OUT_FILE"
EOF

chmod +x ~/bin/seed-sync-tf-outputs
hash -r