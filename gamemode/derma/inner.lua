--- @class DR_Inner : DPanel
--- @field Parent DR_Frame
local DR_Inner = {
	["Paint"] = DR.EmptyFunction,
}

function DR_Inner:Init()
	self.Parent = self:GetParent()
end

derma.DefineControl("DR_Inner","",DR_Inner,"DPanel")
