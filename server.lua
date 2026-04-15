local QBCore = exports['qb-core']:GetCoreObject()

local function EnsureTable()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS player_chains (
            citizenid VARCHAR(50) NOT NULL,
            chain_name VARCHAR(100) DEFAULT NULL,
            PRIMARY KEY (citizenid)
        )
    ]])
end

CreateThread(function()
    EnsureTable()

    for itemName, _ in pairs(Config.Chains) do
        QBCore.Functions.CreateUseableItem(itemName, function(source, item)
            TriggerClientEvent('sx-chains:client:toggleChain', source, itemName)
        end)
    end
end)

RegisterNetEvent('sx-chains:server:saveEquipped', function(chainName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    if not citizenid then return end

    if chainName and not Config.Chains[chainName] then
        return
    end

    MySQL.update([[
        INSERT INTO player_chains (citizenid, chain_name)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE chain_name = VALUES(chain_name)
    ]], { citizenid, chainName })
end)

RegisterNetEvent('sx-chains:server:requestEquipped', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    if not citizenid then return end

    local result = MySQL.single.await(
        'SELECT chain_name FROM player_chains WHERE citizenid = ?',
        { citizenid }
    )

    local chainName = result and result.chain_name or nil
    TriggerClientEvent('sx-chains:client:loadEquipped', src, chainName)
end)
