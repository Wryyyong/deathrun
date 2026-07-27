local Colors = DR.Colors
local ColorClouds = Colors.Clouds
local ColorGrey = Colors.Grey
local ColorTurq = Colors.Turq

--- @class DR_AuToggle : Panel
--- @field Button DR_ToggleButton
--- @field ConVar ConVar
local DR_AuToggle = {
	["State"] = false,
	["Text"] = "AuToggle Toggle Switch",
	["Font"] = "Deathrun_Derma_ExtraSmall",
	["Time"] = 0,
}

function DR_AuToggle:Init()
	self.Button = self:Add("DR_ToggleButton")
end

function DR_AuToggle:SetText(text)
	self.Text = text
	self:SizeToContents()
end

function DR_AuToggle.SetTextColor(self,color)
end

function DR_AuToggle:GetText()
	return self.Text
end

function DR_AuToggle:SetFont(font)
	self.Font = font
end

function DR_AuToggle:GetFont()
	return self.Font
end

function DR_AuToggle:PerformLayout()
	self.Button:SetSize(self:GetSize())
end

function DR_AuToggle:Think()
	local time = self.Time
	local threshold = self.State and 1 or 0

	if time == threshold then return end

	local diff = FrameTime() * 2

	if time > threshold then
		diff = -diff
	end

	self.Time = math.Clamp(time + diff,0,1)
end

function DR_AuToggle:Paint(_,height)
	local time = self.Time
	local heightHalf = height * .5

	local lerpFrac,lerpStart,lerpEnd

	if self.State then
		lerpFrac = time
		lerpStart = 1
		lerpEnd = 0
	else
		lerpFrac = 1 - time
		lerpStart = 0
		lerpEnd = 1
	end

	draw.NoTexture()

	surface.DrawCircle(
		16,
		heightHalf,
		8,
		ColorTurq
	)
	surface.DrawCircle(
		16,
		heightHalf,
		6,
		ColorClouds
	)
	surface.DrawCircle(
		16,
		heightHalf,
		4 * (1 - DR.QuadLerp(lerpFrac,lerpStart,lerpEnd)),
		ColorTurq
	)

	draw.SimpleText(
		self:GetText(),
		self:GetFont(),
		32, -- 8 + 16 + 8
		heightHalf,
		ColorGrey,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER,
		1
	)
end

function DR_AuToggle:SetConVar(str)
	self:SetConVarObj(GetConVar(str))
end

--- @param cvar ConVar
function DR_AuToggle:SetConVarObj(cvar)
	self.ConVar = cvar
	self.State = cvar:GetBool()
end

function DR_AuToggle:Toggle()
	self:SetValue(not self.State)
end

--- @param bool boolean?
function DR_AuToggle:SetValue(bool)
	self.State = bool

	local cVar = self.ConVar
	if not cVar then return end

	cVar:SetBool(bool)
end

function DR_AuToggle:SizeToContents()
	local fontWidth = surface.GetTextSize(self:GetText())

	surface.SetFont(self:GetFont())
	self:SetSize(fontWidth + 40,self:GetTall()) -- 16 + 8 + 8 + fontWidth + 8
end

derma.DefineControl("DR_AuToggle","",DR_AuToggle,"Panel")
