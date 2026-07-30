local NetReadUInt = net.ReadUInt

local RoundSystem = DR.RoundSystem

net.Receive("DeathrunSyncRoundTimer",function(len,ply)
	RoundSystem.RoundTimer = NetReadUInt(16)
end)

net.Receive("DeathrunUpdateRoundState",function()
	local round = NetReadUInt(16)

	local roundTblOld = RoundSystem.States[RoundSystem.CurrentState]
	local roundTblNew = RoundSystem.States[round]
	if not roundTblNew then return end

	if roundTblOld then
		roundTblOld.OnExit()
	end

	roundTblNew.OnEnter()

	RoundSystem.CurrentState = round
end)
