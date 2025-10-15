local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GeneralRemotes = ReplicatedStorage.Remotes
local IS_SERVER = RunService:IsServer()
local IS_CLIENT = RunService:IsClient()
local ServerScriptService = IS_SERVER and game:GetService("ServerScriptService") or nil
local TalkModuleHelpers = IS_SERVER and require(ServerScriptService.Server.TalkModuleHelpers) or nil
local CurrencyHandler = IS_SERVER and require(ServerScriptService.Server.CurrencyHandler) or nil
local ServerHelperFunctions = IS_SERVER and require(ServerScriptService.Server.ServerHelperFunctions) or nil
local MovementConnection = nil
local MB1Connection = nil
local LaunchPosition = nil
local ItemHolderConn = nil
local StackPlacePos = Vector3.new(-247.9, 249.836, 65.5)
local HoldPosIncrement = 0
local Timelimit = 60
local SpawnCooldown = 5
local Score = 0
local CarryLimit = 6
local StunTime = 3
local Stunned = false
local ItemNames = {
	{ Name = "RiceBag", Chance = 0.8 }, -- 80%
	{ Name = "PC", Chance = 0.2 }, -- 20%
}
local ItemsHolding = {}

local HaulJob = {}

local function GameFinished(player, model)
	-- disconnect server connections
	ItemHolderConn:Disconnect()
	MB1Connection:Disconnect()
	MB1Connection = nil
	ItemHolderConn = nil

	-- add the money (£2 per item)
	local finalScore = Score * 2
	print(finalScore)
	CurrencyHandler.AddMoney(player, finalScore)

	-- along with client events
	Remotes.HaulJob.GameFinished:FireClient(player)
	-- to prevent invocation error, remove this server connection after client mouse position connection is gone
	task.wait(0.5)
	MovementConnection:Disconnect()
	MovementConnection = nil

	-- reset variables
	Score = 0
	StackPlacePos = Vector3.new(-247.9, 249.836, 65.5)
	HoldPosIncrement = 0
	LaunchPosition = nil
	Stunned = false
	table.clear(ItemsHolding)

	-- reset camera back to player
	GeneralRemotes.ChangeCameraSubject:FireClient(player, nil)
	GeneralRemotes.EnableControls:FireClient(player, nil)
	TalkModuleHelpers.SetCanTalk(true)

	model:Destroy()
end

local function ChooseItemToSpawn()
	local roll = math.random()
	local cumulative = 0
	local chosenItem

	for _, entry in ipairs(ItemNames) do
		cumulative += entry.Chance
		if roll <= cumulative then
			chosenItem = entry.Name
			break
		end
	end

	return chosenItem
end

-- game loop blocks thread
local function GameLoop(player, clockLabel)
	-- game loop timer
	for i = Timelimit, 0, -1 do
		local randSpawnTime = math.random(1, SpawnCooldown * 10) / 10
		if i % 10 == 0 then
			SpawnCooldown = SpawnCooldown - 0.1
		end
		clockLabel.Text = tostring(i)

		task.delay(randSpawnTime, function()
			local item =
				ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "ManualLabor", ChooseItemToSpawn(), nil)
			-- ensures client simulates the item physics for reduced/no stuttery laggy movement
			item:SetNetworkOwner(player)
			if item and LaunchPosition then
				item.Position = LaunchPosition.Position
				item.Velocity = Vector3.new(0, math.random(30, 100), math.random(15, 30))
			end
		end)
		task.wait(1)
	end
end

local function DropAllItems(playerModel)
	for _, item in ipairs(ItemsHolding) do
		local weldConstraint = item:FindFirstChild("WeldConstraint")
		if not weldConstraint then
			return
		end
		weldConstraint.Part0 = nil
	end
	local receiveCollider = playerModel:FindFirstChild("ReceiveItemCollider")
	if not receiveCollider then
		return
	end
	receiveCollider.Position = receiveCollider.Position - Vector3.new(0, HoldPosIncrement, 0)
	HoldPosIncrement = 0
	table.clear(ItemsHolding)
end

local function StunPlayer(playerModel)
	if Stunned then
		return
	end
	Stunned = true
	local stunParticle = playerModel:FindFirstChild("Head"):FindFirstChild("StunnedParticle")
	local receiveCollider = playerModel:FindFirstChild("ReceiveItemCollider")
	if not stunParticle or not receiveCollider then
		return
	end
	stunParticle.Enabled = true

	task.delay(StunTime, function()
		Stunned = false
		stunParticle.Enabled = false
	end)
end

local function CatchItem(player, playerModel, receiveItemCollider)
	-- hold item
	ItemHolderConn = receiveItemCollider.Touched:Connect(function(hit)
		if Stunned then
			return
		end
		if not CollectionService:HasTag(hit, "HaulItem") then
			-- hit a bad item, remove all carried items
			DropAllItems(playerModel)
			StunPlayer(playerModel)
			GeneralRemotes.PlaySound:InvokeClient(player, "MetalPipe")
			print("Stunned")
			return
		end
		-- make sure it's physically colliding, not welded or player body
		if not hit:IsA("BasePart") then
			return
		end
		if #ItemsHolding >= CarryLimit then
			-- holding too much items
			DropAllItems(playerModel)
			StunPlayer(playerModel)
			GeneralRemotes.PlaySound:InvokeClient(player, "BoneSnap")

			print("Overloaded")
			return
		end

		local holdPos = playerModel:FindFirstChild("HoldPos")
		print("Item should be held.")
		hit.Position = holdPos.Position + Vector3.new(0, HoldPosIncrement, 0)
		receiveItemCollider.Position = receiveItemCollider.Position + Vector3.new(0, 1, 0)
		local weldConstraint = hit:FindFirstChild("WeldConstraint")
		if weldConstraint then
			weldConstraint.Part0 = playerModel.HoldPos
		end
		HoldPosIncrement += 1
		table.insert(ItemsHolding, hit)
		GeneralRemotes.PlaySound:InvokeClient(player, "Rustle")
	end)
end

local function PlaceOnPallet(player, playerModel, pallet, receiveItemCollider)
	-- place on pallet
	MB1Connection = Remotes.MB1Down.OnServerEvent:Connect(function(_)
		local pivot = playerModel:GetPivot()
		if (pallet.Position - pivot.Position).Magnitude > 10 then
			return
		end

		if Stunned then
			return
		end

		if #ItemsHolding <= 0 then
			return
		end
		print("MB1 Down")
		local topItem = ItemsHolding[#ItemsHolding]
		table.remove(ItemsHolding, #ItemsHolding)
		HoldPosIncrement = math.max(HoldPosIncrement - 1, 0)

		local weld = topItem:FindFirstChild("WeldConstraint")
		if weld then
			weld.Part0 = pallet
		end

		print("can place down")
		if topItem then
			topItem.Position = StackPlacePos
			Score = Score + 1
			GeneralRemotes.PlaySound:InvokeClient(player, "Ping")
		end

		StackPlacePos = StackPlacePos + Vector3.new(0, 1, 0)
		receiveItemCollider.Position = receiveItemCollider.Position - Vector3.new(0, 1, 0)
	end)
end

local function PlayerMouseMove(playerModel)
	-- move player
	MovementConnection = Remotes.MousePosition.OnServerEvent:Connect(function(_, mousePos)
		if Stunned then
			return
		end
		local pivot = playerModel:GetPivot()
		if not mousePos then
			return
		end
		local targetPivot = CFrame.new(pivot.Position.X, pivot.Position.Y, mousePos.Z) * (pivot - pivot.Position)

		local lerpAlpha = 0.2
		local smoothPivot = pivot:Lerp(targetPivot, lerpAlpha)
		playerModel:PivotTo(smoothPivot)
	end)
end

function HaulJob.ServerInit(player)
	local model = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "ManualLabor", "HaulJob", nil)
	LaunchPosition = model:FindFirstChild("Van"):FindFirstChild("LaunchPos")
	local pallet = model:FindFirstChild("pallet")
	local playerModel = model:FindFirstChild("Player")
	local receiveItemCollider = playerModel:FindFirstChild("ReceiveItemCollider")
	local clockLabel =
		model:FindFirstChild("Clock"):FindFirstChild("BG"):FindFirstChild("SurfaceGui"):FindFirstChild("TimeLabel")

	-- change camera view to game
	GeneralRemotes.ChangeCameraSubject:FireClient(player, model:FindFirstChild("CameraPos").CFrame)

	PlayerMouseMove(playerModel)
	CatchItem(player, playerModel, receiveItemCollider)
	PlaceOnPallet(player, playerModel, pallet, receiveItemCollider)
	GameLoop(player, clockLabel)

	-- won't run until GameLoop is finished
	print("game end")
	GameFinished(player, model)
end

-- mouse to world position for moving the player left/right
local function GetMouseWorldPosition(player)
	local camera = workspace.CurrentCamera
	local mouseLocation = UserInputService:GetMouseLocation()
	local unitRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

	-- raycast from mouse position to detect the raycast wall responsible for movement
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { player.Character }
	params.FilterType = Enum.RaycastFilterType.Exclude
	local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 100, params)

	if result and CollectionService:HasTag(result.Instance, "RaycastWall") then
		return result.Position
	else
		return nil
	end
end

function HaulJob.ClientInit()
	local StarterPlayer = game:GetService("StarterPlayer")

	local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)

	-- wait for server to spawn models
	task.wait(1)
	workspace:WaitForChild("HaulJob")
	local player = Players.LocalPlayer

	SoundModule.PlayTheme("Saloon")

	-- mouse movement logic
	local MousePositionConn = RunService.RenderStepped:Connect(function()
		local mouseToWorldPos = GetMouseWorldPosition(player)
		Remotes.MousePosition:FireServer(mouseToWorldPos)
	end)

	local mouse = player:GetMouse()
	-- place item down on pallet logic
	local MB1Clicked = mouse.Button1Down:Connect(function()
		Remotes.MB1Down:FireServer()
	end)

	-- game finished disconnect connections client
	Remotes.HaulJob.GameFinished.OnClientEvent:Once(function()
		MousePositionConn:Disconnect()
		MB1Clicked:Disconnect()
		SoundModule.PlayTheme("Main")
	end)
end

return HaulJob
