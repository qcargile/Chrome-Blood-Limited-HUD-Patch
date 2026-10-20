local NativeSettingsUI = {}
local debugOptionTable = nil

function NativeSettingsUI.Build(nativeSettings, SettingsManager)
    local settings = SettingsManager.GetAll()
    nativeSettings.addTab("/MinimapVisibilityFix", "Minimap Visibility Fix")
    nativeSettings.addSubcategory("/MinimapVisibilityFix/Debug", "Debug")
    nativeSettings.addSwitch("/MinimapVisibilityFix/Debug", "Enable Debug Log", "Master toggle for diagnostic output. When off, only ERROR-level output is written.", settings.EnableDebugLog, false, function(state) SettingsManager.Set("EnableDebugLog", state) SettingsManager.Save() NativeSettingsUI.RebuildDebugOptions(nativeSettings, SettingsManager) end)
    NativeSettingsUI.CreateDebugOptions(nativeSettings, SettingsManager)
end

function NativeSettingsUI.RebuildDebugOptions(nativeSettings, SettingsManager)
    NativeSettingsUI.ClearDebugOptions(nativeSettings)
    NativeSettingsUI.CreateDebugOptions(nativeSettings, SettingsManager)
    nativeSettings.refresh()
end

function NativeSettingsUI.ClearDebugOptions(nativeSettings)
    if debugOptionTable ~= nil then nativeSettings.removeOption(debugOptionTable) debugOptionTable = nil end
end

function NativeSettingsUI.CreateDebugOptions(nativeSettings, SettingsManager)
    local settings = SettingsManager.GetAll()
    if settings.EnableDebugLog then
        local levels = { "ERROR", "WARNING", "INFO", "DEBUG", "TRACE" }
        debugOptionTable = nativeSettings.addSelectorString("/MinimapVisibilityFix/Debug", "Debug Log Level", "How much detail to log.", levels, settings.DebugLogLevel + 1, 3, function(value) SettingsManager.Set("DebugLogLevel", value - 1) SettingsManager.Save() end)
    end
end

return NativeSettingsUI
