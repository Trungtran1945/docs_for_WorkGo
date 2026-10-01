# WorkGo Frontend — UX, Responsive, Accessibility & Visual Quality Rules

## 1. Desktop-first is not enough

Mỗi component phải được xem xét ở:
- 1440px;
- 1024px;
- 768px;
- 390px;
- 360px.

## 2. Mobile priorities

Mobile phải ưu tiên:
1. content;
2. primary action;
3. status;
4. navigation.

Secondary information có thể:
- collapse;
- move below;
- open drawer.

## 3. Touch targets

Interactive elements nên có vùng chạm đủ lớn.

Không đặt icon-only controls quá sát nhau.

## 4. Forms

Mobile:
- one-column;
- label rõ;
- error gần field;
- keyboard type phù hợp;
- sticky submit nếu form dài và action quan trọng.

## 5. Tables

Nếu table không thể đọc:
- chuyển card/list;
- hoặc cho horizontal scroll có visual cue.

Không scale font xuống quá nhỏ.

## 6. Search/filter

Desktop:
- filter sidebar.

Mobile:
- filter button;
- drawer;
- active filter chips.

## 7. Navigation

Desktop:
- sidebar/header.

Mobile:
- bottom nav cho primary areas;
- drawer cho secondary.

Không nhồi 10 item vào bottom navigation.

## 8. Accessibility

### Keyboard
- Tab order hợp lý;
- Enter/Space cho controls;
- Escape đóng dialog;
- focus return sau modal.

### Screen reader
- semantic headings;
- labels;
- landmarks;
- accessible names.

### Color
Không truyền status chỉ bằng màu.

### Motion
Tôn trọng `prefers-reduced-motion`.

## 9. Loading

Có 3 mức:
- shell loading;
- component loading;
- action loading.

Không khóa toàn trang nếu chỉ một button đang submit.

## 10. Error

Error phải:
- nói chuyện gì xảy ra;
- nếu có thể, nói cách khắc phục;
- có retry khi phù hợp.

Không:
"Something went wrong."

Nên:
"Không thể tải danh sách dịch vụ. Kiểm tra kết nối và thử lại."

## 11. Empty

Empty state phải khác error.

Empty:
"Chưa có dịch vụ."

Error:
"Không thể tải dịch vụ."

## 12. Not found

404 resource:
- title;
- short explanation;
- back;
- home/marketplace CTA.

## 13. Permission denied

403:
- explain access;
- avoid leaking sensitive data;
- provide safe navigation.

## 14. Visual QA

AI agent phải tự kiểm:
- alignment;
- spacing;
- typography;
- inconsistent radius;
- inconsistent buttons;
- excessive borders;
- excessive cards;
- empty areas;
- clipping;
- overflow;
- mobile breakpoints.

## 15. Anti-AI visual checklist

Nếu page có:
- quá nhiều gradient;
- mọi section là card;
- mọi button là pill;
- icon xuất hiện cạnh mọi heading;
- shadow ở mọi card;
- giant heading;
- huge empty hero;
- random blobs;
- neon accent;
- excessive animation;

=> phải redesign trước khi coi là hoàn thành.

## 16. Human product feel

Một UI "human" thường:
- biết thông tin nào quan trọng;
- không cố gây ấn tượng ở mọi nơi;
- dùng typography để tạo hierarchy;
- có copy ngắn;
- có trạng thái thật;
- có lỗi và recovery;
- có edge cases;
- có visual rhythm.
