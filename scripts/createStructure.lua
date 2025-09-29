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
            loggy("Delayed creation of device '" .. saveName .. "' failed. Error code: " .. result, 0)
        end
    else
        LogForPlayer(teamId,"Delayed creation of device '" .. saveName .. "' cancelled: one of the nodes was destroyed.")
    end
end

function CreateStructureFromDefinition(deviceId, structureDefinition, teamId)
    local sideId = teamId % MAX_SIDES
    local def
    if sideId == 1 or not structureDefinition.mirrorable then
        def = structureDefinition
    else
        def = MirrorStructureDefinition(structureDefinition)
    end


    local nodeA = GetDevicePlatformA(deviceId)
    local nodeB = GetDevicePlatformB(deviceId)
    local nodeMap = { A = nodeA, B = nodeB }
    
    local linksToProcess = {}
    for _, linkDef in ipairs(def.links) do
        table.insert(linksToProcess, linkDef)
    end

    local progressMadeInLoop = true
	local logremerror = true
    while #linksToProcess > 0 and progressMadeInLoop do
        progressMadeInLoop = false
        local remainingLinks = {}

        for _, linkDef in ipairs(linksToProcess) do
            local fromNodeId = nodeMap[linkDef.from]
            
            if fromNodeId then
                progressMadeInLoop = true
                
                local toNodeName = linkDef.to
                local toNodeId = nodeMap[toNodeName]

                if toNodeId then
                    CreateLink(teamId, linkDef.material, fromNodeId, toNodeId)
                else
                    local fromPos = NodePosition(fromNodeId)
                    local angleRad = math.rad(linkDef.angle)
                    local dir = { x = math.cos(angleRad), y = math.sin(angleRad) }
                    local toPos = { x = fromPos.x + dir.x * linkDef.length, y = fromPos.y + dir.y * linkDef.length }

                    local newNodeId = CreateNode(teamId, linkDef.material, fromNodeId, toPos)
                    
                    if newNodeId > 0 then
                        nodeMap[toNodeName] = newNodeId
                        CreateLink(teamId, linkDef.material, fromNodeId, newNodeId)

                        local bestCandidateId = -1
                        local minDistance = 300.0
                        
                        local mainLinkVector = SubtractVectors(NodePosition(newNodeId), NodePosition(fromNodeId))

                        for nodeName, existingNodeId in pairs(nodeMap) do
                            if existingNodeId ~= newNodeId and existingNodeId ~= fromNodeId then
                                if not IsNodeLinkedTo(newNodeId, existingNodeId) then
                                    local distance = Magnitude(SubtractVectors(NodePosition(newNodeId), NodePosition(existingNodeId)))
                                    
                                    if distance < minDistance then
                                        local candidateVector = SubtractVectors(NodePosition(existingNodeId), NodePosition(newNodeId))
                                        local angleDiff = math.abs(SignedAngleBetweenVectors(mainLinkVector, candidateVector))
                                        
                                        if angleDiff > 20 and angleDiff < 160 then
                                            minDistance = distance
                                            bestCandidateId = existingNodeId
                                        end
                                    end
                                end
                            end
                        end

                        if bestCandidateId ~= -1 then
                            CreateLink(teamId, "backbracing", newNodeId, bestCandidateId)
                        end

                    elseif newNodeId == -4 then
						LogForPlayer(teamId,"Insufficient Funds for Structure creation")
						logremerror = false
					else
                        loggy("Failed to create node '"..tostring(toNodeName).."' from '"..tostring(linkDef.from).."'. Error code: " .. newNodeId, 0)
                        progressMadeInLoop = false 
                        break
                    end
                end
            else
                table.insert(remainingLinks, linkDef)
            end
        end
        
        linksToProcess = remainingLinks
        
        if not progressMadeInLoop and #linksToProcess > 0 then
			if logremerror then
				loggy("Error: Could not process remaining links. First unprocessed link starts from: " .. tostring(linksToProcess[1].from), 0)
			end
            break
        end
    end

    if def.requiredDevices then
        for _, dev in ipairs(def.requiredDevices) do
            local fromId = nodeMap[dev.onLink.from]
            local toId = nodeMap[dev.onLink.to]
            if fromId and toId then
                ScheduleCall(6, DelayedCreateDevice, teamId, dev.saveName, fromId, toId, dev.t or 0.5)
            else
                loggy("Error: Device nodes not found for "..tostring(dev.saveName), 0)
            end
        end
    end
end
