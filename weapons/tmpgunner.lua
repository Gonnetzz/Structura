Scale = 1
SelectionWidth = 40.0
SelectionHeight = 40.0
SelectionOffset = { 0.0, -40.5 }
RecessionBox =
{
	Size = { 20, 25 },
	Offset = { -52.5, -40 },
}

WeaponMass = 40.0
HitPoints = 30.0
EnergyProductionRate = 0.0
MetalProductionRate = 0.0
EnergyStorageCapacity = 0.0
MetalStorageCapacity = 0.0
MinWindEfficiency = 1
MaxWindHeight = 0
MaxRotationalSpeed = 0

FireEffect = "effects/fire_machinegun.lua"
ShellEffect = "effects/shell_eject_small.lua"
ConstructEffect = "effects/device_construct.lua"
CompleteEffect = "effects/device_complete.lua"
DestroyEffect = "effects/machinegun_explode.lua"
DestroyUnderwaterEffect = "mods/dlc2/effects/device_explode_submerged_small.lua"
ReloadEffect = "effects/machine_gun_reload.lua"
Projectile = "machinegun"
BarrelLength = 60.0
MinFireClearance = 500
FireClearanceOffsetInner = 20
FireClearanceOffsetOuter = 40
ReloadTime = 1000.5
ReloadTimeIncludesBurst = false
MinFireSpeed = 5000.0
MaxFireSpeed = 5000.1
MinFireRadius = 500.0
MaxFireRadius = 1000.0
MinFireAngle = -35
MaxFireAngle = 80
KickbackMean = 15
KickbackStdDev = 3
PanDuration = 0
FireStdDev = 0.05
FireStdDevAuto = 0.005
Recoil = 20000
EnergyFireCost = 30000.0
MetalFireCost = 20000
ShowFireAngle = true
RoundsEachBurst = 7
RoundPeriod = 0.15
CutOffEffects = true
BeamDuration = 0.05
ReloadFramePeriod = ReloadTime/11
DisruptionBlocksFire = true
DoorCloseDelay = 1
AutofireCloseDoorTicks = DoorCloseDelay*25

CanOverheat = true
HeatPeriod = 1.8
CoolPeriod = 5
CoolPeriodOverheated = 7

dofile("effects/device_smoke.lua")
SmokeEmitter = StandardDeviceSmokeEmitter

NodeEffects =
{
	{
		NodeName = "Hardpoint0",
		EffectPath = "effects/weapon_overheated.lua",
		Automatic = false,
	},
}

Root =
{
	Name = "Machinegun",
	Angle = 0,
	Pivot = { 0, -0.37 },
	PivotOffset = { 0, 0 },
	Sprite = "mg-base",
	UserData = 0,
	
	ChildrenBehind =
	{
		{
			Name = "Head",
			Angle = 0,
			Pivot = { 0, 0 },
			PivotOffset = { 0, 0 },
			Sprite = "mg-head",
			UserData = 50,

			ChildrenInFront =
			{
				{
					Name = "Arm",
					Angle = 0,
					Pivot = { 0.09, 0.09 },
					Sprite = "mg-arm",
					PivotOffset = { 0, 0 },
					UserData = 50,
				},
				{
					Name = "Hardpoint0",
					Angle = 90,
					Pivot = { 0, 0 },
					PivotOffset = { 0, 0 },
				},
				{
					Name = "Chamber",
					Angle = 0,
					Pivot = { 0.165, -0.05 },
					PivotOffset = { 0, 0 },
				},
				{
					Name = "MuzzleFlash",
					Angle = 0,
					Pivot = { 0.6, 0 },
					PivotOffset = { 0, 0 },
					Sprite = "mg_flash",
					Visible = false,
				},
			},
		},
	},
	ChildrenInFront =
	{
	},
}
