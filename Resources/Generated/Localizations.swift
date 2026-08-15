// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Localizations {
  internal enum Accessibility {
    /// Оставшееся время
    internal static let remainingTime = Localizations.tr("Localizable", "accessibility.remaining_time", fallback: "Оставшееся время")
    /// Запускает обратный отсчёт до первого раунда
    internal static let startHint = Localizations.tr("Localizable", "accessibility.start_hint", fallback: "Запускает обратный отсчёт до первого раунда")
  }
  internal enum Action {
    /// Отмена
    internal static let cancel = Localizations.tr("Localizable", "action.cancel", fallback: "Отмена")
    /// Пауза
    internal static let pause = Localizations.tr("Localizable", "action.pause", fallback: "Пауза")
    /// Продолжить
    internal static let resume = Localizations.tr("Localizable", "action.resume", fallback: "Продолжить")
    /// Начать
    internal static let start = Localizations.tr("Localizable", "action.start", fallback: "Начать")
    /// Завершить
    internal static let stop = Localizations.tr("Localizable", "action.stop", fallback: "Завершить")
  }
  internal enum Active {
    /// ПАУЗА
    internal static let paused = Localizations.tr("Localizable", "active.paused", fallback: "ПАУЗА")
    /// ПОДГОТОВКА
    internal static let preparation = Localizations.tr("Localizable", "active.preparation", fallback: "ПОДГОТОВКА")
    /// ОТДЫХ
    internal static let rest = Localizations.tr("Localizable", "active.rest", fallback: "ОТДЫХ")
    /// РАУНД
    internal static let round = Localizations.tr("Localizable", "active.round", fallback: "РАУНД")
    /// Раунд %d из %d
    internal static func roundProgress(_ p1: Int, _ p2: Int) -> String {
      return Localizations.tr("Localizable", "active.round_progress", p1, p2, fallback: "Раунд %d из %d")
    }
  }
  internal enum Activity {
    /// Открыть
    internal static let openApp = Localizations.tr("Localizable", "activity.open_app", fallback: "Открыть")
    /// ПАУЗА
    internal static let paused = Localizations.tr("Localizable", "activity.paused", fallback: "ПАУЗА")
    /// ПОДГОТОВКА
    internal static let preparation = Localizations.tr("Localizable", "activity.preparation", fallback: "ПОДГОТОВКА")
    /// ОТДЫХ
    internal static let rest = Localizations.tr("Localizable", "activity.rest", fallback: "ОТДЫХ")
    /// РАУНД
    internal static let round = Localizations.tr("Localizable", "activity.round", fallback: "РАУНД")
    /// НУЖНО ОБНОВИТЬ
    internal static let stale = Localizations.tr("Localizable", "activity.stale", fallback: "НУЖНО ОБНОВИТЬ")
    /// Устарело
    internal static let staleShort = Localizations.tr("Localizable", "activity.stale_short", fallback: "Устарело")
  }
  internal enum App {
    /// FIGHT CLOCK
    internal static let name = Localizations.tr("Localizable", "app.name", fallback: "FIGHT CLOCK")
  }
  internal enum Intent {
    /// Открыть Fight Clock
    internal static let openApp = Localizations.tr("Localizable", "intent.open_app", fallback: "Открыть Fight Clock")
    /// Пауза
    internal static let pause = Localizations.tr("Localizable", "intent.pause", fallback: "Пауза")
    /// Продолжить
    internal static let resume = Localizations.tr("Localizable", "intent.resume", fallback: "Продолжить")
  }
  internal enum Notification {
    /// Тренировка завершена
    internal static let complete = Localizations.tr("Localizable", "notification.complete", fallback: "Тренировка завершена")
    /// Отдых
    internal static let rest = Localizations.tr("Localizable", "notification.rest", fallback: "Отдых")
    /// Следующий раунд
    internal static let round = Localizations.tr("Localizable", "notification.round", fallback: "Следующий раунд")
    /// Fight Clock
    internal static let title = Localizations.tr("Localizable", "notification.title", fallback: "Fight Clock")
    /// До конца раунда %d секунд
    internal static func warning(_ p1: Int) -> String {
      return Localizations.tr("Localizable", "notification.warning", p1, fallback: "До конца раунда %d секунд")
    }
  }
  internal enum Permission {
    /// Разрешить уведомления
    internal static let allow = Localizations.tr("Localizable", "permission.allow", fallback: "Разрешить уведомления")
    /// Разрешите уведомления, чтобы слышать сигналы при заблокированном экране. Беззвучный режим, Focus и звонки могут их заглушить.
    internal static let explanation = Localizations.tr("Localizable", "permission.explanation", fallback: "Разрешите уведомления, чтобы слышать сигналы при заблокированном экране. Беззвучный режим, Focus и звонки могут их заглушить.")
    /// Фоновые сигналы
    internal static let title = Localizations.tr("Localizable", "permission.title", fallback: "Фоновые сигналы")
  }
  internal enum Setup {
    /// Время на подготовку
    internal static let preparationDuration = Localizations.tr("Localizable", "setup.preparation_duration", fallback: "Время на подготовку")
    /// Длительность отдыха
    internal static let restDuration = Localizations.tr("Localizable", "setup.rest_duration", fallback: "Длительность отдыха")
    /// Длительность раунда
    internal static let roundDuration = Localizations.tr("Localizable", "setup.round_duration", fallback: "Длительность раунда")
    /// Раунды
    internal static let rounds = Localizations.tr("Localizable", "setup.rounds", fallback: "Раунды")
    /// Точные раунды. Ничего лишнего.
    internal static let tagline = Localizations.tr("Localizable", "setup.tagline", fallback: "Точные раунды. Ничего лишнего.")
    internal enum Sound {
      /// Звуки раунда
      internal static let title = Localizations.tr("Localizable", "setup.sound.title", fallback: "Звуки раунда")
    }
    internal enum Warning {
      /// Выкл.
      internal static let disabled = Localizations.tr("Localizable", "setup.warning.disabled", fallback: "Выкл.")
      /// 10 сек
      internal static let tenSeconds = Localizations.tr("Localizable", "setup.warning.ten_seconds", fallback: "10 сек")
      /// 30 сек
      internal static let thirtySeconds = Localizations.tr("Localizable", "setup.warning.thirty_seconds", fallback: "30 сек")
      /// Сигнал до конца раунда
      internal static let title = Localizations.tr("Localizable", "setup.warning.title", fallback: "Сигнал до конца раунда")
    }
  }
  internal enum SoundSettings {
    /// Начало раунда
    internal static let roundStart = Localizations.tr("Localizable", "sound_settings.round_start", fallback: "Начало раунда")
    /// Используется при старте раунда, включая первый раунд после подготовки.
    internal static let roundStartFooter = Localizations.tr("Localizable", "sound_settings.round_start_footer", fallback: "Используется при старте раунда, включая первый раунд после подготовки.")
    /// Конец раунда и переход
    internal static let roundTransition = Localizations.tr("Localizable", "sound_settings.round_transition", fallback: "Конец раунда и переход")
    /// Используется в конце раунда и при завершении тренировки.
    internal static let roundTransitionFooter = Localizations.tr("Localizable", "sound_settings.round_transition_footer", fallback: "Используется в конце раунда и при завершении тренировки.")
    /// Звуки раунда
    internal static let title = Localizations.tr("Localizable", "sound_settings.title", fallback: "Звуки раунда")
    /// Предупреждение
    internal static let warning = Localizations.tr("Localizable", "sound_settings.warning", fallback: "Предупреждение")
    /// Используется для выбранного предупреждения перед концом раунда.
    internal static let warningFooter = Localizations.tr("Localizable", "sound_settings.warning_footer", fallback: "Используется для выбранного предупреждения перед концом раунда.")
    internal enum Sound {
      /// Дробь на бонго
      internal static let bongoDrumTrill = Localizations.tr("Localizable", "sound_settings.sound.bongo_drum_trill", fallback: "Дробь на бонго")
      /// Яркий колокол
      internal static let brightBell = Localizations.tr("Localizable", "sound_settings.sound.bright_bell", fallback: "Яркий колокол")
      /// Ритм из четырёх щелчков
      internal static let clickQuartetRhythm = Localizations.tr("Localizable", "sound_settings.sound.click_quartet_rhythm", fallback: "Ритм из четырёх щелчков")
      /// Ритмический узор
      internal static let rhythmicPattern = Localizations.tr("Localizable", "sound_settings.sound.rhythmic_pattern", fallback: "Ритмический узор")
      /// Одиночный гонг
      internal static let singleGong = Localizations.tr("Localizable", "sound_settings.sound.single_gong", fallback: "Одиночный гонг")
      /// Тройной гонг
      internal static let tripleGong = Localizations.tr("Localizable", "sound_settings.sound.triple_gong", fallback: "Тройной гонг")
    }
  }
  internal enum Stop {
    /// Завершить тренировку
    internal static let confirm = Localizations.tr("Localizable", "stop.confirm", fallback: "Завершить тренировку")
    /// Текущая сессия не будет сохранена в историю.
    internal static let message = Localizations.tr("Localizable", "stop.message", fallback: "Текущая сессия не будет сохранена в историю.")
    /// Завершить тренировку?
    internal static let title = Localizations.tr("Localizable", "stop.title", fallback: "Завершить тренировку?")
  }
  internal enum Time {
    /// Минуты
    internal static let minutes = Localizations.tr("Localizable", "time.minutes", fallback: "Минуты")
    /// Секунды
    internal static let seconds = Localizations.tr("Localizable", "time.seconds", fallback: "Секунды")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localizations {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
