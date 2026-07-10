#!/usr/bin/env bash
# ============================================================================
#  restore.sh — nạp workflow + credential từ repo vào n8n (khôi phục / máy mới).
#
#  Cách chạy (từ thư mục gốc repo):
#     ./scripts/restore.sh
#
#  ĐIỀU KIỆN QUAN TRỌNG:
#   - .env phải có ĐÚNG N8N_ENCRYPTION_KEY đã dùng lúc export, nếu không
#     credential sẽ KHÔNG giải mã được ("Credentials could not be decrypted").
#   - docker compose đang chạy.
# ============================================================================
set -euo pipefail

cd "$(dirname "$0")/.."
SERVICE="n8n"

echo "==> Kéo bản mới nhất từ Git…"
git pull --ff-only

echo "==> Import credentials TRƯỚC (workflow cần credential để chạy)…"
docker compose exec -u node "$SERVICE" \
  n8n import:credentials --separate --input=/backup/credentials

echo "==> Import workflows…"
docker compose exec -u node "$SERVICE" \
  n8n import:workflow --separate --input=/backup/workflows

echo "==> Xong. Vào http://localhost:5678 kiểm tra lại."
echo "    (Community packages tự cài lại theo N8N_COMMUNITY_PACKAGES trong .env"
echo "     ở lần khởi động container — nếu vừa sửa .env thì chạy: docker compose up -d)"
