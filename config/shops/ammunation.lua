SHOPS['ammunation'] = {
    label = 'Ammunation',
    infinite = true,
    persistant = false,
    delivery = true,
    stock = 'ammunation', -- this is the key from the stock.lua file
    model =  'cs_josef',
    -- animation = {
    --     dict = 'mp_am_hold_up',
    --     name = 'purchase_beerbox_shopkeeper',
    -- },
    scenario = 'WORLD_HUMAN_GUARD_STAND_ARMY',
    blip = {
        sprite = 567,
        color = 27,
        scale = 0.8,
        label = 'Ammunation',
    },
    locations = {
        { coords = vec(16.12, -1105.71, 28.15, 190.0), },
    },
}