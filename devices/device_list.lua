table.insert(Sprites, DetailSprite("hud-detail-control-panel", "HUD-Details-ControlPanel", path))
table.insert(Sprites, ButtonSprite("hud-control-panel-icon", "HUD/HUD-ControlPanel", nil, ButtonSpriteBottom, nil, nil, path))
table.insert(Sprites, DetailSprite("hud-detail-test-device", "HUD-Details-TestDevice", path))
table.insert(Sprites, ButtonSprite("hud-test-device-icon", "HUD/TestDevice", nil, ButtonSpriteBottom, nil, nil, path))

table.insert(Sprites, ButtonSprite("hud-upgrade-log", "context/upgradeLog", nil, nil, nil, nil, path))
table.insert(Sprites, ButtonSprite("hud-upgrade-create", "context/upgradeCreate", nil, nil, nil, nil, path))

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
			Button = "hud-upgrade-test",
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
			Button = "hud-upgrade-test",
        },
    }
    table.insert(Devices, controlPanelUpgrade)
end

table.insert(Devices, IndexOfDevice("sandbags") + 1,
{
	SaveName = "test_device",
	FileName = path .. "/devices/test_device.lua",
	Icon = "hud-test-device-icon",
	Detail = "hud-detail-test-device",
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
	--Enabled = false,
	ShowInEditor = true,
	SelectEffect = "ui/hud/devices/ui_devices",
	Upgrades =
		{
			{
				Enabled = true,
				SaveName = "test_device_log_structure",
				MetalCost = 
				10, EnergyCost = 10, 
				BuildDuration = 1,
				Button = "hud-upgrade-log",
			},
			{
				Enabled = true,
				SaveName = "test_device_create_structure",
				MetalCost = 10, 
				EnergyCost = 10, 
				BuildDuration = 1,
				Button = "hud-upgrade-create",
			},
		},
})

local testdevice = FindDevice("test_device")
local testdeviceLogUpgrade = DeepCopy(testdevice)
if testdeviceLogUpgrade then
    testdeviceLogUpgrade.SaveName = "test_device_log_structure"
    testdeviceLogUpgrade.FileName = path .. "/devices/test_device_upgrade.lua"
    testdeviceLogUpgrade.Enabled = false
    testdeviceLogUpgrade.Upgrades = 
	{ 
		{ 
			Enabled = true, 
			SaveName = "test_device", 
			MetalCost = 0, 
			EnergyCost = 0, 
			BuildDuration = 0.1, 
			Button = "hud-upgrade-log", 
		}, 
	}
    table.insert(Devices, testdeviceLogUpgrade)
end

local testdeviceCreateUpgrade = DeepCopy(testdevice)
if testdeviceCreateUpgrade then
    testdeviceCreateUpgrade.SaveName = "test_device_create_structure"
    testdeviceCreateUpgrade.FileName = path .. "/devices/test_device_upgrade.lua"
    testdeviceCreateUpgrade.Enabled = false
    testdeviceCreateUpgrade.Upgrades = 
	{ 
		{ 
			Enabled = true, 
			SaveName = "test_device", 
			MetalCost = 0, 
			EnergyCost = 0, 
			BuildDuration = 0.1, 
			Button = "hud-upgrade-create", 
		}, 
	}
    table.insert(Devices, testdeviceCreateUpgrade)
end