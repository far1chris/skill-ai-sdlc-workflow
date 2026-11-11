# Testing Guide & Quality Gate Criteria

> **Progressive Disclosure:** อ่านไฟล์นี้ใน **Stage 2 (เขียนเทสต์กำกับแต่ละ Task)** และ **Stage 3 (Self-Healing Loop)**

---

## 1. Coverage Requirements (Spec-to-Test Traceability)
1. ทุก **Acceptance Criterion (`AC`)** ใน `specs/<feature-slug>/spec.md` ต้องมี Automated Test รองรับอย่างน้อย 1 เคส
2. ต้องครอบคลุม Edge Cases สำคัญที่เกี่ยวกับฟีเจอร์นั้นเสมอ:
   - **Boundary / Empty Input:** `0`, ค่าติดลบ, string ว่าง, null/undefined, max length
   - **Invalid / Rejected States:** ข้อมูลหมดอายุ, สถานะไม่ตรงเงื่อนไข, duplicate submission / idempotency
   - **Security / Auth:** unauthenticated (`401`) และ unauthorized role/ownership (`403`)
   - **Dependency Failure:** network error / timeout / upstream error handling

## 2. Test Pyramid & Mocking Boundaries
- **Unit Tests:** ทดสอบ business logic, calculation, validation rules แบบ deterministic (ไม่พึ่ง network/database/system clock จริง)
- **Integration / API Tests:** ทดสอบ HTTP status codes, payload schema, auth middleware และการเชื่อมต่อ layer จริง (หรือ test DB)
- **Mocking Rule:** Mock เฉพาะ external boundary (third-party API, payment gateway, clock/Date, email/SMS) — **ห้าม** mock ตัว module/function ที่กำลังทดสอบอยู่

## 3. Test Integrity Rules (ห้ามละเมิดเด็ดขาด)
1. **ห้ามลบหรือข้ามเทสต์ (`.skip`, `xit`, `xtest`, `pytest.mark.skip`)** เพื่อทำให้ `verify-gate` ผ่าน
2. **ห้ามแก้ expectation ในเทสต์ให้ตรงกับโค้ดที่พัง** (เว้นแต่ผู้ใช้แก้ requirement ใน `spec.md` จริงๆ)
3. **ห้ามใช้เทสต์ว่าง หรือ assertion ที่ผ่านเสมอ** (เช่น `expect(true).toBe(true)`)

## 4. Self-Healing Loop Protocol (Stage 3)
เมื่อ `verify-gate` คืนค่า Error (exit code != 0):
1. **อ่าน Error จริงทั้งหมด:** แยกประเภทว่าพังที่ `[1/3] Typecheck`, `[2/3] Lint` หรือ `[3/3] Test`
2. **หา Root Cause:** ไล่ดูโค้ดที่พังจริงตาม stack trace (ห้ามเดาสุ่มแก้แบบ trial-and-error)
3. **แก้ที่ต้นเหตุและรันซ้ำ:** แก้ source code แล้วรัน `verify-gate` ใหม่ทั้งชุด
4. **Retry Cap (สูงสุด 3 รอบ):**
   - หากครบ **3 รอบ** แล้วยังไม่ผ่าน ให้ **หยุดทันที**
   - ห้ามไปต่อ Stage 4 (`walkthrough.md`) หรือ Stage 5 (`ship-pr`)
   - รายงานผล command ที่รัน, error log จริง และสิ่งที่ลองแก้ทั้ง 3 รอบให้ผู้ใช้ตัดสินใจ

## 5. Pass Criteria Before Gate 2
จะเข้าสู่ Stage 4 (`walkthrough.md`) ได้ต่อเมื่อ:
- `verify-gate` รันหลังการแก้ไขโค้ด **ครั้งสุดท้าย** แล้วจบด้วยสถานะ `ALL CHECKS PASSED!` (exit code `0`)
- ไม่มีเทสต์ที่ถูก skip, ปิดชั่วคราว หรือผ่อนปรน assertion
- ทุก Task ใน `tasks.md` ถูกตรวจและติ๊ก `[x]` ครบถ้วน
