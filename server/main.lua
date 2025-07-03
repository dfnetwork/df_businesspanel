local Framework = nil

Citizen.CreateThread(function()
    Wait(2000) 
    
    while Framework == nil do
        Framework = exports['df_businesspanel']:GetFramework()
        if Framework and Framework.Name then
            print('DF_BUSINESSPANEL: Framework cargado en servidor: ' .. Framework.Name)
            break
        end
        Wait(500)
    end
    
    InitializeServer()
end)

function InitializeServer()
    Framework.Functions.CreateCallback('df_businesspanel:server:checkIdentifier', function(source, cb)
        local src = source
        local allowed = false
        for _, identifier in pairs(GetPlayerIdentifiers(src)) do
            if Config.AllowedIdentifiers[identifier] then
                allowed = true
                break
            end
        end
        cb(allowed)
    end)
    
    Framework.Functions.CreateCallback('df_businesspanel:server:getBusinessData', function(source, cb, businessId)
        local src = source
        local Player = Framework.Functions.GetPlayer(src)
        if not Player then return cb(false) end
        local allowed = false
        
        if Config.AdminGroups[Framework.Player.GetPermission(Player)] then
            allowed = true
        end
        
        if not allowed then
            for _, identifier in pairs(GetPlayerIdentifiers(src)) do
                if Config.AllowedIdentifiers[identifier] then
                    allowed = true
                    break
                end
            end
        end
        
        if Config.AdminOnly and not allowed then
            TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.not_authorized'), Config.Notifications['error'])
            return cb(false)
        end
        
        if not businessId then
            MySQL.Async.fetchAll('SELECT id, label FROM '..Config.Database.Table, {}, function(result)
                if result then
                    cb(result)
                else
                    cb({})
                end
            end)
            return
        end
        
        MySQL.Async.fetchSingle('SELECT * FROM '..Config.Database.Table..' WHERE id = ?', {businessId}, function(result)
            if result then
                cb(result)
            else
                TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.no_business'), Config.Notifications['error'])
                cb(false)
            end
        end)
    end)
    
    RegisterNetEvent('df_businesspanel:server:updateBusinessGeneral', function(businessId, data)
        local src = source
        local Player = Framework.Functions.GetPlayer(src)
        if not Player then return end
        local allowed = false
        
        if Config.AdminGroups[Framework.Player.GetPermission(Player)] then
            allowed = true
        end
        
        if not allowed then
            for _, identifier in pairs(GetPlayerIdentifiers(src)) do
                if Config.AllowedIdentifiers[identifier] then
                    allowed = true
                    break
                end
            end
        end
        
        if Config.AdminOnly and not allowed then
            TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.not_authorized'), Config.Notifications['error'])
            return
        end
        
        if not businessId or not data or type(data) ~= 'table' then
            TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.invalid_data'), Config.Notifications['error'])
            return
        end
        
        if data.money and type(data.money) == 'number' then
            if data.money > 9223372036854775807 then
                data.money = 9223372036854775807
            elseif data.money < 0 then
                data.money = 0
            end
        else
            data.money = 0
        end
        
        MySQL.Async.execute('UPDATE '..Config.Database.Table..' SET label = ?, type = ?, level = ?, experience = ?, money = ?, open = ? WHERE id = ?', 
            {data.label, data.type, data.level, data.experience, data.money, data.open, businessId},
            function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('success.business_saved'), Config.Notifications['success'])
                else
                    TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.db_error'), Config.Notifications['error'])
                end
            end
        )
    end)
    
    RegisterNetEvent('df_businesspanel:server:updateBusinessGrades', function(businessId, grades)
        local src = source
        local Player = Framework.Functions.GetPlayer(src)
        if not Player then return end
        local allowed = false
        
        if Config.AdminGroups[Framework.Player.GetPermission(Player)] then
            allowed = true
        end
        
        if not allowed then
            for _, identifier in pairs(GetPlayerIdentifiers(src)) do
                if Config.AllowedIdentifiers[identifier] then
                    allowed = true
                    break
                end
            end
        end
        
        if Config.AdminOnly and not allowed then
            TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.not_authorized'), Config.Notifications['error'])
            return
        end
        
        if not businessId or not grades or type(grades) ~= 'table' then
            TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.invalid_data'), Config.Notifications['error'])
            return
        end
        
        local gradesJson = json.encode(grades)
        MySQL.Async.execute('UPDATE '..Config.Database.Table..' SET grades = ? WHERE id = ?', 
            {gradesJson, businessId},
            function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('success.business_saved'), Config.Notifications['success'])
                else
                    TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.db_error'), Config.Notifications['error'])
                end
            end
        )
    end)
    
    RegisterNetEvent('df_businesspanel:server:updateBusinessNPCs', function(businessId, npcs)
        local src = source
        local Player = Framework.Functions.GetPlayer(src)
        if not Player then return end
        local allowed = false
        
        if Config.AdminGroups[Framework.Player.GetPermission(Player)] then
            allowed = true
        end
        
        if not allowed then
            for _, identifier in pairs(GetPlayerIdentifiers(src)) do
                if Config.AllowedIdentifiers[identifier] then
                    allowed = true
                    break
                end
            end
        end
        
        if Config.AdminOnly and not allowed then
            TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.not_authorized'), Config.Notifications['error'])
            return
        end
        
        if not businessId or not npcs or type(npcs) ~= 'table' then
            TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.invalid_data'), Config.Notifications['error'])
            return
        end
        
        local npcsJson = json.encode(npcs)
        MySQL.Async.execute('UPDATE '..Config.Database.Table..' SET npcs = ? WHERE id = ?', 
            {npcsJson, businessId},
            function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('success.business_saved'), Config.Notifications['success'])
                    TriggerClientEvent('df_businesspanel:client:updateNPCs', -1, businessId, npcs)
                else
                    TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.db_error'), Config.Notifications['error'])
                end
            end
        )
    end)
    
    RegisterNetEvent('df_businesspanel:server:updateBusinessStats', function(businessId, stats)
        local src = source
        local Player = Framework.Functions.GetPlayer(src)
        if not Player then return end
        local allowed = false
        
        if Config.AdminGroups[Framework.Player.GetPermission(Player)] then
            allowed = true
        end
        
        if not allowed then
            for _, identifier in pairs(GetPlayerIdentifiers(src)) do
                if Config.AllowedIdentifiers[identifier] then
                    allowed = true
                    break
                end
            end
        end
        
        if Config.AdminOnly and not allowed then
            TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.not_authorized'), Config.Notifications['error'])
            return
        end
        
        if not businessId or not stats or type(stats) ~= 'table' then
            TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.invalid_data'), Config.Notifications['error'])
            return
        end
        
        local statsJson = json.encode(stats)
        MySQL.Async.execute('UPDATE '..Config.Database.Table..' SET stats = ? WHERE id = ?', 
            {statsJson, businessId},
            function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('success.business_saved'), Config.Notifications['success'])
                else
                    TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.db_error'), Config.Notifications['error'])
                end
            end
        )
    end)
    
    RegisterNetEvent('df_businesspanel:server:createBusiness', function(data)
        local src = source
        local Player = Framework.Functions.GetPlayer(src)
        if not Player then return end
        local allowed = false
        
        if Config.AdminGroups[Framework.Player.GetPermission(Player)] then
            allowed = true
        end
        
        if not allowed then
            for _, identifier in pairs(GetPlayerIdentifiers(src)) do
                if Config.AllowedIdentifiers[identifier] then
                    allowed = true
                    break
                end
            end
        end
        
        if Config.AdminOnly and not allowed then
            TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.not_authorized'), Config.Notifications['error'])
            return
        end
        
        if not data or type(data) ~= 'table' or not data.id or not data.label or not data.type then
            TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.invalid_data'), Config.Notifications['error'])
            return
        end
        
        local grades = json.encode({["0"] = {label = "Jefe", boss = true, pay = 1000}})
        local npcs = json.encode({})
        local markers = json.encode({})
        local items = json.encode({})
        local stats = json.encode({ duty = {}, money = {} })
        
        MySQL.Async.insert('INSERT INTO '..Config.Database.Table..' (id, label, type, level, experience, money, open, grades, npcs, players, markers, items, missions, vehicles, metadata, stats, allowed_items) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            {data.id, data.label, data.type, 0, 0, 0, 1, grades, npcs, '[]', markers, items, '[]', '[]', '[]', stats, '[]'},
            function(id)
                if id then
                    TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('success.business_saved'), Config.Notifications['success'])
                else
                    TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.db_error'), Config.Notifications['error'])
                end
            end
        )
    end)
    
    RegisterNetEvent('df_businesspanel:server:deleteBusiness', function(businessId)
        local src = source
        local Player = Framework.Functions.GetPlayer(src)
        if not Player then return end
        local allowed = false
        
        if Config.AdminGroups[Framework.Player.GetPermission(Player)] then
            allowed = true
        end
        
        if not allowed then
            for _, identifier in pairs(GetPlayerIdentifiers(src)) do
                if Config.AllowedIdentifiers[identifier] then
                    allowed = true
                    break
                end
            end
        end
        
        if Config.AdminOnly and not allowed then
            TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.not_authorized'), Config.Notifications['error'])
            return
        end
        
        if not businessId then
            TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.invalid_data'), Config.Notifications['error'])
            return
        end
        
        MySQL.Async.execute('DELETE FROM '..Config.Database.Table..' WHERE id = ?', {businessId},
            function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('success.business_deleted'), Config.Notifications['success'])
                    TriggerClientEvent('df_businesspanel:client:removeNPCs', -1, businessId)
                else
                    TriggerClientEvent(Framework.Name == 'qb' and 'QBCore:Notify' or 'esx:showNotification', src, Framework.T('error.db_error'), Config.Notifications['error'])
                end
            end
        )
    end)
end