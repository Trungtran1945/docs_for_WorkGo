# WorkGo Frontend — Admin & Moderation UI

## 1. Admin design philosophy

Admin UI cần:
- information density cao hơn public UI;
- ít decoration;
- table/filter/search mạnh;
- clear status;
- auditability.

Không cần biến admin thành dashboard màu mè.

## 2. Admin shell

Sidebar:
- Overview
- Users
- Provider Verification
- Services
- Posts
- Reviews
- Reports
- Disputes
- Orders/Payments nếu API hỗ trợ

Header:
- search;
- notifications;
- admin profile.

## 3. Admin dashboard

Chỉ hiển thị metrics có ý nghĩa:
- users;
- active providers;
- pending verifications;
- open reports;
- open disputes;
- active orders;
- payment issues nếu backend hỗ trợ.

Không tự tạo metric không có nguồn dữ liệu.

## 4. Users

Table:
- user;
- role;
- status;
- created;
- last activity nếu có;
- actions.

Filters:
- role;
- status;
- date.

Actions:
- view;
- suspend;
- activate;
- ban/unban nếu API hỗ trợ.

Destructive action cần confirmation.

## 5. Provider verification queue

Columns:
- provider;
- verification type;
- submitted date;
- status;
- reviewer.

Detail:
- provider info;
- documents;
- verification data;
- approve;
- reject;
- rejection reason.

## 6. Service moderation

List:
- service;
- provider;
- category;
- status;
- submitted/updated;
- actions.

Detail:
- service content;
- media;
- provider;
- moderation action.

## 7. Post moderation

Tương tự service.

## 8. Review moderation

Table:
- reviewer;
- target;
- rating;
- content;
- status;
- date.

Actions:
- approve;
- reject;
- hide;
- inspect context.

## 9. Reports

Statuses:
- pending;
- reviewing;
- resolved;
- rejected.

Detail:
- reporter;
- target;
- reason;
- description;
- evidence;
- related resource;
- resolution.

## 10. Disputes

Statuses:
- open;
- under review;
- resolved client;
- resolved provider;
- closed.

Detail:
- order;
- participants;
- evidence;
- timeline;
- resolution.

## 11. Admin tables

Bắt buộc:
- pagination;
- sorting nếu API hỗ trợ;
- filtering;
- loading;
- empty;
- error;
- bulk actions chỉ khi nghiệp vụ cho phép.

## 12. Permission

Frontend chỉ ẩn/hiện UI theo permission để UX.

Backend vẫn là authority.

Không coi route guard frontend là security boundary.
