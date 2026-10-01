# WorkGo Frontend — Account, Verification, Reviews, Reports & Disputes

## 1. Account

### Profile
Client:
- client type;
- individual/company;
- company name;
- industry;
- jobs posted.

Provider:
- provider type;
- business name;
- bio;
- verification;
- rating;
- completed orders;
- accepting orders.

Không cho user sửa các field chỉ backend/admin được quyền sửa.

## 2. Address management

Address:
- label;
- contact name;
- phone;
- street/line1;
- ward;
- district;
- city;
- country;
- latitude/longitude;
- note;
- default.

UX:
- list;
- add;
- edit;
- set default;
- delete with confirmation.

## 3. Provider verification

Verification types:
- identity;
- business;
- certification.

Documents:
- ID card;
- passport;
- business license;
- certificate.

Statuses:
- pending;
- verified;
- rejected.

Screen:
- current status;
- required documents;
- upload;
- document list;
- rejection reason if any;
- resubmit.

Sensitive document UI phải:
- hạn chế preview nếu không cần;
- tránh expose public;
- show upload progress;
- clear security copy.

## 4. Settings

Sections:
- account;
- contact;
- security;
- notifications;
- preferences.

Không gom tất cả thành một form dài.

## 5. Reviews

Review:
- two-way;
- client → provider;
- provider → client.

Fields:
- rating;
- comment.

States:
- pending moderation;
- approved;
- rejected;
- hidden.

Review form:
- star/rating input accessible;
- comment;
- submit;
- confirmation.

Không ép người dùng viết review nếu không bắt buộc.

## 6. Report

Target:
- user;
- post;
- service;
- message;
- review.

Form:
- reason;
- description;
- optional evidence if supported.

After submit:
- report ID/status nếu API có;
- explain next step.

## 7. Dispute

Dispute:
- order;
- opened by;
- reason;
- description;
- status;
- resolution.

Statuses:
- open;
- under review;
- resolved client;
- resolved provider;
- closed.

UI:
- order context;
- dispute timeline;
- evidence;
- messages;
- resolution.

Không cho user tự sửa trạng thái dispute.

## 8. Trust indicators

Có thể hiển thị:
- verified;
- rating;
- completed orders;
- review count.

Chỉ hiển thị số liệu backend xác nhận.

Không tạo "trust score" mới nếu nghiệp vụ không có.

## 9. Security UX

Sensitive actions:
- change password;
- delete account;
- payment;
- identity documents;

nên có confirmation/reauthentication nếu backend yêu cầu.

## 10. Error states

Nếu account bị:
- inactive;
- suspended;
- banned;
- pending verification;

UI phải giải thích trạng thái và next step phù hợp, không chỉ hiện mã lỗi.
