-- scripts/script.lua

dofile("scripts/forts.lua")
dofile(path .. "/scripts/StructureUtils.lua")
dofile(path .. "/scripts/readStructure.lua")
dofile(path .. "/scripts/createStructure.lua")
dofile(path .. "/scripts/ConvertStruct.lua")

function OnDeviceCreated(teamId, deviceId, saveName, nodeA, nodeB, t, upgradedId)
    for id, process in pairs(ConversionProcesses) do
        if saveName == "control_panel" and upgradedId == process.controlPanelUpgradeId then
            Log("Conversion "..id..": Detected creation of new control_panel with ID: "..deviceId)
            process.controlPanelId = deviceId --changes iguess
        end
    end
end

function OnDeviceCompleted(teamId, deviceId, saveName)
    if saveName == "control_panel_upgrade" then
        local success, structureData = CheckStructureWithTeam(teamId, deviceId, StructureDefinitions.House)
        if success then
            Log("Test True: 'House' structure found.")
            ConvertStructureStart(teamId, deviceId, structureData)
        else
            Log("Test False: Structure does not match 'House'.")
        end
        UpgradeDevice(deviceId, "control_panel")
    elseif saveName == "test_device_log_structure" then
        GenerateStructureDefinitionString(deviceId)
        UpgradeDevice(deviceId, "test_device")
    elseif saveName == "test_device_create_structure" then
        CreateStructureFromDefinition(deviceId, StructureDefinitions.House, teamId)
        UpgradeDevice(deviceId, "test_device")
    end
end

function OnDeviceDestroyed(teamId, deviceId, saveName, nodeA, nodeB, t)
    for id, process in pairs(ConversionProcesses) do
        if process.triggerDeviceIds then
            for i, triggerId in ipairs(process.triggerDeviceIds) do
                if triggerId == deviceId then
                    Log("Conversion " .. id .. ": Trigger device " .. deviceId .. " confirmed destroyed.")
                    table.remove(process.triggerDeviceIds, i)
                    
                    if #process.triggerDeviceIds == 0 and not process.demolitionInitiated then
                        Log("Conversion " .. id .. ": All trigger devices destroyed. Scheduling link demolition in 1 second.")
                        process.demolitionInitiated = true
                        ScheduleCall(1, InitiateLinkDemolition, id)
                    end
                    return
                end
            end
        end
    end
end

function OnLinkDestroyed(teamId, saveName, nodeA, nodeB, breakType)
    local linkKey = GetLinkKey(nodeA, nodeB)
    
    for id, process in pairs(ConversionProcesses) do
        if process.pendingLinks and process.pendingLinks[linkKey] then
            Log("Conversion " .. id .. ": Link " .. linkKey .. " confirmed destroyed.")
            process.pendingLinks[linkKey] = nil

            local layerComplete = true
            for k, v in pairs(process.pendingLinks) do
                if v then
                    layerComplete = false
                    break
                end
            end

            if layerComplete then
                Log("Conversion " .. id .. ": Layer " .. process.currentLayer .. " demolition complete.")
                ProcessNextDemolitionLayer(id)
            end
            return
        end
    end
end