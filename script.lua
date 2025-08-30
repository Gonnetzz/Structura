-- scripts/script.lua

dofile("scripts/forts.lua")
dofile(path .. "/scripts/StructureUtils.lua")
dofile(path .. "/scripts/readStructure.lua")
dofile(path .. "/scripts/createStructure.lua")
dofile(path .. "/scripts/ConvertStruct.lua")
dofile(path .. "/scripts/bank.lua")

MaterialCostsAndReclaim = {}

function Load(gameStart)
    Log("--- Loading Material Data for Archigebra Mod ---")
    local teamId = GetLocalTeamId()
    if teamId < 1 then teamId = 1 end

    local SupportedMaterials = {
        "bracing", "backbracing", "armour", "door", "rope", "portal", "shield",
        "lead", "uran", "uran2", "test_material"
    }

    for _, materialName in ipairs(SupportedMaterials) do
        local metalCost = GetMaterialValue(materialName, teamId, COMMANDER_CURRENT, "MetalBuildCost", 0)
        local energyCost = GetMaterialValue(materialName, teamId, COMMANDER_CURRENT, "EnergyBuildCost", 0)
        local metalReclaimFactor = GetMaterialValue(materialName, teamId, COMMANDER_CURRENT, "MetalReclaim", 0)
        local energyReclaimFactor = GetMaterialValue(materialName, teamId, COMMANDER_CURRENT, "EnergyReclaim", 0)
        
        MaterialCostsAndReclaim[materialName] = {
            MetalCost = metalCost,
            EnergyCost = energyCost,
            MetalReclaim = metalReclaimFactor,
            EnergyReclaim = energyReclaimFactor
        }
        Log(string.format("Material: %-15s | MC:%.2f EC:%.2f | MR:%.2f ER:%.2f",
            materialName, metalCost, energyCost, metalReclaimFactor, energyReclaimFactor))
    end
    Log("--- Material Data Loaded ---")
end

function OnDeviceCreated(teamId, deviceId, saveName, nodeA, nodeB, t, upgradedId)
    for id, process in pairs(ConversionProcesses) do
        if saveName == "control_panel" and upgradedId == process.controlPanelUpgradeId then
            Log("Conversion "..id..": Detected creation of new control_panel with ID: "..deviceId)
            process.controlPanelId = deviceId
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

function OnDeviceDeleted(teamId, deviceId, saveName, nodeA, nodeB, t)
    local salvageRefundFactor = 0.5
    local costs = GetDeviceCost(saveName)
    
    if costs then
        local metalToSubtract = costs.metal * salvageRefundFactor
        local energyToSubtract = costs.energy * salvageRefundFactor

        Log(string.format("Device '%s' salvaged. Build Cost (M=%.2f, E=%.2f).", saveName, costs.metal, costs.energy))
        Log(string.format("  - Calculated reclaim value to subtract: Metal=%.2f, Energy=%.2f", metalToSubtract, energyToSubtract))

        if metalToSubtract > 0 or energyToSubtract > 0 then
            local currentRes = GetTeamResources(teamId)
            if currentRes.metal >= metalToSubtract and currentRes.energy >= energyToSubtract then
                AddResources(teamId, Value(-metalToSubtract, -energyToSubtract), false, Vec3())
                Log("  - Subtracting device reclaim resources directly.")
            else
                Log("  - Insufficient resources for device reclaim. Using debt system.")
                ManageResourceDebt(teamId, metalToSubtract, energyToSubtract)
            end
        end
    else
        Log("Warning: Could not get costs for device '"..saveName.."'")
    end

    for id, process in pairs(ConversionProcesses) do
        if process.triggerDeviceIds then
            for i, triggerId in ipairs(process.triggerDeviceIds) do
                if triggerId == deviceId then
                    Log("Conversion " .. id .. ": Trigger device " .. deviceId .. " confirmed salvaged.")
                    table.remove(process.triggerDeviceIds, i)
                    
                    if #process.triggerDeviceIds == 0 and not process.demolitionInitiated then
                        Log("Conversion " .. id .. ": All trigger devices salvaged. Scheduling link demolition in 1 second.")
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
            Log("Conversion " .. id .. ": Link " .. linkKey .. " ("..saveName..") confirmed destroyed.")
            process.pendingLinks[linkKey] = nil

            if breakType == LINKBREAK_DELETE and MaterialCostsAndReclaim[saveName] then
                local linkData = process.linkMap[linkKey]
                if linkData and linkData.length then
                    local linkLength = linkData.length
                    local data = MaterialCostsAndReclaim[saveName]
                    
                    local metalToSubtract = linkLength * data.MetalReclaim
                    local energyToSubtract = linkLength * data.EnergyReclaim

                    if metalToSubtract > 0 or energyToSubtract > 0 then
                        local currentRes = GetTeamResources(teamId)
                        if currentRes.metal >= metalToSubtract and currentRes.energy >= energyToSubtract then
                            AddResources(teamId, Value(-metalToSubtract, -energyToSubtract), false, Vec3())
                            Log(string.format("  - Subtracting link resources directly: Metal=%.2f, Energy=%.2f", metalToSubtract, energyToSubtract))
                        else
                            Log("  - Insufficient resources for link reclaim. Using debt system.")
                            ManageResourceDebt(teamId, metalToSubtract, energyToSubtract)
                        end
                    end
                end
            end

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