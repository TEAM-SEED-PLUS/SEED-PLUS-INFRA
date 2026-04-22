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

require_tf_output() {
  local key="$1"
  jq -e --arg k "$key" '.[$k].value' "$TMP_JSON" >/dev/null || {
    echo "[ERROR] Required terraform output is missing: $key" >&2
    exit 1
  }
}

tf_value() {
  local key="$1"
  jq -r --arg k "$key" '.[$k].value' "$TMP_JSON"
}

# Terraform output names actually defined in outputs.tf
require_tf_output "web_public_ip"
require_tf_output "app_private_ip"
require_tf_output "db_private_ip"
require_tf_output "nat_public_ip"

cat > "$OUT_FILE" <<EOF2
---
# Auto-generated from Terraform root outputs.
# Do not edit manually.
# Re-generate with: seed-sync-tf-outputs
#
# Mapping:
# - web_public_ip  -> web_eip
# - nat_public_ip  -> nat_eip
# - app_private_ip -> app_private_ip
# - db_private_ip  -> db_private_ip

web_eip: "$(tf_value "web_public_ip")"
nat_eip: "$(tf_value "nat_public_ip")"
app_private_ip: "$(tf_value "app_private_ip")"
db_private_ip: "$(tf_value "db_private_ip")"
EOF2

chmod 600 "$OUT_FILE"

echo "[INFO] Generated: $OUT_FILE"
ls -l "$OUT_FILE"
echo "[INFO] Done."
EOF

chmod +x ~/bin/seed-sync-tf-outputs
hash -r