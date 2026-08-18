# Scripts and Delivery

`scripts` contains local generation helpers and release automation for Fight Clock.

## Layout

```text
scripts/
├── fastlane/            # CI verification and TestFlight delivery lanes
├── sounds/              # Placeholder sound generation
├── swiftgen/            # SwiftGen config and swiftgen.sh wrapper
├── swiftlint/           # SwiftLint config and swiftlint.sh wrapper
├── xcodegen/            # XcodeGen specs and xcodegen.sh wrapper
├── bootstrap.sh         # Install dependencies, generate and open the project
├── generate.sh          # Canonical local generation entrypoint
└── .env.example         # Local non-secret project variables template
```

## Local Environment

The repository currently contains `scripts/.env`. Check its local values before using generation or Fastlane. If it is missing, recreate it from the example:

```sh
cp scripts/.env.example scripts/.env
```

Expected values:

- `PROJECT_NAME=BoxingTimer`
- `TARGET_NAME=BoxingTimer`
- `BUNDLE_ID=ru.kostyuchenko.fightclock`
- `TEAM_ID=<your Apple Developer Team ID>`

Keep secrets out of `scripts/.env`. Fastlane secrets belong in CI secrets or in an untracked `scripts/fastlane/.env`.

## Generation

Canonical project generation entrypoint:

```sh
scripts/generate.sh
```

It validates `scripts/.env`, exports it to the shell and then runs the existing XcodeGen/SwiftGen wrapper.

Canonical XcodeGen spec locations:

- `scripts/xcodegen/project.yml` as the thin entrypoint
- `scripts/xcodegen/Application.yml` as the main application spec

## Fastlane

Fastlane is intentionally stored in `scripts/fastlane`, matching the structure already used in `Compound Interest`.

Files:

- `Fastfile` — lanes `generate`, `lint`, `test`, `build`, `deploy_to_tf` and `deploy`.
- `Appfile` — resolves the app identifier from environment.
- `Matchfile` — configures Match through environment variables instead of hardcoded secrets.

Version settings used by `deploy_to_tf` live in `scripts/xcodegen/Application.yml`.

Required secret configuration for deploy:

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_CONTENT`
- `MATCH_PASSWORD`

Optional:

- `MATCH_READONLY` default is `true`
- `DEPLOY_ALLOWED_BRANCHES` default is `master,main`
- `CI_XCODE_DESTINATION` to override the test simulator
- `CI_BUILD_DESTINATION` to override the build destination

`APP_STORE_CONNECT_API_KEY_CONTENT` must contain base64-encoded key content because Fastlane uses `is_key_content_base64: true`.

After installing Fastlane dependencies, run the lane from `scripts/fastlane`:

```sh
bundle exec fastlane ios deploy_to_tf
```

## Delivery Boundary

Fastlane exists to make TestFlight delivery reproducible. Its presence does not mean deploy should run automatically:

- do not run deploy lanes without explicit user approval;
- do not hardcode secrets in tracked files;
- keep signing, API keys and CI configuration separate from app source.
