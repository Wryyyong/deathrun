--- @class DR_MapVoteNominateOption : DMenuOption
local DR_MapVoteNominateOption = {
	["Paint"] = DR.EmptyFunction,
}

function DR_MapVoteNominateOption:Init()
	self:SetIcon("icon16/lightbulb.png")
	self:SetText("Nominate")
end

function DR_MapVoteNominateOption:DoClick()
	RunConsoleCommand("mapvote_nominate_map",self.MapName)
end

derma.DefineControl("DR_MapVoteNominateOption","",DR_MapVoteNominateOption,"DMenuOption")
