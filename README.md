# SmartHealth Patient App

Production-quality Flutter patient app for Zimbabwe and across Africa — healthcare directory, emergency hub, and future booking, payments, and tele-consult.

## Stack

- Flutter 3.22+ / Dart 3.4+
- Material 3, Riverpod, go_router
- Offline-first (Hive + Dio cache)
- Localisation: English, Shona, Ndebele, French, Portuguese, Swahili

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter run
```

## Android release (low-end devices)

```bash
flutter build apk --release --split-per-abi
```

- `minSdk` 26, `targetSdk` 34, MultiDex, R8 minify enabled in release.

## Project layout

See `lib/` — `core/`, `features/`, `shared/`, `l10n/`.

## License

Private — SmartHealth.
