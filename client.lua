local QBCore = exports['qb-core']:GetCoreObject()

local CurrentChainName = nil
local CurrentChainEntity = nil
local ShopHiddenChain = nil
local IsShopOpen = false

local function DebugPrint(...)
    if Config.Debug then
        print('[sx-chains]', ...)
    end
end

local function IsPedFemale(ped)
    local model = GetEntityModel(ped)
    return model == `mp_f_freemode_01`
end

local function LoadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)

    if not IsModelInCdimage(hash) then
        DebugPrint('Invalid model:', model)
        return nil
    end

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end

    return hash
end

local function RemoveCurrentChain()
    if CurrentChainEntity and DoesEntityExist(CurrentChainEntity) then
        DeleteEntity(CurrentChainEntity)
    end

    CurrentChainEntity = nil
    CurrentChainName = nil
end

local function GetChainTransform(chainData, ped)
    if chainData.useGenderOffsets then
        if IsPedFemale(ped) then
            return chainData.female.offset, chainData.female.rotation
        else
            return chainData.male.offset, chainData.male.rotation
        end
    end

    return chainData.offset, chainData.rotation
end

local function AttachChain(chainName, saveState)
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return false end

    local chainData = Config.Chains[chainName]
    if not chainData then
        DebugPrint('Chain not found in config:', chainName)
        return false
    end

    RemoveCurrentChain()

    local modelHash = LoadModel(chainData.model)
    if not modelHash then return false end

    local coords = GetEntityCoords(ped)
    local obj = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, false)

    if not DoesEntityExist(obj) then
        DebugPrint('Failed to create object:', chainData.model)
        return false
    end

    SetEntityAsMissionEntity(obj, true, true)
    SetEntityCollision(obj, false, false)
    SetEntityCompletelyDisableCollision(obj, false, true)

    local boneIndex = GetPedBoneIndex(ped, chainData.bone)
    local offset, rotation = GetChainTransform(chainData, ped)

    AttachEntityToEntity(
        obj,
        ped,
        boneIndex,
        offset.x, offset.y, offset.z,
        rotation.x, rotation.y, rotation.z,
        false, false, false, false, 2, true
    )

    CurrentChainEntity = obj
    CurrentChainName = chainName

    SetModelAsNoLongerNeeded(modelHash)

    if saveState then
        TriggerServerEvent('sx-chains:server:saveEquipped', chainName)
    end

    DebugPrint('Attached chain:', chainName)
    return true
end

local function UnequipChain(saveState)
    RemoveCurrentChain()

    if saveState then
        TriggerServerEvent('sx-chains:server:saveEquipped', nil)
    end

    DebugPrint('Unequipped chain')
end

local function ReattachCurrentChain()
    if not CurrentChainName then return end

    local savedName = CurrentChainName
    RemoveCurrentChain()
    Wait(200)
    AttachChain(savedName, false)
end

RegisterNetEvent('sx-chains:client:toggleChain', function(chainName)
    if IsShopOpen then
        QBCore.Functions.Notify('Clothing menu open үед chain toggle хийхгүй.', 'error')
        return
    end

    if CurrentChainName == chainName then
        UnequipChain(true)
        return
    end

    if Config.SingleChainOnly then
        AttachChain(chainName, true)
    else
        -- future multi-layer support
        AttachChain(chainName, true)
    end
end)

RegisterNetEvent('sx-chains:client:loadEquipped', function(chainName)
    RemoveCurrentChain()

    if chainName and Config.Chains[chainName] then
        Wait(Config.ReattachDelay)
        AttachChain(chainName, false)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(Config.ReattachDelay)
    TriggerServerEvent('sx-chains:server:requestEquipped')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    RemoveCurrentChain()
end)

RegisterNetEvent('hospital:client:Revive', function()
    Wait(Config.ReattachDelay)
    TriggerServerEvent('sx-chains:server:requestEquipped')
end)

RegisterNetEvent('qb-clothes:client:loadPlayerClothing', function()
    Wait(Config.ReattachDelay)
    TriggerServerEvent('sx-chains:server:requestEquipped')
end)

RegisterNetEvent('qb-clothing:client:loadOutfit', function()
    Wait(Config.ReattachDelay)
    TriggerServerEvent('sx-chains:server:requestEquipped')
end)

AddEventHandler('playerSpawned', function()
    Wait(Config.ReattachDelay)
    TriggerServerEvent('sx-chains:server:requestEquipped')
end)

if Config.HideInClothingShop then
    for _, eventName in ipairs(Config.ShopOpenEvents) do
        RegisterNetEvent(eventName, function()
            IsShopOpen = true

            if CurrentChainName then
                ShopHiddenChain = CurrentChainName
                RemoveCurrentChain()
            end
        end)
    end

    for _, eventName in ipairs(Config.ShopCloseEvents) do
        RegisterNetEvent(eventName, function()
            IsShopOpen = false

            if ShopHiddenChain and Config.Chains[ShopHiddenChain] then
                Wait(400)
                AttachChain(ShopHiddenChain, false)
                ShopHiddenChain = nil
            end
        end)
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    RemoveCurrentChain()
end)

RegisterCommand('reloadchain', function()
    if CurrentChainName then
        ReattachCurrentChain()
        QBCore.Functions.Notify('Chain reattached.', 'success')
    else
        QBCore.Functions.Notify('No chain equipped.', 'error')
    end
end, false)
