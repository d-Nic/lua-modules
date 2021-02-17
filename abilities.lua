local abilities = {}

local serverStore = game:GetService("ServerStorage")

local repStore = game:GetService("ReplicatedStorage")



local events = repStore:WaitForChild("Events")

local gameData = require(serverStore:WaitForChild("GameData"):WaitForChild("DataStore"))

local GameSettings = require(serverStore:WaitForChild("GameData"):WaitForChild("GameSettings"))

local abilityCooldown = events:WaitForChild("abilityCooldown")

local abilityShop = events:WaitForChild("abilityShop")

local abilityShow = events:WaitForChild("abilityShow")

local notify = require(serverStore:WaitForChild("GameData"):WaitForChild("Notifications"))

local abilityParts = serverStore:WaitForChild("AbilityParts")

local tweenService = game:GetService("TweenService")



local serverEvents = serverStore:WaitForChild("ServerEvents")

local lvlEvents = serverEvents:WaitForChild("LevelUp")

local sounds = repStore:WaitForChild("Sounds")



local abilityEvent = lvlEvents:WaitForChild("Ability")

local potions = require(serverStore:WaitForChild("GameData"):WaitForChild("Potions"))



local abilityTextSize = UDim2.new(0.07,0,0.07,0)

local slotCooldowns = {{}, {}, {}}



local questQuery = serverEvents:WaitForChild("QuestQuery")

--====================================================================

-- Ability Methods (do ability animations/damage here)

-- takeDamage(amount, plr, guiID, staticPos, textSize, textCol)

--====================================================================





local function fireball(player, chest, stats, col)

	--print("Doing fireball on ", chest)

	local dmg = math.random(stats["Min Damage"], stats["Max Damage"])

	

	local fireballModel = abilityParts:FindFirstChild("Fireball")

	local newModel = fireballModel:Clone()

	game:GetService("Debris"):AddItem(newModel, 5)

	



	

	-- + diffVec*3

	local posVec = CFrame.new(player.Character.HumanoidRootPart.Position + Vector3.new(0,5,0), chest.Part.Position)

	newModel:SetPrimaryPartCFrame(posVec)



	newModel.Parent = game.Workspace

	



	

	local goal = {}

	goal.Position = chest.Part.Position

	for i, v in pairs(newModel:GetChildren()) do

		local tween = tweenService:Create(v, TweenInfo.new(0.7), goal)

		tween:Play()

	end

	

	local toPlay = sounds.Fireball

	local sound = toPlay:Clone()

	sound.Parent = newModel.PrimaryPart

	sound:Play()

	local dmgEnchance = potions.PotionStatus(player, "Power Potion")

	local toSend = dmg

	if dmgEnchance then

		toSend = dmg + (dmg*(dmgEnchance/100))

	end

	wait(0.5)

	chest.TakeDamage:Fire(toSend, player, nil, true, abilityTextSize, col)

	wait(1)

	newModel:Destroy()

end



local function acid(player, chest, stats, col)

	--print("Doing acid")

	local dmg = stats["Burn Damage"]

	local ticks = stats["Burn Duration"]

	local acidModel = abilityParts:FindFirstChild("Acid")

	local newModel = acidModel:Clone()

	game:GetService("Debris"):AddItem(newModel, 30)

	

	newModel.Part1.Size = chest.Part.Size*Vector3.new(1,0,1) + Vector3.new(7,0.01,7)

	newModel.Part2.Size = chest.Part.Size*Vector3.new(1,0,1) + Vector3.new(7,0.4,7)

	newModel:SetPrimaryPartCFrame(CFrame.new(chest.Part.Position*Vector3.new(1,0,1) + Vector3.new(0,11.05, 0 )))

	newModel.Parent = game.Workspace

	

	local toPlay = sounds.Acid

	local sound = toPlay:Clone()

	sound.Looped = true

	sound.Parent = newModel.PrimaryPart

	sound:Play()

	

	for i = 0, ticks do

		local toFire = chest:FindFirstChild("TakeDamage") 

		if toFire then  

			local dmgEnchance = potions.PotionStatus(player, "Power Potion")

			local toSend = dmg

			if dmgEnchance then

				toSend = dmg + (dmg*(dmgEnchance/100))

			end

			chest.TakeDamage:Fire(toSend, player, nil, true, abilityTextSize, col)

		else

			break

		end

		wait(2)

	end

	

	newModel:Destroy()

end





local function dagger(player, chest, stats, col)

	--print("Doing dagger")

	local respawnChance = stats["Duplicate Chance"]

	local dmg = stats.Damage

	local dmgEnchance = potions.PotionStatus(player, "Power Potion")

	local toSend = dmg

	if dmgEnchance then

		toSend = dmg + (dmg*(dmgEnchance/100))

	end

	chest.TakeDamage:Fire(toSend, player, nil, true, abilityTextSize, col)



	local toPlay = sounds.Knife

	

	local daggerModel = abilityParts:FindFirstChild("Dagger")

	local newModel = daggerModel:Clone()

	game:GetService("Debris"):AddItem(newModel, 5)

	local posVec = CFrame.new(player.Character.HumanoidRootPart.Position + Vector3.new(0,5,0), chest.Part.Position)

	newModel:SetPrimaryPartCFrame(posVec)

	newModel.Parent = game.Workspace



	local targetPos = Instance.new("Part")

	targetPos.Anchored = true

	targetPos.CanCollide = false

	targetPos.Position = chest.Part.Position

	targetPos.Orientation = Vector3.new(math.random(-10,10),180,180)

	targetPos.Parent = game.Workspace

	targetPos.Transparency = 1

	game:GetService("Debris"):AddItem(targetPos, 5)

	

	local DAGGER_SPEED = 0.4

	local MAX_DAGGERS = 10

	

	local goal = {}

	goal.CFrame = targetPos.CFrame

	

	local tween = tweenService:Create(newModel.Main, TweenInfo.new(DAGGER_SPEED), goal)

	tween:Play()

	local playSound = toPlay:Clone()

	playSound.Parent = newModel.PrimaryPart

	playSound:Play()

	

	local daggerCount = 1

	

	while chest do

		wait(1)

		local num = math.random(1,100)/100

		

		if num < respawnChance then

			local newModel = daggerModel:Clone()

			game:GetService("Debris"):AddItem(newModel, 5)

			if not chest:FindFirstChild("Part") then break end

			local posVec = CFrame.new(player.Character.HumanoidRootPart.Position + Vector3.new(0,5,0), chest.Part.Position)

			newModel:SetPrimaryPartCFrame(posVec)

			newModel.Parent = game.Workspace



			local targetPos2 = Instance.new("Part")

			targetPos2.Anchored = true

			targetPos2.CanCollide = false

			targetPos2.Position = chest.Part.Position

			targetPos2.Orientation = Vector3.new(math.random(-10,10),180,180)

			targetPos2.Parent = game.Workspace

			targetPos2.Transparency = 1

			game:GetService("Debris"):AddItem(targetPos2, 5)

			

			local goal = {}

			goal.CFrame = targetPos2.CFrame

			local playSound = toPlay:Clone()

			playSound.Parent = newModel

			playSound:Play()

			

			local tween = tweenService:Create(newModel.Main, TweenInfo.new(DAGGER_SPEED), goal)

			tween:Play()

			

			chest.TakeDamage:Fire(toSend, player, nil, true, abilityTextSize, col)

			daggerCount += 1

			if daggerCount >= MAX_DAGGERS then

				break

			end

		else

			break

		end

	end



	targetPos:Destroy()

	

	 

end



local function punch(player, chest, stats, col)

	--print("Doing punch")

	local dmg = math.random(stats["Min Damage"], stats["Max Damage"])

	

	local punchModel = abilityParts:FindFirstChild("Punch")

	local newModel = punchModel:Clone()

	game:GetService("Debris"):AddItem(newModel, 30)



	--newModel:MoveTo(chest.Part.Position + Vector3.new(0,10,0))

	newModel.Parent = game.Workspace

	local goal = {}

	goal.Position = chest.Part.Position + Vector3.new(0,-10,0)

	for i, v in pairs(newModel:GetChildren()) do

		v.Position = chest.Part.Position  + Vector3.new(0,15,0)

	end

	

	local woosh = sounds.Woosh

	local wClone = woosh:Clone()

	wClone.Parent = newModel.PrimaryPart

	wClone:Play()

	

	local toPlay = sounds.Punch

	local sound = toPlay:Clone()

	sound.Parent = newModel.PrimaryPart

	sound:Play()

	

	for i, v in pairs(newModel:GetChildren()) do

		local tween = tweenService:Create(v, TweenInfo.new(1), goal)

		tween:Play()

	end

	

	wait(0.8)

	local dmgEnchance = potions.PotionStatus(player, "Power Potion")

	local toSend = dmg

	if dmgEnchance then

		toSend = dmg + (dmg*(dmgEnchance/100))

	end

	chest.TakeDamage:Fire(toSend, player, nil, true, abilityTextSize, col)

	wait(2)

	newModel:Destroy()	

end



local function hammer(player, chest, stats, col)

	local dmg = stats.Damage

	local model = abilityParts:FindFirstChild("Hammer")

	local newModel = model:Clone()

	newModel.Parent = game.Workspace

	newModel:SetPrimaryPartCFrame(CFrame.new(chest.Part.Position + Vector3.new(0,0,5)))

	--local goal = {}

	--goal.Position = chest.Part.Position + Vector3.new(0,-5,0)

	--goal.Orientation = Vector3.new(-90,0,0)

	

	for i = 0, 10 do

		

		newModel:SetPrimaryPartCFrame(newModel.PrimaryPart.CFrame*CFrame.fromEulerAnglesXYZ(math.rad(-9),0,0))

		wait()

	end

	

	--local tween = tweenService:Create(newModel.PrimaryPart, TweenInfo.new(1.5), goal)

	--tween:Play()

	--wait(1)



	chest.TakeDamage:Fire(dmg, player, nil, true, abilityTextSize, col)		

	wait(1.5)

	newModel:Destroy()

end



local function rock(player, chest, stats, col)

	--print("Doing rock")

	local dmg = stats.Damage

	local rockModel = abilityParts:FindFirstChild("Rock")

	local newModel = rockModel:Clone()

	newModel.Parent = game.Workspace

	newModel.Position = chest.Part.Position + Vector3.new(0,10,0)

	local goal = {}

	goal.Position = chest.Part.Position + Vector3.new(0,-13,0)

	

	local tween = tweenService:Create(newModel, TweenInfo.new(1.5), goal)

	tween:Play()

	wait(1)

	newModel:Destroy()

	chest.TakeDamage:Fire(dmg, player, nil, true, abilityTextSize, col)	

end



local function laser(player, chest, stats, col)

	--print("Doing laser")

	local dmg = stats["Tick Damage"]

	for i = 0, 5 do

		local lStart = Instance.new("Part")

		lStart.Size = Vector3.new(1,1,1)

		lStart.Color = Color3.fromRGB(57, 121, 18)

		lStart.Material = Enum.Material.Neon

		lStart.Shape = Enum.PartType.Ball

		lStart.CanCollide = false

		lStart.Anchored = true

		lStart.Parent = game.Workspace

		local cX = chest.Part.Position.X

		local cY = chest.Part.Position.Y

		local cZ = chest.Part.Position.Z

		lStart.Position = Vector3.new(cX + math.random(-5,5), cY + math.random(0,8), cZ + math.random(-5,5))

		game:GetService("Debris"):AddItem(lStart, 3)

		wait(0.3)

		local lPart = Instance.new("Part")

		lPart.Size = Vector3.new(0.2,0.2,7)

		lPart.Transparency = 0.85

		local goal = {}

		goal.Transparency = 0

		goal.Size = Vector3.new(1.3,1.3,7)

		

		lPart.Material = Enum.Material.Neon

		lPart.CanCollide = false

		lPart.Anchored = true

		lPart.Color = Color3.fromRGB(121, 255, 38)

		lPart.CFrame = CFrame.new((lStart.Position+lStart.Position)/2, chest.Part.Position)

		

		local tween = tweenService:Create(lPart,TweenInfo.new(1), goal)

		tween:Play()



		lPart.Parent = game.Workspace

		game:GetService("Debris"):AddItem(lPart, 3)

		chest.TakeDamage:Fire(dmg, player, nil, true, abilityTextSize, col)	

		wait(0.1)

	end

end



local function lightning(player, chest, stats, col)

	--print("Doing laser")

	local dmg = stats.Damage

	for i = 0, 10 do

		chest.TakeDamage:Fire(dmg, player, nil, true, abilityTextSize, col)	

		wait(3)

	end

end



local function missile(player, chest, stats, col)

	--print("Doing laser")

	local dmg = stats.Damage

	for i = 0, 3 do

		chest.TakeDamage:Fire(dmg, player, nil, true, abilityTextSize, col)	

		wait(2)

	end

end



local function plasma(player, chest, stats, col)

	--print("Doing laser")

	local dmg = stats.Damage

	for i = 0, 5 do

		chest.TakeDamage:Fire(dmg, player, nil, true, abilityTextSize, col)	

		wait(0.3)

	end

end



local function nuke(player, chest, stats, col)

	--print("Doing laser")

	local dmg = stats.Damage



	chest.TakeDamage:Fire(dmg, player, nil, true, abilityTextSize, col)	

		



end



local function blackhole(player, chest, stats, col)

	--print("Doing laser")

	local dmg = stats.Damage

	for i = 0, 7 do

		chest.TakeDamage:Fire(dmg, player, nil, true, abilityTextSize, col)	

		wait(0.3)

	end

end





-- Set abilit

local abilityLevels = GameSettings.abilityLevels



local abilityLevelsReverse = {}

for i, v in pairs(abilityLevels) do

	abilityLevelsReverse[v] = i

end



local abilityOrder = {

	"Fireball",

	"Acid Pit",

	"Punch",

	"Dagger Throw",	

	"Hammer Hit",

	"Rock Drop",

	"Laser",

	--"Lightning Storm",

	--"Missile Strike",

	--"Plasma",

	--"Nuke",

	--"Black Hole"

}



local abilityStats = {

	["Fireball"] = {

		["Name"] = "Fireball",

		["Cooldown"] = 7,

		["Mana"] = 10,

		["Function"] = fireball,

		["Level"] = abilityLevelsReverse["Fireball"],

		["Description"] = "A powerful fireball that crushes chest dealing a random amount of damage in a range",

		["Stats"] = {

			["Min Damage"] = 2,

			["Max Damage"] = 4

		},

		["Col"] = Color3.fromRGB(255, 107, 33)

	},

	["Acid Pit"] = {

		["Name"] = "Acid Pit",

		["Cooldown"] = 50,

		["Mana"] = 30,

		["Function"] = acid,

		["Description"] = "A pit of acid that slowly burns away at chests",

		["Level"] = abilityLevelsReverse["Acid Pit"],

		["Stats"] = {

			["Burn Damage"] = 4,

			["Burn Duration"] = 8,

		},

		["Col"] = Color3.fromRGB(173, 255, 41)

	},

	["Punch"] = {

		["Name"] = "Punch",

		["Cooldown"] = 45,

		["Mana"] = 100,

		["Function"] = punch,

		["Description"] = "Release your frustration against the chests by giving them a good damage-dealing punch",

		["Level"] = abilityLevelsReverse["Punch"], -- 7

		["Stats"] = {

			["Min Damage"] = 25,

			["Max Damage"] = 50,

		},

		["Col"] = Color3.fromRGB(255, 255, 73)

	},

	["Dagger Throw"] = {

		["Name"] = "Dagger Throw",

		["Cooldown"] = 40,

		["Mana"] = 175,

		["Function"] = dagger,

		["Description"] = "Shoots a dagger that deals damage and has a chance to spawn another dagger",

		["Level"] = abilityLevelsReverse["Dagger Throw"], -- 10

		["Stats"] = {

			["Damage"] = 35, -- 30,

			["Duplicate Chance"] = 0.3

		},

		["Col"] = Color3.fromRGB(167, 71, 184)

	},

	["Hammer Hit"] = {

		["Name"] = "Hammer Hit",

		["Cooldown"] = 35,

		["Mana"] = 215,

		["Function"] = hammer,

		["Description"] = "Hits a chest with a solid hammer",

		["Level"] = abilityLevelsReverse["Hammer Hit"],

		["Stats"] = {

			["Damage"] = 95,

		},

		["Col"] = Color3.fromRGB(83, 76, 42)

	},

	["Rock Drop"] = {

		["Name"] = "Rock Drop",

		["Cooldown"] = 35,

		["Mana"] = 230,

		["Function"] = rock,

		["Description"] = "Digs up pieces of earth to drop on top of a chest and deal damage",

		["Level"] = abilityLevelsReverse["Rock Drop"],

		["Stats"] = {

			["Damage"] = 150

		},

		["Col"] = Color3.fromRGB(154, 79, 44)

	},

	["Laser"] = {

		["Name"] = "Laser",

		["Cooldown"] = 50,

		["Mana"] = 300,

		["Function"] = laser,

		["Description"] = "Charges up a laser that deals damage to chests",

		["Level"] = abilityLevelsReverse["Laser"],

		["Stats"] = {

			["Charge time"] = 8,

			["Tick Damage"] = 80,

			["Tick Duration"] = 5,

			--["Total Damage"] = 375,

		},

		["Col"] = Color3.fromRGB(15, 184, 63)

	},

	["Lightning Storm"] = {

		["Name"] = "Lightning Storm",

		["Cooldown"] = 35,

		["Mana"] = 30,

		["Function"] = lightning,

		["Description"] = "Summons lightning to strike chests",

		["Level"] = 28,

		["Stats"] = {

			["Damage"] = 80,

		},

		["Col"] = Color3.fromRGB(255, 255, 0)

	},

	["Missile Strike"] = {

		["Name"] = "Missile Strike",

		["Cooldown"] = 35,

		["Mana"] = 30,

		["Function"] = missile,

		["Description"] = "Brings in a missile strike",

		["Level"] = 22,

		["Stats"] = {

			["Damage"] = 80,

		},

		["Col"] = Color3.fromRGB(227, 13, 13)

	},



	["Plasma"] = {

		["Name"] = "Plasma",

		["Cooldown"] = 35,

		["Mana"] = 0,

		["Function"] = plasma,

		["Description"] = "Charges up a plasma beam",

		["Level"] = 25,

		["Stats"] = {

			["Damage"] = 30,

		},

		["Col"] = Color3.fromRGB(254, 34, 232)

	},

	["Nuke"] = {

		["Name"] = "Nuke",

		["Cooldown"] = 35,

		["Mana"] = 30,

		["Function"] = nuke,

		["Description"] = "Hits a chest with a nuke strike",

		["Level"] = 30,

		["Stats"] = {

			["Damage"] = 80,

		},

		["Col"] = Color3.fromRGB(254, 178, 0)

	},	

	["Black Hole"] = {

		["Name"] = "Black Hole",

		["Cooldown"] = 75,

		["Damage"] = 10,

		["Mana"] = 30,

		["Function"] = blackhole,

		["Description"] = "Summons a black hole",

		["Level"] = 40,

		["Stats"] = {

			["Damage"] = 80,

		},

		["Col"] = Color3.fromRGB(0, 0, 0)

	},

}



	

--====================================================================

-- Ability Management

--====================================================================



function abilities.abilityMana(ability)

	if not abilityStats[ability] then return 99999 end

	return abilityStats[ability].Mana

end



function abilities.doAbility(player, abilitySlot)

	if abilitySlot < 0 or abilitySlot > 3 then 

		return false

	end

	

	local ability = gameData.GetEquipAbility(player, abilitySlot)

	if abilityStats[ability] then

		-- check player has required mana here

		if slotCooldowns[abilitySlot][player.Name] == false then

			notify.send(player, "Ability " .. abilitySlot .. " on cooldown!", "Notify")

			return

		end

		local chest = gameData.GetChest(player)

		if chest == nil then

			notify.send(player, "You need to be unlocking a chest!", "Notify")

			return

		end

		if not chest:FindFirstChild("TakeDamage") then

			gameData.SetChest(player, nil)

			notify.send(player, "You need to be unlocking a chest!", "Notify")

			return

		end

		local plrMana = gameData.GetMana(player)

		if plrMana < abilityStats[ability].Mana then

			notify.send(player, "Not enough energy!", "Notify")

			return

		end 

		

		slotCooldowns[abilitySlot][player.Name] = false

		abilityCooldown:FireClient(player, abilitySlot, abilityStats[ability].Cooldown-1)

		gameData.UseMana(player, abilityStats[ability].Mana)		

		--pcall(abilityStats[ability].Function, player, chest, abilityStats[ability].Stats, abilityStats[ability].Col)--abilityStats[ability].Function(player, chest, abilityStats[ability].Stats)

		--abilityStats[ability].Function(player, chest, abilityStats[ability].Stats, abilityStats[ability].Col)

		

		-- run threaded

		local thread = coroutine.create(abilityStats[ability].Function) -- thread some tick damage

		coroutine.resume(thread, player, chest, abilityStats[ability].Stats, abilityStats[ability].Col)

		

		-- test run without thread

		--abilityStats[ability].Function(player, chest, abilityStats[ability].Stats, abilityStats[ability].Col)

		

		questQuery:Fire(player, "Ability", ability)

		wait(abilityStats[ability].Cooldown)

		slotCooldowns[abilitySlot][player.Name] = true

	end

end



function abilities.showAbilities(player)

	

	local ab1 = gameData.GetEquipAbility(player, 1)

	local ab2 = gameData.GetEquipAbility(player, 2)

	local ab3 =  gameData.GetEquipAbility(player, 3)

	

	abilityShow:FireClient(player, 1, ab1, abilities.abilityMana(ab1))

	abilityShow:FireClient(player, 2, ab2, abilities.abilityMana(ab2))

	abilityShow:FireClient(player, 3, ab3, abilities.abilityMana(ab3))



end



function abilities.equipAbility(player, ability, slot)

	if slot < 0 or slot > 3 then

		return

	end

	--print("equipping ability", ability)

	local ab = abilityStats[ability]

	if ab then

		local plrLevel = gameData.GetLevel(player)

		if plrLevel >= ab.Level then

			--print("equpping ab", ability)

			if gameData.GetEquipAbility(player, slot) == ability then

				return

			end

			local isEquipped = gameData.AbilityIsEquipped(player, ability)

			if isEquipped then

				--print("Ability already equipped", isEquipped)

				abilityShow:FireClient(player, isEquipped, "None")

				gameData.EquipAbility(player, isEquipped, "None")

			end

			abilityShow:FireClient(player, slot, ability, abilities.abilityMana(ability))

			gameData.EquipAbility(player, slot, ability)

		end

	end

end

abilityShow.OnServerEvent:Connect(abilities.equipAbility)



function abilities.abilitiesShopInit(player)

	local playerLevel = gameData.GetLevel(player)

	--print("Initing player ability shop lvl:", playerLevel)

	abilityShop:FireClient(player, playerLevel, abilityOrder, abilityStats)

	

end

abilityEvent.Event:Connect(abilities.abilitiesShopInit)





return abilities
