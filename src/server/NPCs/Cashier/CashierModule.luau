local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextToSpeech = require(ReplicatedStorage.Shared.TextToSpeech)
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local ItemsList = {}
local CashierModule = {}

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
	local ttsHandle = TextToSpeech.GetHandle()

	TextToSpeech.Speak(
		"Thanks for your body, i'll use it well. The body swap will only work for 1 hour, so... heh heh... SEE YA, WANNA BE YAH!"
	)
	ttsHandle.Ended:Wait()
	task.wait(2)
	humanoid:MoveTo(exitPos.Position)
	task.wait(1)
	GeneralRemotes.PlaySound:InvokeClient(player, "OpenDoor")
	hrp.CFrame = hiddenPos.CFrame
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
			table.insert(ItemsList, { obj.Name, price.Value, quantity.Value })
		end
	end
end

return CashierModule
