# WorkGo Frontend — QA & Acceptance Checklist

## 1. Functional

- [ ] Route loads.
- [ ] Navigation works.
- [ ] Back navigation works.
- [ ] Forms validate.
- [ ] Submit loading works.
- [ ] Submit failure works.
- [ ] Retry works where applicable.
- [ ] Auth restrictions work.
- [ ] Role-specific UI works.
- [ ] API data maps correctly.
- [ ] Empty state works.
- [ ] Not-found works.
- [ ] Permission denied works.

## 2. Visual

- [ ] Typography hierarchy consistent.
- [ ] Spacing consistent.
- [ ] Button sizes consistent.
- [ ] Radius consistent.
- [ ] Colors come from tokens.
- [ ] No random gradients.
- [ ] No excessive cards.
- [ ] No excessive shadows.
- [ ] No unnecessary icons.
- [ ] No oversized headings.
- [ ] No layout clipping.
- [ ] Images have correct aspect ratio.

## 3. Responsive

- [ ] 1440px
- [ ] 1280px
- [ ] 1024px
- [ ] 768px
- [ ] 390px
- [ ] 360px

Check:
- [ ] nav
- [ ] forms
- [ ] cards
- [ ] tables
- [ ] modal
- [ ] drawer
- [ ] chat
- [ ] order detail
- [ ] payment
- [ ] map/tracking if applicable

## 4. Accessibility

- [ ] keyboard navigation;
- [ ] focus visible;
- [ ] labels;
- [ ] aria names;
- [ ] semantic headings;
- [ ] color contrast;
- [ ] status not color-only;
- [ ] dialog focus;
- [ ] reduced motion.

## 5. Performance

- [ ] images optimized;
- [ ] lazy loading where appropriate;
- [ ] unnecessary re-rendering avoided;
- [ ] long lists paginated/virtualized where necessary;
- [ ] no huge client bundle from unnecessary dependencies.

## 6. Security

- [ ] no secret API key in frontend;
- [ ] no sensitive document URL exposed unnecessarily;
- [ ] no unsanitized HTML;
- [ ] no sensitive payment data stored locally;
- [ ] frontend permission is not treated as backend security.

## 7. UX

- [ ] Primary CTA obvious.
- [ ] Destructive actions confirmed.
- [ ] Error message actionable.
- [ ] Loading doesn't jump layout.
- [ ] Success feedback clear.
- [ ] Empty state has useful next step.
- [ ] Copy is concise and natural.

## 8. Anti-AI review

Reject and redesign if:
- [ ] visual style looks like generic AI SaaS;
- [ ] gradient is used as decoration rather than meaning;
- [ ] every section is a floating card;
- [ ] all buttons are pill-shaped;
- [ ] icons are everywhere;
- [ ] excessive animation;
- [ ] layout prioritizes appearance over workflow;
- [ ] mobile is merely compressed desktop.

## 9. Final acceptance

Before declaring complete:
- [ ] build passes;
- [ ] type check passes;
- [ ] lint passes if configured;
- [ ] browser verification passes;
- [ ] no critical console errors;
- [ ] no broken routes;
- [ ] all P0 screens implemented;
- [ ] known limitations documented.
