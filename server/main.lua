-- RegisterCommand('explode', function(source, args)
--   local playerPed = GetPlayerPed(source)
--   local coords = GetEntityCoords(playerPed)
-- --   AddExplosion(coords.x, coords.y, coords.z, 5, 1.0, true, false, 1.0)
--   TriggerClientEvent('fivem:createExplosion', -1, 
--     coords.x, coords.y, coords.z, 
--     28, 1.0, 
--     true, false, 1.0)
-- end, false)

-- RegisterCommand('spawnobj', function(source, args)
--     local coords = GetEntityCoords(GetPlayerPed(source))
    
--     TriggerClientEvent('spawnObject:client', -1, "ch_prop_ch_ld_bomb_01a", vector3(coords.x, coords.y, coords.z - 1.0))
-- end, false)

-- Define your target coordinates and trigger distance
local triggerDistance = GetConfig().conditions.trigger_distance;
local playersInZone = {} -- Track which players are currently in the zone

-- Check all players every second
Citizen.CreateThread(function()
    while true do
        if GetConfig().feature_flags.detection == false then
            Citizen.Wait(5000) -- If detection is disabled, check less frequently
            goto continue_outer
        end

        Citizen.Wait(100)
        
        local players = GetPlayers()
        
        local already_exploded = {}
        local claymore_cams = claymore_list(0, 100); -- TODO, remove the limit here. If more than 100 claymores exist, some won't be checked.

        for _, player_id in ipairs(players) do
            local playerPed = GetPlayerPed(player_id)
            
            if (Player(player_id).state.sprinting == "false" and GetConfig().conditions.explode_on_sprint == true) then
                -- print("Player not sprinting, don't explode.");
                goto continue;
            end

            if playerPed and DoesEntityExist(playerPed) then
                local playerCoords = GetEntityCoords(playerPed);
                for i, claymore in ipairs(claymore_cams) do
                    if claymore and (claymore.entity ~= nil and claymore.x ~= nil and claymore.y ~= nil and claymore.z ~= nil) then
                        if can_action(player_id, claymore.id, "dont_explode") == true then
                            print("Player has 'dont_explode' permission, don't explode.");
                        else
                            -- if (GetPedConfigFlag(playerPed, 58, true) == true) then
                            --     goto continue;
                            -- end
                            local targetCoords = vector3(claymore.x, claymore.y, claymore.z);
                            local distance = #(playerCoords - targetCoords);

                            -- Player entered the zone
                            if not already_exploded[claymore.id] then
                                if distance <= triggerDistance then
                                    if not playersInZone[player_id] then
                                        playersInZone[player_id] = true
                                        already_exploded[claymore.id] = true;
                                        OnPlayerEnterZone(player_id, claymore);
                                    end

                                    local ex, ey, ez
                                    if claymore.entity and DoesEntityExist(claymore.entity) then
                                        print("USING ENTITY COORDINATES");
                                        local v = GetEntityCoords(claymore.entity)
                                        ex, ey, ez = v.x, v.y, v.z
                                    else
                                        print("USING STATIC COORDINATES");
                                        ex, ey, ez = claymore.x, claymore.y, claymore.z
                                    end

                                    TriggerClientEvent('fivem:createExplosion', -1, 
                                        ex, ey, ez, 
                                        28, 1.0, 
                                        true, false, 1.0);

                                    claymore_remove(claymore.id, true);
                                -- Player left the zone
                                else
                                    if playersInZone[player_id] then
                                        playersInZone[player_id] = nil
                                        OnPlayerLeaveZone(player_id);
                                    end
                                end
                            end
                        end
                    end
                end
            end

            ::continue::
        end
    end

    ::continue_outer::
end)

-- Event triggered when a player enters the zone
function OnPlayerEnterZone(player_id, claymore)
    local playerName = GetPlayerName(player_id)
    print(playerName .. " entered the proximity zone!")
    
    TriggerClientEvent('ox_lib:notify', player_id, {
        title = 'System',
        description = "You entered a special zone!",
        type = 'success'
    });
end

-- Event triggered when a player leaves the zone
function OnPlayerLeaveZone(player_id)
    local playerName = GetPlayerName(player_id)

    TriggerClientEvent('ox_lib:notify', player_id, {
        title = 'System',
        description = "You left a special zone!!",
        type = 'error'
    });
    
    -- Optional: notify player they left
    -- TriggerClientEvent('chat:addMessage', player_id, {
    --     args = {"System", "You left the special zone."}
    -- })
end

-- Clean up when player disconnects
AddEventHandler('playerDropped', function()
    local player_id = source
    playersInZone[player_id] = nil
end)

RegisterNetEvent('hades_claymore:sprinting_state')
AddEventHandler('hades_claymore:sprinting_state', function(sprinting)
    local src = source
    print('called my event', src)
    print("Is sprinting:", sprinting)
    Player(src).state:set('sprinting', tostring(sprinting), true)
end)