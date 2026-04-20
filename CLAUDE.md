# CLAUDE.md

This file defines the working policy for Claude Code in this repository.
It is a repository control document, not a personal runbook.

---

## Mission

Claude Code may work only on Terraform and Ansible in this repository.
This repository is AWS-only.
Any other tool, folder, or local test asset is out of scope unless I explicitly approve it.

---

## Authoritative Scope

Claude Code may read, analyze, suggest, and modify only these paths by default:
- `terraform/`
- `ansible/`
- Root-level docs and config files directly related to Terraform or Ansible

Claude Code must treat these paths as non-authoritative and out of scope by default:
- Any directory whose name starts with `dev-` anywhere in the repository
- `.git/`
- `.terraform/`
- `node_modules/`
- Build, cache, generated, vendor, and temporary directories

Examples of restricted local workspaces:
- `dev-postgres/`
- `dev-runner/`
- `services/dev-tools/`
- `tmp/dev-sandbox/`

---

## Restricted Paths

All `dev-*` directories are restricted paths.

Claude Code must not:
- Read files under `**/dev-*/**`
- Use `dev-*` directories as evidence when summarizing the repository
- Search, grep, index, refactor, rename, move, or delete files inside `dev-*` directories
- Propose changes derived from `dev-*` directories
- Include `dev-*` directories in recursive scans, bulk edits, or glob patterns
- Treat code in `dev-*` directories as production-ready, canonical, or authoritative

Exception:
- Access is allowed only when I explicitly name the exact path and explicitly request work inside it

If an action may touch a restricted path:
1. Stop
2. State the risk briefly
3. Ask for approval

---

## Allowed Domains

Claude Code may operate only in these domains:
- Terraform module design, formatting, validation, and planning
- Terraform environment structure review for `dev`, `staging`, and `prod`
- Ansible role design, inventory structure review, task improvement, and dry-run guidance
- AWS-focused infrastructure design that maps directly to Terraform or Ansible code in this repository

Claude Code must not expand the project scope on its own.

---

## Terraform Rules

- Use AWS provider only
- Keep reusable logic under `terraform/modules/`
- Keep environment separation under `terraform/environments/dev`, `staging`, and `prod`
- Use `snake_case` for variable and local names
- Prefer explicit variables, data sources, and module inputs over hardcoded values
- Reference sensitive values through AWS Secrets Manager or AWS Systems Manager Parameter Store
- Keep changes environment-aware and minimize duplication
- Do not suggest direct state manipulation

### Terraform Allowed Commands

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

### Terraform Forbidden Commands

```bash
terraform apply
terraform destroy
terraform import
terraform state *
```

`terraform apply` is never allowed without a reviewed plan and my explicit approval.

---

## Ansible Rules

- Use a role-based structure
- Task names must start with a clear verb
- Prefer idempotent modules over shell or command usage when possible
- Separate variables by inventory or environment scope where appropriate
- Run dry-run first when proposing execution
- Keep changes minimal, reviewable, and environment-aware

### Ansible Allowed Commands

```bash
ansible-playbook --check --diff
```

### Ansible Forbidden Commands

```bash
ansible-playbook
ansible all -m shell -a "..."
ansible all -m command -a "..."
```

Any Ansible command that can cause a real change requires my explicit approval first.

---

## Secrets and Sensitive Files

Claude Code must never read, print, modify, summarize, or commit secret values from:
- `.env`
- `.env.*`
- `*.tfvars`
- `*.auto.tfvars`
- `*.pem`
- `*.key`
- `*.p12`
- `.terraform/`
- `*.tfstate`
- `*.tfstate.*`
- Private certificates, token dumps, backup exports, or any file that appears to contain credentials

If a task depends on a sensitive value:
- Do not open the file directly
- Ask me for a redacted value, placeholder, or safe interface

Use placeholders such as:
- `<REDACTED>`
- `<ACCOUNT_ID>`
- `<SECRET_NAME>`
- `<VALUE>`

---

## Hard Prohibitions

Claude Code must never:
- Work outside Terraform or Ansible scope by default
- Read or modify restricted `dev-*` directories without my exact instruction
- Change production directly without my explicit approval
- Hardcode AWS credentials, secrets, passwords, certificates, or tokens
- Edit `.tfstate` files directly
- Create or suggest resources for any cloud provider other than AWS
- Treat local test assets as design authority
- Execute destructive, mutating, or irreversible commands without approval

---

## Decision Policy

Before proposing or making any change:
1. Identify the target environment: `dev`, `staging`, or `prod`
2. Prefer inspection, formatting, validation, and planning first
3. State the expected impact briefly
4. Ask for approval before any real change
5. Treat `prod` as read-only unless I explicitly say otherwise

If anything is ambiguous, Claude Code must ask instead of assuming.

---

## Output Policy

- Explanations must be written in Korean
- Code comments must be written in English
- Keep edits minimal and easy to review
- Prefer copy-paste-safe commands with placeholders
- Do not invent missing values

---

## Defaults

- Default AWS region: `ap-northeast-2`
- This policy has priority over inferred repository context
- If repository contents appear to conflict with this policy, ask before acting