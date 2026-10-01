# WorkGo Frontend — Order, Execution, Delivery & Payment Workflows

## 1. Order list

Filters:
- status;
- role;
- date;
- payment status.

Order item:
- order number;
- service;
- counterpart;
- amount;
- status;
- last update;
- CTA.

## 2. Order detail

### Header
- order number;
- status;
- created date;
- primary action.

### Summary
- service snapshot;
- provider/client;
- items;
- subtotal;
- platform fee;
- total;
- provider net if role permits.

### Timeline
Examples:
- order created;
- payment;
- confirmed;
- in progress;
- delivered;
- completed.

### Actions
Context-dependent:
- pay;
- accept;
- deliver;
- request revision;
- cancel;
- open dispute;
- complete;
- review.

Không hiển thị mọi button cùng lúc.

## 3. Payment

Payment screen:
- order summary;
- amount;
- method;
- payment status;
- confirmation;
- failure state.

Methods documented:
- credit card;
- PayPal;
- bank transfer;
- e-wallet;
- internal balance.

Cash payment chỉ triển khai nếu API/contract xác nhận.

Không lưu thông tin thẻ nhạy cảm trong frontend state/localStorage.

## 4. Escrow

Hiển thị theo quyền:
- amount held;
- released;
- refunded;
- current status;
- expected next action.

Không biến thông tin tài chính thành dashboard phức tạp.

## 5. Digital execution

### Requirements
Client gửi:
- requirements;
- deadline;
- references/files.

### Delivery
Provider:
- upload delivery;
- version;
- message;
- final flag.

Client:
- preview/download;
- accept;
- request revision.

### Revision
Hiển thị:
- reason;
- attachments;
- remaining revision allowance nếu có;
- requested time.

## 6. Onsite execution

Timeline:
1. Scheduled
2. Travel
3. Arrived
4. Check-in
5. Service
6. Completed

Hiển thị:
- scheduled time;
- address;
- booking slot;
- travel status;
- check-in;
- work evidence.

Location information phải được hiển thị cẩn trọng theo permission.

## 7. Booking slots

Provider:
- availability rules;
- slots;
- locked/booked/cancelled/completed.

Client:
- available slots;
- selected slot;
- booking state.

Slot card cần rõ:
- date;
- start/end;
- status.

## 8. Logistics

Delivery tracking:
- status;
- current location nếu available;
- ETA;
- timestamps;
- proof.

Desktop:
- map + detail panel nếu map data thực sự có.

Mobile:
- map có thể nằm trên;
- status/timeline bên dưới.

Không tạo fake live map nếu backend chưa cung cấp location.

## 9. Cancellation

Confirmation phải giải thích:
- order;
- reason;
- possible refund;
- consequences.

Nếu cần approval:
- show pending state.

## 10. Completion

Completion screen không chỉ hiện "Success".

Nên có:
- order completed;
- next actions;
- review;
- invoice/payment summary nếu có.

## 11. Error handling

Payment/order workflow phải xử lý:
- network failure;
- expired state;
- unauthorized;
- already completed;
- conflicting update;
- duplicate submission.

Disable submit khi đang xử lý.
