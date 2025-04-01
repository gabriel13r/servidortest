fx_version 'adamant'
game 'gta5'

author 'AysLaN'

client_scripts {
	'@vrp/lib/utils.lua',
	'config/config.lua',
	'client.lua'
}

server_scripts {
	'@vrp/lib/utils.lua',
	'@oxmysql/lib/MySQL.lua',
	'config/config.lua',
	'server.lua'
}

dependencies {
    'oxmysql'
}