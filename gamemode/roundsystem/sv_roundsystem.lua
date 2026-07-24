local DR = DR

local ConVars = DR.ConVars

util.AddNetworkString("DeathrunUpdateRoundState")
util.AddNetworkString("DeathrunSyncRoundTimer")
util.AddNetworkString("DeathrunSendMVPs")

-- send this each time round state changes so that the player can update themselves
function ROUND.RoundSwitch(round) -- this can be used to switch or restart states
	local roundTblOld = ROUND_STATES[ROUND_CURRENT]
	local roundTblNew = ROUND_STATES[round]
	if not roundTblNew then return end

	if roundTblOld then
		roundTblOld.OnExit()
	end

	roundTblNew.OnEnter()

	ROUND_CURRENT = round

	net.Start("DeathrunUpdateRoundState")
		net.WriteUInt(round,16)
	net.Broadcast()

	-- compatibility
	hook.Run("OnRoundSet",round)
end

-- commands
concommand.Add("round_switch",function(ply,_,args)
	if IsValid(ply) then return end

	ROUND.RoundSwitch(tonumber(args[1]))
end)

hook.Add("PlayerInitialSpawn","RoundSyncCurrent",function(ply)
	net.Start("DeathrunUpdateRoundState")
		net.WriteUInt(ROUND.GetCurrent(),16)
	net.Send(ply)
end)

--- @param ply Player?
function ROUND.SyncTimer(ply)
	net.Start("DeathrunSyncRoundTimer")
		net.WriteUInt(ROUND.GetTimer(),16)

	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

--- @param seconds number
function ROUND.SetTimer(seconds)
	ROUND_TIMER = seconds

	ROUND.SyncTimer()
end

hook.Add("PlayerInitialSpawn","DeathrunCleanupSinglePlayer",function(ply)
	ROUND.SyncTimer(ply)

	if player.GetCount() > 1 then return end

	game.CleanUpMap()

	DR.ChatBroadcast("Cleaned up the map.")
end)

-- handle death avoidance here, using the functions defined in init.lua
hook.Add("PlayerDisconnected","DeathrunWatchDeathAvoid",function(ply)
	local roundState = ROUND.GetCurrent()

	if
		not (
			(
				roundState == ROUND_PREP
			or	roundState == ROUND_ACTIVE
			)
		and	ply:Alive()
		and	ply:Team() == TEAM_DEATH
		and	#DR.GetAllPlaying() > 2
		)
	then return end

	DR.PunishDeathAvoid(ply,ConVars.DeathAvoidPunishment:GetInt())

	DR.ChatBroadcast("Player " .. ply:Nick() .. " will be punished for attempting to avoid being on the Death team!")
end)

hook.Add("PlayerDeath","DeathrunMVPs",function(ply,_,attacker)
	if
		not attacker:IsPlayer()
	or	ply == attacker
	then return end

	attacker.KillsThisRound = (attacker.KillsThisRound or 0) + 1
end)

hook.Add("DeathrunBeginActive","DeathrunMVPs",function()
	for _,ply in player.Iterator() do
		ply.KillsThisRound = 0
	end
end)

function ROUND.FinishRound(winningTeam)
	print(winningTeam)

	ROUND.RoundSwitch(ROUND_OVER)

	DR.ChatBroadcast(
		"Round over! " .. (
			winningTeam == WIN_RUNNERS and team.GetName(TEAM_RUNNER) .. " win!"
		or	winningTeam == WIN_DEATHS and team.GetName(TEAM_DEATH) .. " win!"
		or	"Stalemate! Unbelievable!"
		)
	)

	-- calculate MVPs
	--- @type string[]
	local mvpList = {}
	local mostKills = 0
	local mostKillsMvp

	for _,ply in ipairs(DR.GetAllPlaying()) do
		if
			not (
				ply:Alive()
			and	ply:Team() == winningTeam
			)
		then continue end

		mvpList[#mvpList + 1] = ply:Nick() .. " survived the round!"

		if ply.KillsThisRound <= mostKills then continue end

		mostKills = ply.KillsThisRound
		mostKillsMvp = ply
	end

	if mostKillsMvp and winningTeam == TEAM_RUNNER then
		mvpList[#mvpList + 1] = mostKillsMvp:Nick() .. " got " .. mostKills .. " kill" .. (mostKills > 1 and "s" or "") .. "!"
	end

	net.Start("DeathrunSendMVPs")
		net.WriteTable({
			["winteam"] = winningTeam,
			["mvps"] = mvpList,
		})
	net.Broadcast()

	hook.Run("DeathrunRoundWin",winningTeam)

	-- compatibility
	hook.Run("OnRoundSet",ROUND_OVER,winningTeam ~= WIN_STALEMATE and winningTeam or -1)
end

-- initial round
hook.Add("InitPostEntity","DeathrunInitialRoundState",function() ROUND.RoundSwitch(ROUND_WAITING) end)
