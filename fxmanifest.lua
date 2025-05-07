fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'DF Business Panel for Origen_Masterjob (Multiframework QBCore & ESX)'
author 'DF Network & Marco3222'
version '1.1.0'

-----------------------------------------------------------------
-- FEEL FREE TO MODIFY, EDIT, UPDATE, AND IMPROVE THIS SCRIPT  --
--          ITS SOLE PURPOSE IS TO HELP IMPROVE                --  
-- THE BUSINESS MANAGEMENT EXPERIENCE WITHIN ORIGEN_MASTERJOB. --
-----------------------------------------------------------------

shared_scripts {
    'config.lua',
    'framework.lua'
}

client_scripts {
    'client/main.lua',
    'client/nui.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png'
}

dependency 'oxmysql'

exports {
    'GetFramework'
}