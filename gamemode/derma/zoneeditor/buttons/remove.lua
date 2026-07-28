--- @class DR_ZoneEditorButtonRemove : DR_ZoneEditorButtonBase
local DR_ZoneEditorButtonRemove = {
	["ButtonText"] = "Remove this zone",
}

function DR_ZoneEditorButtonRemove:Init()
	self:RefreshSettings()
end

function DR_ZoneEditorButtonRemove:DoClick()
	local command = "zone_remove \"" .. self.ZoneEdit:GetValue() .. "\""

	LocalPlayer():ConCommand(command)
	print(command)
end

derma.DefineControl("DR_ZoneEditorButtonRemove","",DR_ZoneEditorButtonRemove,"DR_ZoneEditorButtonBase")
