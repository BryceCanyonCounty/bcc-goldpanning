game 'rdr3'
fx_version "cerulean"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
author 'BCC @Fistsofury'
description 'Indepth Goldpanning script by BCC'

server_scripts {
    '/server/*.lua'
}

shared_scripts {
    'config.lua',
    'locale.lua',
    'languages/*.lua'
}


client_scripts {
    '/client/*.lua'
}

dependencies {
    'vorp_core',
    'vorp_inventory',
    'feather-progressbar',
    'bcc-minigames',
    'bcc-utils'
}

version '1.0.1'
