# Project Context

## App
Weather App — Flutter, Clean Architecture + DDD, BLoC

## Stack
- State: flutter_bloc, BaseBloc<T>
- DI: get_it (service locator)
- Functional: fpdart (Either<Failure, T>)
- HTTP: dio via ApiService
- JSON: json_serializable + build_runner
- Testing: mockito, bloc_test
- Fonts: google_fonts (Nunito)
- Images: cached_network_image

## Golden Template
`lib/features/weather/` — reference this for every new feature

## Key Reference Files (load as needed)
- `.ai/ARCHITECTURE_PROMPT.md` — full layer rules + code examples
- `.ai/design_guidelines.md` — Material 3 + UI standards
- `.ai/project_status.md` — completed features + shared state
- `.ai/PROGRESS.md` — current task progress

## Architecture
Presentation → Domain → Data
Dependencies point inward only. Domain has zero framework imports.

## Feature Location
`lib/features/<name>/` with `data/`, `domain/`, `presentation/`

## Completed Features
- Weather Module: full vertical slice (Domain → Data → UI)