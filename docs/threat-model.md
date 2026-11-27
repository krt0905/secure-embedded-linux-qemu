# Threat Model

> Trạng thái: skeleton — điền nội dung khi hoàn thành Phase 6.

## 1. Assets

| Asset | Giá trị | Vị trí |
|---|---|---|
| Boot images (BL31, OP-TEE, U-Boot, kernel) | cao | FIP / boot partition |
| Device identity key | rất cao | TEE secure storage |
| App keys | cao | TEE secure storage |
| App binaries + manifest | cao | rootfs |
| Device certificate | trung bình | TEE secure storage |

## 2. Attack scenarios ↔ Negative tests

| # | Kẻ tấn công | Kịch bản | Kiểm soát | Test |
|---|---|---|---|---|
| A1 | Có quyền ghi storage | Sửa kernel image | TF-A/U-Boot verify | test/negative/ |
| A2 | Có quyền ghi storage | Thay app binary | app manifest verify | test/negative/ |
| A3 | Malicious app | Đọc private key từ TEE | TEE isolation | test/negative/ |
| A4 | Malicious app | Re-provision key | one-time flag | test/negative/ |
| A5 | Rollback attack | Cài app version cũ | version check trong manifest | TODO Phase 5 |

## 3. Trust assumptions

- Host build machine được tin cậy (private key không bao giờ ở target).
- QEMU không mô phỏng physical attack (glitch, probe) — xem `limitations.md`.

## 4. Residual risk

```text
TODO: điền sau Phase 6
```
