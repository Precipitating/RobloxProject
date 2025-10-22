local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)
local OpenRain = require(script.Parent.OpenRain)
local currentWeather = nil

local RainRef = OpenRain.new({
	StartDelay = 5,
	RainColor = Color3.fromRGB(50, 50, 50),
	CheckForRoof = true,
	Intensity = 5,
	UntilFullRain = 3,
	RenderArea = 200,
})
local WeatherVisualizer = {}

local WeatherFunctions = {
	Rain = function()
		if currentWeather == "Rain" then
			return
		end
		currentWeather = "Rain"

		-- wait a second for the root part to load (on spawn) to prevent renderstep errors
		task.wait(1)
		RainRef:init()
	end,
	Sun = function()
		if currentWeather == "Sun" then
			return
		end
		currentWeather = "Sun"
		RainRef:Stop()

		TweenService:Create(workspace.Terrain.Clouds, TweenInfo.new(5), { Cover = 0.3 }):Play()
		TweenService:Create(game.Lighting.Atmosphere, TweenInfo.new(5), { Density = 0.295 }):Play()
	end,
}

function WeatherVisualizer.Process(nextWeather)
	if nextWeather == "Sun" then
		WeatherFunctions.Sun()
	elseif nextWeather == "Rain" then
		WeatherFunctions.Rain()
	end
end

return WeatherVisualizer
