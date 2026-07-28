local ColorTurq = DR.Colors.Clouds

--- @class DR_MenuControls : DPanel
--- @field Parent DR_MenuInner
--- @field Scroll DR_CustomScrollPanel
local DR_MenuControls = {}

function DR_MenuControls:Init()
	self.Parent = self:GetParent()

	self:Setup()
end

function DR_MenuControls:Setup()
	self:SetupPos()
end

function DR_MenuControls:SetupPos()
	self:SetSize(self.Parent:GetSize())
	self:SetX(4)
end

function DR_MenuControls:Paint(width,height)
	surface.SetDrawColor(ColorTurq)
	surface.DrawRect(
		0,
		0,
		width,
		height
	)
end

--- @class DR_CrosshairControls : DR_MenuControls
local DR_CrosshairControls = {}

function DR_CrosshairControls:Init()
	self:Setup()
end

function DR_CrosshairControls:SetupPos()
	local width,height = self.Parent:GetSize()
	local widthMod = width * .75 - 2

	self:SetSize(
		widthMod,
		height
	)
	self:SetPos(
		width - widthMod,
		0
	)
end

derma.DefineControl("DR_MenuControls","",DR_MenuControls,"DPanel")

derma.DefineControl("DR_CrosshairControls","",DR_CrosshairControls,"DR_MenuControls")
