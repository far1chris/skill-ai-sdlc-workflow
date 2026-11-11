# AI-SDLC Workflow Skill (`ai-sdlc-workflow`)

Modular Skill Package สำหรับ Antigravity ที่ควบคุมกระบวนการพัฒนาซอฟต์แวร์แบบ **Spec → Agent → Test → Review → Deploy** ระดับทีมด้วย Progressive Disclosure, 2 Human Gates และสคริปต์ตรวจสอบอัตโนมัติ

## โครงสร้างแพ็กเกจ

```text
.agents/skills/ai-sdlc-workflow/
├── SKILL.md                        # State Machine, Gatekeeper และ Guardrails
├── templates/                      # แม่แบบมาตรฐาน (สร้างลง specs/<feature-slug>/)
│   ├── 01-spec.template.md         # Product Spec, AC, Edge Cases, Security
│   ├── 02-plan.template.md         # Architecture, Impacted Files, Contract, Test Plan
│   ├── 03-tasks.template.md        # Checklist งานย่อยทำทีละข้อ
│   └── 04-walkthrough.template.md  # รายงาน Code Review (Gate 2)
├── references/                     # คู่มือโหลดเฉพาะ Stage 2–3
│   ├── coding-rules.md             # มาตรฐานโค้ด, Scope และ Security Baseline
│   └── testing-guide.md            # เกณฑ์เทสต์, Anti-Cheat และกติกา Self-Healing
└── scripts/                        # สคริปต์ตรวจสอบและแพ็กขึ้น Git (รองรับทั้ง Windows/Unix)
    ├── verify-gate.sh              # Typecheck + Lint + Test (macOS / Linux / Git Bash)
    ├── verify-gate.ps1             # Typecheck + Lint + Test (Windows PowerShell)
    ├── ship-pr.sh                  # Safe branch + secret guard + commit/PR (Unix)
    └── ship-pr.ps1                 # Safe branch + secret guard + commit/PR (Windows)
```

## การติดตั้งเข้าโปรเจกต์ของทีม

1. คัดลอกโฟลเดอร์ `.agents/` (และ `.gitattributes`) ไปวางที่ Root ของ Git Repository ของทีม แล้ว commit เข้า Git
2. (ตัวเลือก) หากโปรเจกต์มีคำสั่งตรวจเฉพาะทาง สามารถกำหนด env vars `VERIFY_TYPECHECK_CMD`, `VERIFY_LINT_CMD`, `VERIFY_TEST_CMD` ได้โดยไม่ต้องแก้สคริปต์

## วิธีใช้งานประจำวัน (3 คำสั่งหลัก)

1. **เริ่มฟีเจอร์ (Stage 1: SPEC):**
   > `"ใช้ skill ai-sdlc-workflow สร้างระบบจัดการคูปองส่วนลด"`
   Agent จะสร้าง `specs/<feature-slug>/spec.md`, `plan.md`, `tasks.md` แล้วหยุดรอที่ **Gate 1**
2. **อนุมัติแผนเพื่อเริ่มเขียนโค้ดและเทสต์ (Stage 2–4):**
   > `"Approve Spec"`
   Agent จะทำทีละ Task พร้อมเทสต์, รัน `verify-gate` พร้อม Self-Healing (สูงสุด 3 รอบ), สร้าง `walkthrough.md` แล้วหยุดรอที่ **Gate 2**
3. **อนุมัติหลัง Code Review (Stage 5: DEPLOY):**
   > `"Approve Review"`
   Agent จะรัน `ship-pr` เพื่อสร้าง branch `feature/<feature-slug>` และ commit โค้ดที่ผ่าน gate ทั้งหมดอย่างปลอดภัย
