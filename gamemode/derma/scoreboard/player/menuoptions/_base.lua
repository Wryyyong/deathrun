--- @class DR_ScoreboardPlayerMenuOptionBase : DMenuOption
local DR_ScoreboardPlayerMenuOptionBase = {
	["Caption"] = "",
	["IconPath"] = "",
}

function DR_ScoreboardPlayerMenuOptionBase:Init()
	self:RefreshSettings()
end

function DR_ScoreboardPlayerMenuOptionBase:RefreshSettings()
	self:SetText(self.Caption)

	local iconPath = self.IconPath

	if #iconPath > 0 then
		self:SetIcon(iconPath)
	end
end

function DR_ScoreboardPlayerMenuOptionBase:DoClick()
	if not IsValid(self.Player) then return end

	self:ValidClick()
end

function DR_ScoreboardPlayerMenuOptionBase:ValidClick()
end

derma.DefineControl("DR_ScoreboardPlayerMenuOptionBase","",DR_ScoreboardPlayerMenuOptionBase,"DMenuOption")
