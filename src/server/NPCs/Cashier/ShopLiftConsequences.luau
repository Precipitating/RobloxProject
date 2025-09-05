local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local BadgeHandler = require(ServerScriptService.Server.BadgeHandler)
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local CurrentFade = 1
local FullyBlack = false
local BerateLines = {
	"Thief",
	"Robber",
	"Pilferer",
	"Stealer",
	"Burglar",
	"Looter",
	"Sneak",
	"Kleptomaniac",
	"Snatcher",
	"Booster",
	"Retail criminal",
	"Store thief",
	"Shop robber",
}
local ShopLiftConsequences = {}

function ShopLiftConsequences.IsBlackedOut()
	return FullyBlack
end

function ShopLiftConsequences.FadeOut(player)
	CurrentFade = math.max(0, CurrentFade - 0.1)
	GeneralRemotes.BlackFade:FireClient(player, 1, CurrentFade)
	print(CurrentFade)
	if CurrentFade <= 0.001 then
		print("Should be fully faded")
		FullyBlack = true
		return
	end
end

function ShopLiftConsequences.SpawnJacker(player)
	local character = player.Character
	local hrp = character:FindFirstChild("HumanoidRootPart")

	-- spawn jacker 150 studs in behind  player
	local spawnPos: Vector3 = hrp.Position
		+ hrp.CFrame.RightVector
		+ hrp.CFrame.UpVector * 3
		+ (hrp.CFrame.LookVector * -150)
	local jacker = HelperFunctions.SpawnModelAtPosition("MissionModels", "Cashier", "Jacker", spawnPos)
	local collisionBox = jacker:FindFirstChild("CollisionBox")
	local primary = jacker.PrimaryPart

	-- face the player
	local lookAt = hrp.Position - spawnPos
	lookAt = Vector3.new(lookAt.X, 0, lookAt.Z).Unit

	jacker:SetPrimaryPartCFrame(CFrame.lookAt(spawnPos, spawnPos + lookAt))

	-- tween forwards
	local stepDistance = 500
	local stepDuration = 2

	local goalPosition = primary.Position + primary.CFrame.LookVector * stepDistance
	local goalCFrame = CFrame.new(goalPosition) * primary.CFrame.Rotation

	local tween =
		TweenService:Create(primary, TweenInfo.new(stepDuration, Enum.EasingStyle.Linear), { CFrame = goalCFrame })

	-- remove accessories and limbs until bare bones
	local attackTouchEvent
	local hasAttacked = false
	attackTouchEvent = collisionBox.Touched:Connect(function(hit)
		local character = hit.Parent
		local humanoid = character and character:FindFirstChild("Humanoid")
		if humanoid then
			if hasAttacked then
				return
			end
			hasAttacked = true

			print("Hit player")
			GeneralRemotes.PlaySound:InvokeClient(player, "Chomp")
			ShopLiftConsequences.FadeOut(player)
			local accessoryFound = false
			-- destroy accessories first
			for _, child in ipairs(character:GetChildren()) do
				if child:IsA("Accessory") then
					child:Destroy()
					accessoryFound = true
					break
				end
			end

			if not accessoryFound then
				for _, child in ipairs(character:GetChildren()) do
					if child:IsA("BasePart") then
						local name = child.Name
						if name:lower():find("arm") or name:lower():find("leg") then
							child:Destroy()
							break
						end
					end
				end
			end
			attackTouchEvent:Disconnect()
		end
	end)
	tween:Play()

	-- destroy after tween finishes
	tween.Completed:Connect(function()
		if attackTouchEvent then
			attackTouchEvent:Disconnect()
		end
		jacker:Destroy()
	end)
end

function ShopLiftConsequences.SpawnTrap(player, modelName, soundName, forwardDist, topOffset, stunTime, lifeTime)
	local character = player.Character
	if not character then
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	-- spawn position: forward + upward offset
	local spawnPos = hrp.Position + hrp.CFrame.LookVector * forwardDist + Vector3.new(0, topOffset or 0, 0)

	local trap = HelperFunctions.SpawnModelAtPosition("MissionModels", "Cashier", modelName, spawnPos)

	local trapTouched
	trapTouched = trap.Base.Touched:Connect(function(hit)
		local humanoid = hit.Parent and hit.Parent:FindFirstChild("Humanoid")
		if not humanoid or humanoid.PlatformStand then
			return
		end

		-- stun player
		GeneralRemotes.PlaySound:InvokeClient(player, soundName)
		humanoid.PlatformStand = true
		GeneralRemotes.DisableControls:FireClient(player)
		GeneralRemotes.Blur:FireClient(player, 1, 100)

		ShopLiftConsequences.FadeOut(player)

		-- restore after stun time
		task.delay(stunTime or 3, function()
			if humanoid and humanoid.Parent then
				humanoid.PlatformStand = false
				GeneralRemotes.EnableControls:FireClient(player)
				GeneralRemotes.Blur:FireClient(player, 1, 0)
			end
		end)
		trapTouched:Disconnect()
	end)
	-- destroy trap after life time
	task.delay(lifeTime or 3, function()
		if trapTouched then
			trapTouched:Disconnect()
		end
		trap:Destroy()
	end)
end

function ShopLiftConsequences.InvertControls(player)
	GeneralRemotes.InvertControls:FireClient(player, true)
	task.delay(5, function()
		GeneralRemotes.InvertControls:FireClient(player, false)
	end)
end

function ShopLiftConsequences.Berate(player)
	local displayName = player.DisplayName
	local line = `You're a {BerateLines[math.random(1, #BerateLines)]}, {displayName}`
	-- speed range: 0.5, 2.0
	-- pitch range - -12, 12
	-- voice Id range - 1 - 10
	-- volume range - 1, 3
	GeneralRemotes.PlayTTS:InvokeClient(
		player,
		line,
		math.random(1, 10),
		math.random(-12, 12),
		math.random(0.5, 2),
		math.random(1, 3)
	)
end

function ShopLiftConsequences.SpawnLightningBolt(player)
	local character = player.Character
	local hrp = character:FindFirstChild("HumanoidRootPart")

	local lightningBolt =
		HelperFunctions.SpawnModelAtPosition("MissionModels", "Cashier", "LightningBolt", hrp.Position)
	local bolt = lightningBolt:FindFirstChild("Bolt")

	-- flash
	bolt.Transparency = 1
	bolt.Transparency = 0.5
	task.wait(0.1)
	bolt.Transparency = 0
	task.wait(0.1)
	bolt.Transparency = 0.5
	task.wait(0.1)
	bolt.Transparency = 1
	task.wait(0.1)

	-- explosion
	local explosionPart = bolt:FindFirstChild("BlastCenter")
	local explosion = Instance.new("Explosion")
	explosion.Parent = game.Workspace
	explosion.Position = explosionPart.Position
	explosion.BlastRadius = 0

	-- black bodyparts
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("BasePart") then
			child.Color = Color3.fromRGB(0, 0, 0)
		end
	end

	-- stun
	GeneralRemotes.DisableControls:FireClient(player)
	ShopLiftConsequences.FadeOut(player)
	GeneralRemotes.PlaySound:InvokeClient(player, "LightningBolt")

	task.delay(2, function()
		GeneralRemotes.EnableControls:FireClient(player)
		lightningBolt:Destroy()
	end)
end

function ShopLiftConsequences.SpawnMeteorite(player)
	GeneralRemotes.StopAllMusic:InvokeClient(player)
	BadgeHandler.awardBadge(player, 2207943165943416)
	local timeLength = GeneralRemotes.PlayTTS:InvokeClient(
		player,
		`Stanley - I mean {player.DisplayName} couldn't believe his bad luck... how was this possible, and why? Surely it wasn't the groceries wasn't the culprit. Surely... Just when things were down, this happened.`,
		1,
		1,
		1,
		1
	)

	task.wait(timeLength)
	GeneralRemotes.PlayTheme:FireClient(player, "AirSiren")
	local character = player.Character
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local targetPos = CFrame.new(hrp.Position + Vector3.new(0, 1000, 0))

	local meteorite = HelperFunctions.SpawnModelAtPosition("MissionModels", "Cashier", "Meteorite", nil)

	local tween =
		TweenService:Create(meteorite.PrimaryPart, TweenInfo.new(5, Enum.EasingStyle.Linear), { CFrame = targetPos })

	tween:Play()
	GeneralRemotes.CameraLookAt:FireClient(player, meteorite.Name)
	GeneralRemotes.BlackFade:FireClient(player, 0.2, 1)
	tween.Completed:Connect(function()
		GeneralRemotes.BlackFade:FireClient(player, 0, 0)
		local done = GeneralRemotes.StopAllMusic:InvokeClient(player)
		GeneralRemotes.CameraLookAtDisconnect:FireClient(player)
		if done then
			GeneralRemotes.PlaySound:InvokeClient(player, "Nuke")
		end
		GeneralRemotes.Rejoin:FireClient(player, 7)
	end)
end

return ShopLiftConsequences
