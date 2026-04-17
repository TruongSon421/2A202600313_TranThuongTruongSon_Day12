# Production Deployment on GCP Compute Engine

Muc tieu: deploy stack `06-lab-complete` len 1 VM va cap nhat tu GitHub (khong zip code).

## Terraform IaC (khuyen dung)

IaC da co san trong:

- `deployment/production-compute-engine/terraform`
- Da tach module:
  - `modules/network`
  - `modules/firewall`
  - `modules/compute`

### Profile toi uu chi phi

Ban co 2 profile mau:

- `terraform.tfvars.cost-optimized.example` (re de chay 24/7 nhat)
- `terraform.tfvars.balanced.example` (on dinh hon, cost cao hon)

Cost profile mac dinh dang dung:

- `machine_type = e2-medium`
- `boot_disk_type = pd-standard`
- `boot_disk_size_gb = 20`
- `use_spot_instance = true`

### Cac buoc chay

```bash
cd deployment/production-compute-engine/terraform
cp terraform.tfvars.example terraform.tfvars
# sua terraform.tfvars (project_id, ssh_public_key, ...)

terraform init
terraform plan
terraform apply
```

Neu dung profile co san:

```bash
cp terraform.tfvars.cost-optimized.example terraform.tfvars
# hoac:
# cp terraform.tfvars.balanced.example terraform.tfvars
```

Lay output:

```bash
terraform output
terraform output vm_external_ip
```

Xoa ha tang:

```bash
terraform destroy
```

### Terraform plan tren GitHub Actions

Workflow: `.github/workflows/terraform-plan-compute.yml`

- Chi chay khi thay doi trong `deployment/production-compute-engine/terraform/**`
- Chay `terraform fmt -check`, `terraform validate`, `terraform plan`

Can tao 2 GitHub Secrets:

- `TF_VAR_PROJECT_ID`
- `TF_VAR_SSH_PUBLIC_KEY`

### Compute Engine deploy tren GitHub Actions

Workflow: `.github/workflows/compute-engine-cicd.yml`

- Chi chay khi thay doi trong `06-lab-complete/**`
- PR: chi build validate backend/frontend
- Push `main`: copy source len VM va `docker compose up -d --build`

Can tao them GitHub Secrets:

- `GCE_HOST`
- `GCE_USER`
- `GCE_SSH_KEY`
- `GCE_PORT` (thuong la `22`)

## Kiem tra Docker image (backend/frontend)

Moi truong hien tai can Docker daemon de do dung luong image chinh xac. Neu daemon dang chay, dung lenh sau:

```bash
docker build -t day12-backend:analyze ./06-lab-complete
docker build -t day12-frontend:analyze ./06-lab-complete/frontend
docker image inspect day12-backend:analyze day12-frontend:analyze --format '{{.RepoTags}} {{.Size}}'
```

Nhan xet toi uu tu Dockerfile hien tai:

- Backend da la multi-stage va dung `python:3.11-slim` (tot cho size).
- Frontend runtime da dung `nginx:alpine` (nhe).
- Co the doi `npm install` thanh `npm ci` trong `frontend/Dockerfile` de build reproducible va nhanh hon tren CI.

## Deploy app len VM (sau khi Terraform apply)

1) SSH vao VM:

```bash
gcloud compute ssh <vm_name> --zone <zone>
```

2) Tren VM, clone repo va chay stack:

```bash
git clone https://github.com/<your-user>/<your-repo>.git ~/app
cd ~/app/06-lab-complete
cp -n .env.example .env
nano .env
docker compose up -d --build --remove-orphans
```

3) Kiem tra health:

```bash
curl http://localhost/health
curl http://localhost/ready
```

## Muc tieu CI/CD voi GitHub Actions (khong zip)

Workflow chuan:

1. Runner build/test image.
2. SSH vao VM.
3. Chay `git pull` + `docker compose up -d --build`.

Ban co the dung action `appleboy/ssh-action` de SSH vao VM va chay:

```bash
cd ~/app
git pull --ff-only origin main
cd 06-lab-complete
docker compose up -d --build --remove-orphans
```

GitHub Secrets de deploy qua SSH:

- `GCE_HOST` (external IP cua VM)
- `GCE_USER` (thuong la user linux tren VM)
- `GCE_SSH_KEY` (private key cho user do)
- `GCE_PORT` (mac dinh `22`)
