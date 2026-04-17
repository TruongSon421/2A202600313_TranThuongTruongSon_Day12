# Day 12 Lab - Mission Answers

> **Student Name:** Trần Thượng Trường Sơn
> **Student ID:** 2A202600313
> **Date:** 17/04/2026


## Part 1: Localhost vs Production

### Exercise 1.1: Anti-patterns found
1. Hardcoded secrets directly in code (`OPENAI_API_KEY`, `DATABASE_URL`) in `01-localhost-vs-production/develop/app.py`.
2. Fixed config values and no config management (`DEBUG = True`, `MAX_TOKENS = 500`) instead of environment variables.
3. Logging secrets to stdout (`print(f"[DEBUG] Using key: {OPENAI_API_KEY}")`) creates credential leakage risk.
4. No health check endpoint in the basic version, so orchestrators cannot detect unhealthy containers.
5. Host is bound to `localhost` only, preventing external access in container/cloud runtime.
6. Port is hardcoded to `8000` instead of reading platform-provided `PORT`.
7. `reload=True` in runtime path is a dev setting, not suitable for production stability/performance.

### Exercise 1.3: Comparison table
| Feature | Develop (Basic) | Production (Advanced) | Why Important? |
|---------|------------------|------------------------|----------------|
| Config | Hardcoded constants and secrets in source file | Uses centralized settings from environment (`config.settings`) | Prevents secret leaks and supports per-environment deployment |
| Logging | `print()` debug lines, even exposing API key | Structured JSON logging with metadata and no secrets | Better observability and safer logs in production |
| Health check | Missing | `/health` implemented with status, uptime, timestamp | Required for cloud liveness probes and auto-restart |
| Readiness check | Missing | `/ready` with readiness flag and `503` when not ready | Prevents traffic from reaching warming/unready instance |
| Shutdown handling | No graceful strategy | Lifespan shutdown flow + SIGTERM handler | Allows in-flight requests to complete cleanly |
| Host binding | `localhost` | `0.0.0.0` via settings | Required for container networking and public routing |
| Port strategy | Fixed `8000` | Reads `PORT` from env | Compatible with Railway/Render/Cloud Run runtime |
| CORS and middleware | Not configured | Configurable CORS middleware | Better API safety and frontend integration |

## Part 2: Docker

### Exercise 2.1: Dockerfile questions
1. Base image (develop): `python:3.11`.
2. Working directory: `/app`.
3. `COPY requirements.txt` before app source to maximize Docker layer cache, so dependency install is skipped on code-only changes.
4. `CMD` provides default command at runtime (can be overridden). `ENTRYPOINT` defines fixed executable behavior; `CMD` usually supplies default args/command.

### Exercise 2.3: Image size comparison
- Develop: **1660 MB** (`my-agent:develop` = `1.66GB`)
- Production: **236 MB** (`my-agent:production-temp`)
- Difference: **85.8%** smaller

Calculation:
`((1660 - 236) / 1660) * 100 = 85.8%`

### Exercise 2.4: Docker Compose stack summary
- Services started: `agent`, `redis`, `qdrant`, `nginx` (in `02-docker/production/docker-compose.yml`).
- Communication:
  - `nginx` receives external traffic and proxies to `agent`.
  - `agent` connects to `redis` (`REDIS_URL`) for cache/rate/session use cases.
  - `agent` connects to `qdrant` (`QDRANT_URL`) for vector database/RAG.
  - All services share internal Docker network `internal`.
- `depends_on` + healthchecks ensure `agent` waits for `redis` and `qdrant` readiness.

## Part 3: Cloud Deployment

### Exercise 3.1: Railway deployment
- Platform: Railway
- Public URL: `https://responsible-beauty-production-4be5.up.railway.app`
- Screenshot references:
- [Railway](screenshots/railway.png)
- [Railway DashBoard](screenshots/railway_dashboard.png)
- Platform: Render
- Public URL: `https://ai-agent-ks2o.onrender.com/`
- Screenshot references:
- [Render](screenshots/render.png)
- [Render DashBoard](screenshots/render_dashboard.png)

### Exercise 3.2: Railway vs Render config
- `railway.toml` is optimized for Railway CLI/runtime workflow.
- `render.yaml` is Render Blueprint file (Infrastructure as Code) used to declare service config.
- In this submission, the agent was deployed on both Railway and Render to compare deployment workflow and runtime behavior.

## Part 4: API Security

### Exercise 4.1: API key authentication
- API key is checked in `verify_api_key()` in `04-api-gateway/develop/app.py`.
- If key is missing: `401`.
- If key is invalid: `403`.
- Rotation approach: update `AGENT_API_KEY` via environment variable, redeploy service, and revoke old key.
- Test flow followed CODE_LAB:
  - No key -> unauthorized (`401`)
  - Wrong key -> forbidden (`403`)
  - Correct key -> success (`200`)

### Exercise 4.2: JWT authentication flow
1. Call token endpoint with credentials (as CODE_LAB guide):  
   `POST /token` with `{"username":"admin","password":"secret"}`.
2. Server verifies credentials and generates JWT (contains user identity + expiry).
3. Use token in header: `Authorization: Bearer <token>` when calling `/ask`.
4. If token is missing/invalid/expired -> `401/403`; valid token -> `200`.

### Exercise 4.3: Rate limiting
- Algorithm: sliding window (count requests in a 60-second window per user).
- Limit: `10 requests/minute` for normal users (admin tier can have higher threshold/bypass policy).
- CODE_LAB test used 20 rapid requests:
  - Initial requests: `200`
  - After limit exceeded: `429 Too Many Requests`
  - Confirms limiter blocks abuse on public endpoint.

### Exercise 4.4: Cost guard implementation
Approach (following CODE_LAB):
1. Define monthly key format in Redis: `budget:{user_id}:{YYYY-MM}`.
2. Read current spending from Redis (`current = float(r.get(key) or 0)`).
3. Compare `current + estimated_cost` with monthly budget `$10`.
   - If over budget: return `False` (or block request with budget error).
4. If within budget: increment usage with `incrbyfloat`.
5. Set TTL around 32 days so budget data naturally resets each month.

## Part 5: Scaling & Reliability

### Exercise 5.1: Health and readiness checks
- Executed on `05-scaling-reliability/develop` (Uvicorn on `127.0.0.1:8020`).
- `GET /health` -> `200`
- `GET /ready` -> `200`
- Health payload includes status/uptime/environment/checks (memory probe).

### Exercise 5.2: Graceful shutdown
- Executed SIGTERM test on running process (`python app.py` in develop folder).
- Observed in log:
  - `Received signal 15 — uvicorn will handle graceful shutdown`
  - `Graceful shutdown initiated...`
  - `Shutdown complete`
- After SIGTERM, `GET /health` returned connection failed (`000`), confirming process exited.

### Exercise 5.3: Stateless design
- Deployed production stack with Redis + 3 agent replicas via Docker Compose.
- Stateless session storage ran through Redis (`REDIS_URL=redis://redis:6379/0` in compose).
- `test_stateless.py` showed one conversation served by multiple instances while history stayed consistent.

### Exercise 5.4: Load balancing
- Command executed: `docker compose up --scale agent=3` in `05-scaling-reliability/production`.
- Nginx successfully distributed traffic across 3 agent instances.
- 10-request sample distribution:
  - `instance-1045a3`: 4 requests
  - `instance-51870e`: 3 requests
  - `instance-c25dc8`: 3 requests

### Exercise 5.5: Stateless test results
- Executed `python test_stateless.py` with stack running on `localhost:8080`.
- Result summary:
  - Total requests: 5
  - Instances used: 3 distinct instances (`instance-1045a3`, `instance-51870e`, `instance-c25dc8`)
  - Conversation history count: 10 messages (5 user + 5 assistant)
  - Script output confirmed: `Session history preserved across all instances via Redis`.

---


