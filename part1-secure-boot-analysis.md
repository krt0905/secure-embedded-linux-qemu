# Phần 1: Secure Boot Flow — Phân tích chi tiết

> Phạm vi Phần 1: **mọi thứ xảy ra trước khi Linux kernel bắt đầu thực thi**.
> Mục tiêu: xây dựng chain of trust hoàn chỉnh trên QEMU ARM64 — từ boot ROM (mô phỏng)
> đến kernel — với verification tại MỌI handoff point, kèm negative tests chứng minh
> image bị sửa/không ký bị từ chối ở đúng stage.
>
> Phần 2 (runtime security: OP-TEE TA, key management, app verification, eHSM)
> được phân tích riêng — xem `part2-runtime-security-analysis.md` (sẽ tạo sau).

---

## 1. Ranh giới giữa Phần 1 và Phần 2

```text
┌─────────────────────── PHẦN 1: SECURE BOOT FLOW ───────────────────────┐
│                                                                         │
│  [Boot ROM mô phỏng] → TF-A BL2 → BL31 + OP-TEE OS + U-Boot             │
│                            │                                            │
│                            └── verify từng image trước khi handoff      │
│                                                                         │
│  U-Boot → FIT verified boot → Linux kernel                              │
│                                                                         │
│  ═══════════ ranh giới: kernel bắt đầu thực thi ═══════════             │
└─────────────────────────────────────────────────────────────────────────┘
┌─────────────────────── PHẦN 2: RUNTIME SECURITY ───────────────────────┐
│  init → app verification → hu-app → TA → key management → eHSM          │
└─────────────────────────────────────────────────────────────────────────┘
```

Lưu ý quan trọng: **OP-TEE OS nằm trong Phần 1** (vì nó được TF-A load và verify
trước kernel), nhưng **Trusted Application nằm trong Phần 2** (vì TA chạy sau khi
Linux boot). Trong Phần 1, OP-TEE OS chỉ cần boot được — chưa cần viết TA.

---

## 2. Boot chain mục tiêu trên QEMU

```text
QEMU ARM64 virt (secure=on)
   │
   ▼
[BL1]  — QEMU load bl1.bin qua -bios (mô phỏng boot ROM)
   │      trust anchor: hash root public key NHÚNG TRONG bl1.bin
   │      (mô phỏng OTP/eFuse — ghi rõ giới hạn trong limitations.md)
   ▼
[BL2]  — TF-A boot loader, verify từng image trong FIP:
   │      ├── verify BL31 certificate + image
   │      ├── verify OP-TEE OS certificate + image
   │      └── verify U-Boot certificate + image
   ▼
[BL31] — EL3 Secure Monitor (SMC handler)
   │
   ├──► [OP-TEE OS]  Secure World, S-EL1 — boot xong trả quyền về BL31
   │
   └──► [U-Boot]     Normal World
           │  FIT verified boot:
           │  verify RSA signature của kernel + DTB (+ ramdisk)
           │  pubkey nhúng trong u-boot.dtb, required = "conf"
           ▼
       [Linux kernel + DTB] → init → (hết Phần 1)
```

### Hai verification points (V1, V2)

| # | Điểm | Cơ chế | Ai verify | Trust anchor |
|---|---|---|---|---|
| V1 | TF-A → BL31 / OP-TEE / U-Boot | TF-A Trusted Board Boot (cert chain trong FIP) | BL2 | Root key hash trong BL1 |
| V2 | U-Boot → kernel/DTB | U-Boot FIT signature verification | U-Boot | Public key trong u-boot.dtb |

---

## 3. Những gì cần làm — phân rã công việc

### Bước 1: Platform nền tảng (2 tuần)

**Cần làm:**
- Cài QEMU system-aarch64, toolchain AArch64 cross-compile.
- Buildroot cho QEMU `virt`: toolchain + kernel Image + rootfs.ext4.
- Boot thẳng kernel (chưa có TF-A) để có baseline: `run-qemu.sh` hiện tại.
- Lưu boot log baseline vào `artifacts/boot-logs/`.

**Kết quả:** Linux boot được, có log tham chiếu để so sánh sau khi thêm TF-A.

---

### Bước 2: TF-A tham gia boot chain (2 tuần)

**Cần làm:**
- Clone TF-A (pin version), build `PLAT=qemu` với `secure=on`.
- Build U-Boot cho QEMU (BL33).
- Tạo FIP chứa: BL2, BL31, OP-TEE OS (BL32 — có thể placeholder trước), U-Boot.
- Boot: `qemu-system-aarch64 -M virt,secure=on -bios bl1.bin`.
- Đọc và giải thích từng dòng boot log: BL1 → BL2 → BL31 → U-Boot.
- Vẽ sơ đồ boot flow + execution levels đúng với lab.

**Kết quả:** boot chain TF-A → U-Boot → Linux chạy được, có log + sơ đồ.
**Chưa cần verify signature** — mục đích bước này là hiểu cơ chế handoff.

---

### Bước 3: TF-A Trusted Board Boot — V1 (2–3 tuần)

**Cần làm:**
1. **Key hierarchy cho boot** (tuần 1):
   - Tạo cặp SoC root key (trust anchor) + boot signing key.
   - Quyết định: hash root public key nhúng vào BL1 (mô phỏng OTP).
   - Tài liệu hóa hierarchy: root → trusted key → image signing.
2. **Bật TBB** (tuần 2):
   - Build TF-A với `TRUSTED_BOARD_BOOT=1 GENERATE_COT=1` (dùng mbedTLS).
   - TF-A sinh certificate chain: từng image có cert được ký, cert được ký bởi key cấp trên.
   - Hiểu vai trò từng cert: `TrustedKeyCertificate`, `SCPFW/BL31/BL32/BL33 content certs`.
3. **Kiểm chứng** (tuần 3):
   - Boot hợp lệ pass qua V1.
   - Sửa 1 byte trong BL31/U-Boot trong FIP → BL2 phải từ chối, boot halt.

**Phương án fallback** (nếu TBB quá phức tạp trên QEMU):
- Tự implement verify đơn giản ở BL2: hash + RSA verify từng image trong FIP
  bằng pubkey nhúng. Đơn giản hơn, vẫn đạt luận điểm, nhưng mất cert chain.
- Quyết định: thử TBB trước, fallback nếu >2 tuần không xong.

---

### Bước 4: U-Boot FIT verified boot — V2 (2 tuần)

**Cần làm:**
1. Tạo `.its` mô tả FIT image: kernel + DTB (+ ramdisk) trong 1 bundle.
2. Bật `CONFIG_FIT_SIGNATURE` + `CONFIG_RSA` trong U-Boot.
3. Ký FIT bằng `mkimage -F -k <keydir> -K u-boot.dtb -r kernel.itb`:
   - private key ký, public key tự động nhúng vào `u-boot.dtb`.
   - `required = "conf"` trong `.its` → U-Boot BẮT BUỘC verify configuration.
4. Boot qua FIT hợp lệ → pass.
5. Negative: sửa kernel trong FIT → U-Boot từ chối, không boot.

**Kết quả:** V2 hoạt động độc lập với V1 — có thể demo riêng từng điểm.

---

### Bước 5: Negative tests + evidence (1–2 tuần)

**Bộ test bắt buộc (map với test-matrix.md):**

| ID | Kịch bản | Thao tác | Kỳ vọng |
|---|---|---|---|
| SB-P1 | Boot hợp lệ end-to-end | boot bình thường | đến shell |
| SB-N1 | Sửa BL31 trong FIP | flip 1 byte | BL2 từ chối, halt |
| SB-N2 | Sửa U-Boot trong FIP | flip 1 byte | BL2 từ chối, halt |
| SB-N3 | Sửa kernel trong FIT | flip 1 byte | U-Boot từ chối |
| SB-N4 | FIT không ký | build FIT không sign | U-Boot từ chối |
| SB-N5 | Ký bằng key sai | dùng key khác | từ chối ở V1 hoặc V2 |
| SB-N6 | Thay cert trong FIP | swap cert | BL2 từ chối |

**Evidence cho từng test:** boot log đầy đủ lưu vào `artifacts/boot-logs/`,
đặt tên `sb-n1-tampered-bl31.log` v.v.

---

### Bước 6: Tài liệu Phần 1 (1 tuần)

- `docs/boot-flow.md` — điền sơ đồ thật + boot log thật.
- `docs/architecture.md` — điền trust boundaries TB1–TB3.
- Key hierarchy cho boot artifact (đưa vào `docs/key-management.md` phần boot).
- Cập nhật `docs/limitations.md`: mô phỏng OTP bằng key hash trong BL1.
- Cập nhật `docs/security-test-report.md` với kết quả SB-*.

---

## 4. Timeline Phần 1

```text
Tuần 1–2   Bước 1: Platform nền tảng (Buildroot, baseline boot)
Tuần 3–4   Bước 2: TF-A + U-Boot vào boot chain (chưa verify)
Tuần 5–7   Bước 3: TF-A TBB — key hierarchy + cert chain (V1)
Tuần 8–9   Bước 4: U-Boot FIT verified boot (V2)
Tuần 10    Bước 5: Negative tests + evidence
Tuần 11    Bước 6: Tài liệu Phần 1
```

Tổng: **~11 tuần**. Nếu TBB gặp khó (bước 3), dùng fallback tự implement verify
ở BL2 để giữ tiến độ — luận điểm không đổi.

---

## 5. Tiêu chí hoàn thành Phần 1

- [ ] Boot chain: BL1 → BL2 → BL31 → OP-TEE OS → U-Boot → Linux, có log từng stage.
- [ ] V1: BL2 verify BL31/OP-TEE/U-Boot trước khi handoff.
- [ ] V2: U-Boot verify kernel/DTB trước khi boot.
- [ ] ≥5 negative tests có log chứng minh từ chối ở đúng stage.
- [ ] Key hierarchy cho boot được tài liệu hóa (root key → signing key → certs).
- [ ] Trust anchor + giới hạn mô phỏng OTP được ghi rõ.
- [ ] Build tái tạo được bằng `scripts/build-all.sh`.
- [ ] Sơ đồ boot flow + execution levels khớp với log thật.

---

## 6. Rủi ro riêng của Phần 1

| Rủi ro | Ảnh hưởng | Giảm thiểu |
|---|---|---|
| TBB cert chain trên QEMU khó cấu hình | Bước 3 trễ | Fallback: custom verify ở BL2 (hash + RSA) |
| OP-TEE OS chưa có ở bước 2 | FIP thiếu BL32 | Dùng placeholder hoặc build OP-TEE OS sớm hơn dự kiến |
| Version TF-A/U-Boot không tương thích | Build fail | Pin version từ repo OP-TEE manifest (đã test cùng nhau) |
| FIT signature không enforce | V2 vô nghĩa | Kiểm tra `required = "conf"` + test SB-N4 phải FAIL khi thiếu |
| Nhầm lẫn giữa verified boot và measured boot | Sai phạm vi | Phần 1 chỉ làm verified boot; measured boot/TPM đã bị cắt |

---

## 7. Đầu ra của Phần 1 cho Phần 2

Phần 1 cung cấp nền cho Phần 2:

1. **OP-TEE OS đã boot** → Phần 2 chỉ cần viết TA + client.
2. **Key hierarchy đã có** → Phần 2 mở rộng thêm device key + app signing key.
3. **Rootfs Buildroot ổn định** → Phần 2 thêm hu-app, launcher, provisioning tools.
4. **Quy trình negative test + evidence** → tái sử dụng cho runtime tests.
