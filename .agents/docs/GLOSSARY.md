# GLOSSARY.md — Shared Language & Terminology
> Canonical glossary for the finance_pulse project. Extracted from the cross-grilled document set (Phase 1 output). Updated inline as terms are resolved.

---

## Canonical Terms

### Entities

| Term | Definition |
|---|---|
| **FinancialEvent** | A discrete, time-bounded financial occurrence. Attributes: UUID, name, polarity (income/expense), `startMonth`, `endMonth`, amount, `isBaseline` flag. |
| **Strawman Block** | A `FinancialEvent` with `isBaseline = true`. Auto-generated during onboarding using the 50/30/20 rule. Presented as a correctable estimate, not a verified fact. |
| **Scenario** | A named, independent container of `FinancialEvent` IDs. Has a UUID and a user-defined name. V1 supports a maximum of 2 active Scenarios simultaneously. |
| **Default Scenario** | The single Scenario that always exists and cannot be deleted. Created automatically at onboarding. |
| **ProjectionNode** | The mathematical output of the calculation engine for one month within one Scenario. Contains: `monthIndex`, `startingBalance`, `netCashFlow`, `endingBalance`, `activeEventIds`. |
| **FinancialShock** | An app-level (not Scenario-scoped) stress event. Contains a UUID, label, and a list of `FinancialEvent` deltas. Injected simultaneously into every active Scenario's projection engine when activated. |
| **ResilienceScore** | Alias: Projected Resilience Score. A per-Scenario computed value (0–100). Formula: `min(runwayMonths / 12, 1.0) * 100`. Labelled "Projected Resilience" in UI — never "Resilience Score". Simulation-based, not actuals-based. |
| **RunwayMonths** | The number of months until a Scenario's `ProjectionNode.endingBalance` reaches zero. Input to the ResilienceScore formula. |

### Features & Surfaces

| Term | Definition |
|---|---|
| **Sandbox** | The core simulation engine. Encompasses onboarding, FinancialEvent CRUD, ProjectionEngine, and the TimelineChart. Available on both web and mobile. |
| **Panic Room** | The stress-testing screen (mobile-only). Hosts FinancialShock injection and per-Scenario ResilienceScore comparison. Gated by `!kIsWeb`. |
| **Web Playground** | The session-scoped Flutter Web (WASM) build. State backed by IndexedDB. Treated as volatile. Excludes: Panic Room, ResilienceScore, persistent storage, biometric shielding. |
| **Billboard** | The SEO-optimized HTML/CSS marketing landing page (e.g., Framer/Next.js). Separate from the Flutter Web build. |
| **TimelineChart** | The primary visualization. A custom Bezier path painter inside a `RepaintBoundary`. Draws one distinct Bezier path per active Scenario. Bypasses widget reconciliation. |
| **A/B Scenario Forking** | Creating a second named Scenario alongside the default, displayed simultaneously on the TimelineChart for side-by-side trajectory comparison. |

### Data & Portability

| Term | Definition |
|---|---|
| **.pulse file** | The portable backup format. A PBKDF2-encrypted, serialized BLoC state (all Scenarios + FinancialEvents). |
| **Master PIN** | The user-defined PIN used to derive the PBKDF2 encryption key on mobile. Stored persistently (never in plaintext). Used to encrypt the Isar DB and all mobile `.pulse` exports. |
| **Ephemeral PIN** | A one-time PIN entered at web export time only. Not stored anywhere in the web session. Used to encrypt a web-exported `.pulse` file for mobile import. |
| **PBKDF2** | The key derivation function. Parameters: minimum 100,000 iterations, SHA-256. Implemented via `cryptography: ^2.9.0` + `cryptography_flutter: ^2.3.4`. Used for both mobile and web `.pulse` encryption. |

### Architecture & Platform

| Term | Definition |
|---|---|
| **SandboxBloc** | The primary BLoC. Manages the `Map<ScenarioId, Scenario>` and triggers ProjectionEngine recalculation on every state change. Provided at MaterialApp root. |
| **PanicRoomBloc** | Mobile-only BLoC. Manages FinancialShock activation state across all Scenarios. Registered in GetIt only when `!kIsWeb`. |
| **ProjectionEngine** | A pure function: `List<ProjectionNode> calculate(Scenario, List<FinancialShock>)`. Stateless, no side effects. Called once per active Scenario per state change. |
| **IsarService** | Singleton. Manages Isar database lifecycle. Branches on `kIsWeb` for storage strategy. Pinned to `isar: 3.1.0+1`. |
| **kIsWeb** | Flutter's compile-time platform flag. Used as a hard gate for mobile-only features (Panic Room, biometric auth, persistent PIN, `.pulse` import). |
| **Isar Web** | IndexedDB-backed Isar adapter for the web build (`isar_web`, bundled in `isar_flutter_libs`). Session-scoped. No encryption layer on web. |

### Business & Product

| Term | Definition |
|---|---|
| **Zero-server guarantee** | Core product constraint: no backend, no cloud sync, no data harvesting. The open-source codebase is the proof mechanism. |
| **10-Second Time-to-Value** | The onboarding target. User sees a populated chart within 10 seconds of opening the app, without creating an account. |
| **Anti-greed positioning** | The product's market stance: 100% free, no ads, no paywalls, open-sourced. |
| **Web-to-Mobile Funnel** | The acquisition strategy: Billboard → Web Playground → `.pulse` export → mobile app download. |
| **Lock-In Features** | Features intentionally absent from the Web Playground that only exist on mobile: Panic Room, ResilienceScore, persistent encrypted storage, biometric shielding. |

---

## Resolved Decisions (ADR Index)

| ADR | One-line summary |
|---|---|
| ADR-001 | No SMS/notification scraping — Play Store policy + OEM battery kill |
| ADR-002 | No client-side PDF/CSV parsing — brittle + violates zero-server guarantee |
| ADR-003 | Strawman onboarding — 2-input start, 50/30/20 baseline, Cunningham's Law |
| ADR-004 | PBKDF2-encrypted `.pulse` files; ephemeral PIN on web, persistent PIN on mobile |
| ADR-005 | Custom Bezier path painter on bare-metal canvas — 60–120 FPS, bypasses widget tree |
| ADR-006 | 100% FOSS, no monetization — zero server cost, auditability as product feature |
| ADR-007 | Split web: HTML billboard for SEO + Flutter WASM Playground for experience |
| ADR-008 | 2-Scenario hard cap — UX conviction; Panic Room binary narrative depends on exactly 2 |
| ADR-009 | ResilienceScore ceiling = 12 months — deliberate, anchored to emergency fund benchmark |
| ADR-010 | Projection window user-adjustable 12–36 months; 36 is a hard engine cap (accuracy + perf) |
| ADR-011 | `kIsWeb` compile-time gate for all mobile-only features — tree-shakeable, idiomatic Flutter |

---

## Resolved DEFER Items

| # | Feature | Decision | Status |
|---|---|---|---|
| D-01 | Isar version | **Pin `isar: 3.1.0+1`** — Isar 4 (`4.0.0-dev.14`) is still pre-release and stalled. Isar 3.x has confirmed web platform support. | ✅ Resolved |
| D-02 | PBKDF2 library | **`cryptography: ^2.9.0` + `cryptography_flutter: ^2.3.4`** — high-level API, actively maintained, WASM-safe, native backends (Apple CryptoKit / javax.crypto). | ✅ Resolved |
| D-03 | Web storage adapter | **`isar_web` (bundled in `isar_flutter_libs`)** — no separate adapter needed. `IsarService` branches on `kIsWeb` per TDD §4.1. | ✅ Resolved |
