# App Store Connect — Fight Clock 1.0.3

## Основание

- Версия: `1.0.3` (предыдущая: `1.0.2`), build `1`.
- Диапазон изменений: `76ed86a..HEAD` (текущий `HEAD`: `19b5234`).
- Статус версии: committed.
- Подтверждённые пользовательские изменения: обновлены настройка тренировки и выбор звуков, подсказки о фоновых сигналах и разрешении на уведомления, а также представление Live Activity и состояние устаревших данных.
- Не включено: реорганизация кода, тесты, генерация проекта, CI и незакоммиченные изменения существующего документа App Store.

## App Information

| Поле App Store Connect | Значение для заполнения | Статус |
| --- | --- | --- |
| Primary Language | `English (U.S.)` | подтверждено: development region `en`, английская первая локаль |
| Primary Category | `Health & Fitness` | подтверждено назначением приложения |
| Secondary Category | `Sports` | подтверждено назначением приложения |
| Age Rating | В анкете выбрать отсутствие всех категорий контента; ожидаемый результат — `4+`. | подтверждено репозиторием; итоговый рейтинг рассчитывает App Store Connect |
| App Encryption Documentation | Выбрать `No`: приложение не использует non-exempt encryption. | подтверждено `ITSAppUsesNonExemptEncryption = NO` |
| App Store Regulation & Permits | Выбрать `No`: офлайн-таймер не предлагает регулируемые товары или услуги, медицинскую диагностику, финансовые операции, азартные игры или иной лицензируемый контент. | требует подтверждения владельцем аккаунта для стран распространения и статуса продавца |
| App Store Server Notifications | Не настраивать: Production URL и Sandbox URL оставить пустыми. | подтверждено: нет IAP, подписок, App Store Server API или backend |

### Age Rating — ответы анкеты

Для всех категорий контента выбрать отсутствие. В приложении нет насилия, азартных игр, сексуального контента, ненормативной лексики, медицинских рекомендаций, пользовательского контента, чата, сообщений, открытого веб-доступа, покупок, рекламы или социальных взаимодействий.

### App Encryption Documentation

`ITSAppUsesNonExemptEncryption` установлен в `NO`. В приложении нет сетевого обмена и собственного криптографического функционала, поэтому документация об экспортном шифровании не требуется.

## Русский

### Name

Fight Clock  
Символов: 11/30

### Subtitle

Таймер боксёрских раундов  
Символов: 26/30

### Description

Fight Clock — точный таймер раундов для боксёрских тренировок. Настройте количество раундов, время подготовки, длительность раунда и отдыха, а также предупреждение за 10 или 30 секунд до конца. Выберите встроенные звуки для начала раунда, переходов и предупреждений — и запустите тренировку одним нажатием.

Во время сессии крупный таймер показывает текущий этап, номер раунда и оставшееся время. Тренировку можно поставить на паузу, продолжить или завершить в любой момент. Последние настройки сохраняются на устройстве, поэтому к следующей тренировке легко вернуться.

Разрешите уведомления, чтобы слышать запланированные сигналы при заблокированном экране или в фоне. Live Activity помогает видеть ключевую информацию о тренировке с первого взгляда. На слышимость фоновых сигналов могут влиять Беззвучный режим, Фокусирование, звонки и настройки уведомлений.

Fight Clock работает без аккаунта, рекламы, покупок и подключения к интернету.

Символов: 871/4000

### What’s New

• Обновили настройку тренировки: раунды, подготовку, отдых и звуки стало проще настроить.
• Улучшили подсказки для фоновых сигналов и разрешений на уведомления.
• Обновили Live Activity: состояние тренировки и устаревшие данные теперь понятнее.

### Promotional Text

Точные раунды. Ничего лишнего.  
Символов: 31/170

## English (U.S.)

### Name

Fight Clock  
Characters: 11/30

### Subtitle

Boxing Round Timer  
Characters: 18/30

### Description

Fight Clock is a precise round timer for boxing training. Set the number of rounds, preparation time, round duration, rest time, and an optional 10- or 30-second warning. Choose built-in sounds for round starts, transitions, and warnings, then start your workout in one tap.

During a session, the large timer shows the current phase, round number, and remaining time. Pause, resume, or end a workout whenever you need. Your latest settings are saved on your device, so it is easy to return to your next session.

Allow notifications to hear scheduled signals while the screen is locked or the app is in the background. Live Activity helps keep key workout information visible at a glance. Silent Mode, Focus, calls, and notification settings can affect whether background signals are heard.

Fight Clock works without an account, ads, purchases, or an internet connection.

Characters: 790/4000

### What’s New

• Refreshed workout setup with clearer controls for rounds, preparation, rest, and sounds.
• Improved guidance for background timer signals and notification permissions.
• Updated the Live Activity with clearer session and stale-state information.

### Promotional Text

Precise rounds. No distractions.  
Characters: 32/170

## App Privacy, URLs and review materials

| Поле App Store Connect | Значение |
| --- | --- |
| Privacy Labels | `Data Not Collected`; tracking отсутствует. Настройки и состояние активной тренировки хранятся только локально в `UserDefaults`. |
| Privacy Policy URL | `https://cobug92.github.io/Fight-Clock/site/privacy/` |
| User Privacy Choices URL | Оставить пустым: приложение не собирает и не передаёт данные и не предоставляет соответствующих настроек. |
| Support URL | `https://cobug92.github.io/Fight-Clock/site/support/` |
| Marketing URL | Не заполнять: отдельная страница не подготовлена. |
| Product Page Preview | Не добавлять: в репозитории есть только статичные скриншоты, а не видео App Preview. |
| Pricing | Не менять. |
| Copyright | Не менять. |
| App Review Information — Testing Notes | Не менять: нет аккаунтов, входа, демо-доступа или особых шагов для проверки. |

### Скриншоты

- English (U.S.): `docs/AppStore/Preview/en/01.png` … `07.png`.
- Russian: `docs/AppStore/Preview/ru/01.png` … `07.png`.
- Каждый файл: 1242×2688 px.
- Общий архив: `docs/AppStore/Preview/FightClock-AppStore-Previews.zip`.

### App Accessibility

До ручной проверки релизной сборки не отмечать функции универсального доступа в App Store Connect. VoiceOver — кандидат для тестирования: у ключевых элементов есть accessibility-метаданные. Larger Text, Voice Control, Differentiate Without Color, Sufficient Contrast, Reduced Motion и остальные категории требуют отдельной проверки на устройстве.

## Проверить перед отправкой

- Выбрать загруженный build `1.0.3 (1)`.
- Убедиться, что Support URL и Privacy Policy URL публично доступны.
- Загрузить семь скриншотов в каждую соответствующую локаль без смешения русского и английского интерфейса.
- Не заявлять интерактивное управление из Live Activity: текущий UI его не показывает.
- Не обещать слышимость фоновых сигналов при любых системных настройках: Беззвучный режим, Фокусирование и звонки могут их заглушить.
- Подтвердить ответ о регулировании и разрешениях от имени владельца аккаунта.
