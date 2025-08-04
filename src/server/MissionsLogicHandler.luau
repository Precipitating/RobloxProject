local HelperFunctions = require(script.Parent.HelperFunctions)
local BadgeHandler = require(script.Parent.BadgeHandler)
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cutsceneRemotes = ReplicatedStorage.Shared.Cutscenes
local generalRemotes = ReplicatedStorage.Shared.Remotes

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
	Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
	Lighting.ClockTime = 0
	local pathModel = HelperFunctions.SpawnModelAtPosition("Safechatter", "InvisiblePaths", nil)
	local character = player.Character
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	rootPart.CFrame = pathModel:FindFirstChild("SpawnLoc").CFrame
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
