# workflows/

Nơi chứa workflow export ra dạng JSON (mỗi workflow 1 file, đặt tên theo ID).

- File được tạo/cập nhật tự động bởi `scripts/backup.sh`
  (lệnh `n8n export:workflow --backup`).
- An toàn để commit lên Git — đây là logic workflow, không chứa secret.
- Khôi phục bằng `scripts/restore.sh` (`n8n import:workflow`).

Đừng sửa tay các file ở đây trừ khi bạn biết rõ mình đang làm gì.
