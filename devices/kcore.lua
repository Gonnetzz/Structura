ConstructEffect = "effects/device_construct.lua"
CompleteEffect = "effects/device_complete.lua"
DestroyUnderwaterEffect = "mods/dlc2/effects/device_explode_submerged.lua"
Scale = 1
SelectionWidth = 44.0
SelectionHeight = 40.0
SelectionOffset = { 0.0, -40.5 }
Mass = 40.0
HitPoints = 250.0
EnergyProductionRate = 0.0
MetalProductionRate = 0.0
EnergyStorageCapacity = 0.0
MetalStorageCapacity = 0.0
MinWindEfficiency = 0
MaxWindHeight = 0
MaxRotationalSpeed = 0
DrawBracket = false
DrawBehindTerrain = true
NoReclaim = false
TeamOwned = true
BlockPenetration = false

dofile("effects/device_smoke.lua")
SmokeEmitter = StandardDeviceSmokeEmitter

Sprites =
{
	{
		Name = "kcore-base",
		States =
		{
			Normal =
			{
				Frames = {
					{ texture = path .. "/devices/KCore/0001.png" },
					{ texture = path .. "/devices/KCore/0002.png" },
					{ texture = path .. "/devices/KCore/0003.png" },
					{ texture = path .. "/devices/KCore/0004.png" },
					{ texture = path .. "/devices/KCore/0005.png" },
					{ texture = path .. "/devices/KCore/0006.png" },
					{ texture = path .. "/devices/KCore/0007.png" },
					{ texture = path .. "/devices/KCore/0008.png" },
					{ texture = path .. "/devices/KCore/0009.png" },
					{ texture = path .. "/devices/KCore/0010.png" },
					{ texture = path .. "/devices/KCore/0011.png" },
					{ texture = path .. "/devices/KCore/0012.png" },
					{ texture = path .. "/devices/KCore/0013.png" },
					{ texture = path .. "/devices/KCore/0014.png" },
					{ texture = path .. "/devices/KCore/0015.png" },
					{ texture = path .. "/devices/KCore/0016.png" },
					{ texture = path .. "/devices/KCore/0017.png" },
					{ texture = path .. "/devices/KCore/0018.png" },
					{ texture = path .. "/devices/KCore/0019.png" },
					{ texture = path .. "/devices/KCore/0020.png" },
					{ texture = path .. "/devices/KCore/0021.png" },
					{ texture = path .. "/devices/KCore/0022.png" },
					{ texture = path .. "/devices/KCore/0023.png" },
					{ texture = path .. "/devices/KCore/0024.png" },
					{ texture = path .. "/devices/KCore/0025.png" },
					{ texture = path .. "/devices/KCore/0026.png" },
				},
				duration = 0.2,
				mipmap = true,
			},
		},
	},
}

Root =
{
	Name = "KCore",
	Angle = 0,
	Pivot = { 0, -0.23},
	PivotOffset = { 0, 0 },
	Scale = 0.4,
	Sprite = "kcore-base",

	ChildrenInFront =
	{
	},
}