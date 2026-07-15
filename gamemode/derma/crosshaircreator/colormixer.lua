local ConVarsCrosshair = DR.ConVars.Crosshair
local CvCrosshair_ColorR = ConVarsCrosshair.ColorR
local CvCrosshair_ColorG = ConVarsCrosshair.ColorG
local CvCrosshair_ColorB = ConVarsCrosshair.ColorB
local CvCrosshair_ColorA = ConVarsCrosshair.ColorA

--- @class DR_CrosshairColorMixer : DColorMixer
local DR_CrosshairColorMixer = {}

function DR_CrosshairColorMixer:Init()
	self:SetWide(self:GetParent():GetWide())

	self:SetConVarR(CvCrosshair_ColorR:GetName())
	self:SetConVarG(CvCrosshair_ColorG:GetName())
	self:SetConVarB(CvCrosshair_ColorB:GetName())
	self:SetConVarA(CvCrosshair_ColorA:GetName())
end

derma.DefineControl("DR_CrosshairColorMixer","",DR_CrosshairColorMixer,"DColorMixer")
