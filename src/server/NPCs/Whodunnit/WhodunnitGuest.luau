local Chat = game:GetService("Chat")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local GeneralRemotes = ReplicatedStorage.Remotes
local TweenService = game:GetService("TweenService")
local Dialogue = {
	"I can't see!",
	"how to play?",
	"i'm scared omg",
	"HELP ME",
	"whats happening?",
	"my screen is black",
	"this game is scary",
	"can i play",
	"why u blind me",
	"im so scared oooh, heh so scarrry..",
	"can i be host plz",
	"why is a blue tentacle guy in admin commands shirt comments saying its a scam? iZzap..?",
}
local IsPanicking = false
local GuestHeads = {}
local WhodunnitGuest = {}

function WhodunnitGuest.SetPanicking(val)
	IsPanicking = val
end
function WhodunnitGuest.RemoveHeadFromTable(key)
	GuestHeads[key] = nil
end
function WhodunnitGuest.ToggleCanKillPrompt(val)
	for _, head in pairs(GuestHeads) do
		head.Parent:FindFirstChildWhichIsA("ProximityPrompt").Enabled = val
	end
end

function WhodunnitGuest.DestroyAllGuests()
	for _, head in pairs(GuestHeads) do
		head:FindFirstAncestorOfClass("Folder"):Destroy()
		break
	end
	table.clear(GuestHeads)
end

function WhodunnitGuest.AllGuestsSpeak(player, textTable)
	local idx = 1
	for _, head in pairs(GuestHeads) do
		local tts = head.Parent:FindFirstChildWhichIsA("AudioTextToSpeech")
		tts.Text = textTable[idx]
		idx += 1
		GeneralRemotes.Whodunnit.Speak3D:InvokeClient(player, tts, nil)
	end
end

function WhodunnitGuest.DiscussVoteSelection(player)
	local DiscussDialogue = {
		"How to play. Can I be Host Pleez. I no admin abuse.",
		"According to my calculations, this is reverse psychology. I know exactly what this is as I have watched Life Note and Protect The 3 foot titan. I know exactly who to pick.",
	}
	WhodunnitGuest.AllGuestsSpeak(player, DiscussDialogue)
end

function WhodunnitGuest.AnnouncePlayerIsMurderer(player)
	local CaughtDialogue = {
		`{player.DisplayName}, just put the knife in the bag bro`,
		`I pick {player.DisplayName}. Do I even need to explain?`,
		`{player.DisplayName}, thanks for the easy win. You are the weakest link. Goodbye.`,
	}

	WhodunnitGuest.AllGuestsSpeak(player, CaughtDialogue)
end

function WhodunnitGuest.TurnGuestHeadsToPlayer(target)
	local tween = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for key, head in pairs(GuestHeads) do
		print(key)
		task.spawn(function()
			local goal = {
				CFrame = CFrame.lookAt(head.Position, target.Position),
			}
			TweenService:Create(head, tween, goal):Play()
		end)
	end
end

function WhodunnitGuest.StartPanicking(head)
	GuestHeads[head.Parent.Name] = head
	task.spawn(function()
		while IsPanicking do
			Chat:Chat(head, Dialogue[math.random(1, #Dialogue)])
			task.wait(math.random(7, 10))
		end
	end)
end

return WhodunnitGuest
