.PHONY: ansible-sync ansible-lint ansible-check ansible-dry-run

# Sync live IPs from AWS into Ansible inventory vars after terraform apply.
# Requires: aws cli, jq (both available in WSL)
ansible-sync:
	bash scripts/ansible-sync.sh

# Lint Ansible project (WSL)
ansible-lint:
	wsl bash -c "cd /mnt/c/Users/lenovo/Git/SEED-PLUS/SEED-PLUS-INFRA/ansible && ansible-lint ."

# Syntax check (WSL)
ansible-check:
	wsl bash -c "cd /mnt/c/Users/lenovo/Git/SEED-PLUS/SEED-PLUS-INFRA/ansible && ansible-playbook --syntax-check playbooks/site.yml"

# Dry-run with diff (WSL) — requires prior 'make ansible-sync'
ansible-dry-run:
	wsl bash -c "cd /mnt/c/Users/lenovo/Git/SEED-PLUS/SEED-PLUS-INFRA/ansible && ansible-playbook --check --diff -i inventory/dev playbooks/site.yml"

# Trivy config scan
trivy-scan:
	trivy config .
