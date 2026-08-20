local HookRun = hook.Run

local TimerSimple = timer.Simple

local DR = DR

local ConVars = DR.ConVars
local MapVote = DR.MapVote

local CvFinishDuration = ConVars.FinishDuration
local CvRoundLimit = ConVars.RoundLimit

local RoundSystem = DR.RoundSystem

local function RestartRound()
	RoundSystem.RoundSwitch(DR_ROUND_PREP)
end

function ROUNDSTATE:EnterRealm()
	local roundsPlayed = RoundSystem.RoundsPlayed
	local roundLimit = CvRoundLimit:GetInt()

	if
		not HookRun("DeathrunShouldMapSwitch",roundsPlayed)
	and	roundsPlayed < roundLimit
	then
		DR.ChatBroadcast("Round " .. roundsPlayed .. " over. " .. (roundLimit - roundsPlayed) .. " rounds to go!")

		local finishDur = CvFinishDuration:GetInt()

		RoundSystem.SetTimer(finishDur)

		TimerSimple(finishDur,RestartRound)
	else
		--DR.ChatBroadcast("Round limit reached. Initiating RTV...")

		TimerSimple(3,function()
			if HookRun("DeathrunStartMapvote",roundsPlayed) then return end

			MapVote.BeginMapVote()
		end)
	end
end
