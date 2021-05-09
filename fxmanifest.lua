fx_version 'adamant'

game 'gta5'

description 'MasterkinG32 Shops'

version '1.0.0'

ui_page 'html/index.html'

client_scripts {
	'client/*.lua'
}
server_scripts {
	'server/server.lua'
}

files {
	'html/*.html',
	'html/*.css',
	'html/*.js',
	-- default
	'html/img/*.png',
}

dependency 'es_extended'
