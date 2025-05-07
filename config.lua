Config = {}

Config.Framework = 'auto' -- 'auto', 'qb', 'esx'

Config.Command = 'businesspanel'
Config.AdminOnly = true

Config.AdminGroups = {
    ['admin'] = false,
    ['god'] = false,
    ['mod'] = false
}

Config.AllowedIdentifiers = {
    ["discord:732306312024555632"] = true,
    --["steam:TU_ID_STEAM"] = true,
    --["license:TU_LICENSE"] = true
}

Config.Database = {
    Table = 'origen_masterjob',
    BillsTable = 'origen_masterjob_bills'
}

Config.BusinessTypes = {
    'shop', 
    'mechanic', 
    'police', 
    'ambulance', 
    'custom'
}

Config.MarkerTypes = {
    'stash',
    'stash_safe',
    'clothing',
    'duty',
    'boss',
    'shop',
    'crafting',
    'garage',
    'custom'
}

Config.DefaultItems = {
    {name = 'sandwich', price = 5, level = 0},
    {name = 'water_bottle', price = 3, level = 0},
    {name = 'coffee', price = 4, level = 0},
    {name = 'snikkel_candy', price = 5, level = 0},
    {name = 'tosti', price = 6, level = 0},
    {name = 'kurkakola', price = 4, level = 0}
}

Config.Notifications = {
    ['success'] = 'success',
    ['error'] = 'error',
    ['info'] = 'primary'
}

Config.Locales = {
    ['en'] = {
        ['error'] = {
            ['not_authorized'] = 'You are not authorized',
            ['no_business'] = 'Business not found',
            ['invalid_data'] = 'Invalid data',
            ['db_error'] = 'Database error'
        },
        ['success'] = {
            ['business_saved'] = 'Business saved',
            ['business_deleted'] = 'Business deleted'
        },
        ['info'] = {
            ['panel_opened'] = 'Business panel opened',
            ['panel_closed'] = 'Business panel closed',
            ['no_businesses'] = 'No businesses available'
        }
    },
    ['es'] = {
        ['error'] = {
            ['not_authorized'] = 'No estás autorizado',
            ['no_business'] = 'Negocio no encontrado',
            ['invalid_data'] = 'Datos inválidos',
            ['db_error'] = 'Error de base de datos'
        },
        ['success'] = {
            ['business_saved'] = 'Negocio guardado',
            ['business_deleted'] = 'Negocio eliminado'
        },
        ['info'] = {
            ['panel_opened'] = 'Panel de negocio abierto',
            ['panel_closed'] = 'Panel de negocio cerrado',
            ['no_businesses'] = 'No hay negocios disponibles'
        }
    }
}

Config.Language = 'es' -- 'en', 'es'