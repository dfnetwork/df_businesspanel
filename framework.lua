Framework = {}
Framework.Name = nil
Framework.Functions = {}
Framework.Events = {}
Framework.Player = {}

local QBCore, ESX = nil, nil

Citizen.CreateThread(function()
    Wait(1000)
    
    if Config.Framework == 'qb' then
        Framework.Name = 'qb'
        QBCore = exports['qb-core']:GetCoreObject()
    elseif Config.Framework == 'esx' then
        Framework.Name = 'esx'
        if GetResourceState('es_extended') ~= 'missing' then
            ESX = exports['es_extended']:getSharedObject()
        end
    else
        if GetResourceState('qb-core') ~= 'missing' then
            local success = pcall(function()
                QBCore = exports['qb-core']:GetCoreObject()
            end)
            
            if success and QBCore then
                Framework.Name = 'qb'
                print('DF_BUSINESSPANEL: QBCore detectado automáticamente')
            end
        end
        
        if Framework.Name == nil then
            if GetResourceState('es_extended') ~= 'missing' then
                local success = pcall(function()
                    ESX = exports['es_extended']:getSharedObject()
                end)
                
                if success and ESX then
                    Framework.Name = 'esx'
                    print('DF_BUSINESSPANEL: ESX Legacy detectado automáticamente')
                end
            end
        end
        
        if Framework.Name == nil then
            print('DF_BUSINESSPANEL: No se pudo detectar el framework. Configurando manualmente en config.lua.')
        end
    end
    
    print('DF_BUSINESSPANEL: Framework detectado - ' .. (Framework.Name or 'ninguno'))
    InitializeFramework()
end)

function InitializeFramework()
    if Framework.Name == 'qb' then
        InitializeQBCore()
    elseif Framework.Name == 'esx' then
        InitializeESX()
    end
end

function InitializeQBCore()
    Framework.Functions.GetPlayerData = function()
        return QBCore.Functions.GetPlayerData()
    end
    
    Framework.Functions.Notify = function(message, type)
        QBCore.Functions.Notify(message, type)
    end
    
    Framework.Functions.TriggerCallback = function(name, cb, ...)
        QBCore.Functions.TriggerCallback(name, cb, ...)
    end
    
    Framework.Functions.CreateCallback = function(name, cb)
        QBCore.Functions.CreateCallback(name, cb)
    end
    
    Framework.Functions.GetPlayer = function(source)
        return QBCore.Functions.GetPlayer(source)
    end
    
    -- Add safety checks to prevent nil value errors
    Framework.Player.GetIdentifier = function(player)
        -- Check if player and PlayerData exist before accessing
        if player and player.PlayerData then
            return player.PlayerData.license
        else
            print('DF_BUSINESSPANEL: Warning - PlayerData is nil in GetIdentifier')
            return nil
        end
    end
    
    Framework.Player.GetPermission = function(player)
        -- Check if player and PlayerData exist before accessing
        if player and player.PlayerData then
            return player.PlayerData.permission
        else
            print('DF_BUSINESSPANEL: Warning - PlayerData is nil in GetPermission')
            return 'user' -- Default permission if not found
        end
    end
    
    Framework.Player.GetName = function(player)
        -- Check if player and PlayerData and charinfo exist before accessing
        if player and player.PlayerData and player.PlayerData.charinfo then
            return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
        else
            print('DF_BUSINESSPANEL: Warning - PlayerData or charinfo is nil in GetName')
            return 'Unknown Player'
        end
    end
    
    Framework.Player.GetJob = function(player)
        -- Check if player and PlayerData exist before accessing
        if player and player.PlayerData then
            return player.PlayerData.job
        else
            print('DF_BUSINESSPANEL: Warning - PlayerData is nil in GetJob')
            return {name = 'unemployed', grade = 0} -- Default job if not found
        end
    end
    
    Framework.Player.SetJob = function(player, job, grade)
        -- Check if player and Functions exist before calling
        if player and player.Functions and type(player.Functions.SetJob) == 'function' then
            player.Functions.SetJob(job, grade)
        else
            print('DF_BUSINESSPANEL: Warning - Cannot set job, player.Functions.SetJob not found')
        end
    end
    
    Framework.Events.OnPlayerLoaded = 'QBCore:Client:OnPlayerLoaded'
    Framework.Events.PlayerLogout = 'QBCore:Client:OnPlayerUnload'
    Framework.Events.JobUpdate = 'QBCore:Client:OnJobUpdate'
end

function InitializeESX()
    Framework.Functions.GetPlayerData = function()
        return ESX.GetPlayerData()
    end
    
    Framework.Functions.Notify = function(message, type)
        if type == Config.Notifications['success'] then
            ESX.ShowNotification(message, 'success')
        elseif type == Config.Notifications['error'] then
            ESX.ShowNotification(message, 'error')
        else
            ESX.ShowNotification(message, 'info')
        end
    end
    
    Framework.Functions.TriggerCallback = function(name, cb, ...)
        ESX.TriggerServerCallback(name, cb, ...)
    end
    
    Framework.Functions.CreateCallback = function(name, cb)
        ESX.RegisterServerCallback(name, cb)
    end
    
    Framework.Functions.GetPlayer = function(source)
        return ESX.GetPlayerFromId(source)
    end
    
    Framework.Player.GetIdentifier = function(player)
        -- Safety check
        if player and player.identifier then
            return player.identifier
        else
            print('DF_BUSINESSPANEL: Warning - player.identifier is nil in GetIdentifier')
            return nil
        end
    end
    
    Framework.Player.GetPermission = function(player)
        -- Safety checks for all possible paths
        if player then
            if player.getGroup and type(player.getGroup) == 'function' then
                return player.getGroup()
            elseif player.group then
                return player.group
            else
                local data = nil
                if player.getPlayerData and type(player.getPlayerData) == 'function' then
                    data = player.getPlayerData()
                elseif player.PlayerData then
                    data = player.PlayerData
                else
                    data = player
                end
                
                if data and data.group then
                    return data.group
                end
            end
        end
        return 'user'
    end
    
    Framework.Player.GetName = function(player)
        -- Safety checks for all possible paths
        if player then
            if player.getName and type(player.getName) == 'function' then
                return player.getName()
            elseif player.name then
                return player.name
            else
                local data = nil
                if player.getPlayerData and type(player.getPlayerData) == 'function' then
                    data = player.getPlayerData()
                elseif player.PlayerData then
                    data = player.PlayerData
                else
                    data = player
                end
                
                if data and data.name then
                    return data.name
                end
            end
        end
        return 'Unknown Player'
    end
    
    Framework.Player.GetJob = function(player)
        -- Safety checks for all possible paths
        if player then
            if player.getJob and type(player.getJob) == 'function' then
                return player.getJob()
            else
                local data = nil
                if player.getPlayerData and type(player.getPlayerData) == 'function' then
                    data = player.getPlayerData()
                elseif player.PlayerData then
                    data = player.PlayerData
                else
                    data = player
                end
                
                if data and data.job then
                    return data.job
                end
            end
        end
        return {name = 'unemployed', grade = 0}
    end
    
    Framework.Player.SetJob = function(player, job, grade)
        if player and player.setJob and type(player.setJob) == 'function' then
            player.setJob(job, grade)
        else
            print('DF_BUSINESSPANEL: No se pudo establecer el trabajo, método setJob no encontrado')
        end
    end
    
    Framework.Events.OnPlayerLoaded = 'esx:playerLoaded'
    Framework.Events.PlayerLogout = 'esx:playerDropped'
    Framework.Events.JobUpdate = 'esx:setJob'
end

function Framework.T(key, ...)
    local language = Config.Language
    local keys = {}
    
    for word in string.gmatch(key, "([^.]+)") do
        table.insert(keys, word)
    end
    
    local value = Config.Locales[language]
    for i=1, #keys do
        value = value and value[keys[i]] or nil
        if value == nil then
            return key
        end
    end
    
    if select('#', ...) > 0 then
        local args = {...}
        local result = value
        for i=1, #args do
            result = string.gsub(result, '%%s', tostring(args[i]), 1)
        end
        return result
    end
    
    return value
end

exports('GetFramework', function()
    return Framework
end)