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
	self.MovementCoroutine = nil
	self.Humanoid = model:FindFirstChild("Humanoid")
	self.HumanoidRootPart = model:FindFirstChild("HumanoidRootPart")
	return self
end

function NPC:SetInteractedWith(val)
	self.InteractedWith = val

	if not val then
		if self.MovementCoroutine and coroutine.status(self.MovementCoroutine) == "suspended" then
			coroutine.resume(self.MovementCoroutine)
		end
	end
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
	local path = PathfindingService:CreatePath()
	path:ComputeAsync(self.HumanoidRootPart.Position, targetPos.Position)

	for _, waypoint in path:GetWaypoints() do
		while self.InteractedWith do
			print("Paused...")
			coroutine.yield() -- Pause here
		end

		self:MoveTo(waypoint.Position, true)

		local finished = false
		local connection
		local thread = coroutine.running()

		connection = self.Humanoid.MoveToFinished:Connect(function()
			if not finished then
				finished = true
				connection:Disconnect()
				coroutine.resume(thread, "moveDone")
			end
		end)

		local resumeReason = coroutine.yield()

		while self.InteractedWith do
			print("Paused after MoveTo")
			coroutine.yield()
		end
	end

	arrivedRemote:Fire()
	print("Path complete")
end

function NPC:StartPathing(targetPos)
	if self.MovementCoroutine and coroutine.status(self.MovementCoroutine) == "suspended" then
		print("Already moving")
		return
	end

	self.InteractedWith = false
	self.MovementCoroutine = coroutine.create(function()
		self:PathFindTo(targetPos)
	end)

	coroutine.resume(self.MovementCoroutine)
end

return NPC
