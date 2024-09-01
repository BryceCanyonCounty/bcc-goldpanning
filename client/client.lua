VORPcore = exports.vorp_core:GetCore() -- NEW includes  new callback system
BccUtils = exports['bcc-utils'].initiate()
Progressbar = exports["feather-progressbar"]:initiate()
local MiniGame = exports['bcc-minigames'].initiate()



local placing = false
local prompt = false
local BuildPrompt, DelPrompt, PlacingObj
local stage = "mudBucket"

local promptGroup = BccUtils.Prompt:SetupPromptGroup()
local useMudBucketPrompt = promptGroup:RegisterPrompt(_U('promptMudBucket'), Config.keys.E, 1, 1, true, 'hold',
    { timedeventhash = "MEDIUM_TIMED_EVENT" })
local useWaterBucketPrompt = promptGroup:RegisterPrompt(_U('promptWaterBucket'), Config.keys.R, 1, 1, true, 'hold',
    { timedeventhash = "MEDIUM_TIMED_EVENT" })
local useGoldPanPrompt = promptGroup:RegisterPrompt(_U('promptPan'), Config.keys.G, 1, 1, true, 'hold',
    { timedeventhash = "MEDIUM_TIMED_EVENT" })
local removeTablePrompt = promptGroup:RegisterPrompt(_U('promptPickUp'), Config.keys.F, 1, 1, true, 'hold',
    { timedeventhash = "MEDIUM_TIMED_EVENT" })


local function RemoveTable() -- Initiates check to remove the spawned prop
    TriggerServerEvent('bcc-goldpanning:checkCanCarry', Config.goldwashProp)
end

local props = {}
local objectCounter = 0

-----------------------------------Mud Bucket-----------------------------------

function IsNearWater()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed, true)
    local waterHash = Citizen.InvokeNative(0x5BA7A68A346A5A91, coords.x, coords.y, coords.z) -- GetWaterMapZoneAtCoords
    local pos = GetEntityCoords(PlayerPedId(), true)

    print(isInAllowedZone)

    local isInAllowedZone = false
    for i = 1, #Config.waterTypes do
        local waterZone = Config.waterTypes[i]
        if waterHash == joaat(waterZone.hash) and IsPedOnFoot(playerPed) and IsEntityInWater(playerPed) then
            isInAllowedZone = true
            break
        end
    end

    if not isInAllowedZone then
        VORPcore.NotifyObjective(_U('noWater'),4000)
        return
    end
    return isInAllowedZone
end

local activePrompts = {
    mudBucket = false,
    waterBucket = false,
    goldPan = false,
    removeTable = true,
}

CreateThread(function()
    while true do
        Wait(5)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local prop = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 2.0,
            GetHashKey(Config.goldwashProp), false, false, false)

        if props then
            for objectid, objdata in pairs(props) do
                local objCoords = objdata.coords
                local distance = GetDistanceBetweenCoords(playerCoords, objCoords, true)
                if distance < 2.0 and objdata.object and not placing then
                    if DoesEntityExist(TempObj) then
                        promptGroup:ShowGroup("Gold Panning")

                        -- Only toggle prompts based on their active state
                        useMudBucketPrompt:TogglePrompt(activePrompts.mudBucket and stage == "mudBucket")
                        useWaterBucketPrompt:TogglePrompt(activePrompts.waterBucket and stage == "waterBucket")
                        useGoldPanPrompt:TogglePrompt(activePrompts.goldPan and stage == "goldPan")
                        removeTablePrompt:TogglePrompt(activePrompts.removeTable)

                        -- Mud Bucket
                        if stage == "mudBucket" and useMudBucketPrompt:HasCompleted() and activePrompts.mudBucket then
                            TriggerServerEvent('bcc-goldpanning:useMudBucket')
                            activePrompts.mudBucket = false
                        end
                        -- Water Bucket
                        if stage == "waterBucket" and useWaterBucketPrompt:HasCompleted() and activePrompts.waterBucket then
                            TriggerServerEvent('bcc-goldpanning:useWaterBucket')
                            activePrompts.waterBucket = false
                        end
                        -- Gold Pan
                        if stage == "goldPan" and useGoldPanPrompt:HasCompleted() and activePrompts.goldPan then
                            TriggerServerEvent('bcc-goldpanning:usegoldPan')
                            activePrompts.goldPan = false
                        end
                        -- Remove Table
                        if removeTablePrompt:HasCompleted() and activePrompts.removeTable then
                            RemoveTable()
                            activePrompts.removeTable = false
                        end
                    else
                        ResetActivePrompts()
                    end
                else
                    ResetActivePrompts()
                end
            end
            end
    end
end)

function ResetActivePrompts()
    activePrompts.mudBucket = true
    activePrompts.waterBucket = true
    activePrompts.goldPan = true
    activePrompts.removeTable = true
end

RegisterNetEvent('bcc-goldpanning:mudBucketUsedSuccess', function()
    local playerPed = PlayerPedId()
    Citizen.InvokeNative(0x524B54361229154F, playerPed, GetHashKey('WORLD_HUMAN_BUCKET_POUR_LOW'), -1, true, 0, -1, false)
    Progressbar.start("Pouring mud", Config.bucketingTime, function()
        ClearPedTasks(playerPed, true, true)
        Citizen.InvokeNative(0xFCCC886EDE3C63EC, playerPed, 2, true)
        Wait(100)
    end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')
    Wait(Config.bucketingTime)
    stage = "waterBucket"
end)



RegisterNetEvent('bcc-goldpanning:waterUsedSuccess', function()
    local playerPed = PlayerPedId()
    Citizen.InvokeNative(0x524B54361229154F, playerPed, GetHashKey('WORLD_HUMAN_BUCKET_POUR_LOW'), -1, true, 0, -1, false)
    Progressbar.start(_U('pouringWater'), Config.bucketingTime, function()
        ClearPedTasks(playerPed, true, true)
        Citizen.InvokeNative(0xFCCC886EDE3C63EC, playerPed, 2, true)
        Wait(100)
    end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')
    Wait(Config.bucketingTime)
    stage = "goldPan"
end)

RegisterNetEvent('bcc-goldpanning:goldPanUsedSuccess', function()
    MiniGame.Start('skillcheck', Config.Minigame, function(result)
        if result.passed then
            PlayAnim("script_re@gold_panner@gold_success", "panning_idle", Config.goldWashTime, true, true)
            Wait(Config.goldWashTime)
            TriggerServerEvent('bcc-goldpanning:panSuccess')
            stage = "mudBucket"
        end
    end)
end)

RegisterNetEvent('bcc-goldpanning:mudBucketUsedfailure', function()
    stage = "mudBucket"
    ResetActivePrompts()
end)
RegisterNetEvent('bcc-goldpanning:waterUsedfailure', function()
    stage = "mudBucket"
    ResetActivePrompts()
end)
RegisterNetEvent('bcc-goldpanning:goldPanfailure', function()
    stage = "mudBucket"
    ResetActivePrompts()
end)


RegisterNetEvent('bcc-goldpanning:useEmptyMudBucket')
AddEventHandler('bcc-goldpanning:useEmptyMudBucket', function()
    if IsNearWater() then
        local playerPed = PlayerPedId()
        Citizen.InvokeNative(0x524B54361229154F, playerPed, GetHashKey('WORLD_HUMAN_BUCKET_FILL'), -1, true, 0, -1, false)
        Progressbar.start(_U('collectingMud'), Config.bucketingTime, function()
            ClearPedTasks(playerPed, true, true)
            Citizen.InvokeNative(0xFCCC886EDE3C63EC, playerPed, 2, true)
            Wait(100)
            TriggerServerEvent('bcc-goldpanning:mudBuckets')
        end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')
    end
end)


RegisterNetEvent('bcc-goldpanning:useWaterBucket')
AddEventHandler('bcc-goldpanning:useWaterBucket', function()
    if IsNearWater() then
        local playerPed = PlayerPedId()
        Citizen.InvokeNative(0x524B54361229154F, playerPed, GetHashKey('WORLD_HUMAN_BUCKET_FILL'), -1, true, 0, -1, false)
        Progressbar.start(_U('collectingWater'), Config.bucketingTime, function()
            ClearPedTasks(playerPed, true, true)
            Citizen.InvokeNative(0xFCCC886EDE3C63EC, playerPed, 2, true)
            Wait(100)
            TriggerServerEvent('bcc-goldpanning:waterBuckets')
        end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')
    end
end)

RegisterNetEvent('bcc-goldpanning:canCarryResponse')
AddEventHandler('bcc-goldpanning:canCarryResponse', function(canCarry)
    if canCarry then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local prop = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 2.0,
            GetHashKey(Config.goldwashProp), false, false, false)

        if prop ~= 0 then
            DeleteObject(prop)
            TriggerServerEvent('bcc-goldpanning:givePropBack')
        end
    else
        VORPcore.NotifyObjective(_U('propFull'), 4000)
    end
end)




-----------------------------------PROP STUFF-----------------------------------

function SetupBuildPrompt() -- Sets up the prompt for building the prop
    local str = _U('BuildPrompt')
    BuildPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(BuildPrompt, Config.keys.R)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(BuildPrompt, str)
    PromptSetEnabled(BuildPrompt, false)
    PromptSetVisible(BuildPrompt, false)
    PromptSetHoldMode(BuildPrompt, true)
    PromptRegisterEnd(BuildPrompt)
end

function SetupDelPrompt() -- Sets up the prompt for deleting the prop when being placed
    local str = _U('DelPrompt')
    DelPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(DelPrompt, Config.keys.E)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(DelPrompt, str)
    PromptSetEnabled(DelPrompt, false)
    PromptSetVisible(DelPrompt, false)
    PromptSetHoldMode(DelPrompt, true)
    PromptRegisterEnd(DelPrompt)
end

RegisterNetEvent('bcc-goldpanning:placeProp') --you guessed it, places the prop
AddEventHandler('bcc-goldpanning:placeProp', function(propName)
    SetupBuildPrompt()
    SetupDelPrompt()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed, true)
    local waterHash = Citizen.InvokeNative(0x5BA7A68A346A5A91, coords.x, coords.y, coords.z)
    local pos = GetEntityCoords(PlayerPedId(), true)


    local isInAllowedZone = false
    for _, waterZone in ipairs(Config.waterTypes) do
        if waterHash == GetHashKey(waterZone.hash) and IsPedOnFoot(playerPed) and IsEntityInWater(playerPed) then
            isInAllowedZone = true
            break
        end
    end

    if not isInAllowedZone then
        VORPcore.NotifyObjective(_U('noWater'), 4000)
        TriggerServerEvent('bcc-goldpanning:givePropBack')
        return
    end

    local pHead = GetEntityHeading(playerPed)
    local object = GetHashKey(propName)
    if not HasModelLoaded(object) then
        RequestModel(object)
    end
    while not HasModelLoaded(object) do
        Wait(5)
    end

    placing = true
    PlacingObj = CreateObject(object, pos.x, pos.y, pos.z, false, true, false)
    SetEntityHeading(PlacingObj, pHead)
    SetEntityAlpha(PlacingObj, 51)
    AttachEntityToEntity(PlacingObj, PlayerPedId(), 0, 0.0, 1.0, -0.7, 0.0, 0.0, 0.0, true, false, false, false, false,
        true)
    while placing do
        Wait(10)
        if prompt == false then
            PromptSetEnabled(BuildPrompt, true)
            PromptSetVisible(BuildPrompt, true)
            PromptSetEnabled(DelPrompt, true)
            PromptSetVisible(DelPrompt, true)
            prompt = true
        end
        if PromptHasHoldModeCompleted(BuildPrompt) then
            PromptSetEnabled(BuildPrompt, false)
            PromptSetVisible(BuildPrompt, false)
            PromptSetEnabled(DelPrompt, false)
            PromptSetVisible(DelPrompt, false)
            prompt = false
            local PropPos = GetEntityCoords(PlacingObj, true)
            local PropHeading = GetEntityHeading(PlacingObj)
            DeleteObject(PlacingObj)
            Progressbar.start(_U('buildingTable'), Config.washBuildTime, function()
            end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')
            TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_SLEDGEHAMMER'), -1, true, false, false, false)
            Citizen.Wait(Config.washBuildTime)
            ClearPedTasksImmediately(PlayerPedId())
            if propName == Config.goldwashProp then
                TempObj = CreateObject(object, PropPos.x, PropPos.y, PropPos.z, true, true, true)
                SetEntityHeading(TempObj, PropHeading)
                PlaceObjectOnGroundProperly(TempObj)
                placing = false
                if TempObj then
                    objectCounter = objectCounter + 1
                    local objectId = "obj_" .. objectCounter
                    props[objectId] = { object = TempObj, coords = vector3(PropPos.x, PropPos.y, PropPos.z) }
                else
                    print("Failed to create " .. propName)
                end
            end
            break
        end
        if PromptHasHoldModeCompleted(DelPrompt) then
            PromptSetEnabled(BuildPrompt, false)
            PromptSetVisible(BuildPrompt, false)
            PromptSetEnabled(DelPrompt, false)
            PromptSetVisible(DelPrompt, false)
            DeleteObject(PlacingObj)
            prompt = false
            TriggerServerEvent('bcc-goldpanning:givePropBack')
            break
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    prompt = false
    PromptSetEnabled(BuildPrompt, false)
    PromptSetVisible(BuildPrompt, false)
    PromptSetEnabled(BrewPrompt, false)
    PromptSetVisible(BrewPrompt, false)
    PromptSetEnabled(DelPrompt, false)
    PromptSetVisible(DelPrompt, false)
    DeleteEntity(PlacingObj)
end)


-----------------------------------Animations-----------------------------------
function PlayAnim(animDict, animName, time, raking, loopUntilTimeOver) --function to play an animation
    local animTime = time
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(100)
    end
    local flag = 16
    -- if time is -1 then play the animation in an infinite loop which is not possible with flag 16 but with 1
    -- if time is -1 the caller has to deal with ending the animation by themselve
    if loopUntilTimeOver then
        flag = 1
        animTime = -1
    end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, 1.0, animTime, flag, 0, true, 0, false, 0, false)
    if raking then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local rakeObj = CreateObject(Config.goldSiftingProp, playerCoords.x, playerCoords.y, playerCoords.z, true, true,
            false)
        AttachEntityToEntity(rakeObj, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)
        Progressbar.start(_U('siftingGold'), time, function()
            Wait(5)
            DeleteObject(rakeObj)
            ClearPedTasksImmediately(PlayerPedId())
        end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')
    else
        Wait(time)
        ClearPedTasksImmediately(PlayerPedId())
    end
end

function ScenarioInPlace(hash, time) -- CHANGE ALL SCENARIOS OR REMOVE
    local pl = PlayerPedId()
    FreezeEntityPosition(pl, true)
    TaskStartScenarioInPlace(pl, joaat(hash), time, true, false, false, false)
    Wait(time)
    ClearPedTasksImmediately(pl)
    FreezeEntityPosition(pl, false)
end
