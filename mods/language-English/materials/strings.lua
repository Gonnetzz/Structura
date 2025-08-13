function Merge(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

Merge(Material,
{
	lead = L"Lead",
	leadTip2 = L"Used in multi-tile structures",

    uran = L"Uranium",
    uranTip2 = L"Used in multi-tile structures",
})
