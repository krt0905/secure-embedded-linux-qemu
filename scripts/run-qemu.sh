#!/bin/bash
# Boot QEMU ARM64 với chuỗi platform đã build.
# Skeleton — sẽ hoàn thiện dần theo Phase 0 (kernel+rootfs) → Phase 1 (TF-A) → Phase 2 (secure boot).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMG_DIR="${ROOT_DIR}/artifacts/images"

# Phase 0: boot kernel + rootfs Buildroot trực tiếp
# Phase 1: thêm -bios bl1.bin (TF-A)
# Phase 2: boot qua signed FIT, thêm swtpm không dùng — chỉ TF-A verify
qemu-system-aarch64 \
    -M virt \
    -cpu cortex-a57 \
    -nographic \
    -smp 2 \
    -m 1024M \
    -kernel "${IMG_DIR}/Image" \
    -append "console=ttyAMA0 root=/dev/vda" \
    -drive "file=${IMG_DIR}/rootfs.ext4,if=virtio,format=raw" \
    "$@"

# TODO Phase 1+: thay bằng chuỗi TF-A:
#   -bios "${IMG_DIR}/bl1.bin"
#   -machine virt,secure=on
#   load OP-TEE + U-Boot qua FIP
