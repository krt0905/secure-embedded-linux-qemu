# Project 2: Secure Automotive Device Ecosystem

## 1. Mục tiêu

Tái sử dụng nền tảng bảo mật của Project 1 để xây dựng mô hình một hệ sinh thái connected vehicle/automotive gồm nhiều thiết bị mô phỏng ECU, một gateway hoặc IVI và backend quản lý thiết bị.

Project tập trung vào **system view và product security lifecycle**: device identity, provisioning, secure communication, fleet OTA, certificate lifecycle, threat modeling và vận hành nhiều thiết bị.

Project 2 không thay thế Project 1. Project 1 xây các cơ chế bảo mật; Project 2 chứng minh cách kết hợp chúng thành một hệ thống sản phẩm.

## 2. Kiến trúc tổng quát

```text
                         +----------------------+
                         |   PKI / Provisioning |
                         | Root CA / Issuing CA |
                         +----------+-----------+
                                    |
                                    v
+----------------+       +----------------+       +----------------+
| ECU-A          | mTLS  | Gateway / IVI  | mTLS  | Backend        |
| QEMU ARM64     +------>+ QEMU/Linux     +------>+ Device Registry|
| Device cert    |       | Policy/Router  |       | OTA Service    |
+----------------+       +----------------+       +----------------+
        |                         |                         |
        +-------------------------+-------------------------+
                         Signed OTA artifacts
```

Có thể chạy mỗi ECU dưới dạng một QEMU VM hoặc container/process tùy giai đoạn. Nếu cần chứng minh platform security, ít nhất một node nên tái sử dụng image của Project 1.

## 3. Project này cover gì?

### Các năng lực được cover trực tiếp

- Automotive cybersecurity ở mức hệ thống mô phỏng
- Security architecture cơ bản
- Asset identification và trust boundaries
- Threat modeling và mitigation mapping
- Device identity bằng certificate
- PKI hierarchy và certificate lifecycle
- Key provisioning workflow
- Mutual TLS cho ECU-to-gateway và device-to-backend
- Secure communication
- Secure firmware distribution
- Fleet OTA orchestration ở mức lab
- Version, deployment status và rollback policy
- Device inventory và authorization
- Security logging và audit trail
- Incident scenarios như credential revocation hoặc compromised ECU
- Tích hợp secure boot, OP-TEE/TPM, TLS và OTA từ Project 1 vào hệ thống lớn hơn

### Cover một phần

- Automotive architecture: dùng mô hình ECU/gateway/IVI nhưng không đại diện đầy đủ kiến trúc xe sản xuất.
- Security architecture review: thực hành trên project tự thiết kế, chưa thay thế kinh nghiệm review sản phẩm thương mại.
- Manufacturing provisioning: mô phỏng enrollment/injection workflow, không có dây chuyền hoặc secure programming station thật.
- Fleet management: mô phỏng nhiều thiết bị ở quy mô lab, không tuyên bố khả năng production-scale.
- Automotive standards: có thể mapping thiết kế với ISO/SAE 21434 hoặc UNECE R155/R156 ở mức học tập; không tuyên bố compliance hoặc certification.
- MACsec: là module mở rộng tùy chọn cho Ethernet link security.

### Chưa cover hoặc cover rất ít

- Qualcomm-specific automotive BSP
- Android Automotive OS và Android Security
- QNX hoặc AUTOSAR integration
- CAN/CAN-FD controller thật
- SOME/IP stack sản phẩm
- Automotive Ethernet PHY, TSN và hardware MACsec
- Hardware Security Module trong automotive MCU/SoC thật
- Safety engineering và ISO 26262
- Production PKI/HSM operation ở quy mô doanh nghiệp
- Vehicle testing, bench testing và in-vehicle validation

## 4. Các module thực hiện

### Module 1: Multi-device automotive lab

**Nội dung**

- Tạo tối thiểu ECU-A, Gateway/IVI và Backend.
- Tách network segment và định nghĩa trust boundary.
- Gán identity và role riêng cho từng node.
- Xác định các service và data flow giữa các node.

**Deliverable**

- System architecture diagram.
- Data-flow diagram.
- Network topology có thể tái tạo.
- Danh sách asset, actor và trust boundary.

### Module 2: Automotive-style device identity và PKI

**Nội dung**

- Tạo Root CA, Issuing CA và certificate profile.
- Cấp identity riêng cho mỗi ECU/gateway/backend.
- Xác định certificate validity, rotation và revocation policy.
- Ngăn một ECU sử dụng identity của ECU khác.

**Deliverable**

- PKI hierarchy.
- Certificate profile cho từng device role.
- Enrollment script.
- Demo thiết bị không có certificate hợp lệ bị từ chối.

### Module 3: Secure provisioning lifecycle

**Nội dung**

- Mô phỏng trạng thái factory-new, provisioned, active, revoked và decommissioned.
- Sinh hoặc import key trong TPM/TEE khi khả thi.
- Gửi CSR và nhận device certificate.
- Gắn certificate với device record ở backend.
- Mô phỏng reprovisioning và decommissioning.

**Deliverable**

- Provisioning state machine.
- Enrollment workflow.
- Audit log cho các bước provisioning.
- Demo revoked/decommissioned device không còn được truy cập.

### Module 4: Secure ECU communication

**Nội dung**

- Thiết lập mTLS giữa ECU và Gateway/IVI.
- Thiết lập mTLS giữa Gateway/IVI và Backend.
- Authorization dựa trên certificate identity và role.
- Chống endpoint giả mạo và certificate không được tin cậy.
- Ghi log security events.

**Deliverable**

- mTLS communication demo.
- Access-control matrix theo role.
- Packet capture.
- Negative tests cho unauthorized ECU, CA sai và certificate bị revoke.

### Module 5: Fleet OTA

**Nội dung**

- Backend quản lý device ID, software version và update status.
- Publish signed update metadata/artifact.
- Chọn target device hoặc deployment group.
- Thiết bị tải, xác minh, cài đặt và báo trạng thái.
- Thực hiện staged deployment ở quy mô lab.
- Xử lý failed update, rollback và retry policy.

**Deliverable**

- Device inventory.
- OTA campaign workflow.
- Signed artifact distribution.
- Update status dashboard hoặc report đơn giản.
- Demo một node update thành công và một node rollback.

### Module 6: Threat modeling và security review

**Nội dung**

- Xác định asset: firmware, private key, certificate, update signing key, telemetry và backend credentials.
- Xác định threat theo STRIDE hoặc phương pháp tương đương.
- Mapping threat sang control của Project 1 và Project 2.
- Đánh giá residual risk và assumptions.
- Review thiết kế từ góc nhìn attacker.

**Deliverable**

- Threat model document.
- Attack tree hoặc data-flow-based threat analysis.
- Risk register đơn giản.
- Security requirements và mitigation traceability matrix.

### Module 7: Incident và certificate lifecycle

**Nội dung**

- Mô phỏng private key/certificate của một ECU bị compromise.
- Revoke certificate.
- Chặn ECU tại gateway/backend.
- Re-enroll thiết bị nếu policy cho phép.
- Ghi audit trail và incident report.

**Deliverable**

- Revocation demo.
- Incident response runbook.
- Evidence chứng minh compromised identity bị từ chối.

### Module 8 tùy chọn: MACsec hoặc secure in-vehicle Ethernet

**Nội dung gợi ý**

- Tạo Ethernet link mô phỏng giữa hai node Linux.
- So sánh TLS ở application/transport layer với MACsec ở Layer 2.
- Nếu triển khai MKA, ghi rõ vai trò của CAK, CKN, SAK và key server.
- Test traffic hợp lệ, invalid key và rekey.

**Deliverable**

- Link-security demo.
- Packet capture trước và sau khi bật MACsec.
- Tài liệu phân biệt phạm vi bảo vệ của TLS và MACsec.

## 5. Project 2 bổ sung gì so với Project 1?

| Khía cạnh | Project 1 | Project 2 |
|---|---|---|
| Phạm vi | Một embedded platform | Nhiều ECU/gateway/backend |
| Trọng tâm | Implementation | System integration và lifecycle |
| Identity | Một client/server lab | Identity riêng cho từng thiết bị |
| PKI | Tạo và dùng certificate | Issuance, rotation, revocation, decommissioning |
| OTA | Update một thiết bị | Campaign, inventory, status, staged deployment |
| Threat modeling | Platform-local | End-to-end data flow và trust boundary |
| Incident | Negative test kỹ thuật | Compromised device và certificate revocation |
| Automotive | Security building blocks | Mô hình connected ECU ecosystem |

## 6. Các kịch bản demo cuối

1. Factory-new ECU chưa provision không được kết nối backend.
2. ECU tạo/nhận identity và hoàn thành enrollment.
3. ECU và gateway giao tiếp bằng mTLS.
4. ECU dùng certificate không thuộc role bị từ chối authorization.
5. Backend phát hành signed OTA cho một deployment group.
6. ECU hợp lệ cập nhật và báo version/status mới.
7. Update lỗi dẫn tới rollback theo policy.
8. Compromised ECU bị revoke và mất quyền truy cập.
9. Gateway tiếp tục phục vụ các ECU hợp lệ.
10. Threat-to-control matrix chỉ ra control nào xử lý từng attack scenario.

## 7. Tiêu chí hoàn thành

- Có ít nhất ba logical components: ECU, gateway/IVI và backend.
- Mỗi device có identity riêng.
- Mutual authentication và authorization được kiểm thử.
- Có provisioning, rotation/revocation hoặc decommissioning flow.
- OTA có chữ ký, target selection, status và failure handling.
- Threat model gắn trực tiếp với architecture/data flow.
- Có positive và negative test cho các luồng quan trọng.
- Không tuyên bố compliance automotive nếu chưa có đánh giá/certification chính thức.

## 8. Cấu trúc repository gợi ý

```text
secure-automotive-ecosystem/
├── README.md
├── docs/
│   ├── system-architecture.md
│   ├── data-flow.md
│   ├── threat-model.md
│   ├── security-requirements.md
│   ├── incident-runbook.md
│   └── limitations.md
├── ecu/
├── gateway/
├── backend/
├── pki/
├── provisioning/
├── ota-service/
├── inventory/
├── network/
├── macsec-optional/
├── scripts/
└── tests/
```

## 9. Giá trị đối với JD

Project 2 chứng minh rằng người thực hiện không chỉ biết chạy từng security feature riêng lẻ mà còn hiểu cách chúng phối hợp trong lifecycle của một connected embedded product. Giá trị lớn nhất là device identity, provisioning, secure communication, fleet OTA, threat modeling, risk-to-control mapping và certificate revocation.

Cách mô tả chính xác trên CV là **automotive-style security ecosystem simulated with virtual embedded devices**. Không nên mô tả đây là kinh nghiệm sản xuất automotive thật, Qualcomm BSP thật hoặc compliance experience.
