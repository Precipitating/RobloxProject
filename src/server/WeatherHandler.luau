local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local GeneralRemotes = ReplicatedStorage.Remotes
local WeatherThread = nil
local WeatherHandler = {}
local cancelled = false

local WeatherTypes = {
	"Sun",
	"Sun",
	"Sun",
	"Rain",
}

function WeatherHandler.Start()
	WeatherThread = coroutine.wrap(function()
		while not cancelled do
			local nextWeather = WeatherTypes[math.random(1, #WeatherTypes)]
			GeneralRemotes.UpdateWeather:FireAllClients(nextWeather)
			task.wait(math.random(60, 120))
		end
	end)
	WeatherThread()
end

function WeatherHandler.Cancel()
	cancelled = true
end

return WeatherHandler
