module MinimapVisibilityFix.Logging

import MinimapVisibilityFixConfig.*

public enum LogLevel {
  ERROR = 0,
  WARNING = 1,
  INFO = 2,
  DEBUG = 3,
  TRACE = 4
}

public class LoggerStateSystem extends ScriptableSystem {
  private let m_lastLogMessage: String;
  private let m_lastLogContext: String;
  private let m_lastLogTimestamp: Float;
  private let m_duplicateCount: Int32;

  private func OnAttach() {
    this.m_lastLogMessage = "";
    this.m_lastLogContext = "";
    this.m_lastLogTimestamp = 0.0;
    this.m_duplicateCount = 0;
  }

  public func GetLastMessage() -> String { return this.m_lastLogMessage; }
  public func GetLastContext() -> String { return this.m_lastLogContext; }
  public func GetLastTimestamp() -> Float { return this.m_lastLogTimestamp; }
  public func GetDuplicateCount() -> Int32 { return this.m_duplicateCount; }
  public func SetLastMessage(message: String) { this.m_lastLogMessage = message; }
  public func SetLastContext(context: String) { this.m_lastLogContext = context; }
  public func SetLastTimestamp(time: Float) { this.m_lastLogTimestamp = time; }
  public func SetDuplicateCount(count: Int32) { this.m_duplicateCount = count; }
  public func IncrementDuplicateCount() { this.m_duplicateCount += 1; }
}

private static func GetCurrentLogLevel() -> LogLevel {
  if !MVFSettings.EnableDebugLog() {
    return LogLevel.ERROR;
  }
  let level: Int32 = MVFSettings.DebugLogLevel();
  switch level {
    case 0: return LogLevel.ERROR;
    case 1: return LogLevel.WARNING;
    case 2: return LogLevel.INFO;
    case 3: return LogLevel.DEBUG;
    default: return LogLevel.TRACE;
  }
}

public static func MVFError(context: String, message: String) -> Void {
  LogWithLevel(LogLevel.ERROR, context, message);
}

public static func MVFWarn(context: String, message: String) -> Void {
  if EnumInt(GetCurrentLogLevel()) >= EnumInt(LogLevel.WARNING) {
    LogWithLevel(LogLevel.WARNING, context, message);
  }
}

public static func MVFInfo(context: String, message: String) -> Void {
  if EnumInt(GetCurrentLogLevel()) >= EnumInt(LogLevel.INFO) {
    LogWithLevel(LogLevel.INFO, context, message);
  }
}

public static func MVFDebug(context: String, message: String) -> Void {
  if EnumInt(GetCurrentLogLevel()) >= EnumInt(LogLevel.DEBUG) {
    LogWithLevel(LogLevel.DEBUG, context, message);
  }
}

public static func MVFTrace(context: String, message: String) -> Void {
  if EnumInt(GetCurrentLogLevel()) >= EnumInt(LogLevel.TRACE) {
    LogWithLevel(LogLevel.TRACE, context, message);
  }
}

private static func LogWithLevel(level: LogLevel, context: String, message: String) -> Void {
  let gameInstance: GameInstance = GetGameInstance();
  let loggerState: ref<LoggerStateSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"MinimapVisibilityFix.Logging.LoggerStateSystem") as LoggerStateSystem;
  if !IsDefined(loggerState) {
    ModLog(n"MinimapVisibilityFix", GetLevelPrefix(level) + " [" + context + "] " + message);
    return;
  }
  let currentTime: Float = EngineTime.ToFloat(GameInstance.GetSimTime(gameInstance));
  let timeSinceLastLog: Float = currentTime - loggerState.GetLastTimestamp();
  if timeSinceLastLog < 5.0 && Equals(loggerState.GetLastContext(), context) && Equals(loggerState.GetLastMessage(), message) {
    loggerState.IncrementDuplicateCount();
    return;
  }
  if loggerState.GetDuplicateCount() > 0 {
    ModLog(n"MinimapVisibilityFix", GetLevelPrefix(level) + " [" + loggerState.GetLastContext() + "] -> Previous message repeated " + ToString(loggerState.GetDuplicateCount()) + " times");
    loggerState.SetDuplicateCount(0);
  }
  ModLog(n"MinimapVisibilityFix", GetLevelPrefix(level) + " [" + context + "] " + message);
  loggerState.SetLastMessage(message);
  loggerState.SetLastContext(context);
  loggerState.SetLastTimestamp(currentTime);
}

private static func GetLevelPrefix(level: LogLevel) -> String {
  switch level {
    case LogLevel.ERROR: return "[ERROR]  ";
    case LogLevel.WARNING: return "[WARN]   ";
    case LogLevel.INFO: return "[INFO]   ";
    case LogLevel.DEBUG: return "[DEBUG]  ";
    case LogLevel.TRACE: return "[TRACE]  ";
  }
  return "[UNKNOWN]";
}
