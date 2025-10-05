local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
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
local Timelimit = 60
local SpawnCooldown = 7
local CanShoot = true
local GunDamage = 50
local ZombiesKilled = 0
local BarrierHP = 200
local NextBarrierDeletion = 160
local ZombieDamage = 10
local Finished = false
local ZombieTargetPos = nil
local MuzzleFlashes: { ParticleEmitter | PointLight } = nil
local SandBagsRef: { Model } = nil
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

	-- reset camera back to player
	GeneralRemotes.ChangeCameraSubject:FireClient(player, nil)
	GeneralRemotes.EnableControls:FireClient(player, nil)
	TalkModuleHelpers.SetCanTalk(true)

	model:Destroy()
end

local function ZombieLogic(zombie)
	task.spawn(function()
		local humanoid = zombie:FindFirstChild("Humanoid")
		if not humanoid or Finished then
			return
		end

		local animationTrack = humanoid:LoadAnimation(zombie.Animations.Attack)

		-- move to barrier
		local zombiePos = zombie:GetPivot().Position
		local target = Vector3.new(zombiePos.X, zombiePos.Y, ZombieTargetPos.WorldPosition.Z)
		humanoid:MoveTo(target)

		while (zombie:GetPivot().Position - target).Magnitude > 2 and humanoid.Health > 0 do
			task.wait(0.1)
		end
		print("target reached")

		-- attack barrier
		while BarrierHP > 0 and zombie.Parent and humanoid.Health > 0 and not Finished do
			animationTrack:Play()
			BarrierHP -= ZombieDamage
			task.wait(2)
			print(BarrierHP)

			if #SandBagsRef > 0 and (BarrierHP <= NextBarrierDeletion) then
				print("should remove")
				NextBarrierDeletion -= 40
				local randIdx = math.random(1, #SandBagsRef)
				SandBagsRef[randIdx]:Destroy()
				table.remove(SandBagsRef, randIdx)
			end
		end

		if BarrierHP <= 0 then
			Finished = true
		end
	end)
end

local function GameLoop(player, clockLabel, model)
	local spawns = workspace.ZombieMap.ZombieSpawns:GetChildren()
	local timeLeft = Timelimit
	local nextSpawnIn = 0

	local BASE_SPAWN_COOLDOWN = SpawnCooldown
	local MIN_SPAWN_COOLDOWN = 1

	while timeLeft > 0 do
		if Finished then
			break
		end

		-- update clock
		clockLabel.Text = tostring(timeLeft)

		-- calculate cooldown based on remaining time (ramp-up)
		local timeRatio = timeLeft / Timelimit --
		local currentCooldown = MIN_SPAWN_COOLDOWN + (BASE_SPAWN_COOLDOWN - MIN_SPAWN_COOLDOWN) * timeRatio

		-- spawn zombie if timer elapsed
		if nextSpawnIn <= 0 then
			local spawnPoint = spawns[math.random(1, #spawns)]
			local zomb = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "ZombieJob", "Zombie", nil)
			zomb.PrimaryPart:SetNetworkOwner(nil)
			local humanoid = zomb:FindFirstChild("Humanoid")
			zomb:PivotTo(spawnPoint.CFrame)
			zomb.Parent = model
			if humanoid then
				humanoid.WalkSpeed = math.random(10, 30)
			end
			ZombieLogic(zomb)

			-- reset spawn timer based on scaled cooldown
			nextSpawnIn = math.random(MIN_SPAWN_COOLDOWN, currentCooldown)
		end

		task.wait(1)
		timeLeft -= 1
		nextSpawnIn -= 1
	end

	print("game end")
	GameFinished(player, model)
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

local function EmitMuzzleFlash()
	if not MuzzleFlashes then
		return
	end
	-- muzzle flash effect
	for _, obj in MuzzleFlashes do
		obj.Enabled = true
	end
	task.delay(0.1, function()
		for _, obj in MuzzleFlashes do
			if obj and obj.Parent then
				obj.Enabled = false
			end
		end
	end)
end

local function EmitBloodSplatter(target)
	local blood = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "ZombieJob", "BloodSplat", nil)
	local pos = CFrame.lookAt(target.Position, target.Position + target.Normal)
	blood:PivotTo(pos)
	blood:FindFirstChild("WeldConstraint").Part0 = target.Instance
	Debris:AddItem(blood, 0.2)
end
local function Shoot(player, playerModel)
	local gun = playerModel:FindFirstChild("Gun")
	local gunRaycast = gun:FindFirstChild("ShootRay")

	local Raycast = function()
		local rayOrigin = gunRaycast.Position
		local rayDir = Vector3.new(0, 0, 100)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { playerModel, gun, gunRaycast }
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

		EmitMuzzleFlash()

		if shotRay then
			local hitTarget = shotRay.Instance
			local zombieModel = hitTarget:FindFirstAncestorWhichIsA("Model")

			if zombieModel and zombieModel:HasTag("Zombie") then
				local humanoid = zombieModel:FindFirstChild("Humanoid")
				if humanoid then
					local finalHP = humanoid.Health - GunDamage
					humanoid:TakeDamage(GunDamage)
					EmitBloodSplatter(shotRay)
					if finalHP <= 0 then
						ZombiesKilled = ZombiesKilled + 1
					end
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
	-- reset variables
	ZombiesKilled = 0
	Finished = false
	BarrierHP = 200
	CanShoot = true
	NextBarrierDeletion = 160

	-- variable inits
	local model = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "ZombieJob", "ZombieMap", nil)
	ZombieTargetPos = model:FindFirstChild("TargetPos")
	local playerModel = model:FindFirstChild("Player")
	local clockLabel =
		model:FindFirstChild("Clock"):FindFirstChild("BG"):FindFirstChild("SurfaceGui"):FindFirstChild("TimeLabel")
	SandBagsRef = model:FindFirstChild("Sandbags"):GetChildren()
	MuzzleFlashes = model
		:FindFirstChild("Player")
		:FindFirstChild("Gun")
		:FindFirstChild("Muzzle")
		:FindFirstChild("Attachment")
		:GetChildren()

	-- change camera view to game
	GeneralRemotes.ChangeCameraSubject:FireClient(player, model:FindFirstChild("CameraPos").CFrame)

	PlayerMouseMove(playerModel)
	Shoot(player, playerModel)
	GameLoop(player, clockLabel, model)
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
		SoundModule.PlayTheme("Main")
	end)
end

return ZombieJob
