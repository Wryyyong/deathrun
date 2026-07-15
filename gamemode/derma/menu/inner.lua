--- @class DR_MenuInner : DR_Inner
--- @field Controls DR_MenuControls
local DR_MenuInner = {}

function DR_MenuInner:Init()
	self:RefreshSettings()
end

function DR_MenuInner:RefreshSettings()
	local width,height = self.Parent:GetSize()

	self:SetSize(
		width - 8,
		height - 44
	)
	self:SetPos(4,32)
end

derma.DefineControl("DR_MenuInner","",DR_MenuInner,"DR_Inner")
