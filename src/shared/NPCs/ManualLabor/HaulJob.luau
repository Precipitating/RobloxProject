local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GeneralRemotes = ReplicatedStorage.Remotes
local MovementConnection = nil
local MB1Connection = nil
local LaunchPosition = nil
local ItemHolderConn = nil
local StackPlacePos = Vector3.new(-247.9, 249.836, 65.5)
local HoldPosIncrement = 0
local Timelimit = 60
local SpawnCooldown = 5
local Score = 0
local ItemsHolding = {}

local HaulJob = {}

function HaulJob.ServerInit(player)
	local ServerScriptService = game:GetService("ServerScriptService")

	local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
	local model = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "ManualLabor", "HaulJob", nil)
	GeneralRemotes.ChangeCameraSubject:FireClient(player, model:FindFirstChild("CameraPos").CFrame)
	LaunchPosition = model:FindFirstChild("Van"):FindFirstChild("LaunchPos")
	local pallet = model:FindFirstChild("pallet")
	local playerModel = model:FindFirstChild("Player")
	local receiveItemCollider = playerModel:FindFirstChild("ReceiveItemCollider")

	-- move player
	MovementConnection = Remotes.MousePosition.OnServerEvent:Connect(function(_, mousePos)
		local pivot = playerModel:GetPivot()
		if mousePos then
			local targetPivot = CFrame.new(pivot.Position.X, pivot.Position.Y, mousePos.Z) * (pivot - pivot.Position)

			local lerpAlpha = 0.2
			local smoothPivot = pivot:Lerp(targetPivot, lerpAlpha)
			playerModel:PivotTo(smoothPivot)
		end
	end)

	-- place on pallet
	MB1Connection = Remotes.MB1Down.OnServerEvent:Connect(function(_)
		print("MB1 Down")
		local pivot = playerModel:GetPivot()

		if (pallet.Position - pivot.Position).Magnitude < 10 and #ItemsHolding > 0 then
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
			end

			StackPlacePos = StackPlacePos + Vector3.new(0, 1, 0)
		end
	end)

	-- hold item
	ItemHolderConn = receiveItemCollider.Touched:Connect(function(hit)
		if CollectionService:HasTag(hit, "HaulItem") and #ItemsHolding < 6 then
			local holdPos = playerModel:FindFirstChild("HoldPos")
			print("Item should be held.")
			--hit.CFrame = holdPos.CFrame * CFrame.new(HoldPosIncrement, 0, 0)
			hit.Position = holdPos.Position + Vector3.new(0, HoldPosIncrement, 0)
			local weldConstraint = hit:FindFirstChild("WeldConstraint")
			if weldConstraint then
				weldConstraint.Part0 = receiveItemCollider
			end
			HoldPosIncrement += 1
			table.insert(ItemsHolding, hit)
		end
	end)

	for i = 1, Timelimit do
		local randSpawnTime = math.random(1, SpawnCooldown * 10) / 10
		if i % 10 == 0 then
			SpawnCooldown = SpawnCooldown - 0.1
		end

		task.delay(randSpawnTime, function()
			local item = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "ManualLabor", "RiceBag", nil)
			item.Position = LaunchPosition.Position
			item.Velocity = Vector3.new(0, math.random(30, 100), math.random(15, 30))
		end)
		task.wait(1)
	end

	print("game end")
	ItemHolderConn:Disconnect()
	MB1Connection:Disconnect()
	MovementConnection:Disconnect()
	Remotes.HaulJob.GameFinished:FireClient(player)
end

-- mouse to world position for moving the player left/right
local function GetMouseWorldPosition(player)
	local camera = workspace.CurrentCamera
	local mouseLocation = UserInputService:GetMouseLocation()
	local unitRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
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
	-- wait for server to spawn models
	local model = workspace:WaitForChild("HaulJob")
	local player = Players.LocalPlayer

	-- movement logic
	MovementConnection = RunService.RenderStepped:Connect(function()
		local mouseToWorldPos = GetMouseWorldPosition(player)
		Remotes.MousePosition:FireServer(mouseToWorldPos)
	end)

	local mouse = player:GetMouse()
	-- place item down on pallet logic
	MB1Connection = mouse.Button1Down:Connect(function()
		Remotes.MB1Down:FireServer()
	end)

	local conn

	conn = Remotes.HaulJob.GameFinished.OnClientEvent:Connect(function()
		conn:Disconnect()
		MB1Connection:Disconnect()
		MovementConnection:Disconnect()
	end)
end

return HaulJob
