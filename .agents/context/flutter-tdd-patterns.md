# Flutter TDD Patterns

Context file loaded alongside Matt's /tdd and /implement-spec skills.
Defines what a correct Flutter test looks like — and what a bad one looks like — for every testable unit.
Nothing here is feature-specific. All names use <Feature> / <Entity> tokens.

---

## Stack
- State: flutter_bloc + BaseBloc<T>
- DI: get_it
- Functional: fpdart — Either<Failure, T>
- HTTP: dio via ApiService
- JSON: json_serializable + build_runner
- Testing: mockito, bloc_test
- Fixtures: test/fixtures/<feature>.json via fixture_reader.dart
- Mocks: @GenerateMocks([...]) + build_runner

## File Mirror Rule
Every lib/ file has a test/ mirror at the same relative path.
lib/features/<f>/domain/entities/<entity>.dart
→ test/features/<f>/domain/entities/<entity>_test.dart

Shared test constants → test/features/<f>/utils/<f>_test_data.dart
Never inline fixture data — always use fixture('filename.json').

---

## Shared Test Helpers

```dart
// test/helpers/fixture_reader.dart
String fixture(String name) =>
    File('test/fixtures/$name').readAsStringSync();

// test/helpers/network_info_helper.dart
void runTestsOnline(void Function() body) {
  group('device is online', () {
    setUp(() =>
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true));
    body();
  });
}

void runTestsOffline(void Function() body) {
  group('device is offline', () {
    setUp(() =>
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false));
    body();
  });
}
```

provideDummy in setUp is required for fpdart Either types:
```dart
setUp(() {
  provideDummy<Either<Failure, <Entity>>>(const Right(<Entity>()));
  ...
});
```

---

## 1. Entity

Entities extend Equatable. Test value equality behaviour — not Equatable internals.

### ❌ Bad
```dart
test('props contains correct fields', () {
  expect(entity.props, [entity.id, entity.name]);
});
// Tests the Equatable mechanism, not the entity contract.
// Breaks if field order changes for non-business reasons.
// Tells you nothing about whether the entity behaves correctly.
```

### ✅ Good
```dart
group('<Entity>', () {
  const tEntity = <Entity>(id: '1', name: 'Alice', score: 42);

  test('two instances with identical values are equal', () {
    const other = <Entity>(id: '1', name: 'Alice', score: 42);
    expect(tEntity, equals(other));
  });

  test('instances differing by id are not equal', () {
    const other = <Entity>(id: '2', name: 'Alice', score: 42);
    expect(tEntity, isNot(equals(other)));
  });

  test('instances differing by name are not equal', () {
    const other = <Entity>(id: '1', name: 'Bob', score: 42);
    expect(tEntity, isNot(equals(other)));
  });

  test('instances differing by score are not equal', () {
    const other = <Entity>(id: '1', name: 'Alice', score: 0);
    expect(tEntity, isNot(equals(other)));
  });
});
```

Rule: one test per differentiating field. If an entity has 6 fields, there are 6 inequality tests.

---

## 2. Mapper

Static, unidirectional: Model → Entity only. Test field translation as a whole, never field by field.

### ❌ Bad
```dart
test('mapper converts model', () {
  final result = <Feature>Mapper.toEntity(t<Feature>Model);
  expect(result.id, isNotNull);        // proves nothing — id can never be null
  expect(result.name, isA<String>());  // proves nothing — already typed
});
// Type assertions on non-nullable fields are noise.
// You can ship a mapper that drops 3 fields and this test passes.
```

### ✅ Good
```dart
group('<Feature>Mapper', () {
  final t<Feature>Model = <Feature>Model(id: '1', name: 'Alice', score: 42);
  const t<Feature>Entity = <Feature>(id: '1', name: 'Alice', score: 42);

  test('toEntity maps all fields correctly', () {
    final result = <Feature>Mapper.toEntity(t<Feature>Model);
    expect(result, equals(t<Feature>Entity));
  });

  test('different input produces different entity', () {
    final otherModel = <Feature>Model(id: '2', name: 'Bob', score: 0);
    final result = <Feature>Mapper.toEntity(otherModel);
    expect(result, isNot(equals(t<Feature>Entity)));
  });
});
```

Why: asserting the full entity catches dropped fields, wrong mappings, and type coercions in one shot.

---

## 3. Model (JSON serialisation)

Test the round trip. Assert the whole model against the fixture — never individual fields.

### ❌ Bad
```dart
test('fromJson parses id', () {
  final model = <Feature>Model.fromJson(json);
  expect(model.id, '1');
});
// Tests one field. Silently misses every other field.
// You can rename a field in the API response and this test still passes.
```

### ✅ Good
```dart
group('<Feature>Model', () {
  final t<Feature>Model = <Feature>Model(id: '1', name: 'Alice', score: 42);

  test('fromJson returns valid model matching fixture', () {
    final result = <Feature>Model.fromJson(
      jsonDecode(fixture('<feature>.json')) as Map<String, dynamic>,
    );
    expect(result, equals(t<Feature>Model));
  });

  test('toJson produces map matching fixture', () {
    final result = t<Feature>Model.toJson();
    expect(result, equals(jsonDecode(fixture('<feature>.json'))));
  });
});
```

Run build_runner before running model tests.
Fixture at: test/fixtures/<feature>.json — must reflect exact API response shape.

---

## 4. DataSource

Tests the HTTP contract: correct response → correct model; error → ServerException.
Never verify that a method was called. Verify what came back.

### ❌ Bad
```dart
test('calls the api', () async {
  when(mockApiService.get(any)).thenAnswer((_) async =>
    Response(data: {}, statusCode: 200, requestOptions: RequestOptions(path: '')));
  await dataSource.get<Feature>(tId);
  verify(mockApiService.get(ApiRoutes.<feature>(tId))).called(1);
  // Confirms a call happened. Says nothing about correctness.
  // Passes even if the model is completely wrong.
  // Missing: exception path, non-200 path.
});
```

### ✅ Good
```dart
group('<Feature>RemoteDataSourceImpl', () {
  late <Feature>RemoteDataSourceImpl dataSource;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    dataSource = <Feature>RemoteDataSourceImpl(apiService: mockApiService);
  });

  test('returns <Feature>Model on 200 response', () async {
    when(mockApiService.get(ApiRoutes.<feature>(tId))).thenAnswer(
      (_) async => Response(
        data: jsonDecode(fixture('<feature>.json')),
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ),
    );

    final result = await dataSource.get<Feature>(tId);

    expect(result, equals(t<Feature>Model));
  });

  test('throws ServerException on DioException', () async {
    when(mockApiService.get(any)).thenThrow(
      DioException(requestOptions: RequestOptions(path: '')),
    );

    expect(
      () => dataSource.get<Feature>(tId),
      throwsA(isA<ServerException>()),
    );
  });

  test('throws ServerException on non-200 status', () async {
    when(mockApiService.get(any)).thenAnswer(
      (_) async => Response(
        data: null,
        statusCode: 404,
        requestOptions: RequestOptions(path: ''),
      ),
    );

    expect(
      () => dataSource.get<Feature>(tId),
      throwsA(isA<ServerException>()),
    );
  });
});
```

Three paths. Always. Success, DioException, bad status code.

---

## 5. Repository

Tests the translation layer: Model → Entity on success, Exception → Failure on error.
Uses runTestsOnline / runTestsOffline. verifyNever when offline is mandatory.

### ❌ Bad
```dart
test('get<Feature> returns entity', () async {
  when(mockDataSource.get<Feature>(any))
    .thenAnswer((_) async => t<Feature>Model);
  final result = await repository.get<Feature>(tParams);
  expect(result, Right(t<Feature>Model)); // ❌ comparing with Model not Entity
});
// Missing: ServerException path, offline path.
// Wrong: repository must return the entity, not the model.
// A mapper bug is invisible here.
```

### ✅ Good
```dart
group('<Feature>RepositoryImpl', () {
  late <Feature>RepositoryImpl repository;
  late Mock<Feature>RemoteDataSource mockDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    provideDummy<Either<Failure, <Entity>>>(Right(<Entity>()));
    mockDataSource = Mock<Feature>RemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = <Feature>RepositoryImpl(
      dataSource: mockDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  runTestsOnline(() {
    test('returns Right(<Entity>) on datasource success', () async {
      when(mockDataSource.get<Feature>(any))
          .thenAnswer((_) async => t<Feature>Model);

      final result = await repository.get<Feature>(tParams);

      expect(result, equals(Right(t<Feature>Entity)));
    });

    test('returns Left(ServerFailure) when datasource throws ServerException', () async {
      when(mockDataSource.get<Feature>(any))
          .thenThrow(const ServerException(message: 'server error'));

      final result = await repository.get<Feature>(tParams);

      expect(result, equals(const Left(ServerFailure(message: 'server error'))));
    });
  });

  runTestsOffline(() {
    test('returns Left(InternetFailure) without touching datasource', () async {
      final result = await repository.get<Feature>(tParams);

      expect(result, equals(const Left(InternetFailure())));
      verifyNever(mockDataSource.get<Feature>(any));
    });
  });
});
```

verifyNever on offline is not optional — it proves networkInfo is checked before the call, not after.

---

## 6. UseCase

Tests the pass-through contract. Both success and every failure type need a test.
The use case must not transform or swallow failures.

### ❌ Bad
```dart
test('calls repository', () async {
  when(mockRepository.get<Feature>(tParams))
    .thenAnswer((_) async => Right(t<Feature>Entity));
  await useCase(tParams);
  verify(mockRepository.get<Feature>(tParams)).called(1);
  // Verify-only test. No assertion on the return value.
  // A use case that calls the repo and throws would pass this.
  // Missing: both failure paths.
});
```

### ✅ Good
```dart
group('Get<Feature>', () {
  late Get<Feature> useCase;
  late Mock<Feature>Repository mockRepository;

  setUp(() {
    provideDummy<Either<Failure, <Entity>>>(Right(<Entity>()));
    mockRepository = Mock<Feature>Repository();
    useCase = Get<Feature>(mockRepository);
  });

  test('returns Right(<Entity>) when repository succeeds', () async {
    when(mockRepository.get<Feature>(tParams))
        .thenAnswer((_) async => Right(t<Feature>Entity));

    final result = await useCase(tParams);

    expect(result, equals(Right(t<Feature>Entity)));
  });

  test('passes Left(ServerFailure) through unchanged', () async {
    when(mockRepository.get<Feature>(tParams))
        .thenAnswer((_) async => const Left(ServerFailure()));

    final result = await useCase(tParams);

    expect(result, equals(const Left(ServerFailure())));
  });

  test('passes Left(InternetFailure) through unchanged', () async {
    when(mockRepository.get<Feature>(tParams))
        .thenAnswer((_) async => const Left(InternetFailure()));

    final result = await useCase(tParams);

    expect(result, equals(const Left(InternetFailure())));
  });
});
```

"Passes through unchanged" is a deliberate test name. The use case is a thin orchestrator — it must not mutate failures.

---

## 7. BLoC

Every state transition gets its own blocTest. Never put two events in one test.
Never assert only the final state — assert every emitted state in order.
Seed state before refresh tests to prove prior data is preserved.

### ❌ Bad
```dart
blocTest<<Feature>Bloc, FetchDataState<<Entity>>>(
  'bloc works',
  build: () => <Feature>Bloc(get<Feature>: mockGet<Feature>),
  act: (b) {
    b.add(FetchData(filter: tFilter));
    b.add(FetchData(filter: tFilter, refresh: true)); // two events — masks which failed
  },
  expect: () => [
    FetchDataState<<Entity>>(status: Status.success, data: t<Entity>),
    // missing loading, missing refresh — only checks the landing state
  ],
);
// Two events in one test. If either fails you don't know which.
// Skips intermediate states — you'll never catch a missing loading spinner.
// No failure tests, no refresh tests, no filter tests.
```

### ✅ Good — one scenario per test
```dart
group('<Feature>Bloc', () {
  late <Feature>Bloc bloc;
  late MockGet<Feature> mockGet<Feature>;

  setUp(() {
    provideDummy<Either<Failure, <Entity>>>(Right(<Entity>()));
    mockGet<Feature> = MockGet<Feature>();
    bloc = <Feature>Bloc(get<Feature>: mockGet<Feature>);
  });

  tearDown(() => bloc.close());

  // --- Fetch ---

  blocTest<<Feature>Bloc, FetchDataState<<Entity>>>(
    'emits [loading, success] when fetch succeeds',
    build: () {
      when(mockGet<Feature>.call(any))
          .thenAnswer((_) async => Right(t<Entity>));
      return <Feature>Bloc(get<Feature>: mockGet<Feature>);
    },
    act: (b) => b.add(FetchData(filter: tFilter)),
    expect: () => [
      const FetchDataState<<Entity>>(status: Status.loading),
      FetchDataState<<Entity>>(
        status: Status.success,
        data: t<Entity>,
        filter: tFilter,
      ),
    ],
  );

  blocTest<<Feature>Bloc, FetchDataState<<Entity>>>(
    'emits [loading, failure] on ServerFailure',
    build: () {
      when(mockGet<Feature>.call(any))
          .thenAnswer((_) async => const Left(ServerFailure()));
      return <Feature>Bloc(get<Feature>: mockGet<Feature>);
    },
    act: (b) => b.add(FetchData(filter: tFilter)),
    expect: () => [
      const FetchDataState<<Entity>>(status: Status.loading),
      const FetchDataState<<Entity>>(
        status: Status.failure,
        failure: ServerFailure(),
      ),
    ],
  );

  blocTest<<Feature>Bloc, FetchDataState<<Entity>>>(
    'emits [loading, failure] on InternetFailure',
    build: () {
      when(mockGet<Feature>.call(any))
          .thenAnswer((_) async => const Left(InternetFailure()));
      return <Feature>Bloc(get<Feature>: mockGet<Feature>);
    },
    act: (b) => b.add(FetchData(filter: tFilter)),
    expect: () => [
      const FetchDataState<<Entity>>(status: Status.loading),
      const FetchDataState<<Entity>>(
        status: Status.failure,
        failure: InternetFailure(),
      ),
    ],
  );

  // --- Refresh ---

  blocTest<<Feature>Bloc, FetchDataState<<Entity>>>(
    'emits [refresh, success] when refresh succeeds — preserves prior data during refresh',
    seed: () => FetchDataState<<Entity>>(
      status: Status.success,
      data: t<Entity>,
      filter: tFilter,
    ),
    build: () {
      when(mockGet<Feature>.call(any))
          .thenAnswer((_) async => Right(t<Entity>));
      return <Feature>Bloc(get<Feature>: mockGet<Feature>);
    },
    act: (b) => b.add(FetchData(filter: tFilter, refresh: true)),
    expect: () => [
      FetchDataState<<Entity>>(                   // prior data still visible during refresh
        status: Status.refresh,
        data: t<Entity>,
        filter: tFilter,
      ),
      FetchDataState<<Entity>>(
        status: Status.success,
        data: t<Entity>,
        filter: tFilter,
      ),
    ],
  );

  blocTest<<Feature>Bloc, FetchDataState<<Entity>>>(
    'emits [refresh, refreshFailure] when refresh fails — preserves prior data',
    seed: () => FetchDataState<<Entity>>(
      status: Status.success,
      data: t<Entity>,
      filter: tFilter,
    ),
    build: () {
      when(mockGet<Feature>.call(any))
          .thenAnswer((_) async => const Left(ServerFailure()));
      return <Feature>Bloc(get<Feature>: mockGet<Feature>);
    },
    act: (b) => b.add(FetchData(filter: tFilter, refresh: true)),
    expect: () => [
      FetchDataState<<Entity>>(
        status: Status.refresh,
        data: t<Entity>,
        filter: tFilter,
      ),
      FetchDataState<<Entity>>(                   // data preserved even on failure
        status: Status.refreshFailure,
        data: t<Entity>,
        filter: tFilter,
      ),
    ],
  );

  // --- Filter guard ---

  blocTest<<Feature>Bloc, FetchDataState<<Entity>>>(
    'emits [failure] with BadFilterFailure when wrong filter type passed',
    build: () => <Feature>Bloc(get<Feature>: mockGet<Feature>),
    act: (b) => b.add(FetchData(filter: WrongFilter())),
    expect: () => [
      const FetchDataState<<Entity>>(
        status: Status.failure,
        failure: BadFilterFailure(),
      ),
    ],
  );
});
```

---

## 8. Widget

Tests that the UI renders the correct content for each BLoC state, handles interactions,
and passes accessibility guidelines. One testWidgets call per scenario.

### Setup — always use buildSubject helper

```dart
@GenerateMocks([<Feature>Bloc])
void main() {
  late Mock<Feature>Bloc mockBloc;

  setUp(() {
    mockBloc = Mock<Feature>Bloc();
    // Required: stub the state stream even if not testing transitions
    when(mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(mockBloc.state).thenReturn(
      const FetchDataState<<Entity>>(status: Status.initial),
    );
  });

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light,   // use real app theme — catches colorScheme issues
      home: BlocProvider<<Feature>Bloc>.value(
        value: mockBloc,
        child: const <Feature>Page(),
      ),
    );
  }
```

Use the real app theme, not ThemeData(). A test with ThemeData() will miss hardcoded color violations.

### ❌ Bad
```dart
testWidgets('renders', (tester) async {
  await tester.pumpWidget(buildSubject());
  expect(find.byType(<Feature>Page), findsOneWidget);
  // Proves the widget exists. That's it.
  // Loading, success, failure, empty, interaction — none of it tested.
});
```

### ✅ Good — state tests

```dart
  // --- Initial ---

  testWidgets('shows nothing interactive in initial state', (tester) async {
    when(mockBloc.state).thenReturn(
      const FetchDataState<<Entity>>(status: Status.initial),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(<Entity>ListView), findsNothing);
  });

  // --- Loading ---

  testWidgets('shows loading indicator and hides content when loading', (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        const FetchDataState<<Entity>>(status: Status.loading),
      ]),
      initialState: const FetchDataState<<Entity>>(status: Status.initial),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(<Entity>ListView), findsNothing);
  });

  // --- Success ---

  testWidgets('shows entity content and hides spinner when success', (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        FetchDataState<<Entity>>(status: Status.success, data: t<Entity>),
      ]),
      initialState: const FetchDataState<<Entity>>(status: Status.initial),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(<Entity>ListView), findsOneWidget);
    expect(find.text(t<Entity>.name), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  // --- Empty ---

  testWidgets('shows empty state message when success with no data', (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        const FetchDataState<<Entity>>(status: Status.success, data: null),
      ]),
      initialState: const FetchDataState<<Entity>>(status: Status.initial),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text(<Feature>Strings.emptyState), findsOneWidget);
    expect(find.byType(<Entity>ListView), findsNothing);
  });

  // --- Failure ---

  testWidgets('shows error message from AppStrings on failure — not raw exception', (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        const FetchDataState<<Entity>>(
          status: Status.failure,
          failure: ServerFailure(),
        ),
      ]),
      initialState: const FetchDataState<<Entity>>(status: Status.initial),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text(<Feature>Strings.serverError), findsOneWidget);
    expect(find.byType(<Entity>ListView), findsNothing);
    expect(find.text('ServerFailure'), findsNothing);   // raw exception must never appear
    expect(find.text('Exception'), findsNothing);
  });

  // --- Refresh ---

  testWidgets('shows existing content during refresh', (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        FetchDataState<<Entity>>(
          status: Status.refresh,
          data: t<Entity>,
          filter: tFilter,
        ),
      ]),
      initialState: FetchDataState<<Entity>>(
        status: Status.success,
        data: t<Entity>,
        filter: tFilter,
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    // content is still visible during refresh
    expect(find.byType(<Entity>ListView), findsOneWidget);
    expect(find.text(t<Entity>.name), findsOneWidget);
  });

  // --- RefreshFailure ---

  testWidgets('shows error snackbar on refreshFailure — keeps existing content visible', (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        FetchDataState<<Entity>>(
          status: Status.refreshFailure,
          data: t<Entity>,
          filter: tFilter,
        ),
      ]),
      initialState: FetchDataState<<Entity>>(
        status: Status.success,
        data: t<Entity>,
        filter: tFilter,
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(<Feature>Strings.refreshError), findsOneWidget);
    expect(find.byType(<Entity>ListView), findsOneWidget); // content preserved
  });
```

### ✅ Good — interaction tests

```dart
  testWidgets('adds FetchData(refresh: true) event on pull-to-refresh', (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        FetchDataState<<Entity>>(status: Status.success, data: t<Entity>, filter: tFilter),
      ]),
      initialState: const FetchDataState<<Entity>>(status: Status.initial),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    verify(mockBloc.add(FetchData(filter: tFilter, refresh: true))).called(1);
  });

  testWidgets('adds correct event when retry button tapped on failure', (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        const FetchDataState<<Entity>>(status: Status.failure),
      ]),
      initialState: const FetchDataState<<Entity>>(status: Status.initial),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text(<Feature>Strings.retry));
    await tester.pump();

    verify(mockBloc.add(FetchData(filter: tFilter))).called(1);
  });
```

### ✅ Good — accessibility tests

Run in success state so all interactive content is visible.

```dart
  testWidgets('meets Android tap target accessibility guideline', (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        FetchDataState<<Entity>>(status: Status.success, data: t<Entity>),
      ]),
      initialState: const FetchDataState<<Entity>>(status: Status.initial),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    final SemanticsHandle handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('meets iOS tap target accessibility guideline', (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        FetchDataState<<Entity>>(status: Status.success, data: t<Entity>),
      ]),
      initialState: const FetchDataState<<Entity>>(status: Status.initial),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    final SemanticsHandle handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('all interactive elements have semantic labels', (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        FetchDataState<<Entity>>(status: Status.success, data: t<Entity>),
      ]),
      initialState: const FetchDataState<<Entity>>(status: Status.initial),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    final SemanticsHandle handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('text meets contrast ratio guideline', (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        FetchDataState<<Entity>>(status: Status.success, data: t<Entity>),
      ]),
      initialState: const FetchDataState<<Entity>>(status: Status.initial),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    final SemanticsHandle handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
```

Why the real app theme matters for contrast tests: textContrastGuideline checks actual rendered colors.
A test using ThemeData() will never catch a hardcoded color that fails contrast.

---

## Coverage Contract

A layer is not done until every item is checked with ✓. A ✗ blocks completion.

```
Entity
  ✓/✗  equal when all fields match
  ✓/✗  not equal when each field differs (one test per field)

Mapper
  ✓/✗  all fields map correctly (assert whole entity)
  ✓/✗  different model produces different entity

Model
  ✓/✗  fromJson matches fixture
  ✓/✗  toJson matches fixture

DataSource
  ✓/✗  returns correct model on 200
  ✓/✗  throws ServerException on DioException
  ✓/✗  throws ServerException on non-200

Repository (online)
  ✓/✗  returns Right(entity) on success
  ✓/✗  returns Left(ServerFailure) on ServerException
Repository (offline)
  ✓/✗  returns Left(InternetFailure)
  ✓/✗  verifyNever: datasource never called when offline

UseCase
  ✓/✗  returns Right(entity) on success
  ✓/✗  passes Left(ServerFailure) through unchanged
  ✓/✗  passes Left(InternetFailure) through unchanged

BLoC
  ✓/✗  [loading, success] on fetch
  ✓/✗  [loading, failure] on ServerFailure
  ✓/✗  [loading, failure] on InternetFailure
  ✓/✗  [refresh, success] — prior data in refresh state
  ✓/✗  [refresh, refreshFailure] — prior data preserved on fail
  ✓/✗  [failure] with BadFilterFailure on wrong filter

Widget (states)
  ✓/✗  initial: no content, no spinner
  ✓/✗  loading: spinner visible, content hidden
  ✓/✗  success: content visible, spinner hidden
  ✓/✗  empty: empty state message visible
  ✓/✗  failure: AppStrings error visible, raw exception never shown
  ✓/✗  refresh: prior content still visible
  ✓/✗  refreshFailure: snackbar shown, prior content still visible

Widget (interactions)
  ✓/✗  pull-to-refresh → FetchData(refresh: true) added
  ✓/✗  retry tap → FetchData added

Widget (accessibility)
  ✓/✗  androidTapTargetGuideline passes
  ✓/✗  iOSTapTargetGuideline passes
  ✓/✗  labeledTapTargetGuideline passes
  ✓/✗  textContrastGuideline passes
```