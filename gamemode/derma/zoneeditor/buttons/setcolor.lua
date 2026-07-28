--- @class DR_ZoneEditorButtonSetColor : DR_ZoneEditorButtonBase
local DR_ZoneEditorButtonSetColor = {
	["ButtonText"] = "Set zone color",
}

function DR_ZoneEditorButtonSetColor:Init()
	self:RefreshSettings()
end

function DR_ZoneEditorButtonSetColor:DoClick()
	local command = "zone_setcolor \"" .. self.ZoneEdit:GetValue() .. "\" " .. tostring(self.Mixer:GetColor())

	LocalPlayer():ConCommand(command)
	print(command)
end

derma.DefineControl("DR_ZoneEditorButtonSetColor","",DR_ZoneEditorButtonSetColor,"DR_ZoneEditorButtonBase")
