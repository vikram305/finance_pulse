# Pulse — Final Product Requirements Document
**Version:** 1.0 · **Status:** Approved  
**Date:** 2026-10-24  
**Sources:** PRD, ADRs (001–017), TDD, Project Status, ADR-DS-001, grill-with-docs session

---

## Table of Contents
1. [Product Vision & Positioning](#1-product-vision--positioning)
2. [Target Audience](#2-target-audience)
3. [Web-to-Mobile Acquisition Funnel](#3-web-to-mobile-acquisition-funnel)
4. [Feature Scope Boundary](#4-feature-scope-boundary)
5. [Core User Journeys](#5-core-user-journeys)
6. [Domain Model](#6-domain-model)
7. [Technical Architecture](#7-technical-architecture)
8. [Security & Storage](#8-security--storage)
9. [Design System](#9-design-system)
10. [Platform-Specific Constraints](#10-platform-specific-constraints)
11. [V1 Predefined Shock Catalogue](#11-v1-predefined-shock-catalogue)
12. [Out of Scope for V1](#12-out-of-scope-for-v1)
13. [Open Tech Debt (Pre-Implementation)](#13-open-tech-debt-pre-implementation)

---

## 1. Product Vision & Positioning

| Field | Value |
|---|---|
| **Working Title** | Pulse (The Financial Sandbox) |
| **Category** | Offline-First Financial Resilience & Simulation Utility |
| **Core Value Proposition** | A private, zero-latency simulation engine for visualising the downstream impact of major life transitions. |
| **Market Differentiator** | Operates entirely offline. 100% Free and Open Source. No ads, no bank logins, no data harvesting, no automated micro-budgeting, no guilt. Positioned as "anti-greed" consumer software. |
| **Business Model** | Permanently free. Open-sourced on GitHub. Zero server costs — the app is offline by design. Open-sourcing is a trust mechanism: users can verify the "no data harvesting" claim by reading the code. |

---

## 2. Target Audience

- **Demographic:** Professionals, ages 25–38, experiencing or planning significant lifestyle transitions.
- **Use Cases:** Planning a wedding, relocating cities, evaluating a vehicle purchase, assessing the runway for a career pivot.
- **Psychology:** Highly protective of data privacy; overwhelmed by spreadsheet building; paralysed by compounding financial variables.

---

## 3. Web-to-Mobile Acquisition Funnel

```
[getpulse.com]  ──► [Web Playground]  ──► [Mobile App]
 SEO billboard       Flutter WASM          iOS / Android
 HTML/CSS            Session-scoped        Full feature set
                     IndexedDB             Persistent encrypted
                     (volatile)            Isar storage
```

### Step 1 — Discovery (The Billboard)
Users find the SEO-optimised HTML/CSS landing page (`getpulse.com`) via organic search. The marketing page is **not** built in Flutter WASM — it is a separate HTML/CSS site to ensure Google SEO crawler visibility.

### Step 2 — The Hook (The Web Playground)
Users click "Try the Sandbox" and land in the Flutter Web (WASM) Playground. They experience the **10-Second Hook** onboarding with zero installation friction.

- Session state is backed by **IndexedDB via Isar Web** (volatile).
- A **session-dismissible header banner** is shown on every new browser session: *"Browser storage is volatile. Clear your cache and your sandbox is gone. Export your scenario or download the app to keep your data."* Dismissal is in-memory only — not written to IndexedDB — so the banner reappears on the next session.
- The web session holds **no persistent Master PIN** and **no Isar encryption layer**. Data at rest in IndexedDB is unencrypted; users are warned accordingly.

### Step 3 — The Lock-In (The Mobile App)
After building their Scenario, users are prompted to export a `.pulse` file (requires entering a one-time Ephemeral PIN) and download the native iOS/Android app to import it. The native app is the **only path** to: the full Panic Room, the Projected Resilience Score, persistent encrypted storage, and biometric security.

### Web Playground — Hard Feature Walls

| Feature | Web Playground | Mobile App |
|---|:---:|:---:|
| 10-Second Hook (Strawman onboarding) | ✅ | ✅ |
| Sandbox Engine (FinancialEvent CRUD + chart) | ✅ | ✅ |
| A/B Scenario Forking | ✅ | ✅ |
| `.pulse` Export (Ephemeral PIN) | ✅ | ✅ |
| `.pulse` Import | ❌ | ✅ |
| Panic Room (Shock chips) | ❌ | ✅ |
| Projected Resilience Score | ❌ | ✅ |
| Persistent encrypted storage (Isar) | ❌ | ✅ |
| Biometric / presentation shielding | ❌ | ✅ |

The absence of Panic Room and Projected Resilience Score on web is the **product mechanic** that drives mobile downloads — not a technical limitation.

---

## 4. Feature Scope Boundary

| Category | In Scope for V1 | Out of Scope for V1 |
|---|---|---|
| **Data Ingestion** | Manual 2-input start, Strawman correction | Bank sync, SMS scraping, PDF/CSV parsing |
| **Simulation** | Time-bound events, drag-to-reorder, named A/B Scenario forking (max 2) | Live investment growth models, multi-currency |
| **Analytics** | Runway calculation, per-Scenario Projected Resilience Score (0–100), cross-Scenario Shock comparison | Categorised past-expense pie charts |
| **Shocks** | 4 predefined hardcoded Shock chips | User-defined custom Shock scenarios |
| **Platform** | iOS, Android, Session-scoped Flutter Web Playground | Centralized cloud databases, user accounts |
| **Portability** | Ephemeral-PIN-encrypted `.pulse` export (web), PIN-encrypted `.pulse` import/export (mobile) | Cloud sync, cross-device auto-backup |

---

## 5. Core User Journeys

### 5.1 The 10-Second Hook (Onboarding)

1. User opens the app — **no splash screen, no account creation, no PIN prompt yet.**
2. UI prompts for two inputs: **Current Liquid Balance** and **Monthly Net Income**.
3. A dismissible notice informs the user: *"The Strawman blocks below are auto-generated estimates. The accuracy of your Projected Resilience Score depends on how much you correct them."*
4. App instantly transitions to the dashboard: a 12-month trajectory chart populated with auto-generated **Strawman** blocks (Rent, Living Costs, EMI) seeded from the 50/30/20 rule. A shimmer `SkeletonLoader` plays during Strawman generation to signal the engine is calculating.
5. User taps a block to correct its value; the chart animates to the new trajectory instantly.
6. **First Isar write-commit triggers PIN setup** (see §8.1).

### 5.2 The Sandbox Engine

#### Single-Scenario Flow
1. User taps the `+` FAB to add a new Event Block.
2. `BlockEditor` bottom sheet opens immediately: **Name, Amount, Polarity (income/expense), Start Month, Duration**.
3. Block appears on the timeline. `TrajectoryChart` redraws in real time.
4. User drags the block horizontally along the timeline rail to change its `startMonth`. Chart animates as the block is dragged.

#### A/B Scenario Forking Flow
1. User taps **"Fork Scenario"** to create a named alternative. Fork is disabled if 2 Scenarios are already active (hard cap).
2. Both Scenarios render simultaneously: **Deep Indigo** (Scenario A) and **Amber** (Scenario B), with a legend overlay.
3. Event Blocks are configured independently per Scenario.
4. Chart updates both trajectories in real time.
5. User can **rename**, **duplicate** (deep copy — new UUIDs for all cloned events), or **delete** any Scenario except the last remaining one.
6. **Projection Window:** 12 / 24 / 36 months (segmented control, default 12 months, hard cap 36 months).

### 5.3 The Panic Room (Stress Test — Mobile Only)

1. User enters the Panic Room. Both Scenario trajectories remain visible.
2. **Projected Resilience** score shown per Scenario side-by-side: *"Scenario A: 34 | Scenario B: 71."*
   - Formula: `score = min(runwayMonths / 12, 1.0) × 100`
   - Ceiling: 12 months runway = 100. Label is always **"Projected Resilience"** — never "Resilience Score."
3. User taps a **Shock chip**. Shock is injected into every active Scenario's engine simultaneously. Scenarios are never mutated — shocks are applied at calculation time only.
4. **Signature crash animation:** Both Bézier lines execute a dramatic crash/diverge animation. The only expressive animation in the product.
5. Diagnostic panel updates per Scenario: *"Scenario A: 2 months survival cash | Scenario B: 6 months survival cash."*
6. Shock chips toggle freely; each change recalculates all Scenarios in real time.

---

## 6. Domain Model

### 6.1 Core Entities

**`FinancialEvent`**
UUID, name, polarity (`income` | `expense`), `startMonth`, `endMonth`, `amount`, `isBaseline`.
`isBaseline = true` → permanent user-confirmed block. `isBaseline = false` → correctable Strawman estimate.

**`Scenario`**
UUID, name, `List<FinancialEvent IDs>`. Min 1, max 2 active in V1 (enforced in `SandboxBloc`; data model is unbounded).
**Duplicate = deep copy.** Shallow copy explicitly rejected.

**`FinancialShock`**
UUID, label, `List<FinancialEvent>` (additive shock events appended at calculation time — Scenario never mutated).
V1: Predefined constant catalogue only. No Isar. No repository. No CRUD.

**`ProjectionNode`**
`monthIndex`, `startingBalance`, `netCashFlow`, `endingBalance`, `activeEventIds`.

**`ResilienceScore`** *(code name — UI label is always "Projected Resilience")*
`scenarioId`, `score` (0–100). Formula: `min(runwayMonths / 12, 1.0) × 100`.

### 6.2 Calculation Engine

```dart
List<ProjectionNode> calculate(Scenario scenario, List<FinancialShock> activeShocks)
```

Pure function. Stateless. Shock flattening: `scenario.events + activeShocks.expand((s) => s.events)`.
Complexity: O(N × M). Target: ≤ 16.6ms per recalculation on 60fps device. Window: 12–36 months.

---

## 7. Technical Architecture

| Concern | Choice | ADR |
|---|---|---|
| State management | BLoC (`flutter_bloc`) | — |
| Dependency injection | GetIt (`get_it`) | ADR-013 |
| Navigation | GoRouter (`go_router`) | ADR-012 |
| Local database | Isar `3.1.0+1` (pinned stable) | ADR-014 |
| Encryption KDF | `cryptography ^2.9.0` + `cryptography_flutter ^2.3.4` (PBKDF2, SHA-256, 100k iterations) | ADR-004 |
| Feature gating | `kIsWeb` compile-time constant | ADR-011 |
| Rendering | Custom Bézier `CustomPainter` in `RepaintBoundary` | ADR-005 |

### Routes (GoRouter)

| Route | Platform | Guard |
|---|---|---|
| `/onboarding` | Both | — |
| `/sandbox` | Both | Redirect to `/onboarding` if no Scenario |
| `/panic-room` | Mobile only | `kIsWeb` → redirect to `/sandbox` |

### Key BLoCs

| BLoC | Platform | Registered via |
|---|---|---|
| `SandboxBloc` | Both | GetIt factory |
| `PanicRoomBloc` | Mobile only | GetIt factory, `if (!kIsWeb)` guard |

### Architecture Mandate
Domain layer is TDD-first. No Presentation or Data layer code may be merged until its Domain use case has a passing test suite.

---

## 8. Security & Storage

### 8.1 Mobile Master PIN Flow (ADR-016)

1. **Deferred to first Isar write-commit** — 10-Second Hook is uninterrupted.
2. `PinEntryDialog(mode: PinMode.setup)` — two fields (PIN + confirm) + export nudge: *"Export a backup now. If you ever forget this PIN or get a new device, your `.pulse` file is the only way to recover your data."*
3. No data ever written to Isar without a PIN.
4. **PIN change:** Requires entering current PIN.
5. **Forgotten PIN:** No server recovery. Wipe + reinstall. Export nudge at setup is the mitigation.

### 8.2 Biometric Gate (Mobile Only)

Foreground transitions gated by `local_auth`.
**Fallback:** `PinEntryDialog(mode: PinMode.entry)` — single PIN field.
Presentation shielding: `FLAG_SECURE` (Android) / `ignoresScreenshotForRecording` (iOS).

### 8.3 `.pulse` File Format (ADR-015)

UTF-8 JSON, independently versioned from Isar schema, PBKDF2-encrypted.

```json
{
  "version": 1,
  "exportedAt": "<ISO-8601>",
  "scenarios": [{ "id": "...", "name": "...", "eventIds": ["..."] }],
  "events": [{ "id": "...", "name": "...", "polarity": "expense|income",
               "startMonth": 0, "endMonth": 11, "amount": 15000.0, "isBaseline": false }]
}
```

### 8.4 Web Export (Ephemeral PIN)
`PinEntryDialog(mode: PinMode.webExport)` → PBKDF2 → encrypt → browser download → PIN discarded.

### 8.5 Storage Architecture

| | Mobile | Web Playground |
|---|---|---|
| Database | Isar 3.1.0+1 (encrypted, file-backed) | Isar Web / IndexedDB (unencrypted, volatile) |
| Encryption | PBKDF2(Master PIN, salt, 100k rounds) → AES-256 | None |
| Durability | Persistent | Session-scoped |

---

## 9. Design System

*(Full specification: ADR-DS-001. This section covers implementation-critical constraints.)*

- **Feel:** Precision instrument. Linear + Raycast + Robinhood inspired.
- **Palette:** Deep Indigo primary `HSL(255,45%,55%)` · Amber secondary `HSL(38,80%,52%)` · Teal income · Rose expense.
- **Typography:** Inter (UI) + JetBrains Mono (all financial numbers). Data Hero: 52px 700.
- **Glassmorphism:** Overlay elements only (`PulseBottomSheet`, `PanicRoomPanel`, tooltips). Base surfaces are solid.
- **Chart constraint:** The chart is **never hidden** while editing a block. Mobile: ~60% viewport height, always above the fold.
- **Signature animation:** Shock chip toggle → dramatic Bézier crash/diverge animation. Only expressive animation in the product.
- **WCAG target:** 2.1 Level AA.

### `PinEntryDialog` — Three Modes
`PinMode.setup` (two fields + export nudge) · `PinMode.entry` (one field, fallback unlock) · `PinMode.webExport` (one field + ephemeral copy)

---

## 10. Platform-Specific Constraints

### Mobile-Only (all gated via `kIsWeb`)
Panic Room · PanicRoomBloc · Projected Resilience Score · Biometric gate · Presentation shielding · `.pulse` Import · Persistent encrypted Isar · Master PIN

### Web-Specific
- Max content width 1200px. Single breakpoint at 768px.
- Session-dismissible volatile storage banner (reappears every new session; dismissal in-memory only).
- No Isar encryption, no Master PIN, no persistent state.
- A/B Scenario Forking and `.pulse` Export available.

---

## 11. V1 Predefined Shock Catalogue

`lib/domain/constants/financial_shocks.dart`

| Constant | Label | Impact | Amount |
|---|---|---|---|
| `FinancialShocks.jobLoss({required double monthlyNetIncome})` | Job Loss | Income → ₹0, months 0–5 | **Relative** (factory method) |
| `FinancialShocks.medicalEmergency` | Medical Emergency | One-time expense, month 0 | Fixed: ₹2,00,000 |
| `FinancialShocks.rentSpike` | Rent Spike | Additional rent, full window | Fixed: +₹12,000/mo |
| `FinancialShocks.emiShock` | EMI Shock | New loan repayment, 24 months | Fixed: +₹15,000/mo |

`jobLoss` is a static factory method. `PanicRoomBloc` calls it with `state.monthlyNetIncome` at shock-list construction time. The other three are static final constants.

---

## 12. Out of Scope for V1

| Item | Reason |
|---|---|
| Bank sync, SMS scraping, PDF/CSV import | ADR-001, ADR-002 |
| User-defined custom Shock scenarios | Scope; 4 predefined chips deliver the core insight |
| User accounts, cloud sync | Violates "zero-server, absolute privacy" guarantee |
| 3+ active Scenarios | Cognitive load ceiling; Panic Room binary comparison breaks (ADR-008) |
| Projection beyond 36 months | Honesty constraint — self-reported input data (ADR-010) |
| Multi-currency, live investment models | Out of scope |
| Keyboard drag-and-drop for EventBlocks | Cost disproportionate to web's funnel role |
| Screen reader narration of TrajectoryChart | Post-MVP; marked decorative for V1 |

---

## 13. Open Tech Debt (Pre-Implementation)

All items from scaffold audit (2026-10-17). Must be resolved before feature implementation.

| # | File | Action |
|---|---|---|
| 1 | `lib/core/network/api_routes.dart` | Delete. Rotate hardcoded OpenWeatherMap API key if repo goes public. |
| 2 | `lib/core/constants/app_constants.dart` | Replace weather constants with Pulse constants. |
| 3 | `lib/core/constants/app_strings.dart` | Rename appTitle to 'Pulse'. Remove weather unit strings. |
| 4 | `lib/core/constants/app_patterns.dart` | Remove `weatherIconUrl()` + CDN constants. |
| 5 | `lib/core/helper/input_helper.dart` + `input_util.dart` | Delete (weather compass logic). |
| 6 | `lib/core/helper/date_util.dart` | Remove weather/server-era date helpers. |
| 7 | `lib/core/network/` (entire dir) | Delete: ApiService, LoggingInterceptor, CertificateReader, api_keys.dart, api_routes.dart. |
| 8 | `lib/core/platform/network_info.dart` | Delete (NetworkInfo / internet_connection_checker_plus). |
| 9 | `pubspec.yaml` | Move `bloc_test` → dev_dependencies. |
| 10 | `pubspec.yaml` | **Add:** isar:3.1.0+1, isar_flutter_libs, path_provider, local_auth, flutter_secure_storage, cryptography:^2.9.0, cryptography_flutter:^2.3.4, uuid, go_router, isar_generator. |
| 11 | `pubspec.yaml` | **Remove:** dio, internet_connection_checker_plus, cached_network_image, json_annotation, json_serializable. |

---

## Planned Implementation Order

| Phase | Feature | Depends on |
|---|---|---|
| 1 | Scaffold audit & cleanup (§13 tech debt) | — |
| 2 | Domain layer + ProjectionEngine (TDD-first) | Phase 1 |
| 3 | Sandbox (Onboarding + FinancialEvent CRUD + TimelineChart) | Phase 2 |
| 4 | Panic Room (FinancialShock injection + ResilienceScore — mobile only) | Phase 3 |
| 5 | Security layer (biometric, screen shield, `.pulse` export/import, Master PIN) | Phase 3 |
| 6 | Web build validation (IndexedDB session, kIsWeb banner, web-to-mobile flow) | Phase 3, 5 |

---

*This document supersedes the draft PRD. All contradictions between this and earlier drafts are resolved in favour of this document. ADR-DS-001 remains the authoritative design system specification.*
