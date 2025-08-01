local NPC = {}
local NPCStorage = {}
local Collections = game:GetService("CollectionService")
local NPCList = Collections:GetTagged("MoveableNPC")
local PathfindingService = game:GetService("PathfindingService")
local initializedRemote = game.ReplicatedStorage.Shared.Events.NPC.InitializedNPC
local arrivedRemote = game.ReplicatedStorage.Shared.Events.NPC.ArrivedDestination
NPC.__index = NPC

function NPC.new(model)
	local self = setmetatable({}, NPC)
	self.Model = model
	self.Health = 100
	self.AvailablePaths = nil
	self.InteractedWith = false
	self.Humanoid = model:FindFirstChild("Humanoid")
	self.HumanoidRootPart = model:FindFirstChild("HumanoidRootPart")
	return self
end

function NPC:SetInteractedWith(val)
	self.InteractedWith = val
end

function NPC:IsInteracting()
	return self.InteractedWith
end

function NPC:SetPathStorage(path)
	self.AvailablePaths = path
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
		initializedRemote:Fire()
	end)
end

function NPC:MoveTo(targetPos, interruptable)
	if self.Humanoid then
		self.Humanoid:MoveTo(targetPos)
		if not interruptable then
			self.Humanoid.MoveToFinished:Wait()
		end
	else
		error("NPC has no valid Humanoid")
	end
end

function NPC:ForceStopMovement()
	if self.Humanoid and self.HumanoidRootPart then
		self.Humanoid:MoveTo(self.HumanoidRootPart.Position)
		print("Force stopped!")
	end
end

function NPC:PathFindTo(targetPos)
	if self.InteractedWith then
		print("Is interacting, cancelling pathfind attempt")
		return
	end
	if not self.Humanoid or not self.HumanoidRootPart then
		error("Missing Humanoid or HumanoidRootPart")
		return
	end

	local path = PathfindingService:CreatePath()
	path:ComputeAsync(self.HumanoidRootPart.Position, targetPos.Position)

	for _, waypoint in path:GetWaypoints() do
		if self.InteractedWith then
			return
		end
		self:MoveTo(waypoint.Position, true)
		self.Humanoid.MoveToFinished:Wait()
	end

	arrivedRemote:Fire()
end

return NPC
