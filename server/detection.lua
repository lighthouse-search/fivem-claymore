-- Create a thread that continuously checks player positions against Claymore coordinates and the target range..
Citizen.CreateThread(function()
    while true do
        -- Wait 100ms before starting each run. We don't want this running too fast and spamming the database.
        Citizen.Wait(100)

        -- Check if detection was disabled by feature flag.
        if GetConfig().feature_flags.detection == false then
            lib.print.debug("Detection disabled by feature flag.");
            goto continue_outer;
        end
        
        -- Get all players in server.
        local players = GetPlayers()

        -- Keep list of claymores that have already exploded. We don't want to re-query the database for every player, but we also don't want claymores exploding multiple times when multiple players are in a claymore zone. We check against this variable before exploding to prevents this.
        local already_exploded = {}

        -- Query database for claymores.
        local claymore_cams = claymore_list(nil, nil);

        -- Check the position of every player, are they within range of a claymore?
        for _, player_id in ipairs(players) do
            local playerPed = GetPlayerPed(player_id);

            if Player(player_id).state.noclipping == "true" then
                lib.print.debug("Player "..player_id.." is noclipping, skipping detection.");
                goto continue;
            end
            
            -- Check if admins only want us exploding on sprint. If so, and the player is not sprinting, we skip as there's no point in continuing logic.
            if (Player(player_id).state.sprinting == "false" and GetConfig().conditions.explode_on_sprint == true) then
                lib.print.debug("explode on sprint is enabled, player is not sprinting.");
                goto continue;
            end

            -- Check if player has GLOBAL "dont_explode" permission (meaning they can't trigger Claymores). If so, skip.
            if can_action(player_id, nil, "dont_explode", false) == true then
                lib.print.debug("Player has GLOBAL 'dont_explode' permission, don't explode.");
                goto continue;
            end

            -- Check player ped exists to avoid crash.
            if playerPed and DoesEntityExist(playerPed) then
                -- Get player coordinates.
                local playerCoords = GetEntityCoords(playerPed);
                
                -- Iterate through every Claymore and check if any of them are within range of the player.
                for i, claymore in ipairs(claymore_cams) do
                    -- Skip if Claymore already exploded.
                    if already_exploded[claymore.id] then
                        lib.print.debug(claymore.id..": claymore already exploded.");
                        goto next_claymore;
                    end
                    if Entity(NetworkGetEntityFromNetworkId(claymore.entity)).state.enabled == false then
                        lib.print.debug(claymore.id..": claymore is disabled, skipping.");
                        goto next_claymore;
                    end

                    -- Check if player has CLAYMORE "dont_explode" permission (meaning they can't trigger Claymores). If so, skip.
                    if can_action(player_id, claymore.id, "dont_explode", false) == true then
                        lib.print.debug(claymore.id..": Player has CLAYMORE 'dont_explode' permission, don't explode.");
                        goto next_claymore;
                    else
                        lib.print.debug(claymore.id..": Player does not have 'dont_explode' permission, continue.");
                    end

                    -- If Claymore is null or values are missing in database results, skip to next Claymore.
                    if not claymore or not (claymore.entity ~= nil and claymore.x ~= nil and claymore.y ~= nil and claymore.z ~= nil) then
                        lib.print.debug(claymore.id..": missing claymore values");
                        goto next_claymore;
                    end

                    -- Load Claymore coordinates into vector3 for distance calculation.
                    local targetCoords = vector3(claymore.x, claymore.y, claymore.z);
                    -- Calculate player's distance to Claymore.
                    local distance = #(playerCoords - targetCoords);

                    -- Check if player is within the trigger distance.
                    if distance <= GetConfig().conditions.trigger_distance then
                        -- Nice, Player is within range of Claymore. Time to explode!

                        -- Mark Claymore as exploded to prevent multiple explosions.
                        already_exploded[claymore.id] = true;

                        -- Tell all clients to create explosion inside world.
                        claymore_explode(claymore.id);

                        -- Remove Claymore from database.
                        -- FUTURE: Claymore's should be queued into a deletion list and removed in batches to reduce DB queries.
                        claymore_remove(claymore.id, true);
                    end

                    ::next_claymore::
                end

                ::next_player::
            end

            ::continue::
        end
    end

    ::continue_outer::
end)

RegisterNetEvent('hades_claymore:sprinting_state')
AddEventHandler('hades_claymore:sprinting_state', function(sprinting)
    local src = source
    print('called my event', src)
    print("Is sprinting:", sprinting)
    Player(src).state:set('sprinting', tostring(sprinting), true)
end)

AddEventHandler('txsv:logger:menuEvent', function(source, action, allowed, data)
    if not allowed then return end
    local message

    print("SOURCE "..source);

    --SELF menu options
    if action == 'playerModeChanged' then
        if data == 'noclip' then
            message = source.." enabled noclip"
            Player(source).state:set('noclipping', 'true', false)
        elseif data == 'none' then
            Player(source).state:set('noclipping', 'false', false)
        end
    end

    print(message);
end)