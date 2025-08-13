function Merge(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

Merge(Device,
{
	control_panel = L"Kontroll-Zentrum",
	control_panelTip2 = L"Zum Erstellen eines Gerätes mit zusammenhängender Strukturen notwendig",
	control_panelTip3 = L"Benötigt: Upgrade Center",
})
