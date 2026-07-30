--- @class DR_MenuScrollPanel : DR_CustomScrollPanel
--- @field Parent DR_Inner
local DR_MenuScrollPanel = {}

function DR_MenuScrollPanel:Init()
	local parent = self:GetParent()
	self.Parent = parent

	local width,height = parent:GetSize()

	self.pnlCanvas:SetSize(
		width - 16,
		height - 16
	)
	self:SetPos(8,8)

	self.VBar:SetWide(4)

	self:SizeToContents()
end

derma.DefineControl("DR_MenuScrollPanel","",DR_MenuScrollPanel,"DR_CustomScrollPanel")
