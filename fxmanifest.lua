fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'HELIOS'
description 'HELIOS-easytime — Global time & weather management with NUI admin dashboard'

ui_page 'ui/index.html'

shared_scripts {
    'config.lua'
}

server_scripts {
    'server.lua'
}

client_scripts {
    'client.lua'
}

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
}
