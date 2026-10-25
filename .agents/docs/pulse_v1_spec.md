# Pulse V1 — Implementation Spec

> **Synthesized from:** Final PRD (v1.0), ADRs 001–018, ADR-DS-001, TDD, Project Status, Context.md  
> **Date:** 2026-10-25  
> **Status:** Ready for implementation

---

## Problem Statement

Professionals aged 25–38 who are facing major life transitions — a wedding, a city relocation, a vehicle purchase, a career pivot — have no private, friction-free way to visualise how those decisions cascade through their finances over time. Spreadsheets require hours to build, open-banking apps harvest data, and budgeting apps generate guilt rather than insight.

The result: users are paralysed at exactly the moment they need clarity. They cannot compare two futures side by side. They have no way to stress-test their plans against realistic shocks (job loss, medical emergency) without expert help. And they cannot trust any tool that touches their financial data.

---

## Solution

Pulse is an offline-first, zero-server financial simulation utility. Users enter two numbers — their current liquid balance and monthly net income — and within ten seconds they have a populated trajectory chart showing the next twelve months. They then sculpt their future by adding, editing, and repositioning time-bound financial events. They can fork their timeline into two named scenarios and compare them side-by-side. On mobile, they enter the Panic Room: a stress-test mode that injects predefined financial shocks across both scenarios simultaneously and reports a per-scenario Projected Resilience score (0–100).

No bank logins. No data uploaded. No account created. Open-source for auditability. Free forever.

The web version (Flutter WASM) acts as a zero-friction acquisition funnel: users build a scenario in the browser, export it as an encrypted `.pulse` file, and import it into the native app to unlock persistent encrypted storage and the full Panic Room feature set.

---

## User Stories

### Onboarding — The 10-Second Hook

1. As a new user, I want to open the app without a splash screen, account creation, or PIN prompt, so that I experience value before I commit to anything.
2. As a new user, I want to enter only two numbers — my current liquid balance and my monthly net income — so that I can get started without a lengthy setup form.
3. As a new user, I want to see auto-generated Strawman financial event blocks (Rent, Living Costs, EMI) immediately after entering my two numbers, so that I have a starting point to correct rather than a blank slate to fill.
4. As a new user, I want to see a shimmer skeleton loader while the Strawman blocks are being generated, so that I understand the app is calculating for me.
5. As a new user, I want to see a dismissible notice telling me that Strawman blocks are estimates and my Projected Resilience score depends on correcting them, so that I understand the trade-off between speed and accuracy.
6. As a new user on web, I want to see a session-dismissible banner warning me that browser storage is volatile, so that I know to export my scenario before clearing cache.
7. As a new user on web, I want the volatile storage banner to reappear on every new browser session (even if I dismissed it last time), so that I am always warned at least once per session.

### Sandbox Engine — Single Scenario

8. As a user, I want to see a trajectory chart displaying my projected balance over 12 months by default, so that I can immediately see the financial shape of my future.
9. As a user, I want to adjust the projection window between 12, 24, and 36 months using a segmented control, so that I can plan for different life horizons.
10. As a user, I want the projection window to never exceed 36 months, so that I am not presented with false precision on self-reported data.
11. As a user, I want to add a new financial event block by tapping the `+` FAB, so that I can add life events to my timeline without a palette UI.
12. As a user, I want the Block Editor bottom sheet to open immediately when I tap `+`, so that I can enter the event's name, amount, polarity, start month, and duration without navigating away.
13. As a user, I want to see the trajectory chart update in real time as I configure an event block, so that I understand the impact of each event as I define it.
14. As a user, I want to drag an event block horizontally along the timeline rail to change its start month, so that I can reposition it kinetically.
15. As a user, I want the trajectory chart to animate in real time as I drag an event block, so that I feel the chart responding to my hands.
16. As a user, I want to tap an event block to reopen the Block Editor and change any parameter, so that I can correct mistakes easily.
17. As a user, I want to delete an event block, so that I can remove events that no longer apply.
18. As a user, I want Strawman event blocks to be clearly distinguishable from user-confirmed baseline blocks, so that I know which estimates still need correction.
19. As a user, I want tapping a Strawman block to let me edit it just like any other block, so that correction is seamless.
20. As a user, I want the chart to never be hidden while I am editing a block, so that I can always see the trajectory impact of my edits.

### Sandbox Engine — A/B Scenario Forking

21. As a user, I want to tap "Fork Scenario" to create a second named scenario, so that I can explore two competing financial futures simultaneously.
22. As a user, I want both scenarios rendered simultaneously on the same chart canvas — Scenario A in Deep Indigo and Scenario B in Amber — with a legend overlay, so that I can compare their trajectories at a glance.
23. As a user, I want to configure event blocks independently per scenario, so that adding a block to Scenario A does not affect Scenario B.
24. As a user, I want the chart to update both trajectories in real time as I edit events in either scenario, so that the comparison is always live.
25. As a user, I want to rename a scenario, so that I can give it a meaningful label (e.g., "Buy a Car" vs "Use Ubers").
26. As a user, I want to duplicate a scenario, so that I can start a variant without rebuilding from scratch.
27. As a user, I want duplicating a scenario to produce a fully independent deep copy with new UUIDs for all cloned events, so that editing the copy does not affect the original.
28. As a user, I want to delete a scenario, so that I can remove an alternative I no longer need.
29. As a user, I want to be prevented from deleting the last remaining scenario, so that the app always has at least one active scenario.
30. As a user, I want the Fork Scenario action to be disabled when two scenarios are already active, so that the V1 two-scenario cap is clearly communicated.

### Panic Room — Mobile Only

31. As a mobile user, I want to enter the Panic Room from the Sandbox, so that I can stress-test my scenarios.
32. As a mobile user in the Panic Room, I want to see both scenario trajectories remain visible on the chart, so that I have full context while applying shocks.
33. As a mobile user, I want to see a Projected Resilience score (0–100) displayed per scenario side-by-side (e.g., "Scenario A: 34 | Scenario B: 71"), so that I can compare resilience at a glance.
34. As a mobile user, I want the score to always be labelled "Projected Resilience" — never "Resilience Score" — so that I understand it is a simulation output, not a certified rating.
35. As a mobile user, I want to tap a Shock chip to inject a financial shock across all active scenarios simultaneously, so that I can see which scenario survives the same shock better.
36. As a mobile user, I want the shock to never mutate my scenario data — only applied at calculation time — so that my original plan is preserved when I toggle the shock off.
37. As a mobile user, I want both Bézier trajectory lines to execute a dramatic crash or diverge animation when a Shock chip is toggled, so that the resilience gap is visually undeniable.
38. As a mobile user, I want to see a diagnostic panel showing per-scenario survival cash (e.g., "Scenario A: 2 months survival cash | Scenario B: 6 months survival cash"), so that I have a concrete breakdown alongside the score.
39. As a mobile user, I want to toggle Shock chips on and off freely, with each change recalculating all scenarios in real time, so that I can explore multiple stress combinations interactively.
40. As a mobile user, I want the four predefined Shock chips — Job Loss, Medical Emergency, Rent Spike, EMI Shock — always available in the Panic Room, so that I can stress-test common real-world risks.
41. As a mobile user experiencing Job Loss, I want the shock to reflect my actual monthly net income as the impact magnitude (not a fixed amount), so that the shock feels personally relevant regardless of my income level.

### Security — Mobile PIN & Biometrics

42. As a mobile user, I want the app to ask me to set a Master PIN at the moment my first scenario is saved to storage — not before — so that the onboarding 10-Second Hook is uninterrupted.
43. As a mobile user setting up my PIN, I want to enter the PIN twice (PIN + confirm) in a two-field dialog, so that I don't accidentally lock myself out with a typo.
44. As a mobile user setting up my PIN, I want to see a prominent export nudge — "Export a backup now. If you ever forget this PIN or get a new device, your `.pulse` file is the only way to recover your data." — so that I understand my recovery options before I need them.
45. As a mobile user, I want no financial data ever written to storage before a Master PIN is set and a PBKDF2 encryption key is derived, so that my data is always encrypted at rest.
46. As a mobile user, I want to change my Master PIN by entering my current PIN first, so that PIN changes require me to prove I know the current PIN.
47. As a mobile user who has forgotten their PIN, I want to understand that there is no server-side recovery — only a wipe and reinstall — so that I am not surprised and take the export nudge seriously.
48. As a mobile user, I want the app to require biometric authentication when I bring it to the foreground, so that my financial data is not visible if someone else picks up my phone.
49. As a mobile user whose biometrics fail or are unavailable, I want to fall back to entering my Master PIN, so that biometric failure never permanently locks me out.
50. As a mobile user, I want the app's screen to be obscured (native screenshot-blocking) when I background the app, so that my financial data is not visible in the app switcher or in screenshots.

### Portability — `.pulse` Files

51. As a web user, I want to export my scenario as an encrypted `.pulse` file by entering a one-time ephemeral PIN, so that I can carry my work to the mobile app.
52. As a web user exporting, I want to see the copy "Choose a PIN you'll remember — you'll need it to import on mobile. There is no recovery if you forget it." so that I choose a PIN I can recall.
53. As a web user, I want the ephemeral PIN to be immediately discarded after export — never stored in the browser — so that my export PIN cannot be retrieved.
54. As a mobile user, I want to import a `.pulse` file by entering the same PIN I used at web export, so that I can restore my web sandbox session on my phone.
55. As a mobile user importing, I want to be prompted to set or change my Master PIN immediately after a successful import, so that my imported data is protected under my mobile encryption key.
56. As a mobile user, I want to export a `.pulse` file using my Master PIN at any time, so that I can create manual backups or migrate to a new device.
57. As any user, I want the `.pulse` file to be encrypted with PBKDF2 (100k iterations, SHA-256), so that the file is secure even if it is shared or stored on an untrusted service.

### Web Playground — Specific Behaviours

58. As a web user, I want to use all Sandbox features (Strawman onboarding, FinancialEvent CRUD, A/B Scenario Forking, `.pulse` export) without installing anything, so that I can evaluate the app with zero commitment.
59. As a web user, I want the web build to be capped at 1200px content width with a single breakpoint at 768px, so that the chart-forward layout is presented correctly on any screen.
60. As a web user, I want the web build to never show the Panic Room, Projected Resilience Score, `.pulse` Import, persistent encrypted storage, or biometric features, so that the mobile value proposition is preserved.

### Design & Experience

61. As a user, I want all financial numbers displayed in JetBrains Mono, so that amounts feel precise and instrument-like rather than decorative.
62. As a user, I want the primary UI in Inter, so that labels and copy are clean and invisible in the best way.
63. As a user, I want the Projected Resilience score displayed as a hero number at 52px / 700 weight in JetBrains Mono, so that it commands immediate attention.
64. As a user, I want interactive elements to respond with a subtle scale animation (0.97 → 1.0, 120ms) on tap, so that the UI feels physical and responsive.
65. As a user, I want all state transitions to animate at 300ms ease-out by default, so that the interface feels fast and functional without being sluggish.
66. As a user on web, I want interactive elements to show a primary-color border glow on hover, so that focusable elements are clearly discoverable with a pointer.
67. As a user on web, I want all interactive elements to be keyboard-focusable (Tab, Enter, Escape), so that the web playground is usable without a mouse.
68. As a user, I want all UI text, buttons, chips, and inputs to meet WCAG 2.1 Level AA contrast ratios, so that the app is accessible to users with low vision.
69. As a user, I want empty states to display minimal line-art illustrations (and nowhere else), so that the product feels analytical rather than decorative.
70. As a user, I want the Panic Room panel and the Block Editor bottom sheet to use glassmorphism (frosted glass), while all other surfaces remain solid, so that overlays feel elevated without degrading performance on mid-range devices.

---

## Implementation Decisions

### Domain Layer

- **`FinancialEvent`** entity: UUID, name, polarity (`income` | `expense`), `startMonth`, `endMonth`, `amount`, `isBaseline`. `isBaseline = true` means user-confirmed; `isBaseline = false` means correctable Strawman estimate.
- **`Scenario`** entity: UUID, name, ordered list of `FinancialEvent` IDs. The BLoC state holds `Map<ScenarioId, Scenario>`. Data model is unbounded; the V1 cap of 2 is enforced in `SandboxBloc` only (not in the entity).
- **Scenario duplication is always a deep copy.** New UUIDs generated for all cloned events. Shallow copy (shared references) is explicitly rejected — it silently corrupts both scenarios on edit.
- **`FinancialShock`** entity: UUID, label, `List<FinancialEvent>` of additive deltas. App-level scope (not Scenario-scoped). Shocks are applied at calculation time by flattening them into the event list; the `Scenario` entity is never mutated.
- **V1 `FinancialShock` catalogue** is a predefined constant set — no database storage, no repository, no CRUD. Four shocks:
  - `FinancialShocks.jobLoss({required double monthlyNetIncome})` — static factory method; makes income → ₹0 for months 0–5. Relative so it scales to any income level.
  - `FinancialShocks.medicalEmergency` — static final; ₹2,00,000 one-time expense, month 0.
  - `FinancialShocks.rentSpike` — static final; +₹12,000/mo for full projection window.
  - `FinancialShocks.emiShock` — static final; +₹15,000/mo for 24 months.
- **`ProjectionNode`** entity: `monthIndex`, `startingBalance`, `netCashFlow`, `endingBalance`, `activeEventIds`.
- **`ResilienceScore`** entity (internal name): `scenarioId`, `score` (0–100). UI label is always **"Projected Resilience"**, never "Resilience Score".

### Calculation Engine

- **Signature:** `List<ProjectionNode> calculate(Scenario scenario, List<FinancialShock> activeShocks)` — pure function, stateless, no side effects.
- **Shock flattening:** `scenario.events + activeShocks.expand((s) => s.events)` before computing each `ProjectionNode`.
- **Complexity:** O(N × M), N = months, M = active events. Target: ≤ 16.6ms per full recalculation on a 60fps device.
- **Projection window:** 12–36 months (user-adjustable via segmented control: 1yr / 2yr / 3yr). Default: 12 months. Hard cap: 36 months enforced in the engine regardless of input.
- **Isolates:** Not required for V1 data scale. Migration to an Isolate is permitted if profiling reveals frame drops.
- **Resilience formula:** `score = min(runwayMonths / 12, 1.0) × 100`. Ceiling: 12 months runway = 100. The ceiling is an honesty constraint — self-reported input data does not support finer differentiation above 12 months.

### State Management & BLoC Architecture

- **`SandboxBloc`:** Manages `Map<ScenarioId, Scenario>` and calls `ProjectionEngine` on every state change. Registered as a GetIt factory, provided at MaterialApp root via `BlocProvider`. Available on both web and mobile.
- **`PanicRoomBloc`:** Manages `FinancialShock` activation and constructs the active shock list (calling `FinancialShocks.jobLoss(monthlyNetIncome: state.monthlyNetIncome)` at list construction time). Registered only when `!kIsWeb`. Mobile-only.
- **V1 two-scenario cap** is enforced in `SandboxBloc` — reject a Fork Scenario event if the map already contains 2 entries.

### Dependency Injection & Navigation

- **DI container:** `get_it`. Manages construction and lifetime of repositories, services, and use cases. BLoC state is managed by `flutter_bloc`'s `BlocProvider`, not directly by GetIt.
- **Platform gating at registration time:** `if (!kIsWeb)` guards on `PanicRoomBloc` and the encrypted `DatabaseService` registration. Dead-code branches are tree-shaken by the Flutter compiler.
- **Navigation:** `go_router`. Three named routes: `/onboarding`, `/sandbox`, `/panic-room`. The `/panic-room` route has a GoRouter redirect guard: if `kIsWeb`, redirect to `/sandbox`.

### Storage & Database

- **Database:** Drift (`drift`, `drift_flutter`, `drift_dev`) (ADR-018). Used for both mobile (encrypted SQLite file-backed) and web (IndexedDB-backed via `drift/wasm.dart` Web Worker, unencrypted).
- **Schema:** Relational tables `scenarios` and `financial_events` (`scenario_id` foreign key referencing `scenarios(id) ON DELETE CASCADE` and integer `order_index`).
- **`DatabaseService`** branches on `kIsWeb` for encrypted vs. unencrypted open. Web opens immediately unencrypted; Mobile opens lazily once Master PIN PBKDF2 key is derived.
- **Mobile:** PBKDF2(Master PIN, salt, 100k rounds, SHA-256) → AES-256 encryption key → full database page encryption via `sqlcipher_flutter_libs`. No plaintext financial data ever written to disk.
- **Web:** No encryption layer. IndexedDB storage is unencrypted and volatile. Session-dismissible banner shown every new session. Ephemeral export PIN is never stored in the browser.

### Encryption & Portability

- **PBKDF2 library:** `cryptography ^2.9.0` + `cryptography_flutter ^2.3.4`. Uses native backends (Apple CryptoKit / javax.crypto) and supports WASM/Web Crypto API.
- **`.pulse` file format:** UTF-8 JSON, PBKDF2-encrypted, independently versioned from the database schema. V1 envelope:
  ```json
  {
    "version": 1,
    "exportedAt": "<ISO-8601 timestamp>",
    "scenarios": [{ "id": "...", "name": "...", "eventIds": ["..."] }],
    "events": [{ "id": "...", "name": "...", "polarity": "expense|income",
                 "startMonth": 0, "endMonth": 11, "amount": 15000.0, "isBaseline": false }]
  }
  ```
- **Mobile Master PIN setup:** Deferred to the moment of the first database write-commit (not at app open). `PinEntryDialog(mode: PinMode.setup)` — two fields (PIN + confirm) + export nudge copy.
- **Biometric fallback:** If `local_auth` fails, fall back to `PinEntryDialog(mode: PinMode.entry)`. Biometric is a convenience layer; the Master PIN is the ultimate backstop.
- **Ephemeral web export:** `PinEntryDialog(mode: PinMode.webExport)` — one field + ephemeral copy. PIN derived via PBKDF2, `.pulse` file downloaded, PIN immediately discarded.
- **Forgotten PIN:** No server-side recovery. Wipe + reinstall. Export nudge at PIN setup is the mitigation.

### Rendering

- **Chart:** `TrajectoryChart` — custom Bézier `CustomPainter` wrapped in a `RepaintBoundary`. Receives `Map<ScenarioId, List<ProjectionNode>>`. Draws one named Bézier path per active Scenario.
- **Scenario colours:** Scenario A → Deep Indigo `HSL(255, 45%, 55%)`. Scenario B → Amber `HSL(38, 80%, 52%)`. Passes the deuteranopia colorblind test.
- **Performance target:** 60–120 FPS. The painter bypasses Flutter widget reconciliation — painting directly to the GPU via `RepaintBoundary`.
- **Chart is never hidden while editing a block.** This is a non-negotiable constraint — it is the product's core kinetic feedback mechanic.
- **Web rendering engine:** Flutter WASM. Mobile: Flutter Impeller/Skia.

### Design System (ADR-DS-001)

- **Primary palette:** Deep Indigo `HSL(255, 45%, 55%)` (CTAs, active states, Scenario A); Amber `HSL(38, 80%, 52%)` (Scenario B, secondary accent).
- **Polarity colours:** Teal `HSL(174, 55%, 45%)` for income (positive); Rose `HSL(350, 60%, 55%)` for expense (negative). These communicate direction, not moral judgment.
- **Semantic tokens:** Error → Rose `HSL(350, 65%, 58%)`; Warning → Gold `HSL(45, 90%, 52%)`; Success → Emerald `HSL(155, 55%, 42%)`; Info → Sky `HSL(200, 75%, 52%)`. Standard red/green/blue explicitly avoided to prevent palette collision with primary Indigo and Amber.
- **Typography:** Inter (all UI — headings, body, labels). JetBrains Mono (all numbers, scores, values). Data Hero number at 52px / 700 weight in JetBrains Mono.
- **Spacing base unit:** 4px. Full scale: `4, 8, 12, 16, 24, 32, 48, 64px`.
- **Glassmorphism scope:** `PulseBottomSheet`, `PanicRoomPanel`, floating scenario label tooltips on chart. All other surfaces are solid. Scoped to avoid Flutter `BackdropFilter` performance penalty on mid-range Android.
- **Motion:** Default `300ms ease-out` for all state transitions. Tap feedback: scale `0.97 → 1.0` at `120ms`. No decorative animations.
- **Signature animation:** Shock chip toggle in the Panic Room triggers a dramatic Bézier crash/diverge animation. The only expressive animation in the product. If it takes more than one day to implement, simplify to `300ms` opacity + translate.
- **Dark mode is the primary design surface.** Light mode is also required and must pass WCAG AA (`4.5:1`). Deep Indigo must be lightness-adjusted in the light theme to maintain contrast.
- **Background texture:** 3–5% noise grain on dark surfaces (prevents OLED banding, reads as premium matte).
- **Component strategy:** Material 3 (heavily themed) for commodity widgets (`TextField`, `BottomSheet`, `SnackBar`, `Dialog`, `NavigationBar`). Custom primitives for signature components: `TrajectoryChart`, `EventBlock`, `ResilienceScoreDisplay`, `ShockChip`.
- **`PinEntryDialog`** is parameterised via `PinMode` enum: `PinMode.setup` (two fields + export nudge), `PinMode.entry` (one field, biometric fallback), `PinMode.webExport` (one field + ephemeral copy).

### EventBlock Interaction Model (ADR-017)

- **Tap-to-add, drag-to-reorder.** A FAB or inline `+` button triggers block creation and opens the `BlockEditor` bottom sheet immediately.
- **Drag-to-reorder:** Dragging an `EventBlock` horizontally along the timeline rail changes `startMonth`. `TrajectoryChart` animates in real time during drag.
- No block palette component. "Drag" in the PRD refers to repositioning, not drag-from-palette-to-add.

### Scaffold Cleanup (Pre-Implementation Tech Debt)

All items must be resolved before feature implementation begins:

| # | File | Action |
|---|------|--------|
| 1 | `lib/core/network/api_routes.dart` | Delete. Rotate hardcoded OpenWeatherMap API key before repo goes public. |
| 2 | `lib/core/constants/app_constants.dart` | Replace weather constants with Pulse constants. |
| 3 | `lib/core/constants/app_strings.dart` | Rename `appTitle` to `'Pulse'`. Remove weather unit strings. |
| 4 | `lib/core/constants/app_patterns.dart` | Remove `weatherIconUrl()` and CDN constants. |
| 5 | `lib/core/helper/input_helper.dart` + `input_util.dart` | Delete (weather compass logic). |
| 6 | `lib/core/helper/date_util.dart` | Remove weather/server-era date helpers. |
| 7 | `lib/core/network/` (entire dir) | Delete: `ApiService`, `LoggingInterceptor`, `CertificateReader`, `api_keys.dart`, `api_routes.dart`. |
| 8 | `lib/core/platform/network_info.dart` | Delete (`NetworkInfo` / `internet_connection_checker_plus`). |
| 9 | `pubspec.yaml` | Move `bloc_test` → `dev_dependencies`. |
| 10 | `pubspec.yaml` | **Add:** `drift: ^2.24.2`, `drift_flutter: ^0.2.4`, `sqlcipher_flutter_libs: ^0.5.24`, `sqlite3: ^2.5.7`, `path_provider`, `local_auth`, `flutter_secure_storage`, `cryptography: ^2.9.0`, `cryptography_flutter: ^2.3.4`, `uuid`, `go_router`, `drift_dev: ^2.24.2`. |
| 11 | `pubspec.yaml` | **Remove:** `dio`, `internet_connection_checker_plus`, `cached_network_image`, `json_annotation`, `json_serializable`. |

### Planned Implementation Order

| Phase | Feature | Depends on |
|-------|---------|-----------|
| 1 | Scaffold audit & cleanup (tech debt above) | — |
| 2 | Domain layer + ProjectionEngine (TDD-first) | Phase 1 |
| 3 | Sandbox (Onboarding + FinancialEvent CRUD + TimelineChart) | Phase 2 |
| 4 | Panic Room (FinancialShock injection + ResilienceScore — mobile only) | Phase 3 |
| 5 | Security layer (biometric, screen shield, `.pulse` export/import, Master PIN) | Phase 3 |
| 6 | Web build validation (IndexedDB session, `kIsWeb` banner, web-to-mobile flow) | Phases 3, 5 |

---

## Testing Decisions

### What Makes a Good Test

Tests must cover **external, observable behaviour** of a module — not its internal implementation. A test should not change when the implementation is refactored, only when the contract changes. Prefer testing the BLoC's emitted states over reaching into its private fields, and test the `ProjectionEngine` via its output `List<ProjectionNode>` rather than intermediate calculations.

### Modules to Test

| Module | Priority | Seam |
|--------|----------|------|
| **`ProjectionEngine`** (`calculate`) | P0 — TDD-first | Pure function. Input: `Scenario` + `List<FinancialShock>`. Output: `List<ProjectionNode>`. No mocks needed. |
| **`SandboxBloc`** | P0 — TDD-first | External seam: events in, states out. Use `bloc_test`'s `blocTest` harness. |
| **`PanicRoomBloc`** | P0 — TDD-first | Same `bloc_test` approach. Test shock injection results via emitted states. |
| **`ResilienceScore` formula** | P0 | Unit test the formula in isolation: known `ProjectionNode` arrays → expected score. |
| **`.pulse` serialization (V1 JSON schema)** | P1 | Round-trip test: `Scenario` + events → serialize → deserialize → equality check. |
| **PBKDF2 encryption round-trip** | P1 | Encrypt with PIN → decrypt with same PIN → plaintext equality. |
| **`DatabaseService` web/mobile branch** | P1 | Integration test via the actual GetIt setup, using the real `kIsWeb` platform. |
| **GoRouter guards** | P1 | Test that `kIsWeb` redirect on `/panic-room` routes to `/sandbox`. |

### Architecture Mandate

> No Presentation or Data layer code for a feature may be merged until its corresponding Domain use case has a passing test suite.

The Domain layer (entities, `ProjectionEngine`, use cases) is always implemented and tested first. The `lib/features` directory is currently empty — every feature starts with Domain.

### Prior Art

- `bloc_test` is already in `pubspec.yaml` (currently under `dependencies` — move to `dev_dependencies` as part of scaffold cleanup).
- The existing `lib/core/error/failure.dart` (`Failure`, `ServerFailure`, `BadFilterFailure`) follows an abstract base + Equatable pattern that the domain entities and use cases should mirror.

---

## Out of Scope

| Item | Reason |
|------|--------|
| Bank sync, SMS scraping, PDF/CSV import | Privacy constraint + Play Store policy (ADR-001, ADR-002) |
| User-defined custom Shock scenarios | 4 predefined chips deliver the core insight; user-defined shocks are a post-V1 feature |
| User accounts, cloud sync, centralized database | Violates the "zero-server, absolute privacy" guarantee (ADR-006) |
| More than 2 active Scenarios | Cognitive load ceiling; Panic Room binary comparison requires exactly 2 (ADR-008) |
| Projection beyond 36 months | Honesty constraint — self-reported input data cannot support greater precision (ADR-010) |
| Multi-currency, live investment growth models | Out of scope for V1 |
| Keyboard drag-and-drop for EventBlocks | Engineering cost disproportionate to the web build's funnel role (ADR-DS-001) |
| Screen reader narration of `TrajectoryChart` | Marked decorative for V1; meaningful narration is a post-MVP roadmap item |
| Categorised past-expense pie charts | The product is forward-looking simulation, not backward-looking accounting |
| `PlatformCapabilities` runtime abstraction over `kIsWeb` | `kIsWeb` is compile-time and tree-shaken — a runtime abstraction adds indirection for a boundary that cannot change (ADR-011) |
| Stalled database engines (Isar 3.x / 4.x) | Replaced by Drift with SQLCipher and WASM web support (ADR-018). |

---

## Further Notes

- **Domain vocabulary is canonical.** The glossary in `Context.md` defines every term used in code, UI, and tests. The term "Projected Resilience" is a UI label — never "Resilience Score". The term "FinancialEvent" is never "transaction" or "entry". The term "Scenario" is never "Plan" or "Timeline".
- **Open-source readiness is a first-class constraint.** The API key currently hardcoded in `lib/core/network/api_routes.dart` must be deleted and rotated before the repository is made public (tech debt item #1). No secrets may be committed.
- **The web build is a funnel, not the product.** Every design and implementation decision for the web Playground should be evaluated through this lens. Its job is to create user investment and then drive mobile downloads. The absence of the Panic Room and Projected Resilience Score on web is intentional and must not be "fixed."
- **The 10-Second Hook is a non-negotiable product mechanic.** No friction may be introduced before the user sees a populated trajectory chart. The Master PIN setup must remain deferred to the first database write-commit.
- **`lib/features/` is currently empty.** The scaffold is clean and ready for Phase 2 (Domain layer).
- **Database architecture:** Drift provides type-safe SQLite with SQLCipher full-disk encryption on mobile and WASM IndexedDB on web. Domain entities are clean Pure Dart objects decoupled from Drift table classes via the repository pattern (ADR-018).
