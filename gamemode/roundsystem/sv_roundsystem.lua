local DR = DR

local ConVars = DR.ConVars
local RoundSystem = DR.RoundSystem

util.AddNetworkString("DeathrunUpdateRoundState")
util.AddNetworkString("DeathrunSyncRoundTimer")
util.AddNetworkString("DeathrunSendMVPs")

-- send this each time round state changes so that the player can update themselves
function RoundSystem.RoundSwitch(round) -- this can be used to switch or restart states
	local roundTblOld = RoundSystem.States[RoundSystem.CurrentState]
	local roundTblNew = RoundSystem.States[round]
	if not roundTblNew then return end

	if roundTblOld then
		roundTblOld.OnExit()
	end

	roundTblNew.OnEnter()

	RoundSystem.CurrentState = round

	net.Start("DeathrunUpdateRoundState")
		net.WriteUInt(round,16)
	net.Broadcast()

	-- compatibility
	hook.Run("OnRoundSet",round)
end

-- commands
concommand.Add("round_switch",function(ply,_,args)
	if IsValid(ply) then return end

	RoundSystem.RoundSwitch(tonumber(args[1]))
end)

hook.Add("PlayerInitialSpawn","RoundSyncCurrent",function(ply)
	net.Start("DeathrunUpdateRoundState")
		net.WriteUInt(RoundSystem.GetCurrent(),16)
	net.Send(ply)
end)

--- @param ply Player?
function RoundSystem.SyncTimer(ply)
	net.Start("DeathrunSyncRoundTimer")
		net.WriteUInt(RoundSystem.GetTimer(),16)

	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

--- @param seconds number
function RoundSystem.SetTimer(seconds)
	RoundSystem.RoundTimer = seconds

	RoundSystem.SyncTimer()
end

hook.Add("PlayerInitialSpawn","DeathrunCleanupSinglePlayer",function(ply)
	RoundSystem.SyncTimer(ply)

	if player.GetCount() > 1 then return end

	game.CleanUpMap()

	DR.ChatBroadcast("Cleaned up the map.")
end)

-- handle death avoidance here, using the functions defined in init.lua
hook.Add("PlayerDisconnected","DeathrunWatchDeathAvoid",function(ply)
	local roundState = RoundSystem.GetCurrent()

	if
		not (
			(
				roundState == DR_ROUND_PREP
			or	roundState == DR_ROUND_ACTIVE
			)
		and	ply:Alive()
		and	ply:Team() == DR_TEAM_DEATH
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

function RoundSystem.FinishRound(winningTeam)
	RoundSystem.RoundSwitch(DR_ROUND_OVER)

	DR.ChatBroadcast(
		"Round over! " .. (
			winningTeam == DR_WIN_RUNNERS and team.GetName(DR_TEAM_RUNNER) .. " win!"
		or	winningTeam == DR_WIN_DEATHS and team.GetName(DR_TEAM_DEATH) .. " win!"
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

	if mostKillsMvp and winningTeam == DR_TEAM_RUNNER then
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
	hook.Run("OnRoundSet",DR_ROUND_OVER,winningTeam ~= DR_WIN_STALEMATE and winningTeam or -1)
end

-- initial round
hook.Add("InitPostEntity","DeathrunInitialRoundState",function() RoundSystem.RoundSwitch(DR_ROUND_WAITING) end)

local BalloonDir = Vector()
local BalloonAngle = Angle()

local BalloonEndPosMul = 92
local BalloonDistCheck = 30 ^ 2

local BalloonTraceCache = {
	["start"] = vector_origin,
	["endpos"] = vector_origin,
	["mins"] = vector_origin,
	["maxs"] = vector_origin,
}

hook.Add("DeathrunPlayerFinishMap","Balloons",function(ply)
	local balloonCount = ConVars.FinishBalloons:GetInt()

	if balloonCount <= 0 then return end

	local shootPos = ply:GetShootPos()

	for _ = 1,balloonCount do
		local balloon = ents.Create("ent_deathrun_balloon") --- @cast balloon -NULL

		balloon:Spawn()

		BalloonDir:SetUnpacked(
			math.Rand(-100,100),
			math.Rand(-100,100),
			math.Rand(-100,100)
		)
		BalloonDir:Normalize()
		BalloonDir:Mul(BalloonEndPosMul)

		BalloonAngle[2] = math.Rand(-180,180)
		balloon:SetAngles(BalloonAngle)

		BalloonTraceCache.start = shootPos
		BalloonTraceCache.endpos = shootPos + BalloonDir
		BalloonTraceCache.filter = ply
		BalloonTraceCache.mins = balloon:OBBMins()
		BalloonTraceCache.maxs = balloon:OBBMaxs()

		local trace = util.TraceHull(BalloonTraceCache)
		local hitPos = trace.HitPos

		if hitPos:DistToSqr(shootPos) > BalloonDistCheck then
			BalloonDir:Div(BalloonEndPosMul)
			BalloonDir:Mul(2.5)

			balloon:SetPos(hitPos)

			balloon:GetPhysicsObject():ApplyForceCenter(BalloonDir)
		else
			balloon:Remove()
		end
	end
end)
