local Colors = DR.Colors
local ColorClouds = Colors.Clouds
local ColorGrey = Colors.Grey
local ColorTurq = Colors.Turq

--- @class DR_ScoreboardTop : DR_ScoreboardItemBase
local DR_ScoreboardTop = {
	["Counter"] = .5,
}

function DR_ScoreboardTop:Init()
	self:SetTall(48)

	self.BgColor = ColorTurq or ColorGrey
end

function DR_ScoreboardTop:Paint(width,height)
	local heightMod = height * .5 - 2
	local hostName = GetHostName()
	local newCounter = self.Counter + FrameTime() / 12

	if newCounter > 1 then
		newCounter = 0
	end

	self.Counter = newCounter

	surface.SetDrawColor(self.BgColor)
	surface.DrawRect(
		0,
		0,
		width,
		height
	)

	surface.SetDrawColor(255,255,255,155 * (1 - (math.sin(CurTime()) + 1) * .5) ^ .1)
	surface.DrawRect(
		0,
		0,
		width,
		height
	)

	surface.SetDrawColor(0,0,0,100)
	surface.DrawRect(
		0,
		height,
		width,
		3
	)

	-- make the hostname scroll left and right
	surface.SetFont("Deathrun_Derma_Large")
	local fontWidth,fontHeight = surface.GetTextSize(hostName)
	fontWidth = fontWidth + 64 -- 64 pixel gap

	if fontWidth > width then
		DR.ShadowTextSimple(
			hostName,
			"Deathrun_Derma_Large",
			4 + fontWidth - self.Counter * fontWidth,
			heightMod,
			ColorClouds,
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER,
			1
		)
		DR.ShadowTextSimple(
			hostName,
			"Deathrun_Derma_Large",
			4 - self.Counter * fontWidth,
			heightMod,
			ColorClouds,
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER,
			1
		)
	else
		DR.ShadowTextSimple(
			hostName,
			"Deathrun_Derma_Large",
			width * .5,
			heightMod,
			ColorClouds,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER,
			1
		)
	end
end

derma.DefineControl("DR_ScoreboardTop","",DR_ScoreboardTop,"DR_ScoreboardItemBase")
