local Iterator = ipairs({})

if not DR.FontsInitialized then
	surface.CreateFont("DeathrunDermaLarge",{
		["font"] = "Roboto Black",
		["size"] = 45,
		["antialias"] = true,
	})

	surface.CreateFont("DeathrunDermaMedium",{
		["font"] = "Roboto Medium",
		["size"] = 34,
		["weight"] = 200,
	})

	surface.CreateFont("DeathrunDermaSmall",{
		["font"] = "Roboto Medium",
		["size"] = 24,
		["antialias"] = true,
	})

	surface.CreateFont("DeathrunDermaTiny",{
		["font"] = "Roboto Regular",
		["size"] = 18,
		["antialias"] = true,
		["weight"] = 500,
	})

	surface.CreateFont("DeathrunDermaWindowTitle",{
		["font"] = "Roboto Black",
		["size"] = 18,
		["antialias"] = true,
	})

	DR.FontsInitialized = true
end

local Colors = DR.Colors
local ColorClouds = Colors.Clouds
local ColorTurq = Colors.Turq

local DermaColors = DR.DermaColors
DermaColors.Bad = HexColor("#e74c3c")
DermaColors.BadDark = HexColor("#c0392b")
DermaColors.Good = HexColor("#2ecc71")
DermaColors.GoodDark = HexColor("#27ae60")
DermaColors.NeutralHigh = HexColor("#ecf0f1")
DermaColors.NeutralMed = HexColor("#bdc3c7")
DermaColors.NeutralLow = HexColor("#95a5a6")
DermaColors.NeutralDark = HexColor("#7f8c8d")
DermaColors.Turq = ColorTurq
DermaColors.TurqDark = HexColor("#d35400")

local MatBlur = Material("pp/blurscreen")

local function EmptyFunc()
end

--- @param textFunc fun(text: string | any,font: string?,x: number?, y: number?,color: Color?,xAlign: number?,yAlign: number?)
--- @param text string
--- @param font string?
--- @param x number?
--- @param y number?
--- @param color Color?
--- @param xAlign number?
--- @param yAlign number?
--- @param layer number?
local function ShadowTextBase(textFunc,text,font,x,y,color,xAlign,yAlign,layer)
	layer = layer or 1
	local layerLower = layer * 2

	if layer ~= 0 then
		textFunc(
			text,
			font,
			x + layerLower,
			y + layerLower,
			Color(0,0,0,color.a / 4),
			xAlign,
			yAlign
		)
		textFunc(
			text,
			font,
			x + layer,
			y + layer,
			Color(0,0,0,color.a / 2),
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
--- @param font string
--- @param x number
--- @param y number
--- @param color Color
--- @param xAlign number?
--- @param yAlign number?
--- @param layer number?
function DR.ShadowText(text,font,x,y,color,xAlign,yAlign,layer)
	ShadowTextBase(draw.DrawText,text,font,x,y,color,xAlign,nil,layer)
end

--- @param text string
--- @param font string
--- @param x number
--- @param y number
--- @param color Color
--- @param xAlign number?
--- @param yAlign number?
--- @param layer number?
function DR.ShadowTextSimple(text,font,x,y,color,xAlign,yAlign,layer)
	ShadowTextBase(draw.SimpleText,text,font,x,y,color,xAlign,yAlign,layer)
end

--[[------------------------------------
	DR_Window
------------------------------------]]--
--- @class DR_Window : DFrame
--- @field CloseButton DR_CloseButton
--- @field InnerWindow DR_InnerWindow
local DR_Window = {
	["Title"] = "Deathrun Window",
	["BgAlpha"] = 25,
	["BgColor"] = ColorClouds,
	["FgColor"] = ColorTurq,
}

function DR_Window:Init()
	self.CloseButton = self:Add("DR_CloseButton")
	self.InnerWindow = self:Add("DR_InnerWindow")

	self:SetSize(384,548) -- 512 + 28 + 8
	self:Center()
	self:ShowCloseButton(false)

	self.lblTitle:SetVisible(false)
end

DR_Window.OnClose = EmptyFunc

function DR_Window:PerformLayout()
	local width,height = self:GetSize()

	local closeButton = self.CloseButton
	closeButton:SetSize(20,20)
	closeButton:SetPos(width - 24,4) -- 20 - 4

	local innerWindow = self.InnerWindow
	innerWindow:SetSize(width,height - 36) -- 28 - 8
	innerWindow:SetPos(0,28)
end

function DR_Window:Paint(width,height)
	local colFg = self:GetPrimaryColor()
	local wide,tall = self:GetSize()
	local heightInner = height - 8

	surface.SetDrawColor(DermaColors.NeutralHigh)
	self:DrawPanelBlur(4)

	surface.SetDrawColor(self:GetSecondaryColor())
	surface.DrawRect(
		0,
		28,
		wide,
		tall - 36 -- 28 - 8
	)

	surface.SetDrawColor(colFg)
	draw.RoundedBox(
		0,
		0,
		0,
		width,
		16,
		colFg
	)
	surface.DrawRect(
		0,
		8,
		width,
		20
	)
	draw.RoundedBox(
		0,
		0,
		heightInner,
		width,
		8,
		colFg
	)
	surface.DrawRect(0,heightInner,width,4)

	-- title
	DR.ShadowTextSimple(
		self.Title,
		"DeathrunDermaWindowTitle",
		8,
		14,
		ColorClouds,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER
	)
end

--- @param amount number?
function DR_Window:DrawPanelBlur(amount)
	local width = ScrW()
	local height = ScrH()
	local x,y = self:LocalToScreen(0,0)

	x = -x
	y = -y
	amount = amount or 7

	surface.SetDrawColor(color_white)
	surface.SetMaterial(MatBlur)

	for pass = 1,3 do -- 3 pass blur i guess?
		MatBlur:SetFloat("$blur",(pass / 3) * amount)
		MatBlur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x,y,width,height)
	end
end

function DR_Window:SetPrimaryColor(color)
	self.FgColor = color:Copy()
end

function DR_Window:SetSecondaryColor(color)
	self.BgColor = color:Copy()
end

function DR_Window:GetPrimaryColor()
	return self.FgColor
end

function DR_Window:GetSecondaryColor()
	return self.BgColor
end

function DR_Window:SetTitle(str)
	self.Title = str:upper()
end

vgui.Register("DR_Window",DR_Window,"DFrame")

--[[------------------------------------
	DR_InnerWindow
------------------------------------]]--
--- @class DR_InnerWindow : DPanel
local DR_InnerWindow = {}

DR_InnerWindow.Paint = EmptyFunc

vgui.Register("DR_InnerWindow",DR_InnerWindow,"DPanel")

--[[------------------------------------
	DR_Button
------------------------------------]]--
--- @class DR_Button : DButton
--- @field Parent Panel
local DR_Button = {
	["Width"] = 64,
	["Height"] = 24,
	["OffsetX"] = 0,
	["OffsetY"] = 0,
	["CornerRadius"] = 0,
	["Hover"] = false,
	["Active"] = false,
	["Disabled"] = false,
	["Font"] = "DeathrunDermaSmall",
	["Text"] = "Label",
	["TextColor"] = color_white,
	["TextFunction"] = DR.ShadowTextSimple,
	["ColorUp"] = DermaColors.NeutralDark,
	["ColorHover"] = DermaColors.NeutralLow,
}

function DR_Button:Init()
	self.Parent = self:GetParent()

	local subButton = self:Add("DR_SubButton")
	self.SubButton = subButton
	subButton:SetText("")
end

function DR_Button:PerformLayout()
	self.SubButton:SetSize(self:GetSize())
end

DR_Button.Paint = EmptyFunc

function DR_Button:PaintOver(width,height)
	self:PaintShapes(width,height)
	self:PaintText(width,height)
end

function DR_Button:PaintShapes(width,height)
	local colorTarget

	if self.Hover or self.Active then
		colorTarget = self.ColorHover
	elseif not self.Hover then
		colorTarget = self.ColorUp
	else return end

	surface.SetDrawColor(colorTarget)
	draw.RoundedBox(
		self.CornerRadius,
		0,
		0,
		width,
		height,
		colorTarget
	)
end

function DR_Button:PaintText(width,height)
	self.TextFunction(
		self.Text,
		self.Font,
		width * .5 + self.OffsetX,
		height * .5 + self.OffsetY,
		self.TextColor,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		0
	)
end

function DR_Button:SetTextColor(color)
	self.TextColor = color
end

function DR_Button:SetFont(font)
	self.Font = font
end

--- @param x number?
--- @param y number?
function DR_Button:SetOffsets(x,y)
	self.OffsetX = x
	self.OffsetY = y
end

function DR_Button:SetSelected(bool)
	self.Active = bool
end

function DR_Button:SetText(text)
	self.Text = text
end

--- @param colorUp Color
--- @param colorHover Color
function DR_Button:SetColors(colorUp,colorHover)
	self.ColorUp = colorUp
	self.ColorHover = colorHover
end

DR_Button.DoClick = EmptyFunc

function DR_Button:OnMousePressed(keyCode)
	if self.Disabled then return end

	if keyCode == MOUSE_LEFT then
		self:DoClick()
	elseif keyCode == MOUSE_RIGHt then
		self:DoRightClick()
	end
end

function DR_Button:IsDown()
	return
		self.Hover
	and	input.IsMouseDown(MOUSE_LEFT)
end

function DR_Button:SetDisabled(bool)
	self.Disabled = bool
end

vgui.Register("DR_Button",DR_Button,"DButton")

--[[------------------------------------
	DR_SubButton
------------------------------------]]--
--- @class DR_SubButton : DButton
--- @field Parent DR_Button
local DR_SubButton = {}

function DR_SubButton:Init()
	local parent = self:GetParent() --- @cast parent DR_Button
	self.Parent = parent

	local doErrorText

	if not parent then
		doErrorText = "has no parent panel"
	elseif parent.Hover == nil then
		doErrorText = "has a parent panel lacking a 'Hover' property"
	end

	if not doErrorText then return end

	ErrorNoHaltWithStack("'",self:GetName(),"' instance ",doErrorText,"!")
	self:Remove()
end

DR_SubButton.Paint = EmptyFunc

function DR_SubButton:OnCursorEntered()
	self.Parent.Hover = true
end

function DR_SubButton:OnCursorExited()
	self.Parent.Hover = false
end

function DR_SubButton:OnMousePressed(keyCode)
	self.Parent:OnMousePressed(keyCode)
end

function DR_SubButton:SetText(text)
	self.BaseClass--[[@cast -?]].SetText(self,text)
end

vgui.Register("DR_SubButton",DR_SubButton,"DButton")

--[[------------------------------------
	DR_CloseButton
------------------------------------]]--
--- @class DR_CloseButton : DR_Button
--- @field Parent DR_Window
local DR_CloseButton = {}

function DR_CloseButton:DoClick()
	self.Parent:Close()
end

function DR_CloseButton.PaintOver(self,width,height)
	draw.RoundedBox(
		0,
		0,
		0,
		width,
		height,
		DermaColors.Bad
	)
end

vgui.Register("DR_CloseButton",DR_CloseButton,"DR_Button")

--[[------------------------------------
	DR_NavButtonBase
------------------------------------]]--
--- @class DR_NavButtonBase : DR_Button
--- @field Parent DR_MultiPanel
local DR_NavButtonBase = {
	["Text"] = "",
	["ZPos"] = -32768,
}

function DR_NavButtonBase:Init()
	self:SetColors(DermaColors.GoodDark,DermaColors.Good)
	self:SetSize(24,24)
	self:SetText(self.Text)
	self:SetZPos(self.ZPos)
end

function DR_NavButtonBase.GetNewOffset()
	return FrameTime() * 200
end

function DR_NavButtonBase:Think()
	if not self:IsDown() then return end

	local parent = self.Parent
	parent.ButtonOffset = parent.ButtonOffset + self:GetNewOffset()
	parent:InvalidateLayout()
end

vgui.Register("DR_NavButtonBase",DR_NavButtonBase,"DR_Button")

--[[------------------------------------
	DR_NavButtonLeft
------------------------------------]]--
--- @class DR_NavButtonLeft : DR_NavButtonBase
local DR_NavButtonLeft = {
	["Text"] = "<",
	["ZPos"] = 99,
}

vgui.Register("DR_NavButtonLeft",DR_NavButtonLeft,"DR_NavButtonBase")

--[[------------------------------------
	DR_NavButtonRight
------------------------------------]]--
--- @class DR_NavButtonRight : DR_NavButtonBase
local DR_NavButtonRight = {
	["Text"] = ">",
	["ZPos"] = 98,
}

function DR_NavButtonRight:GetNewOffset()
	return -(self.BaseClass--[[@cast -?]].GetNewOffset())
end

vgui.Register("DR_NavButtonRight",DR_NavButtonRight,"DR_NavButtonBase")

--[[------------------------------------
	DR_MultiPanel
------------------------------------]]--
--- @class DR_MultiPanel : Panel
--- @field Tabs table<integer,string>
--- @field Buttons table<string,DR_MultiPanelTabButton>
--- @field Panels table<string,DR_MultiPanelTabPanel>
--- @field Spacer DR_MultiPanelSpacer
--- @field NavLeft DR_NavButtonLeft
--- @field NavRight DR_NavButtonRight
local DR_MultiPanel = {
	["ActiveTab"] = 0,
	["ButtonOffset"] = 0,
	["VisibleArrows"] = true,
	["ColorUp"] = DermaColors.BadDark,
	["ColorHover"] = DermaColors.Bad,
	["Tabs"] = {},
	["Buttons"] = {},
	["Panels"] = {},
}

function DR_MultiPanel:Init()
	self.Tabs = setmetatable({},DR_MultiPanel.Tabs)
	self.Buttons = setmetatable({},DR_MultiPanel.Buttons)
	self.Panels = setmetatable({},DR_MultiPanel.Panels)

	self:SetSize(640,320)

	self.Spacer = self:Add("DR_MultiPanelSpacer")
	self.NavLeft = self:Add("DR_NavButtonLeft")
	self.NavRight = self:Add("DR_NavButtonRight")

	self:InvalidateLayout()
end

function DR_MultiPanel:ShowArrows(bool)
	self.NavLeft:SetVisible(bool)
	self.NavRight:SetVisible(bool)
end

function DR_MultiPanel:SetTab(idx)
	local tabs = self.Tabs
	local buttons = self.Buttons
	local panels = self.Panels

	for _,tab in Iterator,tabs,0 do
		buttons[tab]:SetSelected(false)
		panels[tab]:SetVisible(false)
	end

	local targetTab = tabs[idx]
	buttons[targetTab]:SetSelected(true)
	panels[targetTab]:SetVisible(true)
end

function DR_MultiPanel:SetTabDisabled(idx,bool)
	self.Buttons[self.Tabs[idx]]:SetDisabled(bool)
end

DR_MultiPanel.SetColors = DR_Button.SetColors

function DR_MultiPanel:AddTab(name)
	local tabs = self.Tabs
	local targetIndex = #tabs + 1

	tabs[targetIndex] = name
	self.ActiveTab = targetIndex

	local button = self:Add("DR_MultiPanelTabButton")
	self.Buttons[name] = button
	button:SetText(name)
	button.Index = targetIndex

	local panel = self:Add("DR_MultiPanelTabPanel")
	self.Panels[name] = panel

	self:SetTab(self.ActiveTab)
	self:InvalidateLayout()

	return panel
end

function DR_MultiPanel:PerformLayout()
	local tabs = self.Tabs
	local buttons = self.Buttons
	local panels = self.Panels

	local width,height = self:GetSize()
	local minOffset = -(#tabs * 92 - width) - 56 -- 24 * 2 - 8

	local newOffset =
		minOffset > 0
	and	8
	or	math.Clamp(self.ButtonOffset,minOffset,8)
	self.ButtonOffset = newOffset

	self.NavRight:SetPos(width - 24,0)
	self.Spacer:SetSize(width,4)

	for idx,tab in Iterator,tabs,0 do
		local button = buttons[tab]
		local offset = (idx - 1) * 92

		button:SetPos(24 + offset + newOffset,0)
		button.OriginalX = 8 + offset

		panels[tab]:SetSize(width,height - 28)
	end
end

vgui.Register("DR_MultiPanel",DR_MultiPanel,"Panel")

--[[------------------------------------
	DR_MultiPanelSpacer
------------------------------------]]--
--- @class DR_MultiPanelSpacer : DPanel
local DR_MultiPanelSpacer = {}

function DR_MultiPanelSpacer:Init()
	self:SetPos(0,24)
end

function DR_MultiPanelSpacer:Paint()
	surface.SetDrawColor(DermaColors.NeutralLow)
	surface.DrawRect(
		0,
		0,
		self:GetSize()
	)
end

vgui.Register("DR_MultiPanelSpacer",DR_MultiPanelSpacer,"DPanel")

--[[------------------------------------
	DR_MultiPanelTabButton
------------------------------------]]--
--- @class DR_MultiPanelTabButton : DR_Button
--- @field Parent DR_MultiPanel
local DR_MultiPanelTabButton = {
	["CornerRadius"] = 4,
	["OriginalX"] = 0,
	["Index"] = -1,
	["TextFunction"] = DR.ShadowText,
}

function DR_MultiPanelTabButton:Init()
	self:SetSize(92,24)
	self:SetColors(DermaColors.GoodDark,DermaColors.Good)
end

function DR_MultiPanelTabButton:DoClick()
	self.Parent:SetTab(self.Index)
end

function DR_MultiPanelTabButton:PaintOver()
	local width,height = self:GetSize()

	self:PaintShapes(width,height)
	surface.DrawRect(
		0,
		8,
		width,
		height - 8
	)
	self:PaintText(width,height)
end

vgui.Register("DR_MultiPanelTabButton",DR_MultiPanelTabButton,"DR_Button")

--[[------------------------------------
	DR_MultiPanelTabPanel
------------------------------------]]--
--- @class DR_MultiPanelTabPanel : DPanel
--- @field Parent DR_MultiPanel
local DR_MultiPanelTabPanel = {}

function DR_MultiPanelTabPanel:Init()
	local parent = self:GetParent() --- @cast parent DR_MultiPanel
	self.Parent = parent

	self:SetSize(parent:GetWide(),parent:GetTall() - 28)
	self:SetPos(0,28)
	self:SetVisible(false)
	self:SetColors(DermaColors.GoodDark,DermaColors.Good)
end

function DR_MultiPanelTabPanel.Paint(self,width,height)
	surface.SetDrawColor(225,225,225)
	surface.DrawRect( -- meh
		0,
		0,
		width,
		height
	)
end

vgui.Register("DR_MultiPanelTabPanel",DR_MultiPanelTabPanel,"DR_Button")

--[[------------------------------------
	DR_AuToggle
------------------------------------]]--
--- @class DR_AuToggle : Panel
--- @field Button DR_ToggleButton
--- @field ConVar ConVar
local DR_AuToggle = {
	["State"] = false,
	["Text"] = "AuToggle Toggle Switch",
	["Font"] = "DeathrunDermaTiny",
	["Time"] = 0,
}

function DR_AuToggle:Init()
	self.Button = self:Add("DR_ToggleButton")
end

function DR_AuToggle:SetText(text)
	self.Text = text
end

function DR_AuToggle.SetTextColor(self,color)
end

function DR_AuToggle:GetText()
	return self.Text
end

function DR_AuToggle:SetFont(font)
	self.Font = font
end

function DR_AuToggle:GetFont()
	return self.Font
end

function DR_AuToggle:PerformLayout()
	self.Button:SetSize(self:GetSize())
end

function DR_AuToggle:Think()
	local time = self.Time
	local threshold = self.State and 1 or 0

	if time == threshold then return end

	local diff = FrameTime() * 2

	if time > threshold then
		diff = -diff
	end

	self.Time = math.Clamp(time + diff,0,1)
end

function DR_AuToggle:Paint(_,height)
	local time = self.Time
	local heightHalf = height * .5

	local lerpFrac,lerpStart,lerpEnd

	if self.State then
		lerpFrac = time
		lerpStart = 1
		lerpEnd = 0
	else
		lerpFrac = 1 - time
		lerpStart = 0
		lerpEnd = 1
	end

	draw.NoTexture()

	surface.DrawCircle(
		16,
		heightHalf,
		8,
		ColorTurq
	)
	surface.DrawCircle(
		16,
		heightHalf,
		6,
		ColorClouds
	)
	surface.DrawCircle(
		16,
		heightHalf,
		4 * (1 - DR.QuadLerp(lerpFrac,lerpStart,lerpEnd)),
		ColorTurq
	)

	DR.ShadowTextSimple(
		self:GetText(),
		self:GetFont(),
		32, -- 8 + 16 + 8
		heightHalf,
		ColorTurq,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER,
		1
	)
end

function DR_AuToggle:SetConVar(str)
	local cVar = GetConVar(str)

	self.ConVar = cVar
	self.State = cVar:GetBool()
end

--[[
--- @param cvar ConVar
function DR_AuToggle:SetConVar(cvar)
	self.ConVar = cvar
	self.State = cvar:GetBool()
end
--]]

function DR_AuToggle:Toggle()
	self:SetValue(not self.State)
end

--- @param bool boolean?
function DR_AuToggle:SetValue(bool)
	self.State = bool

	local cVar = self.ConVar
	if not cVar then return end

	cVar:SetBool(bool)
end

function DR_AuToggle:SizeToContents()
	local fontWidth = surface.GetTextSize(self:GetText())

	surface.SetFont(self:GetFont())
	self:SetSize(fontWidth + 40,self:GetTall()) -- 16 + 8 + 8 + fontWidth + 8
end

vgui.Register("DR_AuToggle",DR_AuToggle,"Panel")

--[[------------------------------------
	DR_ToggleButton
------------------------------------]]--
--- @class DR_ToggleButton : DButton
--- @field Parent DR_AuToggle
local DR_ToggleButton = {}

function DR_ToggleButton:Init()
	self.Parent = self:GetParent()

	self:SetText("")
	self:SetSize(self.Parent:GetSize())
end

DR_ToggleButton.Paint = EmptyFunc

function DR_ToggleButton:DoClick()
	self.Parent:Toggle()
end

vgui.Register("DR_ToggleButton",DR_ToggleButton,"DButton")

concommand.Add("deathrun_test_derma",function() vgui.Create("DR_Window") end)

--[[
function surface.EasyPoly(tbl) -- needs a table in format { {x1,y1}, {x2,y2} }
	local poly = {}
	for i = 1,#tbl do
		local temp = {}
		temp["x"] = tbl[i][1]
		temp["y"] = tbl[i][2]
		table.insert(poly,temp)
	end

	surface.DrawPoly(poly)
end

function surface.DrawCircle(x,y,r)
	local segments = 45
	local poly = {}
	for i = 1,segments do
		local temp = {}
		temp["x"] = math.cos(math.ceil(i * (360 / segments)) * (math.pi / 180)) * r + x
		temp["y"] = math.sin(math.ceil(i * (360 / segments)) * (math.pi / 180)) * r + y
		table.insert(poly,temp)
	end

	surface.DrawPoly(poly)
end
--]]
