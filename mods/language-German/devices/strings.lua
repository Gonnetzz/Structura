function Merge(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

Merge(Device,
{
	control_panel = L"Kontroll-Zentrum",
	control_panelTip2 = L"Zum Erstellen eines Gerätes mit zusammenhängender Strukturen notwendig",
	control_panelTip3 = L"Benötigt: Upgrade Center",
	
	upgrade_test_device_log_structureTip = L"Log Structure",

    upgrade_create_houseTip = L"Create House",
    upgrade_create_weapon20mmTip = L"Create 20mm",
    upgrade_create_weaponcanonTip = L"Create Canon",
    upgrade_create_weaponfirebeamTip = L"Create Firebeam",
    upgrade_create_weaponlaserTip = L"Create Laser"
})

