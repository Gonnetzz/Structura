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
	
	local baseVector = SubtractVectors(NodePosition(nodeB), NodePosition(nodeA))
    local baseAngle = SignedAngleBetweenVectors({x=1, y=0}, baseVector)
    Log("--- Generating Structure Definition (relative to base angle: " .. string.format("%.2f", baseAngle) .. ") ---")
    
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
					
					local absoluteAngle = SignedAngleBetweenVectors({x=1, y=0}, vec)
                    local relativeAngle = absoluteAngle - baseAngle
					
					if relativeAngle > 180 then relativeAngle = relativeAngle - 360 end
                    if relativeAngle < -180 then relativeAngle = relativeAngle + 360 end
					
                    --local ang = SignedAngleBetweenVectors({x=1,y=0}, vec)
                    
                    local fromName = (current.name == "A" or current.name == "B") and '"'..current.name..'"' or current.name
                    local toName = (nextNodeName == "A" or nextNodeName == "B") and '"'..nextNodeName..'"' or nextNodeName
                    
                    table.insert(linksToLog, string.format("            { from = %s, to = %s, material = \"%s\", length = %.2f, angle = %.2f },", fromName, toName, material, len, relativeAngle))
                    
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

function CheckFailedBuild(teamId, expectedLinks)
    local buildFailed = false
    for _, expectedLink in ipairs(expectedLinks) do
        local actualMaterial = GetLinkMaterialSaveName(expectedLink.nodeA, expectedLink.nodeB)
        
        if actualMaterial == "" or actualMaterial ~= expectedLink.material then
            buildFailed = true
            loggy("Build check failed: Link " .. expectedLink.nodeA .. "-" .. expectedLink.nodeB .. " expected " .. expectedLink.material .. ", but found " .. tostring(actualMaterial), 1)
            break 
        end
    end

    if buildFailed then
        local errorMessage = "Error: Failed to fully create the structure. Try moving the core device towards the middle of the base strut, or flip it to the other side, to ensure it can be built correctly."
        LogForPlayer(teamId, errorMessage)
    end
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

function CreateStructureFromDefinition(deviceId, structureDefinition, teamId, existingNodeMap, linksToBuild)
    local sideId = teamId % MAX_SIDES
    local def
    if sideId == 1 or not structureDefinition.mirrorable then
        def = structureDefinition
    else
        def = MirrorStructureDefinition(structureDefinition)
    end

    local nodeA = GetDevicePlatformA(deviceId)
    local nodeB = GetDevicePlatformB(deviceId)
	local unsupportedNodes = {}
	local currentBuildStep = 0
	
	local baseVector = SubtractVectors(NodePosition(nodeB), NodePosition(nodeA))
    local baseAngle = SignedAngleBetweenVectors({x=1, y=0}, baseVector)
    loggy("Base link A-B angle: " .. baseAngle, 2)
	
    local nodeMap = existingNodeMap or { A = nodeA, B = nodeB }
    
    local linksToProcess = linksToBuild or {}
    if #linksToProcess == 0 and not linksToBuild then
        for _, linkDef in ipairs(def.links) do
            table.insert(linksToProcess, linkDef)
        end
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
					if not IsNodeLinkedTo(fromNodeId, toNodeId) then
                        local linkresult = CreateLink(teamId, linkDef.material, fromNodeId, toNodeId)
						--loggy("CreateLink: material=" .. tostring(linkDef.material) .. ", result=" .. tostring(linkresult), 2)--always -14
                    end
                else
                    local fromPos = NodePosition(fromNodeId)
					local absoluteAngle = linkDef.angle + baseAngle
                    local angleRad = math.rad(absoluteAngle)
                    local dir = { x = math.cos(angleRad), y = math.sin(angleRad) }
                    local toPos = { x = fromPos.x + dir.x * linkDef.length, y = fromPos.y + dir.y * linkDef.length }

                    local newNodeId = CreateNode(teamId, linkDef.material, fromNodeId, toPos)
                    
                    if newNodeId > 0 then
                        nodeMap[toNodeName] = newNodeId
                        --CreateLink(teamId, linkDef.material, fromNodeId, newNodeId) --alr done through createnode

						-- check1
                        local bestImmediateCandidateId = -1
                        local bestImmediateScore = -1
                        local searchRadius = 350.0 -- i know its 200
                        
                        local mainLinkVector = SubtractVectors(NodePosition(newNodeId), NodePosition(fromNodeId))
                        local newNodePos = NodePosition(newNodeId)
						
                        for nodeName, existingNodeId in pairs(nodeMap) do
                            if existingNodeId ~= newNodeId and existingNodeId ~= fromNodeId then
                                if not IsNodeLinkedTo(newNodeId, existingNodeId) then
                                    local distance = Magnitude(SubtractVectors(newNodePos, NodePosition(existingNodeId)))
                                    if distance > 55 and distance < searchRadius then
                                        local candidateVector = SubtractVectors(NodePosition(existingNodeId), newNodePos)
                                        local angleDiff = math.abs(SignedAngleBetweenVectors(mainLinkVector, candidateVector))
                                        if angleDiff > 20 and angleDiff < 160 then
                                            local angleScore = math.sin(math.rad(angleDiff))
                                            local distancePenalty = 1 - (distance / searchRadius)
                                            local score = (angleScore * angleScore) * 0.7 + distancePenalty * 0.3
                                            if score > bestImmediateScore then
                                                bestImmediateScore = score
                                                bestImmediateCandidateId = existingNodeId
                                            end
                                        end
                                    end
                                end
                            end
                        end
						
						if bestImmediateCandidateId ~= -1 then
                            loggy("support for node " .. newNodeId .. " -> " .. bestImmediateCandidateId, 2)
							local result = CreateLink(teamId, "backbracing", newNodeId, bestImmediateCandidateId)
							if result == -4 then
								LogForPlayer(teamId,"Insufficient Funds for support structure")
							end
						else
                            --table.insert(unsupportedNodes, {nodeId = newNodeId, parentId = fromNodeId, addedAtStep = currentBuildStep})
						end
						--[[
                        for i = #unsupportedNodes, 1, -1 do
                            local waitingNode = unsupportedNodes[i]
                            
                            if waitingNode.addedAtStep < currentBuildStep then
                                local bestSupportForWaitingNodeId = -1
                                local bestSupportScore = -1
                                local waitingNodePos = NodePosition(waitingNode.nodeId)
                                local waitingMainLinkVector = SubtractVectors(waitingNodePos, NodePosition(waitingNode.parentId))

                                for nodeName, existingNodeId in pairs(nodeMap) do
                                    if existingNodeId ~= waitingNode.nodeId and existingNodeId ~= waitingNode.parentId then
                                        if not IsNodeLinkedTo(waitingNode.nodeId, existingNodeId) then
                                            local distance = Magnitude(SubtractVectors(waitingNodePos, NodePosition(existingNodeId)))
                                            if distance > 55 and distance < searchRadius then
                                                local candidateVector = SubtractVectors(NodePosition(existingNodeId), waitingNodePos)
                                                local angleDiff = math.abs(SignedAngleBetweenVectors(waitingMainLinkVector, candidateVector))
                                                if angleDiff > 20 and angleDiff < 160 then
                                                    local angleScore = math.sin(math.rad(angleDiff))
                                                    local distancePenalty = 1 - (distance / searchRadius)
                                                    local score = (angleScore * angleScore) * 0.7 + distancePenalty * 0.3
                                                    if score > bestSupportScore then
                                                        bestSupportScore = score
                                                        bestSupportForWaitingNodeId = existingNodeId
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                                if bestSupportForWaitingNodeId ~= -1 then
                                    loggy("support for waiting node " .. waitingNode.nodeId .. " -> " .. bestSupportForWaitingNodeId, 2)
                                    CreateLink(teamId, "backbracing", waitingNode.nodeId, bestSupportForWaitingNodeId)
                                    table.remove(unsupportedNodes, i) -- Aus der Warteliste entfernen
                                end
                            end
						end--]]
						
						-- Does not work, looks like snapping is inversed, but i dont want to iterate over all nodes of the player, 
						-- that seems to be bad, e.g. battleships ...
                        --[[local finalCandidateId = -1
                        if bestInternalCandidateId ~= -1 then
                            finalCandidateId = bestInternalCandidateId
                            loggy("Found best internal support node " .. finalCandidateId .. " with score " .. string.format("%.3f", bestInternalScore), 2)
                        else
                            local snappedNodeId = SnapToNode(newNodePos, teamId, searchRadius)
                            if snappedNodeId ~= -1 and snappedNodeId ~= newNodeId and snappedNodeId ~= fromNodeId then
                                if not IsNodeLinkedTo(newNodeId, snappedNodeId) then
                                    local distance = Magnitude(SubtractVectors(newNodePos, NodePosition(snappedNodeId)))
                                    if distance > 55 then
                                        local candidateVector = SubtractVectors(NodePosition(snappedNodeId), newNodePos)
                                        local angleDiff = math.abs(SignedAngleBetweenVectors(mainLinkVector, candidateVector))
                                        if angleDiff > 20 and angleDiff < 160 then
                                            finalCandidateId = snappedNodeId
                                            loggy("Internal search failed. Found external support node via SnapToNode: " .. finalCandidateId, 2)
                                        end
                                    end
                                end
							else
								loggy("Error: No Supporting Node found!", 0)--might happen on open 3++long baselinks
                            end
							
                        end
                        
                        if finalCandidateId ~= -1 then
							CreateLink(teamId, "backbracing", newNodeId, finalCandidateId)
						end--]]

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

    local linksToCheck = linksToBuild or def.links
    if #linksToCheck > 0 then
        local expectedLinks = {}
        for _, linkDef in ipairs(linksToCheck) do
            local nodeIdA = nodeMap[linkDef.from]
            local nodeIdB = nodeMap[linkDef.to]

            if nodeIdA and nodeIdB then
                table.insert(expectedLinks, {
                    nodeA = nodeIdA,
                    nodeB = nodeIdB,
                    material = linkDef.material
                })
            end
        end
        if #expectedLinks > 0 then
            ScheduleCall(0.1, CheckFailedBuild, teamId, expectedLinks)
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
