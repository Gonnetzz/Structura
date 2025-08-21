dofile("scripts/forts.lua")
dofile(path .. "/scripts/StructureUtils.lua")
dofile(path .. "/scripts/readStructure.lua")
dofile(path .. "/scripts/createStructure.lua")

function OnDeviceCompleted(teamId, deviceId, saveName)
    --Log("OnDeviceCompleted: teamId="..teamId.." deviceId="..deviceId.." saveName="..saveName)

    if saveName == "control_panel_upgrade" then
        local success = CheckStructureWithTeam(teamId, deviceId, StructureDefinitions.House)
        if success then
            Log("Test True: 'House' structure found.")
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
