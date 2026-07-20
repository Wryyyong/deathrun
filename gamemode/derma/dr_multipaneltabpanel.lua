local DermaColors = DR.DermaColors

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

derma.DefineControl("DR_MultiPanelTabPanel","",DR_MultiPanelTabPanel,"DPanel")
