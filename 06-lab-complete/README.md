# Lab 12 — Complete Production Agent

Kết hợp TẤT CẢ những gì đã học trong 1 project hoàn chỉnh.

## Checklist Deliverable

- [x] Dockerfile (multi-stage, < 500 MB)
- [x] docker-compose.yml (agent + redis + qdrant)
- [x] .dockerignore
- [x] Health check endpoint (`GET /health`)
- [x] Readiness endpoint (`GET /ready`)
- [x] API Key authentication
- [x] JWT authentication (register/login/me)
- [x] Rate limiting
- [x] Cost guard
- [x] Config từ environment variables
- [x] Structured logging
- [x] Graceful shutdown
- [x] Public URL ready (Railway / Render config)

---

## Cấu Trúc

```
06-lab-complete/
├── app/
│   ├── main.py         # Entry point — kết hợp tất cả
│   ├── config.py       # 12-factor config
│   ├── auth.py         # API Key + JWT
│   ├── rate_limiter.py # Rate limiting
│   └── cost_guard.py   # Budget protection
├── Dockerfile          # Multi-stage, production-ready
├── docker-compose.yml  # Full stack (agent + redis + qdrant + mysql)
├── railway.toml        # Deploy Railway
├── render.yaml         # Deploy Render
├── .env.example        # Template
├── .dockerignore
└── requirements.txt
```

---

## Chạy Local

```bash
# 1. Setup
cp .env.example .env

# 2. Chạy với Docker Compose
docker compose up

# 3. Test
curl http://localhost/health

# 4. Lấy API key từ .env, test endpoint
API_KEY=$(grep AGENT_API_KEY .env | cut -d= -f2)
curl -H "X-API-Key: $API_KEY" \
     -X POST http://localhost/ask \
     -H "Content-Type: application/json" \
     -d '{"question": "What is deployment?"}'
```

---

## Deploy Railway (< 5 phút)

```bash
# Cài Railway CLI
npm i -g @railway/cli

# Login và deploy
railway login
railway init
railway variables set OPENAI_API_KEY=sk-...
railway variables set AGENT_API_KEY=your-secret-key
railway up

# Nhận public URL!
railway domain
```

---

## Deploy Render

1. Push repo lên GitHub
2. Render Dashboard → New → Blueprint
3. Connect repo → Render đọc `render.yaml`
4. Set secrets: `OPENAI_API_KEY`, `AGENT_API_KEY`
5. Deploy → Nhận URL!

---

## CI/CD GitHub Actions -> Cloud Run (khong can zip)

Da co workflow san tai `.github/workflows/cloud-run-cicd.yml`:

- PR: chi chay `docker build` de validate backend/frontend.
- Push vao `main`: tu dong build image, push Artifact Registry, cap nhat Secret Manager va deploy Cloud Run.
- Co the chay tay bang `workflow_dispatch`.

### 1) Tao GitHub Secrets

Vao **GitHub repo -> Settings -> Secrets and variables -> Actions**, tao cac secret:

- `GCP_PROJECT_ID`
- `GCP_SA_KEY` (JSON key cua service account)
- `OPENAI_API_KEY`
- `AGENT_API_KEY`
- `JWT_SECRET`
- `ADMIN_EMAIL`
- `ADMIN_PASSWORD`

### 2) Quyen service account toi thieu

Gan cac role sau cho service account dung trong `GCP_SA_KEY`:

- `roles/run.admin`
- `roles/artifactregistry.admin`
- `roles/secretmanager.admin`
- `roles/iam.serviceAccountUser`
- `roles/serviceusage.serviceUsageAdmin`

### 3) Luong deploy

1. Merge code vao `main`.
2. GitHub Actions se chay workflow `Cloud Run CI/CD`.
3. Sau khi thanh cong, service URL hien trong log buoc `Output deployed service URL`.

---

## Kiểm Tra Production Readiness

```bash
python check_production_ready.py
```

Script này kiểm tra tất cả items trong checklist và báo cáo những gì còn thiếu.

---

## Multi-Agent (LangGraph + NeMo Guardrails + HITL)

Lab này có thêm endpoint mock multi-agent:

- `POST /ask-multi-agent/stream`
- Dùng `LangGraph` để chạy flow `planner -> researcher -> writer -> hitl`
- Tích hợp `NeMo Guardrails` (có fallback local nếu chưa cài đủ runtime)
- Dùng mock knowledge base, không cần OpenAI API để demo
- Bo sung RAG mock quy dinh di may bay: chunk mock docs, luu vao Qdrant, truy van trong `regulation_agent`

### Hoi dap quy dinh di may bay (RAG + Qdrant)

`/ask-multi-agent/stream` da duoc noi them `regulation_agent`:

1. Khoi tao mock regulation docs (hanh ly, giay to, gio co mat, vat pham cam, doi/hoan ve).
2. Chunk van ban va tao vector embedding hash nhe.
3. Upsert vao Qdrant collection `airline_regulations`.
4. Truy van top-k chunk lien quan cau hoi de dua vao cau tra loi cuoi.

Neu chay Docker Compose, Qdrant se duoc bat cung stack.

### Test nhanh

```bash
API_KEY=$(grep AGENT_API_KEY .env | cut -d= -f2)

# 1) Chưa duyệt HITL => trạng thái chờ duyệt
curl -H "X-API-Key: $API_KEY" \
  -X POST http://localhost/ask-multi-agent/stream \
  -H "Content-Type: application/json" \
  -d '{
    "question": "Cho em tóm tắt deployment với docker",
    "human_approved": false
  }'

# 2) Đã duyệt HITL => trả về answer cuối
curl -H "X-API-Key: $API_KEY" \
  -X POST http://localhost/ask-multi-agent/stream \
  -H "Content-Type: application/json" \
  -d '{
    "question": "Cho em tóm tắt deployment với docker",
    "human_approved": true,
    "human_feedback": "Giải thích ngắn gọn hơn"
  }'
```

### Dang ky / dang nhap JWT voi MySQL

Backend da them MySQL + bang `users` va 3 endpoint auth:

- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/me` (header `Authorization: Bearer <token>`)

Test nhanh:

```bash
# 1) Register
curl -X POST http://localhost/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email":"son@example.com",
    "full_name":"Son Tran",
    "password":"12345678"
  }'

# 2) Login
TOKEN=$(curl -s -X POST http://localhost/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"son@example.com","password":"12345678"}' | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')

# 3) Me
curl -H "Authorization: Bearer $TOKEN" http://localhost/auth/me
```

### UX/UI Demo

Sau khi app chay, mo giao dien:

```bash
http://localhost/ui
```

UI nay cho phep:
- Nhap API key + cau hoi travel
- Bat/tat HITL approval va feedback
- Xem ket qua, trace, judge scores, redactions, audit id
- Tai metrics monitoring truc tiep

### Frontend rieng (Vite + TypeScript)

UI chinh hien tai duoc phuc vu tu `frontend/dist` qua route `/ui`.

- Source TypeScript: `frontend/src/main.ts`
- Runtime static files: `frontend/dist/*`

Neu ban muon dev/build lai giao dien:

```bash
cd frontend
npm install
npm run build
```
