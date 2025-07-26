local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Missions = require(ReplicatedStorage.Missions.Server.Missions)

ReplicatedStorage.Missions.Events.UnlockMissionEvent.OnServerEvent:Connect(function(player, missionName)
	print(missionName)
	print("called server")
	if typeof(missionName) == "string" then
		Missions.unlockMission(player, missionName)
		print("Server attempting to unlock the mission " .. missionName)
	end
end)
