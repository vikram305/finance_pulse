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

### 🔄 In Progress
<!-- Ready for next ticket: Issue 04 (PanicRoomBloc TDD) -->

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
<!-- Planned (provided at MaterialApp root):
- PanicRoomBloc — manages FinancialShock activation across all Scenarios (mobile-only)
-->

### Routes
<!-- GoRouter not yet wired. Planned routes:
- /onboarding
- /sandbox
- /panic-room  (mobile only — kIsWeb guard)
-->

### DI Keys
- `CalculateResilienceScore` (lazy singleton) — pure domain resilience score evaluation usecase.
- `SandboxBloc` (factory) — feature state machine for Scenarios & projection recalculation.
<!-- Planned registrations (injection_container.dart):
- DatabaseService (singleton)
- FinancialEventRepository (lazy singleton)
- ScenarioRepository (lazy singleton)
- PanicRoomBloc (factory, !kIsWeb guard)
-->

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