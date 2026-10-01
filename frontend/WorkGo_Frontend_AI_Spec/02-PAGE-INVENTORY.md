# WorkGo Frontend — Page Inventory & Information Architecture

## 1. Nguyên tắc

Đây là inventory UI dựa trên nghiệp vụ đã được tài liệu hóa.

Một số phần backend có thể tồn tại trước UI hoặc đang planned. AI agent không được giả định rằng mọi endpoint đều đã có.

## 2. Public pages

- Landing / Home
- Service marketplace
- Service detail
- Public post marketplace
- Post detail
- Provider public profile
- Search results
- Category results
- Login
- Register
- Email/phone verification
- Forgot/reset password
- Public legal/help pages nếu source yêu cầu

## 3. Client pages

- Client dashboard
- My profile
- Addresses
- My posts
- Create/edit post
- Post detail management
- Applications received
- Proposal review
- Orders
- Order detail
- Payment
- Escrow/payment status
- Delivery/execution tracking
- Reviews
- Notifications
- Conversations
- Settings

## 4. Provider pages

- Provider dashboard
- Public profile
- Provider profile edit
- Verification
- My services
- Create/edit service
- Service package management
- Add-ons
- Availability
- Booking slots
- Applications
- Proposals
- Orders
- Order detail
- Delivery
- Revision requests
- Work evidence
- Reviews
- Notifications
- Conversations
- Settings

## 5. Shared workflow pages

- Conversation
- Notifications
- Order timeline
- Delivery tracking
- Dispute
- Report
- Review submission

## 6. Admin pages

- Admin dashboard
- Users
- User detail
- Provider verification queue
- Verification detail
- Services moderation
- Posts moderation
- Reports
- Report detail
- Reviews moderation
- Disputes
- Dispute detail
- Platform/order/payment overview as supported by backend

## 7. Navigation model

### Public

Header:
- logo;
- Services;
- Posts;
- Search;
- login/register;
- optional language/help.

### Authenticated

Desktop:
- logo;
- contextual navigation/sidebar;
- search;
- notifications;
- messages;
- avatar/menu.

### Client primary navigation

Suggested:
- Overview
- Posts
- Orders
- Messages
- Notifications
- Profile

### Provider primary navigation

Suggested:
- Overview
- Services
- Applications
- Orders
- Messages
- Notifications
- Profile

Do not force every secondary feature into primary navigation.

## 8. URL principles

Routes should be human-readable and resource-oriented.

Examples:
- `/services`
- `/services/:id`
- `/providers/:id`
- `/posts`
- `/posts/:id`
- `/orders`
- `/orders/:id`
- `/messages`
- `/notifications`
- `/settings`

Role-specific routes may use:
- `/client/...`
- `/provider/...`
- `/admin/...`

Use the existing project routing conventions if already established.

## 9. Page priority

### P0 — required foundation
- Login/register
- Home
- Service marketplace
- Service detail
- Provider profile
- Post marketplace
- Post detail
- Dashboard
- Orders
- Messages
- Notifications

### P1 — core business workflows
- Create/edit service
- Create/edit post
- Applications
- Proposals
- Order detail
- Payment
- Delivery
- Reviews
- Verification

### P2 — operational/admin
- Reports
- Disputes
- Moderation
- Advanced availability
- advanced execution states

## 10. Page composition rule

Mỗi page nên có:

1. page shell;
2. page header;
3. primary content;
4. contextual actions;
5. secondary information;
6. states;
7. responsive variant.

Không xây page chỉ bằng một grid card.
