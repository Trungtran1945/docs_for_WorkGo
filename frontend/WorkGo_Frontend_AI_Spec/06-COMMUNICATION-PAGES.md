# WorkGo Frontend — Communication & Notification UX

## 1. Communication philosophy

Communication của WorkGo là communication phục vụ công việc.

Không biến app thành social network.

## 2. Inbox

Desktop:
- conversation list;
- active conversation;
- contextual panel nếu cần.

Mobile:
- conversation list;
- click → conversation screen;
- back → list.

## 3. Conversation list

Mỗi row:
- avatar;
- name/title;
- last message;
- timestamp;
- unread count;
- contextual indicator nếu có.

Sort:
- most recent activity.

## 4. Conversation types

Được tài liệu hóa:
- direct message;
- group chat;
- support ticket.

Context có một số khác biệt giữa architecture và SQL. UI phải dựa trên enum/API thực tế.

## 5. Message types

- text;
- image;
- file;
- system event;
- proposal.

### Message bubble
Không dùng bubble quá lớn.

System event nên khác visual với user message.

Proposal message nên có structured card:
- amount;
- estimated days;
- status;
- action.

## 6. Composer

Có:
- text;
- attach;
- send.

States:
- uploading;
- sending;
- failed;
- retry.

Không tự động gửi khi người dùng chọn file nếu chưa có requirement.

## 7. Message attachments

Hiển thị:
- filename;
- type;
- size;
- preview nếu supported;
- download/open.

## 8. Read state

Unread:
- visual distinction;
- count;
- no excessive color.

## 9. Notifications

Notification center:
- all;
- unread;
- category filter nếu backend hỗ trợ.

Notification item:
- icon/type;
- title;
- short content;
- time;
- read state;
- click target.

Notification types có thể liên quan:
- application;
- proposal;
- order;
- payment;
- delivery;
- review;
- dispute;
- message.

Không hard-code những loại backend chưa xác nhận.

## 10. Notification navigation

Click notification phải đưa tới resource liên quan nếu reference tồn tại.

Ví dụ:
- proposal → proposal/order;
- message → conversation;
- payment → order/payment;
- dispute → dispute.

## 11. Support ticket

Nếu SUPPORT_TICKET được backend hỗ trợ:
- subject;
- conversation;
- status;
- attachments;
- response history.

## 12. Communication safety

Không render HTML message trực tiếp nếu không sanitize.

File URL phải qua security policy của backend.

## 13. Empty states

Inbox empty:
"Chưa có cuộc trò chuyện."

Notification empty:
"Bạn chưa có thông báo mới."
