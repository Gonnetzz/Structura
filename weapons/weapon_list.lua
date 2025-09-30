dofile("ui/uihelper.lua")
dofile("scripts/type.lua")

BuildQueueConcurrent = {}
OriginalBuildTimes = {}

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

function UpdateWeapons(upgradeNames)
    for _, name in ipairs(upgradeNames) do
        local target = string.sub(name, 3)

        local baseWeapon = FindWeapon(target)
        if baseWeapon then
            baseWeapon.Prerequisite = nil
            baseWeapon.Enabled = false
			OriginalBuildTimes[target] = baseWeapon.BuildTimeComplete or 10
        end
    end
end

local weaponNames = { "laser", "firebeam", "cannon", "cannon20mm" }
if dlc1Var_Active then
	local maggy = FindWeapon("magnabeam")
	local howi = FindWeapon("howitzer")
	if maggy then
		table.insert(weaponNames, "magnabeam")
	end
	if howi then
		table.insert(weaponNames, "howitzer")
	end
end


local upgradeNames = {}
for _, name in ipairs(weaponNames) do
	local tmp = FindWeapon(name)
    if tmp then
        table.insert(upgradeNames, "to" .. name)
    end
end

UpdateWeapons(upgradeNames)

local gunner = FindWeapon("machinegun")
local patchgunner = DeepCopy(gunner)

if patchgunner then
	patchgunner.SaveName = "patchgunner"
	patchgunner.BuildTimeComplete = 0
	patchgunner.Enabled = true
	patchgunner.FileName = path .. "/weapons/tmpgunner.lua"
	patchgunner.MetalCost = 0
	patchgunner.EnergyCost = 0
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
		
		local target = string.sub(name, 3)
		local originalBuildTime = OriginalBuildTimes[target] or 10
		local upgradeDuration = originalBuildTime - 10
		if upgradeDuration < 0.1 then 
			upgradeDuration = 0.1 
		end
		tmpgunner.Upgrades = {
            {
                Enabled = true,
                SaveName = target,
                MetalCost = 0,
                EnergyCost = 0,
                BuildDuration = upgradeDuration,
            }
        }

        table.insert(Weapons, tmpgunner)
    end
end


