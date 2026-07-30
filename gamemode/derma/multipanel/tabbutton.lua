local SurfaceDrawRect = CLIENT and surface.DrawRect

local DermaColors = DR.Colors.Derma
local DermaColorsGoodDark = DermaColors.GoodDark
local DermaColorsGood = DermaColors.Good

--- @class DR_MultiPanelTabButton : DR_Button
--- @field Parent DR_MultiPanel
local DR_MultiPanelTabButton = {
	["CornerRadius"] = 4,
	["OriginalX"] = 0,
	["Index"] = -1,
	["TextFunction"] = DR.UI.ShadowText,
}

function DR_MultiPanelTabButton:Init()
	self:SetSize(92,24)
	self:SetColors(DermaColorsGoodDark,DermaColorsGood)
end

function DR_MultiPanelTabButton:DoClick()
	self.Parent:SetTab(self.Index)
end

function DR_MultiPanelTabButton:PaintOver()
	local width,height = self:GetSize()

	self:PaintShapes(width,height)
	SurfaceDrawRect(
		0,
		8,
		width,
		height - 8
	)
	self:PaintText(width,height)
end

derma.DefineControl("DR_MultiPanelTabButton","",DR_MultiPanelTabButton,"DR_Button")
