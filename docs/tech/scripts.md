# Локальные скрипты и доставка

Каталог `scripts/` содержит локальные утилиты генерации проекта, вспомогательные обёртки над XcodeGen и SwiftGen, а также Fastlane-конфигурацию для сборки и доставки Fight Clock.

## Структура

```text
scripts/
├── fastlane/                      # lane'ы проверки, архивации и TestFlight
├── sounds/                        # генерация placeholder-аудио
├── swiftgen/                      # конфиг SwiftGen и shell-обёртка
├── swiftlint/                     # конфиг SwiftLint и shell-обёртка
├── xcodegen/                      # XcodeGen-спеки и shell-обёртка
├── bootstrap.sh                   # установка зависимостей, генерация и открытие проекта
├── generate.sh                    # каноническая точка локальной генерации
├── generate_github_social_preview.py
│                                  # генерация `docs/assets/github-social-preview.png`
└── .env.example                   # шаблон локальных несекретных переменных
```

## Локальное окружение

В репозитории сейчас есть `scripts/.env`, но перед генерацией и Fastlane нужно проверить его локальные значения. Если файла нет, восстановите его из шаблона:

```sh
cp scripts/.env.example scripts/.env
```

Ожидаемые значения:

- `PROJECT_NAME=BoxingTimer`
- `TARGET_NAME=BoxingTimer`
- `BUNDLE_ID=ru.kostyuchenko.fightclock`
- `TEAM_ID=<ваш Apple Developer Team ID>`

Секреты не должны попадать в `scripts/.env`. Fastlane-секреты нужно держать в CI secrets или в неотслеживаемом `scripts/fastlane/.env`.

## Генерация проекта

Каноническая точка локальной генерации:

```sh
scripts/generate.sh
```

`scripts/generate.sh` проверяет наличие `scripts/.env`, экспортирует его в shell и затем запускает существующие обёртки над SwiftGen и XcodeGen.

Канонические XcodeGen-спеки:

- `scripts/xcodegen/project.yml` — тонкая входная точка;
- `scripts/xcodegen/Application.yml` — основной application-spec.

`BoxingTimer.xcodeproj` является результатом генерации. Он может присутствовать локально в рабочей области, но источником правды для структуры targets, bundle identifiers, deployment target и signing-настроек остаются XcodeGen-спеки.

`scripts/bootstrap.sh` поверх этого дополнительно:

- проверяет наличие Homebrew;
- при наличии `Brewfile` запускает `brew bundle`;
- при наличии Bundler запускает `bundle install`;
- выполняет `scripts/generate.sh`;
- открывает сгенерированный `BoxingTimer.xcodeproj` в Xcode.

## Fastlane

Fastlane намеренно живёт в `scripts/fastlane`, повторяя структуру, уже использованную в соседних проектах автора.

Файлы:

- `Fastfile` — lane'ы `generate`, `lint`, `test`, `build`, `deploy_to_tf` и `deploy`;
- `Appfile` — получает app identifier из окружения;
- `Matchfile` — настраивает Match через переменные окружения без захардкоженных секретов.

Параметры версии, которые использует `deploy_to_tf`, лежат в `scripts/xcodegen/Application.yml`.

Обязательные секреты для deploy:

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_CONTENT`
- `MATCH_PASSWORD`

Опционально:

- `MATCH_READONLY`, по умолчанию `true`;
- `DEPLOY_ALLOWED_BRANCHES`, по умолчанию `master,main`;
- `CI_XCODE_DESTINATION` для переопределения тестового симулятора;
- `CI_BUILD_DESTINATION` для переопределения build-destination.

`APP_STORE_CONNECT_API_KEY_CONTENT` должен содержать ключ в base64, потому что Fastlane использует `is_key_content_base64: true`.

После установки Ruby/Fastlane-зависимостей lane запускается из `scripts/fastlane`:

```sh
bundle exec fastlane ios deploy_to_tf
```

## Границы доставки

Fastlane нужен для воспроизводимой доставки в TestFlight, но его наличие не означает, что deploy надо запускать автоматически:

- не запускать deploy-lane'ы без явного одобрения пользователя;
- не хардкодить секреты в отслеживаемых файлах;
- держать signing, API keys и CI-конфигурацию отдельно от исходников приложения.

Неизвестно по репозиторию: настроены ли внешние App Store Connect API key, Match-хранилище сертификатов и CI-секреты. Документ описывает локальный контракт скриптов, а не подтверждённую готовность внешней доставки.
