# Project 1: Secure Embedded Linux Platform trên QEMU

## 1. Mục tiêu

Xây dựng một nền tảng Embedded Linux ARM64 có chuỗi khởi động, vùng thực thi tin cậy, quản lý khóa, hardening, giao tiếp bảo mật và cập nhật firmware an toàn. Toàn bộ lab chạy bằng QEMU, không phụ thuộc board vật lý.

Project tập trung vào **implementation ở mức platform**: tự build, tích hợp, cấu hình, kiểm thử và chứng minh từng cơ chế bảo mật hoạt động.

## 2. Kiến trúc tổng quát

```text
Host Linux
  |
  +-- QEMU ARM64 virt machine
        |
        +-- Trusted Firmware-A / EL3
        +-- OP-TEE / Secure World
        +-- U-Boot
        +-- Linux kernel
        +-- Buildroot root filesystem
        +-- Normal-world applications
        +-- swtpm / virtual TPM
```

Luồng ứng dụng TEE:

```text
Linux client application
        |
        v
TEE Client API
        |
        v
OP-TEE Trusted Application
        |
        v
Key generation / signing / verification / secure storage
```

## 3. Project này cover gì?

### Các yêu cầu cốt lõi được cover trực tiếp

- Buildroot
- Embedded Linux
- ARM64 architecture và ARM Exception Levels
- Boot flow và low-level system architecture
- Trusted Firmware-A
- TrustZone architecture ở mức phần mềm và luồng Secure World/Normal World
- OP-TEE và Trusted Applications
- U-Boot
- Secure/verified boot ở mức lab
- Linux system hardening
- SELinux
- TPM 2.0 thông qua `swtpm`
- PKI, certificate và key management
- TLS và mutual TLS
- Secure storage
- Secure update OTA
- Firmware signing, verification và rollback handling
- Secure code review và security testing cơ bản

### Cover một phần

- Hardware-based security mechanisms: cover API, kiến trúc và key lifecycle; không cover bảo vệ vật lý của silicon.
- HSM/Secure Element: mô phỏng hành vi qua TPM, PKCS#11 hoặc software token; không thay thế HSM thật.
- Secure Boot: cover ký, xác minh và chain of trust; không cover eFuse/OTP và root key provisioning trên silicon thật.
- BSP development: cover build/integration trên QEMU `virt`; không cover PMIC, DDR training, clock, PHY và peripheral bring-up của SoC thật.
- Automotive cybersecurity: cover các building block bảo mật dùng trong ECU/IVI; chưa phải hệ thống automotive nhiều ECU.

### Chưa cover hoặc cover rất ít

- Qualcomm-specific BSP, QSEE và Qualcomm Secure Processor
- Android/Android Automotive Security
- AVB, dm-verity, KeyMint/Keymaster, SEAndroid
- eFuse/OTP provisioning thật
- Physical tamper resistance và side-channel testing
- Driver bring-up trên phần cứng thật
- AUTOSAR/QNX-specific security

## 4. Các module thực hiện

### Module 1: ARM64 platform bring-up

**Nội dung**

- Build và boot QEMU ARM64.
- Build Linux kernel và Buildroot rootfs.
- Tạo package/application riêng trong Buildroot.
- Quan sát boot log và xác định vai trò của từng thành phần.
- Nghiên cứu EL0, EL1, EL2, EL3 và SMC.

**Deliverable**

- Script build có thể tái tạo.
- Image boot thành công.
- Sơ đồ boot flow.
- Log chứng minh kernel và rootfs do project tự build.

### Module 2: Trusted Firmware-A, OP-TEE và TrustZone

**Nội dung**

- Tích hợp TF-A và OP-TEE vào boot chain.
- Viết một normal-world client và một Trusted Application.
- Trusted Application sinh khóa, ký dữ liệu và xác minh chữ ký.
- Bảo vệ khóa và dữ liệu bằng secure storage của OP-TEE.
- Phân tích đường đi của request từ Linux đến Secure World.

**Deliverable**

- Trusted Application và client source code.
- Sequence diagram cho GlobalPlatform TEE Client API.
- Demo key không được xử lý trực tiếp trong normal-world application.
- Negative tests cho client hoặc dữ liệu không hợp lệ.

### Module 3: Secure/verified boot và chain of trust

**Nội dung**

- Xây dựng key hierarchy cho boot artifact.
- Ký bootloader, kernel, DTB hoặc FIT image tùy thiết kế.
- Xác minh chữ ký trước khi boot artifact kế tiếp.
- Thay đổi image để chứng minh cơ chế phát hiện tampering.
- Ghi rõ giới hạn: QEMU không cung cấp eFuse/OTP hardware root of trust giống SoC sản phẩm.

**Deliverable**

- Signed image boot thành công.
- Tampered hoặc unsigned image bị từ chối.
- Tài liệu key hierarchy, trust boundary và threat assumptions.

### Module 4: Virtual TPM và measured boot

**Nội dung**

- Kết nối `swtpm` với QEMU.
- Dùng TPM 2.0 tools để tạo key, sign và verify.
- Thực hành PCR extend/read.
- Seal secret theo PCR state và kiểm thử unseal.
- Thực hiện attestation demo ở mức lab.

**Deliverable**

- TPM-backed key demo.
- PCR measurement log.
- Secret chỉ unseal được ở trạng thái dự kiến.
- Tài liệu phân biệt verified boot và measured boot.

### Module 5: PKI, TLS và device identity

**Nội dung**

- Tạo Root CA và Intermediate CA cho lab.
- Cấp server certificate và device/client certificate.
- Thiết lập TLS và mutual TLS.
- Kiểm thử certificate không tin cậy, hết hạn hoặc sai identity.
- Nếu phù hợp, dùng TPM/TEE-backed private key qua PKCS#11.

**Deliverable**

- CA hierarchy và certificate policy đơn giản.
- mTLS client/server chạy được.
- Negative tests cho certificate và hostname/identity validation.
- Packet capture chứng minh payload không truyền plaintext.

### Module 6: SELinux và Linux hardening

**Nội dung**

- Bật SELinux trong kernel/userspace phù hợp với image.
- Tạo domain riêng cho một ứng dụng mẫu.
- Chỉ cấp quyền tối thiểu cần thiết.
- Chặn truy cập file, socket hoặc device ngoài phạm vi.
- Áp dụng thêm hardening: capabilities, read-only filesystem where applicable, service privilege reduction và compiler hardening.

**Deliverable**

- SELinux policy riêng.
- Allowed operation hoạt động.
- Forbidden operation bị AVC denial.
- Báo cáo trước/sau hardening.

### Module 7: Secure OTA update

**Nội dung**

- Dùng RAUC hoặc SWUpdate.
- Thiết kế A/B root filesystem hoặc chiến lược recovery tương đương.
- Ký và xác minh update bundle.
- Quản lý boot success/failure.
- Test corrupted update, signature sai, mất điện giả lập và rollback.
- Thiết kế version/rollback policy phù hợp với giới hạn QEMU.

**Deliverable**

- Signed update bundle.
- Update thành công từ version A sang B.
- Bundle không hợp lệ bị từ chối.
- Recovery/rollback demo.

### Module 8: Security validation và tài liệu

**Nội dung**

- Lập asset list và trust boundaries.
- Viết threat model phạm vi platform.
- Tạo test matrix cho positive và negative paths.
- Tổng hợp log, packet capture và bằng chứng.
- Viết security assumptions và known limitations.

**Deliverable**

- Architecture document.
- Threat model.
- Security test report.
- Reproducible build/run guide.
- Video hoặc script demo end-to-end.

## 5. Các kịch bản demo cuối

1. Boot image hợp lệ thành công.
2. Thay đổi kernel/FIT image làm boot verification thất bại.
3. Linux app gọi Trusted Application để ký dữ liệu.
4. TPM seal/unseal phụ thuộc PCR state.
5. Client chỉ kết nối server qua mutual TLS với certificate hợp lệ.
6. SELinux chặn ứng dụng đọc tài nguyên không được cấp quyền.
7. OTA bundle hợp lệ được cài vào slot thụ động.
8. OTA bundle bị sửa hoặc ký sai bị từ chối.
9. Boot lỗi sau update dẫn tới recovery/rollback theo thiết kế.

## 6. Tiêu chí hoàn thành

Project chỉ được xem là hoàn thành khi:

- Build có thể tái tạo bằng script và tài liệu.
- Mỗi security feature có positive test và negative test.
- Có log hoặc artifact chứng minh kết quả.
- Private key không được commit vào repository.
- Threat assumptions và giới hạn mô phỏng được ghi rõ.
- Có sơ đồ kiến trúc, boot flow và trust boundaries.
- Có README đủ để người khác chạy lại lab.

## 7. Cấu trúc repository gợi ý

```text
secure-embedded-linux-qemu/
├── README.md
├── docs/
│   ├── architecture.md
│   ├── boot-flow.md
│   ├── threat-model.md
│   ├── security-test-report.md
│   └── limitations.md
├── build/
├── buildroot/
├── tfa/
├── optee/
│   ├── client/
│   └── trusted-app/
├── u-boot/
├── tpm/
├── pki/
├── tls-demo/
├── selinux/
├── ota/
├── scripts/
└── test/
```

## 8. Giá trị đối với JD

Project chứng minh khả năng xây dựng và kiểm thử các security building block ở mức hệ thống: Embedded Linux, ARM boot architecture, secure boot chain, TEE, secure storage, key management, TLS, Linux hardening và secure OTA. Điểm mạnh của project nằm ở chiều sâu implementation và khả năng giải thích đường đi từ bootloader đến application.

Project không nên được mô tả là kinh nghiệm Qualcomm thực tế hoặc hardware security thực tế. Cách mô tả chính xác là **ARM64 virtual embedded security platform built with production-oriented open-source components**.
