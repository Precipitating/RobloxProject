local NPC = {}
local NPCStorage = {}
local Collections = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local InitializedRemote = ReplicatedStorage.Events.NPC.InitializedNPC
local ArrivedRemote = ReplicatedStorage.Events.NPC.ArrivedDestination
local WeepingAngelModeEvent = ReplicatedStorage.Events.NPC.WeepingAngelMode
local TweenService = game:GetService("TweenService")
local ModeDebounce = false
NPC.__index = NPC

function NPC.new(model)
	local self = setmetatable({}, NPC)
	self.Model = model
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

function NPC:SetMode(mode, player)
	if ModeDebounce then
		return
	end
	if self.Mode == mode then
		return
	end
	print(`NPC going to state {mode}, prev state {self.Mode}`)

	self.LastMode = self.Mode
	self.Mode = mode
	ModeDebounce = true
	if mode == "Interacting" then
		self:ForceStopMovement()
		if player then
			local character = player.Character or player.CharacterAdded:Wait()
			local playerPos = character:GetPivot().Position
			local modelPosition = self.Model:GetPivot().Position
			local targetPosition = Vector3.new(playerPos.X, modelPosition.Y, playerPos.Z)

			-- rotate towards player via tween on seperate, non blocking thread
			task.spawn(function()
				local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
				local facingCFrame = CFrame.lookAt(modelPosition, targetPosition)
				local tween = TweenService:Create(self.Model.PrimaryPart, tweenInfo, { CFrame = facingCFrame })
				tween:Play()
			end)
		end
	elseif mode == "Patrol" then
		ArrivedRemote:Fire()
	elseif mode == "Angel" then
		WeepingAngelModeEvent:Fire(player)
	end

	task.wait(1)
	ModeDebounce = false
end

function NPC:SetBackPreviousMode(player)
	print(self.LastMode)
	if self.LastMode == self.Mode then
		warn("NPC GOING BACK TO SAME MODE???")
		return
	end
	self:SetMode(self.LastMode, player)
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
		error(name .. "isnt stored in NPCList")
		return nil
	end
end

function NPC:Init()
	local NPCList = Collections:GetTagged("MoveableNPC")
	-- get all MoveableNPC tagged objects and initialize it
	for _, currNPC in pairs(NPCList) do
		if currNPC:IsA("Model") and currNPC:FindFirstChildOfClass("Humanoid") then
			local assignedNPC = NPC.new(currNPC)
			-- check for valid destination points and set if so
			if currNPC.Parent:FindFirstChild("NavLocations") then
				assignedNPC:SetPathStorage(currNPC.Parent:FindFirstChild("NavLocations"))
				print("NPC has path data, storing...")
			end
			NPCStorage[currNPC.Name] = assignedNPC

			-- set all bodyparts network ownership to nil (fix stuttering issue with pathfinding)
			for _, part in pairs(currNPC:GetChildren()) do
				if part:IsA("BasePart") then --
					part:SetNetworkOwner(nil)
				end
			end
		end
	end

	task.defer(function()
		InitializedRemote:Fire()
	end)
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

function NPC:StartPathing(targetPos, obj)
	print("should start moving npc")
	if not self.Humanoid then
		error("NPC Humanoid not found to pathfind!")
		return
	end

	self.PathCancelled = false
	local path = PathfindingService:CreatePath()

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

	ArrivedRemote:Fire(obj)
end

return NPC
