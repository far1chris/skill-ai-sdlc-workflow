# Implementation Tasks: [ชื่อฟีเจอร์]

- **Feature Slug:** `<feature-slug>`
- **Spec:** `./spec.md` | **Plan:** `./plan.md`

> **กติกาบังคับของ Agent (Stage 2):**
> 1. ทำทีละ **1 Task ย่อย** ตามลำดับ ห้ามทำรวบหลาย Task โดยไม่ทดสอบ
> 2. เขียน Automated Test กำกับใน Task นั้นและรันให้ผ่านก่อน จึงเปลี่ยน `[ ]` เป็น `[x]`
> 3. ห้ามแตะไฟล์นอกเหนือจากที่ระบุใน `plan.md` โดยไม่ขออัปเดตแผน

---

## Phase 1: Data, Schema & Contracts
- [ ] **Task 1.1:** สร้าง/อัปเดต Types, Interfaces หรือ Database Schema (`plan.md` §3)
- [ ] **Task 1.2:** สร้าง Repository / Service / API Contract Layer พร้อม Unit Tests ครอบคลุม Happy Path และ Invalid Input (`AC1`, `AC2`)

## Phase 2: Business Logic, Auth & UI Integration
- [ ] **Task 2.1:** พัฒนา Core Business Logic / Component หลัก พร้อม Unit Tests สำหรับ Edge Cases
- [ ] **Task 2.2:** เชื่อมต่อ Auth/Permissions, State และ Error Handling (`AC3`, Edge Cases ใน `spec.md`) พร้อม Integration/Component Tests

## Phase 3: Full Verification & Diff Hygiene
- [ ] **Task 3.1:** รัน `verify-gate` ผ่าน 100% ทุกด่าน (Typecheck + Lint + Tests) โดยไม่มีการ skip หรือลดความเข้มงวดของ test
- [ ] **Task 3.2:** ตรวจ `git status` และ `git diff` ว่าไม่มี debug logs, secrets หรือไฟล์ขยะ และสร้าง `walkthrough.md` พร้อมขอ **Gate 2**
