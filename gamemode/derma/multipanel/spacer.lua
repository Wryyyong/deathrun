local SurfaceSetDrawColor = CLIENT and surface.SetDrawColor
local SurfaceDrawRect = CLIENT and surface.DrawRect

local ColorNeutralLow = DR.Colors.Derma.NeutralLow

--- @class DR_MultiPanelSpacer : DPanel
local DR_MultiPanelSpacer = {}

function DR_MultiPanelSpacer:Init()
	self:SetPos(0,24)
end

function DR_MultiPanelSpacer:Paint()
	SurfaceSetDrawColor(ColorNeutralLow)
	SurfaceDrawRect(
		0,
		0,
		self:GetSize()
	)
end

derma.DefineControl("DR_MultiPanelSpacer","",DR_MultiPanelSpacer,"DPanel")
