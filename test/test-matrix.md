# Security Test Matrix

> Danh sách đầy đủ positive/negative tests. Kết quả chi tiết nằm ở `docs/security-test-report.md`.

## Phase 2 — Secure Boot

| ID | Loại | Mô tả | Cách thực hiện | Kỳ vọng |
|---|---|---|---|---|
| SB-P1 | Positive | Boot image hợp lệ end-to-end | `scripts/run-qemu.sh` | boot đến shell |
| SB-N1 | Negative | Kernel bị sửa 1 byte | sửa 1 byte trong FIT image rồi boot | từ chối ở U-Boot |
| SB-N2 | Negative | Image không ký | build FIT không sign | từ chối |
| SB-N3 | Negative | Ký bằng key sai | dùng key khác signing key | từ chối |
| SB-N4 | Negative | Đổi cert trong FIP | thay cert trong FIP | từ chối ở TF-A |

## Phase 3 — Trusted Application

| ID | Loại | Mô tả | Cách thực hiện | Kỳ vọng |
|---|---|---|---|---|
| TA-P1 | Positive | Sign payload trong TA | `hu-app sign <file>` | signature đúng, verify pass |
| TA-P2 | Positive | Verify bằng public key | `hu-app verify` | TEE_SUCCESS |
| TA-P3 | Positive | Generate key trong TEE | `hu-app genkey` | key nằm trong secure storage |
| TA-N1 | Negative | Export private key | gọi command export | từ chối |
| TA-N2 | Negative | Session/param sai | client gửi param sai | TEE_ERROR_BAD_PARAMETERS |
| TA-N3 | Negative | UUID sai | load TA với UUID không tồn tại | không load được |

## Phase 4 — Key Management

| ID | Loại | Mô tả | Cách thực hiện | Kỳ vọng |
|---|---|---|---|---|
| KM-P1 | Positive | Provisioning lần đầu | `scripts/provision-device.sh` | device cert trong secure storage |
| KM-P2 | Positive | Rotation key | `hu-app rotate-key` | key version mới hoạt động |
| KM-N1 | Negative | Re-provision | chạy provisioning lần 2 | từ chối (one-time flag) |
| KM-N2 | Negative | Dùng key đã revoke | gọi sign bằng revoked key | từ chối |
| KM-N3 | Negative | Destroy rồi dùng lại | delete key rồi sign | từ chối |

## Phase 5 — App Verification

| ID | Loại | Mô tả | Cách thực hiện | Kỳ vọng |
|---|---|---|---|---|
| AV-P1 | Positive | App hợp lệ được launch | boot với app đã ký | hu-app chạy |
| AV-N1 | Negative | App bị sửa | sửa 1 byte app binary | launcher từ chối |
| AV-N2 | Negative | App không ký | bỏ manifest | launcher từ chối |
| AV-N3 | Negative | Manifest ký sai key | ký bằng boot key | launcher từ chối |
| AV-N4 | Negative | Version cũ (rollback) | hạ version trong manifest | từ chối (nếu làm anti-rollback) |
