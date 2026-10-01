# WorkGo Frontend — Marketplace, Service & Post Management

## 1. Provider Service Management

### My Services
Hiển thị:
- service title;
- category;
- status;
- price;
- updated time;
- orders;
- actions.

Actions:
- edit;
- publish/unpublish nếu allowed;
- archive;
- preview.

### Status
- Draft
- Published
- Archived
- Suspended

Status phải được phân biệt rõ nhưng không quá màu mè.

## 2. Create/Edit Service

Form sections:

### Basic information
- title;
- description;
- category;
- execution type.

### Media
- image;
- video;
- document;
- cover;
- ordering.

### Packages
Mỗi package:
- name;
- description;
- price;
- currency;
- delivery days;
- duration;
- revision limit;
- features.

### Add-ons
- name;
- description;
- price.

### Availability
Nếu execution type cần lịch:
- weekday;
- start/end;
- slot duration;
- active status.

### UX
Form dài nên dùng section rõ ràng hoặc multi-step nếu thật sự cần.

Không dùng accordion cho mọi section chỉ vì "trông hiện đại".

## 3. Post Management

### My Posts
Table/list:
- title;
- category;
- budget;
- deadline;
- status;
- applications;
- updated.

### Create Post
Sections:
- title;
- description;
- category;
- budget;
- currency;
- execution type;
- location;
- deadline;
- attachments.

### Important
Budget min/max phải được validate.

Location UI chỉ hiển thị field phù hợp với execution type.

## 4. Applications

Client view:
- provider;
- provider rating;
- message;
- proposal;
- estimated days;
- status.

Provider view:
- application status;
- proposal;
- withdrawal.

Actions:
- accept;
- reject;
- withdraw;
- view provider.

## 5. Proposal

Proposal panel gồm:
- price;
- currency;
- estimated days;
- message;
- terms;
- expiration;
- status.

Nếu accepted:
- chuyển sang order workflow.

Không coi Application và Order là cùng một entity.

## 6. Search

Search cần:
- debounce nếu gọi API liên tục;
- preserve query;
- filters;
- sort;
- pagination/infinite loading theo API.

Search state nên có URL query khi phù hợp để link/share được.

## 7. Favorites

Nếu backend có favorite:
- toggle state;
- optimistic update nếu an toàn;
- error rollback;
- login required nếu anonymous.

Không giả định feature nếu backend không hỗ trợ.

## 8. Marketplace visual rule

Service card và Post card phải có hierarchy khác nhau.

Service:
`image → title → provider → rating → price → delivery`

Post:
`title → budget → category/execution → deadline → client`

Không dùng cùng một card template cho hai loại nội dung.
