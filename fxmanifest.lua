fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'DF Business Panel (Multiframework QBCore & ESX)'
author 'DF Network (Modified by Marco3222)'
version '1.0.0'

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