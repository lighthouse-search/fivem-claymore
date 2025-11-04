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

function can_action(player_id, claymore_id, action_type, error_on_fail)
    if (action_type == "admin") then
        if (IsPlayerAceAllowed(player_id, GetConfig().admin.ace_role)) then
            return true;
        else
            -- Need to immediately return false otherwise admin actions might get accidentally approved in the permissions JSON for large amounts of people.
            return false;
        end
    end

    local decision = false;

    if IsPlayerAceAllowed(player_id, "claymore.permission."..action_type) then
        decision = true;
    end

    if claymore_id then
        lib.print.debug("Claymore ID provided!");
        local claymore = claymore_get(claymore_id);
        local state = Entity(NetworkGetEntityFromNetworkId(claymore.entity)).state
        local xPlayer = ESX.GetPlayerFromId(player_id);

        local permissions = json.decode(state.permissions);
        if (state.permissions == nil or #permissions == 0) then
            lib.print.warn("No permissions set on Claymore ID "..claymore_id..". ");
            lib.print.info(state.permissions);
            permissions = {};
        end

        if state.claymore ~= "true" then
            error("Invalid claymore id");
            return;
        end
        
        for _, v in ipairs(permissions) do
            if (v.all == true) then
                -- Permission is applied to all players.
                lib.print.debug("Permissions callout 0");
                decision = true;
            end

            -- Check if player has permission through their job.
            if xPlayer and xPlayer.job.name then
                if v.job == xPlayer.job.name and v.permission == action_type then
                    if v.value ~= nil then
                        lib.print.debug("Permissions callout 1");
                        decision = v.value;
                    else
                        lib.print.debug("Permissions callout 2");
                        decision = true;
                    end
                end
            end

            -- Check if player has permission through their ID.
            lib.print.debug(v.player_id.." == "..player_id.." and "..v.permission.." == "..action_type);
            if v.player_id == tonumber(player_id) and v.permission == action_type then
                lib.print.debug("action_type "..action_type.." permission GRANTED to player "..player_id);
                decision = true;
            else
                lib.print.debug("action_type "..action_type.." permission DENIED to player "..player_id);
            end
        end
    else
        lib.print.debug("No Claymore ID provided, skipping most permission checks.");
    end

    if decision == false and error_on_fail ~= false then
        error("can_action: No permission " .. player_id .. " " .. (claymore_id or "none") .. " " .. tostring(action_type));
    end

    return decision;
end

function default_permissions(claymore_id, player_id)
    return { { player_id = player_id, permission = "pickup" }, { player_id = player_id, permission = "dont_explode" } };
end