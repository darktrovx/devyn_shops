fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54        'yes'

ui_page 'html/index.html'

files {
	'html/**',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config/shops.lua',
    'config/shops/*.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/stashshop.lua',
    'config/stocks.lua',
    'config/stocks/*.lua',
}

