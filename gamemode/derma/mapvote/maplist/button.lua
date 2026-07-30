--- @class DR_MapVoteButtonMapList : DButton
--- @field Parent DR_MapVoteRowBase
local DR_MapVoteButtonMapList = {
	["Paint"] = DR.EmptyFunction,
}

function DR_MapVoteButtonMapList:Init()
	local parent = self:GetParent()
	self.Parent = parent

	self.MapName = parent.MapName

	self:SetSize(parent:GetSize())
	self:SetText("")
end

function DR_MapVoteButtonMapList:DoClick()
	local menu = vgui.Create("DR_MapVoteMenu")
	local nominate = menu:AddOption("DR_MapVoteNominateOption")
	nominate.MapName = self.MapName

	menu:Open()
end

derma.DefineControl("DR_MapVoteButtonMapList","",DR_MapVoteButtonMapList,"DButton")
