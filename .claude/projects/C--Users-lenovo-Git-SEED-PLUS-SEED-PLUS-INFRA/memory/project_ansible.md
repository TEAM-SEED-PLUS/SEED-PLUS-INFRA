---
name: Ansible Project Structure
description: Ansible 프로젝트 전체 설계 및 구현 현황 (2026-04-22 완료)
type: project
---

Ansible 프로젝트가 `ansible/` 디렉토리에 처음부터 신규 생성 완료.

**Why:** SEED-PLUS-INFRA Terraform 인프라(web/app/db/nat 4티어)에 대한 초기 프로비저닝 자동화 필요.

**How to apply:** 다음 작업 시 ansible/ 기존 파일 참고해 이어서 작업.

## 설계 결정 사항
- 인벤토리: 동적(aws_ec2.yml) + 정적(hosts.yml) 병행
- PG 버전: 17, 데이터 디렉토리: /mnt/pgdata (/dev/xvdb 마운트)
- 컨테이너 이미지: traefik/whoami (web 8081 internal/NAT via Nginx, app 8080 직접)
- NAT 인터페이스: ansible_default_ipv4.interface 자동 감지
- 포함된 역할: common, docker, web, app, db_postgres, nat, fail2ban, cloudwatch_agent
- ansible-sync 스크립트: scripts/ansible-sync.sh (AWS CLI로 live IP 조회), Makefile에 target 등록
- IAM CloudWatch 정책: 이미 terraform/modules/iam/main.tf에 구현됨 — Terraform 추가 변경 불필요

## 주요 파일 위치
- `ansible/playbooks/site.yml` — 마스터 플레이북 (nat→db→app→web 순)
- `ansible/playbooks/smoke.yml` — 배포 후 헬스체크
- `ansible/inventory/dev/group_vars/all/terraform_outputs.yml` — make ansible-sync가 작성 (.gitignore 처리)
- `scripts/ansible-sync.sh` — terraform apply 후 실행 필요
- `Makefile` — ansible-lint, ansible-check, ansible-dry-run, ansible-sync, trivy-scan 타겟
