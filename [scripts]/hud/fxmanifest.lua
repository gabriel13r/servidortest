fx_version 'adamant'
game 'gta5'

ui_page "web-side/index.html"
client_scripts {
	"@vrp/lib/utils.lua",
	"client.lua"
}

server_scripts {
	"@vrp/lib/utils.lua",
	"server.lua"
}
files {
	"web-side/*",
	"web-side/*.html",
	"web-side/*.js",
	"web-side/*.css",
	"web-side/*.otf",
	"web-side/*.ttf",
	"web-side/*.css",
	"web-side/dist/loading-bar.css",
	"web-side/dist/loading-bar.js",
	"web-side/dist/loading-bar.min.css",
	"web-side/dist/loading-bar.min.js",
	"web-side/svg/*.svg",
}


                            