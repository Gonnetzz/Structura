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


Projectile = "machinegun"
ReloadTime = 1000.5
EnergyFireCost = 3000000.0
MetalFireCost = 2000000
ShowFireAngle = true
RoundsEachBurst = 0
ReloadFramePeriod = ReloadTime/11
DisruptionBlocksFire = true
DoorCloseDelay = 1
AutofireCloseDoorTicks = DoorCloseDelay*25

dofile("effects/device_smoke.lua")
SmokeEmitter = StandardDeviceSmokeEmitter


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
			UserData = 50,

			ChildrenInFront =
			{
				{
					Name = "Hardpoint0",
					Angle = 90,
					Pivot = { 0, 0 },
					PivotOffset = { 0, 0 },
				},
			},
		},
	},
}
