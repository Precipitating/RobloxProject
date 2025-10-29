local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local BadgeHandler = require(ServerScriptService.Server.BadgeHandler)
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local GeneralRemotes = ReplicatedStorage.Remotes
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

local function JackerTouchConnection(jacker, primary, player, collisionBox)
	local STEP_DISTANCE = 500
	local STEP_DURATION = 2
	local hasAttacked = false
	-- jacker straight line bulldoze towards player from ? distance
	local function BulldozeTween()
		local goalPosition = primary.Position + primary.CFrame.LookVector * STEP_DISTANCE
		local goalCFrame = CFrame.new(goalPosition) * primary.CFrame.Rotation
		local tween =
			TweenService:Create(primary, TweenInfo.new(STEP_DURATION, Enum.EasingStyle.Linear), { CFrame = goalCFrame })
		tween:Play()
		tween.Completed:Once(function()
			jacker:Destroy()
		end)
	end

	local function DestroyAccessories(character)
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Accessory") then
				child:Destroy()
				return true
			end
		end
		return false
	end

	local function DestroyLimbs(character)
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("BasePart") then
				local name = child.Name:lower()
				if name:find("arm") or name:find("leg") then
					child:Destroy()
					break
				end
			end
		end
	end

	local function OnJackerHitPlayerConnection()
		collisionBox.Touched:Connect(function(hit)
			local character = hit.Parent
			local humanoid = character and character:FindFirstChild("Humanoid")
			if not humanoid or hasAttacked then
				return
			end

			hasAttacked = true
			print("Hit player")
			GeneralRemotes.PlaySound:InvokeClient(player, "Chomp")
			ShopLiftConsequences.FadeOut(player)

			if not DestroyAccessories(character) then
				DestroyLimbs(character)
			end
		end)
	end

	OnJackerHitPlayerConnection()
	BulldozeTween()
end

function ShopLiftConsequences.SpawnJacker(player)
	local character = player.Character
	local hrp = character:FindFirstChild("HumanoidRootPart")

	-- spawn jacker 150 studs in behind  player
	local function SpawnJackerNow()
		local spawnPos: Vector3 = hrp.Position
			+ hrp.CFrame.RightVector
			+ hrp.CFrame.UpVector * 3
			+ (hrp.CFrame.LookVector * -150)
		local jacker = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Cashier", "Jacker", spawnPos)
		local collisionBox = jacker:FindFirstChild("CollisionBox")
		local primary = jacker.PrimaryPart

		return spawnPos, jacker, primary, collisionBox
	end
	-- face the player
	local function FacePlayer(spawnPos, jacker, primary, collisionBox)
		-- face the player
		local lookAt = hrp.Position - spawnPos
		lookAt = vector.normalize(vector.create(lookAt.X, 0, lookAt.Z))
		jacker:SetPrimaryPartCFrame(CFrame.lookAt(spawnPos, spawnPos + lookAt))
		JackerTouchConnection(jacker, primary, player, collisionBox)
	end

	local spawnPos, jacker, primary, collisionBox = SpawnJackerNow()
	FacePlayer(spawnPos, jacker, primary, collisionBox)
end

local function TrapTouchedConnection(player, trap, stunTime, lifeTime, soundName)
	local function Stun(humanoid)
		-- stun player
		GeneralRemotes.PlaySound:InvokeClient(player, soundName)
		humanoid.PlatformStand = true
		GeneralRemotes.DisableControls:FireClient(player)
		GeneralRemotes.BlackFade:FireClient(player, 1, 100)
	end

	local function StunRecover(humanoid)
		-- restore after stun time
		task.delay(stunTime or 3, function()
			if humanoid and humanoid.Parent then
				humanoid.PlatformStand = false
				GeneralRemotes.EnableControls:FireClient(player)
				GeneralRemotes.Blur:FireClient(player, 1, 0)
			end
		end)
	end
	local function TrapDestroy(trapTouched)
		-- destroy trap after life time
		task.delay(lifeTime or 3, function()
			if trapTouched then
				trapTouched:Disconnect()
			end
			trap:Destroy()
		end)
	end

	local trapTouched
	-- stun player if trap touched
	trapTouched = trap.Base.Touched:Connect(function(hit)
		local humanoid = hit.Parent and hit.Parent:FindFirstChild("Humanoid")
		if not humanoid or humanoid.PlatformStand then
			return
		end
		Stun(humanoid)
		ShopLiftConsequences.FadeOut(player)
		StunRecover(humanoid)
		trapTouched:Disconnect()
	end)

	TrapDestroy(trapTouched)
end
function ShopLiftConsequences.SpawnTrap(player, modelName, soundName, forwardDist, topOffset, stunTime, lifeTime)
	-- reference validation
	local character = player.Character
	if not character then
		return
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	-- spawn position: forward + upward offset
	local spawnPos = hrp.Position + hrp.CFrame.LookVector * forwardDist + vector.create(0, topOffset or 0, 0)
	local trap = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Cashier", modelName, spawnPos)
	TrapTouchedConnection(player, trap, stunTime, lifeTime, soundName)
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
	local randomConfig = {
		VoiceId = tostring(math.random(1, 10)),
		Pitch = math.random(-12, 12),
		Speed = math.random(0.5, 2),
		Volume = math.random(1, 3),
	}
	GeneralRemotes.PlayTTS:InvokeClient(player, line, randomConfig)
end

function ShopLiftConsequences.SpawnLightningBolt(player)
	-- ref validation
	local character = player.Character
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local lightningBolt =
		ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Cashier", "LightningBolt", hrp.Position)
	local bolt = lightningBolt:FindFirstChild("Bolt")

	local function Flash()
		bolt.Transparency = 1
		bolt.Transparency = 0.5
		task.wait(0.1)
		bolt.Transparency = 0
		task.wait(0.1)
		bolt.Transparency = 0.5
		task.wait(0.1)
		bolt.Transparency = 1
		task.wait(0.1)
	end

	local function Explosion()
		-- explosion
		local explosionPart = bolt:FindFirstChild("BlastCenter")
		local explosion = Instance.new("Explosion")
		explosion.Parent = game.Workspace
		explosion.Position = explosionPart.Position
		explosion.BlastRadius = 0
	end

	local function BlackBodyParts()
		-- black bodyparts
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("BasePart") then
				child.Color = Color3.fromRGB(0, 0, 0)
			end
		end
	end

	local function Stun()
		-- stun
		GeneralRemotes.DisableControls:FireClient(player)
		ShopLiftConsequences.FadeOut(player)
		GeneralRemotes.PlaySound:InvokeClient(player, "LightningBolt")
	end

	local function StunRecover()
		-- stop stun
		task.delay(2, function()
			GeneralRemotes.EnableControls:FireClient(player)
			lightningBolt:Destroy()
		end)
	end

	Flash()
	Explosion()
	BlackBodyParts()
	Stun()
	StunRecover()
end

function ShopLiftConsequences.SpawnMeteorite(player)
	GeneralRemotes.StopAllMusic:InvokeClient(player)
	BadgeHandler.awardBadge(player, 2207943165943416)
	local config = {
		VoiceId = "1",
		Pitch = 1,
		Speed = 1,
		Volume = 1,
	}

	local function PlayNarration()
		local timeLength = GeneralRemotes.PlayTTS:InvokeClient(
			player,
			`Stanley - I mean {player.DisplayName} couldn't believe his bad luck... how was this possible, and why? Surely it wasn't the groceries wasn't the culprit. Surely... Just when things were down, this happened.`,
			config
		)
		task.wait(timeLength)
	end

	local function MeteoriteSpawnAndMove()
		local character = player.Character
		local hrp = character:FindFirstChild("HumanoidRootPart")

		local targetPos = CFrame.new(hrp.Position + vector.create(0, 1000, 0))
		local meteorite = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Cashier", "Meteorite", nil)

		local tween = TweenService:Create(
			meteorite.PrimaryPart,
			TweenInfo.new(5, Enum.EasingStyle.Linear),
			{ CFrame = targetPos }
		)
		tween:Play()
		GeneralRemotes.CameraLookAt:FireClient(player, meteorite.Name)
		return tween
	end

	local function MeteoriteTweenComplete(tween)
		tween.Completed:Once(function()
			GeneralRemotes.BlackFade:FireClient(player, 0, 0)
			local done = GeneralRemotes.StopAllMusic:InvokeClient(player)
			GeneralRemotes.CameraLookAtDisconnect:FireClient(player)
			if done then
				GeneralRemotes.PlaySound:InvokeClient(player, "Nuke")
			end
			GeneralRemotes.Rejoin:FireClient(player, 7)
		end)
	end

	PlayNarration()
	GeneralRemotes.PlayTheme:FireClient(player, "AirSiren")
	local tween = MeteoriteSpawnAndMove()
	MeteoriteTweenComplete(tween)
	GeneralRemotes.BlackFade:FireClient(player, 0.2, 1)
end

return ShopLiftConsequences
