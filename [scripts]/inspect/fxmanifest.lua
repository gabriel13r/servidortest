fx_version 'adamant'
game 'gta5'

ui_page 'nui/darkside.html'

client_scripts {
	'@vrp/lib/utils.lua',
	'config.lua',
	'client.lua'
}

server_scripts {
	'@vrp/lib/utils.lua',
	'config.lua',
	'server.lua'
}

files {
	'nui/*.html',
	'nui/*.css',
	'nui/*.js'
}