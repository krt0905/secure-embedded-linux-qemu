#!/bin/bash
# Ký app manifest cho app-verify launcher (skeleton — Phase 5)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY_DIR="${ROOT_DIR}/pki/keys"

APP_BIN="${1:?Usage: sign-app.sh <app-binary> [version]}"
VERSION="${2:-1}"

echo "==> Tạo manifest cho ${APP_BIN} (version ${VERSION})"
# TODO Phase 5:
#   1. sha256sum app binary
#   2. ghi manifest JSON: app, version, sha256
#   3. ký manifest bằng App Signing Key:
#      openssl dgst -sha256 -sign "${KEY_DIR}/app-signing.key" ...
#   4. ghi signature vào manifest
echo "==> sign-app skeleton — TODO Phase 5."
