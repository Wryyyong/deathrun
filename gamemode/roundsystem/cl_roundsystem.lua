net.Receive("DeathrunSyncRoundTimer",function(len,ply)
	DR_ROUND_TIMER = net.ReadUInt(16)
end)

net.Receive("DeathrunUpdateRoundState",function()
	local round = net.ReadUInt(16)

	local roundTblOld = ROUND_STATES[ROUND_CURRENT]
	local roundTblNew = ROUND_STATES[round]
	if not roundTblNew then return end

	if roundTblOld then
		roundTblOld.OnExit()
	end

	roundTblNew.OnEnter()

	ROUND_CURRENT = round
end)
