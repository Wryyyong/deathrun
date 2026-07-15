--- @class DR_ScoreboardPlayerButton : DButton
--- @field Parent DR_ScoreboardPlayerPanel
local DR_ScoreboardPlayerButton = {
	["Paint"] = DR.EmptyFunction,
}

function DR_ScoreboardPlayerButton:Init()
	local parent = self:GetParent()
	self.Parent = parent

	self:SetSize(parent:GetSize())
	self:SetText("")
end

function DR_ScoreboardPlayerButton:DoRightClick()
	self.Parent:Add("DR_ScoreboardPlayerMenu")
end

derma.DefineControl("DR_ScoreboardPlayerButton","",DR_ScoreboardPlayerButton,"DButton")
