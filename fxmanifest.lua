fx_version 'cerulean'
game 'gta5'

name 'hades_claymore'

server_script '@oxmysql/lib/MySQL.lua'
server_script '@es_extended/imports.lua'
shared_script '@ox_lib/init.lua'
shared_script '@es_extended/imports.lua'

client_scripts {
    'client/**/*',
}

server_scripts {
    'server/**/*',
}