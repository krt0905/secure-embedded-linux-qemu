# Quyết định nền tảng mô phỏng: Board + Hệ điều hành

> Trạng thái: ĐÃ CHỐT — QEMU ARM64 `virt` machine + Linux (Buildroot).
> Tài liệu này ghi lại căn cứ lựa chọn để bảo vệ trước hội đồng.

## 1. Quyết định

| Hạng mục | Lựa chọn | Ghi chú |
|---|---|---|
| Board mô phỏng | **QEMU `virt` (ARM64)** | `-M virt,secure=on` |
| CPU | `cortex-a57` (hoặc `max`) | ARMv8-A, đủ EL0–EL3 |
| Hệ điều hành | **Linux, build bằng Buildroot** | Kernel + rootfs tự build |
| Bootloader | U-Boot (`qemu_arm64_defconfig`) | BL33 |
| EL3 firmware | TF-A `PLAT=qemu` | BL1/BL2/BL31 |
| Secure World OS | OP-TEE OS (`qemu_v8` port) | BL32 |

## 2. Vì sao chọn `virt`?

1. **TF-A platform `qemu` chính thức** — build BL1/BL2/BL31 ngay, hỗ trợ
   `TRUSTED_BOARD_BOOT` (yêu cầu bắt buộc cho verification point V1).
2. **OP-TEE port `qemu_v8` chính thức** — combo TF-A + OP-TEE + U-Boot + Linux
   đã được cộng đồng test cùng nhau (OP-TEE manifest), pin version là build được.
3. **U-Boot `qemu_arm64_defconfig`** — FIT verified boot (V2) chạy được ngay.
4. **`-M virt,secure=on`** — bật Secure World, điều kiện để OP-TEE chạy.
5. **ARM64** — khớp yêu cầu ARM64 trong JD.

## 3. Các phương án đã loại và lý do

| Phương án | Lý do loại |
|---|---|
| `vexpress-a15` (ARM32) | Cũ, ARM32 — không khớp ARM64 |
| `sbsa-ref` | Cho server, phức tạp không cần thiết |
| `raspi3b`/`raspi4b` | Không có TF-A/OP-TEE chính thức, không bật được secure=on |
| Android Automotive | Cần BSP vendor thật, không build thực tế được trên `virt` |
| QNX | Đóng nguồn, cần license, không tự build được |

## 4. Vì sao Linux + Buildroot?

- Mã nguồn mở hoàn chỉnh: build được toolchain → kernel → rootfs từ đầu (yêu cầu
  "không phụ thuộc image tải sẵn").
- Linux kernel có sẵn **OP-TEE driver** (`drivers/tee/optee`) và TEE subsystem —
  Normal World client gọi TA qua TEE Client API không cần patch kernel.
- Buildroot có package sẵn cho `optee-client`, `optee-test`, dễ thêm custom package
  (`hu-app`).
- JD yêu cầu "Embedded Linux platform development" — Buildroot là công cụ chuẩn.

## 5. Giới hạn của lựa chọn này

- `virt` là máy ảo generic, **không mô phỏng SoC automotive cụ thể** (không có
  eFuse/OTP, không có peripheral ô tô như CAN/LIN). Xem `limitations.md`.
- Nếu sau này cần gần automotive hơn: có thể chuyển sang `PLAT=qemu_sbsa` hoặc
  board thật (Renesas R-Car, NXP i.MX8) — kiến trúc phần mềm không đổi vì mọi
  thành phần đều là ARM64 standard.
