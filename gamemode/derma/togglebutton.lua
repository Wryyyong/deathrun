--- @class DR_ToggleButton : DButton
--- @field Parent DR_AuToggle
local DR_ToggleButton = {
	["Paint"] = DR.EmptyFunction,
}

function DR_ToggleButton:Init()
	local parent = self:GetParent()
	self.Parent = parent

	self:SetText("")
	self:SetSize(parent:GetSize())
end

function DR_ToggleButton:DoClick()
	self.Parent:Toggle()
end

derma.DefineControl("DR_ToggleButton","",DR_ToggleButton,"DButton")
