# WorkGo Frontend — Public & Authentication Pages

## 1. Landing / Home

### Goal
Giải thích WorkGo là gì và đưa người dùng đến marketplace hoặc post marketplace.

### Structure
1. Header
2. Hero
3. Search
4. Popular categories
5. Featured services
6. How it works
7. Trust/verification explanation
8. CTA
9. Footer

### Design
Hero không nên chiếm toàn màn hình.

Ưu tiên:
- headline rõ;
- search box nổi bật;
- hình ảnh marketplace thực tế;
- supporting copy ngắn.

Không dùng:
- 3D blobs;
- glowing gradients;
- animation quá mạnh.

## 2. Service marketplace

### Layout desktop
- top search;
- category selector;
- filter sidebar;
- result grid/list;
- sort.

### Filters
- category;
- price;
- execution type;
- provider type;
- rating;
- availability nếu API hỗ trợ.

### Service card
- cover;
- title;
- provider;
- rating;
- starting price;
- delivery;
- execution type;
- favorite nếu feature tồn tại.

### Empty
"Không tìm thấy dịch vụ phù hợp."

Có:
- clear filters.

## 3. Service detail

Layout:
- gallery;
- service title;
- provider summary;
- rating;
- package selector;
- price;
- delivery;
- requirements;
- CTA;
- description;
- package details;
- add-ons;
- reviews;
- provider profile.

Desktop có thể dùng sticky purchase panel.

Mobile:
- CTA sticky bottom;
- sections stacked.

## 4. Provider public profile

Sections:
- avatar/name;
- provider type;
- verification;
- rating;
- completed orders;
- response indicators nếu có data;
- bio;
- services;
- reviews.

Không hiển thị dữ liệu nhạy cảm.

## 5. Post marketplace

Card:
- title;
- category;
- budget range;
- execution type;
- location;
- deadline;
- status.

Filters:
- category;
- budget;
- execution type;
- location;
- deadline.

## 6. Post detail

Sections:
- title;
- description;
- attachments;
- budget;
- deadline;
- execution/location;
- client summary;
- applications count nếu permitted;
- provider CTA: apply.

Client owner:
- edit;
- close/cancel;
- review applications.

## 7. Login

Elements:
- email/username;
- password;
- show/hide password;
- submit;
- forgot password;
- register;
- optional Google sign-in only if backend supports it.

States:
- invalid credentials;
- account inactive/suspended/banned;
- network error;
- loading.

Không dùng background decoration làm giảm readability.

## 8. Register

Nếu backend có multi-step registration:
1. identity;
2. email/contact;
3. role/type/level data theo backend contract;
4. verification.

Mỗi step:
- progress;
- concise title;
- form;
- back/next;
- validation.

## 9. Verification

Email/phone verification:
- code input;
- resend;
- countdown;
- error;
- success.

Không khóa toàn UI khi resend.

## 10. Forgot/reset password

Flow:
- identifier;
- confirmation;
- code/link;
- new password;
- success.

## 11. Authentication shell

Auth pages nên tối giản hơn app pages.

Không đưa sidebar/dashboard navigation vào login/register.
