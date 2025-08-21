dofile(path .. "/scripts/Math.lua")
--[[
Angle is based on prev brace and constructed direction
]]

StructureDefinitions = {
	House1 = {
		links = {
            { from = "A", to = 1, material = "uran", length = 100.00, angle = -90.00 },
            { from = "A", to = 2, material = "backbracing", length = 141.42, angle = -45.00 },
            { from = "B", to = 1, material = "backbracing", length = 141.42, angle = -135.00 },
            { from = "B", to = 2, material = "uran", length = 100.00, angle = -90.00 },
            { from = 1, to = 2, material = "backbracing", length = 100.00, angle = 0.00 },
            { from = 1, to = 3, material = "armour", length = 70.71, angle = -45.00 },
            { from = 2, to = 3, material = "armour", length = 70.71, angle = -135.00 },
		}
	},
	House = {
		mirrorable = true,
        requiredDevices = {
			{ onLink = {from=3, to=4}, saveName="battery" },
		},
		links = {
			{ from = "A", to = 1, material = "uran", length = 100.00, angle = -90.00 },
			{ from = "A", to = 2, material = "backbracing", length = 141.42, angle = -45.00 },
			{ from = "B", to = 1, material = "backbracing", length = 141.42, angle = -135.00 },
			{ from = "B", to = 2, material = "uran", length = 100.00, angle = -90.00 },
			{ from = 1, to = 2, material = "backbracing", length = 100.00, angle = 0.00 },
			{ from = 1, to = 3, material = "armour", length = 70.71, angle = -45.00 },
			{ from = 2, to = 3, material = "armour", length = 70.71, angle = -135.00 },
			{ from = 2, to = 4, material = "uran2", length = 70.71, angle = -45.00 },
			{ from = 3, to = 4, material = "bracing", length = 100.00, angle = 0.00 },
		}
	},
}
