dofile("scripts/forts.lua")
table.insert(Sprites, ButtonSprite("lead_context", "context/lead_mat", nil, nil, nil, nil, path))
table.insert(Sprites, DetailSprite("lead_detail", "lead_det", path))
table.insert(Sprites, ButtonSprite("uran_context", "context/uran_mat", nil, nil, nil, nil, path))
table.insert(Sprites, DetailSprite("uran_detail", "uran_det", path))
table.insert(Sprites, ButtonSprite("testmat_context", "context/test_mat", nil, nil, nil, nil, path))
table.insert(Sprites, DetailSprite("testmat_detail", "test_det", path))

table.insert(Sprites,
{
    Name = "lead_icon",
    States =
    {
        Normal =   { Frames = {{ texture = path .. "/ui/textures/HUD/lead_mat-A.tga", bottom = 0.664 },},},
        Rollover = { Frames = {{ texture = path .. "/ui/textures/HUD/lead_mat-R.tga", bottom = 0.664 },},},
        Pressed =  { Frames = {{ texture = path .. "/ui/textures/HUD/lead_mat-S.tga", bottom = 0.664 },},},
        Disabled = { Frames = {{ texture = path .. "/ui/textures/HUD/lead_mat-D.tga", bottom = 0.664 },},},
    },
})
table.insert(Sprites,
{
    Name = "uran_icon",
    States =
    {
        Normal =   { Frames = {{ texture = path .. "/ui/textures/HUD/uran_mat-A.tga", bottom = 0.664 },},},
        Rollover = { Frames = {{ texture = path .. "/ui/textures/HUD/uran_mat-R.tga", bottom = 0.664 },},},
        Pressed =  { Frames = {{ texture = path .. "/ui/textures/HUD/uran_mat-S.tga", bottom = 0.664 },},},
        Disabled = { Frames = {{ texture = path .. "/ui/textures/HUD/uran_mat-D.tga", bottom = 0.664 },},},
    },
})
table.insert(Sprites,
{
	Name = "testmat_icon",
	States =
	{
		Normal   = { Frames = {{ texture = path .. "/ui/textures/HUD/test_mat-A.tga", bottom = 0.664 },},},
		Rollover = { Frames = {{ texture = path .. "/ui/textures/HUD/test_mat-R.tga", bottom = 0.664 },},},
		Pressed  = { Frames = {{ texture = path .. "/ui/textures/HUD/test_mat-S.tga", bottom = 0.664 },},},
		Disabled = { Frames = {{ texture = path .. "/ui/textures/HUD/test_mat-D.tga", bottom = 0.664 },},},
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
table.insert(Sprites, 
{
	Name = "testmat_strut",
	States =
	{
		Normal =
		{
			Frames =
			{
				{ texture = path .. "/materials/test.tga", duration = 0.3 },
				{ texture = path .. "/materials/test.tga", duration = 0.2 },
				{ texture = path .. "/materials/test.tga", duration = 0.2 },
				{ texture = path .. "/materials/test.tga", duration = 0.3 },
				mipmap = true,
				repeatS = true,
			},
		},
	},
})
table.insert(Sprites, 
{
    Name = "uran_strut",
    States =
    {
        Normal =
        {
            Frames =
            {
                { texture = path .. "/materials/uran/0001.png" },
                { texture = path .. "/materials/uran/0002.png" },
                { texture = path .. "/materials/uran/0003.png" },
                { texture = path .. "/materials/uran/0004.png" },
                { texture = path .. "/materials/uran/0005.png" },
                { texture = path .. "/materials/uran/0006.png" },
                { texture = path .. "/materials/uran/0007.png" },
                { texture = path .. "/materials/uran/0008.png" },
                { texture = path .. "/materials/uran/0009.png" },
                { texture = path .. "/materials/uran/0010.png" },
                { texture = path .. "/materials/uran/0011.png" },
                { texture = path .. "/materials/uran/0012.png" },
                { texture = path .. "/materials/uran/0013.png" },
                { texture = path .. "/materials/uran/0014.png" },
                { texture = path .. "/materials/uran/0015.png" },
                { texture = path .. "/materials/uran/0016.png" },
				
                duration = 0.1,
				blendColour = false,
				blendCoordinates = false,
				mipmap = true,
				repeatS = true,
            },
			NextState = "Normal",
        },
    },
})
table.insert(Sprites, 
{
    Name = "uran_strut2",
    States =
    {
        Normal =
        {
            Frames =
            {
                { texture = path .. "/materials/uran2/0001.png" },
                { texture = path .. "/materials/uran2/0002.png" },
                { texture = path .. "/materials/uran2/0003.png" },
                { texture = path .. "/materials/uran2/0004.png" },
                { texture = path .. "/materials/uran2/0005.png" },
                { texture = path .. "/materials/uran2/0006.png" },
                { texture = path .. "/materials/uran2/0007.png" },
                { texture = path .. "/materials/uran2/0008.png" },
                { texture = path .. "/materials/uran2/0009.png" },
                { texture = path .. "/materials/uran2/0010.png" },
                { texture = path .. "/materials/uran2/0011.png" },
                { texture = path .. "/materials/uran2/0012.png" },
                { texture = path .. "/materials/uran2/0013.png" },
                { texture = path .. "/materials/uran2/0014.png" },
                { texture = path .. "/materials/uran2/0015.png" },
                { texture = path .. "/materials/uran2/0016.png" },
				
                duration = 0.1,
				blendColour = false,
				blendCoordinates = false,
				mipmap = true,
				repeatS = true,
            },
			NextState = "Normal",
        },
    },
})


bracing = FindMaterial("bracing")
armour = FindMaterial("armour")

table.insert(Materials, IndexOfMaterial("armour") + 1, InheritMaterial(bracing,
{
	SaveName = "test_material",
	Icon = "testmat_icon",
	Detail = "testmat_detail",
	Sprite = "testmat_strut",
	Context = "testmat_context",
	Enabled = false,
	ShowInEditor = true,
}))
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

table.insert(Materials, IndexOfMaterial("armour") + 1, InheritMaterial(armour,
{
	SaveName = "uran",
	Icon = "uran_icon",
	Detail = "uran_detail",
	Sprite = "uran_strut",
	Context = "uran_context",
	KeySpriteByDamage = false,
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
table.insert(Materials, IndexOfMaterial("armour") + 1, InheritMaterial(armour,
{
	SaveName = "uran2",
	Icon = "uran_icon",
	Detail = "uran_detail",
	Sprite = "uran_strut2",
	Context = "uran_context",
	KeySpriteByDamage = false,
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
--[[
local materialsToClone = {
    "bracing", "backbracing", "armour", "door", "rope", "portal", "shield",
    "lead", "uran", "uran2", "test_material"
}

for _, materialName in ipairs(materialsToClone) do
    local originalMaterial = FindMaterial(materialName)
    if originalMaterial then
        local freeMaterial = DeepCopy(originalMaterial)
        freeMaterial.SaveName = materialName .. "_free"
        
        freeMaterial.MetalBuildCost = 0
        freeMaterial.EnergyBuildCost = 0
        freeMaterial.MetalRepairCost = 0
        freeMaterial.EnergyRepairCost = 0
        freeMaterial.MetalReclaim = 0
        freeMaterial.EnergyReclaim = 0

        freeMaterial.Enabled = false
        
        table.insert(Materials, freeMaterial)
        --Log("Created free clone: " .. freeMaterial.SaveName)
    else
        Log("Warning: Could not find material to clone: " .. materialName)
    end
end--]]