--- @class DR_ZoneEditorButtonCreate : DR_ZoneEditorButtonBase
local DR_ZoneEditorButtonCreate = {
	["ButtonText"] = "Create Zone",
}

function DR_ZoneEditorButtonCreate:Init()
	self:RefreshSettings()
end

function DR_ZoneEditorButtonCreate:DoClick()
	local command = "zone_create \"" .. self.ZoneName:GetText() .. "\" \"" .. self.ZoneType:GetValue() .. "\""

	LocalPlayer():ConCommand(command)
end

derma.DefineControl("DR_ZoneEditorButtonCreate","",DR_ZoneEditorButtonCreate,"DR_ZoneEditorButtonBase")
