SHOPS['general'] = {
    label = 'General Store',
    infinite = false,
    persistant = false,
    delivery = true,
    stock = 'general', -- this is the key from the stock.lua file
    model =  'mp_m_shopkeep_01',
    -- animation = {
    --     dict = 'mp_am_hold_up',
    --     name = 'purchase_beerbox_shopkeeper',
    -- },
    scenario = 'WORLD_HUMAN_STAND_MOBILE',
    blip = {
        sprite = 52,
        color = 2,
        scale = 0.8,
        label = 'General Store',
    },
    locations = {
        { coords = vec4(24.05, -1348.03, 28.5, 263.21), },
        { coords = vec(-3038.41, 584.53, 6.91, 9.37), },
        { coords = vec(-3241.67, 999.7, 11.83, 336.01), },
        { coords = vec(1727.49, 6414.89, 34.04, 212.74), },
        { coords = vector4(1697.46, 4923.33, 41.06, 312.77), },
        { coords = vec(1960.26, 3739.33, 31.34, 306.82), },
        { coords = vec(549.16, 2672.07, 41.16, 77.26), },
        { coords = vector4(2678.42, 3279.7, 54.24, 333.86), },
        { coords = vector4(2557.6, 381.33, 107.62, 348.36), },
        { coords = vec(372.23, 325.63, 102.57, 232.03), },
        { coords = vec(-47.55, -1759.28, 28.42, 58.16), }, -- Grove Street
    },
}

SHOPS['liqour'] = {
    label = 'Liquor Store',
    persistant = false,
    infinite = false,
    delivery = true,
    stock = 'liquor', -- this is the key from the stock.lua file
    model =  'mp_m_shopkeep_01',
    -- animation = {
    --     dict = 'mp_am_hold_up',
    --     name = 'purchase_beerbox_shopkeeper',
    -- },
    scenario = 'WORLD_HUMAN_SMOKING',
    blip = {
        sprite = 52,
        color = 2,
        scale = 0.8,
        label = 'Liquor Store',
    },
    locations = {
        { coords = vector4(1134.44, -983.05, 45.42, 267.66), },
        { coords = vector4(-1221.35, -907.82, 11.33, 27.42), },
        { coords = vector4(-1486.93, -377.55, 39.16, 136.43), },
        { coords = vector4(-2966.48, 391.78, 14.04, 94.51), },
        { coords = vector4(1165.07, 2710.7, 37.16, 179.28), },
        { coords = vector4(1392.4, 3606.37, 33.98, 217.5), },
    },
}

SHOPS['clicklover'] = {
    label = "Clicklovers",
    delivery = true,
    infinite = false,
    stock = 'clicklover',
    model = 'a_f_y_hipster_02',
    scenario = 'WORLD_HUMAN_GUARD_STAND_CASINO',
    blip = {
        sprite = 521,
        color = 43,
        scale = 0.8,
        label = 'Clicklovers',
    },
    locations = {
        { coords = vec4(212.69, -1507.64, 28.29, 199.14), radius = 10, distance = 5, interactDst = 3, },
    }
}


SHOPS['utool'] = {
    label = 'U-TOOL',
    delivery = true,
    infinite = true,
    stock = 'utool',
    model = 'a_m_y_stbla_02',
    scenario = 'WORLD_HUMAN_AA_COFFEE',
    locations = {
        { coords = vec4(2747.94, 3472.92, 54.67, 244.56), radius = 30, distance = 5, interactDst = 3, },
    }
}

SHOPS['washers'] = {
    label = 'Washing Machines',
    delivery = true,
    infinite = true,
    stock = 'washers',
    model =  `s_f_m_sweatshop_01`,
    scenario = 'WORLD_HUMAN_AA_COFFEE',
    locations = {
        { coords = vec(83.3, -1558.38, 28.71, 295.61), radius = 40, distance = 5, interactDst = 3, },
    }
}