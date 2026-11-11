---
name: ai-sdlc-workflow
description: Use when building new features, modifying existing system behavior, or running the team workflow (สร้างฟีเจอร์ใหม่ แก้ระบบ รัน workflow ทีม), especially under pressure to code before specs or skip verification gates.
---

# AI-Native SDLC Workflow Controller

คุมการทำงานครบ 5 Stages (`Spec -> Agent -> Test -> Review -> Deploy`) พร้อม Human Gate 2 จุดและ Progressive Disclosure เพื่อประหยัด Context Window

**หลักการเหล็ก:** การละเมิดตัวอักษรของกติกา เท่ากับการละเมิดเจตนารมณ์ของกติกา — ห้ามข้าม Stage, ห้ามรวบ Stage ข้าม Gate, และห้ามแก้ไข `src/` ก่อนผ่าน Gate 1

---

## Stage 1: SPEC (Planning & Impact Analysis)
1. **อ่านเฉพาะแม่แบบที่จำเป็น:**
   - [01-spec.template.md](./templates/01-spec.template.md)
   - [02-plan.template.md](./templates/02-plan.template.md)
   - [03-tasks.template.md](./templates/03-tasks.template.md)
   *(ห้ามโหลด `references/` หรือ `04-walkthrough.template.md` ในขั้นนี้)*
2. **สำรวจโค้ดจริงในโปรเจกต์** เพื่อระบุไฟล์ที่จะได้รับผลกระทบ, สัญญา API/Schema, และความเสี่ยง
3. สร้างโฟลเดอร์ `specs/<feature-slug>/` ใน workspace แล้วสร้างไฟล์ `spec.md`, `plan.md`, และ `tasks.md` ตามแม่แบบ (ใช้ `<feature-slug>` เป็นตัวพิมพ์เล็กและขีดกลาง เช่น `discount-coupons`)
4. **🛑 GATE 1 — Human Approval (ห้ามข้ามเด็ดขาด):**
   - หยุดการทำงานทันทีหลังสร้างเอกสาร 3 ไฟล์เสร็จ
   - **ห้าม** สร้างหรือแก้ไขไฟล์ใน `src/`, `tests/` หรือไฟล์ config ใดๆ จนกว่าผู้ใช้จะพิมพ์ **`Approve Spec`**
   - หากผู้ใช้เร่งด่วน (เช่น demo/hotfix) ห้ามข้าม Gate 1 โดยพลการ — ให้ถามชัดเจนว่าจะให้หยุดรอ `Approve Spec` หรือยกเลิกการใช้ `ai-sdlc-workflow` เพื่อทำ throwaway spike แทน

---

## Stage 2: AGENT (Sequential Implementation)
> เริ่มได้ต่อเมื่อได้รับ **`Approve Spec`** แล้วเท่านั้น

1. **อ่านคู่มือมาตรฐาน:** [coding-rules.md](./references/coding-rules.md) และ [testing-guide.md](./references/testing-guide.md)
2. หยิบงานจาก `specs/<feature-slug>/tasks.md` มาทำ **ทีละ 1 Task ย่อย** ตามลำดับ
3. แก้เฉพาะไฟล์ที่ระบุใน `plan.md` (หากต้องแก้ไฟล์อื่น ให้แจ้งเหตุผลและอัปเดต `plan.md` ก่อน)
4. เขียน Automated Test กำกับ Task นั้นทันที รันเทสต์เฉพาะจุดให้ผ่าน แล้วจึงอัปเดต `[x]` ลงใน `tasks.md`

---

## Stage 3: TEST (Self-Healing Verification Loop)
1. เมื่อทำครบ Phase ย่อยหรือครบทุก Task ให้รันสคริปต์ตรวจสอบตาม OS:
   - **Windows (PowerShell):** `powershell -ExecutionPolicy Bypass -File .agents/skills/ai-sdlc-workflow/scripts/verify-gate.ps1`
   - **macOS / Linux / Git Bash:** `bash .agents/skills/ai-sdlc-workflow/scripts/verify-gate.sh`
2. **Self-Healing Rule (สูงสุด 3 รอบ):**
   - หากเกิด Error ให้วิเคราะห์ root cause จาก log จริง แก้ต้นเหตุใน source code แล้วรัน `verify-gate` ใหม่ทั้งชุด
   - **ห้าม** ลบ, `.skip`, ลดความเข้มงวดของ test หรือปิด lint/typecheck rule เพื่อให้ผ่าน
   - หากแก้ครบ **3 รอบ** แล้วยังไม่ผ่าน ให้ **หยุดทันที** รายงาน log จริงและสิ่งที่ลองแก้ทั้ง 3 รอบให้ผู้ใช้ตัดสินใจ (ห้ามไป Stage 4)

---

## Stage 4: REVIEW (Walkthrough & Diff Gate)
> เริ่มได้ต่อเมื่อ `verify-gate` คืนค่า `ALL CHECKS PASSED!` หลังการแก้ไขครั้งสุดท้ายแล้วเท่านั้น

1. อ่าน [04-walkthrough.template.md](./templates/04-walkthrough.template.md) แล้วสร้าง `specs/<feature-slug>/walkthrough.md`
2. ตรวจสอบ `git status` และ `git diff` ให้สะอาดจาก debug logs/ความลับ และแปะผลลัพธ์จริงจากการรัน `verify-gate` (ห้ามแต่งตัวเลขหรือสรุปเกินจริง)
3. ติ๊ก `[x]` งานสุดท้ายใน `tasks.md` ให้ครบ
4. **🛑 GATE 2 — Code Review:** แจ้งผู้ใช้ตรวจ `git diff` และ `specs/<feature-slug>/walkthrough.md` แล้วรอคำสั่ง **`Approve Review`** (ห้าม commit, push หรือ ship ก่อนได้รับอนุมัติ)

---

## Stage 5: DEPLOY (Safe Branch & Commit)
> เริ่มได้ต่อเมื่อได้รับ **`Approve Review`** แล้วเท่านั้น

1. รันสคริปต์สร้าง Branch (`feature/<feature-slug>`) และ Commit ตาม OS:
   - **Windows (PowerShell):** `powershell -ExecutionPolicy Bypass -File .agents/skills/ai-sdlc-workflow/scripts/ship-pr.ps1 <feature-slug>`
   - **macOS / Linux / Git Bash:** `bash .agents/skills/ai-sdlc-workflow/scripts/ship-pr.sh <feature-slug>`
   *(ใช้ `-Push` / `--push` หรือ `-Pr` / `--pr` เฉพาะเมื่อผู้ใช้สั่งให้ push/เปิด PR บน remote ด้วย; ห้าม push ตรงเข้า `main`/`master`)*
2. รายงานชื่อ Branch, Commit summary และคำสั่งสำหรับ Merge / Deploy ขึ้น Staging จากผลรันจริงของสคริปต์

---

## Red Flags & Rationalization Guardrails

| ข้ออ้างที่พบบ่อย | ความจริง & กติกาบังคับ |
| :--- | :--- |
| "รีบ/ต้อง demo ใน 30 นาที ขอรวบทำโค้ดเลย" | ห้ามรวบข้าม Gate 1 ถ้ายังใช้ skill นี้อยู่ ต้องหยุดรอ `Approve Spec` เสมอ |
| "เขียน `spec.md` แล้ว ถือว่าทำตามหลักการแล้ว โค้ดต่อได้เลย" | การเขียน spec โดยไม่รอ Gate 1 คือการข้าม Gate — ห้ามแตะ `src/` ก่อนได้รับ `Approve Spec` |
| "แก้ test expectation หรือ skip 1 เคสชั่วคราวเพื่อให้ผ่าน" | การปรับ test ให้ตรงกับโค้ดที่พังซ่อนบั๊ก — ห้ามแก้/ลบ test เพื่อหนี fail |
| "เหลืออีกนิดเดียว ลองแก้รอบที่ 4-5 ดู" | เกิน 3 รอบแปลว่าสมมติฐานผิด ต้องหยุดรายงาน log จริงให้คนตัดสินใจ |
| "ผ่านเทสต์แล้ว ข้าม `walkthrough.md` แล้ว commit เลย" | `ship-pr` บังคับตรวจ `walkthrough.md` และต้องผ่าน Gate 2 (`Approve Review`) ก่อนเสมอ |
