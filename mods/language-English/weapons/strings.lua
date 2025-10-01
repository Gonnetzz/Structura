function Merge(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

Merge(Weapon,
{
	patchgunner = L"Mod Helper",
	patchgunnerTip2 = L"No function, has to be there for the mod to work",
})