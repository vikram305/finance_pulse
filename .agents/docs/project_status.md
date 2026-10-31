# Project Status — finance_pulse

Updated at the end of every feature (Phase 6, Axis 6).
Human reads this before Phase 1 to answer shared-state questions in grill-with-docs.
AI never loads this file — human references it and tells AI what's relevant.

---

## Features

### ✅ Completed
- Scaffold audit & cleanup — DONE (Issue 01: weather artefacts removed, pubspec dependencies updated for Drift/cryptography, CI passing for tests, analyze, apk, and web).
- Domain Entities & Projection Engine — DONE (Issue 02: pure Dart entities FinancialEvent, Scenario, ProjectionNode, ResilienceScore, FinancialShock, predefined shock catalogue, ProjectionEngine O(N×M) calculation engine, CalculateResilienceScore use case, 100% test coverage).
- SandboxBloc (TDD) — DONE (Issue 03: SandboxBloc, SandboxState, SandboxEvent, Strawman generation on init, Event CRUD, A/B Scenario operations with deep-copy & 2-scenario cap, projection recalculation on every state change, GetIt factory registration, 100% test coverage).
- PanicRoomBloc (TDD) — DONE (Issue 04: PanicRoomBloc, PanicRoomState, PanicRoomEvent, dynamic jobLoss construction, additive shock application without mutating Scenarios, survival months calculation, mobile-only !kIsWeb factory registration, 100% test coverage).
- DI Container & Navigation Shell — DONE (Issue 05: GetIt wiring for ProjectionEngine, SandboxBloc, mobile-only PanicRoomBloc, GoRouter config with /onboarding, /sandbox, /panic-room routes and platform/scenario guards, MaterialApp.router integration, 100% test coverage).
- Design System Foundation — DONE (Issue 06: PulseTheme dark/light Material 3 themes, ADR-DS-001 design tokens for PulseColors, PulseSpacing, PulseMotion, PulseTextStyles with Inter & JetBrains Mono, core presentation primitives PulseBottomSheet with glassmorphism, PulseEmptyState line-art, PulseTapTarget with 48x48 min bounds & hover glow, PulseWebLayout with 1200px max width and 768px breakpoint, PulseNoiseOverlay 3-5% OLED grain, 100% test coverage with WCAG AA contrast & 4 accessibility guidelines).

### 🔄 In Progress
<!-- Ready for next ticket: Issue 07 (Onboarding Screen) -->

### 📋 Planned
- Sandbox (Onboarding + FinancialEvent CRUD + ProjectionEngine + TimelineChart)
- Panic Room (FinancialShock injection + ResilienceScore — mobile only)
- Security layer (biometric gate, screen shield, `.pulse` export/import)
- Web build validation (IndexedDB session, kIsWeb banner, web-to-mobile `.pulse` flow)

---

## Shared Resources

Things built in one feature that other features can reuse.
Check this before Phase 2 to avoid duplicating contracts.

### Entities
- `FinancialEvent` (`lib/domain/entities/financial_event.dart`): UUID, name, polarity (`income`|`expense`), startMonth, endMonth, amount, isBaseline.
- `Scenario` (`lib/domain/entities/scenario.dart`): UUID, name, eventIds (ordered `List<String>`).
- `FinancialShock` (`lib/domain/entities/financial_shock.dart`): UUID/key, label, events (`List<FinancialEvent>`). Predefined catalogue in `lib/domain/constants/financial_shocks.dart`.
- `ProjectionNode` (`lib/domain/entities/projection_node.dart`): monthIndex, startingBalance, netCashFlow, endingBalance, activeEventIds.
- `ResilienceScore` (`lib/domain/entities/resilience_score.dart`): scenarioId, score (0–100) derived from runway months against a 12-month ceiling.

### BLoCs
- `SandboxBloc` (`lib/features/sandbox/presentation/bloc/sandbox_bloc.dart`): Central state machine managing active Scenarios, FinancialEvents per Scenario, and real-time ProjectionEngine recalculations. Registered as a factory in GetIt.
- `PanicRoomBloc` (`lib/features/panic_room/presentation/bloc/panic_room_bloc.dart`): Central state machine for Panic Room stress-testing, active shock management, and resilience score/survival runway calculation (mobile-only, guarded by `!kIsWeb`). Registered as a factory in GetIt.

### Routes
- `/onboarding` (`AppRoutes.onboarding`): Entry/onboarding route, loads `OnboardingScreen`. Always accessible without guards.
- `/sandbox` (`AppRoutes.sandbox`): Core sandbox simulation, loads `SandboxScreen`. Redirects to `/onboarding` if no active Scenario in `SandboxBloc.state`.
- `/panic-room` (`AppRoutes.panicRoom`): Stress-test arena, loads `PanicRoomScreen`. Mobile only — guarded by redirect to `/sandbox` on web (`kIsWeb`). Scoped `BlocProvider<PanicRoomBloc>` provisioned on route.
- `/` (`AppRoutes.root`): Default root alias; follows `/sandbox` scenario guard.

### DI Keys
- `ProjectionEngine` (lazy singleton) — pure stateless financial balance and resilience projection engine.
- `CalculateResilienceScore` (lazy singleton) — pure domain resilience score evaluation usecase.
- `SandboxBloc` (factory) — feature state machine for Scenarios & projection recalculation.
- `PanicRoomBloc` (factory, `!kIsWeb` guard) — stress-test state machine for FinancialShocks and resilience metrics.
<!-- Planned registrations (injection_container.dart):
- DatabaseService (singleton)
- FinancialEventRepository (lazy singleton)
- ScenarioRepository (lazy singleton)
-->

### Design Tokens & Primitives
- `PulseTheme` (`lib/core/presentation/theme/pulse_theme.dart`): `PulseTheme.dark()` (default), `PulseTheme.light()` with WCAG AA-adjusted indigo primary, `PulseThemeExtension` for polarity & semantic tokens.
- `PulseColors` (`lib/core/presentation/theme/pulse_colors.dart`): Primary Deep Indigo, Secondary Amber, Polarity Teal/Rose, Semantic Error/Warning/Success/Info, near-black dark surfaces, relative luminance and contrast ratio helpers.
- `PulseSpacing` (`lib/core/presentation/theme/pulse_spacing.dart`): 4px base increment (`xs = 4`, `sm = 8`, `md = 12`, `base = 16`, `lg = 24`, `xl = 32`, `xxl = 48`, `xxxl = 64`) with prebuilt `EdgeInsets` helpers.
- `PulseMotion` (`lib/core/presentation/theme/pulse_motion.dart`): `defaultDuration` (300ms), `defaultCurve` (easeOut), `tapScaleDuration` (120ms), `tapScaleValue` (0.97).
- `PulseTextStyles` (`lib/core/presentation/theme/pulse_text_styles.dart`): JetBrains Mono for financial metrics (`dataHero`, `financialValue`, `dataInline`, `financialLabel`, `dataSmall`) and Inter for UI copy (`display`, `bodyLarge`, `bodyMedium`, `bodySmall`, `labelLarge`, `labelMedium`, `labelSmall`).
- `PulseBottomSheet` (`lib/core/presentation/widgets/pulse_bottom_sheet.dart`): Glassmorphic bottom sheet primitive with `BackdropFilter` (sigma 12), 24px top radius, drag handle, and static `show()` helper.
- `PulseTapTarget` (`lib/core/presentation/widgets/pulse_tap_target.dart`): Interactive wrapper enforcing 48×48px minimum touch target, 0.97 scale animation, web hover glow, keyboard focus (Enter/Space), and semantic button annotations.
- `PulseEmptyState` (`lib/core/presentation/widgets/pulse_empty_state.dart`): Minimalist line-art vector empty state for zero-data timelines and scenarios.
- `PulseWebLayout` (`lib/core/presentation/widgets/pulse_web_layout.dart`): 1200px max width content centering with 768px responsive breakpoint.
- `PulseNoiseOverlay` (`lib/core/presentation/widgets/pulse_noise_overlay.dart`): 3%–5% noise grain texture on dark surfaces to prevent OLED banding.

### Shared Failures
<!-- Defined in lib/core/error/failure.dart — KEPT from scaffold: -->
- `Failure` (abstract base, Equatable)
- `ServerFailure` — will be repurposed as `StorageFailure` for database errors when needed
- `InternetFailure` — kept; may surface if any future connectivity check is added
- `BadFilterFailure` — kept; used by BaseBloc filter contract

---

## Tech Debt

Items logged during scaffold audit as breaking references or deliberate deferrals.

| # | File | Description | Logged |
|---|------|-------------|--------|
| 1 | `lib/core/network/api_routes.dart` | **Hardcoded OpenWeatherMap API key** in source. File is scheduled for deletion (audit Step 2). If repo history is ever made public, rotate/revoke key at OpenWeatherMap. | 2026-10-17 |
| 2 | `lib/core/constants/app_constants.dart` | ~60% of constants are weather-specific (grid, forecast, wind, humidity, timestamps). Scheduled for replacement with Pulse constants in audit Step 3. | 2026-10-17 |
| 3 | `lib/core/constants/app_strings.dart` | `appTitle = 'Flutter Demo'` — rename to `'Pulse'` in audit Step 3. Weather unit strings (`degreeSymbol`, `kmPerHour`, `milliBar`, `percentSymbol`) scheduled for removal. | 2026-10-17 |
| 4 | `lib/core/constants/app_patterns.dart` | `weatherIconUrl()` builder and associated private URL constants reference OpenWeatherMap CDN. Scheduled for removal in audit Step 3. | 2026-10-17 |
| 5 | `lib/core/helper/input_helper.dart` + `input_util.dart` | Entire content is `windDirection()` (weather compass). Scheduled for deletion or repurposing in audit Step 2. | 2026-10-17 |
| 6 | `lib/core/helper/date_util.dart` | `convertServerToLocal()`, `timeAgoSinceDate()`, `getFormattedDateFromTimestamp()`, `calculateAge()` — weather/server-era helpers with no Pulse equivalent. Scheduled for removal in audit Step 2. | 2026-10-17 |
| 7 | `lib/core/network/` (entire dir) | `ApiService` (Dio), `LoggingInterceptor`, `CertificateReader`, `api_keys.dart`, `api_routes.dart` — all network-layer files with no Pulse use. Scheduled for deletion in audit Step 2. | 2026-10-17 |
| 8 | `lib/core/platform/network_info.dart` | `NetworkInfo`/`NetworkInfoImpl` wraps `InternetConnection` from `internet_connection_checker_plus`. Offline app has no connectivity gate. Scheduled for deletion in audit Step 2. | 2026-10-17 |
| 9 | `pubspec.yaml` | `bloc_test` listed under `dependencies` instead of `dev_dependencies`. Move in audit Step 1. | 2026-10-17 |
| 10 | `pubspec.yaml` | Missing: `drift`, `drift_flutter`, `sqlcipher_flutter_libs`, `sqlite3`, `path_provider`, `local_auth`, `flutter_secure_storage`, `cryptography`, `uuid`, `go_router`, `drift_dev`. Add in audit Step 1. | 2026-10-17 |
| 11 | `pubspec.yaml` | Remove: `dio`, `internet_connection_checker_plus`, `cached_network_image`, `json_annotation`, `json_serializable`. All are network/HTTP concerns; Pulse is offline. Remove in audit Step 1. | 2026-10-17 |

---

## Active DEFER Items

Ambiguities from Phase 1 that were deferred and not yet resolved.
These become follow-up tickets when the feature they affect starts.

| Feature | DEFER Item | Reason | Status |
|---------|------------|--------|--------|
| Database choice | Migrate from stalled Isar to Drift | Isar 4 stalled in pre-release. **Adopt Drift (`drift`, `drift_flutter`, `drift_dev`)** with `sqlcipher_flutter_libs` on mobile and Drift WASM on web (ADR-018). | ✅ Resolved |
| Security | Choose PBKDF2 library: `cryptography` vs `pointycastle` | **Use `cryptography: ^2.9.0` + `cryptography_flutter: ^2.3.4`**. Higher-level API, actively maintained (Nov 2025), explicit WASM/Web Crypto API support, native backend (Apple CryptoKit / javax.crypto) via the Flutter companion package. | ✅ Resolved |
| Web build | Web database adapter | **Use Drift WASM (`drift/wasm.dart` via Web Worker)** for session-scoped IndexedDB per ADR-007 / ADR-018. | ✅ Resolved |