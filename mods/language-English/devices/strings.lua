function Merge(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

Merge(Device,
{
	control_panel = L"Control Panel",
	control_panelTip2 = L"Used to create a device from multi-tile structures",
	control_panelTip3 = L"Requires: Upgrade Centre",
	
	upgrade_test_device_log_structureTip = L"Log Structure",
	
	ecore = L"Energized Core",
	ecoreTip2 = L"Used to create Laserweaponry",
	ecore_upgrade = L"Firebeam",
	
	kcore = L"Kinetic Core",
	kcoreTip2 = L"Used to create Kineticweaponry",

	upgrade_create_house = L"Create House",
    upgrade_create_houseTip2 = L"Create House",
	upgrade_create_houseTip3 = L"Create House",
    upgrade_create_weapon20mmTip3 = L"Create 20mm",
    upgrade_create_weaponcanonTip = L"Create Canon",
    upgrade_create_weaponfirebeamTip = L"Create Firebeam",
    upgrade_create_weaponlaserTip = L"Create Laser"
})