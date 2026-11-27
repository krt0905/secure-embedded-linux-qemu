#!/bin/sh
# app-verify launcher: chỉ launch app có manifest ký hợp lệ (skeleton — Phase 5)
#
# Manifest format (đề xuất):
#   {
#     "app": "hu-app",
#     "version": 1,
#     "sha256": "<hash của app binary>",
#     "signature": "<RSA signature của các trường trên, ký bằng App Signing Key>"
#   }
#
# Luồng:
#   1. Đọc manifest của app
#   2. Verify signature bằng App Signing public key (qua openssl hoặc TA)
#   3. Verify sha256 của app binary khớp manifest
#   4. (anti-rollback) version phải >= version đã lưu
#   5. Chỉ khi tất cả pass mới exec app

set -eu

APP_DIR="${1:-/usr/bin}"
APP_NAME="${2:-hu-app}"
MANIFEST="${APP_DIR}/${APP_NAME}.manifest"

fail() {
    echo "app-verify: REFUSED: $1" >&2
    logger -t app-verify "REFUSED: $1" 2>/dev/null || true
    exit 1
}

[ -f "$MANIFEST" ] || fail "manifest not found: $MANIFEST"

# TODO Phase 5:
#  - verify signature của manifest (openssl dgst -verify hoặc qua TA)
#  - tính sha256 của app binary và so với manifest
#  - check version >= stored version (anti-rollback)
#  - chỉ exec khi tất cả pass

echo "app-verify: skeleton — verification TODO Phase 5"
# exec "${APP_DIR}/${APP_NAME}"
