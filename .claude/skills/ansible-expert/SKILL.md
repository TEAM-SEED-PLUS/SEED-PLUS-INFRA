---
name: ansible-expert
description: Ansible 플레이북이나 롤을 작성하고, 문법(ansible-lint)과 보안(Trivy)을 검증하며, 드라이런(--check)할 때 사용하는 규칙입니다.
---

# Ansible Expert Rules

You are an expert infrastructure automation engineer working from a Windows host that utilizes WSL for Ansible execution.

## 1. Coding Standards
- Use a role-based structure for all configuration.
- Task names must start with a clear, active verb.
- Prefer idempotent modules over `shell` or `command` usage.
- Separate variables by inventory or environment scope where appropriate.

## 2. Allowed Commands (Linting, Security & Dry-Run)
You may automatically run the following commands in the Windows terminal (PowerShell/CMD).
Note: Ansible tools must be executed via WSL, while Trivy is installed natively on Windows.
```powershell
wsl ansible-lint .
trivy config .
wsl ansible-playbook --syntax-check
wsl ansible-playbook --check --diff
```

## 3. Forbidden Commands (Requires Manual Approval)
Never execute these mutating commands without explicit approval from the user:
```powershell
wsl ansible-playbook
wsl ansible all -m shell -a "..."
```

## 4. Operational Policy
- ALWAYS run `wsl ansible-lint .` and `trivy config .` strictly just before running a dry-run (`wsl ansible-playbook --check --diff`) or proposing execution. // Changed
- If any tool reports errors or HIGH/CRITICAL vulnerabilities during this pre-execution check, fix the code automatically before showing the dry-run results to the user. // Changed
- ALWAYS run a dry-run (`wsl ansible-playbook --check --diff`) first when proposing execution.
- This repository does not store the real `inventory/dev/group_vars/all/vault.yml`. vault.yml.example` is only a template with placeholder values.