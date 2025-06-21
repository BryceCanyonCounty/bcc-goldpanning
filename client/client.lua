-- Refactored and optimized version of the Gold Panning script

-- Core dependency setups
VORPcore = exports.vorp_core:GetCore()
BccUtils = exports['bcc-utils'].initiate()
Progressbar = exports['feather-progressbar']:initiate()
local MiniGame = exports['bcc-minigames']:initiate()

-- State management variables
local placing, prompt = false, false
local BuildPrompt, DelPrompt, PlacingObj, TempObj
local stage = "mudBucket"

-- Track placed props
local props = {}
local objectCounter = 0

-- Set up a prompt group
local promptGroup = BccUtils.Prompt:SetupPromptGroup()

-- Helper to create standard prompts for each gold panning stage
local function RegisterPanningPrompt(nameKey, key)
    return promptGroup:RegisterPrompt(_U(nameKey), key, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
end

-- Prompts for each stage
local useMudBucketPrompt = RegisterPanningPrompt('promptMudBucket', Config.keys.E)
local useWaterBucketPrompt = RegisterPanningPrompt('promptWaterBucket', Config.keys.R)
local useGoldPanPrompt = RegisterPanningPrompt('promptPan', Config.keys.G)
local removeTablePrompt = RegisterPanningPrompt('promptPickUp', Config.keys.F)

-- Current active prompts toggle table
local activePrompts = {
    mudBucket = true,
    waterBucket = true,
    goldPan = true,
    removeTable = true,
}

-- Resets all prompts to active
local function ResetActivePrompts()
    for k in pairs(activePrompts) do
        activePrompts[k] = true
    end
end

-- Checks if the player is in a valid water zone
local function IsPlayerInValidWater()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local waterHash = Citizen.InvokeNative(0x5BA7A68A346A5A91, pos.x, pos.y, pos.z)
    for _, zone in ipairs(Config.waterTypes) do
        if waterHash == joaat(zone.hash) and IsPedOnFoot(ped) and IsEntityInWater(ped) then
            return true
        end
    end
    return false
end

-- Generic prompt handler by stage
local function HandlePrompt(stageKey, prompt, trigger, resetKey)
    if stage == stageKey and prompt:HasCompleted() and activePrompts[resetKey] then
        TriggerServerEvent(trigger)
        activePrompts[resetKey] = false
    end
end

-- Unified bucket fill handling with animation, water check, and progress bar
local function HandleBucketFill(serverEvent, animationName, progressText)
    if not IsPlayerInValidWater() then
        VORPcore.NotifyObjective(_U('noWater'), 4000)
        return
    end
    local ped = PlayerPedId()
    Citizen.InvokeNative(0x524B54361229154F, ped, GetHashKey(animationName), -1, true, 0, -1, false)
    Progressbar.start(progressText, Config.bucketingTime, function()
        ClearPedTasks(ped, true, true)
        Citizen.InvokeNative(0xFCCC886EDE3C63EC, ped, 2, true)
        TriggerServerEvent(serverEvent)
    end, 'linear', 'rgba(255,255,255,0.8)', '20vw', 'rgba(255,255,255,0.1)', 'rgba(211,211,211,0.5)')
end

-- Universal animation playing function for gold panning and raking
function PlayAnim(animDict, animName, time, raking, loopUntilTimeOver)
    local animTime = time
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(100) end

    local flag = loopUntilTimeOver and 1 or 16
    if not loopUntilTimeOver then animTime = time end

    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, 1.0, animTime, flag, 0, true, 0, false, 0, false)

    if raking then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local rakeObj = CreateObject(Config.goldSiftingProp, playerCoords.x, playerCoords.y, playerCoords.z, true, true, false)
        AttachEntityToEntity(rakeObj, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)
        Progressbar.start(_U('siftingGold'), time, function()
            Wait(5)
            DeleteObject(rakeObj)
            ClearPedTasksImmediately(PlayerPedId())
        end, 'linear', 'rgba(255,255,255,0.8)', '20vw', 'rgba(255,255,255,0.1)', 'rgba(211,211,211,0.5)')
    else
        Wait(time)
        ClearPedTasksImmediately(PlayerPedId())
    end
end

-- Abstracted prompt setup helper
function SetupPrompt(controlKey, labelKey)
    local prompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(prompt, controlKey)
    local str = CreateVarString(10, 'LITERAL_STRING', _U(labelKey))
    PromptSetText(prompt, str)
    PromptSetEnabled(prompt, false)
    PromptSetVisible(prompt, false)
    PromptSetHoldMode(prompt, true)
    PromptRegisterEnd(prompt)
    return prompt
end

-- Initialize Build/Delete prompts
BuildPrompt = SetupPrompt(Config.keys.R, 'BuildPrompt')
DelPrompt = SetupPrompt(Config.keys.E, 'DelPrompt')

-- Handles the entire placement and build process of the gold wash prop
function PlaceGoldwashProp(propName)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local waterHash = Citizen.InvokeNative(0x5BA7A68A346A5A91, pos.x, pos.y, pos.z)

    local inZone = false
    for _, zone in ipairs(Config.waterTypes) do
        if waterHash == GetHashKey(zone.hash) and IsPedOnFoot(ped) and IsEntityInWater(ped) then
            inZone = true
            break
        end
    end

    if not inZone then
        VORPcore.NotifyObjective(_U('noWater'), 4000)
        TriggerServerEvent('bcc-goldpanning:givePropBack')
        return
    end

    if not HasModelLoaded(propName) then RequestModel(propName) end
    while not HasModelLoaded(propName) do Wait(5) end

    placing = true
    PlacingObj = CreateObject(propName, pos.x, pos.y, pos.z, false, true, false)
    SetEntityHeading(PlacingObj, heading)
    SetEntityAlpha(PlacingObj, 51)
    AttachEntityToEntity(PlacingObj, ped, 0, 0.0, 1.0, -0.7, 0.0, 0.0, 0.0, true, false, false, false, false, true)

    while placing do
        Wait(10)
        if not prompt then
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

            local propPos = GetEntityCoords(PlacingObj)
            local propHeading = GetEntityHeading(PlacingObj)
            DeleteObject(PlacingObj)

            Progressbar.start(_U('buildingTable'), Config.washBuildTime, function() end, 'linear', 'rgba(255,255,255,0.8)',
                '20vw', 'rgba(255,255,255,0.1)', 'rgba(211,211,211,0.5)')
            TaskStartScenarioInPlace(ped, GetHashKey('WORLD_HUMAN_SLEDGEHAMMER'), -1, true, false, false, false)
            Wait(Config.washBuildTime)
            ClearPedTasksImmediately(ped)

            TempObj = CreateObject(propName, propPos.x, propPos.y, propPos.z, true, true, true)
            SetEntityHeading(TempObj, propHeading)
            PlaceObjectOnGroundProperly(TempObj)
            placing = false

            if TempObj then
                objectCounter += 1
                props["obj_" .. objectCounter] = { object = TempObj, coords = vector3(propPos.x, propPos.y, propPos.z) }
            else
                print("Failed to create " .. propName)
            end
            break
        elseif PromptHasHoldModeCompleted(DelPrompt) then
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
end

-- Cleanup prompt state on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    prompt = false
    PromptSetEnabled(BuildPrompt, false)
    PromptSetVisible(BuildPrompt, false)
    PromptSetEnabled(DelPrompt, false)
    PromptSetVisible(DelPrompt, false)
    if DoesEntityExist(PlacingObj) then
        DeleteEntity(PlacingObj)
    end
end)
