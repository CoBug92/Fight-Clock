# Train in Intervals: Technical Architecture

## Назначение

Документ описывает текущее устройство iOS-приложения Train in Intervals для разработчиков и ревьюеров. Источник фактов: Swift-код, XcodeGen/SwiftGen-конфигурация и существующая документация на 22 августа 2026 года.

Продуктовое имя в интерфейсе — **Train in Intervals**. Техническое имя проекта — `BoxingTimer`; targets и Swift-модули называются `Main` и `LiveActivity`.

`Main` собирается для iPhone, iPad и Mac Catalyst из общих исходников. Расширение `LiveActivity` встраивается в сборки iPhone и iPad. В Mac Catalyst вызовы `LiveActivityControlling` не обращаются к ActivityKit.

## Границы

В документ входят слои приложения, поток состояния таймера, хранение, уведомления, Live Activity, звук и генерация проекта. Не входят история продуктовых решений, детали отдельных тестов и планы будущих функций.

## Проверенные источники

- `Main/App/AppDependencies.swift`, `Main/App/BoxingTimerApp.swift`;
- `Main/Core/Session/*`;
- `Main/Model/Domain/*`;
- `Main/Flows/Setup/*`, `Main/Flows/Root/*`, `Main/Flows/Active/*`;
- `Main/Infrastructure/Persistence/*`, `Main/Infrastructure/Notifications/*`, `Main/Infrastructure/Audio/*`, `Main/Infrastructure/System/*`;
- `LiveActivity/Flows/*`, `LiveActivity/Infrastructure/Client/*`, `LiveActivity/Infrastructure/AppIntents/*`, `LiveActivity/Model/*`;
- `Main/Resources/Configuration/*`, `Main/Resources/Localization/*`, `Main/Resources/Audio/*`;
- `Makefile`, `scripts/generate.sh`, `scripts/xcodegen/*`, `scripts/swiftgen/*`, `scripts/fastlane/*`.

Тесты использовались только как дополнительный сигнал контракта, без документирования отдельных test cases.

## Слои

```text
+----------------------+      +----------------------+
| Main/App/            | ---> | Main/Flows/          |
| entry point, DI      |      | SwiftUI screens, VM  |
+----------------------+      +----------+-----------+
                                         |
                                         v
+----------------------+      +----------------------+
| Main/Infrastructure/ | <--- | Main/Core/          |
| persistence, audio,  |      | session engine,      |
| notifications, live  |      | boundary planning    |
| activity, system     |      +----------+-----------+
+----------------------+                 |
          ^                              v
          |                   +----------------------+
          +------------------>| Main/Model/          |
                              | domain state/types   |
                              +----------------------+
```

`AppDependencies` собирает единые production-зависимости в экранные модели и контроллеры. Конфигурация и активная сессия не копируются между экранами.

## Основные компоненты

| Компонент | Ответственность |
|---|---|
| `RootViewModel` | Корневая композиция и маршрутизация между setup и активной сессией; передаёт смену scene phase контроллеру сессии. |
| `TimerConfigurationController` | Единый владелец сохранённой редактируемой `TimerConfiguration` до запуска сессии. |
| `SetupViewModel` | Редактирование настроек, разрешение уведомлений и запуск. |
| `SoundSettingsViewModel` | Выбор и preview звуков через общую конфигурацию. |
| `ActiveTimerViewModel` | Presentation-модель активного таймера и действия паузы/остановки. |
| `WorkoutSessionController` | Единственный владелец активной сессии, тикера, persistence, уведомлений, Live Activity, idle timer, сигналов и аналитики. |
| `SessionEngine` | Чистая доменная логика запуска, переходов между фазами, паузы, продолжения и расчёта остатка. |
| `SessionBoundaryPlanner` | Построение будущих границ сессии для локальных уведомлений. |
| `TimerConfiguration` | Валидируемый снимок настроек: раунды, длительности, предупреждение и выбранные звуки. |
| `SessionState` | Сохранённое состояние активной сессии с абсолютной границей текущего этапа. |
| `NotificationScheduler` | Запрос разрешений, планирование и отмена локальных уведомлений по будущим границам. |
| `ForegroundSignalPlayer` | Воспроизведение foreground-сигналов и preview выбранных звуков через `AVAudioPlayer`. |
| `LiveActivityController` | Создание, обновление и завершение ActivityKit Live Activity. |
| `FirebaseAnalyticsTracker` | Отправляет в Firebase Analytics анонимные события жизненного цикла тренировки через проектный контракт `AnalyticsTracking`. |
| Firebase Crashlytics | Автоматически фиксирует необработанные сбои и загружает dSYM основного приложения для читаемых отчётов. |

## Поток сессии

```mermaid
sequenceDiagram
    participant UI as SetupView/RootView
    participant Setup as SetupViewModel
    participant Session as WorkoutSessionController
    participant Engine as SessionEngine
    participant Store as UserDefaults repositories
    participant Notifications as NotificationScheduler
    participant Activity as LiveActivityController

    UI->>Setup: start()
    Setup->>Session: start(configuration)
    Session->>Engine: start(configuration, now)
    Engine-->>Session: SessionState
    Session->>Store: save(SessionState)
    Session->>Notifications: schedule(for: state)
    Session->>Activity: start(for: state)
    Session->>Session: start ticker when scene is active and session is running
    loop every ~200 ms while scene is active and session is running
        Session->>Engine: resolve(state, now)
        Engine-->>Session: resolved state + signals
        Session->>Store: save or clear
        Session->>Notifications: reschedule when boundary signals occurred
        Session->>Activity: update or end
    end
```

Состояние таймера не выводится из количества UI-тиков. Для running-фазы источником истины является `phaseEndDate`; для паузы — `pausedRemaining`.
Тикер останавливается на паузе и при переходе приложения в неактивное состояние. При возвращении в foreground контроллер сначала
пересчитывает сессию по абсолютной границе, а затем возобновляет UI-тикер. Фоновые границы обслуживаются заранее запланированными
системными уведомлениями, а не продолжающим работать UI-циклом.

Если состояние сцены изменилось до завершения запуска, `RootViewModel` передаёт контроллеру последнее полученное состояние сцены.

После штатного завершения `WorkoutSessionController` публикует признак завершения для экрана настройки. Признак хранится в памяти до следующего запуска тренировки. Досрочная остановка его не устанавливает.

## Конфигурация и валидация

`TimerConfiguration.defaultValue` задаёт:

- `roundCount = 3`;
- `roundDuration = 180`;
- `restDuration = 60`;
- `preparationDuration = 10`;
- `roundWarning = .tenSeconds`;
- `soundConfiguration = .defaultValue`.

Валидная конфигурация ограничена диапазонами:

- раунды: `1...15`;
- раунд: `10...900` секунд;
- отдых: `0...300` секунд;
- подготовка: `0...300` секунд;
- все длительности кратны 5 секундам.

Пока сессия активна, `SetupViewModel` не меняет конфигурацию. Sound settings и setup используют один `TimerConfigurationController`, поэтому не получают расходящихся копий настроек.

Setup-экран не даёт пользователю ввести произвольное число с клавиатуры: длительности выбираются через `DurationPicker`, где минуты и секунды строятся из допустимого диапазона, а секунды идут с шагом 5.

## Переходы и сигналы

`SessionEngine.resolve(_:at:)` последовательно догоняет состояние до текущего времени. Если приложение пропустило несколько границ, engine может вернуть несколько сигналов, но foreground-воспроизведение в `WorkoutSessionController` выбирает только релевантный сигнал рядом с недавней границей и не проигрывает старые переходы задним числом.

Предупреждение конца раунда создаётся только когда:

- текущая фаза — `round`;
- предупреждение не `disabled`;
- длительность раунда больше выбранного предупреждения;
- предупреждение ещё не воспроизводилось в текущем раунде.

## Хранение

Конфигурация, активная сессия и состояние раскрытия setup-карточек сохраняются в `SharedDefaults.store` через JSON-кодирование в UserDefaults. `SharedDefaults.store` использует App Group `group.ru.kostyuchenko.fightclock`, поэтому Live Activity intents могут читать и обновлять активную сессию из extension.

При невалидной или нечитаемой сохранённой конфигурации используется `TimerConfiguration.defaultValue`. Завершённая сессия очищается, история тренировок в текущей версии не хранится.

## Аналитика

Основной target подключает зафиксированную версию `FirebaseAnalyticsCore` и `FirebaseCrashlytics` через Swift Package Manager. `FirebaseAppDelegate` конфигурирует Firebase только при наличии `GoogleService-Info.plist` в основном bundle и явно включает сбор Analytics; Crashlytics использует ту же конфигурацию. `FirebaseAnalyticsTracker` не вызывает SDK, если Firebase не сконфигурирован, поэтому приложение остаётся работоспособным без файла конфигурации. Финальная build phase Crashlytics загружает dSYM основного target для символикации отчётов о сбоях.

`WorkoutSessionController` передаёт в `AnalyticsTracking` события жизненного цикла тренировки; `SetupViewModel` передаёт `notification_permission_updated`. Событие старта содержит настройки сессии, а остальные события — номер текущего и общего раунда либо итоговый статус разрешения. Проектный слой не передаёт свой идентификатор пользователя, текстовые данные или идентификаторы сессии; Firebase Analytics при включённом сборе может автоматически собирать технические данные и идентификаторы своей установки.

## Уведомления

`NotificationScheduler` планирует локальные уведомления для будущих границ, которые возвращает `SessionBoundaryPlanner`. Перед новым планированием уведомления текущей сессии отменяются по идентификаторам вида `boxing-timer.boundary.<sessionID>.<notificationRevision>.<index>`. Диапазон индексов `0...44` покрывает максимальную конфигурацию MVP: подготовку, 15 предупреждений, 14 переходов к отдыху, 14 стартов следующего раунда и финальное завершение.

Планирование выполняется только при разрешении `.allowed`. Отказ в разрешении не блокирует активную сессию, но фоновые сигналы через системные уведомления не создаются.

## Live Activity

Live Activity содержит только данные отображения: фазу, текущий и общий номер раунда, `phaseEndDate`, `pausedRemaining` и флаг паузы. `staleDate` равен `phaseEndDate`, поэтому без выполнения кода приложения системное отображение не обещает автономно переключать этапы после ближайшей границы.

`PauseSessionIntent` и `ResumeSessionIntent` объявлены в extension: при вызове они читают `SessionState` из общего UserDefaults, пересчитывают состояние через `SessionEngine`, отменяют или заново планируют уведомления и обновляют ActivityKit-состояние. Текущие Lock Screen и Dynamic Island представления не содержат интерактивных элементов, которые вызывают эти intents; команды Stop также нет.

## Звук

Foreground-сигналы и preview используют встроенные ресурсы `BundledTimerSound`. По умолчанию:

- начало раунда: `singleGong`;
- переход к отдыху и завершение тренировки: `tripleGong`;
- предупреждение: `bongoDrumTrill`.

В модели конфигурации есть три независимые роли звука: `roundStartSound`, `roundTransitionSound` и `warningSound`. Начало отдыха и завершение тренировки используют общий `roundTransitionSound`, отдельного звука "финал тренировки" в текущей реализации нет.

Для foreground-воспроизведения и системных уведомлений используется точный выбранный WAV-ресурс.

`ForegroundSignalPlayer` использует категорию AVAudioSession `.playback` с `.duckOthers` и деактивирует сессию после завершения воспроизведения.

## Инварианты

- `SessionEngine` не имеет зависимостей от UI, UserDefaults, уведомлений или ActivityKit.
- Запуск сессии фиксирует снимок конфигурации; изменения настроек применяются только до запуска.
- Пауза отменяет будущие уведомления и удаляет `phaseEndDate`; продолжение создаёт новую границу от текущего времени.
- Штатное и досрочное завершение очищают сохранённую активную сессию, отменяют уведомления, включают обратно системную автоблокировку и завершают Live Activity.
- Foreground-звук завершения при штатном окончании проигрывается только если приложение активно и граница была недавней.

## Ограничения

- iOS-режимы Silent Mode, Focus, звонки и аудиомаршруты могут помешать слышимости фоновых сигналов.
- После force quit нельзя рассчитывать на выполнение кода приложения; восстановление происходит при следующем запуске.
- Live Activity без push-обновлений не является фоновым процессом таймера.
- В репозитории используются встроенные аудиоресурсы; часть файлов названа как placeholder.
- App Store metadata, privacy text и release notes не обнаружены в репозитории как готовые артефакты.

## Связанные документы

- [Product Requirements Document](../product/prd.md)
- [UX Flow](../ux/flow.md)
- [Локальные скрипты и доставка](scripts.md)
