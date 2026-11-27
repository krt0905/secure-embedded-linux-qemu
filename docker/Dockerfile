# Dockerfile — Môi trường build cho Secure Embedded Linux Platform (QEMU ARM64)
#
# Chứa mọi công cụ cần để build: Buildroot, TF-A, OP-TEE, U-Boot, Linux kernel.
# QEMU chạy trong container để boot image sau khi build.
#
# Build image:
#   docker build -t selab-build -f docker/Dockerfile docker/
#
# Chạy container (mount repo vào /workspace):
#   ./scripts/dev-shell.sh
#
# Build platform trong container:
#   ./scripts/build-all.sh

FROM ubuntu:22.04

# Proxy (tùy môi trường mạng — truyền qua --build-arg khi cần)
ARG http_proxy=""
ARG https_proxy=""
ARG no_proxy=""

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8

# Toolchain + dependencies cho Buildroot/TF-A/OP-TEE/U-Boot + QEMU để boot
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc g++ make git wget curl ca-certificates \
    libssl-dev libncurses-dev flex bison bc cpio rsync unzip file \
    sed patch tar gzip bzip2 xz-utils perl python3 python3-dev python3-setuptools \
    device-tree-compiler u-boot-tools swig \
    gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu \
    qemu-system-arm qemu-utils \
    vim less sudo locales \
    && rm -rf /var/lib/apt/lists/*

# User không phải root (Buildroot không cho build bằng root)
RUN useradd -m -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/builder

USER builder
WORKDIR /workspace

CMD ["/bin/bash"]
