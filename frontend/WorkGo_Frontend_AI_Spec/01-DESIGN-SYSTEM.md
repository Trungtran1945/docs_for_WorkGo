# WorkGo Frontend — Design System Specification

## 1. Mục tiêu

Tạo một hệ thống giao diện thống nhất trước khi xây các màn hình.

Design system không phải một thư viện component khổng lồ. Nó là tập hợp quy tắc giúp mọi màn hình có cùng "ngôn ngữ".

## 2. Visual personality

Từ khóa:
- trustworthy;
- professional;
- practical;
- human;
- calm;
- modern;
- marketplace;
- work-oriented.

Không sử dụng phong cách:
- cyberpunk;
- futuristic AI;
- gaming;
- crypto;
- neon SaaS;
- excessive glass.

## 3. Layout grid

Desktop:
- max content width khoảng 1200–1440px tùy page;
- page horizontal padding khoảng 24–40px;
- sidebar cố định khi cần;
- main content linh hoạt.

Tablet:
- padding giảm;
- grid chuyển 2 cột hoặc 1 cột tùy nội dung.

Mobile:
- padding khoảng 16px;
- một cột;
- action chính có thể sticky ở bottom khi thao tác quan trọng.

## 4. Spacing scale

Dùng scale thống nhất, ví dụ:
- 4
- 8
- 12
- 16
- 20
- 24
- 32
- 40
- 48
- 64

Không tạo spacing 13px, 17px, 27px tùy tiện.

## 5. Surface hierarchy

Level 0:
- app background.

Level 1:
- surface/card.

Level 2:
- elevated popover/modal.

Không đặt card bên trong card bên trong card nếu không cần.

## 6. Buttons

Variants:
- primary;
- secondary;
- outline;
- ghost;
- destructive;
- link.

Sizes:
- sm;
- md;
- lg.

Rules:
- primary action duy nhất trong một vùng nếu có thể;
- destructive action phải visually distinct;
- loading button giữ width để tránh layout shift;
- icon-only button phải có accessible label.

## 7. Form controls

Bao gồm:
- text input;
- textarea;
- select;
- combobox;
- date/time;
- currency/number;
- checkbox;
- radio;
- switch;
- file upload.

Mỗi control có:
- default;
- hover;
- focus;
- disabled;
- error;
- success nếu cần.

## 8. Cards

Card dùng cho:
- service;
- post;
- provider;
- order summary;
- package;
- review;
- notification.

Card không phải mặc định cho mọi nội dung.

## 9. Status badges

Status phải có:
- label;
- semantic color;
- optional icon.

Không chỉ dùng màu để truyền đạt trạng thái.

Ví dụ:
- Published;
- Draft;
- Pending;
- Accepted;
- Rejected;
- In progress;
- Delivered;
- Completed;
- Cancelled;
- Refunded.

## 10. Avatar

Avatar hỗ trợ:
- image;
- initials;
- fallback.

Dùng kích thước nhất quán.

## 11. Tables

Table chỉ dùng khi dữ liệu có giá trị khi so sánh theo cột.

Mobile:
- chuyển list/card;
- hoặc horizontal scroll có chủ đích.

Không ép bảng 10 cột vào màn hình 375px.

## 12. Modal / Drawer

Modal:
- confirmation;
- destructive action;
- compact form.

Drawer:
- filters;
- mobile navigation;
- contextual details.

Không dùng modal cho workflow dài.

## 13. Toast

Chỉ dùng cho:
- action completed;
- background operation;
- lightweight feedback.

Validation lỗi phải nằm gần field.

## 14. Empty state

Mỗi empty state gồm:
- title;
- short explanation;
- primary action nếu có;
- optional illustration nhẹ.

Không dùng illustration quá lớn.

## 15. Skeleton

Skeleton phải gần với layout thật.

Không skeleton mọi thứ nếu page có thể render shell trước.

## 16. Iconography

Chọn một icon family thống nhất.

Không trộn nhiều icon styles.

Icon có chức năng rõ ràng, không trang trí vô nghĩa.

## 17. Imagery

Service/provider imagery nên:
- thật;
- có crop nhất quán;
- không quá saturated;
- không dùng ảnh stock cliché nếu không cần.

Nếu chưa có dữ liệu thật, dùng neutral placeholder.

## 18. Design tokens

Tất cả:
- colors;
- spacing;
- typography;
- radius;
- shadow;
- z-index;
- motion;

phải tập trung trong token layer.

## 19. Component architecture

Nên chia:
- primitives;
- composed components;
- domain components;
- page sections;
- pages.

Ví dụ:

`Button`
→ `ServiceCard`
→ `ServiceGrid`
→ `MarketplacePage`

Không để `ServiceCard` chứa business logic API.

## 20. Microcopy

Ngôn ngữ UI phải:
- ngắn;
- rõ;
- trực tiếp;
- tự nhiên;
- không marketing quá mức.

Ví dụ tốt:
- "Đặt dịch vụ"
- "Gửi đề xuất"
- "Xác nhận hoàn thành"
- "Yêu cầu chỉnh sửa"

Tránh:
- "Khám phá hành trình tuyệt vời của bạn ngay hôm nay!!!"
