local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local PlayThemeRemote = ReplicatedStorage.Remotes.PlayTheme
local APIs = { "https://random-word-api.vercel.app/api?words=", "https://random-word-api.herokuapp.com/word?number=" }
local GeneralRemotes = ReplicatedStorage.Remotes
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local Missions = require(ReplicatedStorage.Missions.Server.Missions)

local WORD_AMOUNT = 30
local DURATION = 60

local wordList = { "The", "API", "Failed", "To", "Load", "So", "Enjoy", "This", "Easy", "Win" }
local whiteBoard = nil
local examRoom = nil
local currentScore = nil
local targetScore = nil
local clockText = nil
local WordType = {}
local currentWordIdx = 1
local finishedExecuted = false
function WordType.GenerateWordList(amount)
	for _, api in APIs do
		api = api .. amount
		local success, response = pcall(function()
			return HttpService:GetAsync(api)
		end)

		if success then
			local data = HttpService:JSONDecode(response)
			return data
		end
	end

	return nil
end

function WordType.StartTimer(textToModify, duration, async, player)
	local function timerLogic()
		for i = duration, 0, -1 do
			if textToModify == clockText then
				-- stop timer if reached target
				if currentWordIdx > #wordList then
					return
				end
			end
			textToModify.Text = tostring(i)
			task.wait(1)
		end

		-- if we reached here, it means timer went to 0, meaning fail
		if textToModify == clockText then
			WordType.Finished(false, player)
		end
	end

	if async then
		task.spawn(timerLogic)
	else
		timerLogic()
	end
end

function WordType.Init(player)
	-- get refs
	wordList = WordType.GenerateWordList(WORD_AMOUNT)
	examRoom = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "PsychoMantis", "ExamRoom", nil)
	clockText = examRoom.Clock.Screen.SurfaceGui.TextLabel
	whiteBoard = examRoom.Whiteboard.SurfaceGui.TextLabel
	currentScore = examRoom.CurrentScore.Screen.SurfaceGui.TextLabel
	targetScore = examRoom.RequiredScore.Screen.SurfaceGui.TextLabel
	local spawnPos = examRoom:FindFirstChild("CameraPos")

	clockText.Text = DURATION

	-- change cam to mission area
	if spawnPos then
		GeneralRemotes.ChangeCameraSubject:FireClient(player, spawnPos.CFrame)
	else
		error("Part not found for camera to move to")
	end

	-- start
	if wordList then
		-- add onFocusLost connection, aim is to detect if enter is pressed + check if matches current word
		GeneralRemotes.PsychoMantis.OnFocusLostConnect:FireClient(player, wordList[currentWordIdx])
		task.wait(1)

		-- set target
		targetScore.Text = tostring(#wordList)
		-- whiteboard timer
		whiteBoard.Text = "Get ready..."
		WordType.StartTimer(whiteBoard, 3, false, player)
		targetScore = tostring(#wordList)
		return true
	else
		return false
	end
end

function WordType.Begin(player)
	-- clock timer
	PlayThemeRemote:FireClient(player, "Intense")
	warn("Intense playing?")
	WordType.StartTimer(clockText, DURATION, true, player)
	whiteBoard.Text = wordList[currentWordIdx]

	GeneralRemotes.PsychoMantis.GetNextWord.OnServerInvoke = function()
		if currentWordIdx >= #wordList then
			currentWordIdx = currentWordIdx + 1
			currentScore.Text = tostring(currentWordIdx - 1)
			WordType.Finished(true, player)
			print("Competition Complete!")
			GeneralRemotes.EnableAllNPCPrompts:FireClient(player, true)
			return "(Finished)"
		end

		currentWordIdx = currentWordIdx + 1
		currentScore.Text = tostring(currentWordIdx - 1)
		whiteBoard.Text = wordList[currentWordIdx]

		return wordList[currentWordIdx]
	end
end

function WordType.Finished(won, player)
	if finishedExecuted then
		return
	end
	-- disconnect events
	finishedExecuted = true
	GeneralRemotes.PsychoMantis.GetNextWord.OnServerInvoke = nil
	GeneralRemotes.PsychoMantis.PsychoMantisEventCleanup:FireClient(player)

	if won then
		whiteBoard.Text = "YOU WIN!"
		local model = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "PsychoMantis", "ExamWin", nil)
		model.Parent = workspace.ExamRoom
		Missions.addProgressToTask(player, "TypingCompetition", "Type", 1)
	else
		whiteBoard.Text = "YOU LOSE!"
		local model = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "PsychoMantis", "ExamLose", nil)
		model.Parent = workspace.ExamRoom
		Missions.FailMission(player, "TypingCompetition")
	end
	GeneralRemotes.BlackFade:FireClient(player, 7, 0)
	task.wait(7)

	GeneralRemotes.StopAllMusic:InvokeClient(player)
	GeneralRemotes.EnableControls:FireClient(player, nil)
	examRoom:Destroy()
	PlayThemeRemote:FireClient(player, "Main")
	GeneralRemotes.ChangeCameraSubject:FireClient(player, nil)
	task.wait(1)
	GeneralRemotes.BlackFade:FireClient(player, 2, 1)

	--
end

return WordType
