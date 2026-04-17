# Deployment Information

> **Student Name:** Trần Thượng Trường Sơn
> **Student ID:** 2A202600313
> **Date:** 17/04/2026

## Public URL
http://34.87.10.146

## Platform
Google Cloud Platform (Compute Engine VM with Docker Compose)

## Deployment Method
- Infrastructure as Code: Terraform
- Runtime: Docker Compose on VM
- CI/CD: GitHub Actions

### Terraform Folder
`deployment/production-compute-engine/terraform`

### GitHub Workflows
- `.github/workflows/terraform-plan-compute.yml`
  - Trigger: changes in `deployment/production-compute-engine/terraform/**`
  - Runs: `terraform fmt -check`, `terraform validate`, `terraform plan`
- `.github/workflows/compute-engine-cicd.yml`
  - Trigger: changes in `06-lab-complete/**`
  - PR: build validation
  - Push to `main`: copy code to VM and run `docker compose up -d --build`

## Required GitHub Secrets

### For Terraform Plan
- `TF_VAR_PROJECT_ID`
- `TF_VAR_SSH_PUBLIC_KEY`

### For Compute Engine CI/CD
- `GCE_HOST` (VM public IP)
- `GCE_USER` (SSH user, e.g. `ubuntu`)
- `GCE_SSH_KEY` (private SSH key)
- `GCE_PORT` (`22`)

## Test Commands

### Health Check
```bash
curl http://34.87.10.146/health
# Expected: {"status":"ok", ...}
```

### Readiness Check
```bash
curl http://34.87.10.146/ready
# Expected: {"ready":true}
```


### API Test (with JWT authentication, stream endpoint)
```bash
TOKEN=$(curl -s -X POST http://34.87.10.146/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"Admin@123456"}' | \
  python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')

curl -i -N -X POST http://34.87.10.146/ask-multi-agent/stream \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"question":"quy định về hành lý xách tay"}'
# Expected: HTTP 200
```

### Authentication Required Test (without bearer token)
```bash
curl -i -N -X POST http://34.87.10.146/ask-multi-agent/stream \
  -H "Content-Type: application/json" \
  -d '{"question":"hello"}'
# Expected: HTTP 401 Unauthorized
```

## Environment Notes
- Production secrets are configured in VM file `06-lab-complete/.env` (not committed).
- Only `.env.example` is committed.

## Screenshots
- [Deployment dashboard](screenshots/dashboard.png)
- [Service running](screenshots/running.png)
- [GitHub Actions CI/CD success](screenshots/github_action.png)
- [Health check result](screenshots/test_health.png)
- [Readiness check result](screenshots/test_ready.png)
- [Unauthorized test (401)](screenshots/test_unauthorized.png)
- [JWT authenticated test](screenshots/test_have_jwt.png)

## Submission Notes
- Ensure public URL is reachable from another network/device.
- Ensure `.env`, `terraform.tfvars`, and private keys are never committed.
