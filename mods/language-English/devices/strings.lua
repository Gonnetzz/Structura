function Merge(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

Merge(Device,
{
	control_panel = L"Control Panel",
	control_panelTip2 = L"Used to create a device from multi-tile structures",
	control_panel_upgrade = L"Check and Convert House Struct",
	
	ecore = L"Energized Core",
	ecoreTip2 = L"Used to create Laserweaponry",
	kcore = L"Kinetic Core",
	kcoreTip2 = L"Used to create Kineticweaponry",
	
	checklaser    = L"Check Laser",
    buildlaser    = L"Build Laser",
    convlaser     = L"Convert Laser",

    checkfirebeam = L"Check Firebeam",
    buildfirebeam = L"Build Firebeam",
    convfirebeam  = L"Convert Firebeam",

    checkmagnabeam = L"Check Magnabeam",
    buildmagnabeam = L"Build Magnabeam",
    convmagnabeam  = L"Convert Magnabeam",

    checkcannon = L"Check Cannon",
    buildcannon = L"Build Cannon",
    convcannon  = L"Convert Cannon",

    checkcannon20mm = L"Check Cannon20mm",
    buildcannon20mm = L"Build Cannon20mm",
    convcannon20mm  = L"Convert Cannon20mm",
	
    checkhowitzer = L"Check Howitzer",
    buildhowitzer = L"Build Howitzer",
    convhowitzer  = L"Convert Howitzer",

	
	test_device = L"TestDevice",
	test_deviceTip2 = L"Used for creating Structs",
	test_device_log_structure = L"Log Structure In Chat",
	create_house = L"Create House",
	create_weaponfirebeam = L"Create WeaponFirebeam",
    create_weaponlaser = L"Create WeaponLaser",
	create_weaponcannon = L"Create WeaponCannon",
    create_weapon20mm = L"Create Weapon20mm",
	
	patchgunner = L"Mod Helper",
	patchgunnerTip2 = L"No function, has to be there for the mod to work",
})