--- @class DR_InnerWindow : DPanel
--- @field Parent DR_Window
local DR_InnerWindow = {}

function DR_InnerWindow:Init()
	self.Parent = self:GetParent()
end

DR_InnerWindow.Paint = DR.EmptyFunction

derma.DefineControl("DR_InnerWindow","",DR_InnerWindow,"DPanel")
