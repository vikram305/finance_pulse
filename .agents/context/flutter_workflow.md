# Flutter Feature Workflow

Single reference for the complete pipeline — from feature request to merged PR.

---

## File Roles

```
Loaded into AI context                 Human reference only — never load into AI
──────────────────────                 ────────────────────────────────────────
FLUTTER_ARCH.md                        flutter-workflow.md   (this file)
FLUTTER_STANDARDS.md                   flutter-tdd-patterns.md
CONTEXT.md
flutter-tdd-rules.md
gate documents (.ai/gates/*.md)
```

## Skill Map

```
Matt's generic skills          Flutter binding (.ai/ folder)
─────────────────────          ──────────────────────────────
/grill-with-docs               (nothing — feature description only)
/to-tickets                    (nothing)
/implement-spec      ←── fed ── flutter-tdd-rules.md
/tdd                 ←── fed ── flutter-tdd-rules.md
/code-review         ←── fed ── FLUTTER_ARCH.md
                                FLUTTER_STANDARDS.md
                                flutter-tdd-rules.md (coverage contract)
```

Matt's skills handle how to think.
Flutter binding handles what Flutter looks like.
Never rewrite Matt's logic into Flutter files.

---

## Session Strategy

Phases 1–3 and Phase 6 are always manual — human judgment required at every gate.
Phase 4 (implementation) can be orchestrated on Claude Code using the Task tool.

```
Phase 1   /grill-with-docs       manual session
Phase 2   /to-tickets            manual session
Phase 3   /implement-spec        manual session
──── spec approved ──────────────────────────────────────────
Phase 4a  /tdd — Domain          Claude Code subagent  OR  manual session
Phase 4b  /tdd — Data            Claude Code subagent  OR  manual session
Phase 4c  /tdd — BLoC            Claude Code subagent  OR  manual session
Phase 4d  /tdd — Widget          Claude Code subagent  OR  manual session
Phase 4e  DI registration        Claude Code subagent  OR  manual session
──── all layers complete ────────────────────────────────────
Phase 5   Full test run          any session
Phase 6   /code-review           manual session
```

On Claude.ai (chat only): use manual sessions for every phase.
On Claude Code: use subagents for Phase 4 only — orchestrator passes gate docs, never full transcripts.

---

## Gate Documents

Each phase produces a gate document — a small structured file saved to .ai/gates/.
The next session loads only its gate document + binding files. Never a full transcript.

```
.ai/gates/
├── phase1-gate.md    answered ambiguities
├── phase2-gate.md    4 approved tickets
├── phase3-gate.md    approved spec (typed Dart pseudocode)
├── phase4a-gate.md   domain coverage contract ✓
├── phase4b-gate.md   data coverage contract ✓
├── phase4c-gate.md   BLoC coverage contract ✓
├── phase4d-gate.md   widget coverage contract ✓
└── phase4e-gate.md   DI registration confirmed ✓
```

Gate documents are also your recovery point.
If anything fails mid-feature, restart from the last gate — never from scratch.

---

## Full Pipeline

```
                    feature description
                          │
                          ▼
          ┌───────────────────────────────┐
          │  Phase 1   Requirements       │  manual
          │  /grill-with-docs             │
          │  GATE: all ambiguities        │
          │  answered → phase1-gate.md    │
          └──────────────┬────────────────┘
                         │ ✓
                          ▼
          ┌───────────────────────────────┐
          │  Phase 2   Tickets            │  manual
          │  /to-tickets                  │
          │  GATE: 4 tickets approved     │
          │  → phase2-gate.md             │
          └──────────────┬────────────────┘
                         │ ✓
                          ▼
          ┌───────────────────────────────┐
          │  Phase 3   Spec               │  manual
          │  /implement-spec              │
          │  load: flutter-tdd-patterns   │
          │  GATE: spec approved          │
          │  → phase3-gate.md             │
          └──────────────┬────────────────┘
                         │ ✓
                          ▼
          ┌───────────────────────────────┐
          │  Phase 4   Implementation     │  subagent / manual
          │  4a Domain  4b Data           │
          │  4c BLoC    4d Widget         │
          │  4e DI                        │
          │  GATE per layer: coverage ✓   │
          └──────────────┬────────────────┘
                         │ all layers ✓
                          ▼
          ┌───────────────────────────────┐
          │  Phase 5   Full Test Run      │
          │  GATE: 100% passing           │
          └──────────────┬────────────────┘
                         │ ✓
                          ▼
          ┌───────────────────────────────┐
          │  Phase 6   Code Review        │  manual
          │  /code-review                 │
          │  6 axes — all must pass       │
          │  GATE: 6/6 green = PR ready   │
          └───────────────────────────────┘
```

---

## Phase 1 — Requirements

**Call:** `/grill-with-docs`
**Load:** nothing — feature description only

FLUTTER_ARCH.md and FLUTTER_STANDARDS.md already decided the tech stack.
Loading them here re-litigates settled decisions on every feature.

Exception: if the feature introduces something the architecture doesn't cover
(caching, WebSockets, a third-party SDK), the human flags it and loads only
the relevant file for that specific question.

Interrogate across four lenses:

```
[DOMAIN]
  - What entities are needed? Do any exist in a completed feature?
  - What are the exact failure cases? (network, empty, invalid, auth)
  - Is this one use case or several? Where are the boundaries?
  - Is any business rule ambiguous or missing from the description?

[DATA]
  - What API endpoints are required? Are they documented?
  - What is the exact response shape? Are field names confirmed?
  - Does any field need transformation before mapping to entity?
  - Pagination, caching, or staleness requirements?
  - Does the endpoint require auth headers?

[PRESENTATION]
  - What states must the UI handle?
    (initial, loading, empty, success, failure, refresh, refreshFailure)
  - What user actions trigger what events?
  - New routes or navigation requirements?
  - Edge cases not described?
    (empty list, single item, max text length, offline banner)

[CROSS-CUTTING]
  - Shared state with any existing feature?
  - Auth or permissions required?
  - Does this need something the current architecture doesn't cover?
    → if yes: flag it, load only the relevant file for that question
```

Output — save as phase1-gate.md:
```
Ambiguities: N

[DOMAIN]        D1. <question> → <answer>
[DATA]          DA1. <question> → <answer>
[PRESENTATION]  P1. <question> → <answer>
[CROSS-CUTTING] C1. <question> → <answer>

Deferred: DEFER — <item> — <reason>
  (becomes explicit constraint in the relevant ticket)

Reuse from existing features:
  - <what> from <feature> (or "nothing")
```

Do not suggest answers. Raise questions only.
If a lens has no ambiguities: say so explicitly — never leave it blank.

**GATE:** Every question answered or marked DEFER.
No ticket is written on an unresolved ambiguity.
Save output as .ai/gates/phase1-gate.md.

---

## Phase 2 — Tickets

**Call:** `/to-tickets`
**Load:** phase1-gate.md

Output: exactly 4 tickets. Each in this schema:

```
Ticket N — <Layer>
Goal: <one sentence>

Files to create (in order):
  - <path> (<what it is>)

Contracts:
  - <ClassName>: <signature — enough to write the spec from this>

Acceptance criteria:
  - [ ] <verifiable statement>

Depends on: Ticket N-1
Deferred items: <any DEFER from phase1 that affects this ticket>
  → must be resolved before this ticket starts
```

The four tickets:

```
Ticket 1 — Domain
  entity, repository abstract contract, usecase(s), mapper
  Constraints: zero framework imports, const constructors,
               no fromJson/toJson on entities

Ticket 2 — Data
  model, datasource abstract contract, datasource impl, repository impl
  Constraints: build_runner after every model, datasource throws never returns null,
               repo impl checks networkInfo before any API call

Ticket 3 — Presentation
  strings, filter (only if needed — state explicitly), bloc, page, widgets
  Constraints: strings file before any UI file, zero hardcoded anything,
               all BLoC states handled

Ticket 4 — DI + Tests
  injection_container.dart additions, full test suite
  Constraints: BLoC=Factory, UseCase/Repo/DS=LazySingleton,
               abstract type registered not concrete,
               DI order: External → Core → Data → Domain → Presentation
```

After tickets:
```
Reuse from existing features:
  - <what> from <feature> (or "nothing")

→ Approve tickets? (yes / change <N> / reject)
```

Do not start implementation. Do not write specs. Wait for explicit yes.
On change: update only the named ticket, show diff, ask again.

**GATE:** Human approves all 4 tickets.
Save output as .ai/gates/phase2-gate.md.

---

## Phase 3 — Spec

**Call:** `/implement-spec`
**Load:** phase2-gate.md + .ai/flutter-tdd-rules.md

For each file in the approved tickets, write a typed Dart spec:

Rules:
- All class names, method signatures, return types must be valid Dart
- Method bodies replaced with `// TODO: implement`
- Every public method gets a `///` doc: what it does, returns, can fail with
- Every dependency listed in the constructor
- Uncertain type: mark `// ❓ DECISION: <what needs deciding>`
- No framework imports in domain specs
- No fromJson/toJson on entity specs
- No concrete types in repository/datasource contracts

Example:
```dart
/// Fetches <entity> record by ID.
/// Returns [Right(<Entity>)] on success.
/// Returns [Left(ServerFailure)] on API error.
/// Returns [Left(InternetFailure)] when offline.
abstract class <Feature>Repository {
  Future<Either<Failure, <Entity>>> get<Feature>(Get<Feature>Params params);
}

class Get<Feature> extends UseCase<<Entity>, Get<Feature>Params> {
  final <Feature>Repository repository;
  const Get<Feature>(this.repository);

  @override
  Future<Either<Failure, <Entity>>> call(Get<Feature>Params params) async {
    // TODO: implement
  }
}
```

After the spec, list every design decision made:
```
Decisions:
D1. <Entity> has X as String — matches API field type
D2. Params: X field only — no pagination in this scope
D3. Filter not needed — BLoC extends BaseBloc<<Entity>>
```

→ Ask: "Spec correct? (yes / change <what> / reject)"
Do NOT write any implementation before explicit yes.
On change: apply, show diff, ask again.

**GATE:** Human approves spec + all decisions.
Save output as .ai/gates/phase3-gate.md.

---

## Phase 4 — Implementation

**Call:** `/tdd` (one layer at a time)
**Load:** phase3-gate.md + .ai/flutter-tdd-rules.md

TDD loop per file:
```
🔴 Red    write test → run → must fail for the right reason
           → ask: "failing for the right reason? (yes / no — <what's wrong>)"
🟢 Green  minimum code to pass → run → must pass
           → if fails: show error, ask how to fix
🔵 Refactor  run checklist → show each finding → get approval per change → run all tests
```

Refactor checklist (run after every file, show result per item):
```
[ ] build() over ~50 lines? → propose extraction
[ ] Hardcoded string? → move to AppStrings
[ ] Hardcoded number? → move to AppConstants
[ ] Hardcoded color? → use colorScheme token
[ ] Widget missing const? → add it
[ ] Public method missing ///? → add it
[ ] Model changed? → run build_runner, show output
```

For any item needing change: show diff, ask "Apply? (yes / no)", wait.

---

### Phase 4a — Domain Layer

**Files in order:** entity → repository contract → usecase(s) → mapper

Layer rules (enforced by flutter-tdd-rules.md):
- Entity: extends Equatable, const constructor, zero framework imports
- Repo contract: abstract class, returns `Either<Failure, T>`, never throws
- UseCase: extends `UseCase<ReturnType, ParamType>`, Params extends Equatable
- Mapper: static methods only, Model → Entity direction only

**GATE — Domain:**
```
Entity    ✓/✗ equal when all fields match
          ✓/✗ not equal when each field differs (one test per field)
Mapper    ✓/✗ all fields map correctly (whole entity asserted)
          ✓/✗ different model → different entity
UseCase   ✓/✗ Right(entity) passes through
          ✓/✗ Left(ServerFailure) passes through unchanged
          ✓/✗ Left(InternetFailure) passes through unchanged
```

Save as .ai/gates/phase4a-gate.md.

---

### Phase 4b — Data Layer

**Files in order:** model → datasource contract → datasource impl → repository impl

Extra rule: run `dart run build_runner build --delete-conflicting-outputs`
after every model file. Show output before continuing. Stop if build_runner fails.

Layer rules:
- Model: @JsonSerializable, round-trip test against fixture
- DataSource: throws ServerException — never returns null, never catches
- Repo impl: checks networkInfo.isConnected before any API call (verifyNever enforces this)

**GATE — Data:**
```
Model         ✓/✗ fromJson matches fixture
              ✓/✗ toJson matches fixture
DataSource    ✓/✗ returns model on 200
              ✓/✗ throws ServerException on DioException
              ✓/✗ throws ServerException on non-200
Repo online   ✓/✗ Right(entity) on success
              ✓/✗ Left(ServerFailure) on ServerException
Repo offline  ✓/✗ Left(InternetFailure)
              ✓/✗ verifyNever — datasource never called when offline
```

Save as .ai/gates/phase4b-gate.md.

---

### Phase 4c — BLoC Layer

**Files in order:** strings → filter (ask first — only if needed) → bloc

Strings file is always first. No hardcoded string in any file written after it.

Layer rules:
- BLoC: BaseBloc<T> for read-only, standard Bloc<Event, State> for CRUD
- BLoC: validates filter type with `is` check in operation()
- Every state name used in the bloc must already exist in the strings file

**GATE — BLoC:**
```
BLoC  ✓/✗ [loading, success] on fetch
      ✓/✗ [loading, failure] on ServerFailure
      ✓/✗ [loading, failure] on InternetFailure
      ✓/✗ [refresh, success] — data in refresh state (seed required)
      ✓/✗ [refresh, refreshFailure] — data preserved on fail (seed required)
      ✓/✗ [failure] BadFilterFailure on wrong filter
```

Save as .ai/gates/phase4c-gate.md.

---

### Phase 4d — Widget Layer

**Files in order:** write all widget tests first → then implement page → extract widgets >50 lines

Use real app theme in buildSubject — not ThemeData(). Contrast tests need real colors.

```dart
Widget buildSubject() {
  return MaterialApp(
    theme: AppTheme.light,
    home: BlocProvider<<Feature>Bloc>.value(
      value: mockBloc,
      child: const <Feature>Page(),
    ),
  );
}
```

Layer rules:
- All text from <Feature>Strings (created in 4c)
- All colors via colorScheme — never Colors.X or Color(0xFF...)
- All sizes via AppConstants
- Material 3 components throughout
- const on every eligible widget
- Any build() over ~50 lines: propose extraction, get approval, then extract

**GATE — Widget:**
```
States        ✓/✗ initial: no content, no spinner
              ✓/✗ loading: spinner visible, content hidden
              ✓/✗ success: content visible, spinner hidden
              ✓/✗ empty: empty state message visible
              ✓/✗ failure: AppStrings error visible
                           raw exception text never shown (assert absence)
              ✓/✗ refresh: prior content still visible
              ✓/✗ refreshFailure: snackbar + content preserved

Interactions  ✓/✗ pull-to-refresh → FetchData(refresh: true) added
              ✓/✗ retry tap → FetchData added

Accessibility ✓/✗ androidTapTargetGuideline
              ✓/✗ iOSTapTargetGuideline
              ✓/✗ labeledTapTargetGuideline
              ✓/✗ textContrastGuideline
```

Save as .ai/gates/phase4d-gate.md.

---

### Phase 4e — DI Registration

No Matt skill. Human-in-the-loop only.

Show plan before touching injection_container.dart:

```
DI Registration Plan

registerFactory:
  - <Feature>Bloc

registerLazySingleton:
  - Get<Feature>                       (UseCase)
  - <Feature>Repository                (abstract → <Feature>RepositoryImpl)
  - <Feature>RemoteDataSource          (abstract → <Feature>RemoteDataSourceImpl)

Insertion point: after [dependency this feature needs]
```

→ Ask: "DI plan correct? (yes / change / no)"
→ Apply only on yes.
→ Show added lines after applying.
→ Ask: "Lines correct? (yes / no)"

DI rules:
- BLoC → registerFactory
- UseCase / Repo / DataSource → registerLazySingleton
- Always register abstract type, not concrete
- Order: External → Core → Data → Domain → Presentation

**GATE:** Human confirms plan AND confirms added lines.
Save as .ai/gates/phase4e-gate.md.

---

## Phase 5 — Full Test Run

Run all tests. Show per layer:

```
Domain layer:           ✅  N/N passing
Data layer:             ✅  N/N passing
Presentation (BLoC):    ✅  N/N passing
Presentation (Widget):  ✅  N/N passing
─────────────────────────────────────────
Total:                  ✅  N/N passing
```

If any test fails:
→ Show exact error + file + line
→ Ask: "How would you like to fix this?"
→ Wait. Do not touch anything before instruction.

**GATE:** 100% passing. No exceptions.
Do not start Phase 6 with a single failing test.

---

## Phase 6 — Code Review

**Call:** `/code-review`
**Load:** .ai/FLUTTER_ARCH.md + .ai/FLUTTER_STANDARDS.md + .ai/flutter-tdd-rules.md
**Also load:** phase2-gate.md (for Axis 6 spec compliance check)

Work through all 6 axes in order.
After each axis: show findings, wait for acknowledgement before continuing.

Severity labels:
- `[BLOCKS PR]` — must fix before merge
- `[TECH DEBT]` — log as follow-up ticket, does not block merge

---

### Axis 1 — Architecture

```
[ ] Dependencies inward only: Presentation → Domain ← Data
[ ] Domain layer: zero framework imports (dart:core only)
[ ] Entities: extend Equatable, const constructor, no fromJson/toJson
[ ] Repository contracts: return Either<Failure, T>, never throw
[ ] Repository impl: checks networkInfo.isConnected before API call
[ ] DataSource: throws ServerException, never returns null
[ ] Mapper: static methods only, Model → Entity, lives in domain/utils/
[ ] Model: @JsonSerializable, extends Equatable, fromJson + toJson
[ ] UseCase: extends UseCase<R, P>, Params extends Equatable, single call()
[ ] BLoC: BaseBloc<T> for read-only, standard Bloc for CRUD
[ ] BLoC: validates filter type with `is` check in operation()
[ ] DI: BLoC=Factory, UseCase/Repo/DS=LazySingleton
[ ] DI: abstract type registered, not concrete
[ ] DI order: External → Core → Data → Domain → Presentation
```

→ Show Axis 1 findings. Ask: "Acknowledged? (yes / no)"

---

### Axis 2 — Flutter Standards

```
[ ] Zero hardcoded strings — all in AppStrings or <feature>_strings.dart
[ ] Zero hardcoded numbers — all in AppConstants
[ ] Zero hardcoded dates/regex/URL patterns — all in AppPatterns
[ ] Zero hardcoded colors — all via colorScheme.<token>
[ ] Zero hardcoded typography — all via textTheme.<style>
[ ] const on every eligible widget
[ ] No build() over ~50 lines — extracted to named widget classes
[ ] Reusable widgets location:
      cross-feature → lib/core/presentation/widgets/
      feature-only  → features/<n>/presentation/ui/widgets/
[ ] Material 3: useMaterial3: true, M3 components used throughout
[ ] No Cupertino widgets unless iOS-only screen
[ ] Naming conventions match FLUTTER_STANDARDS.md
[ ] /// docs on all public classes and non-obvious methods
[ ] Docs say WHY / edge cases — not restatements of the method name
[ ] .g.dart files committed alongside model files
```

→ Show Axis 2 findings. Ask: "Acknowledged? (yes / no)"

---

### Axis 3 — Test Coverage

Check coverage contract from flutter-tdd-patterns.md.
Do not accept ✓ without verifying the test file exists and the test name matches.

```
Entity        ✓/✗ equality + inequality per field
Mapper        ✓/✗ full entity assertion + different model
Model         ✓/✗ fromJson round-trip + toJson round-trip
DataSource    ✓/✗ 200 success + DioException + non-200
Repository    ✓/✗ Right(entity) + Left(ServerFailure) + offline + verifyNever
UseCase       ✓/✗ Right pass-through + Left(ServerFailure) + Left(InternetFailure)
BLoC          ✓/✗ all 6 scenarios
Widget states ✓/✗ all 7 states including raw exception absence assertion
Widget interaction ✓/✗ refresh + retry
Accessibility ✓/✗ all 4 guidelines
```

A missing test is `[BLOCKS PR]`.
A verify-only test or single-field assertion is `[BLOCKS PR]`.

→ Show Axis 3 findings. Ask: "Acknowledged? (yes / no)"

---

### Axis 4 — Accessibility

```
[ ] All interactive widgets have Semantics label or Tooltip
[ ] All images have semanticLabel or excludeFromSemantics: true
[ ] Touch targets minimum 48×48 logical pixels
[ ] Error states use text + icon — not color alone
[ ] Loading state has meaningful Semantics (not an unlabelled spinner)
[ ] SnackBars and error banners announced by screen reader
[ ] Material 3 components used (inherently accessible)
[ ] No GestureDetector replacing a semantic button
[ ] All 4 accessibility guidelines pass in widget tests:
      androidTapTargetGuideline  ✓
      iOSTapTargetGuideline      ✓
      labeledTapTargetGuideline  ✓
      textContrastGuideline      ✓  (must use real app theme)
```

→ Show Axis 4 findings. Ask: "Acknowledged? (yes / no)"

---

### Axis 5 — Security

```
[ ] No API keys, secrets, or auth tokens in source
[ ] No PII in LoggingInterceptor output (debug level only)
[ ] Sensitive user data in flutter_secure_storage — not shared_preferences
[ ] API responses validated before fromJson
[ ] Error messages in UI use AppStrings — not raw exception.message
[ ] Raw exception text never visible in widget (confirmed by widget failure test)
[ ] SSL pinning configured if feature touches auth endpoints
[ ] All base URLs and endpoints only in ApiRoutes
[ ] No secrets in test fixtures (test/fixtures/*.json)
[ ] No hardcoded user IDs or tokens in any test file
```

→ Show Axis 5 findings. Ask: "Acknowledged? (yes / no)"

---

### Axis 6 — Spec Compliance

Load phase2-gate.md. Check each acceptance criterion.

```
[ ] All acceptance criteria from Tickets 1–4 met (check each ✓/✗ explicitly)
[ ] All BLoC states handled in UI:
      initial ✓  loading ✓  success ✓  failure ✓  refresh ✓  refreshFailure ✓
[ ] Empty state handled — user-facing message, not just null check
[ ] Offline state communicated to user via AppStrings
[ ] New screens registered in app_router.dart
[ ] injection_container.dart updated with all new dependencies
[ ] project_status.md updated: feature moved to ✅ Completed
[ ] project_status.md updated: new shared BLoCs, keys, routes recorded
[ ] All DEFER items from Phase 1 resolved or logged as follow-up tickets
```

An unresolved DEFER is `[BLOCKS PR]`.

→ Show Axis 6 findings. Ask: "Acknowledged? (yes / no)"

---

## Review Report Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
REVIEW REPORT — <Feature Name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Axis 1  Architecture:     ✅ PASS
Axis 2  Standards:        ❌ FAIL
  [BLOCKS PR]   profile_page.dart:44 — Colors.blue not colorScheme.primary
  [TECH DEBT]   profile_card.dart:12 — missing /// on ProfileCard
Axis 3  Test Coverage:    ✅ PASS
Axis 4  Accessibility:    ❌ FAIL
  [BLOCKS PR]   AvatarImage — missing semanticLabel
Axis 5  Security:         ✅ PASS
Axis 6  Spec Compliance:  ✅ PASS

PR Ready:     NO
Must fix:     2 × [BLOCKS PR]
Tech debt:    1 × [TECH DEBT] — log as ticket
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

→ Ask: "Fix BLOCKS PR items now? (yes / fix manually)"

If yes:
- Fix one item at a time
- Show diff before applying
- Ask: "Apply? (yes / no)" per item
- Re-run affected axis after each fix
- Show updated ✅/❌

PR is ready only when all 6 axes show ✅ PASS.
A skipped [BLOCKS PR] means the PR is not ready — not a workaround, not a note.

---

## Global Rules

- Never skip a phase
- Never start a phase without human yes at the previous gate
- Never load the full previous session transcript — load gate documents only
- On any gate no: ask what needs changing, fix only that, repeat the gate
- Scope creep during implementation: log it, do not touch it, finish current file
- An unresolved DEFER from Phase 1 is [BLOCKS PR] in Axis 6
- A failed build_runner in Phase 4b stops the layer — do not continue past it
- 100% tests passing is the only acceptable state before Phase 6 starts