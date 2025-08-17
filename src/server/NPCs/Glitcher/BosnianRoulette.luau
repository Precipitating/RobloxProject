local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local BosnianRoulette = {}
local LandMine = nil
local LandMineTimer = math.floor(math.random(60, 120))
local BeepSound = nil
local BoomSound = nil
local CurrentTime = LandMineTimer

local function SetCameraPosition(player)
	local camPos = workspace:FindFirstChild("GlitchRoom"):FindFirstChild("CamPos")
	if not camPos then
		error("No CamPos in GlitchRoom")
	end
	GeneralRemotes.ChangeCameraSubject:FireClient(player, camPos.CFrame)
end

local function RevealLandMine()
	if not LandMine then
		error("Cannot find LandMine reference")
		return
	end

	task.spawn(function()
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local goal = { Scale = Vector3.new(1.583, 0.866, 1.592) }
		local tween = TweenService:Create(LandMine.Mesh, tweenInfo, goal)
		tween:Play()
	end)

	BeepSound = LandMine:FindFirstChild("beep")
	BoomSound = LandMine:FindFirstChild("boom")
end

function BosnianRoulette.Init(player)
	print("Bosnian Roulette Init")
	task.wait(1)
	GeneralRemotes.PlayTheme:FireClient(player, "Breathing")
	LandMine = workspace:FindFirstChild("GlitchRoom"):FindFirstChild("LandMine")

	SetCameraPosition(player)
	RevealLandMine()

	BosnianRoulette.StartBomb()
end

function BosnianRoulette.StartBomb()
	while CurrentTime > 0 do
		print(CurrentTime)
		BeepSound:Play()
		local minDelay = 0.1
		local maxDelay = 1
		local progress = CurrentTime / LandMineTimer
		local delayTime = minDelay + (maxDelay - minDelay) * progress
		task.wait(delayTime)
		CurrentTime -= delayTime
	end
	BoomSound:Play()

	print("BOOM")
end

return BosnianRoulette
