local Iterator = ipairs({})

local Color = Color

local DrawDrawText = draw.DrawText
local DrawSimpleText = draw.SimpleText

local MathRound = math.Round

local SurfaceGetTextSize = surface.GetTextSize
local SurfaceSetFont = surface.SetFont

local UI = DR.UI

local ShadowColorCache = {}

--- @param color Color
--- @return Color,Color
local function GetShadowColors(color)
	local alpha = color.a or 255

	local alphaQuar = MathRound(alpha * .25)
	local alphaHalf = MathRound(alpha * .5)

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
	ShadowTextBase(DrawDrawText,text,font,x,y,color,xAlign,nil,dist)
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
	ShadowTextBase(DrawSimpleText,text,font,x,y,color,xAlign,yAlign,dist)
end

--- @param text string
--- @param width number
--- @param font string
function UI.GetWordWrapText(text,width,font)
	local displayText = ""
	local displayLine = ""

	SurfaceSetFont(font)
	text = text:Replace("\n","")
	text = text:Replace("\t","")
	text = text:Replace([[\n]],"\n")
	text = text:Replace([[\t]],"\t")
	text = text:Replace([[\b]],"• ")

	local args = text:Split(" ")

	for _,word in Iterator,args,0 do
		local textWidth = SurfaceGetTextSize(displayLine .. word .. " ")

		if textWidth > width then
			displayText = displayText .. displayLine .. "\n"
			displayLine = word .. " "
		else
			displayLine = displayLine .. word .. " "
		end
	end

	return displayText .. displayLine
end

for _,panelName in Iterator,UI.DermaFiles,0 do
	include(panelName)
end

concommand.Add("deathrun_test_derma",function()
	vgui.Create("DR_Frame")
end)
