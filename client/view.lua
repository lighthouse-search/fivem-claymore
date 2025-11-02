-- THIS VIEWING CODE IS TEMPORARY. As discussed with Synth, it will be replaced with the prison CCTV camera APIs :)
-- Note: Under this temporary code, if a camera is far away, it will be out of render distance.

-- Note: This hasn't been tested. I will setup another FiveM instance to test it on in the near future. I think we're using the prison CCTV for this anyways.
function view_person(targetPed, x, y, z)
    if not targetPed or not DoesEntityExist(targetPed) then return end
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    
    -- Offset: x = right/left, y = forward/back, z = up/down (neck position)
    local offset = vector3(0.0, 0.15, 1.2) -- neck: center, slightly forward, up
    AttachCamToEntity(cam, targetPed, offset.x, offset.y, offset.z, true)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)

    -- Keep camera rotation synced with target's heading
    local running = true
    Citizen.CreateThread(function()
        while running do
            SetCamRot(cam, 0.0, 0.0, GetEntityHeading(targetPed), 2)
            Wait(0)
        end
    end)

    -- Optional: Return to normal view after a delay
    Citizen.SetTimeout(5000, function()
        running = false
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
    end)
end

function view_ground(x, y, z)
    -- Camera logic (first person, looking forward)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local objHeading = GetEntityHeading(obj)
    SetCamCoord(cam, x, y, z + 0.7) -- Eye level
    SetCamRot(cam, 0.0, 0.0, objHeading, 2) -- Pitch, Roll, Yaw (heading)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)

    -- Optional: Add a way to return to normal view (e.g., after a delay or button press)
    Citizen.SetTimeout(5000, function()
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
    end)
end

exports('view_person', view_person)
exports('view_ground', view_ground)



-- NUI
RegisterNUICallback('camera/view', function(data, cb)
  -- Camera JSON object from MDT cache. This is client-side, so we won't validate this data with the server.
  local camera = data.camera;

  if (camera.type == "person") then
    view_person(camera.entity, camera.x, camera.y, camera.z);
  elseif (camera.type == "ground") then
    view_ground(camera.x, camera.y, camera.z);
  end

  cb({ ok = true })
end)


-- Net events. Called by server to put user into a view state upon request.
RegisterNetEvent('hades_claymore:view_person', function(entity, x, y, z)
    local src = source
    print('called my event', src);
    view_person(src, entity, x, y, z);
end)

RegisterNetEvent('hades_claymore:view_ground', function(x, y, z)
    local src = source
    print('called my event', src);
    view_ground(src, x, y, z);
end)