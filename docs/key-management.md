# Key Management

> Trạng thái: skeleton — điền nội dung khi hoàn thành Phase 3–4.

## 1. Key hierarchy

```text
[SoC Root Key]  (trust anchor — hash nhúng trong TF-A, mô phỏng OTP/eFuse)
     │
     ├── [Boot Signing Key] ── ký BL31 / OP-TEE / U-Boot / FIT
     │
     ├── [App Signing Key]  ── ký app manifest (khác boot key)
     │
     └── [Lab Root CA]      ── cấp Device Certificate cho provisioning
              │
              └── [Device Identity Key]  (sinh BÊN TRONG TEE, không bao giờ export)
                       │
                       └── [App Keys]  (sinh trong TEE theo yêu cầu của hu-app)
```

## 2. Vòng đời key

```text
generate → provision → use → rotate → revoke/destroy
```

| Giai đoạn | Thực hiện ở đâu | Cơ chế |
|---|---|---|
| Generate | TEE (TA) | TEE_GenerateKey |
| Provision | Factory (host script) + TEE | one-time flag trong secure storage |
| Use | TEE | key usage policy (sign-only / decrypt-only) |
| Rotate | TEE | key version mới, key cũ vô hiệu |
| Destroy | TEE | xóa khỏi secure storage |

## 3. Secure storage

| Phương án | Ưu | Nhược | Quyết định |
|---|---|---|---|
| OP-TEE REE FS (mã hóa) | chạy được trên QEMU | key material mã hóa nhưng metadata ở REE | TODO chọn sau Phase 3 |
| RPMB | mạnh hơn | cần QEMU hỗ trợ | TODO kiểm tra |

## 4. Provisioning flow

```text
TODO: sequence diagram provisioning sau Phase 4
```

## 5. Negative scenarios

- Re-provision → từ chối (one-time flag)
- Dùng key đã revoke → từ chối
- Export private key ra Normal World → từ chối
