include("sh_round.lua")

net.Receive("ROUND_STATE",function()
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
