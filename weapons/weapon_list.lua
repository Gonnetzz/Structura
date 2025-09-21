dofile("ui/uihelper.lua")
dofile("scripts/type.lua")

BuildQueueConcurrent = {}

StandardMaxUpAngle = 20
ButtonSpriteBottom = 0.664
GroupButtonSpriteBottom = 0.80973

function FindWeapon(saveName)
	for k, v in ipairs(Weapons) do
		if v.SaveName == saveName then
			return v
		end
	end
	return nil
end

function IndexOfWeapon(saveName)
	for k,v in ipairs(Weapons) do
		if v.SaveName == saveName then
			return k
		end
	end
	return #Weapons
end

function CreateWeaponCopies(upgradeNames)
    for _, name in ipairs(upgradeNames) do
        local target = string.sub(name, 3)

        local baseWeapon = FindWeapon(target)
        if baseWeapon then
            local cpyWeapon = DeepCopy(baseWeapon)

            cpyWeapon.SaveName = target .. "cpy"
            cpyWeapon.Prerequisite = nil
			cpyWeapon.Enabled = false

            table.insert(Weapons, cpyWeapon)
        end
    end
end


--local upgradeNames = { "tolaser", "tofirebeam", "tocannon", "to20mm" }
local upgradeNames = { "tolaser", "tofirebeam", "tocannon"}
CreateWeaponCopies(upgradeNames)

local gunner = FindWeapon("machinegun")
local patchgunner = DeepCopy(gunner)

if patchgunner then
	patchgunner.SaveName = "patchgunner"
	patchgunner.BuildTimeComplete = 0
	patchgunner.Enabled = true
	patchgunner.Upgrades = {}
    for _, name in ipairs(upgradeNames) do
        table.insert(patchgunner.Upgrades, {
            Enabled = false,
            SaveName = name,
            MetalCost = 0,
            EnergyCost = 0,
			BuildDuration = 0.1,
        })
    end
	table.insert(Weapons, patchgunner)
end

for _, name in ipairs(upgradeNames) do
    local tmpgunner = DeepCopy(gunner)
    if tmpgunner then
        tmpgunner.SaveName = name
        tmpgunner.FileName = path .. "/weapons/tmpgunner.lua"
        tmpgunner.Enabled = false
		tmpgunner.BuildTimeComplete = 2
		
		local target = string.sub(name, 3)
		tmpgunner.Upgrades = {
            {
                Enabled = true,
                SaveName = target .. "cpy",
                MetalCost = 0,
                EnergyCost = 0,
                BuildDuration = 0.1,
            }
        }

        table.insert(Weapons, tmpgunner)
    end
end


