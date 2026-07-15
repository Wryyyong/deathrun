local UI = DR.UI

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
--- @param font string? = "DermaDefault"
--- @param x number? = 0
--- @param y number? = 0
--- @param color Color? = color_white
--- @param xAlign number? = TEXT_ALIGN_LEFT
--- @param yAlign number? = TEXT_ALIGN_TOP
--- @param dist number? = 1
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
--- @param font string? = "DermaDefault"
--- @param x number? = 0
--- @param y number? = 0
--- @param color Color? = color_white
--- @param xAlign number? = TEXT_ALIGN_LEFT
--- @param yAlign number? = nil
--- @param dist number? = 1
function UI.ShadowText(text,font,x,y,color,xAlign,yAlign,dist)
	ShadowTextBase(draw.DrawText,text,font,x,y,color,xAlign,nil,dist)
end

--- @param text string
--- @param font string? = "DermaDefault"
--- @param x number? = 0
--- @param y number? = 0
--- @param color Color? = color_white
--- @param xAlign number? = TEXT_ALIGN_LEFT
--- @param yAlign number? = TEXT_ALIGN_TOP
--- @param dist number? = 1
function UI.ShadowTextSimple(text,font,x,y,color,xAlign,yAlign,dist)
	ShadowTextBase(draw.SimpleText,text,font,x,y,color,xAlign,yAlign,dist)
end

--- @param text string
--- @param width number
--- @param font string
function UI.GetWordWrapText(text,width,font)
	local displayText = ""
	local displayLine = ""

	surface.SetFont(font)
	text = text:Replace("\n","")
	text = text:Replace("\t","")
	text = text:Replace([[\n]],"\n")
	text = text:Replace([[\t]],"\t")
	text = text:Replace([[\b]],"• ")

	local args = text:Split(" ")

	for _,word in ipairs(args) do
		local textWidth = surface.GetTextSize(displayLine .. word .. " ")

		if textWidth > width then
			displayText = displayText .. displayLine .. "\n"
			displayLine = word .. " "
		else
			displayLine = displayLine .. word .. " "
		end
	end

	return displayText .. displayLine
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
	"zoneeditor/buttons/setpos",
	"zoneeditor/buttons/setcolor",
}) do
	include("derma/" .. panelName .. ".lua")
end

concommand.Add("deathrun_test_derma",function()
	vgui.Create("DR_Frame")
end)
