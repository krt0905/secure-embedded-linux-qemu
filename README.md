# Secure Automotive Head Unit Platform on ARM64 QEMU

> Đồ án: Secure Boot + Trusted Application + Key Management cho head unit automotive,
> mô phỏng trên QEMU ARM64 với các thành phần mã nguồn mở production-oriented:
> TF-A, OP-TEE, U-Boot, Linux/Buildroot.

## Luận điểm

Một head unit automotive phải:

1. **Boot từ một root of trust** — mọi image trong boot chain được verify trước khi thực thi.
2. **Chỉ chạy app đã được xác minh** — app binary phải có manifest ký hợp lệ mới được launch.
3. **Mọi thao tác key nằm trong vùng bảo vệ** — key sinh/lưu/dùng trong TEE (OP-TEE),
   có vòng đời đầy đủ: provisioning → storage → use → rotation → destruction.

## Kiến trúc

```text
[ROM mô phỏng] → TF-A BL2 (verify) → BL31 + OP-TEE OS + U-Boot
                                          │ U-Boot FIT verified boot
                                          ▼
                                     Linux kernel → init
                                          │ app verification (signed manifest)
                                          ▼
                                  hu-app ── TEE Client API ──► Trusted Application
                                                                  │ key ops + secure storage
```

Xem chi tiết: `docs/architecture.md`, `docs/boot-flow.md`.

## Cấu trúc repository

```text
secure-embedded-linux-qemu/
├── README.md                  ← file này
├── docs/                      ← bộ tài liệu cuối của đồ án
├── build/                     ← hệ thống build (Makefile tổng + config từng thành phần)
│   ├── buildroot/             ← config Buildroot + custom package hu-app
│   ├── tfa/                   ← config build TF-A
│   ├── u-boot/                ← config build U-Boot (FIT key, ITS)
│   └── optee/                 ← config build OP-TEE
├── scripts/                   ← script build/run/provision dùng một lệnh
├── optee/
│   ├── ta/                    ← Trusted Application (head unit TA)
│   └── client/                ← Normal-world client (thư viện + demo)
├── app-verify/                ← app manifest + launcher chỉ chạy app đã ký
├── pki/                       ← lab CA + cert profile cho provisioning
├── provisioning/              ← luồng provisioning key nhà máy (one-time)
├── test/
│   ├── positive/              ← test luồng hợp lệ
│   ├── negative/              ← test tampered/unsigned/wrong-key...
│   └── test-matrix.md         ← ma trận test tổng hợp
└── artifacts/                 ← boot log, evidence (không commit key)
```

## Quickstart (sau khi các phase hoàn thành)

```bash
# 1. Build toàn bộ platform
./scripts/build-all.sh

# 2. Boot QEMU
./scripts/run-qemu.sh

# 3. Provisioning key nhà máy (mô phỏng, one-time)
./scripts/provision-device.sh

# 4. Ký app manifest và demo end-to-end
./scripts/sign-app.sh
```

## Roadmap

Xem `thesis-scope-analysis.md` — 6 phase:

| Phase | Nội dung | Trạng thái |
|---|---|---|
| 0 | Môi trường + Buildroot platform | ⬜ |
| 1 | TF-A boot chain | ⬜ |
| 2 | Secure Boot (TF-A CoT + U-Boot FIT) | ⬜ |
| 3 | OP-TEE + Trusted Application | ⬜ |
| 4 | Key Management (provisioning, lifecycle) | ⬜ |
| 5 | App verification sau boot | ⬜ |
| 6 | Tích hợp, threat model, tài liệu | ⬜ |

> Mở rộng automotive: virtual eHSM (SHE/EVITA-style) mô phỏng bằng HSM Service TA
> trên OP-TEE — xem `docs/virtual-hsm.md`.

## Lưu ý bảo mật

- **Không bao giờ commit private key thật** vào repository. Key lab nằm trong `pki/keys/`
  và đã bị `.gitignore` loại trừ.
- QEMU không có eFuse/OTP hardware root of trust thật — trust anchor được mô phỏng
  bằng hash root public key nhúng vào TF-A. Xem `docs/limitations.md`.
