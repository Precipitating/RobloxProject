local NPC = {}
local NPCStorage = {}
local Collections = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local InitializedRemote = ReplicatedStorage.Events.NPC.InitializedNPC
local ArrivedRemote = ReplicatedStorage.Events.NPC.ArrivedDestination
local WeepingAngelModeEvent = ReplicatedStorage.Events.NPC.WeepingAngelMode
local TweenService = game:GetService("TweenService")

NPC.__index = NPC

function NPC.new(model)
	local self = setmetatable({}, NPC)
	self.ModeDebounce = false
	self.Model = model
	self.Name = nil
	self.Health = 100
	self.AvailablePaths = nil
	self.LastMode = nil
	self.Humanoid = model:FindFirstChild("Humanoid")
	self.HumanoidRootPart = model:FindFirstChild("HumanoidRootPart")
	self.Mode = "Idle"
	self.PathCancelled = false
	self.Connections = {}

	return self
end

function NPC:GetModel()
	return self.Model
end

function NPC:DisconnectAllConnections()
	if not self.Connections then
		return
	end

	for event in pairs(self.Connections) do
		if event.Connected then
			event:Disconnect()
		end
	end

	table.clear(self.Connections)
end

function NPC:SetMode(mode)
	if self.Mode == mode then
		return
	end
	-- debounce: ignore if already changing mode
	if self.ModeDebounce then
		print("MODE DEBOUNCE")
		return
	end

	self.ModeDebounce = true
	print(`{self.Name} going to state {mode}, prev state {self.Mode}`)
	self.LastMode = self.Mode
	self.Mode = mode

	local function getPlayer()
		return Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
	end

	if mode == "Interacting" then
		local player = getPlayer()
		self:ForceStopMovement()

		local character = player.Character or player.CharacterAdded:Wait()
		local playerPos = character:GetPivot().Position
		local modelPos = self.Model:GetPivot().Position
		local targetPos = Vector3.new(playerPos.X, modelPos.Y, playerPos.Z)

		-- rotate towards player without blocking
		task.spawn(function()
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
			local facingCFrame = CFrame.lookAt(modelPos, targetPos)
			TweenService:Create(self.Model.PrimaryPart, tweenInfo, { CFrame = facingCFrame }):Play()
		end)
	elseif mode == "Patrol" then
		ArrivedRemote:Fire(self.Name)
	elseif mode == "Angel" then
		WeepingAngelModeEvent:Fire(getPlayer())
	end

	-- Non-blocking debounce reset
	task.delay(0.5, function()
		self.ModeDebounce = false
	end)
end

function NPC:SetBackPreviousMode()
	print(self.LastMode)
	if self.LastMode == self.Mode then
		warn("NPC GOING BACK TO SAME MODE???")
		return
	end
	self:SetMode(self.LastMode)
end

function NPC:GetMode()
	return self.Mode
end

function NPC:SetPathStorage(path)
	self.AvailablePaths = path
end

function NPC:EnableProximityChat(val)
	local prompt = self.Model:FindFirstChild("ProximityPrompt")

	if prompt then
		prompt.Enabled = val
	end
end

function NPC:GetPathStorage()
	if self.AvailablePaths then
		return self.AvailablePaths
	else
		error("Set path storage data")
	end
end

function NPC:GetNPC(name)
	if NPCStorage[name] then
		return NPCStorage[name]
	else
		error(`{name} isnt stored in NPCList`)
		return nil
	end
end

function NPC:Init()
	local NPCList = Collections:GetTagged("MoveableNPC")
	-- get all MoveableNPC tagged objects and initialize it
	for _, currNPC in pairs(NPCList) do
		if currNPC:IsA("Model") and currNPC:FindFirstChildOfClass("Humanoid") then
			-- new NPC object to be stored into a table
			local assignedNPC = NPC.new(currNPC)
			assignedNPC.Name = currNPC.Name

			-- check for valid destination points and set if so, optional
			if currNPC.Parent:FindFirstChild("NavLocations") then
				assignedNPC:SetPathStorage(currNPC.Parent:FindFirstChild("NavLocations"))
				print(`{currNPC.Name} NPC has path data, storing...`)
			end
			NPCStorage[currNPC.Name] = assignedNPC

			-- set all bodyparts network ownership to nil (fix stuttering issue with pathfinding)
			for _, part in pairs(currNPC:GetChildren()) do
				if part:IsA("BasePart") then --
					part:SetNetworkOwner(nil)
				end
			end

			task.defer(function()
				print(`Intialize remote for {currNPC.Name}`)
				InitializedRemote:Fire(currNPC.Name)
			end)
		end
	end
end

function NPC:ForceStopMovement()
	if self.Humanoid and self.HumanoidRootPart then
		self.PathCancelled = true
	end
end

function NPC:SetWalkspeed(val)
	if self.Humanoid then
		self.Humanoid.WalkSpeed = val
	end
end

function NPC:StartPathing(targetPos)
	print(`{self.Name} should start moving to waypoints!`)
	if not self.Humanoid then
		error("NPC Humanoid not found to pathfind!")
		return
	end

	self.PathCancelled = false
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		Costs = {
			Pavement = 1,
			ZebraCrossing = 2,
			Road = 100,
			Grass = 50,
			Conrete = 50,
			Glass = 100,
			Snow = 100,
			Plastic = 50,
		},
	})

	path:ComputeAsync(self.HumanoidRootPart.Position, targetPos.Position)

	for _, waypoint in path:GetWaypoints() do
		if self.PathCancelled then
			print("Pathfinding cancelled.")
			return
		end
		self.Humanoid:MoveTo(waypoint.Position)
		local reached = self.Humanoid.MoveToFinished:Wait()
		if not reached or self.PathCancelled then
			warn("Movement interrupted or waypoint not reached")
			return
		end
	end

	ArrivedRemote:Fire(self.Name)
end

return NPC
