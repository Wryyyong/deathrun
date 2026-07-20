--- @class DR_ToggleButton : DButton
--- @field Parent DR_AuToggle
local DR_ToggleButton = {}

function DR_ToggleButton:Init()
	self.Parent = self:GetParent()

	self:SetText("")
	self:SetSize(self.Parent:GetSize())
end

DR_ToggleButton.Paint = DR.EmptyFunction

function DR_ToggleButton:DoClick()
	self.Parent:Toggle()
end

derma.DefineControl("DR_ToggleButton","",DR_ToggleButton,"DButton")
