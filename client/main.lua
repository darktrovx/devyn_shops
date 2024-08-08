interact = exports.interact
ITEMS = exports.ox_inventory:Items()

local zones = {}
local shopData = {}
local imagePath = 'https://cfx-nui-ox_inventory/web/images/'

-- functions

local function buildItems(stock)
    local items = {}

    for name, data in pairs(stock) do
        local item = ITEMS[name]
        
        if item then
            local image = ('%s%s.png'):format(imagePath, name)
            if item?.client and item.client?.image then image = item.client.image end

            items[name] = {
                name = item.name,
                label = item.label,
                weight = item.weight,
                price = data.price,
                stock = data.stock,
                metadata = data.metadata or {},
                image = image,
                category = data.category
            }
        else
            print(('Invalid Item: %s'):format(name))
        end
    end
    return items
end

local function openShop(key, locationId)
    local stock = lib.callback.await('shops:getShopData', false, key, locationId)
    if not stock then
        lib.notify({
            title = 'Shop',
            description = 'Nothing to buy here.',
            type = 'error'
        })
        return 
    end

    local items = buildItems(stock)

    local label = SHOPS[key]?.label or 'Shop'
    SendNUIMessage({
        action = "open",
        shopName = label,
        key = key,
        locationId = locationId or 0,
        items = items,
        cash = QBX.PlayerData.money.cash or 0,
        bank = QBX.PlayerData.money.bank or 0,
    })
    SetNuiFocus(true, true)
end
exports('openShop', openShop)

local function onEnter(self)
    local shop = SHOPS[self.key]
    local location = shop.locations[self.locationId]

    if shop.model then
        lib.requestModel(shop.model)
        location.ped = CreatePed(4, shop.model, location.coords.x, location.coords.y, location.coords.z, location.coords.w, false, false)
        FreezeEntityPosition(location.ped, true)
        SetEntityInvincible(location.ped, true)
        SetBlockingOfNonTemporaryEvents(location.ped, true)

        if shop.anim then
            lib.requestAnimDict(shop.anim.dict)
            TaskPlayAnim(location.ped, shop.anim.dict, shop.anim.name, 8.0, 8.0, -1, 1, 0, false, false, false)
        end

        if shop.scenario then
            TaskStartScenarioInPlace(location.ped, shop.scenario, 0, true)
        end

        interact:AddLocalEntityInteraction({
            entity = location.ped,
            interactDst = location.interactDst or 2.0,
            distance = location.interactDst or 8.0,
            options = {
                {
                    label = 'Shop',
                    action = function()

                        openShop(self.key, self.locationId)

                        if location.ped then
                            PlayPedAmbientSpeechNative(location.ped, "GENERIC_HI", "SPEECH_PARAMS_FORCE_NORMAL_CLEAR")
                        end
                    end
                },
                {
                    label = 'Deliver Goods',
                    action = function()
                        exports.delivery:deliver(self.key, self.locationId)
                    end,
                    canInteract = function()
                        return exports.delivery:isDeliverLocation(self.key, self.locationId)
                    end
                }
            }
        })
    else
        interact:AddInteraction({
            coords = location.coords,
            interactDst = 2.0,
            distance = 10.0,
            options = {
                {
                    label = 'Shop',
                    action = openShop
                },
            }
        })
    end

end

local function onExit(self)
    local shop = SHOPS[self.key].locations[self.locationId]
    if DoesEntityExist(shop.ped) then
        DeleteEntity(shop.ped)
    end
end

-- vending machine targets

exports.ox_target:addModel(
    {
        `prop_vend_soda_02`, 
        `prop_vend_fridge01`, 
        `prop_vend_water_01`, 
        `prop_vend_soda_01`
    },
    {
        {
            name = 'ox_target:vendingMachine',
            icon = 'fa-solid fa-shopping-basket',
            label = 'Vending Machine',
            distance = 2,
            onSelect = function(data)
                exports.fr_shops:openShop('vendingmachine')
            end
        }

    }
)

-- events

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

end)

-- callbacks

RegisterNUICallback('close', function(_, cb)
    SendNUIMessage({  action = "close", })
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('purchase', function(data, cb)
    local success, items = lib.callback.await('shops:purchase', false, data)
    cb({ success = success, items = buildItems(items) })
end)

-- threads

CreateThread(function()
    for key, shop in pairs(SHOPS) do
        for locationId, location in pairs(shop.locations) do
            location.zone = lib.zones.sphere({
                coords = location.coords,
                radius = location.radius or 20.0,
                debug = false,
                onEnter = onEnter,
                onExit = onExit,

                -- shop data
                key = key,
                locationId = locationId,
            })

            if shop.blip then
                local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
                SetBlipSprite(blip, shop.blip.sprite)
                SetBlipScale(blip, shop.blip.scale)
                SetBlipColour(blip, shop.blip.color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(shop.blip.label)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
end)