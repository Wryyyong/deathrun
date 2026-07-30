local DR = DR

local UI = DR.UI

local ColorTurq = DR.Colors.Turq

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

local Scoreboard = UI.Scoreboard or {}
UI.Scoreboard = Scoreboard

--- @type table<string,DeathrunScoreboardSpecial>
local Specials = Scoreboard.Specials or setmetatable({},{
	["__index"] = function()
		return Special_Default
	end,
})
Scoreboard.Specials = Specials

local Panel = Scoreboard.Panel
Scoreboard.Panel = Panel

--- @param scoreboardNew DR_Scoreboard?
function Scoreboard.Set(scoreboardNew)
	local scoreboardOld = Scoreboard.Panel

	if IsValid(scoreboardOld) then
		scoreboardOld:Remove()
	end

	Panel = scoreboardNew
	Scoreboard.Panel = Panel
end

function Scoreboard.Create()
	if IsValid(Scoreboard.Panel) then return end

	local scoreboard = vgui.Create("DR_Scoreboard")
	Scoreboard.Set(scoreboard)

	local scroll = scoreboard:Add("DR_ScoreboardScrollPanel")
	local list = scroll:Add("DR_ScoreboardList")

	list:AddTop()

	list:AddHeader("[Hint] Right Click to scroll and interact with scoreboard.",ColorTurq)

	list:AddTeamGroup(DR_TEAM_DEATH)
	list:AddTeamGroup(DR_TEAM_RUNNER)
	list:AddTeamGroup(DR_TEAM_GHOST)
	list:AddTeamGroup(DR_TEAM_SPECTATOR)

	list:AddOptions()

	list:SizeToChildren()

	scoreboard.IsOpen = true
end

function Scoreboard.Destroy()
	if not IsValid(Panel) then return end

	Panel.IsOpen = false
end

GM.ScoreboardHide = Scoreboard.Destroy

Scoreboard.Destroy()

function GM:ScoreboardShow()
	-- return false to suppress scoreboard opening
	if hook.Run("DeathrunOpenScoreboard") == false then return end

	Scoreboard.Create()
end

hook.Add("CreateMove","DeathrunScoreboardPopup",function(cmd)
	if
		not (
			Panel
		and	Panel.IsOpen
		and	input.WasMousePressed(MOUSE_RIGHT)
		)
	then return end

	Panel:MakePopup()
end)

--- @param id64 string
--- @param icon string?
--- @param color Color?
--- @param tag string?
--- @param rank integer?
function Scoreboard.SetDisplay(id64,icon,color,tag,rank) -- leave nil to use defaults
	Specials[id64] = setmetatable({
		["Icon"] = icon,
		["Color"] = color,
		["Tag"] = tag,
		["Rank"] = rank,
	},Special_Meta)
end

-- hall of fame/hall of lame
local ColorCyan = Color(140,250,239)

-- arizard
Scoreboard.SetDisplay(
	"76561198020843439",
	"icon16/cup.png",
	Color(50,200,0),
	"Author"
)

-- zelpa
Scoreboard.SetDisplay(
	"76561198018967904",
	"icon16/rainbow.png",
	Color(200,0,0),
	"Worst Player"
)

-- krystal
Scoreboard.SetDisplay(
	"76561198216519239",
	"icon16/drink.png",
	Color(255,200,255),
	"Confirmed Grill"
)

-- tarkus
Scoreboard.SetDisplay(
	"76561198141687640",
	"icon16/cup_error.png",
	Color(0,150,0),
	"Associate"
)

-- kaay
Scoreboard.SetDisplay(
	"76561198254542787",
	"icon16/anchor.png",
	Color(166,107,190),
	"MEME MASTER"
)

-- gamefresh
Scoreboard.SetDisplay(
	"76561198089131001",
	"icon16/map_go.png",
	Color(153,255,51),
	"Playboy Bunny"
)

-- fich
Scoreboard.SetDisplay(
	"76561198138707687",
	"icon16/joystick.png",
	ColorCyan,
	"Neko Nation"
)

-- haina
Scoreboard.SetDisplay(
	"76561198104250962",
	"icon16/tux.png",
	ColorCyan,
	math.random(100) .. "% Unstable"
)

-- josh
Scoreboard.SetDisplay(
	"76561198132396847",
	"icon16/lightning.png",
	Color(255,18,18),
	"Little Kid"
)

-- preck
Scoreboard.SetDisplay(
	"76561198073959598",
	"icon16/money.png",
	Color(255,192,72),
	"Scammer"
)

-- do not remove or i kill u
hook.Add("GetScoreboardSpecial","DeathrunInternalGetScoreboardSpecial",function(ply)
	return Specials[ply:SteamID64()]
end)
