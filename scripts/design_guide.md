# Boba Broker — Design Guide for Code

## Color Palette

Use these exact hex values when assigning colors in code:

| Use Case | Variable | Hex | Purpose |
|----------|----------|-----|---------|
| **Primary** | `cream` | `#FFF8F0` | Main background |
| **Text** | `text` | `#4A3B52` | All body text (Brown Sugar) |
| **Text Alt** | `subtext` | `#7A6880` | Secondary/hint text |
| **Accent** | `accent` | `#C87AB0` | Buttons, headers, CTAs |
| **UI Panels** | `blush` | `#FFD6E0` | Cards, UI panels |
| **Modals** | `lavender` | `#E8D5FF` | Modal backgrounds |
| **Success/Gain** | `mint` | `#C8F0E0` | Money gained, positive feedback |
| **Info** | `sky` | `#C8E8FF` | Tooltips, info states |
| **Warm Accent** | `peach` | `#FFE0C8` | Toasts, notifications |
| **Highlight** | `yellow` | `#FFF0B0` | Rewards, emphasis |
| **Secondary** | `lilac` | `#D8CCFF` | Supporting elements |
| **Accent Alt** | `rose` | `#FFB8C8` | Blush, accents |
| **Accent Alt 2** | `sage` | `#B8E8C8` | Supporting elements |
| **Outline** | `text` | `#4A3B52` | Strokes at 2–3px only |

## Typography

- **Titles, Logos, Numbers:** Fredoka One (32–48px for titles, 20–28px for stats)
- **Headings:** Fredoka One (18–24px)
- **Body Text:** Nunito Bold 700 (13–15px)
- **Captions/Hints:** Nunito 600 (11–12px)

## UI Component Rules

- **Buttons:** Pill-shaped (border-radius: 999px), gradient fill, drop shadow at 0 4px 0
- **Cards & Panels:** 16–20px rounded corners, white or light pastel bg, soft drop shadow
- **Tags/Badges:** Soft rounded pills (999px radius) on pastel backgrounds
- **Text Color:** Always use Brown Sugar (#4A3B52), never pure black
- **Outlines:** Only on strokes; 2–3px width; Brown Sugar color, no black

## Animation Principles

- **Idle Float:** Characters/objects bob gently (2s ease-in-out, 4–8px amplitude)
- **Reward Pulse:** Scale 1.0 → 1.15 → 1.0 (0.3s ease-out) for coins, profit popups
- **Wiggle:** Rotate ±8° on hover/click (0.2s) to signal interactivity
- **Spin:** 3–5s linear ONLY for decorative background elements (never interactive)
- **Transitions:** Keep animations soft and playful; avoid jarring/snappy movements

## Visual Style Guidelines for Coding

1. **Shapes:** Round everything—corners, buttons, character limbs. Use `border-radius` liberally.
2. **Shadows:** Use soft drop shadows (0 4px 12px rgba(0,0,0,0.05–0.1)), never hard/black.
3. **Contrast:** Keep colors soft and low-contrast; avoid neon or highly saturated colors.
4. **Depth:** Use `box-shadow` for button presses (e.g., 0 4px 0 darker-shade) to simulate depth.
5. **Text:** Only use Brown Sugar (#4A3B52) for text; never pure black.
6. **Decorations:** Add sparkles/stars freely for visual interest; use emoji or SVG icons.
7. **Feedback:** Color state changes by background (mint for gain, blush for error, peach for warning).

## Responsive Design Notes

- Maintain padding/margins proportional to 20px base unit
- Use `max-width: 900px` for content containers
- Pill buttons scale with text; ensure clickable area ≥ 44px
- Card shadows and radii remain constant across breakpoints

---

**Summary:** Soft, round, pastel. Think "cozy boba shop UI" — warm, inviting, no sharp edges, playful animations.