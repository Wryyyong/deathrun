local Iterator = ipairs({})

local DR = DR

local CvRoundDuration = DR.ConVars.RoundDuration

local RoundSystem = DR.RoundSystem

--[[
local function AutoslayDelay()
	for _,ply in Iterator,DR.GetAllPlaying(),0 do
		local idleTime = DR.CheckIdleTime()

		if idleTime <= CvAutoslayDelay:GetInt() then continue end

		NetStart("DeathrunSpectatorNotification")
		NetSend(ply)

		if ply:Team() == DR_TEAM_DEATH then
			DR.PunishDeathAvoid(ply,CvDeathAvoidPunishment:GetInt())

			DR.ChatBroadcast("Player " .. ply:Nick() .. " went AFK during a Death round! They will be punished.")
		end

		ply:ConCommand("deathrun_spectate_only 1")
	end
end
--]]

function ROUNDSTATE:EnterRealm()
	RoundSystem.SetTimer(CvRoundDuration:GetInt())

	--TimerCreate("DeathrunAutoslay",CvAutoslayDelay:GetInt() + 5,1,AutoslayDelay)
end

function ROUNDSTATE:ThinkRealm()
	local playing = DR.GetAllPlaying()

	if #playing < 2 then
		RoundSystem.RoundSwitch(DR_ROUND_WAITING)

		return
	end

	local deaths = {}
	local runners = {}

	for _,ply in Iterator,playing,0 do
		if not ply:Alive() then continue end

		local targetTbl
		local plyTeam = ply:Team()

		if plyTeam == DR_TEAM_RUNNER then
			targetTbl = runners
		elseif plyTeam == DR_TEAM_DEATH then
			targetTbl = deaths
		else continue end

		targetTbl[#targetTbl + 1] = ply
	end

	local allGoneDeaths = #deaths == 0
	local allGoneRunners = #runners == 0
	local winTeam

	if allGoneDeaths and allGoneRunners or RoundSystem.GetTimer() == 0 then
		winTeam = DR_WIN_STALEMATE
	elseif allGoneDeaths then
		winTeam = DR_WIN_RUNNERS
	elseif allGoneRunners then
		winTeam = DR_WIN_DEATHS
	else return end

	RoundSystem.FinishRound(winTeam)
end
