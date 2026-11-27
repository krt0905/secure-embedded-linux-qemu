#!/bin/bash
# Vào shell môi trường build trong Docker (mount repo vào /workspace).
# Dùng cho mọi lệnh build/boot để host sạch và build tái tạo được.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="selab-build:latest"

# Build image nếu chưa có
if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
    echo "==> Docker image chưa có, đang build..."
    docker build -t "${IMAGE_NAME}" -f "${ROOT_DIR}/docker/Dockerfile" "${ROOT_DIR}/docker/"
fi

exec docker run -it --rm \
    --name selab-build \
    -v "${ROOT_DIR}:/workspace" \
    -u "$(id -u):$(id -g)" \
    "${IMAGE_NAME}" /bin/bash
