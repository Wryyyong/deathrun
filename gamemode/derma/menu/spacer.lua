--- @class DR_MenuSpacerBase : DPanel
local DR_MenuSpacerBase = {
	["Height"] = 0,

	["Paint"] = DR.EmptyFunction,
}

function DR_MenuSpacerBase:Init()
	self:SetWide(self:GetParent():GetWide())

	self:RefreshSettings()
end

function DR_MenuSpacerBase:RefreshSettings()
	self:SetTall(self.Height)
end

--- @class DR_MenuSpacerSmall : DPanel
local DR_MenuSpacerSmall = {
	["Height"] = 6,
}

function DR_MenuSpacerSmall:Init()
	self:RefreshSettings()
end

--- @class DR_MenuSpacerLarge : DPanel
local DR_MenuSpacerLarge = {
	["Height"] = 12,
}

function DR_MenuSpacerLarge:Init()
	self:RefreshSettings()
end

derma.DefineControl("DR_MenuSpacerBase","",DR_MenuSpacerBase,"DPanel")

derma.DefineControl("DR_MenuSpacerSmall","",DR_MenuSpacerSmall,"DR_MenuSpacerBase")
derma.DefineControl("DR_MenuSpacerLarge","",DR_MenuSpacerLarge,"DR_MenuSpacerBase")
