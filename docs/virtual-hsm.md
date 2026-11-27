# Virtual eHSM — Mô phỏng Embedded HSM (EVITA/SHE-style)

> Trạng thái: thiết kế mở rộng — có thể triển khai trong Phase 3–4 hoặc làm stretch goal.
> Động cơ: bám sát automotive thật (SoC ô tô có eHSM: EVITA full/medium, SHE theo
> HIS Consortium), và bám sát JD Embedded Security (HSM/TEE-backed keys).

## 1. Định vị trong kiến trúc

```text
[Boot phase]  ROM → TF-A → U-Boot → kernel
              (verify dùng root key nhúng trong TF-A — mô phỏng OTP,
               vì boot xảy ra TRƯỚC khi TEE chạy)

[Runtime]     hu-app ──► HSM Service TA (virtual eHSM, Secure World)
                            │
                            ├── Key slots (SHE-style IDs)
                            ├── Crypto ops: sign/verify/encrypt/MAC
                            ├── Key flags + access policy
                            └── Key lifecycle: provision/rotate/destroy
```

Phân công rõ ràng:

- **TF-A verified boot** = root of trust giai đoạn boot (key nhúng trong firmware).
- **Virtual eHSM TA** = key safe giai đoạn runtime (key trong Secure World).

Đây chính xác mô hình thật: boot ROM dùng OTP root key, runtime dùng eHSM.

## 2. API surface (SHE-style, rút gọn)

| Command | Chức năng | Ghi chú |
|---|---|---|
| `HSM_GENERATE_KEY` | Sinh key vào slot | key không bao giờ export |
| `HSM_IMPORT_KEY` | Nạp key từ provisioning (bọc bằng key-encryption-key) | chỉ khi slot cho phép |
| `HSM_SIGN` / `HSM_VERIFY` | Ký/verify bằng key trong slot | |
| `HSM_ENCRYPT` / `HSM_DECRYPT` | Mã hóa/giải mã | |
| `HSM_GET_KEY_STATUS` | Đọc flags/version (không đọc key material) | |
| `HSM_ROTATE_KEY` | Cấp version mới, vô hiệu version cũ | |
| `HSM_DELETE_KEY` | Destroy key | |

## 3. Key slots (mô phỏng SHE)

| Slot | Mục đích | Flags mặc định |
|---|---|---|
| `MASTER_ECU_KEY` | Key gốc của ECU, dùng bọc key khác | WRITE_PROTECTED, BOOT_PROTECTED |
| `SECRET_KEY` | Key chung cho app | KEY_USAGE hạn chế |
| `DEVICE_IDENTITY_KEY` | Identity dùng provisioning cert | WRITE_PROTECTED, SIGN_ONLY |
| `BOOT_MAC_KEY` | Tính BOOT_MAC cho image | BOOT_PROTECTED |
| `RAM_KEY` | Key tạm, mất khi reset | volatile |

## 4. Key flags (mô phỏng SHE key attributes)

- `WRITE_PROTECTED` — không ghi đè được (trừ quy trình update đặc biệt)
- `BOOT_PROTECTED` — chỉ dùng cho boot-related ops
- `DEBUG_DISABLED` — không xuất key qua debug interface
- `KEY_USAGE` — sign-only / encrypt-only / decrypt-only / mac-only
- `EXPORT_ALLOWED` — mặc định FALSE cho mọi private key

## 5. Những gì mô phỏng KHÔNG thay thế được

Ghi vào `limitations.md`:

- Chống side-channel (DPA/SPA), fault injection, probe — HSM thật có countermeasure
  ở mức silicon.
- Key không thể bị dump bởi ai kiểm soát host QEMU — trên chip thật, key nằm trong
  vùng memory không map được từ ngoài HSM.
- Monotonic counter phần cứng chống rollback.
- Hiệu năng: HSM thật có crypto accelerator riêng, timing không so sánh được.

## 6. Tích hợp với các phase

| Phase | Tích hợp |
|---|---|
| Phase 3 | HSM TA là một TA đặc biệt; hu-ta có thể gọi qua hoặc gộp chung |
| Phase 4 | Provisioning ghi `DEVICE_IDENTITY_KEY` vào slot với WRITE_PROTECTED |
| Phase 5 | App verification có thể verify manifest qua HSM TA thay vì openssl |
| Negative tests | Thêm: ghi đè slot WRITE_PROTECTED → từ chối; dùng slot sai mục đích → từ chối; export key flag=FALSE → từ chối |

## 7. Quyết định triển khai

- **Lựa chọn A (khuyến nghị):** gộp vào Phase 3–4 — HSM TA chính là hu-ta mở rộng
  theo SHE-style API. Không tăng thời gian đáng kể, tăng giá trị automotive rõ rệt.
- **Lựa chọn B:** stretch goal sau Phase 5 nếu thời gian gấp.
