--- @class DR_WaitingMenuFrame : DR_MenuFrame
local DR_WaitingMenuFrame = {
	["Title"] = "Waiting For Players",
	["Width"] = 600,
	["Height"] = 270,
}

function DR_WaitingMenuFrame:Init()
	self:RefreshSettings()
end

derma.DefineControl("DR_WaitingMenuFrame","",DR_WaitingMenuFrame,"DR_MenuFrame")
