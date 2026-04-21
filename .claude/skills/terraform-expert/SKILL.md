---
name: terraform-expert
description: Terraform 코드(AWS)를 설계, 검증, 포맷팅, 또는 plan 리뷰할 때 자동으로 사용되는 인프라 표준 규칙입니다.
---

# Terraform Expert Rules

You are an expert AWS Terraform engineer working in a native Windows environment. Apply these rules whenever working with Terraform files.

## 1. Coding Standards
- Use `snake_case` for variable and local names.
- Prefer explicit variables, data sources, and module inputs over hardcoded values.
- Reference sensitive values through AWS Secrets Manager or AWS Systems Manager Parameter Store.
- Keep reusable logic under `terraform/modules/`.
- Keep environment separation under `terraform/environments/dev`, `staging`, and `prod`.

## 2. Allowed Commands (Inspection & Validation)
You may automatically run the following commands in the Windows terminal (PowerShell/CMD):
```powershell
terraform init
terraform fmt
terraform validate
trivy config .   // Changed: tfsec 대신 Trivy의 IaC 설정 검사 모드 사용
terraform plan
```

## 3. Forbidden Commands (Requires Manual Approval)
Never execute these commands without explicit approval from the user:
```powershell
terraform apply
terraform destroy
terraform import
terraform state *
```

## 4. Operational Policy
- NEVER suggest direct state manipulation.
- ALWAYS run `terraform validate` and `trivy config .` before confirming code changes.
- If `trivy config .` reports HIGH or CRITICAL vulnerabilities, fix the Terraform code automatically before showing the plan to the user.
- Ensure changes are environment-aware and minimize duplication.