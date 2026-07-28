--- @class DR_ScoreboardScrollPanel : DR_CustomScrollPanel
local DR_ScoreboardScrollPanel = {}

function DR_ScoreboardScrollPanel:Init()
	self.pnlCanvas:SetSize(self:GetParent():GetSize())

	self:SizeToContents()
end

derma.DefineControl("DR_ScoreboardScrollPanel","",DR_ScoreboardScrollPanel,"DR_CustomScrollPanel")
