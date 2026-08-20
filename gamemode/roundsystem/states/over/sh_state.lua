local RoundSystem = DR.RoundSystem

ROUNDSTATE.ID = DR_ROUND_OVER
ROUNDSTATE.EnterHook = "DeathrunBeginOver"

function ROUNDSTATE:Enter()
	RoundSystem.RoundsPlayed = RoundSystem.RoundsPlayed + 1

	self.BaseClass.Enter(self)
end
