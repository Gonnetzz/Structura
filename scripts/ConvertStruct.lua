-- scripts/ConvertStruct.lua

ConversionProcesses = {}
NextConversionId = 1

function GetLinkKey(nodeA, nodeB)
    if nodeA < nodeB then return nodeA .. "-" .. nodeB else return nodeB .. "-" .. nodeA end
end

function SalvageDevice(deviceIds)
    Log("Salvaging " .. #deviceIds .. " devices to trigger conversion...")
    for _, deviceId in ipairs(deviceIds) do
        if DeviceExists(deviceId) then
            DestroyDeviceById(deviceId)
        end
    end
    return true
end

function ProcessNextDemolitionLayer(conversionId)
    local process = ConversionProcesses[conversionId]
    if not process then return end

    process.currentLayer = process.currentLayer + 1
    local layer = process.demolitionLayers[process.currentLayer]

    if not layer or #layer == 0 then
        Log("Conversion " .. conversionId .. ": All layers demolished. Process complete.")
        
        if DeviceExists(process.controlPanelId) then
            Log("Upgrading control panel "..process.controlPanelId.." to target device 'test_device'.")
            local result = UpgradeDevice(process.controlPanelId, "test_device")
            if result < 0 then
                Log("ERROR: UpgradeDevice failed with code: " .. result)
            else
                Log("Upgrade successful. New device ID: " .. result)
            end
        else
            Log("Control panel "..process.controlPanelId.." no longer exists. Cannot complete conversion.")
        end

        ConversionProcesses[conversionId] = nil
        return
    end

    Log("Conversion " .. conversionId .. ": Demolishing layer " .. process.currentLayer .. " with " .. #layer .. " links.")
    process.pendingLinks = {}
    for _, linkKey in ipairs(layer) do
        local link = process.linkMap[linkKey]
        if link and NodeExists(link.nodeA) and NodeExists(link.nodeB) then
            process.pendingLinks[linkKey] = true
            DestroyLink(process.teamId, link.nodeA, link.nodeB)
        end
    end
    
    local hasPending = false
    for k, v in pairs(process.pendingLinks) do hasPending = true; break; end
    if not hasPending then
        ProcessNextDemolitionLayer(conversionId)
    end
end

function InitiateLinkDemolition(conversionId)
    local process = ConversionProcesses[conversionId]
    if not process or not process.linkNodePairs then return false end

    local adj = {}
    local linkMap = {}
    
    for _, link in ipairs(process.linkNodePairs) do
        local nodeA, nodeB = link.nodeA, link.nodeB
        adj[nodeA] = adj[nodeA] or {}
        adj[nodeB] = adj[nodeB] or {}
        table.insert(adj[link.nodeA], nodeB)
        table.insert(adj[link.nodeB], nodeA)
        link.length = Magnitude(SubtractVectors(NodePosition(nodeA), NodePosition(nodeB)))
        linkMap[GetLinkKey(nodeA, nodeB)] = link
    end

    local distance = {}
    local queue = {}
    distance[process.baseNodeA] = 0
    distance[process.baseNodeB] = 0
    table.insert(queue, process.baseNodeA)
    table.insert(queue, process.baseNodeB)
    
    local head = 1
    while head <= #queue do
        local u = queue[head]
        head = head + 1
        if adj[u] then
            for _, v in ipairs(adj[u]) do
                if distance[v] == nil then
                    distance[v] = distance[u] + 1
                    table.insert(queue, v)
                end
            end
        end
    end

    local layers = {}
    local maxDist = 0
    for linkKey, link in pairs(linkMap) do
        local distA = distance[link.nodeA]
        local distB = distance[link.nodeB]
        if distA and distB then
            local linkDist = math.max(distA, distB)
            layers[linkDist] = layers[linkDist] or {}
            table.insert(layers[linkDist], linkKey)
            if linkDist > maxDist then maxDist = linkDist end
        end
    end

    local demolitionLayers = {}
    for i = maxDist, 0, -1 do
        if layers[i] then
            table.insert(demolitionLayers, layers[i])
        end
    end
    
    process.demolitionLayers = demolitionLayers
    process.linkMap = linkMap
    process.pendingLinks = {}
    process.currentLayer = 0

    Log("Conversion " .. conversionId .. ": Structure analysis complete. Found " .. #demolitionLayers .. " demolition layers.")
    ProcessNextDemolitionLayer(conversionId)
    return true
end

function ConvertStructureStart(teamId, controlPanelUpgradeId, structureData)
    Log("--- Preparing Structure Conversion ---")
    
    if not structureData or not structureData.linkNodePairs or not structureData.nodeMap then
        Log("Error: Invalid structure data provided for conversion.")
        return false
    end

    local conversionId = NextConversionId
    NextConversionId = NextConversionId + 1

    ConversionProcesses[conversionId] = {
        id = conversionId,
        teamId = teamId,
        controlPanelId = -1,
        controlPanelUpgradeId = controlPanelUpgradeId,
        triggerDeviceIds = {},
        linkNodePairs = structureData.linkNodePairs,
        baseNodeA = structureData.nodeMap.A,
        baseNodeB = structureData.nodeMap.B,
        demolitionInitiated = false
    }

    for _, id in ipairs(structureData.deviceIds) do
        table.insert(ConversionProcesses[conversionId].triggerDeviceIds, id)
    end
    
    Log("Conversion " .. conversionId .. ": Process created. Waiting for " .. #structureData.deviceIds .. " devices to be salvaged.")

    if structureData.deviceIds and #structureData.deviceIds > 0 then
        SalvageDevice(structureData.deviceIds)
    else
        Log("Conversion " .. conversionId .. ": No trigger devices found, scheduling link demolition immediately.")
        ConversionProcesses[conversionId].demolitionInitiated = true
        ScheduleCall(1, InitiateLinkDemolition, conversionId)
    end
    
    return true
end