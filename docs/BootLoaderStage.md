
Power ON
   │
   ▼
┌────────────┐
│    BL1     │  Trusted boot đầu tiên
└─────┬──────┘
      ▼
┌────────────┐
│    BL2     │  Load/verify firmware tiếp theo
└─────┬──────┘
      ▼
┌────────────┐
│   BL31     │  TF-A runtime firmware
│    EL3     │  Secure Monitor
└─────┬──────┘
      │
      ├──► BL32 (OPTEE)
      │     Trusted OS / Secure Payload
      │
      ▼
┌────────────┐
│   BL33     │  Normal-world bootloader
│            │  ví dụ U-Boot
└─────┬──────┘
      ▼
 Linux / QNX / Android





 Stage	Hiểu đơn giản
BL1	Bắt đầu boot
BL2	Load + authenticate firmware
BL31	TF-A runtime / EL3
BL32	Secure World software, optional
BL33	Normal World bootloader → OS


BL1: Start
 ↓
BL2: Load
 ↓
BL31: Secure Monitor / EL3
 ↓
BL32: Secure World        (optional)
 ↓
BL33: Normal World
 ↓
Linux/QNX