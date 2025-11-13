local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ScreenGUIHandler = {}

function ScreenGUIHandler.DisableAllGUI(val)
	if val then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
		-- disable custom GUI
		for _, gui in ipairs(PlayerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and not CollectionService:HasTag(gui, "Untouchable") then
				gui.Enabled = false
			end
		end
	else
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
		for _, gui in ipairs(PlayerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and not CollectionService:HasTag(gui, "Untouchable") then
				gui.Enabled = true
			end
		end
	end
end

return ScreenGUIHandler
