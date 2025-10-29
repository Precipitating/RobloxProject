local TweenService = game:GetService("TweenService")
local OpenRain = require(script.Parent.OpenRain)
local CurrentWeather = nil

local RainRef = OpenRain.new({
	StartDelay = 5,
	RainColor = Color3.fromRGB(50, 50, 50),
	CheckForRoof = true,
	Intensity = 5,
	UntilFullRain = 3,
	RenderArea = 200,
})
local WeatherVisualizer = {}

function WeatherVisualizer.GetWeather()
	return CurrentWeather
end

local WeatherFunctions = {
	Rain = function()
		if CurrentWeather == "Rain" then
			return
		end
		CurrentWeather = "Rain"

		-- wait a second for the root part to load (on spawn) to prevent renderstep errors
		task.wait(1)
		RainRef:init()
	end,
	Sun = function()
		if CurrentWeather == "Sun" then
			return
		end
		CurrentWeather = "Sun"
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
