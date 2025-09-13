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
		Name = "ecore-base",
		States =
		{
			Normal =
			{
				Frames =
				{
					{ texture = path .. "/devices/ECore/0600.png" },
					{ texture = path .. "/devices/ECore/0601.png" },
					{ texture = path .. "/devices/ECore/0602.png" },
					{ texture = path .. "/devices/ECore/0603.png" },
					{ texture = path .. "/devices/ECore/0604.png" },
					{ texture = path .. "/devices/ECore/0605.png" },
					{ texture = path .. "/devices/ECore/0606.png" },
					{ texture = path .. "/devices/ECore/0607.png" },
					{ texture = path .. "/devices/ECore/0608.png" },
					{ texture = path .. "/devices/ECore/0609.png" },
					{ texture = path .. "/devices/ECore/0610.png" },
					{ texture = path .. "/devices/ECore/0611.png" },
					{ texture = path .. "/devices/ECore/0612.png" },
					{ texture = path .. "/devices/ECore/0613.png" },
					{ texture = path .. "/devices/ECore/0614.png" },
					{ texture = path .. "/devices/ECore/0615.png" },
					{ texture = path .. "/devices/ECore/0616.png" },
					{ texture = path .. "/devices/ECore/0617.png" },
					{ texture = path .. "/devices/ECore/0618.png" },
					{ texture = path .. "/devices/ECore/0619.png" },
					{ texture = path .. "/devices/ECore/0620.png" },
					{ texture = path .. "/devices/ECore/0621.png" },
					{ texture = path .. "/devices/ECore/0622.png" },
					{ texture = path .. "/devices/ECore/0623.png" },
					{ texture = path .. "/devices/ECore/0624.png" },
					{ texture = path .. "/devices/ECore/0625.png" },
					{ texture = path .. "/devices/ECore/0626.png" },
					{ texture = path .. "/devices/ECore/0627.png" },
				},
				duration = 0.2,
				mipmap = true,
			},
		},
	},
}

Root =
{
	Name = "ECore",
	Angle = 0,
	Pivot = { 0, -0.23},
	PivotOffset = { 0, 0 },
	Scale = 0.4,
	Sprite = "ecore-base",

	ChildrenInFront =
	{
	},
}