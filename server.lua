local Clock = {
    year   = Config.StartTime.year,
    month  = Config.StartTime.month,
    day    = Config.StartTime.day,
    hour   = Config.StartTime.hour,
    minute = Config.StartTime.minute,
    frozen = false,
}

local GlobalWeather = {
    current       = Config.WeatherTransitions.EXTRASUNNY and 'EXTRASUNNY' or 'CLEAR',
    nextChangeMin = 0,
}

local function weightedPick(weights)
    local total = 0
    for _, w in pairs(weights) do total = total + w end
    local roll = math.random() * total
    local cumulative = 0
    for weather, w in pairs(weights) do
        cumulative = cumulative + w
        if roll <= cumulative then return weather end
    end
    local keys = {}; for k in pairs(weights) do keys[#keys + 1] = k end
    return keys[#keys]
end

local function minuteToHour(gameMinute)
    return math.floor((gameMinute % 1440) / 60)
end

local function totalGameMinutes()
    return (Clock.year - 1) * 12 * 30 * 1440
         + (Clock.month - 1) * 30 * 1440
         + (Clock.day - 1) * 1440
         + Clock.hour * 60
         + Clock.minute
end

local function getEffectiveWeights(currentWeather, gameMinute)
    local transitions = Config.WeatherTransitions[currentWeather]
    if not transitions then
        return Config.WeatherTransitions.CLEAR or { CLEAR = 100 }
    end
    local hour = minuteToHour(gameMinute)
    local mods = Config.WeatherHourModifiers[hour]
    if not mods then return transitions end
    local effective = {}
    for weather, weight in pairs(transitions) do
        local w = weight * (mods[weather] or 1.0)
        if w > 0 then effective[weather] = w end
    end
    if next(effective) == nil then return transitions end
    return effective
end

-- ── Access Control ─────────────────────────────────────────────────

local function hasAccess(playerId)
    if Config.Access.disable then return true end

    local checks = 0
    local passed = 0

    if Config.Access.identifiers and #Config.Access.identifiers > 0 then
        checks = checks + 1
        local playerIdentifiers = GetPlayerIdentifiers(playerId)
        for _, id in ipairs(playerIdentifiers) do
            for _, allowed in ipairs(Config.Access.identifiers) do
                if id == allowed then passed = passed + 1; break end
            end
            if passed > 0 then break end
        end
    end

    if Config.Access.esx_groups and #Config.Access.esx_groups > 0 then
        checks = checks + 1
        local xPlayer = ESX and ESX.GetPlayerFromId and ESX.GetPlayerFromId(playerId)
        if xPlayer and xPlayer.getGroup then
            local g = xPlayer.getGroup()
            for _, allowed in ipairs(Config.Access.esx_groups) do
                if g == allowed then passed = passed + 1; break end
            end
        end
    end

    if Config.Access.qb_groups and #Config.Access.qb_groups > 0 then
        checks = checks + 1
        local Player = QBCore and QBCore.Functions and QBCore.Functions.GetPlayer and QBCore.Functions.GetPlayer(playerId)
        if Player and Player.PlayerData then
            local g = Player.PlayerData.job and Player.PlayerData.job.name or Player.PlayerData.group
            for _, allowed in ipairs(Config.Access.qb_groups) do
                if g == allowed then passed = passed + 1; break end
            end
        end
    end

    if checks == 0 then return true end
    return passed > 0
end

local function advanceClock(dtMinutes)
    if Clock.frozen then return end
    Clock.minute = Clock.minute + dtMinutes
    if Clock.minute >= 60 then
        local overflow = math.floor(Clock.minute / 60)
        Clock.minute = Clock.minute % 60
        Clock.hour = Clock.hour + overflow
        if Clock.hour >= 24 then
            local dayOverflow = math.floor(Clock.hour / 24)
            Clock.hour = Clock.hour % 24
            Clock.day = Clock.day + dayOverflow
            if Clock.day > 30 then
                local monthOverflow = math.floor((Clock.day - 1) / 30)
                Clock.day = ((Clock.day - 1) % 30) + 1
                Clock.month = Clock.month + monthOverflow
                if Clock.month > 12 then
                    local yearOverflow = math.floor((Clock.month - 1) / 12)
                    Clock.month = ((Clock.month - 1) % 12) + 1
                    Clock.year = Clock.year + yearOverflow
                end
            end
        end
    end
    -- scrub floating-point noise from repeated decimal accumulation
    Clock.minute = tonumber(string.format('%.3f', Clock.minute))
end

local function updateGlobalWeather(currentGameMinute)
    if currentGameMinute < GlobalWeather.nextChangeMin then return end
    local weights = getEffectiveWeights(GlobalWeather.current, currentGameMinute)
    GlobalWeather.current = weightedPick(weights)
    GlobalWeather.nextChangeMin = currentGameMinute + Config.WeatherChangeIntervalMin
end

local function buildSyncPayload()
    return {
        frozen    = Clock.frozen,
        timeSpeed = Config.TimeSpeed,
        clock     = { year = Clock.year, month = Clock.month, day = Clock.day, hour = Clock.hour, minute = math.floor(Clock.minute) },
        weather   = GlobalWeather.current,
    }
end

local function broadcastAll()
    local payload = buildSyncPayload()
    local players = GetPlayers()
    for i = 1, #players do
        TriggerClientEvent('helios_timeweather:sync', tonumber(players[i]), payload)
    end
end

CreateThread(function()
    local startMin = totalGameMinutes()
    GlobalWeather.nextChangeMin = startMin + Config.WeatherChangeIntervalMin
    local dtMinutes = Config.TimeSpeed / 60
    while true do
        Wait(1000)
        advanceClock(dtMinutes)
        updateGlobalWeather(totalGameMinutes())
    end
end)

CreateThread(function()
    while true do
        Wait(Config.SyncInterval * 1000)
        broadcastAll()
    end
end)

RegisterNetEvent('helios_timeweather:requestSync', function()
    if source > 0 then
        TriggerClientEvent('helios_timeweather:sync', source, buildSyncPayload())
    end
end)

RegisterNetEvent('helios_timeweather:checkAccess', function()
    if source > 0 and hasAccess(source) then
        TriggerClientEvent('helios_timeweather:openMenu', source)
    end
end)

RegisterNetEvent('helios_timeweather:setTime', function(h, m)
    if source > 0 and not hasAccess(source) then return end
    Clock.hour   = math.max(0, math.min(23, h))
    Clock.minute = math.max(0, math.min(59, m))
    broadcastAll()
end)

RegisterNetEvent('helios_timeweather:setFreeze', function(frozen)
    if source > 0 and not hasAccess(source) then return end
    Clock.frozen = frozen
    broadcastAll()
end)

RegisterNetEvent('helios_timeweather:setTimeSpeed', function(speed)
    if source > 0 and not hasAccess(source) then return end
    Config.TimeSpeed = math.max(0.1, math.min(5, speed))
    broadcastAll()
end)

RegisterNetEvent('helios_timeweather:setWeather', function(weather)
    if source > 0 and not hasAccess(source) then return end
    if not Config.WeatherTransitions[weather] then return end
    GlobalWeather.current = weather
    GlobalWeather.nextChangeMin = totalGameMinutes() + Config.WeatherChangeIntervalMin
    broadcastAll()
end)

exports('GetClock', function()
    return { year = Clock.year, month = Clock.month, day = Clock.day, hour = Clock.hour, minute = math.floor(Clock.minute) }
end)

exports('GetWeather', function()
    return GlobalWeather.current
end)

exports('SetWeather', function(weather)
    if not Config.WeatherTransitions[weather] then return false end
    GlobalWeather.current = weather
    GlobalWeather.nextChangeMin = totalGameMinutes() + Config.WeatherChangeIntervalMin
    broadcastAll()
    return true
end)

exports('SetClockTime', function(hour, minute)
    Clock.hour = math.max(0, math.min(23, hour))
    Clock.minute = math.max(0, math.min(59, minute))
    broadcastAll()
end)

print('^2[HELIOS-easytime]^7 Loaded — global time & weather, sync every ' .. Config.SyncInterval .. 's')
