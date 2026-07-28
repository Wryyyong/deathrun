--- @class DR_ZoneEditorFrame : DR_MenuFrame
local DR_ZoneEditorFrame = {
	["Title"] = "Zone Editor",
	["Width"] = 480,
	["Height"] = 480,
}

function DR_ZoneEditorFrame:Init()
	self:RefreshSettings()
end

derma.DefineControl("DR_ZoneEditorFrame","",DR_ZoneEditorFrame,"DR_MenuFrame")
