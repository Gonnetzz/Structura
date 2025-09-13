-- scripts/script.lua

dofile("scripts/forts.lua")
dofile(path .. "/scripts/StructureUtils.lua")
dofile(path .. "/scripts/readStructure.lua")
dofile(path .. "/scripts/createStructure.lua")
dofile(path .. "/scripts/ConvertStruct.lua")
dofile(path .. "/scripts/bank.lua")

MaterialCostsAndReclaim = {}
ResourceDebt = {}

DEBUG = true
DEBUG_LEVEL = 0

function loggy(msg, level)
    level = level or 0
    if DEBUG and level <= DEBUG_LEVEL then
        Log(msg)
    end
end

function LogForPlayer(teamId, msg)
    if GetLocalTeamId() == teamId then
        Log(msg)
    end
end

function LogForSpec(teamId, msg)
    local localTeam = GetLocalTeamId()
    if localTeam == TEAM_OBS or (localTeam > 0 and teamId > 0 and localTeam % MAX_SIDES == teamId % MAX_SIDES) then
        Log(msg)
    end
end

CONVERSION_TIMEOUT = 30
HIGHLIGHT_TIMEOUT = 5

function Load(gameStart)
    loggy("--- Loading Material Data for Archigebra Mod ---", 0)
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
            MetalCost = metalCost, EnergyCost = energyCost,
            MetalReclaim = metalReclaimFactor, EnergyReclaim = energyReclaimFactor
        }
        loggy(string.format("Material: %-15s | MC:%.2f EC:%.2f | MR:%.2f ER:%.2f",
            materialName, metalCost, energyCost, metalReclaimFactor, energyReclaimFactor), 0)
    end
    loggy("--- Material Data Loaded ---", 0)
end

function DisableHighlight(nodeA, nodeB)
    if NodeExists(nodeA) and NodeExists(nodeB) then
        HighlightLink(nodeA, nodeB, false)
    end
end

function OnDeviceCreated(teamId, deviceId, saveName, nodeA, nodeB, t, upgradedId)
    for id, process in pairs(ConversionProcesses) do
        if saveName == "control_panel" and upgradedId == process.controlPanelUpgradeId then
            loggy("Conversion "..id..": Detected creation of new control_panel with ID: "..deviceId, 1)
            process.controlPanelId = deviceId
        end
    end
end

function OnDeviceCompleted(teamId, deviceId, saveName)
    if saveName == "control_panel_upgrade" then
        local success, structureData, failureData = CheckStructureWithTeam(teamId, deviceId, "House", StructureDefinitions.House)
        if success then
            loggy("Test True: 'House' structure found.", 1)
            ConvertStructureStart(teamId, deviceId, "House", structureData)
        else
            loggy("Test False: Structure does not match 'House'.", 1)
            if failureData then
                local errMsg = "Error: " .. (failureData.primary.reason or "Unknown issue")
                if failureData.secondary and failureData.secondary.reason and failureData.primary.reason ~= failureData.secondary.reason then
                    errMsg = errMsg .. " or " .. failureData.secondary.reason
                end
                LogForPlayer(teamId, errMsg)
                if GetLocalTeamId() % MAX_SIDES == teamId % MAX_SIDES then
                    if failureData.primary and failureData.primary.correctLinkKeys and failureData.primary.linkMap then
                        loggy("Highlighting correctly placed struts for " .. HIGHLIGHT_TIMEOUT .. " seconds...", 1)
                        for linkKey, _ in pairs(failureData.primary.correctLinkKeys) do
                            local link = failureData.primary.linkMap[linkKey]
                            if link then
                                HighlightLink(link.nodeA, link.nodeB, true)
                                ScheduleCall(HIGHLIGHT_TIMEOUT, DisableHighlight, link.nodeA, link.nodeB)
                            end
                        end
                    end
                end
            end
        end
        UpgradeDevice(deviceId, "control_panel")
    elseif saveName == "test_device_log_structure" then
        GenerateStructureDefinitionString(deviceId)
        UpgradeDevice(deviceId, "test_device")
    
    elseif string.sub(saveName, 1, 7) == "create_" then
        local structureName = string.gsub(string.sub(saveName, 8), "_", " ")
        for name, def in pairs(StructureDefinitions) do
            if string.lower(name) == string.lower(structureName) then
                loggy("Creating structure: " .. name, 1)
                CreateStructureFromDefinition(deviceId, def, teamId)
                break
            end
        end
        UpgradeDevice(deviceId, "test_device")
    end
end

function OnDeviceDeleted(teamId, deviceId, saveName, nodeA, nodeB, t)
    local isConversionDevice = false
    for id, process in pairs(ConversionProcesses) do
        if process.triggerDeviceIds then
            for i, triggerId in ipairs(process.triggerDeviceIds) do
                if triggerId == deviceId then
                    isConversionDevice = true
                    loggy("Conversion " .. id .. ": Trigger device " .. deviceId .. " confirmed salvaged.", 2)
                    table.remove(process.triggerDeviceIds, i)
                    if #process.triggerDeviceIds == 0 and not process.demolitionInitiated then
                        loggy("Conversion " .. id .. ": All trigger devices salvaged. Scheduling link demolition in 1 second.", 2)
                        process.demolitionInitiated = true
                        ScheduleCall(1, InitiateLinkDemolition, id)
                    end
                    break
                end
            end
        end
        if isConversionDevice then break end
    end

    if isConversionDevice then
        local salvageRefundFactor = GetRule(teamId, "SalvageRefundFactor")
        if salvageRefundFactor == nil or salvageRefundFactor == 0 then salvageRefundFactor = 0.5 end
        local costs = GetDeviceCost(saveName)
        if costs then
            local metalToSubtract = costs.metal * salvageRefundFactor
            local energyToSubtract = costs.energy * salvageRefundFactor
            loggy(string.format("Device '%s' (part of conversion) salvaged. Reclaim value to subtract: M=%.2f, E=%.2f", saveName, metalToSubtract, energyToSubtract), 1)
            if metalToSubtract > 0 or energyToSubtract > 0 then
                local currentRes = GetTeamResources(teamId)
                if currentRes.metal >= metalToSubtract and currentRes.energy >= energyToSubtract then
                    AddResources(teamId, Value(-metalToSubtract, -energyToSubtract), false, Vec3())
                    loggy("  - Subtracting device reclaim resources directly.", 2)
                else
                    loggy("  - Insufficient resources for device reclaim. Using debt system.", 1)
                    ManageResourceDebt(teamId, metalToSubtract, energyToSubtract)
                end
            end
        end
    end
end

function OnLinkDestroyed(teamId, saveName, nodeA, nodeB, breakType)
    local linkKey = GetLinkKey(nodeA, nodeB)
    for id, process in pairs(ConversionProcesses) do
        if process.pendingLinks and process.pendingLinks[linkKey] then
            loggy("Conversion " .. id .. ": Link " .. linkKey .. " ("..saveName..") confirmed destroyed.", 2)
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
                            loggy(string.format("  - Subtracting link resources directly: Metal=%.2f, Energy=%.2f", metalToSubtract, energyToSubtract), 2)
                        else
                            loggy("  - Insufficient resources for link reclaim. Using debt system.", 1)
                            ManageResourceDebt(teamId, metalToSubtract, energyToSubtract)
                        end
                    end
                end
            end
            local layerComplete = true
            for k, v in pairs(process.pendingLinks) do
                if v then layerComplete = false; break; end
            end
            if layerComplete then
                loggy("Conversion " .. id .. ": Layer " .. process.currentLayer .. " demolition complete.", 2)
                ProcessNextDemolitionLayer(id)
            end
            return
        end
    end
end