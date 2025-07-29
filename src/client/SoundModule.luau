local ReplicatedStorage = game:GetService("ReplicatedStorage")
local soundLocation = ReplicatedStorage.Shared.Sounds
local SoundHandler = {}

function SoundHandler.PlaySound(soundName)
	print(`Playing {soundName}`)
	if soundName then
		soundLocation:WaitForChild(soundName):Play()
	else
		warn("No sound to play, its nil.")
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

return SoundHandler
