table.insert(Sprites, DetailSprite("hud-detail-control-panel", "HUD-Details-ControlPanel", path))
table.insert(Sprites, ButtonSprite("hud-control-panel-icon", "HUD/HUD-ControlPanel", nil, ButtonSpriteBottom, nil, nil, path))
table.insert(Sprites, DetailSprite("hud-detail-test-device", "HUD-Details-TestDevice", path))
table.insert(Sprites, ButtonSprite("hud-test-device-icon", "HUD/TestDevice", nil, ButtonSpriteBottom, nil, nil, path))

function IndexOfDevice(saveName)
	for k,v in ipairs(Devices) do
		if v.SaveName == saveName then
			return k
		end
	end
	return #Devices
end

table.insert(Devices, IndexOfDevice("sandbags") + 1,
{
	SaveName = "control_panel",
	FileName = path .. "/devices/control_panel.lua",
	Icon = "hud-control-panel-icon",
	Detail = "hud-detail-control-panel",
	Prerequisite = "upgrade",
	BuildTimeComplete = 30,
	ScrapPeriod = 8,
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
	SelectEffect = "ui/hud/devices/ui_devices",
	Upgrades =
	{
		{
			Enabled = true,
			SaveName = "control_panel_upgrade",
			MetalCost = 10,
			EnergyCost = 10,
			BuildDuration = 1,
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
            SaveName = "control_panel",
            MetalCost = 0,
            EnergyCost = 0,
            BuildDuration = 0.1,
        },
    }
    table.insert(Devices, controlPanelUpgrade)
end

table.insert(Devices, IndexOfDevice("sandbags") + 1,
{
	SaveName = "ttest_device",
	FileName = path .. "/devices/test_device.lua",
	Icon = "hud-test-device-icon",
	Detail = "hud-detail-test-device",
	Prerequisite = "upgrade",
	BuildTimeComplete = 30,
	ScrapPeriod = 8,
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
	SelectEffect = "ui/hud/devices/ui_devices",
	Upgrades =
	{
		{
			Enabled = true,
			SaveName = "ttest_device_upgrade",
			MetalCost = 10,
			EnergyCost = 10,
			BuildDuration = 1,
		},
	},
})

local testdevice = FindDevice("ttest_device")
local testdeviceUpgrade = DeepCopy(test_device)
if testdeviceUpgrade then
    testdeviceUpgrade.SaveName = "ttest_device_upgrade"
    testdeviceUpgrade.FileName = path .. "/devices/ttest_device_upgrade.lua"
    testdeviceUpgrade.Enabled = false
   
    testdeviceUpgrade.Upgrades =
    {
        {
            Enabled = true,
            SaveName = "ttest_device",
            MetalCost = 0,
            EnergyCost = 0,
            BuildDuration = 0.1,
        },
    }
    table.insert(Devices, testdeviceUpgrade)
end