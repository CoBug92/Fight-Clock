# Инструкции для агентов Fight Clock

## Назначение и границы

Fight Clock — офлайн-интервальный таймер для боксерских тренировок на iPhone.
Пользовательское имя приложения — **Fight Clock**; техническое имя Xcode-проекта —
`BoxingTimer`, а targets и Swift-модули называются по роли: `Main`, `LiveActivity` и
`MainUnitTests`.

Перед изменением поведения прочитайте соответствующий канонический документ:

- продуктовые требования — `docs/product/prd.md`;
- пользовательские состояния и UI — `docs/ux/flow.md`;
- устройство приложения и инварианты — `docs/tech/architecture.md`;
- генерация, проверка и доставка — `docs/tech/scripts.md`.

README — только входная точка; не дублируйте в нём подробности из `docs/`.

## Структура и ответственность слоёв

```text
Main/App/                   точка входа и production DI
Main/Core/                  чистая логика сессии и расчёт её границ
Main/Model/Domain/          доменные типы и валидируемая конфигурация
Main/Flows/                 SwiftUI-экраны и RootViewModel
Main/Infrastructure/        UserDefaults, звук, уведомления, Live Activity, система
Main/Resources/             локализации, ассеты, аудио и конфигурация
Main/UnitTests/             модульные тесты
LiveActivity/               WidgetKit extension и App Intents
scripts/                    генерация, линт, Fastlane
```

- `SessionEngine` не должен зависеть от SwiftUI, UserDefaults, ActivityKit,
  уведомлений или аудио. Логику переходов фаз и расчёта времени помещайте сюда;
  добавляйте покрытие в `Main/UnitTests/Core/`.
- `RootViewModel` координирует UI и инфраструктуру. Инъецируйте зависимости через
  протоколы, чтобы сохранить проверяемость без системных сервисов.
- Новый файл, необходимый Live Activity extension, нужно явно добавить в `sources`
  target `LiveActivity` в `scripts/xcodegen/Application.yml`.
- Настройки текущей активной сессии нельзя менять. Запуск фиксирует снимок
  `TimerConfiguration`.

## Неподвижные правила таймера

- Источник истины для running-сессии — `SessionState.phaseEndDate`, а не UI-тикер.
  Восстановление после фона должно пересчитываться от абсолютного времени через
  `SessionEngine.resolve(_:at:)`.
- При паузе `phaseEndDate` очищается, а остаток хранится в `pausedRemaining`; при
  продолжении новая граница рассчитывается от текущего момента.
- Окончание или остановка обязаны очистить активную сессию, отменить относящиеся к ней
  уведомления, вернуть idle timer и завершить Live Activity.
- App Group `group.ru.kostyuchenko.fightclock` — контракт между приложением и
  extension. Не меняйте его или bundle identifiers без отдельной миграции.
- Live Activity не является фоновым движком таймера. Без push-обновлений она достоверна
  только до ближайшей границы этапа.

## Ресурсы, локализация и генерация

- Не редактируйте вручную `BoxingTimer.xcodeproj` и
  `Main/Resources/Generated/`: это генерируемые и игнорируемые результаты.
  Источник конфигурации проекта — `scripts/xcodegen/Application.yml`; локализаций —
  `scripts/swiftgen/swiftgen.yml` и файлы ресурсов.
- После изменений XcodeGen-спеки, локализаций или ресурсов выполните
  `scripts/generate.sh`. Для него требуется локальный `scripts/.env`; при отсутствии
  создайте его из `scripts/.env.example` и не коммитьте секреты.
- Сохраняйте product name `Fight Clock` и техническое имя проекта `BoxingTimer` в их
  соответствующих контекстах; не смешивайте их в идентификаторах, targets и UI.

## Стиль Swift

- Swift 6, SwiftUI, отступ 4 пробела. Держите файлы до 500 строк и строки до 150
  символов — это ошибки SwiftLint.
- Не используйте force cast, `try!`, force unwrap или неиспользуемые импорты.
- Следуйте уже принятой структуре: `@MainActor` для UI-координаторов, `Sendable` для
  чистых безопасно передаваемых типов, зависимости — через небольшие протоколы.
- Локализуйте любой пользовательский текст через существующий SwiftGen-подход; не
  добавляйте строковые литералы в SwiftUI-экраны.

## Проверка изменений

Сначала сгенерируйте проект, если он отсутствует или изменялись его входы:

```sh
scripts/generate.sh
```

Для Swift-изменений выполните релевантные проверки:

```sh
scripts/swiftlint/swiftlint.sh
xcodebuild test -project BoxingTimer.xcodeproj -scheme Main \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
  CODE_SIGNING_ALLOWED=NO test
```

Если такого симулятора нет, выберите доступный iPhone через
`xcrun simctl list devices available`. Для полной проверки без подписи используйте:

```sh
cd scripts/fastlane && bundle exec fastlane ios lint
cd scripts/fastlane && bundle exec fastlane ios test
cd scripts/fastlane && bundle exec fastlane ios build
```

Тесты должны проверять наблюдаемый контракт. Для изменений таймера обязательно
проверьте переходы фаз, предупреждение, паузу/продолжение и догоняющее разрешение
после пропущенных границ. Для UI также проверьте portrait и landscape на iPhone.

## Git, CI и доставка

- Сначала проверяйте `git status`; не перезаписывайте и не откатывайте чужие
  незакоммиченные изменения.
- CI запускает `lint` и `test` для pull request в `master`; build добавляется для
  полного вызова workflow. Согласуйте локальные проверки с этими lane'ами.
- Не запускайте `fastlane ios deploy_to_tf` или `deploy` без явного разрешения:
  они подписывают, загружают сборку в TestFlight и меняют build number во время lane.
- Не добавляйте в Git `scripts/.env`, Fastlane API keys, `MATCH_PASSWORD`, сертификаты,
  provisioning profiles или производные артефакты.

## Документация

При изменении продукта, UX, архитектуры, публичных контрактов или доставки обновите
соответствующий документ в `docs/` и ссылки в `docs/index.md` при необходимости.
Описывайте только подтверждённое кодом, конфигурацией или наблюдаемым поведением;
требования, предположения и неизвестное маркируйте явно.
