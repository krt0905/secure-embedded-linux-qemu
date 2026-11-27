# Limitations — Giới hạn của môi trường QEMU

> Tài liệu này bắt buộc phải trung thực về những gì mô phỏng không thay thế được phần cứng thật.

## 1. Root of Trust

- QEMU **không có** eFuse/OTP thật. Trust anchor được mô phỏng bằng cách nhúng
  hash của root public key vào binary TF-A (BL1/BL2).
- Trên SoC thật: root key hash được burn vào OTP ở nhà máy, không thể ghi lại.
  Trên QEMU: attacker có quyền ghi image có thể thay cả trust anchor.
  → Mô phỏng chỉ chứng minh **logic verification**, không chứng minh **tamper resistance**.

## 2. Physical security

- Không có chống side-channel (DPA/SPA), fault injection, probe attack.
- Secure World trên QEMU là phần mềm cô lập bởi QEMU, không phải TrustZone silicon thật.

## 3. Secure storage

- RPMB (nếu dùng) trên QEMU là mô phỏng; RPMB thật có hardware write counter chống replay.

## 4. Anti-rollback

- Không có monotonic counter phần cứng. Version check chỉ ở mức metadata/manifest.

## 4b. Virtual eHSM

- eHSM được mô phỏng bằng HSM Service TA trên OP-TEE (xem `virtual-hsm.md`):
  mô phỏng được **logic, API và vòng đời key** theo style SHE/EVITA.
- KHÔNG mô phỏng được: chống side-channel (DPA/SPA), fault injection, probe attack,
  key nằm trong vùng memory không thể dump từ ngoài HSM, monotonic counter phần cứng,
  crypto accelerator riêng của HSM thật.
- Trên QEMU, ai kiểm soát host đều có thể dump memory của VM — điều này không thể
  xảy ra trên silicon thật với HSM riêng biệt.

## 5. Khác

- Không có secure boot ROM thật — stage đầu được mô phỏng.
- Không có PMIC/DDR/clock bring-up của SoC thật (BSP thật phức tạp hơn nhiều).
- Hiệu năng và timing không đại diện cho head unit thật.
