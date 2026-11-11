# Feature Specification: [ชื่อฟีเจอร์]

- **Feature Slug:** `<feature-slug>`
- **Owner / Requester:** [ชื่อผู้ขอ / ทีม]
- **Status:** `DRAFT (Waiting for Gate 1: Approve Spec)`
- **Target Date:** `YYYY-MM-DD`

---

## 1. User Story & Goal
- **As a** [บทบาทผู้ใช้ / ระบบ],
- **I want to** [สิ่งที่ต้องการทำ],
- **So that** [คุณค่าทางธุรกิจหรือปัญหาที่แก้ได้].
- **Success Metric:** [ตัวชี้วัดความสำเร็จ เช่น latency < 200ms, conversion/error rate]

---

## 2. Acceptance Criteria (เกณฑ์การตรวจรับ)
> ทุกข้อต้องทดสอบได้จริง และต้องถูกแปลงเป็น Automated Test อย่างน้อย 1 เคส

- [ ] **AC1:** Given [บริบทเริ่มต้น], When [การกระทำ], Then [ผลลัพธ์ที่คาดหวัง]
- [ ] **AC2:** Given [ข้อมูลไม่ครบหรือผิดรูปแบบ], When [ส่งคำขอ], Then [ระบบต้องปฏิเสธด้วย status/error ที่ชัดเจน]
- [ ] **AC3:** Given [ผู้ใช้ไม่มีสิทธิ์ / token หมดอายุ], When [เข้าถึงฟีเจอร์], Then [ระบบต้องคืน 401/403 และไม่เปิดเผยข้อมูล]

---

## 3. Edge Cases, Failure Modes & Security
- **Network / Dependency Failure:** [Timeout, retry, fallback, idempotency key]
- **Data Integrity & Concurrency:** [ข้อมูลซ้ำ, race condition, boundary values (0, negative, max length)]
- **Authentication & Authorization:** [ใครมีสิทธิ์เข้าถึง/แก้ไข/ลบ, ตรวจ ownership ฝั่ง server หรือไม่]
- **Input Validation & Sensitive Data:** [Sanitization, rate limit, ข้อมูล PII/secrets ที่ห้าม log]

---

## 4. Non-Functional Requirements
- **Performance / Scale:** [ข้อจำกัดเวลาตอบสนอง / ปริมาณข้อมูล]
- **Compatibility:** [API / DB backward compatibility]
- **Observability:** [Structured logs / metrics ที่ต้องมี (ห้าม log secrets/PII)]

---

## 5. Out of Scope (สิ่งที่ยังไม่ทำในรอบนี้)
- [รายการที่ตั้งใจไม่ทำในรอบนี้ เพื่อคุมขอบเขตงาน]

---

## 6. Open Questions & Assumptions
- **Assumptions:** [สมมติฐานที่ใช้ถ้ายังไม่ระบุในคำขอ]
- **Open Questions (ต้องเคลียร์ก่อน Approve Spec):** [คำถามที่อาจเปลี่ยนขอบเขตหรือดีไซน์]
