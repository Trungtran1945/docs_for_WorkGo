# WorkGo Frontend AI Implementation Specification

Đây là bộ tài liệu đặc tả dành cho AI coding agent triển khai frontend WorkGo.

## Cấu trúc

| File | Nội dung |
|---|---|
| `00-MASTER-IMPLEMENTATION-GUIDE.md` | Quy tắc tổng thể và thứ tự triển khai |
| `01-DESIGN-SYSTEM.md` | Visual language, tokens, components |
| `02-PAGE-INVENTORY.md` | Information architecture và danh sách màn hình |
| `03-PUBLIC-AND-AUTH-PAGES.md` | Public + authentication |
| `04-MARKETPLACE-PAGES.md` | Marketplace, services, posts, proposals |
| `05-WORKFLOW-PAGES.md` | Orders, execution, delivery, payment |
| `06-COMMUNICATION-PAGES.md` | Chat, messages, notifications |
| `07-ACCOUNT-PAYMENT-TRUST-PAGES.md` | Account, verification, review, report, dispute |
| `08-ADMIN-PAGES.md` | Admin và moderation |
| `09-UX-RESPONSIVE-ACCESSIBILITY.md` | Responsive, accessibility, UX |
| `10-IMPLEMENTATION-PLAN.md` | Roadmap triển khai theo phase |
| `11-QA-ACCEPTANCE-CHECKLIST.md` | QA và Definition of Done |
| `12-AGENT-EXECUTION-PROMPT.md` | Prompt điều phối agent |

## Cách sử dụng

Đặt toàn bộ thư mục này vào project frontend hoặc thư mục documentation mà AI agent có thể đọc.

Khuyến nghị:
1. Agent đọc `00-MASTER-IMPLEMENTATION-GUIDE.md`.
2. Agent đọc toàn bộ các file còn lại.
3. Agent audit source hiện tại.
4. Agent triển khai từng phase.
5. Sau mỗi phase chạy build/test/browser verification.
6. Chỉ chuyển phase khi phase trước đạt acceptance.

## Quan trọng

Bộ tài liệu này đặc tả **frontend experience và cách triển khai**, không thay thế API contract/backend specification.

Nếu frontend gặp nghiệp vụ chưa rõ, agent phải đối chiếu source/API và đánh dấu `DECISION NEEDED`, không tự phát minh behavior.
