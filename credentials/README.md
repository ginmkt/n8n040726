# credentials/  ⚠️ CHỈ CHỨA FILE ĐÃ MÃ HÓA

Nơi chứa credential export ra — **luôn ở dạng ĐÃ MÃ HÓA**.

## Quy tắc bảo mật (đọc kỹ)

- File ở đây được tạo bởi `scripts/backup.sh` với lệnh
  `n8n export:credentials --backup` → **giữ nguyên bản mã hóa**.
- **KHÔNG BAO GIỜ** chạy `export:credentials --decrypted` rồi commit vào đây.
  Bản `--decrypted` là API key / token / mật khẩu ở dạng **chữ thô** — lộ lên
  Git (kể cả repo private) là mất an toàn nghiêm trọng.
- `.gitignore` đã chặn sẵn các file `*decrypted*` / `*.plain.json` để phòng hờ.
- Các file mã hóa này **chỉ giải mã được** trên instance có **cùng
  `N8N_ENCRYPTION_KEY`**. Key đó **KHÔNG nằm trong repo** — cất riêng ở
  password manager / vault.

## Khôi phục

`scripts/restore.sh` sẽ chạy `n8n import:credentials` để nạp lại. Nhớ đảm bảo
`.env` có đúng `N8N_ENCRYPTION_KEY` trước khi import.

## Giữ repo ở chế độ PRIVATE

Dù credential đã mã hóa, vẫn để repo **private** và giới hạn quyền ghi.
