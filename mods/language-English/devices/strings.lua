function Merge(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

Merge(Device,
{
	control_panel = L"Control Panel",
	control_panelTip2 = L"Used to create a device from multi-tile structures",
	control_panelTip3 = L"Requires: Upgrade Centre",
})
