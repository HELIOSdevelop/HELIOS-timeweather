local CurrentWeather = nil
local OverrideTime = nil
local WeatherOverrideQueued = nil
local IsFrozen = false

CreateThread(function()
    while true do
        Wait(500)

        if OverrideTime and not IsFrozen then
            NetworkOverrideClockTime(OverrideTime.hour, OverrideTime.minute, 0)
        end

        if WeatherOverrideQueued then
            SetWeatherTypeNowPersist(WeatherOverrideQueued.weather)
            SetWeatherTypeOverTime(WeatherOverrideQueued.weather, WeatherOverrideQueued.transition or 5.0)
            WeatherOverrideQueued = nil
        end
    end
end)

RegisterNetEvent('helios_timeweather:sync', function(data)
    if not data then return end

    IsFrozen = data.frozen

    if data.clock then
        OverrideTime = {
            hour   = data.clock.hour,
            minute = data.clock.minute,
        }
    end

    if data.weather then
        if data.weather ~= CurrentWeather then
            WeatherOverrideQueued = { weather = data.weather, transition = 5.0 }
        end
        CurrentWeather = data.weather
    end

    SendNUIMessage({
        type = 'sync',
        payload = data,
    })
end)

RegisterNUICallback('getInitialData', function(_, cb)
    TriggerServerEvent('helios_timeweather:requestSync')
    cb({ ok = true })
end)

RegisterNUICallback('setTime', function(data, cb)
    TriggerServerEvent('helios_timeweather:setTime', data.hour, data.minute)
    cb({ ok = true })
end)

RegisterNUICallback('setFreeze', function(data, cb)
    TriggerServerEvent('helios_timeweather:setFreeze', data.frozen)
    cb({ ok = true })
end)

RegisterNUICallback('setTimeSpeed', function(data, cb)
    TriggerServerEvent('helios_timeweather:setTimeSpeed', data.speed)
    cb({ ok = true })
end)

RegisterNUICallback('setWeather', function(data, cb)
    TriggerServerEvent('helios_timeweather:setWeather', data.weather)
    cb({ ok = true })
end)

RegisterCommand('time', function()
    TriggerServerEvent('helios_timeweather:checkAccess')
end, false)

RegisterNetEvent('helios_timeweather:openMenu', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ type = 'open' })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

RegisterNUICallback('escape', function(_, cb)
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

exports('GetWeather', function()
    return CurrentWeather
end)
