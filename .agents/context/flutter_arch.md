# Flutter Architecture Rules

## Layer Rules
- Domain: pure Dart only, zero framework imports
- Data: implements domain contracts only
- Presentation: consumes domain, never imports data directly
- Direction: Presentation → Domain ← Data

## File Creation Order (Never skip or reorder)
1. domain/entities/
2. domain/repositories/ (abstract contract)
3. domain/usecases/
4. domain/utils/ (mappers)
5. data/models/ → run build_runner immediately after
6. data/datasource/ (abstract contract)
7. data/datasource_impl/
8. data/repositories/ (implementation)
9. presentation/constants/<name>_strings.dart
10. presentation/bloc/<name>_filter.dart (if needed)
11. presentation/bloc/<name>_bloc.dart
12. presentation/ui/<name>_page.dart + widgets/
13. injection_container.dart
14. test/ (mirror lib/ structure exactly)

## Entity Rules
- extends Equatable, const constructor
- No fromJson/toJson, no framework imports
- Pure Dart only

## Repository Contract
- Abstract class
- Returns Future<Either<Failure, T>>
- Never throws, never returns null

## UseCase Rules
- extends UseCase<ReturnType, ParamType>
- Single call() method only
- Params extends Equatable with const constructor
- If Params shared by 2+ usecases → extract to usecases/params/

## Mapper Rules
- Static methods only
- Model → Entity direction only, never reverse
- Lives in domain/utils/

## Model Rules
- @JsonSerializable(), extends Equatable
- Has fromJson factory + toJson method
- Always run build_runner after any model change

## DataSource Rules
- Abstract contract separate from impl
- Throws ServerException on error
- Never returns null

## Repository Impl Rules
- Always check networkInfo.isConnected first
- Catch ServerException → return Left(ServerFailure(...))
- No internet → return Left(InternetFailure())
- Use Mapper to convert Model → Entity

## BLoC Rules
- Read-only data → extend BaseBloc<T>, implement operation() only
- CRUD/multi-action → standard Bloc<Event, State>
- Always validate filter type with is check in operation()

## DI Registration Order
External → Core → Data → Domain → Presentation
- BLoC → registerFactory (fresh instance per widget)
- UseCases, Repos, DataSources → registerLazySingleton
- Helpers, ApiService, external libs → registerSingleton
- Always register abstract type not concrete: registerLazySingleton<AbstractClass>(() => ConcreteImpl())

## Error Flow
DataSource throws ServerException
  → RepositoryImpl catches → Left(ServerFailure)
    → UseCase passes Either through unchanged
      → BaseBloc folds → emits Status.failure

## Failure Types
- ServerFailure — API errors
- InternetFailure — no connectivity
- BadFilterFailure — wrong filter type passed to BLoC

## BaseBloc States
initial | loading | success | failure | refresh | refreshFailure

## BaseBloc Events
FetchData(filter, refresh: false) → loading → operation() → success/failure
FetchData(filter, refresh: true)  → refresh → operation() → success/refreshFailure