local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local OpenTime = 18
local CloseTime = 6
local LightsOn = false
local StreetLights = nil
local GeneralRemotes = ReplicatedStorage.Remotes
local Initialized = false
local TimeOfDay = {}
function TimeOfDay.StartSyncing()
	while task.wait(1) do
		local t = os.date("*t") -- player’s local time
		local clockTime = t.hour + (t.min / 60) + (t.sec / 3600)
		Lighting.ClockTime = clockTime
		if not Initialized then
			TimeOfDay.ClientSyncWithLightPosts()
			Initialized = true
		end
	end
end

function TimeOfDay.GetLightState()
	return LightsOn
end

function TimeOfDay.SetLightState(val)
	LightsOn = val
end
function TimeOfDay.GetStreetLights()
	StreetLights = CollectionService:GetTagged("StreetLight")

	return StreetLights
end

local function DecideLightsChange()
	-- extract current hour from the 24 hour time format
	local hour = tonumber(string.sub(game.Lighting.TimeOfDay, 1, 2))

	-- turn off streetlights
	if hour > CloseTime and hour < OpenTime then
		GeneralRemotes.TimeOfDay.ModifyStreetLights:FireServer(false)
	else
		-- turn on streetlights
		GeneralRemotes.TimeOfDay.ModifyStreetLights:FireServer(true)
	end
end

function TimeOfDay.ClientSyncWithLightPosts()
	-- on spawn check, then check every minute afterwards
	DecideLightsChange()
	task.spawn(function()
		while wait(60) do
			DecideLightsChange()
		end
	end)
end

return TimeOfDay
