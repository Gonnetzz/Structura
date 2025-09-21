dofile(path .. "/scripts/Math.lua")
dofile(path .. "/scripts/readStructure.lua")

function GenerateStructureDefinitionString(deviceId)
    local visitedNodes = {}
    local visitedLinks = {}
    local nodeNameCounter = 0
    local nodeNameMap = {}
    local linksToLog = {}
    local devicesToLog = {}

    local nodeA = GetDevicePlatformA(deviceId)
    local nodeB = GetDevicePlatformB(deviceId)

    nodeNameMap[nodeA] = "A"
    nodeNameMap[nodeB] = "B"
    
    local queue = {{id = nodeA, name = "A"}, {id = nodeB, name = "B"}}
    visitedNodes[nodeA] = true
    visitedNodes[nodeB] = true

    while #queue > 0 do
        local current = table.remove(queue, 1)
        
        for i = 0, NodeLinkCount(current.id) - 1 do
            local nextNodeId = NodeLinkedNodeId(current.id, i)
            local linkKey = current.id < nextNodeId and (current.id .. "-" .. nextNodeId) or (nextNodeId .. "-" .. current.id)

            if not visitedLinks[linkKey] then
                visitedLinks[linkKey] = true
                
                local nextNodeName = nodeNameMap[nextNodeId]
                if not nextNodeName then
                    nodeNameCounter = nodeNameCounter + 1
                    nextNodeName = nodeNameCounter
                    nodeNameMap[nextNodeId] = nextNodeName
                end

                local material = GetLinkMaterialSaveName(current.id, nextNodeId)
                if material ~= "test_material" then
                    local vec = SubtractVectors(NodePosition(nextNodeId), NodePosition(current.id))
                    local len = Magnitude(vec)
                    local ang = SignedAngleBetweenVectors({x=1,y=0}, vec)
                    
                    local fromName = (current.name == "A" or current.name == "B") and '"'..current.name..'"' or current.name
                    local toName = (nextNodeName == "A" or nextNodeName == "B") and '"'..nextNodeName..'"' or nextNodeName
                    
                    table.insert(linksToLog, string.format("            { from = %s, to = %s, material = \"%s\", length = %.2f, angle = %.2f },", fromName, toName, material, len, ang))
                    
                    local devId = GetDeviceIdOnPlatform(current.id, nextNodeId)
                    if devId and devId ~= -1 then
                        local devSave = GetDeviceType(devId)
                        local t = GetDeviceLinkPosition(devId)
                        table.insert(devicesToLog, string.format("        { onLink = {from=%s, to=%s}, saveName=\"%s\", t = %.2f },", fromName, toName, devSave, t))
                    end

                    if not visitedNodes[nextNodeId] then
                        visitedNodes[nextNodeId] = true
                        table.insert(queue, {id = nextNodeId, name = nextNodeName})
                    end
                end
            end
        end
    end

    Log("--- Generated Structure Definition ---")
    Log("StructureDefinitions.NewStructure = {")
    Log("    mirrorable = false,")
    if #devicesToLog > 0 then
        Log("    requiredDevices = {")
        for _, line in ipairs(devicesToLog) do Log(line) end
        Log("    },")
    end
    Log("    links = {")
    for _, line in ipairs(linksToLog) do Log(line) end
    Log("    }")
    Log("}")
    Log("------------------------------------")
end

function DelayedCreateDevice(teamId, saveName, fromId, toId, tValue)
    if NodeExists(fromId) and NodeExists(toId) then
        local result = CreateDevice(teamId, saveName, fromId, toId, tValue)
        if result < 0 then
            Log("Delayed creation of device '" .. saveName .. "' failed. Error code: " .. result)
        end
    else
        Log("Delayed creation of device '" .. saveName .. "' cancelled: one of the nodes was destroyed.")
    end
end

function CreateStructureFromDefinition(deviceId, structureDefinition, teamId)
    Log("CreateStructureFromDefinition: deviceId="..deviceId.." teamId="..teamId)

    local def
    if teamId == 1 then
        def = structureDefinition
        Log("Team "..teamId.." -> create normal structure")
    else
        def = MirrorStructureDefinition(structureDefinition)
        Log("Team "..teamId.." -> create mirrored structure")
    end

    local nodeA = GetDevicePlatformA(deviceId)
    local nodeB = GetDevicePlatformB(deviceId)
    local nodeMap = { A = nodeA, B = nodeB }

    for _, linkDef in ipairs(def.links) do
        local fromNodeId = nodeMap[linkDef.from]
        local toNodeName = linkDef.to
        if fromNodeId then
            local fromPos = NodePosition(fromNodeId)
            local angleRad = math.rad(linkDef.angle)

            local dirX, dirY = 1, 0
            local rotatedX = dirX * math.cos(angleRad) - dirY * math.sin(angleRad)
            local rotatedY = dirX * math.sin(angleRad) + dirY * math.cos(angleRad)

            local mag = Magnitude({x=rotatedX, y=rotatedY})
            if mag == 0 then mag = 1 end
            local unitX = rotatedX / mag
            local unitY = rotatedY / mag

            local toPos = { x = fromPos.x + unitX * linkDef.length, y = fromPos.y + unitY * linkDef.length }
            local toNodeId = nodeMap[toNodeName]

            if toNodeId then
                CreateLink(teamId, linkDef.material, fromNodeId, toNodeId)
            else
                local newNodeId = CreateNode(teamId, linkDef.material, fromNodeId, toPos)
                if newNodeId > 0 then
                    nodeMap[toNodeName] = newNodeId
                    CreateLink(teamId, linkDef.material, fromNodeId, newNodeId)
                else
                    Log("Failed to create node. Error code: " .. newNodeId)
                    return
                end
            end
        else
            Log("Error: Node '"..tostring(linkDef.from).."' not found in nodeMap.")
        end
    end

    if def.requiredDevices then
        for _, dev in ipairs(def.requiredDevices) do
            local fromId = nodeMap[dev.onLink.from]
            local toId = nodeMap[dev.onLink.to]
            if fromId and toId then
				ScheduleCall(6, DelayedCreateDevice, teamId, dev.saveName, fromId, toId, dev.t or 0.5)
			--[[
                local result = CreateDevice(teamId, dev.saveName, fromId, toId, dev.t or 0.5)
                if not result then
                    Log("Failed to create device: "..dev.saveName)
                end
            else
                Log("Error: Device nodes not found for "..tostring(dev.saveName))
				--]]
            end
        end
    end
end
