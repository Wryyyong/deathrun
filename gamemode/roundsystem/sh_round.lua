ROUND = ROUND or {}

-- Create round state constants
ROUND_CURRENT = ROUND_CURRENT or ROUND_WAITING -- default to 1
ROUND_STATES = ROUND_STATES or {} -- heheh

function ROUND.AddState(state,fOnEnter,fOnThink,fOnExit) -- constant int, and 3 functions
	ROUND_STATES[state] = {
		["OnEnter"] = fOnEnter,
		["OnThink"] = fOnThink,
		["OnExit"] = fOnExit,
	}
end

function ROUND.RoundThink(state)
	local roundTbl = ROUND_STATES[state]
	if not roundTbl then return end

	roundTbl.OnThink()
end

function ROUND.GetCurrent()
	return ROUND_CURRENT
end

-- keep thinking for the current round, i.e. to check for living players
hook.Add("Think","ROUND_THINK",function()
	ROUND.RoundThink(ROUND_CURRENT)
end)
