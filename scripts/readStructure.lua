dofile(path .. "/scripts/Math.lua")

local LENGTH_TOLERANCE = 5.0
local ANGLE_TOLERANCE = 5.0
local DEVICE_T_TOLERANCE = 0.05

function LogFailureDetails(failureReason, failingNodeId, failingLinkDef, nodeMap)
    if type(failureReason) == "string" then
        Log("Structure Check Failure: " .. failureReason)
    end
    if failingNodeId and failingLinkDef then
        local failingNodeName
        for name, id in pairs(nodeMap) do
            if id == failingNodeId then failingNodeName = name; break; end
        end
        Log("Failure at node '" .. tostring(failingNodeName) .. "' (ID: " .. failingNodeId .. ")")
        Log(string.format("  - Expected Link: From='%s', To='%s', Material=%s, Length=%.2f, Angle=%.2f",
            tostring(failingLinkDef.from), tostring(failingLinkDef.to), failingLinkDef.material, failingLinkDef.length, failingLinkDef.angle))
    end
end

function MirrorStructureDefinition(def)
    local mirrored = {
        mirrorable = def.mirrorable,
        links = {},
        requiredDevices = {}
    }
    local nodeNameSwap = { A = "B", B = "A" }
    for _, link in ipairs(def.links) do
        local newFrom = nodeNameSwap[link.from] or link.from
        local newTo = nodeNameSwap[link.to] or link.to
        local newAngle = 180 - link.angle
        if newAngle > 180 then newAngle = newAngle - 360 end
        if newAngle < -180 then newAngle = newAngle + 360 end
        table.insert(mirrored.links, {
            from = newFrom,
            to = newTo,
            material = link.material,
            length = link.length,
            angle = newAngle
        })
    end
    if def.requiredDevices then
        for _, dev in ipairs(def.requiredDevices) do
            local newDevFrom = nodeNameSwap[dev.onLink.from] or dev.onLink.from
            local newDevTo = nodeNameSwap[dev.onLink.to] or dev.onLink.to
            table.insert(mirrored.requiredDevices, {
                saveName = dev.saveName,
                t = dev.t,
                onLink = { from = newDevFrom, to = newDevTo }
            })
        end
    end
    return mirrored
end

function CheckStructureWithTeam(teamId, deviceId, structureDefinition)
    Log("CheckStructureWithTeam: TeamId="..teamId.." DeviceId="..deviceId)
    local primaryDef, secondaryDef
    if teamId == 1 then
        primaryDef = structureDefinition
        secondaryDef = MirrorStructureDefinition(structureDefinition)
    else
        primaryDef = MirrorStructureDefinition(structureDefinition)
        secondaryDef = structureDefinition
    end

    local success, structureData = CheckStructure(deviceId, primaryDef)
    if success then
        Log("Structure matched (primary).")
        return true, structureData
    else
        Log("Primary check failed, trying secondary...")
        LogFailureDetails(structureData.reason, structureData.failingNodeId, structureData.failingLinkDef, structureData.nodeMap)
        local success2, structureData2 = CheckStructure(deviceId, secondaryDef)
        if success2 then
            Log("Structure matched (secondary).")
            return true, structureData2
        else
            Log("Secondary also failed.")
            LogFailureDetails(structureData2.reason, structureData2.failingNodeId, structureData2.failingLinkDef, structureData2.nodeMap)
            return false, nil
        end
    end
end

function CheckStructure(deviceId, structureDefinition)
    local nodeA = GetDevicePlatformA(deviceId)
    local nodeB = GetDevicePlatformB(deviceId)
    if not nodeA or not nodeB or nodeA == 0 or nodeB == 0 then
        return false, { reason = "Invalid base platform for device." }
    end
    
    local nodeMap = { A = nodeA, B = nodeB }
    local checkedLinks = {}
    local linksToProcess = {}
    for _, link in ipairs(structureDefinition.links) do
        table.insert(linksToProcess, link)
    end
    
    local progressMade = true
    while #linksToProcess > 0 and progressMade do
        progressMade = false
        local remainingLinks = {}
        for _, linkDef in ipairs(linksToProcess) do
            if nodeMap[linkDef.from] then
                local fromNodeId = nodeMap[linkDef.from]
                local matchFound = false
                for i = 0, NodeLinkCount(fromNodeId) - 1 do
                    local nextNodeId = NodeLinkedNodeId(fromNodeId, i)
                    local linkKey = fromNodeId < nextNodeId and (fromNodeId .. "-" .. nextNodeId) or (nextNodeId .. "-" .. fromNodeId)
                    if not checkedLinks[linkKey] then
                        local actualMaterial = GetLinkMaterialSaveName(fromNodeId, nextNodeId)
                        local actualVector = SubtractVectors(NodePosition(nextNodeId), NodePosition(fromNodeId))
                        local actualLength = Magnitude(actualVector)
                        local actualAngle = SignedAngleBetweenVectors({x=1, y=0}, actualVector)
                        if actualMaterial == linkDef.material and
                           math.abs(actualLength - linkDef.length) < LENGTH_TOLERANCE and
                           math.abs(actualAngle - linkDef.angle) < ANGLE_TOLERANCE then
                            if nodeMap[linkDef.to] and nodeMap[linkDef.to] ~= nextNodeId then
                            elseif not nodeMap[linkDef.to] then
                                nodeMap[linkDef.to] = nextNodeId
                                checkedLinks[linkKey] = true
                                matchFound = true
                                progressMade = true
                                break
                            else 
                                checkedLinks[linkKey] = true
                                matchFound = true
                                progressMade = true
                                break
                            end
                        end
                    end
                end
                if not matchFound then
                    table.insert(remainingLinks, linkDef)
                end
            else
                table.insert(remainingLinks, linkDef)
            end
        end
        linksToProcess = remainingLinks
    end

    if #linksToProcess > 0 then
        local firstUnmatched = linksToProcess[1]
        return false, { reason = "Could not find a matching link in the structure.", failingNodeId = nodeMap[firstUnmatched.from], failingLinkDef = firstUnmatched, nodeMap = nodeMap }
    end

    local foundDevices = {}
    local foundLinks = {}
    for linkKey, _ in pairs(checkedLinks) do
        local nodes = {}
        for id in string.gmatch(linkKey, "[^-]+") do
            table.insert(nodes, tonumber(id))
        end
        table.insert(foundLinks, { nodeA = nodes[1], nodeB = nodes[2] })
    end
    if structureDefinition.requiredDevices then
        for _, devDef in ipairs(structureDefinition.requiredDevices) do
            local fromId = nodeMap[devDef.onLink.from]
            local toId = nodeMap[devDef.onLink.to]
            if not fromId or not toId then
                return false, { reason = "Device Check Error: Node not found.", failingLinkDef = devDef, nodeMap = nodeMap }
            end
            local foundDeviceId = GetDeviceIdOnPlatform(fromId, toId)
            if not foundDeviceId or foundDeviceId == -1 then
                return false, { reason = "Device not found: Expected '"..devDef.saveName.."'", failingLinkDef = devDef, nodeMap = nodeMap }
            end
            if GetDeviceType(foundDeviceId) ~= devDef.saveName then
                return false, { reason = "Device mismatch: Expected '"..devDef.saveName.."' but found '"..GetDeviceType(foundDeviceId).."'", failingLinkDef = devDef, nodeMap = nodeMap }
            end
            if devDef.t and devDef.t ~= -1 then
                local foundT = GetDeviceLinkPosition(foundDeviceId)
                if math.abs(foundT - devDef.t) > DEVICE_T_TOLERANCE then
                    return false, { reason = "Device position mismatch", failingLinkDef = devDef, nodeMap = nodeMap }
                end
            end
            table.insert(foundDevices, foundDeviceId)
        end
    end

    local structureData = {
        deviceCount = #foundDevices,
        deviceIds = foundDevices,
        linkNodePairs = foundLinks,
        nodeMap = nodeMap
    }
    return true, structureData
end