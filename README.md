# n8n-config

Repo để **version-control n8n**: lưu workflows, credentials (đã mã hóa) và
danh sách community packages lên GitHub, có thể khôi phục về máy mới.

```
n8n-config/
├── docker-compose.yml     # n8n + PostgreSQL; packages khai báo bằng env
├── .env.example           # mẫu cấu hình → copy thành .env (đừng commit .env)
├── .gitignore             # chặn .env, credential giải mã, key, volume cục bộ
├── workflows/             # workflow JSON (an toàn) — do backup.sh sinh ra
├── credentials/           # credential ĐÃ MÃ HÓA — do backup.sh sinh ra
└── scripts/
    ├── backup.sh          # export + git commit + push
    └── restore.sh         # git pull + import vào n8n
```

> ⚠️ **Repo này phải để PRIVATE.** Và `N8N_ENCRYPTION_KEY` **không bao giờ**
> nằm trong repo — cất riêng ở password manager / vault.

---

## 1. Cài đặt lần đầu

Cần sẵn: Docker + Docker Compose, Git.

```bash
# 1) Lấy code (hoặc copy thư mục này vào máy)
cd n8n-config

# 2) Tạo file .env từ mẫu và điền giá trị
cp .env.example .env

# 3) Sinh encryption key rồi dán vào N8N_ENCRYPTION_KEY trong .env
openssl rand -hex 32

# 4) (khuyến nghị) lưu ngay key đó vào password manager / vault

# 5) Khởi động
docker compose up -d

# 6) Mở http://localhost:5678 và tạo tài khoản owner
```

---

## 2. Nối repo với GitHub

Tạo 1 repo **private** trên GitHub (vd `n8n-config`), rồi:

```bash
git init
git add .
git commit -m "init: n8n config"
git branch -M main
git remote add origin git@github.com:<user>/n8n-config.git   # nên dùng SSH
git push -u origin main
```

Dùng SSH key sẽ tiện hơn nhúng token vào URL. Nếu buộc phải dùng HTTPS thì tạo
**Personal Access Token** (scope `repo`) và Git sẽ hỏi khi push.

---

## 3. Backup (đẩy workflow + credential lên GitHub)

```bash
./scripts/backup.sh            # export → commit → push
./scripts/backup.sh --no-push  # chỉ export + commit (tự push sau)
```

Script sẽ:
1. `n8n export:workflow --backup`  → `workflows/` (mỗi wf 1 file).
2. `n8n export:credentials --backup` → `credentials/` (**đã mã hóa**).
3. Ghi `N8N_COMMUNITY_PACKAGES` ra `packages.lock` để tham chiếu.
4. `git add / commit / push`.

**Chạy định kỳ (cron)** — ví dụ mỗi ngày 2h sáng:

```bash
crontab -e
# thêm dòng (sửa đường dẫn cho đúng máy bạn):
0 2 * * * cd /duong/dan/n8n-config && ./scripts/backup.sh >> backup.log 2>&1
```

---

## 4. Restore (khôi phục / dựng máy mới)

```bash
# đảm bảo .env có ĐÚNG N8N_ENCRYPTION_KEY như lúc export
docker compose up -d
./scripts/restore.sh
```

Thứ tự: import **credentials trước**, rồi **workflows** (vì workflow tham chiếu
tới credential). Nếu key sai, credential sẽ báo *"could not be decrypted"*.

---

## 5. Thêm / bớt community node (packages)

Packages được quản lý **bằng biến môi trường** trong `.env`:

```bash
# .env
N8N_COMMUNITY_PACKAGES=[{"name":"n8n-nodes-mcp","version":"0.1.20"}]
```

Sau khi sửa:

```bash
docker compose up -d      # n8n đồng bộ lại danh sách khi khởi động
git add .env.example      # (chỉ commit .env.example, KHÔNG commit .env)
```

Vì bật `N8N_COMMUNITY_PACKAGES_MANAGED_BY_ENV=true`:
- Trang **Settings → Community Nodes** trong UI thành **read-only**.
- Lần đầu bật, n8n **gỡ** mọi node không có trong list → liệt kê đủ node bạn
  đang dùng vào `.env` trước khi chạy.

> Muốn cài node qua UI như bình thường thì đặt
> `N8N_COMMUNITY_PACKAGES_MANAGED_BY_ENV=false` trong `docker-compose.yml`,
> nhưng khi đó danh sách package sẽ không còn được version-control bằng env.

---

## 6. Ghi nhớ về bảo mật & phạm vi

- **Encryption key** là thứ quan trọng nhất. Mất nó = mất toàn bộ credential.
  Lưu ở vault, ngoài repo.
- `credentials/` **chỉ** chứa bản mã hóa. Không bao giờ commit bản `--decrypted`.
- Repo để **private**, giới hạn quyền ghi.
- **Phạm vi của repo này** = config (workflows + credentials + packages).
  Nó **không** thay thế backup toàn bộ database (execution history, users…).
  Nếu cần DR đầy đủ, backup thêm PostgreSQL bằng `pg_dump` / snapshot volume
  `postgres_data` (một việc riêng, độc lập với repo này).
