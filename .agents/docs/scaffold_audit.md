# Scaffold Audit — finance_pulse
<!-- Produced: 2026-10-17 | Auditor: Antigravity -->
<!-- Cross-referenced against: TDD, PRD, ADR-001…007 -->

---

## 1. KEPT FILES ✅

Files retained exactly as-is. No edits needed before next feature work begins.

| File | Verdict | One-line reason |
|------|---------|-----------------|
| `lib/core/bloc/bloc_events.dart` | ✅ KEEP AS-IS | Generic `FetchDataEvent` / `FetchData` with `filter` and `refresh` — architecture-neutral, reusable by any Pulse BLoC. |
| `lib/core/bloc/bloc_states.dart` | ✅ KEEP AS-IS | `FetchDataState<T>` with `Status` enum covers initial/loading/success/failure/refresh — matches TDD BLoC pattern exactly. Comment referencing "API call" is cosmetic only. |
| `lib/core/bloc/filter.dart` | ✅ KEEP AS-IS | Abstract `Filter` + `NoFilter` — domain-neutral query filter contract used by `BaseBloc.operation()`. |
| `lib/core/error/failure.dart` | ✅ KEEP AS-IS | `Failure`, `ServerFailure`, `InternetFailure`, `BadFilterFailure` — Equatable failure hierarchy. `ServerFailure` → rename mentally to `StorageFailure` when database arrives; no code change needed yet. |
| `lib/core/error/exception.dart` | ✅ KEEP AS-IS | `ServerException` + `BadFilter` exception types — generic enough for database error mapping. |
| `lib/core/usecase/usecase.dart` | ✅ KEEP AS-IS | `UseCase<Type, Params>` abstract contract + `NoParams` — matches TDD §2.2 pure-function use case pattern; `fpdart` `Either` return type is correct. |
| `lib/core/extension/string_extension.dart` | ✅ KEEP AS-IS | `.capitalizeWords()` — generic string utility, no weather content. |
| `lib/core/presentation/theme/app_theme.dart` | ✅ KEEP AS-IS | Full Material 3 `ColorScheme` (light + dark + high/medium contrast variants) backed by Google Fonts (Nunito). No weather content. Ready for Pulse palette tuning in a future polish pass. |
| `lib/core/bloc/base_bloc.dart` | ✅ KEEP AS-IS | Generic `BaseBloc<T>` wrapping fetch→fold→emit pattern. Domain-neutral. Pulse BLoCs (SandboxBloc, PanicRoomBloc) will extend this or reference its pattern. |

---

## 2. DELETED FILES 🗑️

All deleted. None left broken references in `lib/` after the `injection_container.dart` and `main.dart` stubs were rewritten.

### `lib/features/weather/` (entire folder)

| File / Path | Reason |
|-------------|--------|
| `data/datasource/weather_remote_datasource.dart` | Weather API contract — no network layer in Pulse (offline app). |
| `data/datasource_impl/weather_remote_datasource_impl.dart` | Weather API implementation — same reason. |
| `data/models/coord_model.dart` | OpenWeatherMap coordinate DTO — irrelevant. |
| `data/models/weather_model.dart` | Weather DTO — irrelevant. |
| `data/models/weather_data_model.dart` | Weather nested DTO — irrelevant. |
| `data/models/main_model.dart` | Temperature/pressure DTO — irrelevant. |
| `data/models/wind_model.dart` | Wind DTO — irrelevant. |
| `data/models/sys_model.dart` | Sunrise/sunset DTO — irrelevant. |
| `data/models/forecast_model.dart` | 5-day forecast DTO — irrelevant. |
| `data/models/forecast_data_model.dart` | Forecast list item DTO — irrelevant. |
| `data/repositories/weather_repository_impl.dart` | Weather repository with network+cache logic — no API in Pulse. |
| `domain/entities/weather.dart` | Weather entity — no relation to FinancialEvent / Scenario / ProjectionNode. |
| `domain/entities/forecast_weather.dart` | ForecastWeather entity — same reason. |
| `domain/repositories/weather_repository.dart` | Weather repository contract — no API in Pulse. |
| `domain/usecases/get_weather.dart` | Weather use case — irrelevant. |
| `domain/usecases/get_weather_forecast.dart` | Forecast use case — irrelevant. |
| `presentation/bloc/weather_bloc.dart` | Weather BLoC — weather-specific state, events, handler. |
| `presentation/bloc/weather_event.dart` | Weather events — weather-specific. |
| `presentation/bloc/weather_state.dart` | Weather states — weather-specific. |
| `presentation/bloc/forecast_weather_bloc.dart` | Forecast BLoC — weather-specific. |
| `presentation/ui/weather_page.dart` | Weather UI — weather-specific. |
| *(all other files under `features/weather/`)* | Entire folder was weather-scaffold origin; zero Pulse relevance. |

### `test/features/weather/` (entire folder)

| File / Path | Reason |
|-------------|--------|
| `utils/weather_entity_constatns.dart` | Test fixtures for deleted Weather entity. |
| `utils/weather_model_constants.dart` | Test fixtures for deleted weather DTOs. |
| `bloc/weather_bloc_test.dart` | Unit tests for deleted WeatherBloc. |
| `datasource/weather_remote_datasource_test.dart` | Tests for deleted datasource. |
| `repository/weather_repository_test.dart` | Tests for deleted repository. |

### `test/fixtures/` (entire folder)
All JSON fixtures were OpenWeatherMap API response samples — deleted with weather tests.

---

## 3. FILES NEEDING CHANGES ✏️

These files survive but need targeted edits before or during feature work.

### `lib/core/constants/app_constants.dart`
**What to change:** Delete the entire weather-specific block below and replace with Pulse constants.
```
// DELETE these groups:
// ── Network ── (connectionTimeoutMinutes, receiveTimeoutMinutes, httpStatus*)
// ── Image Sizes ── (weatherImageSize, weatherImageSmall, iconScale, iconExtension)
// ── Grid Layout ── (conditionsGrid*)
// ── Forecast ── (forecastListHeight)
// ── Progress ── (progressBarMinHeight, humidityMaxValue)
// ── Wind Direction ── (windDirectionDivider, windDirectionCount)
// ── Timestamp ── (millisecondsMultiplier)

// ADD Pulse constants (examples — finalise when features are designed):
// static const maxScenarioCount = 2;
// static const projectionMinMonths = 12;
// static const projectionMaxMonths = 36;
// static const resilienceTargetMonths = 12;
// static const pbkdf2Iterations = 100000;
// static const databaseEncryptionKeyBits = 256;
// ── Spacing (keep these — valid for any Flutter app) ──
// spacingXS…spacingXXXL  ← KEEP
// ── Font Sizes (keep) ──
// fontSizeSmall, fontSizeMedium, fontSizeLarge  ← KEEP
// ── Border Radius (keep) ──
// borderRadiusProgress  ← KEEP (rename to borderRadiusCard if desired)
```
**When:** First session that builds the Sandbox UI.

---

### `lib/core/constants/app_patterns.dart`
**What to change:**
- Delete `_iconBaseUrl`, `_iconPath`, `_iconScale`, `_iconExtension`, and `weatherIconUrl()` — OpenWeatherMap URL builder.
- Keep: `dateFormat`, `timeFormat`, `hourFormat`, `dayFormat`, `emailRegex`, `phoneRegex`, `strongPasswordRegex`, `urlRegex`, `alphabeticRegex`, `numericRegex`, `alphanumericRegex`.
- Add: `monthYearFormat` (e.g. `'MMM yyyy'`) — needed for the 12–36 month timeline axis labels.

**When:** First session that builds the timeline chart axis rendering.

---

### `lib/core/constants/app_strings.dart`
**What to change:**
- Change `appTitle = 'Flutter Demo'` → `'Pulse'`.
- Delete weather-unit strings: `degreeSymbol`, `percentSymbol`, `kmPerHour`, `milliBar`.
- Keep: `somethingWentWrong`, `noDataFound`, `serverError`, `today`, `yesterday`.
- Add Pulse-specific strings:
  - `volatileWebBannerMessage` — the volatile storage warning banner (TDD §4.1).
  - `projectedResilienceLabel` — `'Projected Resilience'` (TDD §2.1 — never call it "Resilience Score").
  - `strawmanOnboardingNotice` — the Strawman correctable-estimates disclaimer (PRD §4.1).
  - `exportPinWarning` — the one-time web export PIN warning (ADR-004).
  - `masterPinNeverStored` — copy reassuring user PIN is not stored.

**When:** Before any UI work begins (strings drive UI copy).

---

### `lib/core/helper/date_helper.dart` + `date_util.dart`
**What to change:**
- `convertServerToLocal()` — weather-era concept (server UTC→local). Irrelevant for Pulse (offline, no server). **Delete** this method from both files.
- `timeAgoSinceDate()` — weather notification date formatting. No equivalent concept in Pulse. **Delete**.
- `getFormattedDateFromTimestamp()` — used for UNIX timestamps from OpenWeatherMap. No such timestamps in Pulse. **Delete**.
- `calculateAge()` — not relevant to financial simulation. **Delete**.
- **Keep:** `getFormattedDate()`, `getDate()`, `convertDateFormat()`, `getTodayOrData()`, format accessors (`dateFormat`, `timeFormat`, `hourFormat`, `dayFormat`).
- **Add:** `getMonthYear(DateTime date)` — format a `DateTime` to `'MMM yyyy'` for chart axis labels.

**When:** When the timeline chart axis labels are implemented.

---

### `lib/core/helper/input_helper.dart` + `input_util.dart`
**What to change:**
- `windDirection(double angleInDegree)` — wind-compass conversion. **Delete entirely**. Both files become empty/unused.
- **Decision:** Either delete `input_helper.dart` and `input_util.dart` entirely, or repurpose `InputUtil` as `FinancialInputUtil` holding Pulse-specific formatters (e.g. currency formatting, resilience score clamping).

**When:** During Sandbox feature input field implementation.

---

### `lib/core/network/` (entire subdirectory)
**What to change:** **Delete the entire `network/` subdirectory** when database is wired. Contains:
- `api_keys.dart` — OpenWeatherMap query param keys. **Delete.**
- `api_routes.dart` — OpenWeatherMap base URLs + **hardcoded API key** (security risk even though app is FOSS). **Delete immediately** (see note below).
- `api_service.dart` — Dio HTTP client. Pulse is offline; no HTTP client needed. **Delete.**
- `utils/certificate_reader.dart` — loads `assets/certificate/openweather.pem`. **Delete** (no such asset file remains).
- `utils/logging_interceptor.dart` — Dio request/response logger. Pulse has no network calls. **Delete.**

> ⚠️ **Security Note:** `api_routes.dart` contains a hardcoded OpenWeatherMap API key (`c4be759d471f9674f954fcf2bbcbb4d1`). Although this is being deleted, if the repository has any git history, this key is already committed. Rotate or revoke the key at OpenWeatherMap if the repo history is ever made public.

**When:** Delete in the same session that removes `platform/network_info.dart` (below). Both depend on `dio` / `internet_connection_checker_plus`.

---

### `lib/core/platform/network_info.dart`
**What to change:**
- **Delete entirely.** `NetworkInfo` / `NetworkInfoImpl` wrap `InternetConnection` from `internet_connection_checker_plus`. Pulse is offline-first — there is no network reachability gate. Connectivity is never checked.

**When:** Same session as `network/` deletion.

---

### `lib/injection_container.dart`
**What to change:**
- Current state: clean stub (weather references removed, ready to wire Pulse features).
- **Next session rewrite:** Register `DatabaseService` (singleton), `FinancialEventRepository`, `ScenarioRepository`, then `SandboxBloc` (factory) and `PanicRoomBloc` (factory, mobile-only).
- Do **not** register `ApiService`, `Dio`, `InternetConnection`, or `NetworkInfo` — Pulse has no network layer.

**When:** Database + first feature session.

---

### `lib/main.dart`
**What to change:**
- Current state: clean stub with placeholder `Scaffold`.
- **Next session rewrite:** Add `MultiBlocProvider` at `MaterialApp` root providing `SandboxBloc`. Replace placeholder home with `GoRouter` / `AppRouter`. Add `kIsWeb` branch for volatile storage banner (TDD §4.1). Add `FlutterSecureStorage` / `FLAG_SECURE` screen-shield call on mobile (TDD §4.3).

**When:** After SandboxBloc and GoRouter are wired.

---

## 4. MISSING PACKAGES 📦

Add to `pubspec.yaml` → `dependencies:`.

| Package | Purpose | TDD / ADR Reference |
|---------|---------|---------------------|
| `drift: ^2.24.2` | Primary local database for Scenario + FinancialEvent storage | ADR-018, TDD §4.1 |
| `drift_flutter: ^0.2.4` | Flutter integration helper for Drift (paths, isolates) | ADR-018 |
| `sqlcipher_flutter_libs: ^0.5.24` | Native SQLCipher encryption binaries for iOS/Android/desktop | ADR-018 |
| `sqlite3: ^2.5.7` | Dart SQLite3 bindings | ADR-018 |
| `path_provider: ^2.x` | Resolve device document directory for DB path on mobile | TDD §4.1 |
| `local_auth: ^2.x` | Biometric authentication on foreground transitions | TDD §4.3 |
| `flutter_secure_storage: ^9.x` | Store Master PIN hash / session token; `FLAG_SECURE` on Android | TDD §4.3 |
| `cryptography: ^2.9.0` + `cryptography_flutter: ^2.3.4` | PBKDF2 (min 100,000 iterations, SHA-256) key derivation | TDD §4.2, ADR-004 |
| `uuid: ^4.x` | Generate UUID v4 for `FinancialEvent`, `Scenario`, `FinancialShock` entity IDs | TDD §2.1 |
| `go_router: ^14.x` | Declarative routing (Onboarding → Sandbox → Panic Room) | TDD §3, ADR-007 |

> 📌 **Database choice note:** Drift with `sqlcipher_flutter_libs` replaces legacy Isar per ADR-018. Web uses `drift/wasm.dart` backed by IndexedDB.

---

## 5. WHAT IS NOT NEEDED — REMOVE FROM pubspec.yaml 🗑️

These packages have zero use in an offline-first app with no API calls.

| Package | Currently In | Reason to Remove |
|---------|-------------|-----------------|
| `dio: ^5.4.3+1` | `dependencies` | HTTP client — Pulse makes no network requests. |
| `internet_connection_checker_plus: ^2.3.0` | `dependencies` | Network reachability gate — irrelevant for offline app. |
| `cached_network_image: ^3.3.1` | `dependencies` | Remote image caching — no remote images in Pulse. |
| `json_annotation: ^4.9.0` | `dependencies` | JSON serialization annotation — not used for entities; Drift uses `drift_dev`. |
| `json_serializable: ^6.8.0` | `dev_dependencies` | JSON code-gen — replaced by `drift_dev` for DB and standard Dart for `.pulse` JSON. |
| `bloc_test: ^10.0.0` | `dependencies` | ⚠️ **Wrong section** — should be `dev_dependencies`. Move it, don't delete. |

**Packages to keep:**

| Package | Reason |
|---------|--------|
| `flutter_bloc: ^9.1.1` | TDD mandates BLoC pattern. |
| `get_it: ^8.2.0` | TDD mandates DI via GetIt. |
| `fpdart: ^1.1.0` | `Either` type for use case returns (UseCase contract already uses it). |
| `equatable: ^2.0.5` | Entities and states extend `Equatable`. |
| `intl: ^0.20.2` | `DateFormat` in `DateUtil` — still needed for month/year labels on chart axis. |
| `google_fonts: ^6.2.1` | `AppTheme` uses `GoogleFonts.nunitoTextTheme()`. |
| `build_runner: ^2.4.9` | Still needed — `drift_dev` requires it. |
| `drift_dev: ^2.24.2` | Code generation for Drift database tables and queries. |
| `mockito: ^5.4.4` | Unit test mocking — keep in `dev_dependencies`. |
| `flutter_test` | Flutter test SDK — keep. |
| `flutter_lints: ^6.0.0` | Linting — keep. |

---

## 6. IMPLEMENTATION ORDER 🔢

Ordered sequence for next sessions. Each step is a discrete, reviewable unit of work.

### Step 1 — pubspec.yaml cleanup (≤30 min)
1. Remove `dio`, `internet_connection_checker_plus`, `cached_network_image`, `json_annotation`, `json_serializable`.
2. Move `bloc_test` from `dependencies` → `dev_dependencies`.
3. Add `drift`, `drift_flutter`, `sqlcipher_flutter_libs`, `sqlite3`, `path_provider`, `local_auth`, `flutter_secure_storage`, `cryptography`, `cryptography_flutter`, `uuid`, `go_router`.
4. Add `drift_dev` to `dev_dependencies`.
5. Run `flutter pub get` and confirm no version conflicts.

### Step 2 — Delete dead `lib/core/` code (≤20 min)
1. Delete `lib/core/network/` (entire subdirectory: `api_keys.dart`, `api_routes.dart`, `api_service.dart`, `utils/`).
2. Delete `lib/core/platform/network_info.dart`.
3. Delete `lib/core/helper/input_helper.dart` and `lib/core/helper/input_util.dart`.
4. Purge dead methods from `DateUtil` / `DateHelper`: `convertServerToLocal`, `timeAgoSinceDate`, `getFormattedDateFromTimestamp`, `calculateAge`.
5. Run `flutter analyze` — expect zero errors.

### Step 3 — Rewrite `lib/core/constants/` (≤30 min)
1. Replace weather constants in `app_constants.dart` with Pulse constants (see §3 above).
2. Remove `weatherIconUrl()` from `app_patterns.dart`; add `monthYearFormat`.
3. In `app_strings.dart`: rename `appTitle` → `'Pulse'`, delete weather units, add all Pulse copy strings listed in §3.

### Step 4 — Domain layer: Entities (TDD §2.1) — write tests first
For each entity (`FinancialEvent`, `Scenario`, `FinancialShock`, `ProjectionNode`, `ResilienceScore`):
1. Write entity class (plain Dart + `Equatable`, clean domain decoupled from database).
2. Write unit test asserting equality and field constraints.
3. No BLoC, no repository — domain only.

> Follow TDD: red → green → refactor. No feature code without a passing domain test.

### Step 5 — Domain layer: Use cases (TDD §2.2)
For each use case (`AddFinancialEvent`, `RemoveFinancialEvent`, `ForkScenario`, `CalculateProjection`, `CalculateResilienceScore`, `ActivateShock`):
1. Write use case class extending `UseCase<Type, Params>`.
2. Write unit test with mock repository.
3. `CalculateProjection` is a **pure function** — test it in isolation with zero mocks.

### Step 6 — Data layer: Drift database + repositories
1. Create `DatabaseService` singleton: opens DB, handles `kIsWeb` branch (WASM IndexedDB on web, SQLCipher on mobile).
2. Mobile: derive 256-bit key from Master PIN via PBKDF2 before opening Drift with SQLCipher.
3. Implement `FinancialEventRepositoryImpl` and `ScenarioRepositoryImpl` backed by Drift.
4. Write integration tests for each repository.

### Step 7 — Wire `injection_container.dart`
Register in this order:
1. `DatabaseService` (singleton, lazy/lifecycle-gated)
2. `FinancialEventRepository` (lazy singleton)
3. `ScenarioRepository` (lazy singleton)
4. `SandboxBloc` (factory)
5. `PanicRoomBloc` (factory — guard with `!kIsWeb`)

### Step 8 — Presentation: SandboxBloc + Onboarding UI
1. Implement `SandboxBloc` (events: `InitSandbox`, `AddEvent`, `UpdateEvent`, `RemoveEvent`, `ForkScenario`).
2. Implement Onboarding screen (two inputs: Current Liquid Balance + Monthly Net Income).
3. Auto-generate Strawman blocks (50/30/20 rule — ADR-003).
4. Wire `GoRouter` with routes: `/onboarding`, `/sandbox`, `/panic-room`.
5. Provide `SandboxBloc` at `MaterialApp` root via `MultiBlocProvider` in `main.dart`.

### Step 9 — Presentation: Timeline Chart (ADR-005)
1. Implement `ProjectionPainter extends CustomPainter`.
2. Wrap in `RepaintBoundary` (TDD §3.1).
3. Draw one Bezier path per `Scenario` from `Map<ScenarioId, List<ProjectionNode>>`.
4. Add legend overlay and month-axis labels.

### Step 10 — Presentation: Panic Room (mobile-only)
1. Implement `PanicRoomBloc` (events: `ActivateShock`, `DeactivateShock`).
2. Implement Shock chip UI; inject `FinancialShock` deltas into all active Scenarios simultaneously.
3. Show per-Scenario `ResilienceScore` side-by-side.
4. Gate entire screen with `!kIsWeb` check.

### Step 11 — Security layer
1. Implement biometric gate on foreground resume (TDD §4.3, `local_auth`).
2. Implement `FLAG_SECURE` / `ignoresScreenshotForRecording` screen shield.
3. Implement `.pulse` file export (mobile: Master PIN PBKDF2; web: ephemeral PIN modal — ADR-004).
4. Implement `.pulse` file import on mobile.

### Step 12 — Web build
1. Verify `kIsWeb` banner renders correctly.
2. Confirm Panic Room, Resilience Score, and biometric gate are absent from web build.
3. Verify IndexedDB persistence works within a session via Drift WASM.
4. Test ephemeral PIN export → mobile import round-trip.

---

*End of scaffold audit. Next session picks up at Step 1 (pubspec.yaml cleanup).*
