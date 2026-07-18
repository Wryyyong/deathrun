include("sh_round.lua")

util.AddNetworkString("ROUND_STATE")

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

	net.Start("ROUND_STATE")
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
	net.Start("ROUND_STATE")
		net.WriteUInt(ROUND.GetCurrent(),16)
	net.Send(ply)
end)
