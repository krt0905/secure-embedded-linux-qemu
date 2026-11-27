# Kiến trúc hệ thống

> Trạng thái: skeleton — điền nội dung khi hoàn thành Phase 0–5.

## 1. Tổng quan

Mô tả kiến trúc head unit mô phỏng trên QEMU ARM64 `virt` machine:

- Boot chain: ROM (mô phỏng) → TF-A → OP-TEE OS / U-Boot → Linux → app
- Trust boundaries: Normal World / Secure World, Host / Target, Factory / Device
- Thành phần: Buildroot rootfs, hu-app, TA, provisioning service

## 2. Sơ đồ khối

```text
TODO: điền sơ đồ khối sau Phase 1
```

## 3. Trust boundaries

| Boundary | Ranh giới | Bằng chứng kiểm soát |
|---|---|---|
| TB1 | Boot ROM ↔ TF-A | TODO Phase 2 |
| TB2 | TF-A ↔ OP-TEE / U-Boot | TODO Phase 2 |
| TB3 | U-Boot ↔ Linux kernel | TODO Phase 2 (FIT verify) |
| TB4 | Linux userspace ↔ Secure World | TODO Phase 3 (TEE Client API) |
| TB5 | Factory ↔ Device (provisioning) | TODO Phase 4 |

## 4. Thành phần phần mềm

| Thành phần | Vai trò | Nguồn |
|---|---|---|
| TF-A | EL3 firmware, verified boot | TODO pin version |
| OP-TEE OS | Secure World OS | TODO pin version |
| U-Boot | Bootloader Normal World, FIT verify | TODO pin version |
| Linux | Kernel | Buildroot |
| hu-app | Head unit application | tự viết |
| hu-ta | Trusted Application | tự viết |
