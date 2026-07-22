local Colors = DR.Colors
local ColorClouds = Colors.Clouds
local ColorTurq = Colors.Turq

local DermaColors = DR.DermaColors

local MatBlur = Material("pp/blurscreen")

--- @class DR_Window : DFrame
--- @field CloseButton DR_CloseButton
--- @field InnerWindow DR_InnerWindow
local DR_Window = {
	["Title"] = "Deathrun Window",
	["Width"] = 384,
	["Height"] = 548, -- 512 + 28 + 8
	["BgAlpha"] = 25,
	["BgColor"] = ColorClouds,
	["FgColor"] = ColorTurq,

	["OnClose"] = DR.EmptyFunction,
}

function DR_Window:Init()
	self:SetSize(self.Width,self.Height)
	self:Center()
	self:ShowCloseButton(false)

	self.lblTitle:SetVisible(false)

	self:SetupCloseButton()
	self:SetupInnerWindow()
end

function DR_Window:SetupCloseButton()
	local closeButton = self.CloseButton

	if closeButton then
		closeButton:Remove()
		self.CloseButton = nil
	end

	self.CloseButton = self:Add("DR_CloseButton")
end

function DR_Window:SetupInnerWindow()
	local innerWindow = self.InnerWindow

	if innerWindow then
		innerWindow:Remove()
		self.InnerWindow = nil
	end

	self.InnerWindow = self:Add("DR_InnerWindow")
end

function DR_Window:PerformLayout()
	local width,height = self:GetSize()

	local closeButton = self.CloseButton
	if IsValid(closeButton) then
		closeButton:SetSize(
			20,
			20
		)
		closeButton:SetPos(
			width - 24,
			4 -- 20 - 4
		)
	end

	local innerWindow = self.InnerWindow
	if IsValid(innerWindow) then
		innerWindow:SetSize(
			width,
			height - 36 -- 28 - 8
		)
		innerWindow:SetPos(
			0,
			28
		)
	end
end

function DR_Window:Paint(width,height)
	local colFg = self:GetPrimaryColor()
	local wide,tall = self:GetSize()
	local heightInner = height - 8

	surface.SetDrawColor(DermaColors.NeutralHigh)
	self:DrawPanelBlur(4)

	surface.SetDrawColor(self:GetSecondaryColor())
	surface.DrawRect(
		0,
		28,
		wide,
		tall - 36 -- 28 - 8
	)

	surface.SetDrawColor(colFg)
	draw.RoundedBox(
		0,
		0,
		0,
		width,
		16,
		colFg
	)
	surface.DrawRect(
		0,
		8,
		width,
		20
	)
	draw.RoundedBox(
		0,
		0,
		heightInner,
		width,
		8,
		colFg
	)
	surface.DrawRect(0,heightInner,width,4)

	-- title
	DR.ShadowTextSimple(
		self.Title,
		"Deathrun_Derma_WindowTitle",
		8,
		14,
		ColorClouds,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER
	)
end

--- @param amount number?
function DR_Window:DrawPanelBlur(amount)
	local width = ScrW()
	local height = ScrH()
	local x,y = self:LocalToScreen(0,0)

	x = -x
	y = -y
	amount = amount or 7

	surface.SetDrawColor(color_white)
	surface.SetMaterial(MatBlur)

	for pass = 1,3 do -- 3 pass blur i guess?
		MatBlur:SetFloat("$blur",(pass / 3) * amount)
		MatBlur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x,y,width,height)
	end
end

function DR_Window:SetPrimaryColor(color)
	self.FgColor = color:Copy()
end

function DR_Window:SetSecondaryColor(color)
	self.BgColor = color:Copy()
end

function DR_Window:GetPrimaryColor()
	return self.FgColor
end

function DR_Window:GetSecondaryColor()
	return self.BgColor
end

function DR_Window:SetTitle(str)
	self.Title = str:upper()
end

derma.DefineControl("DR_Window","",DR_Window,"DFrame")
