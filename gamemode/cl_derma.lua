local DermaColors = DR.DermaColors
DermaColors.Bad = HexColor("#e74c3c")
DermaColors.BadDark = HexColor("#c0392b")
DermaColors.Good = HexColor("#2ecc71")
DermaColors.GoodDark = HexColor("#27ae60")
DermaColors.NeutralHigh = HexColor("#ecf0f1")
DermaColors.NeutralMed = HexColor("#bdc3c7")
DermaColors.NeutralLow = HexColor("#95a5a6")
DermaColors.NeutralDark = HexColor("#7f8c8d")
DermaColors.Turq = DR.Colors.Turq
DermaColors.TurqDark = HexColor("#d35400")

for _,panelName in ipairs({
	-- Panel
	"autoggle",
	"multipanel",

	-- DPanel
	"innerwindow",
	"multipanelspacer",
	"multipaneltabpanel",

	-- DFrame
	"window",

	-- DButton
	"button",
	"subbutton",
	"togglebutton",

	-- DR_Button
	"closebutton",
	"navbutton",
	"multipaneltabbutton",
}) do
	include("derma/dr_" .. panelName .. ".lua")
end

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

concommand.Add("deathrun_test_derma",function()
	vgui.Create("DR_Window")
end)
