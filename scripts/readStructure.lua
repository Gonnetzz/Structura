-- scripts/readStructure.lua

dofile(path .. "/scripts/Math.lua")

local LENGTH_TOLERANCE = 15.0
local ANGLE_TOLERANCE = 15.0
local DEVICE_T_TOLERANCE = 0.2
-- todo increase for HS

function FormatFailureReason(reason, linkDef)
    if not reason or not linkDef then return "Unknown structure error" end
    if string.find(reason, "Device") then
        if string.find(reason, "not found") then
            return string.format("%s %s is missing on link %s-%s",
                linkDef.saveName, reason, tostring(linkDef.onLink.from), tostring(linkDef.onLink.to))
        else
            return string.format("%s on link %s-%s: %s",
                linkDef.saveName, tostring(linkDef.onLink.from), tostring(linkDef.onLink.to), reason)
        end
    else
        return string.format("%s Link from %s to %s is missing or incorrect",
            linkDef.material, tostring(linkDef.from), tostring(linkDef.to))
    end
end

function MirrorStructureDefinition(def)
    local mirrored = { mirrorable = def.mirrorable, links = {}, requiredDevices = {} }
    local nodeNameSwap = { A = "B", B = "A" }
    for _, link in ipairs(def.links) do
        local newFrom = nodeNameSwap[link.from] or link.from
        local newTo = nodeNameSwap[link.to] or link.to
        local newAngle = 180 - link.angle
        if newAngle > 180 then newAngle = newAngle - 360 end
        if newAngle < -180 then newAngle = newAngle + 360 end
        table.insert(mirrored.links, { from = newFrom, to = newTo, material = link.material, length = link.length, angle = newAngle })
    end
    if def.requiredDevices then
        for _, dev in ipairs(def.requiredDevices) do
            local newDevFrom = nodeNameSwap[dev.onLink.from] or dev.onLink.from
            local newDevTo = nodeNameSwap[dev.onLink.to] or dev.onLink.to
            table.insert(mirrored.requiredDevices, { saveName = dev.saveName, t = dev.t, onLink = { from = newDevFrom, to = newDevTo } })
        end
    end
    return mirrored
end

function CheckStructureWithTeam(teamId, deviceId, structureName, structureDefinition)
    loggy("CheckStructureWithTeam: TeamId="..teamId.." DeviceId="..deviceId, 1)
    local primaryDef, secondaryDef
	local sideId = teamId % MAX_SIDES
    if sideId == 1 then
        primaryDef = structureDefinition
        secondaryDef = MirrorStructureDefinition(structureDefinition)
    else
        primaryDef = MirrorStructureDefinition(structureDefinition)
        secondaryDef = structureDefinition
    end

    local success, data = CheckStructure(deviceId, primaryDef, false)
    if success then
        loggy("Structure matched (primary).", 1)
        data.structureName = structureName
        return true, data, nil, 1
    else
        loggy("Primary check failed, trying secondary...", 2)
        local success2, data2 = CheckStructure(deviceId, secondaryDef, false)
        if success2 then
            loggy("Structure matched (secondary).", 1)
            data2.structureName = structureName
            return true, data2, nil, 2
        else
            loggy("Secondary also failed.", 1)
            local failureData = {
                primary = { reason = FormatFailureReason(data.reason, data.failingLinkDef), correctLinkKeys = data.correctLinkKeys, linkMap = data.linkMap },
                secondary = { reason = FormatFailureReason(data2.reason, data2.failingLinkDef), correctLinkKeys = data2.correctLinkKeys, linkMap = data2.linkMap }
            }
            return false, nil, failureData, 0
        end
    end
end

function CheckStructure(deviceId, structureDefinition, partialMatchAllowed)
    local nodeA, nodeB = GetDevicePlatformA(deviceId), GetDevicePlatformB(deviceId)
    if not nodeA or nodeA == 0 or not nodeB or nodeB == 0 then return false, { reason = "Invalid base platform" } end
	
	local baseVector = SubtractVectors(NodePosition(nodeB), NodePosition(nodeA))
    local baseAngle = SignedAngleBetweenVectors({x=1, y=0}, baseVector)
    
    local nodeMap, checkedLinks, linkMap = { A = nodeA, B = nodeB }, {}, {}
    local linksToProcess = {}
    for _, link in ipairs(structureDefinition.links) do table.insert(linksToProcess, link) end
    
    local progressMade = true
    while #linksToProcess > 0 and progressMade do
        progressMade = false
        local remainingLinks = {}
        for _, linkDef in ipairs(linksToProcess) do
            if nodeMap[linkDef.from] then
                local fromNodeId = nodeMap[linkDef.from]
                local matchFound = false
				--[[
				--Debug Links
				local connectedLinks = {}
                for i = 0, NodeLinkCount(fromNodeId) - 1 do
                    local nextNodeId = NodeLinkedNodeId(fromNodeId, i)
                    local vec = SubtractVectors(NodePosition(nextNodeId), NodePosition(fromNodeId))
                    local absoluteAngle = SignedAngleBetweenVectors({x=1, y=0}, vec)
                    local relativeAngle = absoluteAngle - baseAngle
                    if relativeAngle > 180 then relativeAngle = relativeAngle - 360 end
                    if relativeAngle < -180 then relativeAngle = relativeAngle + 360 end
                    
                    table.insert(connectedLinks, {
                        nodeA = fromNodeId,
                        nodeB = nextNodeId,
                        material = GetLinkMaterialSaveName(fromNodeId, nextNodeId),
                        length = Magnitude(vec),
                        relAngle = relativeAngle
                    })
                end
				--]]
                for i = 0, NodeLinkCount(fromNodeId) - 1 do
                    local nextNodeId = NodeLinkedNodeId(fromNodeId, i)
                    local linkKey = fromNodeId < nextNodeId and (fromNodeId .. "-" .. nextNodeId) or (nextNodeId .. "-" .. fromNodeId)
                    if not checkedLinks[linkKey] then
                        if GetLinkMaterialSaveName(fromNodeId, nextNodeId) == linkDef.material then
                            local vec = SubtractVectors(NodePosition(nextNodeId), NodePosition(fromNodeId))
							
							local absoluteAngle = SignedAngleBetweenVectors({x=1, y=0}, vec)
                            local relativeAngle = absoluteAngle - baseAngle
							
							if relativeAngle > 180 then relativeAngle = relativeAngle - 360 end
                            if relativeAngle < -180 then relativeAngle = relativeAngle + 360 end
							
                            local angleDiff = math.abs(relativeAngle - linkDef.angle)
                            local angularDistance = math.min(angleDiff, 360 - angleDiff)

                            if math.abs(Magnitude(vec) - linkDef.length) < LENGTH_TOLERANCE and
                               angularDistance < ANGLE_TOLERANCE then
                                
                                if not nodeMap[linkDef.to] or nodeMap[linkDef.to] == nextNodeId then
                                    nodeMap[linkDef.to] = nextNodeId
                                    checkedLinks[linkKey], linkMap[linkKey] = true, {nodeA = fromNodeId, nodeB = nextNodeId}
                                    matchFound, progressMade = true, true
                                    break
                                end
                            end
                        end
                    end
                end
                if not matchFound then 
					--[[
					--Debug Links
					Log(string.format("---- Failed to match def: {from=%s, to=%s, mat=%s, len=%.2f, ang=%.2f} ----",
                        tostring(linkDef.from), tostring(linkDef.to), linkDef.material, linkDef.length, linkDef.angle))
                    Log("---- BaseAngle: " .. string.format("%.2f", baseAngle) .. " ----")
                    Log("---- Checking connected links for physical node " .. tostring(fromNodeId) .. " ----")
                    for _, link in ipairs(connectedLinks) do
                        Log(string.format("  -> Link %d-%d, mat=%s, len=%.2f, relAngle=%.2f", 
                            link.nodeA, link.nodeB, link.material, link.length, link.relAngle))
                    end
                    Log("---- End connected links ----")
					--]]
					table.insert(remainingLinks, linkDef) 
				end
            else
                table.insert(remainingLinks, linkDef)
            end
        end
        linksToProcess = remainingLinks
    end
	
	if partialMatchAllowed then
        return true, { nodeMap = nodeMap, remainingLinks = linksToProcess }
    end
    
    if #linksToProcess > 0 then
        return false, { reason = "Link missing/incorrect", failingLinkDef = linksToProcess[1], correctLinkKeys = checkedLinks, linkMap = linkMap, nodeMap = nodeMap }
    end

    local foundDevices, foundLinks = {}, {}
    for linkKey, _ in pairs(checkedLinks) do
        local nodes = {}
        for id in string.gmatch(linkKey, "[^-]+") do table.insert(nodes, tonumber(id)) end
        table.insert(foundLinks, { nodeA = nodes[1], nodeB = nodes[2] })
    end
    if structureDefinition.requiredDevices then
        local errorData = { correctLinkKeys = checkedLinks, linkMap = linkMap, nodeMap = nodeMap }
        for _, devDef in ipairs(structureDefinition.requiredDevices) do
            local fromId, toId = nodeMap[devDef.onLink.from], nodeMap[devDef.onLink.to]
            errorData.failingLinkDef = devDef
            if not fromId or not toId then errorData.reason = "Node not found"; return false, errorData end
            local devId = GetDeviceIdOnPlatform(fromId, toId)
            if not devId or devId == -1 then errorData.reason = "Device not found"; return false, errorData end
            if GetDeviceType(devId) ~= devDef.saveName then errorData.reason = "Device mismatch"; return false, errorData end
            if devDef.t and devDef.t ~= -1 and math.abs(GetDeviceLinkPosition(devId) - devDef.t) > DEVICE_T_TOLERANCE then
                errorData.reason = "Device position mismatch"; return false, errorData
            end
            table.insert(foundDevices, devId)
        end
    end

    return true, { deviceIds = foundDevices, linkNodePairs = foundLinks, nodeMap = nodeMap }
end

function GetLinkNodePairsFromMap(linkMap)
    local pairs = {}
    for _, link in pairs(linkMap) do
        table.insert(pairs, { nodeA = link.nodeA, nodeB = link.nodeB })
    end
    return pairs
end

function count_keys(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end
	
	