# Boot Flow

> Trạng thái: skeleton — điền nội dung khi hoàn thành Phase 1–2.

## 1. Boot stages

```text
[ROM mô phỏng bằng QEMU -bios / TF-A BL1 entrypoint]
        │ verify bằng SoC root public key (hash nhúng trong binary)
        ▼
[TF-A BL2]  ── verify ──► BL31 (EL3 Secure Monitor)
        │
        ├── verify ──► OP-TEE OS (Secure World, S-EL1)
        │
        └── verify ──► U-Boot (Normal World)
                            │ FIT verified boot (RSA signature, required="conf")
                            ▼
                       [Linux kernel + DTB + ramdisk]
                            │
                            ▼
                       [init → app-verify launcher → hu-app]
```

## 2. Execution levels

| Stage | EL | Secure? |
|---|---|---|
| TF-A BL1/BL2 | EL3 | Secure |
| BL31 (SMC handler) | EL3 | Secure |
| OP-TEE OS | S-EL1 | Secure |
| TA | S-EL0 | Secure |
| U-Boot | EL2/EL1 | Non-secure |
| Linux kernel | EL1 | Non-secure |
| hu-app | EL0 | Non-secure |

## 3. Verification points

| # | Điểm verify | Cơ chế | Kết quả fail |
|---|---|---|---|
| V1 | TF-A → BL31/OP-TEE/U-Boot | TODO: TRUSTED_BOARD_BOOT hoặc custom BL2 verify | halt boot |
| V2 | U-Boot → kernel/DTB | U-Boot FIT signature | từ chối boot |
| V3 | init → app binary | app manifest signature | không launch app |

## 4. Boot log tham chiếu

```text
TODO: dán boot log thực tế sau Phase 1 (artifacts/boot-log-phase1.log)
```
