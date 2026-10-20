local SettingsManager = require("settingsManager")
local Logger = {}

local LEVEL_ERROR = 0
local LEVEL_WARNING = 1
local LEVEL_INFO = 2
local LEVEL_DEBUG = 3
local LEVEL_TRACE = 4

local prefixes = {
    [LEVEL_ERROR] = "[ERROR]  ",
    [LEVEL_WARNING] = "[WARN]   ",
    [LEVEL_INFO] = "[INFO]   ",
    [LEVEL_DEBUG] = "[DEBUG]  ",
    [LEVEL_TRACE] = "[TRACE]  "
}

local function GetCurrentLevel()
    if not SettingsManager.Get("EnableDebugLog") then
        return LEVEL_ERROR
    end
    return SettingsManager.Get("DebugLogLevel") or LEVEL_INFO
end

local function LogAt(level, context, message)
    if level <= GetCurrentLevel() then
        print("[MinimapVisibilityFix] " .. prefixes[level] .. "[" .. context .. "] " .. message)
    end
end

function Logger.Error(context, message) LogAt(LEVEL_ERROR, context, message) end
function Logger.Warn(context, message) LogAt(LEVEL_WARNING, context, message) end
function Logger.Info(context, message) LogAt(LEVEL_INFO, context, message) end
function Logger.Debug(context, message) LogAt(LEVEL_DEBUG, context, message) end
function Logger.Trace(context, message) LogAt(LEVEL_TRACE, context, message) end

return Logger
