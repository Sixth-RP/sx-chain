Config = {}

Config.Framework = 'qb' -- future use
Config.Debug = false

-- Clothing shop open үед түр hide хийх эсэх
Config.HideInClothingShop = true

-- Spawn / outfit load / revive дараа дахин attach хийх delay
Config.ReattachDelay = 1000

-- Нэг player дээр нэг л chain зүүх эсэх
Config.SingleChainOnly = true

-- Male/Female offset-ууд хэрэгтэй бол useGenderOffsets = true болго
Config.Chains = {
    ['gold_chain'] = {
        label = 'Gold Chain',
        model = 'chain_gold_01',
        bone = 24818,
        useGenderOffsets = false,
        offset = vec3(0.025, 0.015, 0.000),
        rotation = vec3(0.0, 90.0, 180.0),
    },

    ['diamond_chain'] = {
        label = 'Diamond Chain',
        model = 'chain_diamond_01',
        bone = 24818,
        useGenderOffsets = false,
        offset = vec3(0.023, 0.015, 0.000),
        rotation = vec3(0.0, 90.0, 180.0),
    },

    ['sixlogy_chain'] = {
        label = 'Sixlogy Chain',
        model = 'chain_sixlogy_01',
        bone = 24818,
        useGenderOffsets = true,

        male = {
            offset = vec3(0.025, 0.015, 0.000),
            rotation = vec3(0.0, 90.0, 180.0),
        },

        female = {
            offset = vec3(0.020, 0.012, 0.000),
            rotation = vec3(0.0, 90.0, 180.0),
        }
    },
}

-- Clothing shop hook event-үүд
-- Өөрийн resource-ийн event нэрэнд тааруулж өөрчилж болно
Config.ShopOpenEvents = {
    'qb-clothing:client:openMenu',
    'illenium-appearance:client:openOutfitMenu',
    'fivem-appearance:clothingShop',
    'fivem-appearance:barberMenu',
}

Config.ShopCloseEvents = {
    'qb-clothing:client:onMenuClose',
    'illenium-appearance:client:closeMenu',
    'fivem-appearance:hideMenu',
}
