local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ScreenGUIHandler = {}

function ScreenGUIHandler.DisableAllGUI(val, toggleDialogue)
	if val then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
		-- disable custom GUI
		for _, gui in ipairs(PlayerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and not CollectionService:HasTag(gui, "Untouchable") then
				gui.Enabled = false
			end

			if gui:IsA("Folder") and gui.Name == "NPCChatSystem" then
				if toggleDialogue then
					gui:WaitForChild("ChatUI").Enabled = not gui.ChatUI.Enabled
				else
					gui:WaitForChild("ChatUI").Enabled = false
				end
			end
		end
	else
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
		for _, gui in ipairs(PlayerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and not CollectionService:HasTag(gui, "Untouchable") then
				gui.Enabled = true
			end
			if gui:IsA("Folder") and gui.Name == "NPCChatSystem" then
				if toggleDialogue then
					gui:WaitForChild("ChatUI").Enabled = not gui.ChatUI.Enabled
				end
			end
		end
	end
end

return ScreenGUIHandler
