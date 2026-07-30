local SurfaceSetDrawColor = CLIENT and surface.SetDrawColor
local SurfaceDrawRect = CLIENT and surface.DrawRect

local DermaColors = DR.Colors.Derma
local DermaColorsGoodDark = DermaColors.GoodDark
local DermaColorsGood = DermaColors.Good

--- @class DR_MultiPanelTabPanel : DPanel
local DR_MultiPanelTabPanel = {}

function DR_MultiPanelTabPanel:Init()
	local width,height = self:GetParent():GetSize()

	self:SetSize(width,height - 28)
	self:SetPos(0,28)
	self:SetVisible(false)
	self:SetColors(DermaColorsGoodDark,DermaColorsGood)
end

function DR_MultiPanelTabPanel.Paint(self,width,height)
	SurfaceSetDrawColor(225,225,225)
	SurfaceDrawRect( -- meh
		0,
		0,
		width,
		height
	)
end

derma.DefineControl("DR_MultiPanelTabPanel","",DR_MultiPanelTabPanel,"DPanel")
