--- @class DR_CustomPanelCanvas : Panel
--- @field Parent DR_CustomScrollPanel
local DR_CustomPanelCanvas = {}

function DR_CustomPanelCanvas:Init()
	local parent = self:GetParent()
	self.Parent = parent

	local width,height = parent:GetSize()

	self:SetSize(
		width - 10,
		height
	)
	self:SetMouseInputEnabled(true)
end

function DR_CustomPanelCanvas:OnMousePressed(keyCode)
	self.Parent:OnMousePressed(keyCode)
end

function DR_CustomPanelCanvas:Performlayout()
	local parent = self.Parent

	parent:PerformLayoutInternal()
	parent:InvalidateParent()
end

derma.DefineControl("DR_CustomPanelCanvas","",DR_CustomPanelCanvas,"Panel")
