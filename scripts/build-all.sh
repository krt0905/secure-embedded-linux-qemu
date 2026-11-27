#!/bin/bash
# Build toàn bộ platform: TF-A → OP-TEE → U-Boot → Buildroot (kernel + rootfs)
# Skeleton — từng bước sẽ được hoàn thành theo Phase 0–3.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
OUT_DIR="${ROOT_DIR}/artifacts/images"
mkdir -p "${OUT_DIR}"

echo "==> [1/4] Buildroot (toolchain + kernel + rootfs + hu-app)"
# TODO Phase 0:
#   git clone buildroot (pin version) vào build/buildroot/
#   make BR2_PACKAGE_HU_APP=y  (custom package)
#   cp output/images/* "${OUT_DIR}/"

echo "==> [2/4] TF-A"
# TODO Phase 1:
#   make -C build/tfa PLAT=qemu ARCH=aarch64 bl1 bl2 bl31 fip
# TODO Phase 2: thêm TRUSTED_BOARD_BOOT / GENERATE_COT + key hierarchy

echo "==> [3/4] OP-TEE"
# TODO Phase 3:
#   build optee_os (Secure World) + optee_client + optee_test
#   build hu-ta bằng dev kit

echo "==> [4/4] U-Boot (FIT verified boot)"
# TODO Phase 2:
#   build u-boot với pubkey nhúng vào DTB
#   mkimage -f kernel.its kernel.itb (signed FIT)

echo "==> Build skeleton hoàn tất — các bước TODO sẽ được điền theo phase."
