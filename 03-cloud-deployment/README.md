# Section 3 — Cloud Deployment Options

## 3 Tier: Chọn Platform Theo Nhu Cầu

| Tier | Platform | Khi nào dùng | Thời gian deploy |
|------|----------|-------------|-----------------|
| 1 | Railway, Render | MVP, demo, học | < 10 phút |
| 2 | AWS ECS, Cloud Run | Production | 15–30 phút |
| 3 | Kubernetes | Enterprise, large-scale | Vài giờ setup |

---

## railway/ — Deploy < 5 Phút

Không cần server config. Kết nối GitHub → Auto deploy.

```
railway/
├── railway.toml        # Railway config
├── Procfile            # Define start command
├── app.py              # Agent (Railway-ready)
└── requirements.txt
```

### Các bước deploy Railway:
1. `railway login` (hoặc qua browser)
2. `railway init`
3. `railway up`
4. Nhận URL dạng `https://your-app.up.railway.app`

---

## render/ — render.yaml (Infrastructure as Code)

Định nghĩa toàn bộ infrastructure trong 1 YAML file.

```
render/
├── render.yaml         # Khai báo service, env vars, disk
└── app.py
```

---

## production-cloud-run/ — GCP Cloud Run + CI/CD

Production-grade. Tự động build và deploy khi push code.

```
production-cloud-run/
├── cloudbuild.yaml     # CI/CD pipeline
├── service.yaml        # Cloud Run service definition
└── README.md           # Hướng dẫn chi tiết
```

---

## Câu hỏi thảo luận

1. Tại sao serverless (Lambda) không phải lúc nào cũng tốt cho AI agent?
2. "Cold start" là gì? Ảnh hưởng thế nào đến UX?
3. Khi nào nên upgrade từ Railway lên Cloud Run?


1. Serverless không phải lúc nào cũng phù hợp cho AI agent vì nhiều tác vụ AI có thời gian xử lý dài, cần giữ kết nối ổn định, hoặc cần warm context/cache. Lambda/serverless thường giới hạn thời gian chạy, tài nguyên, và có thể tăng chi phí khi traffic cao liên tục.
2. Cold start là độ trễ khi platform phải khởi tạo instance/container mới trước khi xử lý request đầu tiên. UX bị ảnh hưởng vì user thấy phản hồi chậm (vài giây đến chục giây), nhất là sau thời gian service "sleep" hoặc lúc scale từ 0.
3. Nên upgrade từ Railway lên Cloud Run khi cần kiểm soát production tốt hơn: autoscaling ổn định, cấu hình tài nguyên chi tiết, CI/CD bài bản, quan sát/logging tốt hơn, và yêu cầu độ tin cậy/chi phí tối ưu ở quy mô lớn hơn.
