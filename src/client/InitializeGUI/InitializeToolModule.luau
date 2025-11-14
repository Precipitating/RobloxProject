local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local CameraTool = require(StarterPlayer.StarterPlayerScripts.Client.NPCs.Photographer.CameraTool)
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local GeneralRemotes = ReplicatedStorage.Remotes
local InitializeToolModule = {}
local Connections = {}

function InitializeToolModule.DisconnectAll(name)
	Character.Humanoid:UnequipTools()
	if not Connections[name] then
		warn("Disconnect failed, key doesn't exist")
		return
	end
	for _, conn in pairs(Connections[name]) do
		if typeof(conn) == "RBXScriptConnection" then
			conn:Disconnect()
		end
	end

	table.clear(Connections[name])

	print(`Disconnected {name}!`)
end

local function trackConnect(name, signal, callback)
	-- initialize table for this key
	if not Connections[name] then
		Connections[name] = {}
	end

	local conn = signal:Connect(callback)
	table.insert(Connections[name], conn)
	return conn
end

InitializeToolModule["PrisonSpoon"] = function(tool)
	local cooldown = 1
	local dist = 5
	local canAttack = true
	local hitsBeforeBreak = 2
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = { Character }
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local function BallTerrainDestroy(result)
		-- initiate a ball shaped terrain destruction if raycast hits terrain
		if result and result.Instance == workspace.Terrain then
			SoundModule.PlaySound("Dig")
			local pos = Character:GetPivot().Position + Character:GetPivot().LookVector * dist
			workspace.Terrain:FillBall(pos, 5, Enum.Material.Air)
			hitsBeforeBreak -= 1

			if hitsBeforeBreak <= 0 then
				SoundModule.PlaySound("MetalSnap")
				InitializeToolModule.DisconnectAll("PrisonSpoon")
				GeneralRemotes.RemoveEquippedTool:FireServer()
			end
		end
		task.delay(cooldown, function()
			canAttack = true
		end)
	end

	trackConnect("PrisonSpoon", tool.Activated, function()
		if canAttack then
			-- old style r6 animation activation of slash animation
			local Anim = Instance.new("StringValue")
			Anim.Name = "toolanim"
			Anim.Value = "Slash"
			Anim.Parent = tool
			local result =
				workspace:Raycast(Character:GetPivot().Position, Character:GetPivot().LookVector * dist, rayParams)

			BallTerrainDestroy(result)
		end
	end)
end

InitializeToolModule["Camera"] = function(tool)
	CameraTool.Initialize()
	local MIN_FOV = 20
	local MAX_FOV = 70
	local ZOOM_STEP = 2

	local function EquipCamera()
		Player.CameraMode = Enum.CameraMode.LockFirstPerson
		UserInputService.MouseIconEnabled = false
		GeneralRemotes.EnableAllNPCPrompts:FireServer(false)

		trackConnect("CameraScroll", UserInputService.InputChanged, function(input, _)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local cam = workspace.CurrentCamera
				if input.Position.Z > 0 then
					-- scroll up = zoom in
					cam.FieldOfView = math.clamp(cam.FieldOfView - ZOOM_STEP, MIN_FOV, MAX_FOV)
				else
					-- scroll down = zoom out
					cam.FieldOfView = math.clamp(cam.FieldOfView + ZOOM_STEP, MIN_FOV, MAX_FOV)
				end
			end
			local fov = workspace.CurrentCamera.FieldOfView
			fov = fov + 1
		end)
	end

	local function UnequipCamera()
		Player.CameraMode = Enum.CameraMode.Classic
		UserInputService.MouseIconEnabled = true
		GeneralRemotes.EnableAllNPCPrompts:FireServer(true)

		InitializeToolModule.DisconnectAll("CameraScroll")
		workspace.CurrentCamera.FieldOfView = 70
	end

	trackConnect("Camera", tool.Equipped, function()
		EquipCamera()
	end)

	trackConnect("Camera", tool.Unequipped, function()
		UnequipCamera()
	end)

	trackConnect("Camera", tool.Activated, function()
		CameraTool.TakePhotograph()
	end)

	print("Camera tool initialized!")
end

return InitializeToolModule
