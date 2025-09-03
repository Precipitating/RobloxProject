local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local CurrentFade = 1
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

function ShopLiftConsequences.FadeOut(player)
	if CurrentFade == 0 then
		return
	end
	CurrentFade = CurrentFade - 0.1
	GeneralRemotes.BlackFade:FireClient(player, 1, CurrentFade)
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
	local debounce = false
	local attackTouchEvent = collisionBox.Touched:Connect(function(hit)
		if debounce then
			return
		end
		local character = hit.Parent
		local humanoid = character and character:FindFirstChild("Humanoid")
		if humanoid then
			print("Hit player")
			ShopLiftConsequences.FadeOut(player)
			local accessoryFound = false
			-- destroy accessories first
			for _, child in ipairs(character:GetChildren()) do
				if child:IsA("Accessory") then
					child:Destroy()
					accessoryFound = true
					debounce = true
					break
				end
			end

			if not accessoryFound then
				for _, child in ipairs(character:GetChildren()) do
					if child:IsA("BasePart") then
						local name = child.Name
						if name:lower():find("arm") or name:lower():find("leg") then
							child:Destroy()
							debounce = true
							break
						end
					end
				end
			end
		end

		if debounce then
			task.wait(0.5)
			debounce = false
		end
	end)
	tween:Play()

	-- destroy after tween finishes
	tween.Completed:Connect(function()
		jacker:Destroy()
		attackTouchEvent:Disconnect()
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

		trapTouched:Disconnect()

		-- restore after stun time
		task.delay(stunTime or 3, function()
			if humanoid and humanoid.Parent then
				humanoid.PlatformStand = false
				GeneralRemotes.EnableControls:FireClient(player)
				GeneralRemotes.Blur:FireClient(player, 1, 0)
			end
		end)
	end)
	-- destroy trap after life time
	task.delay(lifeTime or 3, function()
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
	-- speed range: 0.5, 2.0
	-- pitch range - -12, 12
	-- voice Id range - 1 - 10
	-- volume range - 1, 3
	GeneralRemotes.PlayTTS:FireClient(
		player,
		BerateLines[math.random(1, #BerateLines)],
		math.random(1, 10),
		math.random(-12, 12),
		math.random(0.5, 2),
		math.random(1, 3)
	)
end

return ShopLiftConsequences
