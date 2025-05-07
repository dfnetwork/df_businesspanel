RegisterNUICallback('closePanel', function(data, cb)
    SetNuiFocus(false, false)
    Framework.Functions.Notify(Framework.T('info.panel_closed'), Config.Notifications['info'])
    cb('ok')
end)

RegisterNUICallback('getBusinessData', function(data, cb)
    if not data.businessId then
        cb({success = false})
        return
    end
    
    Framework.Functions.TriggerCallback('df_businesspanel:server:getBusinessData', function(businessData)
        if businessData then
            cb({success = true, data = businessData})
        else
            cb({success = false})
        end
    end, data.businessId)
end)

RegisterNUICallback('updateBusinessGeneral', function(data, cb)
    TriggerServerEvent('df_businesspanel:server:updateBusinessGeneral', data.businessId, data.generalData)
    cb('ok')
end)

RegisterNUICallback('updateBusinessGrades', function(data, cb)
    TriggerServerEvent('df_businesspanel:server:updateBusinessGrades', data.businessId, data.grades)
    cb('ok')
end)

RegisterNUICallback('updateBusinessNPCs', function(data, cb)
    TriggerServerEvent('df_businesspanel:server:updateBusinessNPCs', data.businessId, data.npcs)
    cb('ok')
end)

RegisterNUICallback('updateBusinessStats', function(data, cb)
    TriggerServerEvent('df_businesspanel:server:updateBusinessStats', data.businessId, data.stats)
    cb('ok')
end)

RegisterNUICallback('createBusiness', function(data, cb)
    TriggerServerEvent('df_businesspanel:server:createBusiness', data)
    cb('ok')
end)

RegisterNUICallback('deleteBusiness', function(data, cb)
    TriggerServerEvent('df_businesspanel:server:deleteBusiness', data.businessId)
    cb('ok')
end)

RegisterNUICallback('getCurrentPosition', function(data, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    cb({
        x = coords.x,
        y = coords.y,
        z = coords.z,
        w = heading
    })
end)

RegisterNUICallback('nui:ready', function(data, cb)
    if cb then cb('ok') end
end)