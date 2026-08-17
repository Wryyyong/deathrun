print("Creating global tables...")

DR = DR or {}

DR.ButtonClaimSystem = DR.ButtonClaimSystem or {}
DR.ConVars = DR.ConVars or {}
DR.MapVote = DR.MapVote or {}
DR.RoundSystem = DR.RoundSystem or {}
DR.Stats = DR.Stats or {}
DR.ZoneSystem = DR.ZoneSystem or {}

DR.Players = DR.Players or {}
DR.Players.SteamID = DR.Players.SteamID or {}
DR.Players.SteamID64 = DR.Players.SteamID64 or {}

DR.UI = DR.UI or {}
DR.UI.HUD = DR.UI.HUD or {}
DR.UI.Scoreboard = DR.UI.Scoreboard or {}

--- @type string[]
local DermaFiles = {}
DR.UI.DermaFiles = DermaFiles

for idx,panelName in ipairs({
	-- AvatarImage
	"scoreboard/player/avatar",

	-- Panel
	"autoggle",
	"customscrollpanel/panelcanvas",
	"customscrollpanel/vscrollbar",
	"multipanel/main",

	-- DPanel
	"crosshaircreator/preview",
	"customscrollpanel/main",
	"inner",
	"mapvote/row",
	"menu/controls",
	"menu/spacer",
	"multipanel/spacer",
	"multipanel/tabpanel",
	"scoreboard/item",
	"scoreboard/main",
	"scoreboard/player/icon",
	"zoneeditor/data",

	-- DFrame
	"frame",

	-- DLabel
	"menu/item",

	-- DButton
	"button",
	"customscrollpanel/button",
	"scoreboard/player/button",
	"mapvote/maplist/button",
	"mapvote/voting/button",
	"subbutton",
	"togglebutton",

	-- DIconLayout
	"list",

	-- DComboBox
	"zoneeditor/edit",

	-- DColorMixer
	"crosshaircreator/colormixer",
	"zoneeditor/colormixer",

	-- DScrollBarGrip
	"customscrollpanel/grip",

	-- DMenu
	"mapvote/menu",
	"scoreboard/player/menu",

	-- DMenuOption
	"mapvote/maplist/nominateoption",
	"scoreboard/player/menuoptions/_base",

	-- DNumSlider
	"menu/numslider",

	-- DNumberWang
	"zoneeditor/poswang",

	-- DTextEntry
	"zoneeditor/name",

	-- DR_Button
	"closebutton",
	"misc/movedtospec/button",
	"multipanel/navbutton",
	"multipanel/tabbutton",
	"zoneeditor/buttons/_base",

	-- DR_CustomScrollPanel
	"menu/scrollpanel",
	"scoreboard/scrollpanel",

	-- DR_Frame
	"menu/frame",

	-- DR_Inner
	"mapvote/inner",
	"menu/inner",

	-- DR_List
	"mapvote/list",
	"menu/list",
	"scoreboard/list",

	-- DR_MenuFrame
	"crosshaircreator/frame",
	"mapvote/maplist/frame",
	"mapvote/voting/frame",
	"misc/movedtospec/frame",
	"misc/waitingmenu/frame",
	"zoneeditor/frame",

	-- DR_MenuInner
	"misc/movedtospec/inner",
	"misc/waitingmenu/inner",

	-- DR_MenuList
	"zoneeditor/list",

	-- DR_MenuItemBase
	"mapvote/item",

	-- DR_MenuScrollPanel
	"mapvote/maplist/scrollpanel",

	-- DR_MapVoteRowBase
	"mapvote/voting/row",

	-- DR_MapVoteListBase
	"mapvote/maplist/list",
	"mapvote/voting/list",

	-- DR_ScoreboardItemBase
	"scoreboard/player/data",
	"scoreboard/top",

	-- DR_ScoreboardItemSmallBase
	"scoreboard/player/panel",

	-- DR_ScoreboardPlayerMenuOptionBase
	"scoreboard/player/menuoptions/_ulx",
	"scoreboard/player/menuoptions/copyid",
	"scoreboard/player/menuoptions/forcespec",
	"scoreboard/player/menuoptions/mute",
	"scoreboard/player/menuoptions/openprofile",

	-- DR_ScoreboardPlayerMenuOptionULXBase
	"scoreboard/player/menuoptions/ulx_ban",
	"scoreboard/player/menuoptions/ulx_gag",
	"scoreboard/player/menuoptions/ulx_kick",
	"scoreboard/player/menuoptions/ulx_mute",
	"scoreboard/player/menuoptions/ulx_slay",

	-- DR_ZoneEditorButtonBase
	"zoneeditor/buttons/create",
	"zoneeditor/buttons/remove",
	"zoneeditor/buttons/setdir",
	"zoneeditor/buttons/setpos_eyetrace",
	"zoneeditor/buttons/setpos_wang",
	"zoneeditor/buttons/setcolor",
	"zoneeditor/buttons/teleport",
}) do
	DermaFiles[idx] = "derma/" .. panelName .. ".lua"
end

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
