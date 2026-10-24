# Flutter TDD Rules

Loaded into AI context alongside Matt's /tdd and /implement-spec.
Rules only — no examples. Examples are in flutter-tdd-patterns.md (human reference).

---

## Entity
- Test equality behaviour — never test Equatable props directly
- One inequality test per field

## Mapper
- Assert the whole output entity — never individual fields
- Static methods only, Model → Entity direction only

## Model
- Round-trip test against fixture (test/fixtures/<feature>.json)
- fromJson + toJson both required — assert whole model not individual fields
- Run build_runner before running model tests

## DataSource
- Three tests always: 200 success → correct model, DioException → ServerException, non-200 → ServerException
- Throws ServerException — never returns null, never catches internally

## Repository
- Use runTestsOnline / runTestsOffline helpers
- Online: Right(entity) on success, Left(ServerFailure) on ServerException
- Offline: Left(InternetFailure) + verifyNever on datasource — mandatory, not optional
- Assert entity not model in Right()

## UseCase
- Three tests: Right passes through, Left(ServerFailure) passes through, Left(InternetFailure) passes through
- "passes through unchanged" — use that phrase in test name, it's a contract not an implementation detail

## BLoC
- One scenario per blocTest — never two events in one test
- Assert every emitted state in order — never just the final state
- Seed state before all refresh tests
- Required scenarios:
    [loading, success]
    [loading, failure] — ServerFailure
    [loading, failure] — InternetFailure
    [refresh, success] — data present in refresh state
    [refresh, refreshFailure] — data preserved on fail
    [failure] — BadFilterFailure on wrong filter type

## Widget
- buildSubject() wraps in BlocProvider with mock + real AppTheme.light — never ThemeData()
- One testWidgets per state: initial, loading, success, empty, failure, refresh, refreshFailure
- Failure test: assert AppStrings error is present AND assert raw exception text is absent
- Empty state is a separate test from failure — do not combine
- Interactions: pull-to-refresh → FetchData(refresh:true), retry tap → FetchData
- Four accessibility tests run in success state:
    androidTapTargetGuideline, iOSTapTargetGuideline,
    labeledTapTargetGuideline, textContrastGuideline

## Coverage Contract
Before reporting a layer complete, every item below must be ✓.

Entity:     equality ✓   per-field inequality ✓
Mapper:     full entity ✓   different model ✓
Model:      fromJson ✓   toJson ✓
DataSource: 200 ✓   DioException ✓   non-200 ✓
Repo:       Right(entity) ✓   Left(ServerFailure) ✓   Left(InternetFailure) ✓   verifyNever ✓
UseCase:    Right ✓   Left(ServerFailure) ✓   Left(InternetFailure) ✓
BLoC:       all 6 scenarios ✓
Widget:     all 7 states ✓   interactions ✓   4 accessibility guidelines ✓

A ✗ is a blocking issue — not a note. Fix before reporting complete.