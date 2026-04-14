# Paperclip Custom — Internal Setup

> Phiên bản tối ưu hóa của [Paperclip](https://github.com/paperclipai/paperclip) dành cho mục đích nội bộ team.  
> Tập trung vào: **setup nhanh + vận hành ổn định + tránh các lỗi môi trường phổ biến.**

---

## Khác gì repo gốc?

| | Repo gốc | Repo này |
|---|---|---|
| YOLO Mode (auto-approve) | Bật mặc định | **Tắt** — AI phải chờ người duyệt |
| DATABASE_URL | `localhost` | `db` (đúng cho Docker network) |
| Serve UI | `false` | `true` — mở sẵn tại `localhost:3100` |
| `.env` | Tự tạo từ đầu | Có `.env.example` làm sẵn |
| Lỗi EACCES | Gặp sau onboard | Đã có hướng dẫn fix |

---

## Yêu cầu hệ thống

- [Git](https://git-scm.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

**Windows — bắt buộc thêm:**
- Bật WSL2 và Hyper-V
- Docker Desktop → Settings → General → bật `Use the WSL 2 based engine`

---

## Setup (≤ 10 phút)

### Bước 1 — Clone và cấu hình

```bash
git clone https://github.com/Esrgis/paperclip-custom.git
cd paperclip-custom

# Fix lỗi line ending trên Windows
git config core.autocrlf false
```

### Bước 2 — Tạo file `.env`

```bash
cp docker/.env.example docker/.env
```

Mở file `docker/.env` và điền API key:

```env
GOOGLE_GENERATIVE_AI_API_KEY=your_api_key_here
```

> Lấy Gemini API key miễn phí tại: https://aistudio.google.com  
> ⚠️ **Lưu ý:** Free tier chỉ đủ để test nhẹ. Workflow đầy đủ cần paid tier.

### Bước 3 — Cấp quyền thư mục (tránh lỗi EACCES)

**Windows:**
```powershell
icacls "docker/data" /grant "Everyone:(OI)(CI)F" /T
icacls "agent_workspace" /grant "Everyone:(OI)(CI)F" /T
```

**Linux / macOS:**
```bash
chmod -R 777 docker/data
chmod -R 777 agent_workspace
```

### Bước 4 — Khởi động

```bash
docker compose -f docker/docker-compose.yml up -d --build
```

Truy cập UI tại: **http://localhost:3100**

Lần đầu chạy sẽ hiện màn hình tạo tài khoản admin. Nếu không vào được, lấy invite link từ log:

```bash
docker logs docker-server-1 | grep "invites"
```

---

## Fix DNS (nếu agent không có mạng)

Docker Desktop → Settings → Docker Engine → thêm vào JSON:

```json
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
```

Restart Docker Desktop sau khi lưu.

---

## Troubleshooting

| Lỗi | Nguyên nhân | Cách xử lý |
|-----|------------|------------|
| `EACCES: permission denied` | Thiếu quyền thư mục | Chạy lại Bước 3 |
| Agent không có mạng | DNS Docker lỗi | Thêm DNS 8.8.8.8 |
| Container không chạy | Docker chưa bật | Mở Docker Desktop |
| Lỗi build | Cache cũ | `docker compose down -v` rồi build lại |
| Quota hết ngay | Free tier + context nặng | Dùng paid API key |
| `bootstrap invite` không vào được | Invite URL cũ | Chạy `docker exec -it docker-server-1 pnpm paperclipai auth bootstrap-ceo` |

---

## Lưu ý quan trọng

- Không commit file `.env` lên Git
- `chmod 777` / `Everyone:F` chỉ dùng cho môi trường **local dev**
- Production cần cấu hình permission an toàn hơn

---

## Cập nhật từ repo gốc

Repo này sync định kỳ với upstream:

```bash
git remote add upstream https://github.com/paperclipai/paperclip
git fetch upstream
git merge upstream/main
```

> Repo gốc: https://github.com/paperclipai/paperclip
