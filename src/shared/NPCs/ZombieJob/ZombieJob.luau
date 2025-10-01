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
local CurrencyHandler = IS_SERVER and require(ServerScriptService.Server.CurrencyHandler) or nil
local ServerHelperFunctions = IS_SERVER and require(ServerScriptService.Server.ServerHelperFunctions) or nil
local MovementConnection = nil
local MB1Connection = nil
local Timelimit = 60
local SpawnCooldown = 10
local CanShoot = true
local GunDamage = 30
local ZombiesKilled = 0
local ZombieJob = {}

local function GameFinished(player, model)
	-- disconnect server connections
	MB1Connection:Disconnect()
	MB1Connection = nil

	-- add the money (£5 per kill)
	local finalScore = ZombiesKilled * 5
	print(finalScore)
	CurrencyHandler.AddMoney(player, finalScore)

	-- along with client events
	Remotes.ZombieJob.GameFinished:FireClient(player)
	-- to prevent invocation error, remove this server connection after client mouse position connection is gone
	task.wait(0.5)
	MovementConnection:Disconnect()
	MovementConnection = nil

	-- reset variables
	ZombiesKilled = 0

	-- reset camera back to player
	GeneralRemotes.ChangeCameraSubject:FireClient(player, nil)
	GeneralRemotes.EnableControls:FireClient(player, nil)

	model:Destroy()
end

-- game loop blocks thread
local function GameLoop(player, clockLabel)
	-- game loop timer
	for i = Timelimit, 0, -1 do
		local randSpawnTime = math.random(3, SpawnCooldown)
		clockLabel.Text = tostring(i)

		-- spawn zombies
		task.delay(randSpawnTime, function() end)
		task.wait(1)
	end
end

local function PlayerMouseMove(playerModel)
	-- move player
	MovementConnection = Remotes.MousePosition.OnServerEvent:Connect(function(_, mousePos)
		local pivot = playerModel:GetPivot()
		if not mousePos then
			return
		end
		local targetPivot = CFrame.new(mousePos.X, pivot.Position.Y, pivot.Position.Z) * (pivot - pivot.Position)

		local lerpAlpha = 0.2
		local smoothPivot = pivot:Lerp(targetPivot, lerpAlpha)
		playerModel:PivotTo(smoothPivot)
	end)
end

local function Shoot(player, playerModel)
	local gun = playerModel:FindFirstChild("Gun")
	local gunRaycast = gun:FindFirstChild("ShootRay")

	local Raycast = function()
		local rayOrigin = gunRaycast.Position
		local rayDir = Vector3.new(0, 0, 100)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { playerModel, gun }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		return workspace:Raycast(rayOrigin, rayDir, raycastParams)
	end

	MB1Connection = Remotes.MB1Down.OnServerEvent:Connect(function(_)
		if not CanShoot then
			return
		end
		CanShoot = false
		GeneralRemotes.PlaySound:InvokeClient(player, "RevolverShot")
		local shotRay = Raycast()

		if shotRay then
			local hitTarget = shotRay.Instance
			if hitTarget:HasTag("Zombie") then
				local humanoid = hitTarget:FindFirstChild("Humanoid")
				local finalHP = humanoid.Health - GunDamage
				humanoid:TakeDamage(GunDamage)
				if finalHP <= 0 then
					ZombiesKilled = ZombiesKilled + 1
				end
			end
		end

		task.delay(0.5, function()
			CanShoot = true
		end)
	end)
end

function ZombieJob.ServerInit(player)
	print("Zombie job server init")
	local model = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "ZombieJob", "ZombieMap", nil)
	local playerModel = model:FindFirstChild("Player")
	local clockLabel =
		model:FindFirstChild("Clock"):FindFirstChild("BG"):FindFirstChild("SurfaceGui"):FindFirstChild("TimeLabel")

	-- change camera view to game
	GeneralRemotes.ChangeCameraSubject:FireClient(player, model:FindFirstChild("CameraPos").CFrame)

	PlayerMouseMove(playerModel)
	Shoot(player, playerModel)
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

function ZombieJob.ClientInit()
	local StarterPlayer = game:GetService("StarterPlayer")
	local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)

	-- wait for server to spawn models
	task.wait(1)
	workspace:WaitForChild("ZombieMap")
	local player = Players.LocalPlayer

	SoundModule.PlayTheme("Saloon")

	-- mouse movement logic
	local MousePositionConn = RunService.RenderStepped:Connect(function()
		local mouseToWorldPos = GetMouseWorldPosition(player)
		Remotes.MousePosition:FireServer(mouseToWorldPos)
	end)

	local mouse = player:GetMouse()
	-- shoot
	local MB1Clicked = mouse.Button1Down:Connect(function()
		Remotes.MB1Down:FireServer()
	end)

	-- game finished disconnect connections client
	local conn
	conn = Remotes.ZombieJob.GameFinished.OnClientEvent:Connect(function()
		MousePositionConn:Disconnect()
		conn:Disconnect()
		MB1Clicked:Disconnect()
		SoundModule.PlaySound("CashRegister")
		SoundModule.PlayTheme("Main")
		GeneralRemotes.EnableAllNPCPrompts:FireServer(true)
	end)
end

return ZombieJob
