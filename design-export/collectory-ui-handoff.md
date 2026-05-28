# Collectory UI Handoff

## Figma Links

Design file:  
https://www.figma.com/design/SRXpFes4Cl665Unw5Yi3V1/Collectory-Museum-Home-UI?m=dev

Clickable prototype:  
https://www.figma.com/proto/SRXpFes4Cl665Unw5Yi3V1/Collectory-Museum-Home-UI?m=dev&scaling=scale-down&content-scaling=fixed&starting-point-node-id=1%3A2

## UI Scope

This UI prototype covers the main MVP screens for Collectory:

- Home / Museum Hall
- Gallery View
- Item Detail
- Add New Exhibit
- Collection Room Overview
- Profile
- Share Room Settings
- Gallery Layer Motion demo

## Prototype Logic

### Home

- Tap Gallery tab -> Gallery View
- Tap Add tab -> Add New Exhibit
- Tap Profile tab -> Profile
- Tap ROOM 01 / May 2026 Archive -> Collection Room Overview
- Tap Tickets / Memories / Minerals / Vinyl -> Gallery View

### Gallery View

- Tap any layered exhibit set -> Item Detail
- Drag layered set -> Layer Motion demo
- Bottom nav -> Home / Add / Profile

### Item Detail

- Back -> Gallery View
- Bottom nav -> Home / Gallery / Add / Profile

### Add New Exhibit

- Draft / Cancel -> Collection Room Overview
- Bottom nav -> Home / Gallery / Profile

### Collection Room Overview

- Back -> Home
- Top-right share button -> Share Room Settings
- Open wall -> Gallery View
- Add exhibit -> Add New Exhibit

### Profile

- Recent room cards -> Collection Room Overview
- Settings / Privacy -> Share Room Settings
- Bottom nav -> Home / Gallery / Add

### Share Room Settings

- Back -> Profile

## MVP Prototype Note

May 2026 is the active demo room.

ROOM 02 and ROOM 03 are preview rooms. In the prototype, tapping them opens the active May 2026 Collection Room.

The Gallery has four object types: Vinyl, Ticket, Memory, and Mineral. In the Figma prototype, they reuse one detail template; in the MVP app, each object should load different detail data.

# Collectory Frontend UI Style Guide

## 1. Design Concept

Collectory uses a warm personal-museum style. The UI should feel calm, curated, and gallery-like, rather than like normal file storage.

## 2. Color Palette

### Background

- App background: `#F7F1E7`
- Secondary background / floor area: `#EDE2D2`
- Card background: `#F4EBDD`

### Text

- Primary text: `#171512`
- Secondary text: `#7C7469`
- Metadata / label text: `#A8643A`

### Borders

- Light border: `#D4C8B8`
- Dark divider: `#B8A996`

### Category Colors

- Vinyl brown: `#C7A679`
- Vinyl black: `#17120F`
- Ticket clay: `#C98250`
- Memory soft blue-green: `#C9D9D5`
- Mineral green: `#55746A`
- Mineral lavender: `#D8D1E8`

### Action Colors

- Primary button background: `#171512`
- Primary button text: `#FFF8EE`
- Secondary button border: `#D4C8B8`

## 3. Typography

Recommended font:

- `Inter` or system sans-serif

Type scale:

- Page title: 36-44px, Bold
- Section title: 22-26px, Bold
- Card title: 18-22px, Semi Bold
- Body text: 14-16px, Regular
- Metadata label: 10-12px, Medium, uppercase
- Bottom nav: 12px, Regular / Semi Bold when active

Line height:

- Titles: 1.1-1.2
- Body text: 1.4-1.5

## 4. Spacing

Base spacing unit: 8px

Common spacing:

- Screen horizontal padding: 28px
- Section gap: 24-32px
- Card internal padding: 16-18px
- Small label-to-title gap: 8-12px
- Bottom nav height: 50px

## 5. Border Radius

- Small chips/buttons: 20px
- Cards/panels: 8px
- Large phone frame / containers: 28-36px
- Object images: 4-8px

## 6. Shadows

Use soft museum-display shadows, not heavy app shadows.

Default card shadow:

```css
box-shadow: 0 10px 24px rgba(23, 18, 15, 0.10);
```

Elevated object shadow:

```css
box-shadow:
  0 14px 24px rgba(23, 18, 15, 0.18),
  0 2px 4px rgba(23, 18, 15, 0.10);
```

## 7. Buttons

Primary button:

- Background: `#171512`
- Text: `#FFF8EE`
- Radius: 20px
- Height: 28-40px

Secondary button:

- Background: transparent or `#F7F1E7`
- Border: `#D4C8B8`
- Text: `#7C7469`
- Radius: 20px

## 8. Tags / Pills

Tag pill:

- Height: 28px
- Border radius: 20px
- Padding: 12-18px horizontal
- Active background: `#171512`
- Active text: `#FFF8EE`
- Inactive background: transparent
- Inactive border: `#D4C8B8`
- Inactive text: `#7C7469`

## 9. Cards

Room card:

- ROOM 01 background: `#E8D7BD`
- ROOM 02 background: `#D5E0DC`
- ROOM 03 background: `#DCD5EA`
- Border: `#D4C8B8`
- Radius: 8px

Exhibit card:

- Use object visual at the top
- Metadata label above title
- Title should be bold and short
- Avoid long body text inside cards

## 10. Navigation

Bottom nav:

- Height: 50px
- Labels: Home, Gallery, Add, Profile
- Text size: 12px
- Active label: `#171512`, Semi Bold
- Inactive label: `#7C7469`
- Active indicator: 28px width, 3px height, color `#A8643A`

## 11. Motion / Prototype

Transition style:

- Use dissolve or smart animate
- Duration: 120-450ms
- Avoid flashy motion

Layered gallery motion:

- Back layers move slightly upward/right
- Front layer moves slightly downward/left
- Use Smart Animate to suggest layered browsing

## Frontend Note

Color values are frontend-ready approximations based on the final Figma design. Developers should use these tokens consistently when implementing the MVP.

