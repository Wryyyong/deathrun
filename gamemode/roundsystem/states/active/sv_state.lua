local DR = DR

local PlayerFilters = DR.PlayerFilters
local RoundSystem = DR.RoundSystem

local CvRoundDuration = DR.ConVars.RoundDuration

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
	if PlayerFilters.Playing:GetCount() < 2 then
		RoundSystem.RoundSwitch(DR_ROUND_WAITING)

		return
	end

	local allGoneRunners = PlayerFilters.RunnersAlive:GetCount() == 0
	local allGoneDeaths = PlayerFilters.DeathsAlive:GetCount() == 0
	local winTeam

	if RoundSystem.GetTimer() <= 0 or allGoneDeaths and allGoneRunners then
		winTeam = DR_WIN_STALEMATE
	elseif allGoneDeaths then
		winTeam = DR_WIN_RUNNERS
	elseif allGoneRunners then
		winTeam = DR_WIN_DEATHS
	else return end

	RoundSystem.FinishRound(winTeam)
end
