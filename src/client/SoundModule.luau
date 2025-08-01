local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Currencies = require(ReplicatedStorage.Shared.FeaturePackagesCore.Configs.Currencies)
local mainSound = ReplicatedStorage.Shared.Sounds.Main
local soundLocation = ReplicatedStorage.Shared.Sounds
local currentTheme = nil
local SoundHandler = {}

function SoundHandler.GetCurrentTheme()
	if currentTheme then
		return soundLocation:FindFirstChild(currentTheme)
	else
		return nil
	end
end

function SoundHandler.StopSound(soundName)
	print(`Stopping {soundName}`)
	if soundName then
		soundLocation:FindFirstChild(soundName):Stop()
		soundName = nil
	else
		warn("No sound to stop, it's nil")
	end
end

function SoundHandler.StopAllSounds()
	print("Stopping all sounds...")
	local sounds = soundLocation:GetChildren()
	for _, sound in pairs(sounds) do
		if sound:IsA("Sound") and sound.IsPlaying then
			print(sound.Name)
			sound:Stop()
		end
	end
	SoundHandler.StopTheme()
end

function SoundHandler.PlayTheme(name)
	if currentTheme then
		SoundHandler.StopTheme()
	end

	local newTheme = soundLocation:FindFirstChild(name)
	if newTheme and not newTheme.IsPlaying then
		if newTheme.IsPaused then
			newTheme:Resume()
		else
			newTheme:Play()
		end
		currentTheme = name

		print(`Theme set {currentTheme}`)
	else
		print("Theme not found")
		currentTheme = nil
	end
end

function SoundHandler.StopTheme()
	if currentTheme then
		local theme = soundLocation:FindFirstChild(currentTheme)
		if theme and theme:IsA("Sound") and theme.IsPlaying then
			print(`{currentTheme} stopped`)
			theme:Stop()
		else
			print("Theme not found or not playing to be stopped")
		end
		currentTheme = nil
	else
		print("No current theme to stop")
	end
end

function SoundHandler.PauseTheme()
	if currentTheme then
		local curr = soundLocation:FindFirstChild(currentTheme)
		if curr and curr.IsPlaying then
			curr:Pause()
		else
			print("Theme cannot be found to be paused")
		end
	end
end

function SoundHandler.ResumeTheme()
	if currentTheme then
		local curr = soundLocation:FindFirstChild(currentTheme)
		if curr and not curr.IsPlaying then
			curr:Resume()
		else
			print("Theme cannot be found to be resumed")
		end
	end
end

function SoundHandler.PlaySound(soundName)
	--print(`Playing {soundName}`)
	if soundName then
		soundLocation:FindFirstChild(soundName):Play()

		if mainSound then
			mainSound:Pause()
		end
	else
		warn("No sound to play, its nil.")
	end
end

return SoundHandler
