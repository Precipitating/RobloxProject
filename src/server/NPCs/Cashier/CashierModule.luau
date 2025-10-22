local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local BadgeHandler = require(ServerScriptService.Server.BadgeHandler)
local NPCOutfit = require(ServerScriptService.Server.NPCs.NPCOutfit)
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local TalkModuleHelpers = require(ServerScriptService.Server.TalkModuleHelpers)
local GeneralRemotes = ReplicatedStorage.Remotes
local ItemsList = {}
local CashierModule = {}
local currentShoppingList = nil

local function CameraToCashier(player)
	local camPos = workspace.Shop.Cashier.CameraPos

	if camPos then
		GeneralRemotes.ChangeCameraSubject:FireClient(player, camPos.CFrame)
	else
		error("Cashier camera position not found.")
	end
end

local function FakeExitRoom(player)
	local hrp = player.Character.HumanoidRootPart
	local humanoid = player.Character.Humanoid
	local exitPos = workspace.Shop.SpawnLoc
	local hiddenPos = workspace.Shop.HiddenPos

	local speechTime = GeneralRemotes.PlayTTS:InvokeClient(
		player,
		"Thanks for your body, i'll use it well. The body swap will only work for 1 hour, so... heh heh... SEE YA, WANNA BE YAH!"
	)
	task.wait(speechTime)

	task.wait(2)
	humanoid:MoveTo(exitPos.Position)
	task.wait(1)
	GeneralRemotes.PlaySound:InvokeClient(player, "OpenDoor")
	hrp.CFrame = hiddenPos.CFrame
	GeneralRemotes.PlayTheme:FireClient(player, "CashierTheme")
end

function CashierModule.NPCFakeExit(player, customer, lastCustomer)
	local humanoid = customer:FindFirstChild("Humanoid")
	local hrp = customer:FindFirstChild("HumanoidRootPart")
	local exitPos = workspace.Shop.SpawnLoc
	local spawnPos = workspace:FindFirstChild("Shop"):FindFirstChild("CustomerSpawnPos")
	if not spawnPos then
		error("Customer spawn position ref not found!")
	end

	humanoid:MoveTo(exitPos.Position)
	humanoid.MoveToFinished:Wait()
	GeneralRemotes.PlaySound:InvokeClient(player, "OpenDoor")

	if lastCustomer then
		customer:Destroy()
	else
		hrp.CFrame = spawnPos.CFrame
	end
end

function CashierModule.Init(player)
	local hrp = player.Character.HumanoidRootPart
	hrp.CFrame = workspace.Shop.CashierModeInitialPos.CFrame

	GeneralRemotes.BlackFade:FireClient(player, 0, 0)
	CameraToCashier(player)
	task.wait(2)

	GeneralRemotes.BlackFade:FireClient(player, 2, 1)
	task.wait(1)

	-- player walks to door and leaves the room
	FakeExitRoom(player)

	-- enable cashier system
	local screen = workspace.Shop.Cashier.Counter.Register.Screen.SurfaceGui
	screen.Enabled = true

	-- get list of items and store in table
	for _, obj in ipairs(CollectionService:GetTagged("ShopItem")) do
		local price = obj:FindFirstChild("Price")
		local quantity = obj:FindFirstChild("Quantity")
		if price and quantity then
			table.insert(ItemsList, {
				Name = obj.Name,
				Price = price.Value,
				Quantity = quantity.Value,
			})
		end
	end
end

local function GetRandomItems()
	local itemsList = {}
	for _ = 1, math.random(10) do
		local randomIdx = math.random(1, #ItemsList)
		table.insert(itemsList, ItemsList[randomIdx])
	end

	currentShoppingList = itemsList
end

function CashierModule.CheckPrice()
	local total = 0
	if #currentShoppingList > 0 then
		for _, product in ipairs(currentShoppingList) do
			total = total + product.Price
		end
		return total
		--return string.format("%.2f", total)
	else
		return nil
	end
end

function CashierModule.Complete(player)
	print("Complete! Spawning asylum...")
	GeneralRemotes.BlackFade:FireClient(player, 0.5, 0)
	local asylum = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Cashier", "Asylum", nil)
	TalkModuleHelpers.SetCanTalk(true)
	task.wait(2)
	player.Character:FindFirstChild("HumanoidRootPart").CFrame = asylum:FindFirstChild("SpawnPos").CFrame
	GeneralRemotes.ChangeCameraSubject:FireClient(player, nil)
	GeneralRemotes.PlayTheme:FireClient(player, "Gloomy")
	GeneralRemotes.BlackFade:FireClient(player, 2, 1)
	GeneralRemotes.EnableControls:FireClient(player, "UI")
end

function CashierModule.NextCustomerNPC(customer)
	local humanoid = customer:FindFirstChild("Humanoid")
	local hrp = customer:FindFirstChild("HumanoidRootPart")

	-- change outfit
	NPCOutfit.RemoveOutfit(customer)
	NPCOutfit.ApplyRandomOutfit(customer)

	-- move to cashier point
	local cashierPosition = workspace.Shop:FindFirstChild("CashierModeInitialPos")
	humanoid:MoveTo(cashierPosition.Position)
	humanoid.MoveToFinished:Wait()
	task.wait(0.5)
	-- look towards cashier
	local goalCFrame = CFrame.new(cashierPosition.Position, cashierPosition.Position + vector.create(0, 0, -1))
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, { CFrame = goalCFrame })
	tween:Play()
	tween.Completed:Wait()
end

function CashierModule.NextCustomer(player, currentTime)
	GetRandomItems()

	if currentTime <= 0 then
		CashierModule.Complete(player)
		GeneralRemotes.DisconnectGUI:FireClient(player, "Cashier")
	end

	local customer = workspace:FindFirstChild("Customer")
	if not customer then
		customer = ServerHelperFunctions.SpawnModelAtPosition("NPCs", "Cashier", "Customer", nil)
	else
		CashierModule.NPCFakeExit(player, customer, false)
	end
	CashierModule.NextCustomerNPC(customer)

	local formattedItemList = ""
	local formattedPriceList = ""
	for _, product in ipairs(currentShoppingList) do
		formattedItemList ..= `{product.Name} x{product.Quantity}<br/>`
		formattedPriceList ..= `£{string.format("%.2f<br/>", product.Price)}`
	end

	GeneralRemotes.Cashier.UpdateScreen:FireClient(player, formattedItemList, formattedPriceList)
end

function CashierModule.FailedEvent(player)
	GeneralRemotes.DisconnectGUI:FireClient(player, "Cashier")
	GeneralRemotes.StopAllMusic:InvokeClient(player)
	local monster = workspace:FindFirstChild("Monster")
	local customer = workspace:FindFirstChild("Customer")

	if not monster and customer then
		CashierModule.NPCFakeExit(player, customer, true)
		monster = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Cashier", "Monster", nil)
	end

	local humanoid = monster:FindFirstChild("Humanoid")
	local hrp = monster:FindFirstChild("HumanoidRootPart")

	-- move to cashier point
	local cashierPosition = workspace.Shop:FindFirstChild("CashierModeInitialPos")
	humanoid:MoveTo(cashierPosition.Position)
	humanoid.MoveToFinished:Wait()
	task.wait(0.5)
	-- look towards cashier
	local goalCFrame = CFrame.new(cashierPosition.Position, cashierPosition.Position + vector.create(0, 0, -1))
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, { CFrame = goalCFrame })
	tween:Play()
	tween.Completed:Wait()

	-- speak
	GeneralRemotes.PlaySound:InvokeClient(player, "CashierManager")
	local connection
	connection = GeneralRemotes.SoundEnded.OnServerEvent:Connect(function(_, finishedName)
		if finishedName == "CashierManager" then
			connection:Disconnect()
			connection = nil

			-- tween to camera
			local cashierPos = workspace.Shop.Cashier.Cashier.PrimaryPart.Position
			local monsterTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
			local goal = { Position = cashierPos }
			local monsterTween = TweenService:Create(hrp, monsterTweenInfo, goal)
			monsterTween:Play()
			GeneralRemotes.BlackFade:FireClient(player, 0.5, 0)
			BadgeHandler.awardBadge(player, 2719901366655803)
			GeneralRemotes.Rejoin:FireClient(player, 7)
		end
	end)
end

function CashierModule.Start(player)
	print("Cashier mode start!")
	local timeLeft = CollectionService:GetTagged("CashierTimeLeft")[1]
	GeneralRemotes.InitializeGUI:FireClient(player, "Cashier")
	CashierModule.NextCustomer(player, tonumber(timeLeft.Text))
end

return CashierModule
