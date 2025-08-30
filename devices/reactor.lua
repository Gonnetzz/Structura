DestroyEffect = "effects/mushroom_cloud.lua"
HurtEffect = "effects/reactor_hurt.lua"
ClaimsStructures = true
Scale = 1.0
SelectionWidth = 45.0
SelectionHeight = 85.0
SelectionOffset = { 0.0, 0.0 }
Mass = 40.0
HitPoints = 100.0
EnergyProductionRate = 10
MetalProductionRate = -8
EnergyStorageCapacity = 50000 --4000.0
MetalStorageCapacity = 50000 --1000.0
MinWindEfficiency = 1
MaxWindHeight = 0
MaxRotationalSpeed = 0
DeviceSplashDamage = 400
DeviceSplashDamageMaxRadius = 400
DeviceSplashDamageDelay = 0
IncendiaryRadius = 250
IncendiaryRadiusHeated = 350
StructureSplashDamage = 240
StructureSplashDamageMaxRadius = 200
HurtMinDelay = 3
DrawBracket = false
Repairable = false
ExplodeWhenOutOfWorld = true
UnderwaterDamageRate = 10
UnderwaterDamageMinAngle = 30
UnderwaterDamageMaxStructureRadius = 150
UnderwaterDamageMinDepth = 20

dofile("effects/device_smoke.lua")
SmokeEmitter = StandardDeviceSmokeEmitter

Sprites =
{
	{
		Name = "piston_anim",

		States =
		{
			Normal =
			{
				Frames =
				{
					{ texture = "devices/reactor/reactor_piston02.dds" },
					{ texture = "devices/reactor/reactor_piston03.dds" },
					{ texture = "devices/reactor/reactor_piston04.dds" },
					{ texture = "devices/reactor/reactor_piston05.dds" },
					{ texture = "devices/reactor/reactor_piston06.dds" },
					{ texture = "devices/reactor/reactor_piston07.dds" },
					{ texture = "devices/reactor/reactor_piston08.dds" },
					{ texture = "devices/reactor/reactor_piston09.dds" },
					{ texture = "devices/reactor/reactor_piston10.dds" },
					{ texture = "devices/reactor/reactor_piston11.dds" },
					{ texture = "devices/reactor/reactor_piston12.dds" },
					{ texture = "devices/reactor/reactor_piston01.dds", duration = 0.7 },

					duration = 0.1,
					blendColour = false,
					blendCoordinates = false,
					mipmap = true,
				},
				NextState = "Normal",
			},
		},
	},
	{
		Name = "lights_anim",

		States =
		{
			Normal =
			{
				Frames =
				{
					{ texture = "devices/reactor/lights01.dds" },
					{ texture = "devices/reactor/lights02.dds" },
					{ texture = "devices/reactor/lights03.dds" },
					{ texture = "devices/reactor/lights04.dds" },

					duration = 0.8,
					blendColour = false,
					blendCoordinates = false,
					mipmap = true,
				},
				NextState = "Normal",
			},
		},
	},
	{
		Name = "core_anim",

		States =
		{
			Normal =
			{
				Frames =
				{
					{ texture = "devices/reactor/reactor_core01.dds" },
					{ texture = "devices/reactor/reactor_core02.dds" },
					{ texture = "devices/reactor/reactor_core03.dds" },
					{ texture = "devices/reactor/reactor_core04.dds" },

					duration = 0.1,
					blendColour = false,
					blendCoordinates = false,
					mipmap = true,
				},
				NextState = "Normal",
			},
		},
	},
	{
		Name = "reactor-base",
		States =
		{
			Normal = { Frames = { { texture = "devices/reactor/base.dds" }, mipmap = true, }, },
		},
	},
}

NodeEffects =
{
	{
		NodeName = "SteamEmitter",
		EffectPath = "effects/reactor_steam.lua",
		Automatic = true,
	},
	{
		NodeName = "Reactor",
		EffectPath = "effects/commander_reactor_glow.lua",
		Automatic = false,
	},
	{
		NodeName = "Core",
		EffectPath = "effects/reactor_highlight.lua",
		Automatic = false,
	},
}

Root =
{
	Name = "Reactor",
	Angle = 0,
	Pivot = { 0, -0.045 },
	PivotOffset = { 0, 0 },
	Sprite = "reactor-base",
--[[	
	ChildrenBehind =
	{
		{
			Name = "Head",
			Angle = 0,
			Pivot = { 0, 0 },
			PivotOffset = { 0, 0 },
			Sprite = "reactor_detail",
		},
	},
]]
	ChildrenInFront =
	{
		{
			Name = "SteamEmitter",
			Angle = 0,
			Pivot = { 0, -0.3 },
			PivotOffset = { 0, 0 },
		},
		{
			Name = "Lights1",
			Angle = 0,
			Pivot = { 0.3, 0.048},
			PivotOffset = { 0, 0 },
			Sprite = "lights_anim",
		},
		{
			Name = "Lights2",
			Angle = 0,
			Pivot = { -0.3, 0.048},
			PivotOffset = { 0, 0 },
			Sprite = "lights_anim",
		},
		{
			Name = "Core",
			Angle = 0,
			Pivot = { 0, 0.06},
			PivotOffset = { 0, 0 },
			Sprite = "core_anim",
		},
		{
			Name = "Head1",
			Angle = 0,
			Pivot = { 0.37, -0.12},
			PivotOffset = { 0, 0 },
			Sprite = "piston_anim",
		},
		{
			Name = "Head2",
			Angle = -78,
			Pivot = { -0.37, -0.12},
			PivotOffset = { 0, 0 },
			Sprite = "piston_anim",
		},
		{
			Name = "Head3",
			Angle = 180,
			Pivot = { -0.37, 0.24},
			PivotOffset = { 0, 0 },
			Sprite = "piston_anim",
		},
		{
			Name = "Head4",
			Angle = 102,
			Pivot = { 0.37, 0.24},
			PivotOffset = { 0, 0 },
			Sprite = "piston_anim",
		},
	},
}
