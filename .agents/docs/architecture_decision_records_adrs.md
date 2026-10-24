# Architecture Decision Records (ADRs)

### ADR-001: Rejection of Automated SMS and Notification Scraping
* **Context:** The initial concept relied on automatically calculating a user's financial baseline by reading bank transaction SMS alerts or intercepting push notifications.
* **Decision:** Strictly rejected for V1.
* **Rationale:** Google Play Store policies explicitly forbid `READ_SMS` for financial tracking apps. While `NotificationListenerService` bypasses this, OEM battery management aggressively terminates background listeners, leading to missed transactions. Maintaining custom regex parsers introduces massive technical debt.

### ADR-002: Rejection of Client-Side Statement Parsing (PDF/CSV)
* **Context:** Explored allowing users to manually upload historical bank statements.
* **Decision:** Rejected for V1.
* **Rationale:** Indian banking apps predominantly generate PDFs. Extracting tabular data from PDFs client-side is highly brittle. Routing documents to a cloud parser violates the app's core "zero-server, absolute privacy" guarantee.

### ADR-003: Selection of "Strawman Onboarding"
* **Context:** Needed a frictionless method to acquire baseline expense data.
* **Decision:** The onboarding flow will ask for only two inputs (Current Liquid Balance and Monthly Net Income), immediately generating a "Strawman" trajectory utilizing the 50/30/20 budget rule.
* **Rationale:** Leverages Cunningham's Law. Users experience extreme drop-off with blank forms. By presenting an instantly generated, slightly inaccurate chart, users are psychologically compelled to correct it, achieving a sub-10-second Time-to-Value.

### ADR-004: Decoupled Master PIN Encryption
* **Context:** Required a secure backup mechanism that survives physical device loss without a centralized backend. A secondary constraint emerged: the Flutter Web Playground must be able to produce a portable `.pulse` file for import into the native mobile app, despite having no persistent storage of its own.
* **Decision:** Backup payloads are encrypted using a key derived from a user-defined Master PIN via PBKDF2. Two distinct flows are defined for mobile and web:
  * **Mobile (Persistent PIN):** The user sets their Master PIN once during onboarding. The PBKDF2-derived key is used to encrypt the Isar database and all exported `.pulse` files. The PIN is never stored in plaintext.
  * **Web (Ephemeral PIN):** When a web user chooses to export their session, the app prompts them to enter a one-time PIN. This PIN is used ephemerally — PBKDF2 derives the encryption key, the `.pulse` file is encrypted and downloaded, and the PIN is immediately discarded. The web session holds no persistent PIN. The user must enter the same PIN on the mobile app to import the file.
* **Rationale:** Binding the backup to a hardware Keystore key makes recovery impossible if the device is destroyed. A user-held PIN ensures the encrypted file is portable to any new device. The ephemeral web PIN flow preserves the "zero-server, absolute privacy" guarantee while enabling the web-to-mobile continuity story. The user is explicitly warned at export time: "Choose a PIN you'll remember — you'll need it to import on mobile."

### ADR-005: Bare-Metal Canvas Rendering over Charting Libraries
* **Context:** The sandbox requires a visual chart that redraws instantly as the user drags input sliders, and must render multiple scenario trajectories simultaneously for A/B forking.
* **Decision:** The primary visualization will utilize a custom path painter wrapped in a repaint boundary. The painter is responsible for drawing multiple named Bezier paths (one per active Scenario) on a single canvas.
* **Rationale:** Third-party charting libraries carry significant overhead that triggers widget tree rebuilds. A custom painter bypasses the widget reconciliation phase entirely, painting directly to the GPU to guarantee 60-120 FPS. This also gives full control over multi-trajectory rendering, which no off-the-shelf charting library supports out of the box for this use case.

### ADR-006: 100% Free and Open Source Business Model
* **Context:** Evaluated monetization strategies (₹9 upfront, Monthly Subscriptions, Freemium).
* **Decision:** The app will be 100% free with no ads, no paywalls, and open-sourced on GitHub.
* **Rationale:**
  1. **Zero server costs make subscriptions unviable.** The app is entirely offline. There is no infrastructure to fund. Charging for a zero-marginal-cost product creates friction with no operational justification.
  2. **Public auditability is a product feature.** The core value proposition is "no data harvesting." Open-sourcing the codebase allows any user to verify this claim themselves. The absence of a server is provable by reading the code. This transforms the open-source model from a marketing stance into a trust mechanism.
  3. **Portfolio leverage.** A high-quality, publicly visible Flutter codebase serves as a high-signal career artifact for the primary developer.
* **Note:** Community contributions (e.g., localized data-ingestion plugins) are a possible future benefit of open-sourcing, but are not a design constraint for V1 and should not be treated as a commitment.

### ADR-007: Split Web Strategy (Marketing vs. Application)
* **Context:** Required a web presence for discoverability and user onboarding.
* **Decision:** The marketing landing page will be built in HTML/CSS (e.g., Framer/Next.js). The actual app will be compiled to Flutter Web (WASM) as a session-scoped "Playground" linked from the marketing page.
* **Web Playground Scope Boundary:** The web build is intentionally sandboxed. It provides session-scoped state (data persists within an IndexedDB-backed session, but is not guaranteed to survive browser cache clearing). It does **not** include: the Panic Room, the Projected Resilience Score, or biometric/presentation shielding — these are mobile-exclusive features and serve as the primary lock-in driving app downloads. The web experience concludes with a prompt to export a `.pulse` file (see ADR-004) and download the native app.
* **Rationale:** Flutter Web renders a single canvas, making it invisible to Google SEO crawlers. Separating the SEO-optimized HTML billboard from the Flutter WASM engine ensures discoverability while providing a zero-friction "Try it Now" web funnel that ultimately drives mobile downloads for secure, persistent storage and the full feature set.

### ADR-008: Hard Cap of Two Active Scenarios in V1
* **Context:** The `TimelineChart` painter and `SandboxBloc` state (`Map<ScenarioId, Scenario>`) are architecturally unbounded — the data model supports any number of Scenarios. A product decision was needed on how many to expose in V1.
* **Decision:** V1 supports a maximum of **two** active Scenarios simultaneously. This cap is enforced in `SandboxBloc` (reject a "Fork Scenario" event if the map already contains 2 entries). It is a hard product wall, not a temporary scaffold default.
* **Rationale:**
  1. **Cognitive load ceiling.** Two Bezier trajectory lines is the maximum a human can meaningfully compare on a single chart canvas. A third trajectory introduces visual noise that degrades the insight the chart is designed to deliver.
  2. **Panic Room narrative dependency.** The Panic Room's core UX is a binary resilience comparison: *"Scenario A: 34 | Scenario B: 71."* This side-by-side diagnostic only works cleanly with exactly two Scenarios. Allowing three or more would require a redesign of the Panic Room layout and scoring display — a scope expansion unjustified for V1.
  3. **The data model remains unbounded.** Because the cap is enforced in BLoC logic only, lifting it in a future version requires no entity or storage changes — only a revised BLoC guard and updated Panic Room UI.

### ADR-009: ResilienceScore Formula and 12-Month Runway Ceiling
* **Context:** The Panic Room displays a per-Scenario "Projected Resilience" score (0–100) computed from the Scenario's own `ProjectionNode` array. A formula and ceiling had to be chosen that was simple, defensible, and anchored to a recognisable financial benchmark.
* **Decision:** The formula is `score = min(runwayMonths / 12, 1.0) * 100`. The ceiling is **12 months**. Any Scenario with ≥12 months of runway scores 100. The score is always labelled **"Projected Resilience"** in the UI — never "Resilience Score" — to signal its simulation basis.
* **Rationale:**
  1. **12 months is an industry-standard benchmark.** Personal finance convention defines a "fully funded emergency fund" as 3–12 months of expenses. A 12-month runway is widely understood as the ceiling of financial resilience for an individual. Scores above this ceiling provide diminishing informational value.
  2. **The score is a signal, not a precision metric.** The input data is self-reported and Strawman-corrected, not verified actuals. Differentiating between a 14-month and a 20-month runway with false precision would misrepresent the simulation's accuracy. The ceiling keeps the score honest.
  3. **The "Projected Resilience" label carries the caveat.** By never calling it a "Resilience Score," the UI already signals to users that this is a simulation output, not a certified financial rating. A non-linear or extended scale would imply a precision the underlying data cannot support.

### ADR-010: Projection Window — User-Adjustable 12–36 Months with Hard Engine Cap
* **Context:** The `ProjectionEngine` must define a time horizon for how many months it calculates. The TDD specifies a 12–36 month range but did not document whether this is a fixed display window or user-controlled, or why 36 months is the upper bound.
* **Decision:** The projection window is **user-adjustable** between 12 and 36 months (e.g., via a toggle or segmented control: 1 yr / 2 yr / 3 yr). The default is **12 months**. The engine hard-caps at **36 months** — it will never calculate beyond this regardless of user input.
* **Rationale:**
  1. **Accuracy over completeness.** The engine's input data is self-reported and Strawman-corrected, not derived from verified actuals. Projecting beyond 36 months on this data implies a precision that does not exist. The 36-month cap is an honesty constraint: the app should not present 5-year trajectories as credible when its inputs are estimates.
  2. **User agency within the honest range.** Within 1–3 years, the simulation remains useful for planning major life transitions (weddings, car purchases, city relocations). Letting users extend to 24 or 36 months serves the stated use cases without misrepresenting accuracy.
  3. **Performance as a secondary backstop.** The `O(N × M)` engine (N = months, M = active FinancialEvents) must complete within 16.6ms on a 60fps device. At 36 months with a reasonable event count, this target is achievable without Isolates. Beyond 36 months this assumption requires re-validation — making the cap doubly justified.

### ADR-011: `kIsWeb` as the Compile-Time Feature Gate for Mobile-Only Features
* **Context:** Several features are permanently mobile-only (Panic Room, biometric authentication, persistent Master PIN, `.pulse` import, Isar encryption). A gating mechanism was needed to exclude these from the Flutter Web build. Two approaches were evaluated: Flutter's built-in compile-time constant `kIsWeb`, and a runtime `PlatformCapabilities` abstraction injected via GetIt.
* **Decision:** All mobile-only feature gates use **`kIsWeb` directly** — in BLoC guards (e.g., reject `ForkScenario` events in `PanicRoomBloc` registration), widget-tree conditionals, and GetIt registration guards (`if (!kIsWeb)`). No `PlatformCapabilities` abstraction is introduced.
* **Rationale:**
  1. **The web/mobile split is permanent, not a runtime toggle.** `kIsWeb` is resolved at compile time by the Flutter toolchain. A web build will never gain a Panic Room at runtime; the split is architectural. A runtime abstraction would add indirection for a boundary that cannot change.
  2. **Tree-shaking.** Because `kIsWeb` is a compile-time constant, the Flutter compiler eliminates dead branches entirely from each platform build. Mobile-only code paths are literally absent from the web bundle, and vice versa. A runtime interface cannot guarantee this.
  3. **`kIsWeb` is an established Flutter idiom.** It is the canonical mechanism used by the Flutter SDK itself and the broader ecosystem for platform-conditional logic. Introducing a bespoke abstraction on top of it would surprise contributors reading an open-source codebase.
  4. **Unit test coverage is not lost.** The `ProjectionEngine` and core BLoC logic are pure functions testable without platform context. Platform-gated registration guards in `injection_container.dart` are integration-tested via the actual GetIt setup, not mocked.

### ADR-014: Isar as the Local Database
* **Context:** An offline-first app with encrypted persistent storage and a session-scoped web build requires a local database that satisfies three simultaneous constraints: (1) native Flutter support with encryption hooks, (2) web platform compatibility without a separate adapter, and (3) FOSS licensing compatible with open-sourcing the codebase. Four options were evaluated: Isar, drift (SQLite + SQLCipher), Hive, and ObjectBox.
* **Decision:** **Isar 3.1.0+1** (pinned stable release) is the local database for both the mobile and web builds.
* **Rationale:**
  1. **Web platform support (isar_web).** `isar_web` is bundled inside `isar_flutter_libs`. The same `IsarService` code runs on web (IndexedDB-backed, unencrypted) and mobile (file-backed, encrypted) via a single `kIsWeb` branch — no separate adapter or package. drift has no first-class web story; Hive's web support is partial; ObjectBox has no web support at all.
  2. **Built-in encryption integration.** Isar's encryption key is passed directly at database-open time via the `encryptionKey` parameter — no plugin glue, no SQLCipher linking step. This makes the mobile encrypted storage path straightforward and audit-friendly for an open-source codebase.
  3. **Flutter-native API.** Isar is designed from the ground up for Flutter/Dart. Its code-generation model (`isar_generator`), typed query builder, and reactive watchers are idiomatic Dart. drift's type-safe DSL requires SQL knowledge to use effectively; Hive's box model is too flat for the Scenario/FinancialEvent relational structure; ObjectBox's core is closed-source, introducing licensing uncertainty for a FOSS project.
* **Consequences:** The project is pinned to Isar 3.x. Isar 4.x is pre-release and stalled as of the decision date (`4.0.0-dev.14`). If Isar 4 reaches stable or if the project is abandoned, migration to drift remains feasible — the domain entities are clean Pure Dart objects decoupled from Isar annotations via the repository pattern.


### ADR-015: UTF-8 JSON as the `.pulse` File Serialization Format
* **Context:** The web export → mobile import flow (the core acquisition funnel) requires a cross-platform serialization contract. The `.pulse` file encapsulates the full BLoC state (all Scenarios + FinancialEvents) before PBKDF2 encryption. Three options were evaluated: (A) UTF-8 JSON, (B) MessagePack binary, (C) Isar's native JSON export.
* **Decision:** The `.pulse` payload is serialized as **UTF-8 JSON** before encryption. The top-level envelope includes a mandatory `"version"` integer field (starting at `1`) alongside the Scenario and FinancialEvent payloads. The JSON schema is defined independently of the Isar entity schema.
* **Rationale:**
  1. **Schema decoupling.** Tying the portable format to the Isar entity schema (Option C) would mean any future entity refactor silently breaks old `.pulse` files. A dedicated JSON schema evolves independently — the importer can handle version migrations explicitly.
  2. **Forward compatibility at zero cost.** The `"version"` field enables the mobile importer to detect schema version and apply migration logic in V2+ without breaking V1-exported files.
  3. **Debug transparency.** During development, the unencrypted payload can be inspected as plain text. A binary format (Option B) requires dedicated tooling to debug cross-platform import failures — a meaningful cost on an open-source project.
  4. **No additional dependency.** JSON is available in `dart:convert`. MessagePack (Option B) would require `messagepack_dart` for marginal size savings on a file exported infrequently.
* **Schema envelope (V1):**
  ```json
  {
    "version": 1,
    "exportedAt": "<ISO-8601 timestamp>",
    "scenarios": [ { "id": "...", "name": "...", "eventIds": ["..."] } ],
    "events": [ { "id": "...", "name": "...", "polarity": "expense|income", "startMonth": 0, "endMonth": 11, "amount": 15000.0, "isBaseline": false } ]
  }
  ```

### ADR-016: Mobile Master PIN — Setup Timing, Biometric Fallback, and Recovery Policy
* **Context:** ADR-004 defines the Master PIN as the PBKDF2 input for mobile Isar encryption and `.pulse` exports, and states it is set "once during onboarding." Three sub-decisions were unspecified: (1) the exact moment PIN setup is triggered relative to the 10-Second Hook, (2) the fallback path when biometric authentication fails, and (3) the recovery policy if the user forgets their PIN.
* **Decision:**
  1. **PIN setup timing — Deferred to first Isar write-commit.** The Master PIN is not collected during the 10-Second Hook. The user experiences onboarding uninterrupted (entering Liquid Balance + Monthly Net Income → Strawman Scenario → live chart). PIN setup is triggered immediately before the first `Scenario` is persisted to Isar — at the point the user's data has value and they are already invested. No financial data is ever written to Isar without a PIN; the encryption key is derived before the first write, not applied retroactively.
  2. **Biometric gate fallback — Fall back to Master PIN.** If `local_auth` biometric authentication fails (degraded hardware, too many failed attempts, biometric not enrolled), the UI falls back to a Master PIN entry prompt. The PIN is the ultimate backstop. Biometric is a convenience layer, not the gate itself.
  3. **Recovery policy — PIN change via old PIN + export nudge (no server recovery).** The user may change their Master PIN at any time by entering their current PIN first. If they forget the current PIN entirely, there is no server-side recovery — the user must wipe and reinstall the app. To mitigate catastrophic data loss, the PIN setup screen includes a prominent, persistent nudge: *"Export a backup now. If you ever forget this PIN or get a new device, your `.pulse` file is the only way to recover your data."* This is user-managed recovery, not a backdoor.
* **Rationale:**
  1. **Timing preserves the 10-Second Hook.** Inserting PIN setup before the sandbox experience adds friction at the worst possible moment — before the user has seen any value. Deferring it to first-write captures users at peak investment.
  2. **Biometric fallback prevents catastrophic lockout.** A hard biometric gate (no fallback) would permanently lock users with degraded or unavailable biometric hardware out of their encrypted data. The Master PIN is already the root key — making it the fallback is architecturally consistent, not a security downgrade.
  3. **Export nudge is the privacy-preserving escape hatch.** A server recovery mechanism requires a server, which violates the "zero-server, absolute privacy" guarantee. The `.pulse` export flow already exists (ADR-004, ADR-015). Directing users to it immediately after PIN setup converts an existing feature into a recovery path at zero additional implementation cost.

### ADR-017: EventBlock Interaction Model — Tap-to-Add, Drag-to-Reorder
* **Context:** The PRD (§4.2) states "User drags a new Event Block onto their timeline." The Design System (ADR-DS-001) lists `EventBlock` as "Draggable/tappable timeline card" and `BlockEditor` as "Bottom sheet for block params." These descriptions implied two possible models: (A) drag as the primary *add* mechanic requiring a source palette, or (B) drag as a *reposition* mechanic after a block is added by tap.
* **Decision:** **Tap-to-add; drag-to-reorder.**
  * A floating action button (or inline `+` button) triggers block creation and immediately opens the `BlockEditor` bottom sheet for parameter entry (Name, Amount, Polarity, Start Month, Duration).
  * Once created, an `EventBlock` card can be **dragged horizontally along the timeline rail** to change its `startMonth`. The `TrajectoryChart` animates in real time as the block is dragged — this is the kinetic feedback mechanic the PRD describes.
  * "Drag" in the PRD refers to drag-to-reorder, not drag-from-palette-to-add. No block palette component is introduced.
* **Rationale:**
  1. **Consistent with the existing component inventory.** `BlockEditor` as a bottom sheet is purpose-built for block parameter entry. A drag-to-add palette would require a new component undefined in the Design System, adding scope with no additional insight for the user.
  2. **Achieves the PRD's kinetic feedback intent.** The real-time chart animation on drag-to-reorder delivers the *"chart animates to the new trajectory instantly"* experience the PRD describes — the user feels the chart responding to their hands.
  3. **Simpler implementation path.** Drag-from-palette requires drop-zone hit detection on the timeline grid. Drag-to-reorder requires only a `GestureDetector` on the `EventBlock` card updating `startMonth` on each drag delta — straightforward with Flutter's gesture system.

### ADR-012: GoRouter as the Navigation Library
* **Context:** The app has three named routes (`/onboarding`, `/sandbox`, `/panic-room`) with a platform-conditional guard (`/panic-room` is mobile-only). A routing library was needed that supports deep-link-ready declarative routing, `kIsWeb`-aware redirect guards, and is compatible with the BLoC state management pattern.
* **Decision:** **`go_router`** (the Flutter team's official routing package) is used for all navigation.
* **Rationale:**
  1. **Official Flutter team ownership.** `go_router` is maintained by the Flutter team and is the package recommended in the official Flutter docs for declarative routing. For an open-source project, this minimises the risk of the library being abandoned.
  2. **Declarative redirect guards.** GoRouter's `redirect` callback is the cleanest mechanism to implement the `kIsWeb` guard on `/panic-room` — if `kIsWeb` is true, redirect to `/sandbox`. This is a compile-time constant check in a declarative route configuration, not imperative navigation logic scattered across widgets.
  3. **Deep link readiness.** GoRouter's URL-based routing means the web build (`/sandbox`, `/onboarding`) produces navigable URLs — relevant for the Web Playground where browser history and sharing work as expected.
  4. **BLoC compatibility.** GoRouter's `refreshListenable` accepts a `ValueNotifier` or `ChangeNotifier`, enabling route refresh on BLoC state changes (e.g., redirecting to `/onboarding` if no Scenario exists) without coupling routing to widget trees.

### ADR-013: GetIt as the Dependency Injection Container
* **Context:** Clean Architecture requires injecting repositories, services, and BLoCs from the composition root (`injection_container.dart`) without coupling layers together. Three approaches were evaluated: GetIt (service locator), Riverpod (compile-time safe DI + state), and Provider (widget-tree DI).
* **Decision:** **`get_it`** is used as the dependency injection container. BLoCs are provided to the widget tree via `flutter_bloc`'s `BlocProvider`, not via GetIt directly.
* **Rationale:**
  1. **Separation of DI from state management.** GetIt manages the construction and lifetime of repositories and services (singletons, lazy singletons). BLoC state is managed by `flutter_bloc`. Mixing DI and state management (as Riverpod does) creates a tighter coupling that is harder to test in isolation.
  2. **`kIsWeb` registration guards.** GetIt's registration API allows `if (!kIsWeb)` guards at registration time — `PanicRoomBloc` and `IsarService` (encrypted variant) are only registered on mobile. This is the most direct implementation of ADR-011's `kIsWeb` gating strategy.
  3. **Established Clean Architecture idiom.** GetIt + flutter_bloc is the dominant pattern in Flutter Clean Architecture repositories and tutorials. Open-source contributors will recognise it immediately; a bespoke Riverpod architecture would require orientation.
  4. **No widget tree pollution.** GetIt resolves dependencies outside the widget tree. This means `ProjectionEngine` use cases and repositories can be instantiated and tested without a widget test harness — consistent with the TDD mandate for the Domain layer.