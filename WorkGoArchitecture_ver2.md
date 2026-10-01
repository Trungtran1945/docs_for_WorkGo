# WorkGo Architecture

> **Phiên bản:** 2.0 – Final Design (Ver 2)  
> **Trạng thái:** FINAL / TARGET ARCHITECTURE  
> **Mục tiêu:** Thiết kế kiến trúc và dữ liệu mục tiêu cho hệ thống WorkGo theo hướng microservices, có thể triển khai từng phần nhưng không phải thay đổi business model lõi khi mở rộng.
>
> **Nguyên tắc:** Thành phần chưa triển khai được đánh dấu `PLANNED`, nhưng vẫn được xác định rõ boundary, ownership và dữ liệu để có thể bổ sung về sau.
# 1. Tổng quan WorkGo

**WorkGo** là một **professional service marketplace** kết nối Client và Provider để mua, bán và thực hiện dịch vụ từ online đến offline.

WorkGo hỗ trợ:

- Provider đăng bán dịch vụ.
- Client đăng nhu cầu công việc.
- Client và Provider trao đổi trước khi giao dịch.
- Provider ứng tuyển Post.
- Provider gửi Proposal.
- Hai bên xác nhận giao dịch bằng Order.
- Dịch vụ có nhiều Package: Basic / Standard / Premium.
- Có Add-on mở rộng.
- Hỗ trợ dịch vụ DIGITAL, ONSITE, APPOINTMENT, HOURLY, PROJECT và DELIVERY.
- Thanh toán qua Payment Service.
- Holding/escrow-like để giữ tiền trước khi hoàn thành.
- Giao việc và nghiệm thu.
- Delivery đơn giản với pickup → destination → proof.
- Review, Report, Dispute và Provider Verification.
- Notification và Message theo ngữ cảnh công việc.

WorkGo **không phải Social Network**.

Không đưa các chức năng sau vào Marketplace Core:

```text
Like
Comment
Share
Repost
Follower/Following công khai
News Feed giải trí
Viral content
```

Thay vào đó chỉ sử dụng các cơ chế UX cần thiết cho giao dịch:

```text
Message
Conversation
Notification
Activity liên quan đến công việc
```

---

# 2. Business Model cốt lõi

## 2.1. Các khái niệm trung tâm

```text
SERVICE
= Provider đang bán dịch vụ gì?

POST
= Client đang cần công việc gì?

APPLICATION
= Provider muốn nhận Post nào?

PROPOSAL
= Provider đề xuất giá, thời gian và điều kiện thực hiện Post.

ORDER
= Hai bên đã xác nhận giao dịch nào?

EXECUTION
= Order được thực hiện theo hình thức nào?

PAYMENT
= Tiền của giao dịch được xử lý như thế nào?

LOGISTICS
= Việc di chuyển/giao nhận vật lý được quản lý như thế nào?

REVIEW / TRUST
= Kết quả, đánh giá và mức độ tin cậy sau giao dịch.
```

Các khái niệm này không được gộp tùy tiện.

---

# 3. Hai nguồn tạo Order

WorkGo có hai workflow chính.

## 3.1. Flow A – Service Listing

Provider chủ động bán dịch vụ.

```text
Provider
   ↓
Create SERVICE
   ↓
Client discovers SERVICE
   ↓
Contact / Buy
   ↓
Select PACKAGE + ADD-ON
   ↓
ORDER
   ↓
PAYMENT
   ↓
EXECUTION
   ↓
DELIVERY / ACCEPTANCE
   ↓
COMPLETED
   ↓
REVIEW
```

## 3.2. Flow B – Post Marketplace

Client chủ động đăng nhu cầu.

```text
Client
   ↓
POST
   ↓
Provider views Post
   ↓
APPLICATION
   ↓
MESSAGE
   ↓
PROPOSAL
   ↓
Client ACCEPT
   ↓
ORDER
   ↓
PAYMENT
   ↓
EXECUTION
   ↓
COMPLETED
   ↓
REVIEW
```

### Quy tắc bắt buộc

```text
APPLY
≠
ORDER
```

Apply chỉ thể hiện Provider quan tâm đến Post.

Order chỉ được tạo sau khi Client chấp nhận Proposal hoặc sau khi Client mua Service.

---

# 4. Execution Type

`execution_type` là cách Order được thực hiện.

| Code | Ý nghĩa | Ví dụ |
|---|---|---|
| DIGITAL | Bàn giao online/file | Design, content |
| ONSITE | Thực hiện tại địa điểm | Sửa điện |
| APPOINTMENT | Dịch vụ theo lịch hẹn | Gia sư, salon |
| HOURLY | Tính theo thời gian | IT support |
| PROJECT | Dự án nhiều bước | Website, app |
| DELIVERY | Pickup → destination | Giao tài liệu |

`execution_type` không phải Category.

Ví dụ:

```text
CATEGORY
Programming

SERVICE
Build E-commerce Website

PACKAGE
Basic / Standard / Premium

EXECUTION_TYPE
PROJECT
```

---

# 5. Kiến trúc tổng thể

```text
                         WORKGO CLIENT
                       Web / Mobile App
                              │
                              ▼
                       ┌──────────────┐
                       │ API GATEWAY  │
                       └──────┬───────┘
                              │
       ┌──────────┬───────────┼───────────┬───────────┬───────────┐
       ▼          ▼           ▼           ▼           ▼
   IDENTITY    CATALOG       POST   COMMUNICATION    TRUST
       │          │           │           │           │
       └──────────┴───────────┼───────────┴───────────┘
                              │
                              ▼
                         ORDER SERVICE
                              │
                 ┌────────────┼────────────┐
                 ▼            ▼            ▼
             EXECUTION     PAYMENT      LOGISTICS
                 │            │            │
          ┌──────┼──────┐     │      ┌─────┼─────┐
          ▼      ▼      ▼     ▼      ▼     ▼     ▼
       DIGITAL ONSITE PROJECT HOLDING PICKUP TRACK PROOF

                 RabbitMQ + Transactional Outbox
```

**Lưu ý:** Payment và Logistics là **microservice ngang hàng** với Order, không phải module con của Order.

`EXECUTION` là module/bounded subdomain bên trong Order Service.

---

# 6. Các Microservice chính

| Service | Database | Ownership |
|---|---|---|
| Identity Service | `db_identity` | User, Role, Provider Profile, Provider Verification, Address |
| Catalog Service | `db_catalog` | Category, Service, Package, Add-on, Availability |
| Post Service | `db_post` | Post, Application, Proposal |
| Communication Service | `db_communication` | Conversation, Message, Notification |
| Order Service | `db_order` | Order, Snapshot, Execution, Cancellation |
| Payment Service | `db_payment` | Payment, Holding, Escrow, Refund, Provider Payout Account, Payout |
| Logistic Service | `db_logistics` | Delivery, Location, Proof |
| Trust Service | `db_trust` | Review, Report, Dispute |

Infrastructure:

```text
API Gateway
RabbitMQ
PostgreSQL
Object Storage
Redis                 PLANNED
Search Engine         PLANNED
```

---

# 7. Database per Service

Mỗi Service sở hữu Database riêng.

```text
identity-service       → db_identity
catalog-service        → db_catalog
post-service            → db_post
communication-service  → db_communication
order-service          → db_order
payment-service        → db_payment
logistic-service      → db_logistics
trust-service          → db_trust
```

## 7.1. Không có Foreign Key xuyên Service

Ví dụ:

```text
catalog.service.provider_id
```

chỉ là UUID tham chiếu logic tới:

```text
identity.user.id
```

Không tạo:

```sql
FOREIGN KEY (...) REFERENCES ...
```

giữa hai database.

Liên service sử dụng:

```text
REST API
Event
RabbitMQ
Read Model
Saga
```

tùy nghiệp vụ.

---

# 8. Identity Service

## 8.1. Trách nhiệm

- Đăng ký.
- Đăng nhập.
- Password.
- JWT / Refresh Token.
- User.
- Role.
- Provider Profile.
- Provider Verification.
- Address.
- Trạng thái tài khoản.
- Thông tin nhận diện cơ bản.

Provider Verification thuộc Identity Service và được quản lý cùng với hồ sơ Provider.

## 8.2. USER

```text
USER
------------------------------
id                  PK
email               UNIQUE
password_hash
full_name
phone
avatar_url
status
created_at
updated_at
```

### Mục đích

Đại diện cho tài khoản người dùng trong toàn hệ thống.

`id` được các Service khác tham chiếu logic.

## 8.3. USER_ROLE

```text
USER_ROLE
------------------------------
user_id             PK, FK → USER
role                PK
granted_at
```

Role:

```text
CLIENT
PROVIDER
CUSTOMER_SERVICE
ADMIN
```

Một User có thể có nhiều Role.

## 8.4. PROVIDER_PROFILE

```text
PROVIDER_PROFILE
------------------------------
user_id                     PK, FK → USER
provider_type
business_name
bio
verification_status
rating_avg                  read model
rating_count                read model
completed_order_count      read model
is_accepting_orders
joined_at
updated_at
```

### Mục đích

Thông tin nghề nghiệp của Provider.

Các trường:

- `rating_avg`: dữ liệu tổng hợp từ Trust.
- `rating_count`: số review hợp lệ.
- `completed_order_count`: số Order hoàn thành.
- `verification_status`: trạng thái verification do Identity Service quản lý.
- `is_accepting_orders`: Provider có đang nhận đơn hay không.


## 8.5. PROVIDER_VERIFICATION

```text
PROVIDER_VERIFICATION
------------------------------
id                  PK
provider_id
verification_type
document_type
status
submitted_at
verified_at
rejected_reason
verified_by
created_at
updated_at
```

Status:

```text
PENDING
VERIFIED
REJECTED
EXPIRED
```

### Ownership

Identity Service sở hữu chi tiết verification cùng với Provider Profile.

Identity không duplicate verification data sang Service khác.

Không đưa giấy tờ nhạy cảm sang các Service khác.

## 8.6. ADDRESS

```text
ADDRESS
------------------------------
id                  PK
user_id             FK → USER
label
contact_name
contact_phone
line1
ward
district
city
country_code
latitude
longitude
note
is_default
created_at
updated_at
```

### Mục đích

Lưu địa chỉ của User.

Tọa độ phục vụ:

- ONSITE.
- DELIVERY.
- Tìm kiếm theo khu vực.
- Xác nhận địa điểm.

## 8.7. PROVIDER_SKILL – PLANNED

Thiết kế mục tiêu nên tiến tới:

```text
SKILL
------------------------------
id                  PK
name                UNIQUE
description

PROVIDER_SKILL
------------------------------
provider_id         PK
skill_id            PK
level
created_at
```

Không nên duy trì `skill_name` tự do lâu dài vì dễ trùng dữ liệu.

## 8.8. PORTFOLIO_ITEM – PLANNED

```text
PORTFOLIO_ITEM
------------------------------
id                  PK
provider_id
category_id         logical reference
title
description
cover_url
media_url
project_url
created_at
updated_at
status
```

### Mục đích

Lưu các sản phẩm/công việc tiêu biểu của Provider.

Portfolio là nội dung nghề nghiệp, không phải Shared Post.

---

# 9. Catalog Service

## 9.1. Trách nhiệm

Catalog trả lời:

> Provider đang cung cấp dịch vụ gì?

Sở hữu:

```text
CATEGORY
SERVICE
SERVICE_MEDIA
SERVICE_PACKAGE
SERVICE_ADDON
AVAILABILITY_RULE
BOOKING_SLOT
```

## 9.2. CATEGORY

```text
CATEGORY
------------------------------
id                  PK
parent_id           FK → CATEGORY
name
slug                UNIQUE
description
status
sort_order
created_at
updated_at
```

Category có thể phân cấp.

Ví dụ:

```text
Digital
 ├── Programming
 ├── UI/UX
 ├── Graphic Design
 └── Writing

Home Services
 ├── Electrical
 ├── Plumbing
 └── Cleaning

Delivery
 ├── Document
 ├── Parcel
 └── Small Item
```

## 9.3. SERVICE

```text
SERVICE
------------------------------
id                  PK
provider_id
category_id
execution_type
title
slug
description
base_price
currency
status
avg_rating          read model
review_count        read model
order_count         read model
published_at
created_at
updated_at
```

### Mục đích

Đại diện cho một dịch vụ Provider đang bán.

`provider_id` là logical reference tới Identity.

`category_id` là logical reference tới Catalog Category.

## 9.4. SERVICE_MEDIA

```text
SERVICE_MEDIA
------------------------------
id                  PK
service_id          FK → SERVICE
url
media_type
is_cover
sort_order
created_at
```

Mục đích: hình ảnh/video/file giới thiệu Service.

## 9.5. SERVICE_PACKAGE

```text
SERVICE_PACKAGE
------------------------------
id                  PK
service_id          FK → SERVICE
name
description
price
currency
delivery_days
duration_minutes
revision_limit
features            JSON
sort_order
status
created_at
updated_at
```

Ví dụ:

```text
Basic
Standard
Premium
```

### Mục đích

Một Service có nhiều mức cung cấp.

Các thuộc tính như:

```text
delivery_days
duration_minutes
revision_limit
features
```

nằm ở Package vì mỗi Package có thể khác nhau.

## 9.6. SERVICE_ADDON

```text
SERVICE_ADDON
------------------------------
id                  PK
service_id          FK → SERVICE
name
description
price
currency
status
created_at
updated_at
```

Ví dụ:

```text
Extra Revision
Source File
Express Delivery
Additional Page
```

## 9.7. AVAILABILITY_RULE

```text
AVAILABILITY_RULE
------------------------------
id                  PK
service_id          FK → SERVICE
day_of_week
start_time
end_time
slot_duration_minutes
status
```

Mục đích: quy tắc lịch làm việc.

## 9.8. BOOKING_SLOT

```text
BOOKING_SLOT
------------------------------
id                  PK
service_id          FK → SERVICE
start_at
end_at
status
hold_expires_at
order_id            logical reference
version
created_at
updated_at
```

Status:

```text
AVAILABLE
HELD
BOOKED
BLOCKED
```

`HELD` bắt buộc có `hold_expires_at`.

`order_id` là tham chiếu logic. Nếu cần tránh liên kết hai chiều quá mạnh, có thể chỉ dùng `ONSITE_EXECUTION.booking_slot_id` làm liên kết chính và giữ `order_id` như read reference.

---

# 10. Post Service

## 10.1. Trách nhiệm

Post Service trả lời:

> Client đang cần người làm công việc gì?

Sở hữu:

```text
POST
POST_ATTACHMENT
APPLICATION
PROPOSAL
```

## 10.2. POST

```text
POST
------------------------------
id                  PK
client_id
category_id
title
description
budget_min
budget_max
currency
execution_type
location_snapshot
deadline_at
status
created_at
updated_at
```

Status:

```text
OPEN
PAUSED
CLOSED
CANCELLED
EXPIRED
```

`category_id` là logical reference tới Catalog.

`location_snapshot` lưu thông tin địa điểm tại thời điểm đăng Post nếu Post cần địa điểm.

## 10.3. POST_ATTACHMENT

```text
POST_ATTACHMENT
------------------------------
id                  PK
post_id              FK → POST
file_url
file_name
mime_type
size_bytes
created_at
```

## 10.4. APPLICATION

```text
APPLICATION
------------------------------
id                  PK
post_id              FK → POST
provider_id
message
status
created_at
updated_at
```

Status:

```text
SUBMITTED
WITHDRAWN
REJECTED
SHORTLISTED
```

Unique:

```text
(post_id, provider_id)
```

### Mục đích

Ghi nhận Provider ứng tuyển vào Post.

## 10.5. PROPOSAL

```text
PROPOSAL
------------------------------
id                  PK
post_id              FK → POST
application_id      FK → APPLICATION
price
currency
estimated_days
message
terms
expires_at
status
created_at
updated_at
```

Status:

```text
DRAFT
SENT
ACCEPTED
REJECTED
EXPIRED
WITHDRAWN
```

Không lưu `provider_id` vì Provider có thể suy ra từ `APPLICATION.provider_id`.

Nếu cần denormalize cho hiệu năng, phải ghi rõ đây là read optimization và có cơ chế đồng bộ.

---

# 11. Communication Service

## 11.1. Trách nhiệm

Communication sở hữu:

```text
CONVERSATION
CONVERSATION_PARTICIPANT
MESSAGE
MEDIA_ATTACHMENT
NOTIFICATION
```

Communication **không sở hữu business state** của Post, Proposal hoặc Order.

## 11.2. CONVERSATION

```text
CONVERSATION
------------------------------
id                  PK
conversation_type
context_type
context_id
status
created_at
last_message_at
```

`context_type`:

```text
POST
SERVICE
ORDER
GENERAL
```

`context_id` là logical reference.

## 11.3. CONVERSATION_PARTICIPANT

```text
CONVERSATION_PARTICIPANT
------------------------------
conversation_id     PK
user_id             PK
joined_at
last_read_at
```

Quan hệ:

```text
CONVERSATION 1 ─── N PARTICIPANT
USER         1 ─── N PARTICIPANT
```

## 11.4. MESSAGE

```text
MESSAGE
------------------------------
id                  PK
conversation_id     FK
sender_id
content
message_type
sent_at
read_at
```

Type:

```text
TEXT
FILE
IMAGE
SYSTEM
```

Không cho User đọc Conversation nếu không phải Participant.

## 11.5. MEDIA_ATTACHMENT

```text
MEDIA_ATTACHMENT
------------------------------
id                  PK
message_id          FK → MESSAGE
file_url
file_name
mime_type
size_bytes
created_at
```

Tách Attachment thành entity riêng để một Message có thể có nhiều file.

## 11.6. NOTIFICATION

```text
NOTIFICATION
------------------------------
id                  PK
recipient_id
type
title
content
reference_type
reference_id
read_at
created_at
```

Không dùng đồng thời `is_read` và `read_at`.

Quy ước:

```text
read_at = NULL       → chưa đọc
read_at != NULL      → đã đọc
```

Notification chỉ là thông tin dẫn đường.

Business action vẫn thuộc Service sở hữu dữ liệu.

---

# 12. Order Service

## 12.1. Trách nhiệm

Order Service là trung tâm transaction của WorkGo.

Sở hữu:

```text
ORDER
ORDER_SNAPSHOT
ORDER_ITEM
ORDER_STATUS_HISTORY
CANCELLATION_REQUEST

EXECUTION
DIGITAL_EXECUTION
ONSITE_EXECUTION
PROJECT_EXECUTION
HOURLY_EXECUTION
APPOINTMENT_EXECUTION
DELIVERY_EXECUTION

DELIVERY_PACKAGE
DELIVERY_FILE
REVISION_REQUEST
WORK_EVIDENCE

SAGA_INSTANCE
OUTBOX_EVENT
```

**Không sở hữu REVIEW.**

Review thuộc Trust Service.

---

# 13. ORDER

```text
ORDER
------------------------------
id                  PK
order_number        UNIQUE
source_type
source_id
client_id
provider_id
service_id          logical
package_id          logical
execution_type
title
subtotal
platform_fee
total_amount
provider_net_amount
currency
status
payment_status      read model
placed_at
confirmed_at
started_at
delivered_at
completed_at
cancelled_at
auto_complete_at
version
created_at
updated_at
```

`source_type`:

```text
SERVICE
PROPOSAL
```

Ví dụ:

```text
source_type = SERVICE
source_id   = service UUID
```

hoặc:

```text
source_type = PROPOSAL
source_id   = proposal UUID
```

### Quan trọng

Không dùng `workflow_code`.

WorkGo thống nhất một khái niệm:

```text
execution_type
```

Cụ thể:

```text
SERVICE.execution_type
        ↓
ORDER.execution_type
        ↓
EXECUTION.execution_type
```

Order lưu `execution_type` như snapshot của loại thực hiện tại thời điểm tạo Order.

---

# 14. ORDER_SNAPSHOT

```text
ORDER_SNAPSHOT
------------------------------
order_id            PK
service_snapshot
provider_snapshot
package_snapshot
pricing_snapshot
requirement_values
execution_snapshot
created_at
```

Các snapshot nên bao gồm:

```text
Service:
- id
- title
- description

Provider:
- id
- display name
- business name

Package:
- id
- name
- description
- price
- delivery_days
- duration_minutes
- revision_limit
- features

Pricing:
- subtotal
- add-ons
- platform fee
- total

Execution:
- execution_type
- address
- schedule
- policy liên quan
```

### Mục đích

Lịch sử Order không được thay đổi khi Service/Provider thay đổi sau này.

---

# 15. ORDER_ITEM

```text
ORDER_ITEM
------------------------------
id                  PK
order_id            FK → ORDER
item_type
reference_id
name
quantity
unit_price
amount
sort_order
created_at
```

Ví dụ:

```text
PACKAGE
ADDON
EXTRA
FEE
```

`name` và `unit_price` được snapshot tại thời điểm Order.

---

# 16. ORDER_STATUS_HISTORY

```text
ORDER_STATUS_HISTORY
------------------------------
id                  PK
order_id            FK → ORDER
from_status
to_status
actor_id
actor_role
created_at
```

### Mục đích

Audit toàn bộ vòng đời Order.

---

# 17. CANCELLATION_REQUEST

```text
CANCELLATION_REQUEST
------------------------------
id                  PK
order_id            UNIQUE
requested_by
requested_by_role
reason_code
note
refund_percent
status
responded_at
created_at
```

Status:

```text
PENDING
ACCEPTED
REJECTED
AUTO_APPROVED
```

Một Order có tối đa một Cancellation Request active/final record theo policy.

---

# 18. Execution trong Order Service

Execution là **module**, không phải microservice độc lập.

```text
ORDER
  │
  └── EXECUTION
        ├── DIGITAL
        ├── ONSITE
        ├── APPOINTMENT
        ├── HOURLY
        ├── PROJECT
        └── DELIVERY
```

## 18.1. EXECUTION

```text
EXECUTION
------------------------------
id                  PK
order_id            UNIQUE
execution_type
status
started_at
delivered_at
completed_at
created_at
updated_at
```

## 18.2. DIGITAL_EXECUTION

```text
DIGITAL_EXECUTION
------------------------------
execution_id        PK
requirement_submitted_at
deadline_at
revision_limit
revisions_used
```

## 18.3. ONSITE_EXECUTION

```text
ONSITE_EXECUTION
------------------------------
execution_id        PK
address_snapshot
scheduled_start
scheduled_end
arrived_at
checkin_code_hash
service_completed_at
booking_slot_id
```

`booking_slot_id` là logical reference tới Catalog.

## 18.4. APPOINTMENT_EXECUTION – PLANNED

```text
APPOINTMENT_EXECUTION
------------------------------
execution_id        PK
scheduled_start
scheduled_end
location_snapshot
attendance_status
```

## 18.5. HOURLY_EXECUTION – PLANNED

```text
HOURLY_EXECUTION
------------------------------
execution_id        PK
planned_minutes
actual_minutes
started_at
ended_at
```

## 18.6. PROJECT_EXECUTION – PLANNED

```text
PROJECT_EXECUTION
------------------------------
execution_id        PK
milestone_count
current_milestone
```

Milestone chi tiết có thể bổ sung:

```text
PROJECT_MILESTONE
```

khi Project Workflow được triển khai.

## 18.7. DELIVERY_EXECUTION

```text
DELIVERY_EXECUTION
------------------------------
execution_id        PK
logistics_delivery_id
pickup_snapshot
destination_snapshot
```

`logistics_delivery_id` là logical reference tới Logistic Service.

---

# 19. Digital Delivery

Luồng cơ bản:

```text
PENDING_PAYMENT
      ↓
CONFIRMED
      ↓
IN_PROGRESS
      ↓
DELIVERED
      ├── ACCEPT
      │     ↓
      │  COMPLETED
      │
      └── REVISION
             ↓
         IN_PROGRESS
```

## 19.1. DELIVERY_PACKAGE

Tên này được dùng thay cho `DELIVERY_PACKAGE` để tránh nhầm với `SERVICE_PACKAGE`.

```text
DELIVERY_PACKAGE
------------------------------
id                  PK
execution_id        FK → EXECUTION
version_no
message
status
delivered_at
created_at
```

Status:

```text
SUBMITTED
ACCEPTED
REVISION_REQUESTED
REJECTED
```

## 19.2. DELIVERY_FILE

```text
DELIVERY_FILE
------------------------------
id                  PK
submission_id       FK → DELIVERY_PACKAGE
file_url
file_name
mime_type
size_bytes
file_hash
created_at
```

## 19.3. REVISION_REQUEST

```text
REVISION_REQUEST
------------------------------
id                  PK
submission_id       FK → DELIVERY_PACKAGE
requested_by
reason
created_at
status
```

`SERVICE_PACKAGE.revision_limit` là giới hạn.

`REVISION_REQUEST` là lịch sử thực tế.

Hai khái niệm không trùng nhau.

---

# 20. WORK_EVIDENCE

```text
WORK_EVIDENCE
------------------------------
id                  PK
execution_id        FK → EXECUTION
phase
uploaded_by
file_url
file_hash
latitude
longitude
captured_at
created_at
```

`phase`:

```text
BEFORE
DURING
AFTER
ISSUE
```

### Mục đích

Chứng minh quá trình thực hiện công việc.

Không phải Delivery Proof.

---

# 21. Logistic Service

Logistics là Service riêng, nhưng chỉ dành cho workflow cần di chuyển vật lý.

WorkGo **không xây Grab đầy đủ**.

Không cần:

```text
Advanced route optimization
Driver marketplace phức tạp
Dynamic dispatching
Traffic prediction
Full navigation
```

Chỉ cần:

```text
Pickup
→ Move
→ Destination
→ Proof
```

## 21.1. LOGISTICS_DELIVERY

Đổi tên từ `DELIVERY` thành `LOGISTICS_DELIVERY` để tránh nhầm với Delivery Submission trong Order.

```text
LOGISTICS_DELIVERY
------------------------------
id                  PK
order_id
execution_id
provider_id
pickup_address
destination_address
status
current_latitude
current_longitude
estimated_arrival_at
started_at
completed_at
created_at
updated_at
```

Status:

```text
CREATED
ASSIGNED
EN_ROUTE
ARRIVED_PICKUP
PICKED_UP
EN_ROUTE_DESTINATION
ARRIVED
COMPLETED
CANCELLED
```

## 21.2. LOCATION_UPDATE

```text
LOCATION_UPDATE
------------------------------
id                  PK
delivery_id         FK → LOGISTICS_DELIVERY
latitude
longitude
captured_at
```

Chỉ lưu location khi cần.

Không bắt buộc GPS realtime ở phiên bản đầu.

## 21.3. DELIVERY_PROOF

```text
DELIVERY_PROOF
------------------------------
id                  PK
delivery_id         FK → LOGISTICS_DELIVERY
file_url
file_hash
note
created_at
```

### Phân biệt

```text
WORK_EVIDENCE
= bằng chứng Provider đã thực hiện công việc.

DELIVERY_PROOF
= bằng chứng hàng/tài liệu đã được giao.
```

Hai entity không trùng nhau.

---

# 22. Payment Service

Payment là business capability riêng vì liên quan:

```text
Money
Gateway
Audit
Idempotency
Refund
Holding
Reconciliation
```

Order không truy cập trực tiếp database Payment.

## 22.1. PAYMENT

```text
PAYMENT
------------------------------
id                  PK
order_id
payer_id
purpose
amount
currency
gateway
payment_method
gateway_txn_id
idempotency_key     UNIQUE
status
failure_code
failure_message
raw_response
paid_at
expires_at
created_at
updated_at
```

`purpose`:

```text
FULL
DEPOSIT
BALANCE
EXTRA
```

Status:

```text
INITIATED
PENDING
SUCCEEDED
FAILED
EXPIRED
CANCELLED
```

Không lưu:

```text
card number
CVV
```

## 22.2. CASH_PAYMENT_CONFIRMATION

Dùng cho Order có `PAYMENT.payment_method = CASH`. Vì WorkGo không trực tiếp giữ tiền mặt, hệ thống phải ghi nhận việc hai bên xác nhận giao nhận tiền.

```text
CASH_PAYMENT_CONFIRMATION
------------------------------
id                  PK
payment_id          FK → PAYMENT
client_confirmed_at
provider_confirmed_at
client_confirmed_by
provider_confirmed_by
status
note
created_at
updated_at
```

Status:

```text
PENDING
CLIENT_CONFIRMED
PROVIDER_CONFIRMED
CONFIRMED
DISPUTED
CANCELLED
```

Chỉ khi Client và Provider đều xác nhận thì khoản tiền mặt mới được coi là `CONFIRMED`. Nếu một bên phủ nhận hoặc phát sinh tranh chấp, không tự động coi là đã thanh toán; chuyển sang quy trình Dispute của Trust Service.

### Quy tắc

```text
ONLINE
→ Payment Gateway
→ ESCROW HOLDING
→ Release / Refund

CASH
→ Client trả trực tiếp Provider
→ Client xác nhận
→ Provider xác nhận
→ CASH PAYMENT CONFIRMED
→ Order có thể hoàn tất
```

## 22.2. ESCROW_ACCOUNT

WorkGo dùng thuật ngữ **holding / escrow-like** ở mức kiến trúc ứng dụng.

Không mặc định tuyên bố đây là legal escrow.

```text
ESCROW_ACCOUNT
------------------------------
id                  PK
order_id            UNIQUE
payment_id
held_amount
released_amount
refunded_amount
currency
status
held_at
auto_release_at
released_at
version
```

Status:

```text
PENDING
HOLDING
RELEASED
REFUNDED
PARTIALLY_REFUNDED
FROZEN
```

## 22.3. ESCROW_TRANSACTION

```text
ESCROW_TRANSACTION
------------------------------
id                  PK
escrow_account_id   FK
txn_type
amount
balance_after
triggered_by
actor_id
reason_code
saga_id
created_at
```

Type:

```text
HOLD
RELEASE
REFUND
PARTIAL_REFUND
FEE
FREEZE
UNFREEZE
```

Nên coi đây là append-only audit log.

## 22.4. REFUND

```text
REFUND
------------------------------
id                  PK
order_id
payment_id          FK → PAYMENT
escrow_account_id   FK → ESCROW_ACCOUNT
amount
reason_code
initiated_by
status
gateway_ref
processed_at
created_at
```

Status:

```text
PENDING
PROCESSING
COMPLETED
FAILED
```

## 22.5. PROVIDER_PAYOUT_ACCOUNT

Dùng để lưu thông tin tài khoản mà Payment Service sử dụng khi giải ngân tiền cho Freelancer. Entity này thuộc Payment Service vì thông tin được sử dụng cho nghiệp vụ payout, không phải thông tin hồ sơ cá nhân chung của Provider.

```text
PROVIDER_PAYOUT_ACCOUNT
------------------------------
id                  PK
provider_id
account_type
bank_code
bank_name
account_number
account_holder_name
is_default
status
created_at
updated_at
```

`account_type` có thể mở rộng:

```text
BANK
WALLET
```

`status`:

```text
ACTIVE
INACTIVE
VERIFIED
```

Một Provider có thể có nhiều tài khoản nhận tiền nhưng chỉ nên có một tài khoản `is_default = true` tại một thời điểm. Không lưu số thẻ hoặc CVV. Các dữ liệu tài chính nhạy cảm cần được bảo vệ/mã hóa phù hợp.

## 22.6. PAYOUT

`PAYOUT` ghi nhận việc WorkGo giải ngân tiền từ Holding/Escrow-like cho Freelancer. `PAYMENT` và `PAYOUT` là hai nghiệp vụ khác nhau:

```text
PAYMENT
Client → WorkGo / Payment Gateway

PAYOUT
WorkGo → Freelancer
```

```text
PAYOUT
------------------------------
id                  PK
order_id
provider_id
payout_account_id  FK → PROVIDER_PAYOUT_ACCOUNT
escrow_account_id  FK → ESCROW_ACCOUNT
amount
currency
status
payout_method
gateway
gateway_payout_id
initiated_at
processed_at
failed_at
failure_code
failure_message
created_at
updated_at
```

Status:

```text
INITIATED
PROCESSING
COMPLETED
FAILED
CANCELLED
```

Luồng online đầy đủ:

```text
Client
  │
  │ PAYMENT
  ▼
Payment Gateway
  │
  ▼
ESCROW_ACCOUNT
  │
  │ Order COMPLETED / đủ điều kiện release
  ▼
PAYOUT
  │
  ▼
PROVIDER_PAYOUT_ACCOUNT
  │
  ▼
Bank / Wallet
```

`gateway_payout_id` dùng để đối soát với hệ thống thanh toán bên ngoài. Payout phải có cơ chế idempotency và không được tạo trùng khi xử lý event/retry.

### Quy tắc số tiền

Ví dụ Client thanh toán `500.000 VND`, WorkGo thu phí `25.000 VND`:

```text
PAYMENT       = 500.000 VND
ESCROW HOLD   = 500.000 VND
WORKGO FEE    =  25.000 VND
PAYOUT        = 475.000 VND
```

Phí nền tảng cần được xác định theo policy/order snapshot; không hard-code vào Payout.

---

# 23. Trust Service

Trust là bounded context riêng, tập trung vào Review, Report và Dispute.

Sở hữu:

```text
REVIEW
REPORT
DISPUTE
PROVIDER_VERIFICATION
```

Có thể mở rộng:

```text
TRUST_SCORE
REPUTATION_HISTORY
MODERATION_CASE
FRAUD_SIGNAL
```

khi hệ thống lớn hơn.

---

# 24. REVIEW

```text
REVIEW
------------------------------
id                  PK
order_id
reviewer_id
reviewee_id
direction
rating
comment
is_published
moderation_status
created_at
updated_at
```

`direction`:

```text
CLIENT_TO_PROVIDER
PROVIDER_TO_CLIENT
```

Mỗi Order tối đa một Review cho mỗi direction:

```text
UNIQUE(order_id, direction)
```

Review thuộc Trust Service.

**Không tạo REVIEW trong Order Service.**

Flow:

```text
ORDER COMPLETED
       ↓
order.completed
       ↓
trust-service
       ↓
Review Window
       ↓
REVIEW
       ↓
Reputation
```

## 24.1. Double-blind Review

Có thể hỗ trợ:

```text
Client review Provider
Provider review Client
```

Review chỉ được công khai theo policy khi:

```text
cả hai đã review
```

hoặc:

```text
review window hết hạn
```

---

# 25. REPORT

```text
REPORT
------------------------------
id                  PK
reporter_id
target_type
target_id
reason
description
status
created_at
resolved_at
```

`target_type` có thể là:

```text
USER
SERVICE
POST
MESSAGE
ORDER
REVIEW
```

`target_id` là logical reference.

---

# 26. DISPUTE

```text
DISPUTE
------------------------------
id                  PK
order_id
opened_by
reason
description
status
resolution
created_at
resolved_at
```

Status ví dụ:

```text
OPEN
UNDER_REVIEW
RESOLVED
REJECTED
CANCELLED
```

Trust không cập nhật trực tiếp database Order.

Nếu cần thay đổi Order:

```text
Trust
 ↓
decision/event
 ↓
Order Service
 ↓
Order state
```

---

# 28. Saga

Các nghiệp vụ liên service cần Saga.

## 28.1. Saga tạo Order – Service Listing

```text
Client
 ↓
Order Service
 ↓
Create ORDER(PENDING_PAYMENT)
 ↓
Create ORDER_SNAPSHOT
 ↓
OUTBOX
 ↓
Payment Service
 ↓
Create Payment
 ↓
Client pays
 ↓
Gateway callback
 ↓
PAYMENT_SUCCEEDED
 ↓
ESCROW HOLDING
 ↓
escrow.held
 ↓
Order Service
 ↓
CONFIRMED
```

## 28.2. On-site Order

```text
Create Order
      ↓
Hold Booking Slot
      ↓
Create Payment
      ↓
Client pays
      ↓
Escrow HOLDING
      ↓
Order CONFIRMED
      ↓
Confirm Booking Slot
```

Hold slot trước khi thu tiền giúp giảm khả năng thu tiền khi slot đã bị người khác lấy.

---

# 29. SAGA_INSTANCE

```text
SAGA_INSTANCE
------------------------------
id                  PK
saga_type
correlation_id
current_step
state
context
created_at
updated_at
```

Status:

```text
STARTED
COMPENSATING
COMPLETED
FAILED
```

`correlation_id` thường là Order ID nhưng không có FK xuyên service.

---

# 30. Saga Compensation

Nếu:

```text
Order created
+
Slot held
+
Payment failed
```

thì:

```text
Release Slot
+
Cancel Order
```

Nếu:

```text
Payment succeeded
+
Later step failed
```

thì tùy transaction:

```text
Refund
+
Release resource
+
Cancel Order
```

Mọi compensation phải **idempotent**.

---

# 31. Transactional Outbox

Mỗi Service có:

```text
OUTBOX_EVENT
------------------------------
id                  PK
aggregate_type
aggregate_id
event_type
payload
status
created_at
available_at
published_at
retry_count
last_error
```

Business transaction:

```text
BEGIN
    UPDATE business_data
    INSERT outbox_event
COMMIT
```

Worker:

```text
OUTBOX_EVENT
     ↓
RabbitMQ
```

Không dùng:

```text
DB COMMIT
   ↓
RabbitMQ publish
```

mà không có Outbox vì có thể xảy ra:

```text
DB success
RabbitMQ failure
→ data/event inconsistent
```

---

# 32. Event Catalogue

Các event chính:

```text
user.created
user.updated
user.suspended

service.created
service.updated
service.published

post.created
post.updated

application.created
application.withdrawn

proposal.created
proposal.accepted
proposal.rejected

order.created
order.confirmed
order.started
order.delivered
order.completed
order.cancelled

payment.created
payment.succeeded
payment.failed

escrow.held
escrow.released

refund.created
refund.completed

message.created
notification.created

delivery.created
delivery.status_changed
delivery.completed
delivery.proof_added

review.published
report.created
dispute.opened
dispute.resolved

provider.verification_updated
provider.suspended
provider.restricted
```

Event contract phải ổn định trước khi thêm consumer mới.

---

# 33. Idempotency

Mọi consumer phải chịu được duplicate event.

Ví dụ:

```text
escrow.held
escrow.held
```

không được tạo:

```text
CONFIRMED
CONFIRMED
```

Có thể dùng:

```text
processed_event
```

hoặc unique business key/idempotency key.

Các API tạo Payment bắt buộc có:

```text
idempotency_key
```

---

# 34. Order State Machine

```text
PENDING_PAYMENT
       ↓
CONFIRMED
       ↓
IN_PROGRESS
       ↓
DELIVERED
       ↓
COMPLETED
```

Có thể hủy:

```text
PENDING_PAYMENT → CANCELLED
CONFIRMED       → CANCELLED
IN_PROGRESS     → CANCELLED
```

Không dùng `workflow_code`.

Execution subtype quyết định chi tiết trạng thái thực hiện.

---

# 35. Post State Machine

Core state:

```text
OPEN
 ↓
PAUSED
 ↓
CLOSED
```

Có thể:

```text
OPEN → CANCELLED
OPEN → EXPIRED
PAUSED → OPEN
```

Proposal acceptance phải đảm bảo:

```text
PROPOSAL = ACCEPTED
POST      = CLOSED
```

trong cùng transaction của Post Service.

---

# 36. Proposal Rule

Một Post có thể có:

```text
N Applications
N Proposals
```

nhưng chỉ một Proposal được Client chấp nhận.

Flow:

```text
Application
    ↓
Proposal
    ↓
Client Accept
    ↓
Proposal ACCEPTED
+
Post CLOSED
    ↓
Create Order
```

---

# 37. Apply Rule

Provider chỉ Apply khi:

```text
Provider active
AND
Post = OPEN
AND
Provider != Post.client
AND
Provider chưa Apply Post này
```

Unique:

```text
(post_id, provider_id)
```

---

# 38. Auto Completion

Auto-completion policy phải được snapshot khi Order bắt đầu.

Ví dụ:

```text
DIGITAL   → 72h
ONSITE    → 24h
```

Không được phụ thuộc hoàn toàn vào config hiện tại vì config có thể thay đổi sau khi Order đã tạo.

---

# 39. Booking Slot

Khi:

```text
slot.status = HELD
```

bắt buộc:

```text
hold_expires_at != NULL
```

Worker định kỳ:

```text
every 1 minute
      ↓
find expired HELD slots
      ↓
AVAILABLE
```

Đây là safety net độc lập với RabbitMQ.

---

# 40. Workflow Matrix

| Execution | Location | Time | Evidence | Revision | Logistics |
|---|---|---|---|---|---|
| DIGITAL | Không | Deadline | File | Có | Không |
| ONSITE | Có | Appointment | Photo/OTP | Tuỳ | Có thể |
| APPOINTMENT | Có/Tuỳ | Appointment | Attendance | Tuỳ | Có thể |
| HOURLY | Có/Tuỳ | Duration | Time record | Không | Tuỳ |
| PROJECT | Có/Tuỳ | Milestone | Deliverable | Có | Không |
| DELIVERY | Pickup + Destination | Tracking | Proof | Không | Có |

---

# 41. Communication Rules

Message phục vụ:

```text
Client ↔ Provider
```

theo context:

```text
POST
SERVICE
ORDER
GENERAL
```

Không có:

```text
Public chat
Follower system
Like message
Share message
Public group chat
```

Conversation có thể chuyển sang:

```text
READ_ONLY
```

sau Order hoàn thành tùy policy.

Mục tiêu là lưu lịch sử trao đổi phục vụ giao dịch.

---

# 42. Notification Flow

Ví dụ Provider Apply:

```text
post-service
    ↓
application.created
    ↓
RabbitMQ
    ↓
communication-service
    ↓
NOTIFICATION
    ↓
Client thấy thông báo
```

Ví dụ Order Completed:

```text
order-service
    ↓
order.completed
    ↓
communication-service
    ↓
NOTIFICATION
```

Notification không quyết định business state.

---

# 43. Profile và Read Model

Provider Profile lấy thông tin nghề nghiệp từ nhiều nguồn.

```text
Identity
   ↓
Provider Profile

Catalog
   ↓
Services
Packages

Order
   ↓
Completed Orders

Trust
   ↓
Reviews
Reputation
```

Có thể xây Provider Summary:

```text
Provider Summary
├── rating_avg
├── rating_count
├── completed_orders
├── active_services
├── verification_status
└── response statistics
```

Các trường tổng hợp không phải source of truth.

---

# 44. Category vs Skill

Hai khái niệm khác nhau.

```text
CATEGORY
= Marketplace phân loại dịch vụ.

SKILL
= Năng lực của Provider.
```

Ví dụ:

```text
Category:
Programming

Skills:
Java
Spring Boot
React
Docker
MySQL
```

Không gộp hai entity này.

---

# 45. Search

## Phase đầu

Không cần Search Service riêng.

Dùng PostgreSQL:

```text
Full Text Search
+
category
+
execution_type
+
price
+
district
+
rating
+
availability
```

## Phase sau – PLANNED

```text
search-service
      ↓
OpenSearch / Elasticsearch
```

Search không sở hữu dữ liệu gốc.

Nó xây index từ event:

```text
service.created
service.updated
provider.updated
post.created
```

---

# 46. File Storage

Không lưu file binary lớn trực tiếp trong PostgreSQL.

Database chỉ lưu:

```text
file_url
file_name
mime_type
size_bytes
file_hash
```

File thực tế nằm trong:

```text
Object Storage
```

Dùng cho:

```text
Service Media
Portfolio
Post Attachment
Delivery File
Work Evidence
Message Attachment
Delivery Proof
Verification Document
```

File Verification nhạy cảm phải được bảo vệ bằng access control riêng.

---

# 47. Security

## 47.1. Authentication

```text
JWT Access Token
+
Refresh Token
```

## 47.2. Authorization

Có hai tầng:

```text
Role
+
Ownership
```

Ví dụ Provider chỉ được cập nhật Order nếu:

```text
order.provider_id == current_user_id
```

Không chỉ kiểm tra:

```text
role == PROVIDER
```

## 47.3. Message Security

Chỉ Participant mới được đọc Conversation.

## 47.4. File Security

Kiểm tra:

```text
MIME type
size
extension
access permission
```

## 47.5. Payment Security

Không lưu:

```text
Card number
CVV
```

Chỉ lưu gateway transaction/reference.

---

# 48. Reliability

Các Service cần:

```text
Timeout
Retry
Idempotency
Dead Letter Queue
Outbox
Correlation ID
```

Không retry vô hạn.

Ví dụ:

```text
Consumer
   ↓
Failure
   ↓
Retry
   ↓
Retry
   ↓
DLQ
```

---

# 49. Observability

Mỗi Request/Event nên có:

```text
correlation_id
```

Log:

```text
timestamp
service
level
correlation_id
user_id
order_id
event_type
message
```

Mục tiêu:

```text
Client Request
      ↓
API Gateway
      ↓
Order
      ↓
Payment
      ↓
RabbitMQ
      ↓
Trust / Communication
```

có thể trace được.

---

# 50. API Gateway

Gateway chịu trách nhiệm:

```text
JWT validation
Routing
CORS
Rate limiting
Correlation ID
API aggregation ở mức cần thiết
```

Gateway **không chứa business logic**.

---

# 51. API Surface

## Identity

```http
POST /auth/register
POST /auth/login
POST /auth/refresh

GET  /me
PUT  /me

POST /me/provider
GET  /providers/{id}

POST /provider-verifications
GET  /provider-verifications/{id}

GET  /me/addresses
POST /me/addresses
PUT  /me/addresses/{id}
DELETE /me/addresses/{id}
```

## Catalog

```http
GET  /categories

GET  /services
POST /services
GET  /services/{id}
PUT  /services/{id}

POST /services/{id}/media

GET  /services/{id}/packages
POST /services/{id}/packages
PUT  /packages/{id}

POST /services/{id}/availability
GET  /services/{id}/slots

POST /slots/{id}/hold
POST /slots/{id}/confirm
POST /slots/{id}/release
```

## Post

```http
POST /posts
GET  /posts
GET  /posts/{id}
PUT  /posts/{id}

POST /posts/{id}/applications
GET  /posts/{id}/applications

POST /applications/{id}/proposal

POST /proposals/{id}/accept
POST /proposals/{id}/reject
```

## Communication

```http
GET  /conversations
POST /conversations

GET  /conversations/{id}/messages
POST /conversations/{id}/messages

POST /messages/{id}/read

GET  /notifications
POST /notifications/{id}/read
POST /notifications/read-all
```

## Order

```http
POST /orders
GET  /orders
GET  /orders/{id}

POST /orders/{id}/requirements
POST /orders/{id}/submissions
POST /orders/{id}/revisions

POST /orders/{id}/checkin
POST /orders/{id}/evidence

POST /orders/{id}/accept
POST /orders/{id}/complete
POST /orders/{id}/cancel
```

Review không thuộc Order API.

## Payment

```http
POST /payments
GET  /payments/{id}

POST /payments/gateway/callback

GET  /escrows/{id}
POST /escrows/{id}/release

POST /payments/{id}/refund
```

## Logistic

```http
POST /deliveries
GET  /deliveries/{id}

POST /deliveries/{id}/assign
POST /deliveries/{id}/start
POST /deliveries/{id}/location
POST /deliveries/{id}/arrive
POST /deliveries/{id}/complete
POST /deliveries/{id}/proof
```

## Trust

```http
GET  /providers/{id}/reviews
POST /reviews

POST /reports
GET  /reports/{id}

POST /disputes
GET  /disputes/{id}
```

---

# 52. Cross-Service Logical References

| Source | Field | Target | Cách liên kết |
|---|---|---|---|
| Catalog | provider_id | Identity.USER.id | Logical |
| Catalog | category_id | Catalog.CATEGORY.id | Physical |
| Post | client_id | Identity.USER.id | Logical |
| Post | category_id | Catalog.CATEGORY.id | Logical |
| Application | provider_id | Identity.USER.id | Logical |
| Order | client_id | Identity.USER.id | Logical |
| Order | provider_id | Identity.USER.id | Logical |
| Order | service_id | Catalog.SERVICE.id | Logical |
| Order | package_id | Catalog.SERVICE_PACKAGE.id | Logical |
| Order | source_id | Service/Proposal | Logical |
| Order | booking_slot_id | Catalog.BOOKING_SLOT.id | Logical |
| Payment | order_id | Order.ORDER.id | Logical |
| Payment | payer_id | Identity.USER.id | Logical |
| Logistics | order_id | Order.ORDER.id | Logical |
| Logistics | provider_id | Identity.USER.id | Logical |
| Delivery Execution | logistics_delivery_id | Logistics.LOGISTICS_DELIVERY.id | Logical |
| Review | order_id | Order.ORDER.id | Logical |
| Review | reviewer_id | Identity.USER.id | Logical |
| Review | reviewee_id | Identity.USER.id | Logical |
| Verification | provider_id | Identity.USER.id | Logical |

Không có FK vật lý giữa các Database.

---

# 53. Entity Ownership Rules

| Entity | Owner |
|---|---|
| USER | Identity |
| USER_ROLE | Identity |
| PROVIDER_PROFILE | Identity |
| ADDRESS | Identity |
| PROVIDER_SKILL | Identity |
| PORTFOLIO_ITEM | Identity |
| CATEGORY | Catalog |
| SERVICE | Catalog |
| SERVICE_MEDIA | Catalog |
| SERVICE_PACKAGE | Catalog |
| SERVICE_ADDON | Catalog |
| AVAILABILITY_RULE | Catalog |
| BOOKING_SLOT | Catalog |
| POST | Post |
| POST_ATTACHMENT | Post |
| APPLICATION | Post |
| PROPOSAL | Post |
| CONVERSATION | Communication |
| CONVERSATION_PARTICIPANT | Communication |
| MESSAGE | Communication |
| MEDIA_ATTACHMENT | Communication |
| NOTIFICATION | Communication |
| ORDER | Order |
| ORDER_SNAPSHOT | Order |
| ORDER_ITEM | Order |
| ORDER_STATUS_HISTORY | Order |
| CANCELLATION_REQUEST | Order |
| EXECUTION | Order |
| Execution subtypes | Order |
| DELIVERY_PACKAGE | Order |
| DELIVERY_FILE | Order |
| REVISION_REQUEST | Order |
| WORK_EVIDENCE | Order |
| SAGA_INSTANCE | Order |
| PAYMENT | Payment |
| ESCROW_ACCOUNT | Payment |
| ESCROW_TRANSACTION | Payment |
| REFUND | Payment |
| LOGISTICS_DELIVERY | Logistics |
| LOCATION_UPDATE | Logistics |
| DELIVERY_PROOF | Logistics |
| REVIEW | Trust |
| REPORT | Trust |
| DISPUTE | Trust |
| PROVIDER_VERIFICATION | Identity |
| OUTBOX_EVENT | Mỗi Service |

---

# 54. Những entity KHÔNG được duplicate

Các quyết định cuối cùng:

## Review

```text
REVIEW → Trust Service
```

Không tạo Review trong Order.

## Provider Verification

```text
PROVIDER_VERIFICATION → Identity
PROVIDER_PROFILE.verification_status → Identity
```

Không duplicate toàn bộ verification data sang Service khác.

## Execution

```text
EXECUTION → Order module
```

Không tạo Execution Service.

## Delivery

```text
DELIVERY_EXECUTION → Order
LOGISTICS_DELIVERY → Logistics
```

Hai entity khác trách nhiệm.

## Delivery Submission

```text
SERVICE_PACKAGE → Catalog
DELIVERY_PACKAGE → Order
```

Một là thứ Client mua, một là kết quả Provider bàn giao.

## Work Evidence / Delivery Proof

```text
WORK_EVIDENCE → bằng chứng thực hiện công việc
DELIVERY_PROOF → bằng chứng giao nhận
```

Không gộp.

## Service / Post

```text
SERVICE → Provider cung cấp
POST     → Client yêu cầu
```

Không gộp.

## Application / Proposal

```text
APPLICATION → Provider ứng tuyển
PROPOSAL    → đề xuất giao dịch cụ thể
```

Không gộp.

---

# 55. Những điểm đã loại bỏ khỏi thiết kế cũ

## 55.1. WORKFLOW_TYPE

Không còn entity `WORKFLOW_TYPE` riêng.

Thay bằng:

```text
execution_type
```

trong:

```text
SERVICE
ORDER
EXECUTION
```

Lý do: tránh hai khái niệm cùng mô tả cách thực hiện.

Nếu sau này có policy phức tạp, dùng bảng/config:

```text
EXECUTION_POLICY
```

hoặc cấu hình application thay vì tạo một workflow entity chỉ để phân loại.

## 55.2. ORDER.workflow_code

Đã loại bỏ.

Dùng:

```text
ORDER.execution_type
```

## 55.3. REVIEW trong Order

Đã loại bỏ.

Review thuộc Trust.

## 55.4. PROVIDER_VERIFICATION chi tiết trong Identity

Đã chuyển ownership sang Identity Service cùng với Provider Profile.

Identity quản lý dữ liệu verification; không duplicate sang Service khác.

## 55.5. Execution Service

Không tồn tại.

Execution là module của Order.

---

# 56. End-to-End Example – Digital Service

```text
Provider
   ↓
Create Service
   ↓
Create Package
   ↓
Catalog
   ↓
Client searches
   ↓
Client views Package
   ↓
Contact / Message
   ↓
Buy
   ↓
Order PENDING_PAYMENT
   ↓
Payment
   ↓
Escrow HOLDING
   ↓
Order CONFIRMED
   ↓
Execution DIGITAL
   ↓
Provider works
   ↓
DELIVERY_PACKAGE
   ↓
Client accepts
   ↓
Order COMPLETED
   ↓
Escrow RELEASE
   ↓
Trust Review
```

---

# 57. End-to-End Example – Post Marketplace

```text
Client
   ↓
Create POST
   ↓
POST OPEN
   ↓
Provider views Post
   ↓
APPLICATION
   ↓
Notification
   ↓
Message
   ↓
PROPOSAL
   ↓
Client ACCEPT
   ↓
Post CLOSED
   ↓
ORDER
   ↓
PAYMENT
   ↓
EXECUTION
   ↓
COMPLETED
   ↓
REVIEW
```

---

# 58. End-to-End Example – On-site

Ví dụ sửa điện:

```text
Client
   ↓
Service: Electrical Repair
   ↓
Select Package
   ↓
Select Booking Slot
   ↓
Create Order
   ↓
Hold Slot
   ↓
Payment
   ↓
Escrow HOLDING
   ↓
Confirm Slot
   ↓
Provider notified
   ↓
EN_ROUTE
   ↓
ARRIVED
   ↓
OTP CHECK-IN
   ↓
IN_SERVICE
   ↓
BEFORE / DURING / AFTER Evidence
   ↓
DELIVERED
   ↓
Client ACCEPT
   ↓
COMPLETED
   ↓
Escrow RELEASE
   ↓
Review
```

---

# 59. End-to-End Example – Delivery

```text
Client
   ↓
Create / Buy Delivery Service
   ↓
ORDER
   ↓
PAYMENT
   ↓
Escrow HOLDING
   ↓
LOGISTICS_DELIVERY CREATED
   ↓
Provider ASSIGNED
   ↓
PICKUP
   ↓
EN_ROUTE
   ↓
ARRIVED
   ↓
DELIVERY_PROOF
   ↓
COMPLETED
   ↓
Order COMPLETED
```

Không yêu cầu hệ thống điều hướng kiểu Grab đầy đủ.

---

# 60. Data Consistency

## Trong một Service

Ưu tiên:

```text
Strong Consistency
```

## Giữa các Service

Chấp nhận:

```text
Eventual Consistency
```

Ví dụ:

```text
Trust
 ↓
review.published
 ↓
RabbitMQ
 ↓
Catalog
 ↓
rating_avg updated
```

Có thể có độ trễ ngắn.

Không cố tạo Distributed Transaction cho mọi thao tác.

---

# 61. Deployment Architecture

Có thể triển khai bằng:

```text
Docker Compose
```

hoặc sau này:

```text
Kubernetes
```

Deployment mục tiêu:

```text
api-gateway

identity-service
catalog-service
post-service
communication-service
order-service
payment-service
logistic-service
trust-service

PostgreSQL
RabbitMQ
Object Storage

Redis                 PLANNED
Search Engine         PLANNED
```

Mỗi Service có thể scale độc lập.

---

# 62. Recommended Project Structure

Mỗi Service:

```text
service/
├── controller/
├── application/
├── domain/
├── repository/
├── infrastructure/
├── event/
├── security/
└── config/
```

Order:

```text
order-service/
├── order/
├── execution/
│   ├── digital/
│   ├── onsite/
│   ├── appointment/
│   ├── hourly/
│   ├── project/
│   └── delivery/
├── cancellation/
├── saga/
├── event/
└── shared/
```

Trust:

```text
trust-service/
├── review/
├── report/
├── dispute/
├── verification/
├── reputation/
└── event/
```

---

# 63. Roadmap triển khai

Roadmap chỉ là thứ tự triển khai.

Nó **không làm thay đổi Target Architecture**.

## Phase 1 – Core

```text
Identity
Catalog
Order
Payment
```

Workflow:

```text
DIGITAL
ONSITE
```

## Phase 2 – Marketplace

```text
Post
Application
Proposal
Communication
Notification
```

Workflow:

```text
POST
→ APPLY
→ PROPOSAL
→ ACCEPT
→ ORDER
```

## Phase 3 – Rich Execution

```text
Package
Add-on
Appointment
Hourly
Project
```

## Phase 4 – Logistics

```text
Logistics
Delivery
Location
Proof
```

## Phase 5 – Trust & Safety

```text
Review
Report
Dispute
Verification
Reputation
```

## Phase 6 – Scale

```text
Search Service
Redis
Realtime
Analytics
```

---

# 64. Các phần PLANNED nhưng không bị loại

| Thành phần | Trạng thái |
|---|---|
| Provider Skill | PLANNED |
| Portfolio | PLANNED |
| Package Features | TARGET / JSON |
| Appointment Execution | PLANNED |
| Hourly Execution | PLANNED |
| Project Execution | PLANNED |
| Project Milestone | PLANNED |
| Delivery Execution | TARGET |
| Logistics | PLANNED |
| Trust Service | TARGET |
| Search Service | PLANNED |
| Redis | PLANNED |
| Realtime Tracking | PLANNED |
| Payout | IMPLEMENTED IN ARCHITECTURE |
| Double-entry Ledger | PLANNED |
| Invoice | PLANNED |
| Coupon | PLANNED |
| Recurring Order | PLANNED |
| Advanced Analytics | PLANNED |

`PLANNED` nghĩa là chưa cần triển khai ngay, không phải loại khỏi kiến trúc.

---

# 65. Các thành phần không thuộc WorkGo Core

Không nằm trong Core:

```text
Facebook-like Feed
Like
Comment
Share
Repost
Public Follower System
Viral Content Algorithm
Full Grab Navigation
Advanced Driver Dispatch
Full Warehouse Management
Full Accounting System
```

Nếu nhu cầu sản phẩm thay đổi trong tương lai, chúng có thể trở thành sản phẩm mở rộng riêng.

---

# 66. Nguyên tắc mở rộng Execution

Khi thêm Execution Type mới:

**Không tạo Order Service mới.**

Không làm:

```text
digital-order-service
onsite-order-service
delivery-order-service
project-order-service
```

Mà:

```text
ORDER
  ↓
EXECUTION
  ├── DIGITAL
  ├── ONSITE
  ├── APPOINTMENT
  ├── HOURLY
  ├── PROJECT
  ├── DELIVERY
  └── NEW_TYPE
```

Chỉ cần thêm:

```text
Execution subtype
+
Handler
+
Business rules
```

và giữ nguyên:

```text
Order
Payment
Cancellation
Communication
Trust
```

khi nghiệp vụ cho phép.

---

# 67. Nguyên tắc mở rộng Order Source

Hiện tại:

```text
SERVICE
PROPOSAL
```

Sau này có thể:

```text
DIRECT_INVITATION
REPEAT_ORDER
BOOKING
```

Tất cả vẫn hội tụ:

```text
Order Source
     ↓
ORDER
     ↓
EXECUTION
```

Không tạo nhiều loại Order Service.

---

# 68. Nguyên tắc mở rộng Communication

Communication chỉ sở hữu:

```text
Conversation
Message
Notification
```

Không sở hữu:

```text
Post state
Proposal state
Order state
Payment state
Delivery state
```

Nó nhận event và hiển thị/tạo tương tác.

---

# 69. Nguyên tắc mở rộng Trust

Trust không cập nhật trực tiếp database của service khác.

Ví dụ:

```text
Order Completed
       ↓
event
       ↓
Trust
       ↓
Reputation
```

Nếu Provider vi phạm:

```text
Trust
  ↓
provider.restricted
  ↓
Identity
  ↓
Provider status
  ↓
Catalog
  ↓
pause/restrict Service
```

---

# 70. Các nguyên tắc thiết kế quan trọng nhất

## Decision 1

**WorkGo không có Like / Comment / Share trong Marketplace.**

## Decision 2

**WorkGo có Message + Notification.**

## Decision 3

**Apply không tạo Order.**

```text
Apply
 ↓
Proposal
 ↓
Accept
 ↓
Order
```

## Decision 4

**Service Listing và Post là hai nguồn tạo Order.**

## Decision 5

**Execution nằm trong Order Service.**

## Decision 6

**Payment là microservice riêng.**

## Decision 7

**Logistics là microservice riêng cho physical movement.**

## Decision 8

**Trust là bounded context riêng.**

## Decision 9

**Review thuộc Trust Service.**

## Decision 10

**Provider Verification chi tiết thuộc Identity Service cùng với Provider Profile.**

## Decision 11

**Dùng `execution_type`, không dùng `workflow_code`.**

## Decision 12

**Database per Service, không có FK xuyên database.**

## Decision 13

**Order Snapshot bảo vệ lịch sử giao dịch.**

## Decision 14

**Transactional Outbox được dùng cho event reliability.**

## Decision 15

**Consumer phải idempotent.**

## Decision 16

**Search ban đầu có thể dùng PostgreSQL.**

## Decision 17

**Delivery chỉ cần pickup → destination → proof, không xây Grab đầy đủ.**

---

# 71. Final Bounded Context Map

```text
IDENTITY
Who are you?
    │
    ▼
CATALOG
What can you buy?
    │
    ▼
POST
What does someone need?
    │
    ▼
COMMUNICATION
How do the parties communicate?
    │
    ▼
ORDER
What transaction was agreed?
    │
    ▼
EXECUTION
How is it performed?
    │
    ├──────────────► PAYMENT
    │                 How is money handled?
    │
    └──────────────► LOGISTICS
                      How does physical movement happen?

After transaction:

ORDER COMPLETED
       │
       ▼
TRUST
Can the parties trust each other?
```

---

# 72. Final Business Model

WorkGo được định nghĩa bằng chuỗi:

```text
DISCOVER
   ↓
MATCH
   ↓
COMMUNICATE
   ↓
PROPOSE
   ↓
TRANSACT
   ↓
EXECUTE
   ↓
COMPLETE
   ↓
REVIEW
   ↓
TRUST
```

Hai hướng vào Marketplace:

```text
Provider → SERVICE → BUY
Client   → POST     → APPLY
```

Hội tụ:

```text
                         ORDER
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
           PAYMENT      EXECUTION   COMMUNICATION
                           │
             ┌─────────────┼──────────────┐
             ▼             ▼              ▼
          DIGITAL        ONSITE       DELIVERY...
                           │
                           ▼
                       COMPLETION
                           │
                           ▼
                         TRUST
```

---

# 73. Final Architecture Summary

Target Architecture cuối cùng của WorkGo gồm **8 microservices nghiệp vụ**:

```text
1. Identity Service
2. Catalog Service
3. Post Service
4. Communication Service
5. Order Service
6. Payment Service
7. Logistic Service
8. Trust Service
```

Infrastructure:

```text
API Gateway
RabbitMQ
PostgreSQL
Object Storage
Redis                PLANNED
Search Engine        PLANNED
```

Trong đó:

```text
Order
 └── Execution
      ├── Digital
      ├── Onsite
      ├── Appointment
      ├── Hourly
      ├── Project
      └── Delivery
```

Không có:

```text
Execution Service
Review trong Order
Workflow Type Service
```

Final ownership:

```text
Identity    → identity data
Catalog     → service catalog
Post        → demand/application/proposal
Communication → communication
Order       → transaction/execution
Payment     → money
Logistic    → physical delivery
Trust       → review/safety/reputation
```

Đây là **kiến trúc mục tiêu cuối cùng**.

Việc triển khai có thể thực hiện theo từng Phase, nhưng khi bổ sung chức năng mới, không cần thay đổi mô hình Order và các bounded context cốt lõi.
