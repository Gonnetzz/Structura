-- scripts/script.lua

dofile("scripts/forts.lua")
dofile(path .. "/scripts/StructureUtils.lua")
dofile(path .. "/scripts/readStructure.lua")
dofile(path .. "/scripts/createStructure.lua")
dofile(path .. "/scripts/ConvertStruct.lua")

MaterialCostsAndReclaim = {}
ResourceDebt = {}

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

function ProcessDebtPayment(teamId)
    if not ResourceDebt[teamId] then return end

    local debt = ResourceDebt[teamId]
    local currentRes = GetTeamResources(teamId)

    local metalToPay = math.min(currentRes.metal, debt.Metal)
    local energyToPay = math.min(currentRes.energy, debt.Energy)

    if metalToPay > 0 or energyToPay > 0 then
        AddResources(teamId, Value(-metalToPay, -energyToPay), false, Vec3())
        Log(string.format("  - Debt Payment (Team %d): Paid M=%.2f, E=%.2f", teamId, metalToPay, energyToPay))
    end

    debt.Metal = debt.Metal - metalToPay
    debt.Energy = debt.Energy - energyToPay

    if debt.Metal < 0.01 and debt.Energy < 0.01 then
        Log("  - Debt fully paid for Team " .. teamId)
        ResourceDebt[teamId] = nil
    else
        Log(string.format("  - Remaining debt for Team %d: M=%.2f, E=%.2f. Scheduling next payment.", teamId, debt.Metal, debt.Energy))
        ScheduleCall(0.1, ProcessDebtPayment, teamId)
    end
end

function ManageResourceDebt(teamId, metalDebt, energyDebt)
    if metalDebt <= 0 and energyDebt <= 0 then return end

    if ResourceDebt[teamId] then
        ResourceDebt[teamId].Metal = ResourceDebt[teamId].Metal + metalDebt
        ResourceDebt[teamId].Energy = ResourceDebt[teamId].Energy + energyDebt
        Log(string.format("  - Added to existing debt for Team %d: M=%.2f, E=%.2f. Total debt: M=%.2f, E=%.2f",
            teamId, metalDebt, energyDebt, ResourceDebt[teamId].Metal, ResourceDebt[teamId].Energy))
    else
        ResourceDebt[teamId] = { Metal = metalDebt, Energy = energyDebt }
        Log(string.format("  - New debt created for Team %d: M=%.2f, E=%.2f. Starting payment process.", teamId, metalDebt, energyDebt))
        ScheduleCall(0.1, ProcessDebtPayment, teamId)
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

                    Log(string.format("  - Calculation for %s: Length(%.2f) * MR(%.3f) = Metal(%.2f)", saveName, linkLength, data.MetalReclaim, metalToSubtract))
                    Log(string.format("  - Calculation for %s: Length(%.2f) * ER(%.3f) = Energy(%.2f)", saveName, linkLength, data.EnergyReclaim, energyToSubtract))

                    if metalToSubtract > 0 or energyToSubtract > 0 then
                        local currentRes = GetTeamResources(teamId)
                        if currentRes.metal >= metalToSubtract and currentRes.energy >= energyToSubtract then
                            -- pay gonessa rn
                            AddResources(teamId, Value(-metalToSubtract, -energyToSubtract), false, Vec3())
                            Log(string.format("  - Subtracting resources directly: Metal=%.2f, Energy=%.2f", metalToSubtract, energyToSubtract))
                        else
                            -- schedule appointment
                            Log("  - Insufficient resources for direct payment. Using debt system.")
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