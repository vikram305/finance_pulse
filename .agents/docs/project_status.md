# Project Status — finance_pulse

Updated at the end of every feature (Phase 6, Axis 6).
Human reads this before Phase 1 to answer shared-state questions in grill-with-docs.
AI never loads this file — human references it and tells AI what's relevant.

---

## Features

### ✅ Completed
<!-- None yet. Scaffold cleaned. First feature: Sandbox (Onboarding + SandboxBloc). -->

### 🔄 In Progress
<!-- Scaffold audit & cleanup — DONE 2026-10-17 -->
<!-- Next: pubspec.yaml cleanup → Step 1 of scaffold_audit.md implementation order -->

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
<!-- None defined yet. Domain layer is next. -->
<!-- Planned entities (TDD §2.1):
- FinancialEvent — UUID, name, polarity, startMonth, endMonth, amount, isBaseline
- Scenario — UUID, name, List<FinancialEvent IDs>
- FinancialShock — UUID, label, List<FinancialEvent deltas>
- ProjectionNode — monthIndex, startingBalance, netCashFlow, endingBalance, activeEventIds
- ResilienceScore — scenarioId, score (0–100), computed from ProjectionNode runway
-->

### BLoCs
<!-- None provided at app level yet. -->
<!-- Planned (provided at MaterialApp root):
- SandboxBloc — manages Scenario map + ProjectionNode calculation
- PanicRoomBloc — manages FinancialShock activation across all Scenarios (mobile-only)
-->

### Routes
<!-- GoRouter not yet wired. Planned routes:
- /onboarding
- /sandbox
- /panic-room  (mobile only — kIsWeb guard)
-->

### DI Keys
<!-- GetIt locator is stubbed. No features registered yet. -->
<!-- Planned registrations (injection_container.dart):
- IsarService (singleton)
- FinancialEventRepository (lazy singleton)
- ScenarioRepository (lazy singleton)
- SandboxBloc (factory)
- PanicRoomBloc (factory, !kIsWeb guard)
-->

### Shared Failures
<!-- Defined in lib/core/error/failure.dart — KEPT from scaffold: -->
- `Failure` (abstract base, Equatable)
- `ServerFailure` — will be repurposed as `StorageFailure` for Isar errors when needed
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
| 10 | `pubspec.yaml` | Missing: `isar`, `isar_flutter_libs`, `path_provider`, `local_auth`, `flutter_secure_storage`, `cryptography`/`pointycastle`, `uuid`, `go_router`, `isar_generator`. Add in audit Step 1. | 2026-10-17 |
| 11 | `pubspec.yaml` | Remove: `dio`, `internet_connection_checker_plus`, `cached_network_image`, `json_annotation`, `json_serializable`. All are network/HTTP concerns; Pulse is offline. Remove in audit Step 1. | 2026-10-17 |

---

## Active DEFER Items

Ambiguities from Phase 1 that were deferred and not yet resolved.
These become follow-up tickets when the feature they affect starts.

| Feature | DEFER Item | Reason | Status |
|---------|------------|--------|--------|
| Isar setup | Confirm Isar 3.x vs 4.x compatibility with Flutter SDK `^3.10.8` | Isar 4 (`4.0.0-dev.14`) is still pre-release and stalled. **Pin `isar: 3.1.0+1`** — last stable, supports web platform. | ✅ Resolved |
| Security | Choose PBKDF2 library: `cryptography` vs `pointycastle` | **Use `cryptography: ^2.9.0` + `cryptography_flutter: ^2.3.4`**. Higher-level API, actively maintained (Nov 2025), explicit WASM/Web Crypto API support, native backend (Apple CryptoKit / javax.crypto) via the Flutter companion package. | ✅ Resolved |
| Web build | Decide if `isar_web` is included or if web uses a simpler in-memory + IndexedDB adapter | **Use `isar_web` (bundled in `isar_flutter_libs`)**. Isar 3.x has verified web platform support. `IsarService` branches on `kIsWeb` per TDD §4.1 — no separate adapter needed. | ✅ Resolved |