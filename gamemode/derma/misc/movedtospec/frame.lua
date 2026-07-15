--- @class DR_MovedToSpectatorFrame : DR_MenuFrame
local DR_MovedToSpectatorFrame = {
	["Title"] = "Moved to Spectator",
	["Width"] = 640,
	["Height"] = 220,
}

function DR_MovedToSpectatorFrame:Init()
	self:RefreshSettings()
end

derma.DefineControl("DR_MovedToSpectatorFrame","",DR_MovedToSpectatorFrame,"DR_MenuFrame")
