local ColorsText = DR.Colors.Text

--- @class DR_MenuItemBase : DLabel
--- @field Parent DR_MenuList
local DR_MenuItemBase = {
	["Font"] = "Deathrun_Derma_ExtraSmall",
}

function DR_MenuItemBase:Init()
	self.Parent = self:GetParent()

	self.TextColor = ColorsText.Grey3

	self:RefreshSettings()
end

function DR_MenuItemBase:RefreshSettings()
	self:SetTextColor(self.TextColor)
	self:SetFont(self.Font)
	self:SizeToContents()
	self:SetWide(self.Parent:GetWide())
end

--- @class DR_MenuImportant : DR_MenuItemBase
local DR_MenuImportant = {}

function DR_MenuImportant:Init()
	self.TextColor = ColorsText.Turq

	self:RefreshSettings()
end

--- @class DR_MenuTop : DR_MenuImportant
local DR_MenuTop = {
	["Font"] = "Deathrun_Derma_Medium",
}

function DR_MenuTop:Init()
	self:RefreshSettings()
end

--- @class DR_MenuHeader : DR_MenuImportant
local DR_MenuHeader = {
	["Font"] = "Deathrun_Derma_Small",
}

function DR_MenuHeader:Init()
	self:RefreshSettings()
end

derma.DefineControl("DR_MenuItemBase","",DR_MenuItemBase,"DLabel")

derma.DefineControl("DR_MenuImportant","",DR_MenuImportant,"DR_MenuItemBase")

derma.DefineControl("DR_MenuTop","",DR_MenuTop,"DR_MenuImportant")
derma.DefineControl("DR_MenuHeader","",DR_MenuHeader,"DR_MenuImportant")
