#!/usr/bin/env bash
# ============================================================================
#  backup.sh — export workflow + credential (ĐÃ MÃ HÓA) rồi push lên GitHub.
#
#  Cách chạy (từ thư mục gốc repo):
#     ./scripts/backup.sh                 # export + commit + push
#     ./scripts/backup.sh --no-push       # chỉ export + commit, không push
#
#  Yêu cầu: docker compose đang chạy; đã `git remote add origin ...`.
# ============================================================================
set -euo pipefail

# về thư mục gốc repo (thư mục chứa docker-compose.yml)
cd "$(dirname "$0")/.."

SERVICE="n8n"          # tên service trong docker-compose.yml
PUSH=1
[[ "${1:-}" == "--no-push" ]] && PUSH=0

echo "==> Export workflows (JSON, mỗi wf 1 file)…"
docker compose exec -u node "$SERVICE" \
  n8n export:workflow --backup --output=/backup/workflows

echo "==> Export credentials (ĐÃ MÃ HÓA — an toàn để lưu Git)…"
# LƯU Ý: KHÔNG dùng --decrypted. --backup giữ nguyên bản mã hóa.
docker compose exec -u node "$SERVICE" \
  n8n export:credentials --backup --output=/backup/credentials

echo "==> Ghi lại danh sách community packages đang cài (tham chiếu)…"
# Đọc từ file .env cho khớp với thứ đang được quản lý bằng env.
grep '^N8N_COMMUNITY_PACKAGES=' .env > packages.lock 2>/dev/null || true

# chặn double-check: không cho file *decrypted* lọt vào commit
if git status --porcelain | grep -qiE 'decrypted|\.plain\.'; then
  echo "!! Phát hiện file có vẻ đã giải mã. Dừng lại để bạn kiểm tra." >&2
  exit 1
fi

echo "==> Git commit…"
git add workflows credentials packages.lock
if git diff --cached --quiet; then
  echo "   Không có thay đổi. Bỏ qua commit."
  exit 0
fi
git commit -m "backup: n8n workflows + credentials ($(date -u +%Y-%m-%dT%H:%M:%SZ))"

if [[ "$PUSH" -eq 1 ]]; then
  echo "==> Git push…"
  git push
  echo "==> Xong. Đã đẩy lên remote."
else
  echo "==> Đã commit (chưa push). Chạy 'git push' khi sẵn sàng."
fi
