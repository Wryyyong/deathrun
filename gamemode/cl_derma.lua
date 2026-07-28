local ShadowColorCache = {}

--- @param color Color
--- @return Color,Color
local function GetShadowColors(color)
	local alpha = color.a or 255

	local alphaQuar = math.Round(alpha * .25)
	local alphaHalf = math.Round(alpha * .5)

	local shadowColorQuar = ShadowColorCache[alphaQuar]
	local shadowColorHalf = ShadowColorCache[alphaHalf]

	if not shadowColorQuar then
		shadowColorQuar = Color(0,0,0,alphaQuar)
		ShadowColorCache[alphaQuar] = shadowColorQuar
	end

	if not shadowColorHalf then
		shadowColorHalf = Color(0,0,0,alphaHalf)
		ShadowColorCache[alphaHalf] = shadowColorHalf
	end

	return shadowColorQuar,shadowColorHalf
end

--- @param textFunc fun(text: string | any,font: string?,x: number?, y: number?,color: Color?,xAlign: number?,yAlign: number?)
--- @param text string
--- @param font string?
--- @param x number?
--- @param y number?
--- @param color Color?
--- @param xAlign number?
--- @param yAlign number?
--- @param dist number?
local function ShadowTextBase(textFunc,text,font,x,y,color,xAlign,yAlign,dist)
	x = x or 0
	y = y or 0
	color = color or color_white
	dist = dist or 1

	if color.a <= 0 then return end

	if dist ~= 0 then
		local distLower = dist * 2
		local shadowColorQuar,shadowColorHalf = GetShadowColors(color)

		textFunc(
			text,
			font,
			x + distLower,
			y + distLower,
			shadowColorQuar,
			xAlign,
			yAlign
		)
		textFunc(
			text,
			font,
			x + dist,
			y + dist,
			shadowColorHalf,
			xAlign,
			yAlign
		)
	end

	textFunc(
		text,
		font,
		x,
		y,
		color,
		xAlign,
		yAlign
	)
end

--- @param text string
--- @param font string?
--- @param x number?
--- @param y number?
--- @param color Color?
--- @param xAlign number?
--- @param yAlign number?
--- @param dist number?
function DR.ShadowText(text,font,x,y,color,xAlign,yAlign,dist)
	ShadowTextBase(draw.DrawText,text,font,x,y,color,xAlign,nil,dist)
end

--- @param text string
--- @param font string?
--- @param x number?
--- @param y number?
--- @param color Color?
--- @param xAlign number?
--- @param yAlign number?
--- @param dist number?
function DR.ShadowTextSimple(text,font,x,y,color,xAlign,yAlign,dist)
	ShadowTextBase(draw.SimpleText,text,font,x,y,color,xAlign,yAlign,dist)
end

for _,panelName in ipairs({
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
	"innerwindow",
	"menu/controls",
	"menu/spacer",
	"multipanel/spacer",
	"multipanel/tabpanel",
	"scoreboard/item",
	"scoreboard/main",
	"scoreboard/player/icon",

	-- DFrame
	"window",

	-- DLabel
	"menu/item",

	-- DButton
	"button",
	"customscrollpanel/button",
	"scoreboard/player/button",
	"subbutton",
	"togglebutton",

	-- DIconLayout
	"list",

	-- DColorMixer
	"crosshaircreator/colormixer",

	-- DScrollBarGrip
	"customscrollpanel/grip",

	-- DMenu
	"scoreboard/player/menu",

	-- DMenuOption
	"scoreboard/player/menuoptions/_base",

	-- DNumSlider
	"menu/numslider",

	-- DR_Button
	"closebutton",
	"multipanel/navbutton",
	"multipanel/tabbutton",

	-- DR_Window
	"menu/frame",

	-- DR_InnerWindow
	"menu/inner",

	-- DR_List
	"menu/list",
	"scoreboard/list",

	-- DR_CustomScrollPanel
	"menu/scrollpanel",
	"scoreboard/scrollpanel",

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
}) do
	include("derma/" .. panelName .. ".lua")
end

concommand.Add("deathrun_test_derma",function()
	vgui.Create("DR_Window")
end)
