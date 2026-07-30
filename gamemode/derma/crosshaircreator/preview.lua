local SurfaceSetDrawColor = surface.SetDrawColor
local SurfaceDrawRect = surface.DrawRect

local HUD = DR.UI.HUD

--- @class DR_CrosshairPreview : DPanel
local DR_CrosshairPreview = {}

function DR_CrosshairPreview:Init()
	local width,height = self:GetParent():GetSize()

	self:SetSize(
		width * .25 - 2,
		height + 8
	)
	self:SetPos(0,0)
end

function DR_CrosshairPreview:Paint(width,height)
	SurfaceSetDrawColor(0,0,0,200)
	SurfaceDrawRect(
		0,
		0,
		width,
		height
	)

	HUD.DrawCrosshair(
		width * .5,
		height * .5
	)
end

derma.DefineControl("DR_CrosshairPreview","",DR_CrosshairPreview,"DPanel")
