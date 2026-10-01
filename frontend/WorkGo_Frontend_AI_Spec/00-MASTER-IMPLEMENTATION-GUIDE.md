# WorkGo Frontend — Master AI Agent Implementation Guide

## 1. Mục đích

Tài liệu này là tài liệu điều phối cao nhất cho AI agent khi triển khai frontend WorkGo.

WorkGo là một marketplace/work platform kết nối **Client** và **Provider**, hỗ trợ:
- tài khoản và xác thực;
- hồ sơ Client/Provider;
- provider verification;
- marketplace dịch vụ;
- bài đăng nhu cầu công việc;
- application/proposal;
- conversation/message/notification;
- order;
- delivery/execution;
- payment/escrow/refund;
- review/rating;
- report/dispute;
- admin/moderation.

Frontend phải làm nổi bật cảm giác của một **sản phẩm thật đang được sử dụng**, không phải một website được AI sinh ra từ một template.

## 2. Nguyên tắc bắt buộc cho AI agent

### 2.1 Không tự ý phát minh nghiệp vụ

Chỉ triển khai những nghiệp vụ được mô tả trong bộ tài liệu này hoặc đã tồn tại trong source code/API contract.

Không tự thêm:
- social feed;
- like;
- follower/following;
- repost/share;
- reaction;
- gamification không được yêu cầu;
- dashboard với hàng chục biểu đồ chỉ để "trông hiện đại".

### 2.2 Không thiết kế theo kiểu "AI-generated UI"

Tránh:
- gradient xanh/tím phủ toàn trang;
- glassmorphism dùng tràn lan;
- neon;
- card bo góc quá mức;
- shadow nặng;
- icon ở mọi vị trí;
- heading quá lớn;
- quá nhiều badge;
- hero section chiếm phần lớn màn hình nhưng không có giá trị nghiệp vụ;
- mọi section đều có card;
- mọi button đều là pill;
- màu sắc quá bão hòa;
- animation liên tục;
- layout giống landing page SaaS generic.

Mục tiêu là giao diện giống một sản phẩm marketplace/work platform được một đội product designer thực hiện lâu dài.

### 2.3 Ưu tiên hierarchy và whitespace

Mỗi màn hình phải trả lời được:
1. Người dùng đang ở đâu?
2. Họ đang làm việc gì?
3. Hành động chính là gì?
4. Thông tin nào quan trọng nhất?
5. Nếu có lỗi thì họ cần làm gì tiếp?

Không dùng decoration để thay thế hierarchy.

### 2.4 Thiết kế trước, code sau

Trước khi tạo nhiều page:
1. đọc toàn bộ bộ spec;
2. audit source hiện tại;
3. xác định routing;
4. tạo design tokens;
5. tạo primitive components;
6. tạo shared components;
7. tạo shell/layout;
8. sau đó mới xây page.

### 2.5 Reuse có kiểm soát

Nếu hai màn hình có cùng pattern, tạo component dùng chung.

Nhưng không biến mọi thứ thành một component khổng lồ với hàng chục props.

## 3. Design direction

WorkGo nên mang cảm giác:

> Professional marketplace + modern work management + trustworthy service platform.

Phong cách:
- sáng;
- sạch;
- chuyên nghiệp;
- hơi ấm;
- typography rõ;
- whitespace tốt;
- border tinh tế;
- màu accent có kiểm soát;
- imagery thực tế;
- thông tin có mật độ vừa phải.

Không cần cố tạo "wow effect". Chất lượng phải đến từ:
- spacing;
- typography;
- hierarchy;
- consistency;
- micro-interactions;
- empty/loading/error states;
- responsive behavior.

## 4. Color philosophy

Mặc định dùng light theme làm nền tảng.

Gợi ý hệ màu:

- Background: neutral rất sáng, không phải trắng tuyệt đối ở mọi nơi.
- Surface: white.
- Text primary: neutral rất đậm.
- Text secondary: neutral trung bình.
- Border: neutral nhạt.
- Primary: xanh dương WorkGo.
- Success: xanh lá tiết chế.
- Warning: amber.
- Danger: đỏ.
- Info: xanh/cyan nhẹ.

Không hard-code màu rải rác trong component.

Tất cả màu phải đi qua token.

## 5. Typography

Ưu tiên một font sans-serif hiện đại, dễ đọc.

Hierarchy:
- Display: chỉ dùng ở landing/public hero.
- H1: page title.
- H2: section.
- H3: card/section subsection.
- Body: nội dung.
- Caption: metadata.
- Label: form/control.

Không dùng quá nhiều font weight.

## 6. Radius / shadow

Border radius:
- nhỏ cho control;
- vừa cho card;
- lớn hơn một chút cho modal/drawer;
- không biến toàn bộ UI thành pill.

Shadow:
- mặc định rất nhẹ;
- dùng border trước shadow;
- shadow mạnh chỉ cho popover/modal/floating element.

## 7. Motion

Animation phải phục vụ usability.

Nên có:
- hover transition;
- focus transition;
- drawer/modal enter;
- toast;
- loading skeleton;
- optimistic state nếu phù hợp.

Không nên có:
- parallax phức tạp ở dashboard;
- floating animation liên tục;
- animation kéo dài;
- page transition làm chậm thao tác.

Tôn trọng `prefers-reduced-motion`.

## 8. Responsive

Phải thiết kế:
- desktop;
- tablet;
- mobile.

Không chỉ shrink desktop xuống mobile.

Ví dụ:
- desktop sidebar → mobile bottom navigation/drawer tùy context;
- filter sidebar → filter drawer;
- table → responsive list/card;
- two-column detail → stacked layout;
- chat split view → single-pane navigation;
- order timeline → vertical timeline.

## 9. Accessibility

Bắt buộc:
- semantic HTML;
- keyboard navigation;
- visible focus;
- aria-label cho icon-only button;
- form label;
- error message liên kết với input;
- sufficient contrast;
- no color-only status;
- dialog focus management;
- loading state có accessible indication.

## 10. Data state

Mỗi page có data state rõ ràng:
- loading;
- success;
- empty;
- error;
- permission denied;
- not found;
- stale/updating nếu cần.

Không để page chỉ có happy path.

## 11. Quy trình triển khai bắt buộc

### Phase 0 — Audit
- đọc source;
- đọc package/config;
- xác định routing;
- xác định API layer;
- xác định auth/session;
- xác định UI library;
- xác định existing components.

### Phase 1 — Foundation
- tokens;
- typography;
- spacing;
- buttons;
- inputs;
- select;
- checkbox/radio;
- badge;
- avatar;
- card;
- modal;
- drawer;
- toast;
- tabs;
- dropdown;
- tooltip;
- skeleton;
- empty state;
- error state.

### Phase 2 — App shell
- public header;
- authenticated header;
- sidebar;
- mobile navigation;
- breadcrumbs;
- page container.

### Phase 3 — Core pages
Theo thứ tự trong `02-PAGE-INVENTORY.md`.

### Phase 4 — Cross-cutting flows
- auth;
- search/filter;
- application/proposal;
- messaging;
- order;
- delivery;
- payment;
- review;
- dispute.

### Phase 5 — Admin
Moderation và management.

### Phase 6 — QA
- responsive;
- accessibility;
- visual consistency;
- console;
- broken links;
- loading/error/empty;
- API failure;
- auth permission;
- browser verification.

## 12. Definition of Done

Một màn hình chỉ được coi là hoàn thành khi:
- đúng nghiệp vụ;
- đúng route;
- có loading;
- có empty;
- có error;
- có permission state nếu cần;
- responsive;
- accessible;
- dùng design tokens;
- không có hard-coded magic values;
- không duplicate component;
- không có console error;
- không có broken interaction;
- visual hierarchy hợp lý;
- không có UI pattern mang tính "AI-generated template".

## 13. Thứ tự đọc tài liệu

AI agent phải đọc theo thứ tự:

1. `00-MASTER-IMPLEMENTATION-GUIDE.md`
2. `01-DESIGN-SYSTEM.md`
3. `02-PAGE-INVENTORY.md`
4. `03-PUBLIC-AND-AUTH-PAGES.md`
5. `04-MARKETPLACE-PAGES.md`
6. `05-WORKFLOW-PAGES.md`
7. `06-COMMUNICATION-PAGES.md`
8. `07-ACCOUNT-PAYMENT-TRUST-PAGES.md`
9. `08-ADMIN-PAGES.md`
10. `09-UX-RESPONSIVE-ACCESSIBILITY.md`
11. `10-IMPLEMENTATION-PLAN.md`
12. `11-QA-ACCEPTANCE-CHECKLIST.md`

## 14. Khi gặp mâu thuẫn

Không tự chọn.

Các mâu thuẫn đã phát hiện trong tài liệu nghiệp vụ:
- Communication context giữa architecture và SQL;
- role CUSTOMER_SERVICE xuất hiện ở architecture nhưng chưa thống nhất với SQL;
- provider verification thuộc Identity theo architecture nhưng có dữ liệu trong trust service;
- `workflow_code` tồn tại trong SQL nhưng execution type mới là khái niệm UI chính;
- cash payment xuất hiện trong flow nhưng chưa rõ trong payment method SQL;
- một số execution type được mô tả như planned.

Nếu ảnh hưởng trực tiếp tới UI, tạo `DECISION NEEDED` và chọn phương án tối thiểu không phá vỡ kiến trúc.

## 15. Nguyên tắc cuối cùng

Nếu phải lựa chọn giữa:
- nhiều tính năng nhưng UI lộn xộn;
- ít decoration nhưng hierarchy rõ;

hãy chọn hierarchy rõ.

Nếu phải lựa chọn giữa:
- component generic;
- component phù hợp với ngữ cảnh WorkGo;

hãy chọn component có ngữ cảnh nhưng vẫn tái sử dụng hợp lý.

Nếu phải lựa chọn giữa:
- animation;
- usability;

hãy chọn usability.
