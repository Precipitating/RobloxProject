local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Missions = require(ReplicatedStorage.Missions.Server.Missions)
local Types = require(ReplicatedStorage.Missions.Configs.Types)
local MissionEventHandlers = require(script.Parent:FindFirstChild("MissionsLogicHandler"))
local MissionCompleteHandlers = require(script.Parent:FindFirstChild("MissionsCompleteHandler"))
local MissionFailedHandlers = require(script.Parent:FindFirstChild("MissionsFailedHandler"))
local GeneralRemotes = ReplicatedStorage.Remotes

local TTSConfig = {
	VoiceId = "10",
	Pitch = 1,
	Speed = 1,
	Volume = 3,
}

local MissionsHandler = {}

-- mission handlers
local function unlockHandler(player: Player, missionId: Types.MissionId)
	print(` {player} calling mission event {missionId}...`)
	-- calls paired function in MissionsLogicHandler if exists (should be same name as missionId)
	local handler = MissionEventHandlers[missionId]

	GeneralRemotes.PlaySound:InvokeClient(player, "NewMission")

	if handler then
		handler(player)
	else
		print("Mission logic handler not found. Check spelling")
	end
end

local function completeHandler(player: Player, missionId: Types.MissionId)
	print(`{player} completed mission {missionId}`)
	local handler = MissionCompleteHandlers[missionId]
	if handler then
		task.spawn(function()
			GeneralRemotes.PlayTTS:InvokeClient(
				player,
				`{missionId} complete, well done {player.DisplayName}`,
				TTSConfig
			)
		end)

		handler(player)
	else
		print("Failed to claim rewards")
	end
end

local function failHandler(player: Player, missionId: Types.MissionId)
	local handler = MissionFailedHandlers[missionId]
	if handler then
		task.spawn(function()
			GeneralRemotes.PlayTTS:InvokeClient(
				player,
				`{missionId} failed {player.DisplayName}, what are you doing?`,
				TTSConfig
			)
		end)
		handler(player)
	else
		print("Failed to call fail handler")
	end
	print(`{player} failed mission {missionId}`)
end

function MissionsHandler.Initialize()
	for missionId in Missions.Missions do
		Missions.setUnlockHandler(missionId, unlockHandler)
		Missions.setCompletionHandler(missionId, completeHandler)
		Missions.setFailureHandler(missionId, failHandler)
	end
end

return MissionsHandler
