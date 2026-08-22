# Документация Fight Clock

Этот раздел содержит устойчивую документацию по продукту, UX, архитектуре и локальным инструментам Fight Clock.

Продуктовое имя приложения — **Fight Clock**. Техническое имя проекта в репозитории — `BoxingTimer`; targets и Swift-модули называются `Main` и `LiveActivity`.

## Для кого

- Product и design: начать с [Product Vision](product/vision.md), затем открыть [PRD](product/prd.md) и [UX Flow](ux/flow.md).
- iOS-разработка: начать с [Technical Architecture](tech/architecture.md), затем сверить команды в [документе по скриптам](tech/scripts.md).
- Проверка гипотез: смотреть актуальные записи ниже в разделе "Гипотезы".

## Канонические документы

| Документ | Назначение |
|---|---|
| [README](../README.md) | Короткая входная точка: назначение, запуск, требования и ключевые ссылки. |
| [Product Vision](product/vision.md) | Проблема, целевой пользователь, границы MVP и уровень подтверждения гипотез. |
| [Product Requirements Document](product/prd.md) | Функциональные и нефункциональные требования к приложению. |
| [UX Flow](ux/flow.md) | Пользовательские состояния, переходы, ключевые экраны и ограничения UX. |
| [Technical Architecture](tech/architecture.md) | Текущее устройство приложения, слои, поток данных и технические ограничения. |
| [Локальные скрипты и доставка](tech/scripts.md) | Локальная генерация проекта, SwiftGen/XcodeGen/Fastlane и границы доставки. |

## Структура

```text
docs/
├── index.md
├── assets/
├── hypotheses/
│   ├── apple-watch-remote-control-2026-08-21.md
│   └── triple-duration-picker-2026-08-19.md
├── product/
│   ├── prd.md
│   └── vision.md
├── tech/
│   ├── architecture.md
│   └── scripts.md
└── ux/
    └── flow.md
```

Неиспользуемые каталоги из общего стандарта skill (`adr/`, `engineering/`, `integration/`, `diagrams/`) пока не созданы, потому что в проекте нет соответствующих документов.

## Статус проверки

Актуализация от 19 августа 2026 года сверена с текущими файлами:

- доменная логика и модель: `Main/Core/Session`, `Main/Model/Domain`;
- SwiftUI-потоки: `Main/Flows/Setup`, `Main/Flows/Root`, `Main/Flows/Active`;
- инфраструктура: `Main/Infrastructure/Persistence`, `Main/Infrastructure/Notifications`, `Main/Infrastructure/Audio`, `Main/Infrastructure/LiveActivity`, `Main/Infrastructure/System`;
- Live Activity extension и intents: `LiveActivity`;
- ресурсы и локализации: `Main/Resources/Audio`, `Main/Resources/Localization`, `Main/Resources/Configuration`;
- генерация проекта и доставка: `scripts/xcodegen`, `scripts/swiftgen`, `scripts/fastlane`, `scripts/generate.sh`.

Корневой `AGENTS.md` в рабочей области отсутствует; применяются инструкции, переданные пользователем в задаче.

## Гипотезы

| Документ | Статус |
|---|---|
| [Triple Duration Picker](hypotheses/triple-duration-picker-2026-08-19.md) | Отклонено после визуального ревью прототипа |
| [Apple Watch: Time and Sound](hypotheses/apple-watch-remote-control-2026-08-21.md) | Ожидает одобрения проверки |

## Правила обновления

- Не дублировать подробные требования между README и `docs/`: README должен ссылаться на канонические документы.
- Новые факты о поведении приложения проверять по коду, конфигурации или наблюдаемому поведению.
- Исторические причины решений фиксировать отдельными гипотезами или ADR, а текущее состояние держать в PRD, UX Flow и Technical Architecture.
- Если поведение не подтверждено кодом или конфигурацией, помечать его как требование, предположение или неизвестное.
