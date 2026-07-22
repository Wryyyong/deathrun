local Crosshair = DR.ConVars.Crosshair
local CvCrosshairColorR = Crosshair.ColorR
local CvCrosshairColorG = Crosshair.ColorG
local CvCrosshairColorB = Crosshair.ColorB
local CvCrosshairColorA = Crosshair.ColorA

--- @class DR_CrosshairColorMixer : DColorMixer
local DR_CrosshairColorMixer = {}

function DR_CrosshairColorMixer:Init()
	self:SetWide(self:GetParent():GetWide())

	self:SetConVarR(CvCrosshairColorR:GetName())
	self:SetConVarG(CvCrosshairColorG:GetName())
	self:SetConVarB(CvCrosshairColorB:GetName())
	self:SetConVarA(CvCrosshairColorA:GetName())
end

derma.DefineControl("DR_CrosshairColorMixer","",DR_CrosshairColorMixer,"DColorMixer")
