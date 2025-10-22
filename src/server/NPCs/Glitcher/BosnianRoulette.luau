local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local BadgeHandler = require(ServerScriptService.Server.BadgeHandler)
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local GeneralRemotes = ReplicatedStorage.Remotes
local BosnianRoulette = {}
local LandMine = nil
local LandMineTimer = math.floor(math.random(60, 300))
local BeepSound = nil
local BoomSound = nil
local CurrentTime = LandMineTimer
local GUILocation = ReplicatedStorage.GUI.Glitcher.BosnianRouletteGUI
local GUIInstance = nil
local YourTurn = true
local PlayerRef = nil

local function SetCameraPosition()
	local camPos = workspace:FindFirstChild("GlitchRoom"):FindFirstChild("CamPos")
	if not camPos then
		error("No CamPos in GlitchRoom")
	end
	GeneralRemotes.ChangeCameraSubject:FireClient(PlayerRef, camPos.CFrame)
end

local function RevealLandMine()
	if not LandMine then
		error("Cannot find LandMine reference")
		return
	end

	task.spawn(function()
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local goal = { Scale = vector.create(1.583, 0.866, 1.592) }
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
	-- set global player ref so we don't have to pass arguments everywhere
	PlayerRef = player

	if not PlayerRef then
		error("No player reference for BosnianRoulette")
		return
	end

	SetCameraPosition()
	RevealLandMine()

	BosnianRoulette.InitGUI()
	BosnianRoulette.StartBomb()
end

function BosnianRoulette.InitGUI()
	local playerGUI = PlayerRef:WaitForChild("PlayerGui")

	if not playerGUI:FindFirstChild("BosnianRouletteGUI") then
		GUIInstance = GUILocation:Clone()
		GUIInstance.Parent = playerGUI
		GeneralRemotes.InitializeGUI:FireClient(PlayerRef, "BosnianRoulette")
	end
end

function BosnianRoulette.ChangeTurn()
	if CurrentTime <= 0 then
		return
	end

	YourTurn = not YourTurn

	if YourTurn then
		GUIInstance.Enabled = true
	else
		GUIInstance.Enabled = false
		BosnianRoulette.NPCTurn()
	end
end

function BosnianRoulette.ReduceBombTime(val)
	CurrentTime -= val
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "Keypad")
	BosnianRoulette.ChangeTurn()
end

function BosnianRoulette.NPCTurn()
	task.wait(math.random(1, 3)) -- think time
	local choice
	if CurrentTime <= 30 then
		-- Super risky stage: often small reductions, sometimes bigger
		if math.random() < 0.7 then
			choice = math.random(1, 5) -- usually cautious
		else
			choice = math.random(5, 15) -- occasional gamble
		end
	elseif CurrentTime <= 60 then
		-- High danger: mostly mid reductions
		if math.random() < 0.5 then
			choice = math.random(5, 10)
		else
			choice = math.random(10, 20)
		end
	elseif CurrentTime <= 150 then
		-- Mid game: reduce aggressively but not insane
		choice = math.random(10, 40)
	else
		-- Early game: huge reductions
		choice = math.random(20, 60)
	end

	-- Add a little unpredictability (5% chance of "mistake")
	if math.random(1, 100) <= 5 then
		choice = math.random(1, 3)
	end

	BosnianRoulette.ReduceBombTime(choice)
end

function BosnianRoulette.StartBomb()
	local rampStart = 30 -- seconds before end when pitch starts rising
	local minPitch = 1
	local maxPitch = 2
	local done = false
	while CurrentTime > 0 do
		BeepSound:Play()

		local progress = 0
		if CurrentTime <= rampStart then
			progress = 1 - (CurrentTime / rampStart)
		end

		-- delay accelerates only in final ramp
		local minDelay = 0.1
		local maxDelay = 1
		local delayTime = maxDelay - (maxDelay - minDelay) * (progress ^ 2)

		-- pitch ramps up only in final ramp
		BeepSound.PlaybackSpeed = minPitch + (maxPitch - minPitch) * (progress ^ 2)

		task.wait(delayTime)
		CurrentTime -= delayTime

		print(CurrentTime)
	end
	if not done then
		done = true
		BoomSound:Play()
		print(YourTurn)
		GUIInstance.Enabled = false

		local explosion = Instance.new("Explosion")
		explosion.Position = LandMine.Position
		explosion.BlastPressure = 0
		explosion.BlastRadius = 0
		explosion.DestroyJointRadiusPercent = 0
		explosion.Parent = workspace
		-- fade to black
		GeneralRemotes.BlackFade:FireClient(PlayerRef, 0.1, 0)
		BosnianRoulette.SetupCutscene(YourTurn)
		print("BOOM")
	end
end

function BosnianRoulette.SetupCutscene(yourTurnAtDetonation)
	-- player lose
	if yourTurnAtDetonation then
		print("Lose")
		local playerClone = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Glitcher", "PlayerClone", nil)
		GeneralRemotes.StopAllMusic:InvokeClient(PlayerRef)
		task.wait(5)
		GeneralRemotes.BlackFade:FireClient(PlayerRef, 2, 1)
		GeneralRemotes.PlayCutscene:FireClient(PlayerRef, "GlitcherFail")
		task.wait(3)
		local humanoid = playerClone.Humanoid
		if humanoid then
			BadgeHandler.awardBadge(PlayerRef, 2121837446715483)
			humanoid:MoveTo(playerClone:FindFirstChild("WalkPoint").CFrame.Position)
			humanoid.MoveToFinished:Wait()
			task.wait(6)
			GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "RebelsOverLads")
			local connection
			connection = GeneralRemotes.SoundEnded.OnServerEvent:Connect(function(_, finishedName)
				if finishedName == "RebelsOverLads" then
					connection:Disconnect()
					humanoid.Health = 0
					GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "BloodSpurt")
				end
			end)
		end
	else
		print("Win")
		GeneralRemotes.StopAllMusic:InvokeClient(PlayerRef)
		GeneralRemotes.BlackFade:FireClient(PlayerRef, 0.1, 0)
		workspace:FindFirstChild("GlitchRoom"):FindFirstChild("Owner"):Destroy()
		workspace:FindFirstChild("GlitchRoom"):FindFirstChild("LandMine"):Destroy()
		ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Glitcher", "OwnerDead", nil)
		ServerHelperFunctions.SpawnModelAtPosition("Rooms", "ScamRoom", "ScamRoom", nil)
		task.wait(1)
		BadgeHandler.awardBadge(PlayerRef, 2760480705679050)
		GeneralRemotes.BlackFade:FireClient(PlayerRef, 2, 1)
		GeneralRemotes.PlayCutscene:FireClient(PlayerRef, "GlitcherWin")
	end
end

return BosnianRoulette
