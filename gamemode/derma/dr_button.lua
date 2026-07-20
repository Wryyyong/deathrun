local DermaColors = DR.DermaColors

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
	["Font"] = "Deathrun_Derma_Small",
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

DR_Button.Paint = DR.EmptyFunction

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
	self.OffsetX = x or 0
	self.OffsetY = y or 0
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

DR_Button.DoClick = DR.EmptyFunction

function DR_Button:OnMousePressed(keyCode)
	if self.Disabled then return end

	if keyCode == MOUSE_LEFT then
		self:DoClick()
	elseif keyCode == MOUSE_RIGHT then
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

derma.DefineControl("DR_Button","",DR_Button,"DButton")
