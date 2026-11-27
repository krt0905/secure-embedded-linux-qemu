# Security Test Matrix

> Danh sách đầy đủ positive/negative tests. Kết quả chi tiết nằm ở `docs/security-test-report.md`.

## Phase 2 — Secure Boot

> ✅ **HOÀN THÀNH (27/11/2026)** — 7/7 test PASS. Lưu ý: ID thực tế khi test khác
> ma trận ban đầu (SB-N1/N2/N5 = tamper FIP chain ở TF-A; SB-N3/N4 = FIT ở U-Boot).
> Evidence: `artifacts/boot-logs/`.

| ID | Loại | Mô tả | Kết quả | Evidence |
|---|---|---|---|---|
| SB-P1 | Positive | Boot hợp lệ qua TBB (V1) | ✅ PASS — 7 images authenticated | `tbb-valid-boot.log` |
| SB-N1 | Negative | Tamper BL31 trong flash | ✅ PASS — Hash mismatch, halt | `sb-n1-tampered-bl31.log` |
| SB-N2 | Negative | Tamper U-Boot trong flash | ✅ PASS — Failed image id 5 | `sb-n2-tampered-uboot.log` |
| SB-N5 | Negative | Tamper cert (wrong key) | ✅ PASS — auth error code 2 | `sb-n5-wrong-key.log` |
| SB-P2 | Positive | Boot FIT hợp lệ (V2) | ✅ PASS — rsa2048:fit+ OK → login | `fit-valid-boot.log` |
| SB-N3 | Negative | Tamper kernel trong FIT | ✅ PASS — Bad hash, halt | `sb-n3-tampered-kernel.log` |
| SB-N4 | Negative | FIT không ký | ✅ PASS — required signature fail, halt | `sb-n4-unsigned-fit.log` |

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
