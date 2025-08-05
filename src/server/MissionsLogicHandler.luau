local HelperFunctions = require(script.Parent.HelperFunctions)
local BadgeHandler = require(script.Parent.BadgeHandler)
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cutsceneRemotes = ReplicatedStorage.Shared.Cutscenes
local generalRemotes = ReplicatedStorage.Shared.Remotes
local NPCModule = require(script.Parent.NPCs.NPCModule)

local MissionEventHandlers = {}
-- handle all game events

-- Roadman
MissionEventHandlers["StealPhone"] = function()
	-- spawn the next NPC that progresses this mission
	local pos = Vector3.new(math.random(-360, 360), 5.23, -26.1)
	HelperFunctions.SpawnModelAtPosition("Roadman", "PhoneVictim", pos)
end

MissionEventHandlers["RoadmanCaught"] = function(player)
	-- stop movement
	--generalRemotes.DisableControls:FireClient(player, "Cutscene")
	-- spawn surrounding cops around player
	HelperFunctions.SpawnModelAtPosition("Roadman", "Cops", nil)

	-- award badge
	BadgeHandler.awardBadge(player, 3145652566759102)
	-- call cutscene
	cutsceneRemotes.PlayRoadmanFail:FireClient(player)
end

MissionEventHandlers["RoadmanWin"] = function(player)
	-- stop movement
	--generalRemotes.DisableControls:FireClient(player, "Cutscene")

	HelperFunctions.SpawnModelAtPosition("Roadman", "PC", nil)

	-- award badge
	BadgeHandler.awardBadge(player, 2251989026476496)

	-- call cutscene
	cutsceneRemotes.PlayRoadmanWin:FireClient(player)
end

MissionEventHandlers["RoadmanMugged"] = function(player)
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoid and rootPart then
		-- disable movement
		--generalRemotes.DisableControls:FireClient(player, "Cutscene")

		-- spawn signs
		local signs = HelperFunctions.SpawnModelAtPosition("Roadman", "MuggedSigns", nil)

		-- award badge
		BadgeHandler.awardBadge(player, 3689591686016157)

		-- load pose animation
		generalRemotes.PlayAnimation:FireClient(player, "133648952317027")

		-- teleport player to sign's MoveLoc
		rootPart.CFrame = signs.MoveLoc.CFrame

		-- trigger cutscene for this player
		cutsceneRemotes.PlayRoadmanMugged:FireClient(player)
	else
		warn("Humanoid or HumanoidRootPart missing for", player.Name)
	end
end

-- Safechatter
MissionEventHandlers["GuestMoney"] = function(player)
	print("GUEST MISSIO NBEGIN")
	HelperFunctions.SpawnMissionPositionedModels("Safechatter", "Mission")
end

MissionEventHandlers["GuestHorrorMode"] = function(player)
	local safeChatterRef = CollectionService:GetTagged("Safechatter")[1]
	-- set dark lighting
	Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
	Lighting.ClockTime = 0

	-- spawn obby
	local pathModel = HelperFunctions.SpawnModelAtPosition("Safechatter", "InvisiblePaths", nil)
	if not pathModel then
		warn("Failed to spawn pathModel")
		return
	end

	-- teleport player
	local spawnLoc = pathModel:FindFirstChild("SpawnLoc")
	local character = player.Character
	if spawnLoc and character and character.PrimaryPart then
		character:SetPrimaryPartCFrame(spawnLoc.CFrame)
	else
		warn("Missing SpawnLoc or character PrimaryPart")
	end

	-- enable old ROBLOX green circle click to move
	generalRemotes.EnableClickToMove:FireClient(player, true)

	-- teleport NPC

	if safeChatterRef and safeChatterRef.PrimaryPart then
		local safeChatterSpawnLoc = pathModel:FindFirstChild("SafechatterSpawnLoc")
		if safeChatterSpawnLoc then
			safeChatterRef:SetPrimaryPartCFrame(safeChatterSpawnLoc.CFrame)
		else
			warn("SafechatterSpawnLoc not found")
		end

		local NPC = NPCModule:GetNPC("Safechatter")
		NPC:EnableProximityChat(false)
		NPC:SetMode("Angel", player)
	else
		warn("safeChatterRef missing or has no PrimaryPart")
	end

	local failPart = pathModel:FindFirstChild("FailPart")
	local failed

	if failPart then
		failed = failPart.Touched:Connect(function(hit)
			if hit.Parent == character and hit.Parent:FindFirstChild("Humanoid") then
				failed:Disconnect()
				-- handle fail logic here
			end
		end)
	else
		warn("FailPart not found")
	end
end

MissionEventHandlers["GuestComplete"] = function(player)
	local character = player.Character
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local hallway = HelperFunctions.SpawnModelAtPosition("Safechatter", "BrainwashHallway", nil)
	rootPart.CFrame = hallway:FindFirstChild("SpawnLoc").CFrame
	BadgeHandler.awardBadge(player, 844789406145883)
	generalRemotes.PlayAnimation:FireClient(player, "90079565164200")
	cutsceneRemotes.PlayGuestMissionComplete:FireClient(player)

	-- make pitch black
	Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
	Lighting.ClockTime = 0
end

-- Guest

return MissionEventHandlers
