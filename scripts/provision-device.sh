#!/bin/bash
# Provisioning device key — mô phỏng dây chuyền nhà máy (skeleton — Phase 4)
#
# Luồng:
#   1. Target: gọi TA sinh Device Identity Key BÊN TRONG TEE
#   2. Target: xuất public key ra Normal World (được phép)
#   3. Host:   Lab Root CA ký Device Certificate từ public key đó
#   4. Target: ghi cert vào secure storage + set one-time flag
#   5. Chạy lại script này phải bị TỪ CHỐI (one-time provisioning)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKI_DIR="${ROOT_DIR}/pki"

echo "==> [1/4] Kiểm tra Lab Root CA"
# TODO Phase 4:
#   [ -f "${PKI_DIR}/ca/root-ca.key" ] || ./scripts/gen-ca.sh

echo "==> [2/4] Target: sinh device key trong TEE"
# TODO Phase 4:
#   hu-client provision-gen-key  → xuất public key ra /tmp/device-pub.pem

echo "==> [3/4] Host: CA ký device certificate"
# TODO Phase 4:
#   openssl x509 -req -CA root-ca.pem -CAkey root-ca.key ... device.crt

echo "==> [4/4] Target: ghi cert vào secure storage + one-time flag"
# TODO Phase 4:
#   hu-client provision-store device.crt
#   → lần chạy thứ 2 phải trả TEE_ERROR_... và script fail

echo "==> Provisioning skeleton — TODO Phase 4."
