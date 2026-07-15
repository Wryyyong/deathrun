--- @class DR_ZoneEditorButtonBase : DR_Button
--- @field Parent DR_ZoneEditorList
local DR_ZoneEditorButtonBase = {
	["ButtonText"] = "",
}

function DR_ZoneEditorButtonBase:Init()
	local parent = self:GetParent()
	self.Parent = parent

	self:SetSize(
		parent:GetWide(),
		18
	)
	self:SetFont("Deathrun_Derma_ExtraSmall")

	self:RefreshSettings()
end

function DR_ZoneEditorButtonBase:RefreshSettings()
	self:SetText(self.ButtonText)
end

function DR_ZoneEditorButtonBase:DoClick()
end

derma.DefineControl("DR_ZoneEditorButtonBase","",DR_ZoneEditorButtonBase,"DR_Button")
