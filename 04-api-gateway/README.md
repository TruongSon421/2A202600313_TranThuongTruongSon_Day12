# Section 4 — API Gateway & Security

## Mục tiêu học
- Hiểu tại sao cần lớp bảo vệ trước agent
- Implement API Key authentication
- Implement JWT authentication (nâng cao)
- Rate limiting và cost protection

---

## Ví dụ Basic — API Key Authentication

```
develop/
├── app.py              # Agent với API Key auth
├── test_auth.py        # Test script
└── requirements.txt
```

### Chạy thử
```bash
cd basic
pip install -r requirements.txt
AGENT_API_KEY=my-secret-key python app.py

# Test với key hợp lệ
curl -H "X-API-Key: my-secret-key" http://localhost:8000/ask \
     -X POST -H "Content-Type: application/json" \
     -d '{"question": "hello"}'

# Test không có key → 401
curl http://localhost:8000/ask -X POST \
     -H "Content-Type: application/json" \
     -d '{"question": "hello"}'
```

---

## Ví dụ Advanced — JWT + Rate Limiting + Cost Guard

```
production/
├── app.py              # Full security stack
├── auth.py             # JWT token logic
├── rate_limiter.py     # In-memory rate limiter
├── cost_guard.py       # Token budget và spending alerts
├── test_advanced.py    # Test suite
└── requirements.txt
```

### Chạy thử
```bash
cd advanced
pip install -r requirements.txt
python app.py

# Lấy JWT token
curl -X POST http://localhost:8000/auth/token \
     -H "Content-Type: application/json" \
     -d '{"username": "student", "password": "demo123"}'

# Dùng token
curl -H "Authorization: Bearer <token>" \
     http://localhost:8000/ask \
     -X POST -H "Content-Type: application/json" \
     -d '{"question": "what is docker?"}'

# Test rate limit: spam 20 requests liên tiếp
python test_advanced.py --test rate-limit
```

---

## Luồng bảo vệ

```
Request
  → Auth Check (401 nếu fail)
  → Rate Limit (429 nếu vượt quota)
  → Input Validation (422 nếu invalid)
  → Cost Check (402 nếu hết budget)
  → Agent (200 nếu mọi thứ OK)
```

---

## Câu hỏi thảo luận

1. Khi nào nên dùng API Key vs JWT vs OAuth2?
2. Rate limit nên đặt bao nhiêu request/phút cho một AI agent?
3. Nếu API key bị lộ, bạn phát hiện và xử lý như thế nào?



1. API Key phù hợp service-to-service đơn giản, internal tool, hoặc MVP nhanh. JWT phù hợp khi cần đăng nhập user, phân quyền theo role, và stateless auth cho nhiều request. OAuth2 phù hợp khi tích hợp bên thứ ba (Google/GitHub/Microsoft login), cần delegated access và chuẩn enterprise.
2. Không có một con số cố định cho mọi hệ thống; nên bắt đầu theo tier. Ví dụ lab này: user thường `10 req/phút`, admin cao hơn. Với production, nên dựa trên chi phí/token, độ trễ model, hành vi người dùng thật, rồi tinh chỉnh theo metrics (429 rate, latency, cost/user).
3. Cần làm theo incident flow: thu hồi/rotate key ngay, chặn key cũ, kiểm tra logs để xác định phạm vi lạm dụng, giới hạn tạm thời qua rate limit/IP allowlist, cập nhật key mới cho client hợp lệ, và bổ sung cảnh báo tự động (spike usage, failed auth) để phát hiện sớm lần sau.
