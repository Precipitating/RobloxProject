local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundLocation = ReplicatedStorage.Shared.Sounds
local CurrentTheme = nil
local SoundHandler = {}

function SoundHandler.GetCurrentTheme()
	if CurrentTheme then
		return SoundLocation:FindFirstChild(CurrentTheme)
	else
		return nil
	end
end

function SoundHandler.StopSound(soundName)
	print(`Stopping {soundName}`)
	if soundName then
		SoundLocation:FindFirstChild(soundName):Stop()
		soundName = nil
	else
		warn("No sound to stop, it's nil")
	end
end

function SoundHandler.StopAllSounds()
	print("Stopping all sounds...")
	local sounds = SoundLocation:GetChildren()
	for _, sound in pairs(sounds) do
		if sound:IsA("Sound") and sound.IsPlaying then
			if CollectionService:HasTag(sound, "Unstoppable") then
				continue
			end
			print(`Stopped {sound.Name}`)
			sound:Stop()
		end
	end
	CurrentTheme = nil
end

function SoundHandler.PlayTheme(name)
	if CurrentTheme then
		print(`Should stop {CurrentTheme}`)
		SoundHandler.StopTheme()
	end

	local newTheme = SoundLocation:FindFirstChild(name)
	if newTheme and not newTheme.IsPlaying then
		if newTheme.IsPaused then
			newTheme:Resume()
		else
			newTheme:Play()
		end
		CurrentTheme = name

		print(`Theme set {CurrentTheme}`)
	else
		print("Theme not found")
		CurrentTheme = nil
	end
end

function SoundHandler.StopTheme()
	if CurrentTheme then
		local theme = SoundLocation:FindFirstChild(CurrentTheme)
		if theme and theme:IsA("Sound") and theme.IsPlaying then
			print(`{CurrentTheme} stopped`)
			theme:Stop()
		else
			print("Theme not found or not playing to be stopped")
		end
		CurrentTheme = nil
	else
		print("No current theme to stop")
	end
end

function SoundHandler.PauseTheme()
	if CurrentTheme then
		local curr = SoundLocation:FindFirstChild(CurrentTheme)
		if curr and curr.IsPlaying then
			curr:Pause()
		else
			print("Theme cannot be found to be paused")
		end
	end
end

function SoundHandler.ResumeTheme()
	if CurrentTheme then
		local curr = SoundLocation:FindFirstChild(CurrentTheme)
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
		local sound = SoundLocation:FindFirstChild(soundName)
		if not sound.IsPlaying then
			sound:Play()
		else
			sound.TimePosition = 0
		end
		return sound
	else
		warn("No sound to play, its nil.")
		return nil
	end
end

function SoundHandler.ChangeThemePlaybackSpeed(val)
	local theme = SoundHandler.GetCurrentTheme()

	if theme then
		theme.PlaybackSpeed = val
	end
end

return SoundHandler
