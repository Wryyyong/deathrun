print("Creating global table DR...")

DR = DR or {
	["ButtonClaimSystem"] = {},
	["ConVars"] = {},
	["MapVote"] = {},
	["RoundSystem"] = {},
	["Stats"] = {},
	["UI"] = {
		["HUD"] = {},
		["Scoreboard"] = {},
	},
	["ZoneSystem"] = {},
}

GM.Name = "Deathrun"
GM.Author = "Arizard"
GM.Email = ""
GM.Website = "http://vhs7.tv"

DR.TimeStamp = 1462083778
DR.TimeStampFormatted = os.date("%Y-%m-%d %H:%M:%S",DR.TimeStamp)

for _,event in ipairs({
	"player_connect",
}) do
	gameevent.Listen(event)
end

function DR.EmptyFunction()
end

--- @param max integer
--- @param min integer?
--- @param signed boolean?
--- @return integer
function DR.CalcMaxBits(max,min,signed)
	local useVal = math.max(max,math.abs(min or 0))

	return
		math.ceil(math.log(useVal + (useVal == max and 1 or 0),2))
	+	(signed and 1 or 0)
end

DR_TEAM_RUNNER = 1
DR_TEAM_DEATH = 2
DR_TEAM_GHOST = 3
DR_TEAM_SPECTATOR = TEAM_SPECTATOR

DR_TEAM_BITS = DR.CalcMaxBits(DR_TEAM_SPECTATOR)

DR_ROUND_WAITING = 1
DR_ROUND_PREP = 2
DR_ROUND_ACTIVE = 3
DR_ROUND_OVER = 4

DR_ROUND_PREPARING = DR_ROUND_PREP
DR_ROUND_ENDING = DR_ROUND_OVER

DR_ROUND_BITS = DR.CalcMaxBits(DR_ROUND_OVER)

-- win constants
DR_WIN_RUNNERS = DR_TEAM_RUNNER
DR_WIN_DEATHS = DR_TEAM_DEATH
DR_WIN_STALEMATE = 3

DR_WINNER_BITS = DR.CalcMaxBits(DR_WIN_STALEMATE)

-- don't touch this otherwise shit will hit the fan and your custom colors won't work
hook.Add("InitPostEntity","DeathrunChangeColors",function()
	hook.Run("DeathrunChangeColors")
end)
