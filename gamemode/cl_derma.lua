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
	-- Panel
	"autoggle",
	"customscroll/custompanelcanvas",
	"customscroll/customvscrollbar",
	"multipanel/multipanel",

	-- DPanel
	"crosshaircreator/crosshairpreview",
	"customscroll/customscrollpanel",
	"innerwindow",
	"menu/menucontrols",
	"menu/menuspacer",
	"multipanel/multipanelspacer",
	"multipanel/multipaneltabpanel",

	-- DFrame
	"window",

	-- DLabel
	"menu/menuitem",

	-- DButton
	"button",
	"customscroll/customvscrollbarbutton",
	"subbutton",
	"togglebutton",

	-- DIconLayout
	"menu/menulist",

	-- DColorMixer
	"crosshaircreator/crosshaircolormixer",

	-- DScrollBarGrip
	"customscroll/customscrollbargrip",

	-- DNumSlider
	"menu/menunumslider",

	-- DR_Button
	"closebutton",
	"multipanel/multipaneltabbutton",
	"multipanel/navbutton",

	-- DR_Window
	"menu/menuframe",

	-- DR_InnerWindow
	"menu/menuinner",
}) do
	include("derma/" .. panelName .. ".lua")
end

concommand.Add("deathrun_test_derma",function()
	vgui.Create("DR_Window")
end)
