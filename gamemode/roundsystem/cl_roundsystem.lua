local NetReadUInt = net.ReadUInt

local RoundSystem = DR.RoundSystem

net.Receive("DeathrunSyncRoundTimer",function(len,ply)
	RoundSystem.RoundTimer = NetReadUInt(16)
end)

net.Receive("DeathrunUpdateRoundState",function()
	local newState = NetReadUInt(DR_ROUND_BITS)

	RoundSystem.CurrentStateData:Exit()
	RoundSystem.UpdateState(newState):Enter()
end)
