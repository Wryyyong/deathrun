--- @class DR_MapVoteScrollPanel : DR_MenuScrollPanel
local DR_MapVoteScrollPanel = {}

function DR_MapVoteScrollPanel:Init()
	local parent = self.Parent

	local width,height = parent:GetSize()

	self:SetSize(
		width - 8,
		height
	)
	self:SetPos(4,0)
end

derma.DefineControl("DR_MapVoteScrollPanel","",DR_MapVoteScrollPanel,"DR_MenuScrollPanel")
