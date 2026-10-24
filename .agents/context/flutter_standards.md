# Flutter Coding Standards

## Zero Hardcoding (Strict — No Exceptions)
- Strings → AppStrings (shared) or <feature>_strings.dart (feature-specific)
- Numbers, spacing, sizes → AppConstants
- Dates, regex, URL patterns → AppPatterns
- Colors → Theme.of(context).colorScheme.<token>
- Typography → Theme.of(context).textTheme.<style>
- Interpolated strings → static method e.g. static String temp(int t) => '$t\u00B0'

## Naming Conventions
- Entities: singular noun → Weather, Wind, Profile
- Models: <Entity>Model → WindModel, ProfileModel
- UseCases: verb + noun → GetWeather, UpdateProfile
- Repos (abstract): <Feature>Repository
- Repos (impl): <Feature>RepositoryImpl
- DataSources (abstract): <Feature>RemoteDataSource
- DataSources (impl): <Feature>RemoteDataSourceImpl
- BLoCs: <Feature>Bloc
- Filters: <Context>Filter → LocationFilter
- Mappers: <Feature>Mapper
- Strings: <Feature>Strings → WeatherStrings

## Widget Rules
- const on every widget that allows it — no exceptions
- Extract to separate class if build() exceeds ~50 lines
- Reusable across features → lib/core/presentation/widgets/
- Feature-specific reuse → features/<name>/presentation/ui/widgets/

## Material 3 Rules
- useMaterial3: true always enabled in ThemeData
- Use FilledButton, OutlinedButton, TextButton — not raw GestureDetector on Container
- Use Card.filled(), Card.outlined() for cards
- Use TextFormField with InputDecorationTheme from app_theme.dart
- Never use Cupertino widgets unless iOS-only screen

## Color Rules
- Never: Colors.blue, Colors.red, Color(0xFF...)
- Always: Theme.of(context).colorScheme.primary / .error / .surface etc
- Export brand colors via Material Theme Builder → color_schemes.g.dart

## Typography Rules
- Never: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
- Always: Theme.of(context).textTheme.headlineMedium
- Color override only: .copyWith(color: Theme.of(context).colorScheme.onPrimary)

## Documentation Rules
- Use /// for all public classes, methods, and non-obvious properties
- Document WHY or edge cases — not obvious WHAT
- Bad: /// gets user — above getUser()
- Good: /// Returns cached user if token valid, fetches remote otherwise

## Test Standards
- Mirror lib/ structure exactly under test/
- Shared constants → test/features/<name>/utils/
- JSON fixtures → test/fixtures/*.json loaded via fixture_reader.dart
- @GenerateMocks([...]) + build_runner for all mocks
- blocTest<Bloc, State>() for all BLoC tests
- runTestsOnline() / runTestsOffline() helper groups for repository tests
- provideDummy<Either<Failure, T>>() in setUp for fpdart types

## Code Generation
Run after any model file change — do not forget:
dart run build_runner build --delete-conflicting-outputs