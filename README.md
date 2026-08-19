# Fight Clock

Fight Clock — минималистичный интервальный таймер для боксерских тренировок на iPhone. Пользователь задаёт время подготовки, количество и длительность раундов, отдых и предупреждающий сигнал, после чего управляет одной активной тренировкой без аккаунта и подключения к сети.

В пользовательском интерфейсе приложение называется **Fight Clock**. Технические имена Xcode-проекта, схемы и Swift-модуля — `BoxingTimer`.

## Возможности

- 1–15 раундов длительностью от 10 секунд до 15 минут;
- подготовка и отдых от 0 до 5 минут;
- настройка времени с шагом 5 секунд;
- предупреждение за 10 или 30 секунд до конца раунда;
- пауза, продолжение и досрочное завершение с подтверждением;
- восстановление активной сессии по абсолютным временным границам;
- фоновые звуковые уведомления;
- Live Activity с Pause/Resume и состоянием устаревших данных;
- интерфейс на русском и английском, portrait и landscape;
- локальное сохранение последней конфигурации и активной сессии.

По умолчанию настроены 3 раунда по 3:00, отдых 1:00, подготовка 0:10 и предупреждение за 10 секунд до конца раунда.

## Требования

- macOS с Xcode 16 или новее;
- iOS 18.0 или новее;
- [XcodeGen](https://github.com/yonaskolb/XcodeGen);
- [SwiftGen](https://github.com/SwiftGen/SwiftGen).

Инструменты генерации можно установить через Homebrew:

```sh
brew install xcodegen swiftgen
```

## Запуск проекта

1. Проверьте значения в `scripts/.env`, прежде всего `TEAM_ID`.
2. Сгенерируйте локализации и Xcode-проект:

   ```sh
   scripts/generate.sh
   ```

3. Откройте `BoxingTimer.xcodeproj` и запустите схему `BoxingTimer` на iPhone или симуляторе iPhone с iOS 18+.

Файл проекта генерируется и не хранится в Git. Источником настроек служат `scripts/xcodegen/project.yml` и `scripts/xcodegen/Application.yml`.

## Тесты

После генерации проекта тесты можно запустить в Xcode (`Product` → `Test`) или из терминала:

```sh
xcodebuild test \
  -project BoxingTimer.xcodeproj \
  -scheme BoxingTimer \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max'
```

Если такого симулятора нет, подставьте имя доступного iPhone из `xcrun simctl list devices available`.

## Архитектура

```text
BoxingTimer/App/        сборка зависимостей и точка входа
BoxingTimer/Core/       движок сессии, расчёт границ и времени
BoxingTimer/Flows/      экраны настройки и активного таймера
BoxingTimer/Infrastructure/ аудио, уведомления, хранение, Live Activity
BoxingTimer/LiveActivity/    WidgetKit extension и App Intents
BoxingTimer/Model/      доменные модели
BoxingTimer/Resources/  локализации, ассеты, звуки и plist
BoxingTimer/UnitTests/  модульные тесты
scripts/                генерация проекта, ресурсов и доставка
docs/                   продуктовая и UX-документация
```

`SessionEngine` — источник истины для переходов между подготовкой, раундом и отдыхом. UI-тикер только обновляет представление: после фонового режима состояние пересчитывается по сохранённым датам. Для фоновых сигналов заранее планируются локальные уведомления.

## Ограничения

- Silent Mode, Focus, телефонные звонки и настройки уведомлений могут заглушить фоновые сигналы.
- Live Activity без push-обновлений актуальна только до ближайшей границы этапа; затем она предлагает открыть приложение для синхронизации.
- В репозитории пока используются звуки-заглушки из `BoxingTimer/Resources/Audio`.
- История тренировок, пресеты, Apple Watch, iCloud, аккаунты и аналитика не входят в текущую версию.

## Документация

Документация в `docs/` описывает текущее состояние приложения и границы MVP. Технические утверждения в архитектурных разделах сверены с кодом `BoxingTimer/App/`, `BoxingTimer/Core/`, `BoxingTimer/Flows/`, `BoxingTimer/Infrastructure/`, `BoxingTimer/LiveActivity/`, `BoxingTimer/Model/`, `BoxingTimer/Resources/` и `scripts/` на 19 августа 2026 года.

- [Product Vision](docs/product/vision.md)
- [Product Requirements Document](docs/product/prd.md)
- [UX Flow](docs/ux/flow.md)
- [Technical Architecture](docs/tech/architecture.md)
- [Локальные скрипты и доставка](docs/tech/scripts.md)
- [Индекс документации](docs/index.md)
