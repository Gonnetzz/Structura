function Merge(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

Merge(Material,
{
	lead = L"Blei",
	leadTip2 = L"Für mutli-tile Strukturen benutztbar",

    uran = L"Uranium",
    uranTip2 = L"Für mutli-tile Strukturen benutztbar",
})
