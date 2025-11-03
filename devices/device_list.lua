dofile(path .. "/scripts/StructureUtils.lua")

table.insert(Sprites, DetailSprite("hud-detail-control-panel", "HUD-Details-ControlPanel", path))
table.insert(Sprites, ButtonSprite("hud-control-panel-icon", "HUD/HUD-ControlPanel", nil, ButtonSpriteBottom, nil, nil, path))

table.insert(Sprites, DetailSprite("hud-detail-test-device", "HUD-Details-TestDevice", path))
table.insert(Sprites, ButtonSprite("hud-test-device-icon", "HUD/TestDevice", nil, ButtonSpriteBottom, nil, nil, path))

table.insert(Sprites, DetailSprite("hud-detail-ecore", "HUD-Details-ECore", path))
table.insert(Sprites, ButtonSprite("hud-ecore-icon", "HUD/ECore", nil, ButtonSpriteBottom, nil, nil, path))

table.insert(Sprites, DetailSprite("hud-detail-kcore", "HUD-Details-KCore", path))
table.insert(Sprites, ButtonSprite("hud-kcore-icon", "HUD/KCore", nil, ButtonSpriteBottom, nil, nil, path))

table.insert(Sprites, ButtonSprite("hud-energy-weapons", "context/EnergyWeapons", nil, nil, nil, nil, path))
table.insert(Sprites, ButtonSprite("hud-kinetic-weapons", "context/KineticWeapons", nil, nil, nil, nil, path))

table.insert(Sprites, ButtonSprite("hud-upgrade-log", "context/upgradeLog", nil, nil, nil, nil, path))
table.insert(Sprites, ButtonSprite("hud-upgrade-create", "context/upgradeCreate", nil, nil, nil, nil, path))

local weaponNames = { "laser", "firebeam", "cannon", "cannon20mm", "magnabeam", "howitzer" }

local upgradeCosts = {
    default = {
        check = { MetalCost = 100, EnergyCost = 1000, BuildDuration = 0.1 },
        build = { MetalCost = 50, EnergyCost = 500, BuildDuration = 0.1 },
        conv  = { MetalCost = 0, EnergyCost = 0, BuildDuration = 0.1 },
    },
    firebeam = {
        check = { MetalCost = 20, EnergyCost = 1150 },
    },
    laser = {
        check = { MetalCost = 540, EnergyCost = 4500 },
    },
    magnabeam = {
		check = { MetalCost = 140, EnergyCost = 3500 },
    },
	cannon20mm = {
		check = { MetalCost = 30, EnergyCost = 2350 },
    },
	cannon = {
		check = { MetalCost = 260, EnergyCost = 3350 },
    },
	howitzer = {
		check = { MetalCost = 360, EnergyCost = 7250 },
    },
}

for _, weapon in ipairs(weaponNames) do
    table.insert(Sprites, ButtonSprite(
        "hud-build-" .. weapon,
        "context/" .. weapon .. "Construct",
        nil, nil, nil, nil, path
    ))

    table.insert(Sprites, ButtonSprite(
        "hud-check-" .. weapon,
        "context/" .. weapon .. "Convert",
        nil, nil, nil, nil, path
    ))
end

function IndexOfDevice(saveName)
	for k,v in ipairs(Devices) do
		if v.SaveName == saveName then
			return k
		end
	end
	return #Devices
end

function makeUpgradeEntry(prefix, base)
	local buttonName
	if prefix == "conv" then
		buttonName = "hud-upgrade-log"
	else
		buttonName = "hud-" .. prefix .. "-" .. base
	end
	local weaponCosts = upgradeCosts[base] or upgradeCosts["default"]
    local costEntry = weaponCosts[prefix] or upgradeCosts["default"][prefix]
    return {
        Enabled = (prefix ~= "conv"),
        SaveName = prefix .. base,
        MetalCost = costEntry.MetalCost,
        EnergyCost = costEntry.EnergyCost,
        BuildDuration = costEntry.BuildDuration,
        Button = buttonName,
        Prerequisite = nil,
    }
end

function createUpgradeDummy(upgradeName, base)
    local basedevice = FindDevice(base)
    local upgraded = DeepCopy(basedevice)
    if upgraded then
        upgraded.SaveName = upgradeName
        upgraded.FileName = path .. "/devices/"..base.."_upgrade.lua"
        upgraded.Enabled = false
        upgraded.ShowInEditor = false
		upgraded.Prerequisite = nil--idk maybe new gameflow through tech selling
        upgraded.Upgrades =
        {
            {
                Enabled = true,
                SaveName = base .. "_internal", 
                MetalCost = 0,
                EnergyCost = 0,
                BuildDuration = 0.1,
				Prerequisite = nil,
                Button = "hud-upgrade-log",
            },
        }
        table.insert(Devices, upgraded)
    end
end

function AddUpgradeAndDummy(upgradeList, prefix, weaponName, baseDeviceName)
    local weaponCosts = upgradeCosts[weaponName] or upgradeCosts["default"]
    local costEntry = weaponCosts[prefix] or upgradeCosts["default"][prefix]

    local metalCost = costEntry.MetalCost
    local energyCost = costEntry.EnergyCost

    local buttonName = (prefix == "conv") and "hud-upgrade-log" or ("hud-" .. prefix .. "-" .. weaponName)
	
	-- Overwrite, because all energy weapon use same struct and all kinetic use a diffrent struct 
	local enabled = false
    if prefix ~= "conv" then
        if prefix == "build" then
            enabled = (weaponName == "laser" or weaponName == "cannon")
			if weaponName == "laser" then
				buttonName = "hud-energy-weapons"
			elseif weaponName == "cannon" then
				buttonName = "hud-kinetic-weapons"
			end
        else
            enabled = true
        end
    end
    
    local upgradeEntry = {
        Enabled = enabled,
        SaveName = prefix .. weaponName,
        MetalCost = metalCost,
        EnergyCost = energyCost,
        BuildDuration = costEntry.BuildDuration or 0.1,
        Button = buttonName,
        Prerequisite = nil,
    }
    table.insert(upgradeList, upgradeEntry)

    createUpgradeDummy(prefix .. weaponName, baseDeviceName, metalCost, energyCost)
end

table.insert(Devices, IndexOfDevice("sandbags") + 1,
{
	SaveName = "control_panel",
	FileName = path .. "/devices/control_panel.lua",
	Icon = "hud-control-panel-icon",
	Detail = "hud-detail-control-panel",
	Prerequisite = "upgrade",
	BuildTimeComplete = 3,
	ScrapPeriod = 2,
	MetalCost = 150,
	EnergyCost = 600,
	MetalRepairCost = 150,
	EnergyRepairCost = 600,
	MetalReclaimMin = 0,
	MetalReclaimMax = 0,
	EnergyReclaimMin = 0,
	EnergyReclaimMax = 0,
	MaxUpAngle = StandardMaxUpAngle,
	BuildOnGroundOnly = false,
	HasDummy = false,
	Enabled = false,
	ShowInEditor = true,
	SelectEffect = "ui/hud/devices/ui_devices",
	Upgrades =
	{
		{
			Enabled = true,
			SaveName = "control_panel_upgrade",
			MetalCost = 10,
			EnergyCost = 10,
			BuildDuration = 1,
			Button = "hud-upgrade-log",
		},
		{
			Enabled = false,
			SaveName = "test_device",
			MetalCost = 0,
			EnergyCost = 0,
			BuildDuration = 0.1,
		},
	},
})

local controlPanel = FindDevice("control_panel")
local controlPanelUpgrade = DeepCopy(controlPanel)
if controlPanelUpgrade then
    controlPanelUpgrade.SaveName = "control_panel_upgrade"
    controlPanelUpgrade.FileName = path .. "/devices/control_panel_upgrade.lua"
    controlPanelUpgrade.Enabled = false
   
    controlPanelUpgrade.Upgrades =
    {
        {
            Enabled = true,
            SaveName = "control_panel_internal",
            MetalCost = 0,
            EnergyCost = 0,
            BuildDuration = 0.1,
			Button = "hud-upgrade-log",
        },
    }
    table.insert(Devices, controlPanelUpgrade)
end

local testDeviceUpgrades = {
    { 
		Enabled = true, 
		SaveName = "test_device_log_structure", 
		MetalCost = 10, 
		EnergyCost = 10, 
		BuildDuration = 1, 
		Button = "hud-upgrade-log" 
	}
}

local testDeviceBase = {
	SaveName = "test_device",
	FileName = path .. "/devices/test_device.lua",
	Icon = "hud-test-device-icon",
	Detail = "hud-detail-test-device",
	BuildTimeComplete = 3,
	ScrapPeriod = 2,
	MetalCost = 150,
	EnergyCost = 600,
	MetalRepairCost = 150,
	EnergyRepairCost = 600,
	MetalReclaimMin = 0,
	MetalReclaimMax = 0,
	EnergyReclaimMin = 0,
	EnergyReclaimMax = 0,
	MaxUpAngle = StandardMaxUpAngle,
	BuildOnGroundOnly = false,
	HasDummy = false,
	Enabled = false,
	ShowInEditor = true,
	SelectEffect = "ui/hud/devices/ui_devices",
	Upgrades = testDeviceUpgrades
}

for structureName, _ in pairs(StructureDefinitions) do
    local upgradeSaveName = "create_" .. string.lower(structureName)
    
    table.insert(testDeviceUpgrades, {
        Enabled = true,
        SaveName = upgradeSaveName,
        MetalCost = 10,
        EnergyCost = 10,
        BuildDuration = 0.1,
        Button = "hud-upgrade-create",
    })

    local newUpgradeDevice = DeepCopy(testDeviceBase)
    newUpgradeDevice.SaveName = upgradeSaveName
    newUpgradeDevice.FileName = path .. "/devices/test_device_upgrade.lua"
    newUpgradeDevice.Enabled = false
    newUpgradeDevice.ShowInEditor = false
    newUpgradeDevice.Upgrades = { { Enabled = true, SaveName = "test_device", MetalCost = 0, EnergyCost = 0, BuildDuration = 0.1 } }
    table.insert(Devices, newUpgradeDevice)
end

table.insert(Devices, IndexOfDevice("sandbags") + 1, testDeviceBase)

local testdeviceLogUpgrade = DeepCopy(testDeviceBase)
testdeviceLogUpgrade.SaveName = "test_device_log_structure"
testdeviceLogUpgrade.FileName = path .. "/devices/test_device_upgrade.lua"
testdeviceLogUpgrade.Enabled = false
testdeviceLogUpgrade.Upgrades = { { Enabled = true, SaveName = "test_device", MetalCost = 0, EnergyCost = 0, BuildDuration = 0.1, Button = "hud-upgrade-log" } }
table.insert(Devices, testdeviceLogUpgrade)

local ecoreUpgradeBases = { "laser", "firebeam", "magnabeam" }
local ecoreupgrades = {}

table.insert(Devices, IndexOfDevice("sandbags") + 1,
{
    SaveName = "ecore",
    FileName = path .. "/devices/ecore.lua",
    Icon = "hud-ecore-icon",
    Detail = "hud-detail-ecore",
    Prerequisite = "factory",
    BuildTimeComplete = 3,
    ScrapPeriod = 2,
    MetalCost = 100,
    EnergyCost = 400,
    MetalRepairCost = 20,
    EnergyRepairCost = 80,
    MetalReclaimMin = 0,
    MetalReclaimMax = 0,
    EnergyReclaimMin = 0,
    EnergyReclaimMax = 0,
    MaxUpAngle = StandardMaxUpAngle,
    BuildOnGroundOnly = false,
    HasDummy = false,
    ShowInEditor = true,
    SelectEffect = "ui/hud/devices/ui_devices",
    Upgrades = ecoreupgrades,
})

for _, base in ipairs(ecoreUpgradeBases) do
    for _, prefix in ipairs({ "build", "check", "conv" }) do
        AddUpgradeAndDummy(ecoreupgrades, prefix, base, "ecore")
    end
end

local kcoreUpgradeBases = { "cannon", "cannon20mm", "howitzer" }
local kcoreupgrades = {}

table.insert(Devices, IndexOfDevice("sandbags") + 1,
{
	SaveName = "kcore",
	FileName = path .. "/devices/kcore.lua",
	Icon = "hud-kcore-icon",
	Detail = "hud-detail-kcore",
	Prerequisite = "munitions",
	BuildTimeComplete = 3,
	ScrapPeriod = 2,
	MetalCost = 100,
	EnergyCost = 400,
	MetalRepairCost = 20,
	EnergyRepairCost = 80,
	MetalReclaimMin = 0,
	MetalReclaimMax = 0,
	EnergyReclaimMin = 0,
	EnergyReclaimMax = 0,
	MaxUpAngle = StandardMaxUpAngle,
	BuildOnGroundOnly = false,
	HasDummy = false,
	ShowInEditor = true,
	SelectEffect = "ui/hud/devices/ui_devices",
	Upgrades = kcoreupgrades,
})

for _, base in ipairs(kcoreUpgradeBases) do
    for _, prefix in ipairs({ "build", "check", "conv" }) do
        AddUpgradeAndDummy(kcoreupgrades, prefix, base, "kcore")
    end
end


local internalCopies = { "ecore", "kcore", "control_panel" }
for _, baseName in ipairs(internalCopies) do
    local baseDevice = FindDevice(baseName)
    if baseDevice then
        local internalCopy = DeepCopy(baseDevice)
        internalCopy.SaveName = baseName .. "_internal"
		internalCopy.FileName = path .. "/devices/"..baseName.."_upgrade.lua"
        internalCopy.Enabled = false
        internalCopy.ShowInEditor = false
        internalCopy.Prerequisite = nil

        table.insert(Devices, internalCopy)
    end
end




