# Coding Rules & Engineering Standards

> **Progressive Disclosure:** อ่านไฟล์นี้ใน **Stage 2 (Implementation)** เท่านั้น — ห้ามโหลดไว้ล่วงหน้าใน Stage 1

---

## 1. Scope & Plan Discipline
- แก้ไขเฉพาะไฟล์ที่ระบุใน `specs/<feature-slug>/plan.md` §2
- หากจำเป็นต้องแก้ไฟล์นอกแผน ให้หยุดอธิบายเหตุผลและอัปเดต `plan.md` ก่อน
- **ห้าม** refactor โค้ดส่วนอื่นที่ไม่เกี่ยวข้องกับ `spec.md` ในงานเดียวกัน
- รักษา comments และ docstrings เดิมของระบบที่ไม่เกี่ยวข้องกับการแก้ไข

## 2. Structure, Naming & Maintainability
- **Single-Purpose Functions:** แยกฟังก์ชันให้สั้น ชัดเจน ใช้ early return เพื่อลดระดับ nested `if/else`
- **No Duplication:** หากพบ logic ซ้ำ 2 จุดขึ้นไป ให้ดึงเป็น helper หรือ mapping table ร่วมกัน
- **Follow Repo Conventions:** ใช้ naming style, folder layout, error pattern และ helper เดิมของโปรเจกต์ก่อนสร้างใหม่
- **No Silent Suppression:** ห้ามแก้ `tsconfig`, `eslint`, `ruff` rules หรือใส่ `@ts-ignore` / `eslint-disable` เพื่อซ่อน error

## 3. Type Safety & Input Validation
- ตรวจสอบข้อมูลเข้า (request body, params, env vars, external API response) ที่ขอบระบบ (boundary) ด้วย schema validator หรือ type guard ที่ชัดเจน
- หลีกเลี่ยง `any` / `as any` — หากจำเป็นต้อง cast จาก untyped source ให้ตรวจ runtime shape ก่อนเสมอ

## 4. Security Baseline (Mandatory)
- **Authentication & Authorization:** ตรวจสิทธิ์ (AuthN + AuthZ / ownership check) ที่ฝั่ง server เสมอ ห้ามเชื่อค่า `userId`, `role`, `price`, หรือ `discount` จาก client
- **Secrets Management:** ห้าม hardcode API key, password, token หรือ private key ลงในโค้ด/เทสต์/ตัวอย่าง อ่านจาก environment variables เท่านั้น
- **Injection & Path Safety:** ใช้ parameterized queries / ORM bindings เท่านั้น ห้ามต่อ string ใน SQL/shell command; validate path input เพื่อกัน path traversal (`../`)
- **Output & Error Hygiene:** ห้ามส่ง raw stack trace, SQL query หรือ internal config ออกไปใน API error response และห้าม log PII / credentials / bearer tokens

## 5. Error Handling & Cleanup
- จัดการ error อย่างชัดเจนพร้อม context (`throw` / return typed error) — **ห้าม** ปล่อย `catch {}` ว่างเปล่า
- ลบ debug `console.log` / `print()` ชั่วคราวออกให้หมดก่อนรัน Stage 3 (`verify-gate`)
