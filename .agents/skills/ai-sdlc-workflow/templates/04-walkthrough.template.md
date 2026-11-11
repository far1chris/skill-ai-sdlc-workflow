# Review Walkthrough: [ชื่อฟีเจอร์]

- **Feature Slug:** `<feature-slug>`
- **Target Branch:** `feature/<feature-slug>`
- **Spec:** `./spec.md` | **Plan:** `./plan.md` | **Tasks:** `./tasks.md`
- **Status:** `READY FOR GATE 2 (Waiting for: Approve Review)`

---

## 1. Summary of Changes
- [สรุปสิ่งที่สร้าง/แก้ไขทั้งหมดแบบกระชับ เข้าใจได้ใน 30 วินาที]

---

## 2. Key Architectural Decisions & Deviations from Plan
- **Decisions:** [การตัดสินใจสำคัญระหว่างเขียนโค้ด]
- **Deviations from `plan.md`:** [ระบุ "ไม่มี" หรืออธิบายไฟล์/จุดที่เปลี่ยนไปจากแผนเดิมและเหตุผล]

---

## 3. Files Changed
| File Path | Change | Summary |
| :--- | :--- | :--- |
| `...` | `Created` / `Modified` | [สรุปการเปลี่ยนแปลง] |

---

## 4. Acceptance Criteria Traceability
| Spec AC | Status | Verified By (Test File / Case) |
| :--- | :--- | :--- |
| `AC1` | `PASS` | `...` |
| `AC2` | `PASS` | `...` |
| `AC3` | `PASS` | `...` |

---

## 5. Verification Results (`verify-gate`)
> แปะผลลัพธ์จริงที่รันหลังการแก้ไขโค้ดครั้งสุดท้ายเท่านั้น (ห้ามสรุปหรือแต่งตัวเลขเอง)

- **Command:** `<verify-gate command executed>`
- **Timestamp:** `YYYY-MM-DD HH:MM`
- **Outcome:** `ALL CHECKS PASSED` (Self-healing retries used: `0/3`)

```text
[วาง output จริงจาก verify-gate ที่นี่]
```

---

## 6. Reviewer Checklist & Known Follow-ups
- [ ] ตรวจ `git diff` แล้วไม่มีความลับ/token/debug log หลงเหลือ
- [ ] ขอบเขตงานตรงตาม `spec.md` และไม่มีการแก้ไขไฟล์นอกเรื่อง
- **Known Limitations / Future Follow-ups:** [ระบุ "ไม่มี" หรือรายการที่อยู่นอก Scope รอบนี้]

---

**Next Step (Gate 2):** กรุณาตรวจ `git diff` และรายงานฉบับนี้ หากเรียบร้อยให้พิมพ์ **`Approve Review`** เพื่อเข้าสู่ Stage 5 (`ship-pr`)
