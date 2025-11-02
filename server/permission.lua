-- Internal API to check if player can use Claymore. This function is called by all major Claymore APIs.
function can_claymore(player_id, claymore_id, action_type)
    -- NOTE: "camera_id" will be nil if action_type is not "view", "global_remove" or no single Claymore is being operated on (e.g. listing all cameras).
    
    -- Check action type ("place" or "view"), e.g. we might allow some players (e.g. judges) to view cameras but not place them.
    if action_type ~= "place" and action_type ~= "view" and action_type ~= "global_remove" then
        error("can_claymore: Invalid action type: " .. tostring(action_type));
    end

    -- Check if the player has permission to view Claymore cameras. For actual production use, we'd check if the player is PD/etc.
    if IsPlayerAceAllowed(player_id, "claymore.view_and_place") then
        return true
    else
        TriggerClientEvent('ox_lib:notify', player_id, { type = 'error', title = 'Claymore Failed', description = "You don't have permission!" });
        error("can_claymore: Permission failed: " .. tostring(action_type));
    end
end

function can_action(player_id, claymore_id, action_type)
    local claymore = claymore_get(claymore_id);
    local state = Entity(NetworkGetEntityFromNetworkId(claymore.entity)).state
    local permissions = state.permissions;
    local xPlayer = ESX.GetPlayerFromId(player_id)

    if state.claymore ~= true then
        return false;
    end

    for _, v in ipairs(permissions) do
        if (v.all == true) then
            -- Permission is applied to all players.
            return true;
        end

        -- Check if player has permission through their job.
        if xPlayer and xPlayer.job.name then
            if v.job == xPlayer.job.name and v.permission == action_type then
                if v.value ~= nil then
                    return v.value;
                else
                    return true
                end
            end
        end

        -- Check if player has permission through their ID.
        if v.player_id == player_id and v.permission == action_type then
            return true
        end
    end

    if IsPlayerAceAllowed(player_id, "claymore.permission."..action_type) then
        return true;
    end

    -- Nothing granted permission.
    return false;
end