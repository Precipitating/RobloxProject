local ReplicatedStorage = game:GetService("ReplicatedStorage")
local soundLocation = ReplicatedStorage.Shared.Sounds
local SoundHandler = {}

function SoundHandler.PlaySound(soundName)
	print(`Playing {soundName}`)
	soundLocation:WaitForChild(soundName):Play()
end

return SoundHandler
