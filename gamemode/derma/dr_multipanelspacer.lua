local DermaColors = DR.Colors.Derma

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

derma.DefineControl("DR_MultiPanelSpacer","",DR_MultiPanelSpacer,"DPanel")
