# ADR-DS-001: Pulse Design System & UI Theme

**Status:** Accepted  
**Date:** 2026-10-24  
**Deciders:** Product Owner  
**Context:** Establishing the complete design system and UI theme for Pulse (The Financial Sandbox) before any implementation begins.

---

## 1. Brand & Feel

### Decision
Pulse is an **empowering & analytical** product. Users arrive paralyzed; they leave feeling like a pilot, not a passenger. The design language is a precision instrument — not a wellness app, not a bank.

### Inspiration
| Product | What we steal |
|---|---|
| **Linear** | Purposeful dark UI, surgical typography, motion as feedback not decoration |
| **Raycast** | Dense but breathable layout, command-driven, zero fluff |
| **Robinhood** | Chart-forward; the number and the line are the heroes |

### Explicit Avoidances
- ❌ Bank-blue (`#0033CC` family)
- ❌ Stock photo humans
- ❌ Green-checkmark "you're doing great!" wellness UI
- ❌ Rounded cartoon iconography
- ❌ Dashboard bloat (12 widgets on first screen)
- ❌ Mascots, decorative illustrations (except empty states)

### Glassmorphism Rule
Glassmorphism (`BackdropFilter` / frosted glass) is **scoped to overlay elements only**:
- `PulseBottomSheet`
- `PanicRoomPanel`
- Floating scenario label tooltips on chart

Base cards and surfaces are **solid**. Reason: Flutter's `BackdropFilter` is expensive on mid-range Android; glass-on-glass collapses visual hierarchy.

### Visual Texture
- **Dark theme backgrounds:** 3–5% noise grain texture (prevents OLED banding, reads as premium matte)
- **Illustrations:** Minimal line-art only on **empty states**. No illustrations on any primary screen.

---

## 2. Color System

### Themes
Both **dark mode** and **light mode** are required. Dark mode is the primary design surface.

### Primary Palette
| Token | HSL Value | Usage |
|---|---|---|
| `color.primary` | `HSL(255, 45%, 55%)` Deep Indigo | CTAs, active states, logo, Scenario A chart line |
| `color.secondary` | `HSL(38, 80%, 52%)` Amber | Scenario B chart line, secondary accent |

> **Note on saturation:** Primary Indigo is deliberately desaturated (`45%` not `85%`) to read as a precision tool, not a game app. In the light theme, lightness must be adjusted to maintain WCAG AA `4.5:1` contrast.

### Chart Trajectory Colors
| Scenario | Color | Rationale |
|---|---|---|
| Scenario A | Deep Indigo (primary) | — |
| Scenario B | Amber (secondary) | Maximum contrast; passes deuteranopia colorblind test |

### Financial Polarity Colors
These are **not** success/error tokens. They communicate direction, not moral judgment.

| Polarity | Color | HSL |
|---|---|---|
| Income (positive) | Teal | `HSL(174, 55%, 45%)` |
| Expense (negative) | Rose | `HSL(350, 60%, 55%)` |

### Semantic Tokens (Custom-Shifted)
Standard red/amber/green/blue avoided to prevent palette collision with primary Indigo and Amber.

| Token | Color | HSL (approx.) |
|---|---|---|
| `color.error` | Rose | `HSL(350, 65%, 58%)` |
| `color.warning` | Gold | `HSL(45, 90%, 52%)` |
| `color.success` | Emerald | `HSL(155, 55%, 42%)` |
| `color.info` | Sky | `HSL(200, 75%, 52%)` |

---

## 3. Typography

### Font Families
| Role | Font | Source |
|---|---|---|
| UI — headings, body, labels | **Inter** | Google Fonts |
| Data — all numbers, scores, values | **JetBrains Mono** | Google Fonts / JetBrains |

Rationale: Inter is invisible in the best way — attention goes to content. JetBrains Mono on financial numbers (`₹ 4,82,000`, `74 / 100`) gives instrument-panel gravitas.

### Type Scale
| Level | Font | Size | Weight | Usage |
|---|---|---|---|---|
| Display | Inter | 36px | 600 | Section headings, screen titles |
| Body | Inter | 15px | 400 | Primary content, descriptions |
| Label | Inter | 12px | 500 | Chips, tags, captions, form labels |
| **Data Hero** | JetBrains Mono | **52px** | **700** | Resilience Score, hero financial number |
| Data Inline | JetBrains Mono | 15px | 600 | Chart axis labels, block amounts |
| Data Small | JetBrains Mono | 12px | 500 | Timestamp values, secondary metrics |

---

## 4. Spacing & Layout

### Base Unit
**4px** base spacing unit.

Full scale: `4, 8, 12, 16, 24, 32, 48, 64px`

Rationale: Dense UI elements (event blocks, scenario chips, chart labels) need `12px` inner padding — the `8px` system forces a choice between too tight (`8`) and too loose (`16`).

### Web Playground (Flutter Web WASM)
| Property | Value |
|---|---|
| Max content width | `1200px` |
| Breakpoints | Single breakpoint at `768px` (mobile / desktop) |
| Layout | Chart full-bleed; `1200px` content sidebar for controls |

Rationale: The web build is a conversion funnel, not the primary product. One breakpoint ships faster and showcases the chart.

### Mobile Layout (Native iOS / Android)
| Zone | Height |
|---|---|
| Chart canvas | `~60%` of viewport height, always above the fold |
| Event block list | Scrollable below the chart |

**The chart is never hidden while editing a block.** The real-time feedback loop (edit block → chart animates instantly) is the product's core mechanic. Hiding the chart breaks it.

---

## 5. Components

### Foundation Strategy
**Material 3 (heavily themed) + custom Pulse primitives.**

- Material 3 handles commodity widgets: `TextField`, `BottomSheet`, `SnackBar`, `Dialog`, `NavigationBar`
- Pulse builds from raw primitives for signature components: `TrajectoryChart`, `EventBlock`, `ResilienceScoreDisplay`, `ShockChip`

### MVP Component Inventory (All tiers ship in v1)

**Tier 1 — Core Loop**
| Component | Type | Notes |
|---|---|---|
| `PulseTextField` | Custom | Two-input onboarding |
| `TrajectoryChart` | Custom Painter | Animated Bézier, dual-scenario |
| `EventBlock` | Custom | Draggable/tappable timeline card |
| `BlockEditor` | Custom | Bottom sheet for block params |
| `ScenarioChip` | Custom | A/B scenario toggle |
| `PulseButton` | Material-based | Primary / secondary / ghost variants |
| `PulseBottomSheet` | Custom | Glassmorphism overlay container |

**Tier 2 — Panic Room**
| Component | Type | Notes |
|---|---|---|
| `ResilienceScoreDisplay` | Custom | JetBrains Mono 52px hero number |
| `ShockChip` | Custom | Toggleable stress-test chip |
| `PanicRoomPanel` | Custom | Glassmorphism overlay on chart |

**Tier 3 — Polish**
| Component | Type | Notes |
|---|---|---|
| `SkeletonLoader` | Custom | Shimmer on Strawman block generation |
| `EmptyStateIllustration` | Custom | Zero-data state only |
| `ToastNotification` | Material-based | `.pulse` export confirmation |
| `PinEntryDialog` | Custom | **Parameterised, three modes via `PinMode` enum:**<br>• `PinMode.setup` — two fields (PIN + confirm) + export nudge copy (mobile Master PIN setup, ADR-016)<br>• `PinMode.entry` — one field (biometric fallback unlock, ADR-016)<br>• `PinMode.webExport` — one field + ephemeral copy (web `.pulse` export, ADR-004) |

---

## 6. Interaction & Motion

### Philosophy
**Surgical + one signature moment.**

- Default: `300ms ease-out` for all state transitions. Fast, functional, invisible.
- Tap feedback: Scale `0.97 → 1.0` (feels physical, not sluggish)
- Nothing animates for decoration

### The Signature Moment
When a **Shock chip is toggled** in the Panic Room, both Bézier trajectory lines execute a **dramatic crash animation** — diverging or collapsing with distinct choreography. This is the only expressive animation in the product. It earns its place: the PRD says *"both trajectory lines visually crash (or diverge)"* — the animation must make the resilience gap undeniable.

### Interaction States
| State | Treatment |
|---|---|
| Hover (web) | Background tint + `2px` primary color border glow |
| Focus (keyboard) | `2px` solid primary color outline, `2px` offset |
| Pressed / Tap | Scale `0.97 → 1.0`, `120ms` |
| Disabled | `40%` opacity, no interaction |

### Loading & Skeleton
**Shimmer animation** on all skeleton placeholders.

The Strawman block auto-generation on onboarding is a key moment — shimmer communicates "the engine is calculating for you" before the blocks populate. This sets the product's analytical tone immediately.

---

## 7. Accessibility

### WCAG Target
**WCAG 2.1 Level AA**

- Minimum contrast: `4.5:1` for normal text, `3:1` for large text and UI components
- Deep Indigo primary **must be lightness-adjusted in the light theme** to hit `4.5:1`
- All semantic tokens verified against both dark and light surfaces before implementation

### Keyboard Navigation
**Partial** — Web playground only.

- ✅ Tab order on all interactive elements
- ✅ Enter to activate buttons and chips
- ✅ Escape to close modals and bottom sheets
- ❌ Keyboard drag-and-drop for event blocks (pointer-only; engineering cost disproportionate to web's funnel role)

### Screen Reader Support
**Core flow only — MVP.**

- ✅ Semantic labels on all inputs, buttons, chips, and navigation
- ✅ Modal and dialog accessibility (role, aria-labelledby)
- ⚠️ `TrajectoryChart` marked as decorative for MVP; meaningful narration is a post-MVP roadmap item
- ⚠️ `EventBlock` timeline: best-effort labels for MVP

---

## Consequences

### Positive
- Design system is fully defined before a single widget is built
- All color, type, spacing, and motion decisions are explicit — no ambiguity in implementation
- Material 3 foundation reduces accessibility burden significantly
- Scoped glassmorphism avoids Flutter `BackdropFilter` performance penalty on mid-range Android

### Risks & Mitigations
| Risk | Mitigation |
|---|---|
| Deep Indigo fails AA in light theme | Test with Contrast Ratio tool at token definition stage; adjust lightness before any component is built |
| Shimmer performance on old Android | Use `flutter_shimmer` with `RepaintBoundary`; test on Pixel 4a equivalent |
| Signature crash animation is over-engineered | Prototype it first as a standalone widget; if it takes > 1 day, simplify to a `300ms` opacity + translate |
| All-tier MVP scope creep | Tier 3 components are simple; `EmptyStateIllustration` and `ToastNotification` are lowest risk |

---

## References
- [Product Requirements Document](file:///Users/vikrammaurya/Documents/Workspace/Project/finance_pulse/.agents/docs/product_requirements_document.md)
- WCAG 2.1 Guidelines: https://www.w3.org/TR/WCAG21/
- Flutter Material 3 ThemeData: https://docs.flutter.dev/ui/design/material
- Inter typeface: https://rsms.me/inter/
- JetBrains Mono: https://www.jetbrains.com/legalnotice/monofont/
