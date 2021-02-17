local auraSkills = {}

local serverStore = game:GetService("ServerStorage")

local repStore = game:GetService("ReplicatedStorage")



local events = repStore:WaitForChild("Events")

local gameData = require(serverStore:WaitForChild("GameData"):WaitForChild("DataStore"))

local gameSettings = require(serverStore:WaitForChild("GameData"):WaitForChild("GameSettings"))



local serverEvents = serverStore:WaitForChild("ServerEvents")



local function isProcced(chance)

	local num = math.random(0,1000)/1000

	if num < chance then

		return true

	end

	return false

end





local function setAbilityEffects(skill, tier, level)

	-- setup skill data

	for i, v in pairs(skill.Stats[tier]) do

		skill.Stats[i] = v + skill["Stats Increase"][tier][i] * (level)

	end

	

end



local function ignite(player, chest, skill, tier, level, curDmg)

	if not isProcced(skill.Stats.Chance) then return curDmg end

	chest.ApplyModifier:Fire(player, "Ignite", skill.Stats.Duration, skill.Stats.Damage)	

	--for i = 0, skill.Stats.Duration do

	--	chest.TakeDamage:Fire(skill.Stats.Damage, player, nil, true, nil)	

	--	wait(1)

	--end

	return curDmg

end



local function midas(player, chest, skill, tier, level, curDmg)

	if not isProcced(skill.Stats.Chance) then return curDmg end

	local coins = skill.Stats.Coins

	gameData.AddCoins(player, coins)

	return curDmg

end



local function crystal(player, chest, skill, tier, level, curDmg)

	if not isProcced(skill.Stats.Chance) then return curDmg end

	local crystals = skill.Stats.Crystals

	gameData.AddCrystals(player, crystals)

	return curDmg

end





local function swiper(player, chest, skill, tier, level, curDmg)

	if not isProcced(skill.Stats.Chance) then return curDmg end

	local reduce = skill.Stats.Damage

	wait(0.5)

	chest.TakeDamage:Fire(curDmg*reduce, player, nil, true, nil, Color3.fromRGB(54, 54, 54))

	return curDmg

end



local function luck(player, chest, skill, tier, level, curDmg)

	if not isProcced(skill.Stats.Chance) then return curDmg end

	chest.ApplyModifier:Fire(player, "Luck", skill.Stats.Duration)	

	return curDmg

end



local function zap(player, chest, skill, tier, level, curDmg)

	if not isProcced(skill.Stats.Chance) then return curDmg end

	local dmg = skill.Stats.Damage

	wait(0.5)

	chest.TakeDamage:Fire(dmg, player, nil, true, nil, Color3.fromRGB(252, 255, 65))

	return curDmg

end



local function drench(player, chest, skill, tier, level, curDmg)

	if not isProcced(skill.Stats.Chance) then return curDmg end

	chest.ApplyModifier:Fire(player, "Drench", skill.Stats.Duration, skill.Stats.Multiply)	

	return curDmg

end



local function crit(player, chest, skill, tier, level, curDmg)

	if not isProcced(skill.Stats.Chance) then return curDmg end

	local crit = skill.Stats.Multiply

	chest.TakeDamage:Fire(curDmg*crit, player, nil, false, nil, Color3.fromRGB(134, 36, 36))

	return 0

end



local function invigorate(player, chest, skill, tier, level, curDmg)

	if not isProcced(skill.Stats.Chance) then return curDmg end

	gameData.GiveMana(player, skill.Stats.Energy)

	return curDmg

end



local function weaken(player, chest, skill, tier, level, curDmg)

	if not isProcced(skill.Stats.Chance) then return curDmg end

	chest.TakeDamage:Fire(chest.Data.Health.Value*skill.Stats.Amount, player, nil, false, nil, Color3.fromRGB(124, 124, 124))

	return 0

end



local function freeze(player, chest, skill, tier, level, curDmg)

	if not isProcced(skill.Stats.Chance) then return curDmg end

	chest.ApplyModifier:Fire(player, "Freeze", skill.Stats.Duration)

	return curDmg	

end



local function deathStroke(player, chest, skill, tier, level, curDmg)

	if not isProcced(skill.Stats.Chance) then return curDmg end

	chest.TakeDamage:Fire(chest.Data.Health.Value*0.5, player, nil, false, nil, Color3.fromRGB(134, 128, 123))

	return 0 

end



local function pickMaster(player, chest, skill, tier, level, curDmg)

	if not isProcced(skill.Stats.Chance) then return curDmg end

	chest.TakeDamage:Fire(chest.Data.MaxHealth.Value, player, nil, false, nil, Color3.fromRGB(134, 60, 128))

	return 0 

end



-- {thread, function} set thread to true if you want the function to keep executing

local skillFunctions = {

	["Ignite"] 			= {false, ignite},

	["Drench"] 			= {false, drench} ,

	["Freeze"] 			= {false, freeze},

	["Crit"]   			= {false, crit},

	["Midas"]  			= {false, midas},

	["Swiper"] 			= {false, swiper},

	["Zap"] 			= {false, zap},

	["Death Stroke"] 	= {false, deathStroke},

	["Pick Master"] 	= {false, pickMaster},

	["Weaken"] 			= {false, weaken},

	["Crystalizer"]		= {false, crystal},

	["Invigorate"]		= {false, invigorate},

	["Luck"]			= {false, luck}

}



local function deepCopy(original)

	local copy = {}

	for k, v in pairs(original) do

		if type(v) == "table" then

			v = deepCopy(v)

		end

		copy[k] = v

	end

	return copy

end



function auraSkills.doAura(player, skill, tier, level, currentDamage, chest)

	

	-- iterate over all aura skills

	local doFunction = skillFunctions[skill]

	

	local skillData = deepCopy(gameSettings.getAuraSkillInfo(nil, skill))

	

	setAbilityEffects(skillData, tier, level)



	

	if doFunction then

		if doFunction[1] == true then

			-- thread the function

			local thread = coroutine.create(doFunction[2]) -- thread some tick damage

			coroutine.resume(thread, player, chest, skillData, tier, level, currentDamage)

		else

			currentDamage = doFunction[2](player, chest, skillData, tier, level, currentDamage)

		end

	end

	

	return currentDamage

	

end



return auraSkills
