--- @class DR_MapVoteButtonVoting : DButton
--- @field Parent DR_MapVoteRowVoting
local DR_MapVoteButtonVoting = {
	["Paint"] = DR.EmptyFunction,
}

function DR_MapVoteButtonVoting:Init()
	local parent = self:GetParent()
	self.Parent = parent

	self.MapName = parent.MapName

	self:SetSize(parent:GetSize())
	self:SetText("")
end

function DR_MapVoteButtonVoting:DoClick()
	self.Parent:DoClick()
end

derma.DefineControl("DR_MapVoteButtonVoting","",DR_MapVoteButtonVoting,"DButton")
