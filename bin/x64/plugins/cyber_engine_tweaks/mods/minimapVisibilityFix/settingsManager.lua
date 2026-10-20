local SettingsManager = {}

local defaults = {
    EnableDebugLog = false,
    DebugLogLevel = 2
}

local current = {}
for key, value in pairs(defaults) do current[key] = value end

function SettingsManager.Load()
    local file = io.open("settings.json", "r")
    if file ~= nil then
        local contents = file:read("*a")
        local validJson, savedState = pcall(function() return json.decode(contents) end)
        file:close()
        if validJson and type(savedState) == "table" then
            local seededNew = false
            if type(savedState.EnableDebugLog) == "boolean" then
                current.EnableDebugLog = savedState.EnableDebugLog
            else
                seededNew = true
            end
            if type(savedState.DebugLogLevel) == "number" and savedState.DebugLogLevel == math.floor(savedState.DebugLogLevel) and savedState.DebugLogLevel >= 0 and savedState.DebugLogLevel <= 4 then
                current.DebugLogLevel = savedState.DebugLogLevel
            else
                seededNew = true
            end
            if seededNew then SettingsManager.Save() end
            return true
        end
    end
    return false
end

function SettingsManager.Save()
    local validJson, contents = pcall(function() return json.encode(current) end)
    if validJson and contents ~= nil then
        local file = io.open("settings.json", "w+")
        if file == nil then return false end
        file:write(contents)
        file:close()
        return true
    end
    return false
end

function SettingsManager.Get(key) return current[key] end
function SettingsManager.Set(key, value) current[key] = value end
function SettingsManager.GetAll() return current end

function SettingsManager.OverrideConfigFunctions()
    Override("MinimapVisibilityFixConfig.MVFSettings", "EnableDebugLog;", function() return current.EnableDebugLog end)
    Override("MinimapVisibilityFixConfig.MVFSettings", "DebugLogLevel;", function() return current.DebugLogLevel end)
end

return SettingsManager
