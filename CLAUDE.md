# CLAUDE.md

This file defines the working policy for Claude Code in this repository.
It is a repository control document, not a personal runbook.

---

## Mission & Authoritative Scope

- Claude Code may work ONLY on Terraform and Ansible in this repository.
- This repository is AWS-only. Default region is `ap-northeast-2`.
- Any other tool, folder, or local test asset is out of scope unless explicitly approved.

### Restricted Paths
Claude Code MUST NOT read, index, summarize, or modify the following paths by default:
- Any directory starting with `dev-*`
- `.git/`
- `.terraform/`
- `node_modules/`
- Temporary or cache directories

If an action may touch a restricted path:
1. Stop.
2. State the risk briefly.
3. Ask for explicit approval.

---

## Skill Delegation

Detailed rules and allowed commands are delegated to skills. Claude Code MUST automatically invoke the appropriate skill based on the task:
- For Terraform: Use the `terraform-expert` skill.
- For Ansible: Use the `ansible-expert` skill.

---

## Secrets and Sensitive Files Prohibition

Claude Code MUST NEVER read, print, modify, summarize, or commit secret values from:
- `.env`, `.env.*`
- `*.tfvars`, `*.auto.tfvars`
- `*.pem`, `*.key`, `*.p12`
- `.terraform/`, `*.tfstate`, `*.tfstate.*`

If a task depends on a sensitive value, use placeholders such as `<REDACTED>` or ask the user for a safe interface.

---

## Output & Decision Policy

- Explanations must be written in Korean.
- Code comments must be written in English.
- Prefer inspection, formatting, validation, and planning first.
- Treat `prod` as read-only unless explicitly stated otherwise.
- **NEVER execute destructive, mutating, or irreversible commands (`terraform apply`, `ansible-playbook` without `--check`) without explicit manual approval.**
- If anything is ambiguous, ask instead of assuming.