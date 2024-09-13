VORPcore = exports.vorp_core:GetCore()

local goldPanUse = {}

-------------------------------------Register Usable Items-------------------------------------

exports.vorp_inventory:registerUsableItem(Config.emptyMudBucket, function(data) --Use the empty mud bucket
    TriggerClientEvent('bcc-goldpanning:useEmptyMudBucket', data.source, data.item.amount)
    exports.vorp_inventory:closeInventory(data.source)
end)

exports.vorp_inventory:registerUsableItem(Config.goldwashProp, function(data)   --The Gold Wash Table
    TriggerClientEvent('bcc-goldpanning:placeProp', data.source, data.item.item)
    exports.vorp_inventory:subItem(data.source, Config.goldwashProp, 1)
    exports.vorp_inventory:closeInventory(data.source)
end)

if Config.useWaterItems then
    exports.vorp_inventory:registerUsableItem(Config.emptyWaterBucket, function(data) --Use the water bucket
        TriggerClientEvent('bcc-goldpanning:useWaterBucket', data.source, data.item.amount)
        exports.vorp_inventory:closeInventory(data.source)
    end)
end

-------------------------------------Logic for Mud Buckets-------------------------------------

RegisterServerEvent('bcc-goldpanning:mudBuckets')   -- Use the empty mud bucket and gain a mud bucket
AddEventHandler('bcc-goldpanning:mudBuckets', function()
    local _source = source
    if exports.vorp_inventory:canCarryItem(_source, Config.mudBucket, 1, nil) then --Check if player can carry the mud bucket
        exports.vorp_inventory:subItem(_source, Config.emptyMudBucket, 1)
        if Config.debug then
            print("player " .. _source .. " has used a empty mud bucket")
        end
        VORPcore.NotifyRightTip(_source, _U('usedEmptyMudBucket'), 3000)

        exports.vorp_inventory:addItem(_source, Config.mudBucket, 1)
        if Config.debug then
            print("player " .. _source .. " has received a mud bucket")
        end
        VORPcore.NotifyRightTip(_source, _U('receivedEmptyMudBucket'), 3000)
    else
        VORPcore.NotifyRightTip(_source, _U('cannotCarryMoreMudBuckets'), 3000)
    end
end)

RegisterServerEvent('bcc-goldpanning:waterBuckets') -- Use the empty mud bucket and gain a mud bucket
AddEventHandler('bcc-goldpanning:waterBuckets', function()
    local _source = source
    if exports.vorp_inventory:canCarryItem(_source, Config.waterBucket, 1, nil) then --Check if player can carry the mud bucket
        exports.vorp_inventory:subItem(_source, Config.emptyWaterBucket, 1)
        if Config.debug then
            print("player " .. _source .. " has used a empty water bucket")
        end
        VORPcore.NotifyRightTip(_source, _U('receivedEmptyWaterBucket'), 3000)

        exports.vorp_inventory:addItem(_source, Config.waterBucket, 1)
        if Config.debug then
            print("player " .. _source .. " has received a water bucket")
        end
        VORPcore.NotifyRightTip(_source, _U('receivedEmptyWaterBucket'), 3000)
    else
        VORPcore.NotifyRightTip(_source, _U('cantCarryMoreEmptyWaterCans'), 3000)
    end
end)

-------------------------------------Handle Prompt responses-------------------------------------
RegisterServerEvent('bcc-goldpanning:useMudBucket') -- Use the mud bucket
AddEventHandler('bcc-goldpanning:useMudBucket', function()
    local _source = source
    local itemCount = exports.vorp_inventory:getItemCount(_source, nil, Config.mudBucket) --Check if player has a mud bucket

    if exports.vorp_inventory:canCarryItem(_source, Config.emptyMudBucket, 1, nil) then   --Check if player can carry the empty mud bucket rest of the code is self explanatory
        if itemCount > 0 then
            exports.vorp_inventory:subItem(_source, Config.mudBucket, 1)
            VORPcore.NotifyRightTip(_source, _U('usedMudBucket'), 3000)
            exports.vorp_inventory:addItem(_source, Config.emptyMudBucket, 1)
            VORPcore.NotifyRightTip(_source, _U('receivedEmptyMudBucket'), 3000)
            TriggerClientEvent('bcc-goldpanning:mudBucketUsedSuccess', _source)
        else
            VORPcore.NotifyRightTip(_source, _U('dontHaveMudBucket'), 3000)
            TriggerClientEvent("bcc-goldpanning:mudBucketUsedfailure", _source)
        end
    else
        VORPcore.NotifyRightTip(_source, _U('cannotCarryMoreMudBuckets'), 3000)
    end
end)

RegisterServerEvent('bcc-goldpanning:useWaterBucket')
AddEventHandler('bcc-goldpanning:useWaterBucket', function()
    local _source = source
    local itemCount = exports.vorp_inventory:getItemCount(_source, nil, Config.waterBucket)
    if exports.vorp_inventory:canCarryItem(_source, Config.emptyWaterBucket, 1, nil) then
        if itemCount > 0 then
            exports.vorp_inventory:subItem(_source, Config.waterBucket, 1)
            VORPcore.NotifyRightTip(_source, _U('usedWaterBucket'), 3000)
            exports.vorp_inventory:addItem(_source, Config.emptyWaterBucket, 1)
            VORPcore.NotifyRightTip(_source, _U('receivedEmptyWaterBucket'), 3000)
            TriggerClientEvent('bcc-goldpanning:waterUsedSuccess', _source)
        else
            VORPcore.NotifyRightTip(_source, _U('dontHaveWaterBucket'), 3000)
            TriggerClientEvent("bcc-goldpanning:waterUsedfailure", _source)
        end
    else
        VORPcore.NotifyRightTip(_source, _U('cantCarryMoreEmptyWaterCans'), 3000)
    end
end)

RegisterServerEvent('bcc-goldpanning:usegoldPan')
AddEventHandler('bcc-goldpanning:usegoldPan', function()
    local _source = source
    local itemCount = exports.vorp_inventory:getItemCount(_source, nil, Config.goldPan)
    if exports.vorp_inventory:canCarryItem(_source, Config.emptyWaterBucket, 1, nil) then
        if itemCount > 0 then
            local toolUsage = Config.ToolUsage
            local tool = exports.vorp_inventory:getItem(_source, Config.goldPan)
            local toolMeta =  tool['metadata']
        
            if next(toolMeta) == nil then
                exports.vorp_inventory:subItem(_source, Config.goldPan, 1, {})
                exports.vorp_inventory:addItem(_source, Config.goldPan, 1, { description = Config.UsageLeft .. 100 - toolUsage, durability = 100 - toolUsage })
            else
                local durabilityValue = toolMeta.durability - toolUsage
                exports.vorp_inventory:subItem(_source, Config.goldPan, 1, toolMeta)
                if durabilityValue >= toolUsage then
                    exports.vorp_inventory:subItem(_source, Config.goldPan, 1, toolMeta)
                    exports.vorp_inventory:addItem(_source, Config.goldPan, 1, { description = Config.UsageLeft .. durabilityValue, durability = durabilityValue })
                elseif durabilityValue < toolUsage then
                    exports.vorp_inventory:subItem(_source, Config.goldPan, 1, toolMeta)
                    VORPcore.NotifyRightTip(_source, _U('needNewTool'), 4000)
                end
            end
            TriggerClientEvent('bcc-goldpanning:goldPanUsedSuccess', _source)
            goldPanUse[_source] = true
            Citizen.CreateThread(function()
                Citizen.Wait(30000)
                goldPanUse[_source] = nil
            end)
        else
            VORPcore.NotifyRightTip(_source, _U('noPan'), 3000)
            TriggerClientEvent("bcc-goldpanning:goldPanfailure", _source)
        end
    else
        VORPcore.NotifyRightTip(_source, _U('cantCarryMoreEmptyWaterCans'), 3000)
    end
end)

RegisterServerEvent('bcc-goldpanning:placePropGlobal')
AddEventHandler('bcc-goldpanning:placePropGlobal', function(propName, x, y, z, heading)
    TriggerClientEvent('bcc-goldpanning:spawnPropForAll', -1, propName, x, y, z, heading)
end)

-------------------------------------Handle Gold Rewards-------------------------------------
RegisterServerEvent('bcc-goldpanning:panSuccess')
AddEventHandler('bcc-goldpanning:panSuccess', function()
    local _source = source
    if exports.vorp_inventory:canCarryItem(_source, Config.goldWashReward, Config.goldWashRewardAmount) and goldPanUse[_source] then
        exports.vorp_inventory:addItem(_source, Config.goldWashReward, Config.goldWashRewardAmount)
        VORPcore.NotifyRightTip(_source, _U('receivedGoldFlakes'), 3000)
        if Config.debug then
            print("player " .. _source .. " has received " .. Config.goldWashRewardAmount .. " gold flakes")
        end
    else
        VORPcore.NotifyRightTip(_source, _U('cantCarryMoreGoldFlakes'), 3000)
    end

    if math.random(100) <= Config.extraRewardChance and goldPanUse[_source] then
        exports.vorp_inventory:addItem(_source, Config.extraReward, Config.extraRewardAmount)
        VORPcore.NotifyRightTip(_source, _U('receivedExtraReward'), 3000)
        if Config.debug then
            print("player " .. _source .. " has received " .. Config.extraRewardAmount .. " extra reward")
        end
    end

    if not goldPanUse[_source] then
        --prob cheater
        return
    end
    goldPanUse[_source] = nil
end)

-------------------------------------Handle Prop Returns-------------------------------------
RegisterServerEvent('bcc-goldpanning:givePropBack')
AddEventHandler('bcc-goldpanning:givePropBack', function()
    local _source = source
    if exports.vorp_inventory:canCarryItem(_source, Config.goldwashProp, 1, nil) then
        exports.vorp_inventory:addItem(_source, Config.goldwashProp, 1)
        VORPcore.NotifyRightTip(_source, _U('propPickup'), 3000)
    else
        VORPcore.NotifyRightTip(_source, _U('propFull'), 3000)
    end
end)

RegisterServerEvent('bcc-goldpanning:addMudBack')
AddEventHandler('bcc-goldpanning:addMudBack', function()
    local _source = source
    exports.vorp_inventory:addItem(_source, Config.emptyMudBucket, 1)
end)

RegisterServerEvent('bcc-goldpanning:addWaterBack')
AddEventHandler('bcc-goldpanning:addWaterBack', function()
    local _source = source
    exports.vorp_inventory:addItem(_source, Config.emptyWaterBucket, 1)
end)

RegisterServerEvent('bcc-goldpanning:checkCanCarry')
AddEventHandler('bcc-goldpanning:checkCanCarry', function(itemName)
    local _source = source
    local canCarry = exports.vorp_inventory:canCarryItem(_source, itemName, 1)
    TriggerClientEvent('bcc-goldpanning:canCarryResponse', _source, canCarry)
end)
