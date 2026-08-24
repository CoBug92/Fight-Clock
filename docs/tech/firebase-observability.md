# Firebase Analytics и Crashlytics

## Назначение

Fight Clock использует Firebase для двух задач:

- Firebase Analytics — для понимания жизненного цикла тренировок и результата запроса разрешения на уведомления;
- Firebase Crashlytics — для получения отчётов о необработанных сбоях и их символикации.

В проекте нет пользовательских аккаунтов, IDFA и вручную заданного Firebase user ID.

## Конфигурация

Основной target `Main` подключает через Swift Package Manager Firebase `12.17.0`:

- `FirebaseAnalyticsCore` — Analytics без зависимости для доступа к IDFA;
- `FirebaseCrashlytics` — сбор отчётов о сбоях.

Конфигурация Firebase хранится в `Main/Resources/Configuration/GoogleService-Info.plist`. Файл должен соответствовать bundle identifier `ru.kostyuchenko.fightclock` и Firebase-проекту `fight-clock-79eda`.

`FirebaseAppDelegate` вызывает `FirebaseApp.configure()` при наличии этого файла в bundle, затем явно включает Analytics. Если конфигурационный файл отсутствует, `FirebaseAnalyticsTracker` не вызывает SDK, поэтому запуск приложения не блокируется.

## События Analytics

События объявлены в `AnalyticsEvent` и отправляются `FirebaseAnalyticsTracker` через контракт `AnalyticsTracking`.

| Событие | Когда отправляется | Параметры |
|---|---|---|
| `workout_started` | Сессия успешно запущена | Число раундов, длительности подготовки, раунда и отдыха, интервал предупреждения. |
| `workout_paused` | Пользователь поставил сессию на паузу | Текущий и общий номер раунда. |
| `workout_resumed` | Пользователь продолжил сессию | Текущий и общий номер раунда. |
| `workout_stopped` | Пользователь досрочно остановил сессию | Текущий и общий номер раунда. |
| `workout_completed` | Сессия завершилась штатно | Текущий и общий номер раунда. |
| `notification_permission_updated` | Получен результат явного запроса разрешения | Категория статуса разрешения. |

События не содержат текста, идентификатора пользователя или идентификатора сессии. Параметры конфигурации тренировки передаются как точные числовые значения — это осознанный продуктовый выбор.

## Проверка Analytics

Для проверки в Firebase DebugView запустите приложение из Xcode на физическом iPhone с аргументом:

```text
-FIRAnalyticsDebugEnabled
```

В Console должны появиться строки `Debug logging enabled`, `Event logged` и для успешной передачи `Successful upload` с кодом `204`.

В Firebase Console откройте Analytics → DebugView. Для этого приложения используется Google Analytics property `fight-clock-79eda` и iOS stream `Fight Clock` с bundle identifier `ru.kostyuchenko.fightclock`. После проверки удалите аргумент запуска: debug-события предназначены только для разработки.

## Crashlytics и dSYM

Crashlytics запускается автоматически после `FirebaseApp.configure()`; отдельный вызов в коде не нужен. В основном target есть финальная build phase `Upload Crashlytics Symbols`, которая запускает официальный скрипт Firebase и передаёт dSYM для символикации стеков.

`DEBUG_INFORMATION_FORMAT` для основного target — `dwarf-with-dsym`. Скрипт запускается при каждой сборке. Для совместимости Xcode 26 и Firebase SPM у основного target отключён `ENABLE_USER_SCRIPT_SANDBOXING`: официальный скрипт Firebase читает файлы из `SourcePackages`, которые Xcode не разрешил даже после их явного объявления input files. Это исключение ограничено target `Main`.

Проверка build phase успешна, когда в логе сборки есть:

```text
Validating build environment for Crashlytics...
Validation succeeded. Symbol uploading will proceed in the background.
```

Не создавайте намеренный crash в рабочем пользовательском окружении. Для контролируемой проверки используйте отдельную debug-сборку на тестовом устройстве и затем проверьте Firebase Console → Crashlytics.

## Приватность и выпуск

Firebase Analytics автоматически собирает данные приложения, устройства и технические идентификаторы, а приложение передаёт события тренировок. Crashlytics передаёт отчёты о сбоях и диагностические данные, нужные для их исследования. Эти практики отражены в `docs/site/privacy/index.html`.

Перед выпуском необходимо вручную сверить App Store Connect App Privacy с фактической интеграцией Analytics и Crashlytics. Добавление SDK в репозиторий не обновляет декларацию в App Store Connect автоматически.
