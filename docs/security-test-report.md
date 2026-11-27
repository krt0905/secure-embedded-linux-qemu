# Security Test Report

> Trạng thái: skeleton — điền kết quả khi hoàn thành từng phase.

## 1. Ma trận test

Xem `test/test-matrix.md` cho danh sách đầy đủ. Báo cáo này ghi **kết quả thực tế**.

## 2. Kết quả theo phase

### Phase 2 — Secure Boot

| Test ID | Mô tả | Kỳ vọng | Kết quả | Evidence |
|---|---|---|---|---|
| SB-P1 | Boot image hợp lệ | boot thành công | ⬜ | TODO |
| SB-N1 | Kernel bị sửa 1 byte | từ chối ở đúng stage | ⬜ | TODO |
| SB-N2 | Image không ký | từ chối | ⬜ | TODO |
| SB-N3 | Ký bằng key sai | từ chối | ⬜ | TODO |
| SB-N4 | Đổi cert trong FIP | từ chối | ⬜ | TODO |

### Phase 3 — Trusted Application

| Test ID | Mô tả | Kỳ vọng | Kết quả | Evidence |
|---|---|---|---|---|
| TA-P1 | Sign payload trong TA | kết quả đúng | ⬜ | TODO |
| TA-N1 | Export private key | từ chối | ⬜ | TODO |
| TA-N2 | Session/param sai | từ chối | ⬜ | TODO |
| TA-N3 | UUID sai | TA không load | ⬜ | TODO |

### Phase 4 — Key Management

| Test ID | Mô tả | Kỳ vọng | Kết quả | Evidence |
|---|---|---|---|---|
| KM-P1 | Provisioning lần đầu | thành công | ⬜ | TODO |
| KM-N1 | Re-provision | từ chối | ⬜ | TODO |
| KM-N2 | Dùng key đã revoke | từ chối | ⬜ | TODO |

### Phase 5 — App Verification

| Test ID | Mô tả | Kỳ vọng | Kết quả | Evidence |
|---|---|---|---|---|
| AV-P1 | App hợp lệ | được launch | ⬜ | TODO |
| AV-N1 | App bị sửa | không launch | ⬜ | TODO |
| AV-N2 | App không ký | không launch | ⬜ | TODO |

## 3. Evidence

```text
artifacts/
├── boot-logs/
├── ta-logs/
├── provisioning-logs/
└── app-verify-logs/
```
