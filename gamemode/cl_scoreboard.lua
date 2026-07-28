local DR = DR

--- @alias DeathrunScoreboardSpecial {
--- 	Icon: string?,
--- 	Color: Color?,
--- 	Tag: string?,
--- 	Rank: integer?,
--- }

--- @type DeathrunScoreboardSpecial
local Special_Default = {}
local Special_Meta = {
	["__index"] = Special_Default,
}

--- @type table<string,DeathrunScoreboardSpecial>
local ScoreboardSpecials = DR.ScoreboardSpecials or setmetatable({},{
	["__index"] = function()
		return Special_Default
	end,
})
DR.ScoreboardSpecials = ScoreboardSpecials

local ScoreboardPanel = DR.ScoreboardPanel
DR.ScoreboardPanel = ScoreboardPanel

--- @param scoreboardNew DR_Scoreboard?
function DR.SetScoreboard(scoreboardNew)
	local scoreboardOld = DR.ScoreboardPanel

	if IsValid(scoreboardOld) then
		scoreboardOld:Remove()
	end

	ScoreboardPanel = scoreboardNew
	DR.ScoreboardPanel = ScoreboardPanel
end

function DR.CreateScoreboard()
	if IsValid(DR.ScoreboardPanel) then return end

	local scoreboard = vgui.Create("DR_Scoreboard")
	DR.SetScoreboard(scoreboard)

	local scroll = scoreboard:Add("DR_ScoreboardScrollPanel")
	local list = scroll:Add("DR_ScoreboardList")

	list:AddTop()

	list:AddHeader("[Hint] Right Click to scroll and interact with scoreboard.",DR.Colors.Turq)

	list:AddTeamGroup(DR_TEAM_DEATH)
	list:AddTeamGroup(DR_TEAM_RUNNER)
	list:AddTeamGroup(DR_TEAM_GHOST)
	list:AddTeamGroup(DR_TEAM_SPECTATOR)

	list:AddOptions()

	list:SizeToChildren()

	scoreboard.IsOpen = true
end

function DR.DestroyScoreboard()
	if not IsValid(ScoreboardPanel) then return end

	ScoreboardPanel.IsOpen = false
end

GM.ScoreboardHide = DR.DestroyScoreboard

DR.DestroyScoreboard()

function GM:ScoreboardShow()
	-- return false to suppress scoreboard opening
	if hook.Run("DeathrunOpenScoreboard") == false then return end

	DR.CreateScoreboard()
end

hook.Add("CreateMove","DeathrunScoreboardPopup",function(cmd)
	if
		not (
			ScoreboardPanel
		and	ScoreboardPanel.IsOpen
		and	input.WasMousePressed(MOUSE_RIGHT)
		)
	then return end

	ScoreboardPanel:MakePopup()
end)

--- @param id64 string
--- @param icon string?
--- @param color Color?
--- @param tag string?
--- @param rank integer?
function DR.SetScoreboardDisplay(id64,icon,color,tag,rank) -- leave nil to use defaults
	ScoreboardSpecials[id64] = setmetatable({
		["Icon"] = icon,
		["Color"] = color,
		["Tag"] = tag,
		["Rank"] = rank,
	},Special_Meta)
end

-- hall of fame/hall of lame
local ColorCyan = Color(140,250,239)

-- arizard
DR.SetScoreboardDisplay(
	"76561198020843439",
	"icon16/cup.png",
	Color(50,200,0),
	"Author"
)

-- zelpa
DR.SetScoreboardDisplay(
	"76561198018967904",
	"icon16/rainbow.png",
	Color(200,0,0),
	"Worst Player"
)

-- krystal
DR.SetScoreboardDisplay(
	"76561198216519239",
	"icon16/drink.png",
	Color(255,200,255),
	"Confirmed Grill"
)

-- tarkus
DR.SetScoreboardDisplay(
	"76561198141687640",
	"icon16/cup_error.png",
	Color(0,150,0),
	"Associate"
)

-- kaay
DR.SetScoreboardDisplay(
	"76561198254542787",
	"icon16/anchor.png",
	Color(166,107,190),
	"MEME MASTER"
)

-- gamefresh
DR.SetScoreboardDisplay(
	"76561198089131001",
	"icon16/map_go.png",
	Color(153,255,51),
	"Playboy Bunny"
)

-- fich
DR.SetScoreboardDisplay(
	"76561198138707687",
	"icon16/joystick.png",
	ColorCyan,
	"Neko Nation"
)

-- haina
DR.SetScoreboardDisplay(
	"76561198104250962",
	"icon16/tux.png",
	ColorCyan,
	math.random(100) .. "% Unstable"
)

-- josh
DR.SetScoreboardDisplay(
	"76561198132396847",
	"icon16/lightning.png",
	Color(255,18,18),
	"Little Kid"
)

-- preck
DR.SetScoreboardDisplay(
	"76561198073959598",
	"icon16/money.png",
	Color(255,192,72),
	"Scammer"
)

-- do not remove or i kill u
hook.Add("GetScoreboardSpecial","DeathrunInternalGetScoreboardSpecial",function(ply)
	return ScoreboardSpecials[ply:SteamID64()]
end)
