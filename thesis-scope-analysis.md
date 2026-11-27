# Phân tích phạm vi đồ án: Secure Boot + Trusted Application + Quản lý Key cho Head Unit Automotive ARM64 (QEMU)

> Mục đích tài liệu: phân tích lại plan 10 tháng hiện tại so với mục tiêu thật của đồ án,
> xác định rõ **cần làm gì – phạm vi – thời gian** cho từng phần.

---

## 1. Vấn đề của plan hiện tại

Plan 10 tháng hiện tại cover 10 chủ đề song song (QEMU, Buildroot, TF-A, OP-TEE, PKI/TLS,
TPM, Secure Boot, SELinux, OTA, Tích hợp). Đây là plan cho **"trở thành Embedded Security
Engineer"**, không phải plan cho **một đồ án có luận điểm rõ ràng**.

Luận điểm thật của đồ án (theo yêu cầu của bạn):

> **Một head unit automotive phải boot được từ một root of trust, chỉ chạy được app đã được
> xác minh, và mọi thao tác key phải nằm trong vùng bảo vệ (TEE) với vòng đời key đầy đủ
> (provisioning → storage → use → rotation → destruction).**

So sánh trọng tâm:

| Chủ đề | Plan hiện tại | Cần cho đồ án | Quyết định |
|---|---|---|---|
| QEMU + Buildroot platform | Tháng 1–2 | Bắt buộc (nền móng) | **Giữ**, gộp còn ~3 tuần |
| TF-A + boot flow | Tháng 3 | Bắt buộc, phải sâu hơn | **Giữ + nâng cấp** |
| Secure/Verified Boot | Tháng 7 (1 tháng) | **Trái tim của đồ án** | **Mở rộng thành 1 phase riêng 5–6 tuần** |
| OP-TEE + Trusted App | Tháng 4 (1 tháng) | Trái tim thứ 2 | **Mở rộng thành 1 phase riêng 5 tuần** |
| Key management/provisioning | Rải rác trong tháng 4, 5, 6 | **Trái tim thứ 3, hiện không có phase riêng** | **Tạo phase riêng 5 tuần** |
| App verification sau boot | Không có | Bắt buộc ("verified the app can run") | **Thêm mới 3 tuần** |
| swtpm / TPM / measured boot | Tháng 6 (1 tháng) | Không cần — TEE đã cover key protection | **Cắt** (đưa vào appendix/limitations) |
| PKI + mTLS | Tháng 5 (1 tháng) | Chỉ cần tối thiểu cho provisioning | **Thu nhỏ còn ~1 tuần trong phase key** |
| SELinux | Tháng 8 (1 tháng) | Nice-to-have | **Cắt hoặc để stretch goal** |
| Signed OTA | Tháng 9 (1 tháng) | Nice-to-have (head unit thật có, nhưng ngoài luận điểm) | **Stretch goal cuối** |

**Kết luận:** plan hiện tại không sai, nhưng nó dàn trải. Đồ án cần đi **sâu theo chiều dọc**
thay vì **rộng theo chiều ngang**.

---

## 2. Kiến trúc mục tiêu (mô phỏng head unit)

```text
                AUTOMOTIVE HEAD UNIT (mô phỏng trên QEMU ARM64)
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  [ROM] Boot ROM (QEMU không có thật → mô phỏng bằng entrypoint TF-A     │
│         BL1 / QEMU -bios; ghi rõ trong limitations)                     │
│           │  verify bằng SoC root public key (hash root key = RoT)      │
│           ▼                                                             │
│  [BL2] Trusted Firmware-A — verify từng image kế tiếp                   │
│           │                                                             │
│           ├──► BL31 (EL3 Secure Monitor)                                │
│           ├──► OP-TEE OS (Secure World, S-EL1)  ← verify trước          │
│           └──► U-Boot (Normal World)            ← verify trước          │
│                    │  U-Boot FIT verified boot:                         │
│                    │  verify signature của kernel + DTB + ramdisk       │
│                    ▼                                                    │
│  [Linux] Kernel → init → rootfs                                         │
│                    │                                                    │
│                    ▼                                                    │
│  [App verification] Head-unit service chỉ launch app có manifest        │
│                     đã ký hợp lệ (signature + version + hash)           │
│                    │                                                    │
│                    ▼                                                    │
│  [Head-unit app] ── TEE Client API ──► Trusted Application (OP-TEE)     │
│                                          │                              │
│                                          ├── Sinh key                   │
│                                          ├── Sign / verify / decrypt    │
│                                          ├── Secure storage (REE FS     │
│                                          │   mã hóa / RPMB)             │
│                                          └── Enforce vòng đời key       │
│                                                                         │
│  [Provisioning] Luồng provisioning nhà máy (script trên host mô phỏng   │
│                  dây chuyền sản xuất): inject device key + certs        │
│                  vào TEE secure storage một lần duy nhất                │
└─────────────────────────────────────────────────────────────────────────┘
```

Ba trụ cột của đồ án map vào kiến trúc:

1. **Secure Boot flow** — ROM → TF-A → OP-TEE/U-Boot → kernel → app verification.
2. **Trusted Application** — mọi thao tác key của app đi qua TA, không bao giờ ra Normal World.
3. **Key Management** — hierarchy, provisioning, storage, use, rotation, destruction.

---

## 3. Phân rã công việc: từng phần — cần làm gì, phạm vi, thời gian

> Tổng thời gian làm việc hiệu dụng: **~7 tháng + 3 tháng buffer** trong khung 10 tháng.
> Mỗi phase có tiêu chí đạt (exit criteria) — chưa đạt thì không sang phase sau.

---

### Phase 0 — Môi trường & nền tảng (3 tuần)

**Cần làm:**
- Linux host, toolchain AArch64, QEMU ARM64, cấu trúc repo, build scripts.
- Cấu hình Buildroot cho QEMU `virt`: toolchain + kernel + rootfs + custom package.
- Boot đến shell, lưu boot log, hiểu từng stage trong log.

**Phạm vi:** chỉ platform, chưa có security. Custom package = `hu-app` (bộ khung app head unit).

**Tiêu chí đạt:**
- [ ] `make build` một lệnh tạo ra image boot được, tái tạo được từ clean checkout.
- [ ] `hu-app` chạy trong target, in ra log.
- [ ] Tài liệu giải thích được: kernel nằm ở đâu, rootfs nằm ở đâu, boot args là gì.

---

### Phase 1 — TF-A và chuỗi boot nền tảng (3 tuần)

**Cần làm:**
- ARMv8-A Exception Levels, Secure/Non-secure state, SMC — viết lại bằng lời của mình.
- Build TF-A cho QEMU, đưa vào boot chain: TF-A → U-Boot → Linux.
- Đọc và giải thích boot log của TF-A (BL1/BL2/BL31, từng bước handoff).
- Sơ đồ boot flow + execution levels đúng với lab của mình.

**Phạm vi:** TF-A tham gia boot và handoff đúng; **chưa cần verify signature ở phase này**
(verify là Phase 2). Mục đích là hiểu cơ chế trước khi siết bảo mật.

**Tiêu chí đạt:**
- [ ] Boot log cho thấy TF-A chạy trước U-Boot.
- [ ] Tự vẽ và giải thích được sơ đồ EL0/EL1/EL2/EL3 + Secure/Non-secure.
- [ ] Giải thích được SMC là gì và nó xuất hiện ở đâu trong stack OP-TEE sau này.

---

### Phase 2 — Secure Boot chain (5–6 tuần) ⭐ trái tim #1

**Cần làm:**
1. **Thiết kế key hierarchy cho boot** (tuần 1):
   - Cặp SoC root key (trust anchor) → intermediate/boot key → signing key.
   - Quyết định trust anchor lưu ở đâu trên QEMU (hash root pubkey nhúng vào
     binary TF-A BL1/BL2 — mô phỏng OTP/eFuse; ghi rõ giới hạn).
2. **TF-A verified boot** (tuần 2–3):
   - Bật `TRUSTED_BOARD_BOOT` / `GENERATE_COT` của TF-A, hoặc tự implement
     verify ở BL2 cho các image kế tiếp (OP-TEE, U-Boot).
   - TF-A dùng certificate chain (FIP + certs) — hiểu từng cert trong chain.
3. **U-Boot FIT verified boot** (tuần 3–4):
   - FIT image chứa kernel + DTB + ramdisk, ký bằng RSA, `.its` + key hint,
     pubkey nhúng vào U-Boot DTB, `required = "conf"` để bắt buộc verify.
4. **Negative tests** (tuần 5):
   - Kernel bị sửa 1 byte → phải bị từ chối ở đúng stage.
   - Image không ký → từ chối.
   - Ký bằng key sai → từ chối.
   - Đổi cert trong FIP → từ chối.
   - Ghi lại log từ chối của từng case.

**Phạm vi:** verification tại **mỗi handoff point** (TF-A→stage kế, U-Boot→kernel).
Không làm measured boot, không làm TPM.

**Tiêu chí đạt:**
- [ ] Image hợp lệ boot end-to-end qua TF-A verify + U-Boot FIT verify.
- [ ] Ít nhất 4 negative test, mỗi test có log chứng minh bị từ chối ở đúng stage.
- [ ] Tài liệu: key hierarchy, trust anchor, chain of trust, giới hạn QEMU (không có eFuse thật).

---

### Phase 3 — OP-TEE và Trusted Application (5 tuần) ⭐ trái tim #2

**Cần làm:**
1. **Tích hợp OP-TEE** (tuần 1):
   - OP-TEE OS vào boot chain (TF-A load OP-TEE), OP-TEE client + Linux driver trong Buildroot.
   - Chạy `xtest` subset hoặc optee example để xác nhận Secure World sống.
2. **Viết TA riêng** (tuần 2–3):
   - TA cho head unit: `generate_key`, `sign`, `verify`, `get_public_key`,
     `store_key`, `delete_key` — dùng GlobalPlatform TEE Internal Core API.
   - Key **không bao giờ** export ra Normal World dưới dạng plaintext.
3. **Normal-world client** (tuần 3–4):
   - `hu-app` gọi TA qua TEE Client API; sequence diagram cho từng command.
4. **Negative tests** (tuần 4–5):
   - Gọi TA với session/param sai → TA từ chối.
   - Thử yêu cầu export private key → bị từ chối.
   - TA không load được nếu UUID sai / TA binary không đúng (nếu có verify TA).
   - Client không có quyền truy cập command nhất định → từ chối.

**Phạm vi:** một TA hoàn chỉnh + client. Secure storage dùng OP-TEE REE FS (mã hóa)
hoặc RPMB nếu QEMU hỗ trợ — so sánh hai phương án trong tài liệu.

**Tiêu chí đạt:**
- [ ] TA tự viết chạy được, client nhận kết quả đúng.
- [ ] Demo: sign một payload trong TA, verify ở client bằng public key.
- [ ] Ít nhất 3 negative test có log.
- [ ] Sequence diagram Linux → TEE Client API → OP-TEE → TA.

---

### Phase 4 — Key Management: provisioning, storage, vòng đời (5 tuần) ⭐ trái tim #3

Đây là phase **thiếu hoàn toàn** trong plan cũ — nó bị rải vào tháng 4, 5, 6.

**Cần làm:**
1. **Thiết kế key hierarchy cho device** (tuần 1):
   - Device identity key (provisioned ở factory) → app keys (sinh trong TEE).
   - Certificate profile cho device (tối giản: 1 root CA lab + device cert).
2. **Luồng provisioning** (tuần 2–3):
   - Script trên host mô phỏng nhà máy: tạo device key pair **bên trong TEE**,
     xuất public key, CA ký device cert, cert được ghi vào secure storage.
   - Provisioning chỉ chạy **một lần** (flag trong secure storage) — chạy lại phải bị từ chối.
   - Đây chính là "key provisioning + key safe" bạn yêu cầu.
3. **Vòng đời key** (tuần 4):
   - Rotation: cấp key version mới, key cũ bị vô hiệu.
   - Revocation/destruction: xóa key khỏi secure storage, chứng minh không dùng lại được.
   - Key usage policy trong TA: key nào được làm gì (sign-only vs decrypt-only).
4. **Negative tests** (tuần 5):
   - Provisioning lần 2 → từ chối.
   - Dùng key đã revoke → từ chối.
   - Truy cập key của app khác → từ chối (nếu làm multi-app isolation).

**Phạm vi:** PKI chỉ ở mức **tối thiểu phục vụ provisioning** (1 root CA + device cert).
Không làm mTLS server, không làm TLS stack demo.

**Tiêu chí đạt:**
- [ ] Provisioning script chạy được, device cert nằm trong secure storage.
- [ ] Re-provision bị từ chối có log.
- [ ] Tài liệu key hierarchy + lifecycle diagram (generate → provision → use → rotate → destroy).

---

### Phase 5 — App verification sau boot (3 tuần)

Đây là phần **"verified the app can run"** — plan cũ không có.

**Cần làm:**
- Định nghĩa app manifest: hash app binary + version + signature.
- Ký manifest bằng key thuộc hierarchy (app signing key, khác boot key).
- Head-unit service (init script/daemon) **chỉ launch app khi manifest verify pass**.
- Negative tests: app bị sửa → không launch; app không ký → không launch;
  version cũ hơn (rollback attempt) → từ chối nếu làm được anti-rollback ở mức lab.

**Phạm vi:** verification ở userspace service (mô phỏng cách head unit quản lý app).
Không cần IMA/EVM của kernel — ghi vào limitations nếu không làm.

**Tiêu chí đạt:**
- [ ] App hợp lệ được launch tự động sau boot.
- [ ] App bị sửa/không ký bị từ chối launch, có log.
- [ ] Luồng hoàn chỉnh: boot verified → app verified → app dùng TA → key đã provisioned.

---

### Phase 6 — Tích hợp, threat model, kiểm thử, tài liệu (4 tuần)

**Cần làm:**
- End-to-end demo script: từ power-on đến app chạy và ký dữ liệu bằng key trong TEE.
- Threat model: asset (boot images, keys, app binaries), trust boundaries
  (Normal/Secure world, host/target, factory/device), attack scenarios tương ứng
  từng negative test.
- Security test matrix tổng hợp (positive + negative cho mọi control).
- Bộ tài liệu: `architecture.md`, `boot-flow.md`, `threat-model.md`,
  `key-management.md`, `security-test-report.md`, `limitations.md`, `demo-guide.md`.
- Dọn repo, không commit private key, README tái tạo được từ đầu.

**Tiêu chí đạt:**
- [ ] Người khác build + chạy + demo được chỉ theo README.
- [ ] Mỗi security control có ≥1 negative test với bằng chứng.
- [ ] Checklist acceptance (mục 5) tick hết.

---

### Stretch goals (chỉ làm khi 6 phase trên xong và còn thời gian)

| Stretch | Giá trị | Thời gian |
|---|---|---|
| Signed OTA (RAUC, A/B) | Rất "automotive", nói chuyện được với interviewer | 3–4 tuần |
| SELinux policy cho `hu-app` | Chiều sâu hardening | 2–3 tuần |
| dm-verity rootfs | Bổ sung lớp integrity cho rootfs | 1–2 tuần |
| mTLS device → backend | Nối với JD Bosch (connected services) | 2 tuần |

---

## 4. Timeline đề xuất (7 tháng hiệu dụng + buffer)

```text
Tháng  Phase  Nội dung                          Deliverable chính
  1     0–1   Platform + TF-A boot chain        Linux boot qua TF-A, boot-flow diagram
  2     2     Secure boot: TF-A CoT + FIT       Valid image boots; tampered rejected
  3     2–3   FIT verify xong; OP-TEE tích hợp  Negative tests boot; Secure World sống
  4     3     Trusted Application + client      TA sign/verify, key không rời TEE
  5     4     Key provisioning + vòng đời      Factory provisioning, re-provision bị chặn
  6     5     App verification + integration    App chỉ chạy khi manifest hợp lệ
  7     6     Threat model + tests + docs       End-to-end demo + bộ tài liệu
 8–10   —     Buffer + stretch (OTA/SELinux)    Tùy tiến độ
```

So với plan cũ: **cùng khung 10 tháng, nhưng 7 tháng đầu đi sâu đúng luận điểm**,
3 tháng cuối là buffer + stretch thay vì bắt buộc.

---

## 5. Final acceptance checklist (thay thế checklist cũ)

**Secure Boot**
- [ ] TF-A verify các image kế tiếp trong boot chain.
- [ ] U-Boot FIT verify kernel/DTB trước khi boot.
- [ ] Trust anchor được mô tả rõ (và giới hạn mô phỏng OTP/eFuse được ghi nhận).
- [ ] ≥4 negative tests boot (tampered, unsigned, wrong key, wrong cert) có log.

**Trusted Application**
- [ ] TA tự viết với ≥4 operations (generate/sign/verify/store).
- [ ] Private key không bao giờ xuất hiện plaintext ở Normal World (có demo chứng minh).
- [ ] ≥3 negative tests TA có log.

**Key Management**
- [ ] Key hierarchy được thiết kế và tài liệu hóa.
- [ ] Provisioning flow chạy được và one-time (re-provision bị từ chối).
- [ ] Rotation + destruction hoạt động.
- [ ] Key usage policy enforce trong TA.

**App Verification**
- [ ] App chỉ launch khi manifest hợp lệ.
- [ ] Tampered/unsigned app bị từ chối có log.

**Chất lượng kỹ thuật**
- [ ] Build/run bằng script, tái tạo từ clean.
- [ ] Threat model + test matrix + limitations.
- [ ] Không commit private key thật.
- [ ] End-to-end demo: boot → verify → app → TA → key op.

---

## 6. Rủi ro và lưu ý

| Rủi ro | Ảnh hưởng | Giảm thiểu |
|---|---|---|
| TF-A `TRUSTED_BOARD_BOOT` trên QEMU khó cấu hình | Phase 2 trễ | Fallback: tự implement verify đơn giản ở BL2; vẫn đạt luận điểm |
| OP-TEE + Buildroot integration lỗi version | Phase 3 trễ | Pin version đã được cộng đồng test (OP-TEE manifest cho QEMU virt) |
| RPMB trên QEMU không có sẵn | Phase 4 chọn storage | Dùng REE FS mã hóa của OP-TEE; ghi vào limitations |
| Cắt TPM/mTLS/SELinux khiến đồ án "mỏng"? | Lo ngại về độ phủ | Không mỏng — sâu hơn ở 3 trụ cột; stretch goals bù nếu còn thời gian |
| QEMU không có hardware root of trust thật | Luận điểm bị hỏi khi bảo vệ | Chuẩn bị sẵn slide giải thích: mô phỏng RoT bằng key hash trong BL1, giới hạn đã ghi trong `limitations.md` |

---

## 7. Kết luận

- **Cần làm:** 6 phase — Platform → TF-A → Secure Boot → TA → Key Management → App Verification → Tài liệu.
- **Phạm vi:** dọc theo một chuỗi duy nhất (boot → verify → app → key), không dàn trải.
- **Thời gian:** ~7 tháng hiệu dụng + 3 tháng buffer/stretch trong khung 10 tháng.
- **Cắt khỏi plan cũ:** swtpm/measured boot, mTLS demo, SELinux, OTA (chuyển thành stretch goals).
- **Thêm mới so với plan cũ:** app verification sau boot, provisioning one-time flow, key lifecycle (rotate/revoke/destroy).
