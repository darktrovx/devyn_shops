ox_inventory = exports.ox_inventory

local localShops = {}
local externalShops = {}

-- functions

local function getStock(shop, item)
    if shop.items[item].stock then
        return shop.items[item].stock
    end

    return 0
end

local function addStock(shop, item, amount)
    if shop.items[item] then
        shop.items[item].stock = shop[item].stock + amount

        if shop.persistent then
            MySQL.Async.execute('UPDATE shops SET stock = @stock WHERE name = @name', {
                ['@stock'] = json.encode(shop.items),
                ['@name'] = shop,
            })
        end

    else
        print(('Item %s does not exist in shop %s'):format(item, shop))
    end
end

local function removeStock(shop, item, amount)
    if shop.items[item] then
        shop.items[item].stock = shop.items[item].stock - amount
        if shop.items[item].stock < 0 then
            shop.items[item].stock = 0
        end

        if shop.persistent then
            MySQL.Async.execute('UPDATE shops SET stock = @stock WHERE name = @name', {
                ['@stock'] = json.encode(shop.items),
                ['@name'] = shop,
            })
        end

    else
        print(('Item %s does not exist in shop %s'):format(item, shop))
    end
end

local function getItemPrice(shop, item)
    if shop.items[item] then
       return shop.items[item].price
    else
        print(('Item %s does not exist in shop %s'):format(item, shop))
    end
    return false
end

local function buildPurchase(shop, items, source)
    local total = 0
    for item, quantity in pairs(items) do

        local stock = 999999
        if not shop.infinite then
            stock = getStock(shop, item)
        end

        if stock > 0 then
            if stock < quantity then
                items[item] = stock
            end

            local price = getItemPrice(shop, item)
            if price then
                total = price * quantity
            else
                items[item] = nil
            end
        else
            TriggerClientEvent('ox_lib:notify', source, {type = 'error', title = 'shop', description = ('Item: %s was out of stock'):format(item)})
            items[item] = nil
        end
    end

    return total, items
end


local function getShopItems(shop, source)
    local player = exports.qbx_core:GetPlayer(source)
    local job, grade = player.PlayerData.job.name, player.PlayerData.job.grade.level
    local rep = exports.reputation:GetAllRep(player.PlayerData.citizenid)
    local items = {}

    for item, data in pairs(shop.items) do
        local jobCheck = false
        local repCheck = false
        local licenseCheck = false

        if data.jobs then
            for name, grade in pairs(data.jobs) do
                if job == name and grade >= grade  then
                    jobCheck = true
                end
            end
        else
            jobCheck = true
        end

        if data.rep then
            for name, amount in pairs(data.rep) do
                if rep[name] and rep[name] >= amount then
                    repCheck = true
                end
            end
        else
            repCheck = true
        end

        if data.license then
            local licenses = player.PlayerData.metadata.licences
            local hasLicense = true
            for name, value in pairs(data.license) do
                if not licenses[name] then
                    hasLicense = false
                end
            end
            licenseCheck = hasLicense
        else
            licenseCheck = true
        end

        if jobCheck and repCheck and licenseCheck then
            items[item] = data
        end
    end

    return items
end

local function createShop(shop)
    if not shop.name then
        print('Invalid shop name')
        return false
    end

    externalShops[shop.name] = shop
end
exports('createShop', createShop)

local function getDeliveryShops()
    local locations = {}
    for shopId, shopData in pairs(SHOPS) do
        if shopData.delivery then
            for locationId, location in pairs(shopData.locations) do
                locations[#locations + 1] = {
                    coords = location.coords,
                    id = ('%s:%s'):format(shopId, locationId),
                }
            end
        end
    end
    return locations
end
exports('getDeliveryShops', getDeliveryShops)

-- events


-- callbacks
lib.callback.register('shops:getShopData', function(source, key, locationId)

    if not externalShops[key] then

        if not localShops[key] then
            print(('invalid shop key %s'):format(key))
            return false
        end

        if not localShops[key].locations[locationId] then
            print(('invalid shop location %s'):format(locationId))
            return false
        end

        local shop = localShops[key].locations[locationId]
        if shop then
            local items = getShopItems(shop, source)
            return items 
        end
    else
        local shop = externalShops[key]
        if shop then
            local items = getShopItems(shop, source)
            return items
        else
            print(('invalid shop key %s'):format(key))
            return false
        end
    end

end)

lib.callback.register('shops:purchase', function(source, purchaseData)
    local shop = purchaseData.key
    local total = 0
    local items = {}

    if not externalShops[shop] then
        shop = localShops[purchaseData.key].locations[purchaseData.locationId]

        if shop then
            total, items = buildPurchase(shop, purchaseData.items, source)
        else
            print('cheater 1')
        end
    else
        shop = externalShops[shop]
        total, items = buildPurchase(shop, purchaseData.items, source)
    end

    if total > 0 then
        local player = exports.qbx_core:GetPlayer(source)
        if player.PlayerData.money[purchaseData.account] >= total then
            player.Functions.RemoveMoney(purchaseData.account, total)
            for item, quantity in pairs(items) do
                if not shop.infinite then
                    removeStock(shop, item, quantity)
                end

                local success, response = ox_inventory:AddItem(source, item, quantity, shop.items[item].metadata)
                if string.find(item, "WEAPON_") then
					local serial = response[1].metadata.serial
					local imageurl = ("https://cfx-nui-ox_inventory/web/images/%s.png"):format(item)
					local notes = "Purchased from shop"
					local owner = player.PlayerData.citizenid
					local weapClass = "Class"
					local weapModel = item
					
					exports.fr_mdt:CreateWeaponInfo(serial, imageurl, notes, owner, weapClass, weapModel)
                end

                lib.logger(source, 'purchase', ('%s purchased %s %s from %s for %s'):format(player.PlayerData.citizenid, quantity, item, shop.label or 'shop', total))
            end
            return true, getShopItems(shop, source)
        else
            TriggerClientEvent('ox_lib:notify', source, {type = 'error', title = 'shop', description = 'You do not have enough money to purchase these items'})
            return false
        end
    else
        return false
    end

end)

-- threads

CreateThread(function()
    local persistentShops = MySQL.query.await('SELECT * from shops')
     
    if persistentShops then
        for i = 1, #persistentShops do
            local row = persistentShops[i]
        end
        print(('%s shops loaded from database'):format(#persistentShops))
    end

    for key, shop in pairs(SHOPS) do
        if not localShops[key] then
            if not shop.persistent then
                localShops[key] = shop

                for locationId, location in pairs(localShops[key].locations) do
                    location.items = STOCKS[shop.stock]
                end
            end
        else
            print(('Duplicate store name: %s, skipping'):format(name))
        end
    end
end)

-- create vending machines
createShop({
    name = 'vendingmachine',
    label = 'Vending Machine',
    infinte = true,
    items = {
        ['sandwich']    = { price = 25, stock = 100, category = 'food' },
        ['water'] = { price = 25, stock = 100, category = 'food' },
    },
})