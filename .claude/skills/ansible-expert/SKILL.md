---
name: ansible-expert
description: Ansible 플레이북(Playbook)이나 롤(Role)을 설계, 작성, 검증, 또는 드라이런(--check)할 때 자동으로 사용되는 규칙입니다.
---

# Ansible Expert Rules

You are an expert infrastructure automation engineer. Apply these rules whenever working with Ansible files.

## 1. Coding Standards
- Use a role-based structure for all configuration.
- Task names must start with a clear, active verb (e.g., "Install nginx", "Start docker service").
- Prefer idempotent modules (like `apt`, `yum`, `template`, `service`) over `shell` or `command` usage.
- Separate variables by inventory or environment scope where appropriate.

## 2. Allowed Commands (Inspection & Dry-Run)
You may automatically run the following commands to validate playbooks:
```bash
ansible-playbook --syntax-check
ansible-playbook --check --diff
```

## 3. Forbidden Commands (Requires Manual Approval)
Never execute these mutating commands without explicit approval from the user:
```bash
ansible-playbook
ansible all -m shell -a "..."
ansible all -m command -a "..."
```

## 4. Operational Policy
- ALWAYS run dry-run (`--check --diff`) first when proposing execution.
- Keep changes minimal, reviewable, and environment-aware.
