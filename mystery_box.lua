local mysteryBox = {}



local repStore = game:GetService("ReplicatedStorage")

local events = repStore:WaitForChild("Events")

local activateMysteryBox = events:WaitForChild("ActivateMysteryBox")



local serverStore = game:GetService("ServerStorage")

local prestigeColors = repStore:WaitForChild("PrestigeColors")

local potionImages = repStore:WaitForChild("PotionImages")

local rewardHandler = require(serverStore:WaitForChild("GameData"):WaitForChild("RewardHandler"))

local tweenService = game:GetService("TweenService")

local inventory = require(serverStore:WaitForChild("GameData"):WaitForChild("Inventory"))



local rewardsModule = require(script.BoxRewards)

local boxRewards = rewardsModule.Rewards





local function colouriseGui(frame, rarity, imgGui)

	

	--print(frame, rarity, imgGui)

	frame.Bot.BackgroundColor3 = prestigeColors[rarity].Dark.Value -- bottom border

	frame.Bot.Lighter.BackgroundColor3 = prestigeColors[rarity].Lighter.Value -- bottom inside

	frame.Bot.Triangle.ImageColor3 = prestigeColors[rarity].Dark.Value -- bottom border

	frame.Bot.TriangleLighter.ImageColor3 = prestigeColors[rarity].Lighter.Value -- bottom inside

	

	--local col2 = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))

	frame.Top.BackgroundColor3 = prestigeColors[rarity].Dark.Value -- top border

	frame.Top.Lighter.BackgroundColor3 = prestigeColors[rarity].Lighter.Value -- top inside

	frame.Top.Triangle.ImageColor3 = prestigeColors[rarity].Dark.Value -- top border

	frame.Top.TriangleLighter.ImageColor3 = prestigeColors[rarity].Lighter.Value -- top inside

	

	--local col3 = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))

	imgGui.ImageColor3 = prestigeColors[rarity].Dark.Value -- border of middle

	imgGui.ImageBorder.ImageColor3 = prestigeColors[rarity].Lighter.Value -- middle



end



local function showReward(rGui, reward)

	local imGui

	if reward.Reward == "Coins" then

		rGui.Data.Reward.Coins.Visible = true

		rGui.Data.Reward.Crystals.Visible = false

		rGui.Data.Reward.Reward.Visible = false

		imGui = rGui.Data.Reward.Coins

		rGui.Data.Reward.Bot.ShadowText.Text = "$"..reward.Amount

		rGui.Data.Reward.Bot.ShadowText.CoreText.Text = "$"..reward.Amount

	elseif reward.Reward == "Crystals" then

		rGui.Data.Reward.Crystals.Visible = true

		rGui.Data.Reward.Reward.Visible = false

		rGui.Data.Reward.Coins.Visible = false

		imGui = rGui.Data.Reward.Crystals

		rGui.Data.Reward.Bot.ShadowText.Text = "$".. reward.Amount

		rGui.Data.Reward.Bot.ShadowText.CoreText.Text ="$".. reward.Amount

	elseif reward.Reward == "Potion" then

		rGui.Data.Reward.Reward.Visible = true

		rGui.Data.Reward.Crystals.Visible = false

		rGui.Data.Reward.Coins.Visible = false

		imGui = rGui.Data.Reward.Reward

		rGui.Data.Reward.Bot.ShadowText.Text = reward.Amount.Name

		rGui.Data.Reward.Bot.ShadowText.CoreText.Text = reward.Amount.Name



		local potionImage = potionImages:FindFirstChild(reward.Amount.Name .. reward.Amount.Size)

		if potionImage then

			imGui.ImageBorder.Image1.Image = potionImage.Value

		end

	end

	colouriseGui(rGui.Data.Reward, reward.Rarity, imGui)

end



local function chooseReward(boxType)

	local num = math.random(1,100)

	local chosen

	local curChance = 0

	for i, v in pairs(boxRewards[boxType]) do



		curChance = curChance + v.Chance

		if num <= curChance then

			return boxRewards[boxType][i]

		end



	end	

	return boxRewards[boxType][1]

end



local function tweenQuestionMark(boxPart)

	local qMark = boxPart.QuestionMark.Frame

	

	wait(0.3)

	--print("Doing rtween")

	-- Tween rotation to 25

	local rGoal = {}

	rGoal.Rotation = 30

	local rTween = tweenService:Create(qMark, TweenInfo.new(0.5), rGoal)

	rTween:Play()

	wait(0.6)

	

	--print("Doing ltween")

	-- Tween left 360 twice and make size smaller

	local lGoal = {}

	lGoal.Rotation = -720

	lGoal.Size = UDim2.new(0,0,0,0)

	local lTween = tweenService:Create(qMark, TweenInfo.new(2), lGoal)

	lTween:Play()

	wait(1.5)

	

	

end



function mysteryBox.Use(player, boxId)

	print("Mystery box", boxId)

	local count = inventory.getKeyCount(player, boxId)

	if count <= 0 then

		--notify.send(player, "Naughty!", "Error")

		return 

	end

	inventory.ConsumeKey(player, boxId)

	local boxPart = script:FindFirstChild(boxId)

	if boxPart == nil then

		return 

	end

	if boxRewards[boxId] == nil then

		return

	end

	--local boxType = "Paper" -- get box info from player inv

	local boxRewardCount = #boxRewards[boxId]

	--print("Created box")

	local boxPart = boxPart:Clone()

	--game:GetService("Debris"):AddItem(boxPart, 7)

	--boxPart.Size = Vector3.new(2,2,2)

	--boxPart.CanCollide = false

	--boxPart.Anchored = true

	boxPart:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0,-2,-7)))  

	local rGui = script.RewardGui:Clone()

	

	rGui.Data.Position = UDim2.new(0,0,1,0)

	

	rGui.Parent = boxPart.PrimaryPart

	boxPart.Parent = game.Workspace

	

	tweenQuestionMark(boxPart)

	

	rGui.Data:TweenPosition(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 1)

	

	-- choose actual reward here

	local actualReward = chooseReward(boxId)

	

	for i = 1, 12 do

		

		local count = i%(boxRewardCount) + 1

		--print(count)

		local reward = boxRewards[boxId][count]

		--print(reward)

		showReward(rGui, reward)



		wait(0.4)

	end	

	

	showReward(rGui, actualReward)

	rewardHandler.giveReward(player, {actualReward.Reward, actualReward.Amount})

	wait(3)

	boxPart:Destroy()

end



activateMysteryBox.OnServerEvent:Connect(mysteryBox.Use)



return mysteryBox
