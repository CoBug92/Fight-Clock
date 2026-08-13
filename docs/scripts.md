# Scripts and Delivery

`Scripts` contains local generation helpers and release automation for Fight Clock.

## Layout

```text
Scripts/
├── fastlane/            # TestFlight deploy automation
├── sounds/              # Placeholder sound generation
├── swiftgen/            # Localization code generation
├── swiftlint/           # Lint configuration
├── xcodegen/            # Xcode project generation and spec
├── generate.sh          # Canonical local generation entrypoint
└── project.env.example  # Local non-secret project variables template
```

## Local Environment

The repository currently contains `Scripts/project.env`. Check its local values before using generation or Fastlane. If it is missing, recreate it from the example:

```sh
cp Scripts/project.env.example Scripts/project.env
```

Expected values:

- `PROJECT_NAME=BoxingTimer`
- `TARGET_NAME=BoxingTimer`
- `BUNDLE_ID=ru.kostyuchenko.fightclock`
- `TEAM_ID=<your Apple Developer Team ID>`

Keep secrets out of `Scripts/project.env`. Fastlane secrets belong in CI secrets or in an untracked `Scripts/fastlane/.env`.

## Generation

Canonical project generation entrypoint:

```sh
Scripts/generate.sh
```

It validates `Scripts/project.env`, exports it to the shell and then runs the existing XcodeGen/SwiftGen wrapper.

Canonical XcodeGen spec locations:

- `Scripts/xcodegen/project.yml` as the thin entrypoint
- `Scripts/xcodegen/Application.yml` as the main application spec

## Fastlane

Fastlane is intentionally stored in `Scripts/fastlane`, matching the structure already used in `Compound Interest`.

Files:

- `Fastfile` — lane `deploy_to_tf` for TestFlight deploy.
- `Appfile` — resolves the app identifier from environment.
- `Matchfile` — configures Match through environment variables instead of hardcoded secrets.

Version settings used by `deploy_to_tf` live in `Scripts/xcodegen/Application.yml`.

Required secret configuration for deploy:

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_CONTENT`
- `MATCH_PASSWORD`
- `MATCH_GIT_URL`
- `CI_KEYCHAIN_PASSWORD`

Optional:

- `MATCH_GIT_BRANCH` default is `personal`
- `MATCH_READONLY` default is `true`
- `DEPLOY_ALLOWED_BRANCHES` default is `master,main`
- `XCODE_PROJ_PATH` if the generated project path must be overridden

`APP_STORE_CONNECT_API_KEY_CONTENT` must contain base64-encoded key content because Fastlane uses `is_key_content_base64: true`.

After installing Fastlane dependencies, run the lane from `Scripts/fastlane`:

```sh
bundle exec fastlane ios deploy_to_tf
```

Add `bump_version:true` to increment the patch version before upload.

## Delivery Boundary

Fastlane exists to make TestFlight delivery reproducible. Its presence does not mean deploy should run automatically:

- do not run deploy lanes without explicit user approval;
- do not hardcode secrets or certificate repository URLs in tracked files;
- keep signing, API keys and CI configuration separate from app source.
