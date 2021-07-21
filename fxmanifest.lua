fx_version 'adamant'

game 'gta5'

description 'MasterkinG32 Shops'

version '1.0.0'

ui_page 'html/ui.html'

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'locales/en.lua',
	'client/*.lua'
}
server_scripts {
	'@es_extended/locale.lua',
	'@mysql-async/lib/MySQL.lua',
	'locales/en.lua',
	'config.lua',
	'server/main.lua',
	'server/masterking32_loader.lua'
}

files {
	'html/*.html',
	'html/*.css',
	'html/*.js',
	-- default
	'html/img/*.png',
}

dependency 'es_extended'
