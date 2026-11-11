# Implementation Plan: [ชื่อฟีเจอร์]

- **Feature Slug:** `<feature-slug>`
- **Spec Reference:** `./spec.md`
- **Target Branch:** `feature/<feature-slug>`
- **Status:** `DRAFT (Waiting for Gate 1: Approve Spec)`

---

## 1. Architecture Overview & Chosen Approach
- **Summary:** [อธิบายแนวทางสถาปัตยกรรมและการไหลของข้อมูลตั้งแต่ต้นจนจบ]
- **Alternatives Considered:** [ทางเลือกอื่นที่ตัดออกและเหตุผลสั้นๆ]

---

## 2. Impacted Files & Blast Radius
> ต้องสำรวจโค้ดจริงในโปรเจกต์ก่อนกรอกตารางนี้ — ใน Stage 2 ให้แก้เฉพาะไฟล์ที่อยู่ในตารางนี้ (หากต้องเพิ่มไฟล์นอกแผน ให้แจ้งและอัปเดตตารางนี้ก่อน)

| File Path | Action | Purpose / Responsibility | Risk Level |
| :--- | :--- | :--- | :--- |
| `src/...` | `CREATE` / `MODIFY` / `DELETE` | [หน้าที่ของไฟล์และการเปลี่ยนแปลง] | `Low` / `Med` / `High` |
| `tests/...` | `CREATE` / `MODIFY` | [ชุดทดสอบที่ครอบคลุม AC และ Edge cases] | `Low` |

---

## 3. Data Model, Schema & State Changes
- **Schema / Migration:** [ตาราง/คอลัมน์/ดัชนีที่เพิ่มหรือแก้ พร้อม backward-compatibility]
- **Types / Interfaces:** [Interface หรือ DTO หลักที่สร้าง/อัปเดต]
- **State / Cache:** [การจัดการ state ฝั่ง client หรือ cache invalidation]

---

## 4. API & Module Contract
- **Endpoint / Function Signature:** [Method + Path หรือ Exported Function]
- **Request / Input Schema:** [ฟิลด์บังคับ, validation rules]
- **Response / Output Shape:** [โครงสร้างสำเร็จ + Error codes/messages มาตรฐาน]

---

## 5. Security & Error Handling Strategy
- **AuthN / AuthZ Check Point:** [ตรวจสิทธิ์ที่ layer ไหน]
- **Failure & Rollback Handling:** [วิธีจัดการ partial failure / transaction / error mapping]
- **Configuration / Env Vars:** [ตัวแปร env ใหม่ที่ต้องใช้ (ห้ามใส่ค่า secret จริงในเอกสาร)]

---

## 6. Test & Verification Mapping
> จับคู่ทุก AC ใน `spec.md` กับเทสต์ที่จะเขียนจริง

| Spec AC / Edge Case | Test Type | Planned Test File & Assertion |
| :--- | :--- | :--- |
| `AC1` (Happy path) | `Unit` / `Integration` | `tests/...` — [สิ่งที่ตรวจ] |
| `AC2` (Validation / Edge) | `Unit` | `tests/...` — [สิ่งที่ตรวจ] |
| `AC3` (Auth / Security) | `Integration` | `tests/...` — [สิ่งที่ตรวจ] |

---

## 7. Rollout & Rollback Plan
- **Feature Flag / Migration Safety:** [จำเป็นต้องใช้ flag หรือ zero-downtime migration หรือไม่]
- **Rollback Steps:** [ขั้นตอนย้อนกลับหากพบปัญหาหลัง deploy]
