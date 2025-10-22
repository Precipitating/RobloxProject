local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")
local Client = Players.LocalPlayer
local Debug = true
local OpenRain = {}
OpenRain.__index = OpenRain

-- // Types
export type RainData = {
	StartDelay: number?,
	RainColor: Color3?,
	CheckForRoof: boolean?,
	Intensity: number?,
	UntilFullRain: number?,
	RenderArea: number?,
}

local function PRNT(...)
	if Debug then
		print(...)
	end
end

function OpenRain.new(_data: RainData)
	if not _data then
		_data = {}
	end
	local Atmosphere = Lighting:FindFirstChild("Atmosphere") or Instance.new("Atmosphere")
	local Clouds = workspace.Terrain:FindFirstChild("Clouds") or Instance.new("Clouds")

	local ID = HttpService:GenerateGUID(false)
	local Rain = setmetatable({
		StartDelay = _data.StartDelay or 10,
		UntilFullRain = _data.UntilFullRain or 10,
		RainColor = _data.RainColor or Color3.fromRGB(33, 33, 33),
		Active = false,
		CheckForRoof = _data.CheckForRoof or true,
		ID = ID,
		RenderArea = _data.RenderArea or 86,
		Intensity = _data.Intensity or 3,

		CloudsOG = {
			Density = Clouds.Density,
			Cover = Clouds.Cover,
			Color = Clouds.Color,
		},

		AtmosphereOG = {
			Haze = Atmosphere.Haze,
			Decay = Atmosphere.Decay,
			Color = Atmosphere.Color,
			Density = Atmosphere.Density,
		},
		LightingOG = {
			EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
			EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
			Ambient = Lighting.Ambient,
			Brightness = Lighting.Brightness,
		},
		FloorEffect = nil,
		RainEffect = nil,
	}, OpenRain)

	Rain.Intensity = Rain.Intensity * 100

	return Rain
end

function OpenRain:init()
	local Atmosphere = Lighting:FindFirstChild("Atmosphere")
	local Clouds = workspace.Terrain:FindFirstChild("Clouds")

	TweenService:Create(Clouds, TweenInfo.new(self.StartDelay), {
		Density = 0.5,
		Cover = 0.8,
		Color = self.RainColor,
	}):Play()
	TweenService:Create(Atmosphere, TweenInfo.new(self.StartDelay), {
		Haze = 7,
		Color = self.RainColor,
		Decay = self.RainColor,
		Density = 0.5,
	}):Play()

	TweenService:Create(Lighting, TweenInfo.new(self.StartDelay), {
		EnvironmentDiffuseScale = 0,
		EnvironmentSpecularScale = 0,
		Ambient = self.RainColor,
		Brightness = 1,
	}):Play()
	task.delay(self.StartDelay / 2, function()
		self:Start()
	end)
end

function OpenRain:update(_data: RainData)
	for index, value in pairs(_data) do
		self[index] = value
	end

	TweenService:Create(self.FloorEffect.ParticleEmitter, TweenInfo.new(self.UntilFullRain), { Rate = self.Intensity })
		:Play()
	TweenService:Create(self.RainEffect.ParticleEmitter, TweenInfo.new(self.UntilFullRain), { Rate = self.Intensity })
		:Play()
end

function OpenRain:Stop()
	if not self.Active then
		return
	end
	print("rain end")
	local rain = self.RainEffect
	local floor = self.FloorEffect

	if not floor then
		warn("floor ref missing")
	end

	TweenService:Create(floor.ParticleEmitter, TweenInfo.new(self.UntilFullRain), { Rate = 0 }):Play()
	TweenService:Create(rain.ParticleEmitter, TweenInfo.new(self.UntilFullRain), { Rate = 0 }):Play()

	task.delay(self.StartDelay / 2, function()
		TweenService:Create(Lighting:FindFirstChild("Atmosphere"), TweenInfo.new(self.StartDelay), self.AtmosphereOG)
			:Play()
		TweenService:Create(Lighting, TweenInfo.new(self.StartDelay), self.LightingOG):Play()
		TweenService:Create(workspace.Terrain:FindFirstChild("Clouds"), TweenInfo.new(self.StartDelay), self.CloudsOG)
			:Play()
		task.wait(self.StartDelay)
		self.Active = false
	end)
end

function OpenRain:Start()
	if self.Active then
		return
	end
	print("rain start")
	self.Active = true
	local _rain = self.RainEffect or ReplicatedStorage.ClientModels.Weather.Rain:Clone()
	local _floor = self.FloorEffect or ReplicatedStorage.ClientModels.Weather["Floor effect"]:Clone()
	local defaultFloorSize = _floor.Size

	self.RainEffect = _rain
	self.FloorEffect = _floor

	_floor.ParticleEmitter.Rate = 0
	_rain.ParticleEmitter.Rate = 0

	TweenService:Create(_floor.ParticleEmitter, TweenInfo.new(self.UntilFullRain), { Rate = self.Intensity }):Play()
	TweenService:Create(_rain.ParticleEmitter, TweenInfo.new(self.UntilFullRain), { Rate = self.Intensity }):Play()

	RunService:BindToRenderStep("rain", Enum.RenderPriority.Camera.Value + 1, function()
		if not self.Active then
			return
		end

		local character = Client.Character
		if not character or not character.PrimaryPart then
			return
		end
		_rain.Size = Vector3.new(self.RenderArea, _rain.Size.Y, self.RenderArea)
		_floor.Size = Vector3.new(self.RenderArea, _floor.Size.Y, self.RenderArea)

		local params = RaycastParams.new()
		params.FilterDescendantsInstances = { Client.Character, _rain, _floor }
		params.FilterType = Enum.RaycastFilterType.Exclude

		local origin = Client.Character.PrimaryPart.Position
		local roofHit = workspace:Raycast(origin, Vector3.new(0, 100, 0), params)
		local groundHit = workspace:Raycast(origin, Vector3.new(0, -100, 0), params)

		if roofHit then
			_rain.Parent = nil
			_floor.Parent = nil
		else
			_floor.Parent = workspace
			_rain.Parent = workspace
			_rain.Position = Client.Character.PrimaryPart.Position + Vector3.new(0, 50, 0)
			_floor.Position = groundHit.Position
		end
	end)
end

return OpenRain
