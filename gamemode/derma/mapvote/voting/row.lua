--- @class DR_MapVoteRowVoting : DR_MapVoteRowBase
--- @field Parent DR_MapVoteListVoting
local DR_MapVoteRowVoting = {
	["ColumnCount"] = 3,
	["LabelColor"] = DR.Colors.Turq,
}

function DR_MapVoteRowVoting:Init()
	self:SetSize(
		self.Parent:GetWide(),
		24
	)
end

function DR_MapVoteRowVoting:DoClick()
	RunConsoleCommand("mapvote_vote",self.MapName)
end

derma.DefineControl("DR_MapVoteRowVoting","",DR_MapVoteRowVoting,"DR_MapVoteRowBase")
