local MissionEventHandlers = {}
local HelperFunctions = require(script.Parent.HelperFunctions)
local BadgeHandler = require(script.Parent.BadgeHandler)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local cutsceneRemotes = ReplicatedStorage.Shared.Cutscenes
local generalRemotes = ReplicatedStorage.Shared.Remotes
local mainMusic = ReplicatedStorage.Shared.Sounds.Main
local animationFolder = ServerStorage.Animations

-- handle all game events
MissionEventHandlers["StealPhone"] = function()
	-- spawn the next NPC that progresses this mission
	local pos = Vector3.new(math.random(-360, 360), 5.23, -26.1)
	HelperFunctions.SpawnModelAtPosition("NPCS", "PhoneVictim", pos)
end

MissionEventHandlers["RoadmanCaught"] = function(player)
	-- stop movement
	generalRemotes.DisableControls:FireClient(player, "Cutscene")
	-- spawn surrounding cops around player
	HelperFunctions.SpawnModelAtPosition("MissionModels", "Cops", nil)
	mainMusic:Stop()
	mainMusic:Destroy()
	-- award badge
	BadgeHandler.awardBadge(player, 3145652566759102)
	-- call cutscene
	cutsceneRemotes.PlayRoadmanFail:FireClient(player)
end

MissionEventHandlers["RoadmanWin"] = function(player)
	-- stop movement
	generalRemotes.DisableControls:FireClient(player, "Cutscene")

	HelperFunctions.SpawnModelAtPosition("MissionModels", "PC", nil)

	-- destroy main music, because after this function is called, hideUI (UIController) will call, auto resuming main music
	mainMusic:Stop()
	mainMusic:Destroy()

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
		generalRemotes.DisableControls:FireClient(player, "Cutscene")

		-- spawn signs
		local signs = HelperFunctions.SpawnModelAtPosition("MissionModels", "MuggedSigns", nil)

		-- stop and destroy main music
		mainMusic:Stop()
		mainMusic:Destroy()

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

return MissionEventHandlers
