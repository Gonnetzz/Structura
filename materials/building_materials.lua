table.insert(Sprites, ButtonSprite("lead_context", "det/lead_Bud", nil, nil, nil, nil, path))
table.insert(Sprites, DetailSprite("lead_detail", "lead_det", path))

table.insert(Sprites,
{
    Name = "lead_icon",
    States =
    {
        Normal = { Frames = {{ texture = path .. "/ui/textures/det/lead_mat-A.tga", bottom = 0.664 },},},
        Rollover = { Frames = {{ texture = path .. "/ui/textures/det/lead_mat-R.tga", bottom = 0.664 },},},
        Pressed = { Frames = {{ texture = path .. "/ui/textures/det/lead_mat-S.tga", bottom = 0.664 },},},
        Disabled = { Frames = {{ texture = path .. "/ui/textures/det/lead_mat-D.tga", bottom = 0.664 },},},
    },
})

table.insert(Sprites, 
{
    Name = "lead_strut",
    States =
    {
        Normal =
        {
            Frames =
            {
                { texture = path .. "/materials/Lead.tga", duration = 0.3 },
                { texture = path .. "/materials/Lead.tga", duration = 0.2 },
                { texture = path .. "/materials/Lead.tga", duration = 0.2 },
                { texture = path .. "/materials/Lead.tga", duration = 0.3 },
                mipmap = true,
                repeatS = true,
            },
        },
    },
})

armour = FindMaterial("armour")

table.insert(Materials, IndexOfMaterial("armour") + 1, InheritMaterial(armour,
{
	SaveName = "lead",
	Icon = "lead_icon",
	Detail = "lead_detail",
	Sprite = "lead_strut",
	Context = "lead_context",
	Stiffness = 320000,
	MaxCompression = 0.95,
	MaxExpansion = 1.05,
	Mass = 0.25,
	HitPoints = 350,
	AbsorptionMomentumThreshold = 0,
	ReflectionMomentumThreshold = 800,
	PenetrationMomentumThreshold = 2000,
	BeamPenetrationBlockDist = 120,
	MetalBuildCost = 0.9,
	MetalRepairCost = 0.9,
	MetalReclaim = 0.5,
	EnergyBuildCost = 0.75,
	EnergyRepairCost = 0.75,
	BuildTime = 6,
	ScrapTime = 2,
	BuildEffect = "effects/build_armor.lua",
	DestroyEffect = "effects/armor_destroy.lua",
	FullExtrusion = true,
}))