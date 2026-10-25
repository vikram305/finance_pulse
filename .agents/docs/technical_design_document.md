# Technical Design Document (TDD)

## 1. Architectural Standards
The application will adhere strictly to Clean Architecture principles.
* **State Management:** BLoC pattern for unidirectional data flow.
* **Open Source Readiness:** The repository must isolate core architecture from sensitive build variables (API keys, build flavours). This ensures the public repository is safe to fork without leaking secrets.
* **Testing:** The Domain layer mandates Test-Driven Development (TDD) coverage before UI implementation. No Presentation or Data layer code for a feature may be merged until its corresponding Domain use case has a passing test suite.

## 2. Domain Layer & Entity Constraints

### 2.1 Core Entities

* **FinancialEvent:** Encapsulates a UUID, nomenclature, polarity (income/expense), temporal boundaries (start month, end month), an amount, and a boolean `isBaseline` flag identifying it as a permanent baseline block vs. a correctable "Strawman" estimate.

* **FinancialShock:** An app-level event (not Scenario-scoped) representing an external stress scenario (e.g., Job Loss, Medical Emergency). Encapsulates a UUID, label, and a `List<FinancialEvent>` of additive shock events. Each `FinancialEvent` in this list is a fully-formed event (with its own polarity, amount, startMonth, endMonth) representing the financial impact of the shock (e.g., `Job Loss` contains a `{polarity: expense, amount: −₹60,000, startMonth: 0, endMonth: 5}` income-loss event). When a Shock is activated, its event list is **appended to the Scenario's event list at calculation time** — the Scenario itself is never mutated. This is the mechanism that enables cross-Scenario resilience comparison in the Panic Room. **V1 scope constraint:** `FinancialShock` instances are a **predefined, hardcoded catalogue** of constants defined in the domain layer (e.g., `FinancialShocks.catalogue`). They are not stored in the database, have no repository, and are not user-editable in V1. User-defined shocks are explicitly out of scope for V1.

* **Scenario:** A named, independent container of `FinancialEvent` entities. Encapsulates a UUID, a user-defined name (e.g., "Buy a Car"), and an ordered list of `FinancialEvent` IDs. The BLoC state holds a `Map<ScenarioId, Scenario>`. At least one Scenario always exists (the default). A maximum of two active Scenarios are supported in V1. **Duplicate is a deep copy:** duplicating a Scenario generates new UUIDs for all cloned `FinancialEvent` entities; edits to either Scenario's events are fully independent. Shallow copy (shared event references) is explicitly rejected — it silently corrupts both Scenarios on edit.

* **ProjectionNode:** The mathematical output of the calculation engine for a single month within a single Scenario. Encapsulates: month index, starting balance, net cash flow (sum of all active `FinancialEvent` amounts for that month), ending balance, and the list of active `FinancialEvent` UUIDs that contributed to this node.

* **ResilienceScore:** A computed, per-Scenario value (0–100) representing projected financial resilience. It is derived purely from the Scenario's own `ProjectionNode` array (Strawman baseline as ground truth) — it is a simulation score, not an actuals-based score. The formula normalises the runway (months until the ending balance reaches zero) against a 12-month target ceiling: `score = min(runwayMonths / 12, 1.0) * 100`. This score is always labelled "Projected Resilience" in the UI — never "Resilience Score" — to signal its simulation basis to the user.

### 2.2 Calculation Engine Requirements
* **Execution & Efficiency:** The projection engine evaluates 12 to 36 months synchronously on the main thread. It must operate at `O(N × M)` complexity where N = number of months and M = number of active `FinancialEvent` entities in a Scenario. The no-jank target is the real constraint: the engine must complete a full recalculation before the next Flutter frame (≤16.6ms on a 60fps device).
* **Isolates:** Dart Isolates are **not required** for the projection math given the expected data scale (≤36 months × reasonable event count). However, if profiling on a target device shows frame drops during recalculation, migrating the engine to an Isolate is explicitly permitted and should not be treated as an architectural violation.
* **Scenario Isolation:** The engine is a pure function: `List<ProjectionNode> calculate(Scenario scenario, List<FinancialShock> activeShocks)`. It is stateless and produces no side effects. Internally, it flattens `activeShocks` into a combined event list (`scenario.events + shocks.expand((s) => s.events)`) before computing each `ProjectionNode`. The Scenario entity is never mutated. The engine is called once per active Scenario per state change, enabling parallel computation of multiple Scenario projections if needed.

### 2.3 V1 Predefined `FinancialShock` Catalogue
Four hardcoded shocks ship in V1 as constants in `lib/domain/constants/financial_shocks.dart`. Job Loss uses the user's own monthly income as the impact magnitude (relative); the remaining three use fixed amounts calibrated for urban Indian professionals aged 25–38.

| Constant | Label | Events injected | Amount logic |
|---|---|---|---|
| `FinancialShocks.jobLoss` | Job Loss | Income → ₹0 for 6 months | Relative: replaces the user's `monthlyNetIncome` with ₹0 for months 0–5 |
| `FinancialShocks.medicalEmergency` | Medical Emergency | One-time lump expense in month 1 | Fixed: ₹2,00,000 (expense, month 0 only) |
| `FinancialShocks.rentSpike` | Rent Spike | Additional monthly rent expense for full window | Fixed: +₹12,000/mo for all projection months |
| `FinancialShocks.emiShock` | EMI Shock | New recurring loan repayment | Fixed: +₹15,000/mo for 24 months (emergency personal loan) |

**Design intent:** Job Loss is relative so the shock is meaningful regardless of whether the user earns ₹40,000 or ₹2,00,000/mo. Fixed amounts for the other three are calibrated to feel impactful (not trivial) for the target demographic without being unrealistic.

**Implementation note:** Because `jobLoss` is relative, it is a **static factory method** (`FinancialShocks.jobLoss({required double monthlyNetIncome})`) that constructs the `FinancialShock` with the correct income-offset amount at call time. The other three shocks are **static final constants** — their `FinancialEvent` amounts are fixed and need no runtime input. `PanicRoomBloc` calls `FinancialShocks.jobLoss(monthlyNetIncome: state.monthlyNetIncome)` when constructing the active shock list before passing it to the `ProjectionEngine`.



## 3. Presentation Layer & Rendering Strategy

### 3.1 Web & Mobile Rendering
* **Mobile Engine:** Flutter Impeller/Skia.
* **Web Engine:** Flutter WASM (WebAssembly) for high-performance canvas painting in the browser.
* **Visualization:** The main timeline chart is encapsulated within a `RepaintBoundary`. Rendering is executed via a custom Bezier path painter that receives a `Map<ScenarioId, List<ProjectionNode>>` and draws one distinct Bezier path per Scenario in a unique colour, with a legend overlay. The painter listens directly to coordinate state changes, completely bypassing the Flutter widget reconciliation tree for smooth, consistent rendering across both active trajectories.

## 4. Security, Storage & Web Volatility

### 4.1 Storage Architecture (Mobile vs. Web)

#### Mobile (Persistent)
* Local timeline data (all Scenarios, FinancialEvents, user settings) resides in an encrypted SQLite database via Drift and `sqlcipher_flutter_libs` using a 256-bit symmetric key derived from the user's Master PIN (ADR-018). No plain-text financial integers are written to disk.
* Drift tables use relational foreign keys with `ON DELETE CASCADE` (`scenarios` and `financial_events`).

#### Web (Session-Scoped)
* The Flutter Web instance uses IndexedDB via Drift WASM (`drift/wasm.dart` in a dedicated Web Worker) for within-session persistence. This storage is treated as **volatile**: it may be wiped by browser cache clearing, private browsing mode expiry, or browser updates.
* The BLoC detects the web platform at startup (`kIsWeb`) and displays a **session-dismissible** header banner: *"Browser storage is volatile. Clear your cache and your sandbox is gone. Export your scenario or download the app to keep your data."* The banner is shown once per browser session. The user may dismiss it; dismissal state is held in memory only (not written to IndexedDB) so the banner reappears on every new session. This ensures the user is warned at least once per session without a persistent flag that would be wiped alongside the data it warns about.
* The web build does **not** maintain a persistent Master PIN. There is no database encryption layer on web. Data at rest in IndexedDB is unencrypted — this is acceptable because web storage is classified as ephemeral and users are warned accordingly.

### 4.2 Key Derivation & Backup Portability

#### Mobile Export/Import (`.pulse` files)
* The encryption key is derived from the user's persistent Master PIN via PBKDF2 (minimum 100,000 iterations, SHA-256).
* Exported `.pulse` files encapsulate the serialized BLoC state (all Scenarios, all FinancialEvents) encrypted symmetrically with this key. The user can import any `.pulse` file on any new device by entering their Master PIN.

#### Web Export (Ephemeral `.pulse` files)
* When a web user opts to export, the app presents a modal prompting them to create a one-time export PIN. This PIN is **not stored** anywhere in the web session.
* The app derives an encryption key from this PIN via PBKDF2 (same parameters as mobile), encrypts the serialized BLoC state, and triggers a browser download of the `.pulse` file.
* The modal includes explicit copy: *"Choose a PIN you'll remember — you'll need to enter it when importing on the mobile app. There is no recovery if you forget it."*
* On the mobile app, the user selects "Import `.pulse` file" and enters the same PIN used at web export time. The mobile app derives the decryption key via PBKDF2 and populates the Drift database. After a successful import, the user is prompted to set (or change) their persistent Master PIN for ongoing mobile use.

### 4.3 Presentation Shielding (Native Only)
* UI is natively obscured upon transitioning to the OS background (`FlutterSecureStorage` / `FLAG_SECURE` on Android; `ignoresScreenshotForRecording` on iOS).
* Foreground transitions are gated by device-native biometric authentication (`local_auth`). This feature does not exist on the web build.