# WorkGo Frontend — Detailed Implementation Plan for AI Agent

## 1. Rule

Không triển khai tất cả page cùng lúc.

Mỗi phase phải:
1. implement;
2. run;
3. verify;
4. fix;
5. only then move on.

## 2. Phase 0 — Repository audit

AI agent phải:
- inspect project tree;
- inspect package.json;
- inspect frontend entry;
- inspect routing;
- inspect API client;
- inspect auth;
- inspect existing styles;
- inspect components;
- inspect environment variables;
- identify current framework.

Output:
`docs/ai-agent/frontend-audit.md`

Không rewrite framework chỉ vì agent thích framework khác.

## 3. Phase 1 — Foundation

Implement:
- tokens;
- typography;
- global CSS;
- Button;
- Input;
- Textarea;
- Select;
- Checkbox;
- Radio;
- Switch;
- Badge;
- Avatar;
- Card;
- Modal;
- Drawer;
- Dropdown;
- Tabs;
- Toast;
- Skeleton;
- EmptyState;
- ErrorState.

Acceptance:
- no duplicate primitive;
- consistent tokens;
- keyboard usable.

## 4. Phase 2 — Shell

Implement:
- PublicHeader;
- AppHeader;
- Sidebar;
- MobileNav;
- PageContainer;
- Breadcrumb;
- UserMenu;
- NotificationBell;
- MessageEntry.

Verify:
- desktop;
- mobile;
- auth/non-auth.

## 5. Phase 3 — Public marketplace

Order:
1. Home
2. Services
3. Service detail
4. Provider profile
5. Posts
6. Post detail

Do not build admin before public marketplace is stable.

## 6. Phase 4 — Auth

Implement:
- login;
- register;
- verification;
- forgot/reset;
- auth states.

Connect to real API if available.

No fake auth persistence.

## 7. Phase 5 — Client workflow

Order:
1. Client dashboard
2. My posts
3. Create/edit post
4. Applications
5. Proposal review
6. Orders
7. Order detail
8. Payment
9. Delivery/execution
10. Review
11. Settings

## 8. Phase 6 — Provider workflow

Order:
1. Provider dashboard
2. Profile
3. Verification
4. Services
5. Service editor
6. Packages/add-ons
7. Availability
8. Applications
9. Proposals
10. Orders
11. Delivery/revisions
12. Reviews
13. Settings

## 9. Phase 7 — Communication

Implement:
- inbox;
- conversation;
- message composer;
- attachment;
- proposal message;
- notifications.

## 10. Phase 8 — Trust & operations

Implement:
- reports;
- disputes;
- evidence;
- moderation-related states.

## 11. Phase 9 — Admin

Implement admin shell and pages.

## 12. Phase 10 — QA

Run:
- build;
- lint;
- type check;
- browser verification;
- responsive verification.

Fix:
- console errors;
- hydration errors if applicable;
- broken routes;
- API errors;
- accessibility violations;
- overflow.

## 13. Git strategy

Mỗi phase nên có commit rõ ràng.

Ví dụ:
- `feat(ui): establish WorkGo design system`
- `feat(marketplace): build service discovery`
- `feat(order): build order workflow`
- `feat(admin): add moderation screens`

Không tạo commit kiểu:
`update stuff`.

## 14. API uncertainty

Nếu API chưa tồn tại:
- create typed mock/service adapter only if project architecture allows;
- mark TODO;
- do not fake a successful backend mutation as production behavior.

## 15. Don't break existing work

Trước khi sửa shared component:
- inspect consumers;
- update safely;
- run relevant tests/build.

## 16. Completion report

Sau mỗi phase, ghi:
- files changed;
- features completed;
- known limitations;
- API assumptions;
- screenshots/verification;
- next phase.

## 17. Stop conditions

Agent phải dừng và báo cáo nếu:
- backend contract không rõ;
- destructive schema change required;
- auth architecture unknown;
- existing code conflicts materially;
- required asset/credential missing.

Không tự phá architecture để "làm cho chạy".
