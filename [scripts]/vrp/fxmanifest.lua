fx_version 'adamant'
game 'gta5'

ui_page 'gui/index.html'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'lib/utils.lua',
	'base.lua',
	'queue.lua',
	'cfg/*',
	'modules/*'
}

client_scripts {
	'lib/utils.lua',
	'cfg/*',
	"loading/client.lua",
	'client/*',
}

files {
	"loading/index.html",	
	'loading/assets/js/ui.js',
	'loading/assets/img/background.png',
	'loading/assets/fonts/BebasNeue.otf',
	'loading/assets/fonts/BebasNeue.ttf',
	'loading/assets/css/style.css',
	'loading/musi.mp3',
	'lib/Tunnel.lua',
	'lib/Proxy.lua',
	'lib/Tools.lua',
	'gui/*',
}
loadscreen_manual_shutdown "yes"
loadscreen "loading/index.html"   

server_export 'AddPriority'
server_export 'RemovePriority'
