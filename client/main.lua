local businessNPCs = {}
local Framework = nil

Citizen.CreateThread(function()
    Wait(2000)
    
    while Framework == nil do
        Framework = exports['df_businesspanel']:GetFramework()
        if Framework and Framework.Name then
            print('DF_BUSINESSPANEL: Framework cargado en cliente: ' .. Framework.Name)
            break
        end
        Wait(500)
    end
    
    InitializeClient()
end)

function InitializeClient()
    RegisterCommand(Config.Command, function(source, args)
        local PlayerData = Framework.Functions.GetPlayerData()
        
        local allowed = false
        
        if Config.AdminGroups[Framework.Player.GetPermission(PlayerData)] then
            allowed = true
        end
        
        if not allowed then
            Framework.Functions.TriggerCallback('df_businesspanel:server:checkIdentifier', function(isAllowed)
                allowed = isAllowed
                
                if Config.AdminOnly and not allowed then
                    Framework.Functions.Notify(Framework.T('error.not_authorized'), Config.Notifications['error'])
                    return
                end
                
                if args[1] then
                    Framework.Functions.TriggerCallback('df_businesspanel:server:getBusinessData', function(businessData)
                        if businessData then
                            SetupBusinessPanel(businessData)
                        end
                    end, args[1])
                else
                    Framework.Functions.TriggerCallback('df_businesspanel:server:getBusinessData', function(businesses)
                        if businesses and #businesses > 0 then
                            SetupBusinessList(businesses)
                        else
                            Framework.Functions.Notify(Framework.T('info.no_businesses'), Config.Notifications['error'])
                        end
                    end)
                end
            end)
        else
            if args[1] then
                Framework.Functions.TriggerCallback('df_businesspanel:server:getBusinessData', function(businessData)
                    if businessData then
                        SetupBusinessPanel(businessData)
                    end
                end, args[1])
            else
                Framework.Functions.TriggerCallback('df_businesspanel:server:getBusinessData', function(businesses)
                    if businesses and #businesses > 0 then
                        SetupBusinessList(businesses)
                    else
                        Framework.Functions.Notify(Framework.T('info.no_businesses'), Config.Notifications['error'])
                    end
                end)
            end
        end
    end)
    
    print('DF_BUSINESSPANEL: Comando ' .. Config.Command .. ' registrado correctamente')
    
    RegisterNetEvent(Framework.Events.OnPlayerLoaded, function()
        Wait(1000)
        
        Framework.Functions.TriggerCallback('df_businesspanel:server:getBusinessData', function(businesses)
            if businesses and #businesses > 0 then
                for _, business in ipairs(businesses) do
                    Framework.Functions.TriggerCallback('df_businesspanel:server:getBusinessData', function(businessData)
                        if businessData and businessData.npcs then
                            local npcs = type(businessData.npcs) == 'string' and json.decode(businessData.npcs) or businessData.npcs
                            if npcs and #npcs > 0 then
                                SetupNPCs(businessData.id, npcs)
                            end
                        end
                    end, business.id)
                end
            end
        end)
    end)
    
    Wait(1000)
    
    Framework.Functions.TriggerCallback('df_businesspanel:server:getBusinessData', function(businesses)
        if businesses and #businesses > 0 then
            for _, business in ipairs(businesses) do
                Framework.Functions.TriggerCallback('df_businesspanel:server:getBusinessData', function(businessData)
                    if businessData and businessData.npcs then
                        local npcs = type(businessData.npcs) == 'string' and json.decode(businessData.npcs) or businessData.npcs
                        if npcs and #npcs > 0 then
                            SetupNPCs(businessData.id, npcs)
                        end
                    end
                end, business.id)
            end
        end
    end)
end

function SetupNPCs(businessId, npcs)
    if businessNPCs[businessId] then
        for _, ped in pairs(businessNPCs[businessId]) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end
    
    businessNPCs[businessId] = {}
    
    for i, npcData in ipairs(npcs) do
        CreateThread(function()
            local model = npcData.model
            if type(model) == 'string' then
                model = GetHashKey(model)
            end
            
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(10)
            end
            
            local ped = CreatePed(4, model, 
                npcData.coords.x, 
                npcData.coords.y, 
                npcData.coords.z, 
                npcData.coords.w or 0.0, 
                false, 
                true
            )
            
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            FreezeEntityPosition(ped, true)
            
            businessNPCs[businessId][i] = ped
            
            SetModelAsNoLongerNeeded(model)
        end)
    end
end

RegisterNetEvent('df_businesspanel:client:updateNPCs', function(businessId, npcs)
    SetupNPCs(businessId, npcs)
end)

RegisterNetEvent('df_businesspanel:client:removeNPCs', function(businessId)
    if businessNPCs[businessId] then
        for _, ped in pairs(businessNPCs[businessId]) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
        businessNPCs[businessId] = nil
    end
end)

function SetupBusinessPanel(businessData)
    if type(businessData.grades) == 'string' then
        businessData.grades = json.decode(businessData.grades) or {}
    end
    
    if type(businessData.npcs) == 'string' then
        businessData.npcs = json.decode(businessData.npcs) or {}
    end
    
    if type(businessData.markers) == 'string' then
        businessData.markers = json.decode(businessData.markers) or {}
    end
    
    if type(businessData.items) == 'string' then
        businessData.items = json.decode(businessData.items) or {}
    end
    
    if type(businessData.stats) == 'string' then
        businessData.stats = json.decode(businessData.stats) or {}
    end
    
    if type(businessData.allowed_items) == 'string' then
        businessData.allowed_items = json.decode(businessData.allowed_items) or {}
    end
    
    SetupNPCs(businessData.id, businessData.npcs)
    
    SendNUIMessage({
        action = 'openBusinessPanel',
        data = businessData
    })
    SetNuiFocus(true, true)
    
    Framework.Functions.Notify(Framework.T('info.panel_opened'), Config.Notifications['info'])
end

function SetupBusinessList(businesses)
    SendNUIMessage({
        action = 'openBusinessList',
        businesses = businesses
    })
    SetNuiFocus(true, true)
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for businessId, peds in pairs(businessNPCs) do
            for _, ped in pairs(peds) do
                if DoesEntityExist(ped) then
                    DeleteEntity(ped)
                end
            end
        end
        businessNPCs = {}
    end
end)