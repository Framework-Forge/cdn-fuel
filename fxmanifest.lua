fx_version 'cerulean'
game 'gta5'
author 'https://www.github.com/CodineDev' -- Base Refueling System: (https://github.com/InZidiuZ/LegacyFuel), other code by Codine (https://www.github.com/CodineDev).
description 'cdn-fuel'
version '2.2.0'

client_scripts {
    'client/polyzone_compat.lua',
    'client/utils.lua',
    'client/fuel_cl.lua',
    'client/electric_cl.lua',
    'client/station_cl.lua',
}

server_scripts {
    'server/database.lua',
    'server/fuel_sv.lua',
    'server/station_sv.lua',
    'server/electric_sv.lua',
}

shared_scripts {
    '@pr_bridge/init.lua',
    'shared/config.lua',
    'shared/bridge.lua',
    'locales/en.lua', -- Locales traduzidos para PT-BR
    -- 'locales/de.lua', -- Locales em alemão / Deutsch
    -- 'locales/fr.lua', -- Locales em francês / Français
    -- 'locales/es.lua', -- Locales em espanhol / Español / Española
    -- 'locales/ee.lua', -- Locales em estoniano
}

exports { -- Call with exports['cdn-fuel']:GetFuel or exports['cdn-fuel']:SetFuel
    'GetFuel',
    'SetFuel'
}

lua54 'yes'

dependencies {
    'pr_bridge',
}

-- data_file 'DLC_ITYP_REQUEST' 'stream/[electric_nozzle]/electric_nozzle_typ.ytyp'
-- data_file 'DLC_ITYP_REQUEST' 'stream/[electric_charger]/electric_charger_typ.ytyp'

provide 'cdn-syphoning' -- This is used to override cdn-syphoning(https://github.com/CodineDev/cdn-syphoning) if you have it installed. If you don't have it installed, don't worry about this. If you do, we recommend removing it and using this instead.
