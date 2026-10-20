local SettingsManager = require("settingsManager")
local NativeSettingsUI = require("nativeSettingsUI")
local Logger = require("logger")

registerForEvent("onInit", function()
    SettingsManager.Load()
    SettingsManager.OverrideConfigFunctions()
    local nativeSettings = GetMod("nativeSettings")
    if nativeSettings then
        NativeSettingsUI.Build(nativeSettings, SettingsManager)
    end
    Logger.Info("Init", "Initialized")
end)

registerForEvent("onShutdown", function()
    SettingsManager.Save()
end)

return true
