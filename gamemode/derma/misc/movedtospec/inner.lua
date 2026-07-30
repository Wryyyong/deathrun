local SurfaceSetDrawColor = CLIENT and surface.SetDrawColor
local SurfaceDrawRect = CLIENT and surface.DrawRect

local DR = DR

local Colors = DR.Colors
local UI = DR.UI

local ColorClouds = Colors.Clouds
local ColorGrey = Colors.Grey

local TextWidth = 640 - 24
local TextFont = "Deathrun_DefaultHUD_MediumLight"
local TextCommon =
[[
\n
\nTo move back, either click on one of the buttons below, or visit the "Spectator Settings" section of the !settings menu.
\n
\nWould you like to move back into to the game?
]]

--- @class DR_MovedToSpectatorInnerBase : DR_MenuInner
local DR_MovedToSpectatorInnerBase = {
	["Text"] = "",
}

function DR_MovedToSpectatorInnerBase:Paint(width,height)
	SurfaceSetDrawColor(ColorClouds)
	SurfaceDrawRect(
		0,
		0,
		width,
		height
	)

	UI.ShadowText(
		self.Text,
		TextFont,
		8,
		8,
		ColorGrey,
		nil,
		nil,
		0
	)
end

--- @class DR_MovedToSpectatorInnerAFK : DR_MovedToSpectatorInnerBase
local DR_MovedToSpectatorInnerAFK = {}

DR_MovedToSpectatorInnerAFK.Text = UI.GetWordWrapText(
	"You have been moved to the Spectator team for being AFK." .. TextCommon,
	TextWidth,
	TextFont
)

--- @class DR_MovedToSpectatorInnerReturning : DR_MovedToSpectatorInnerBase
local DR_MovedToSpectatorInnerReturning = {}

DR_MovedToSpectatorInnerReturning.Text = UI.GetWordWrapText(
	"You are currently in spectator mode." .. TextCommon,
	TextWidth,
	TextFont
)

derma.DefineControl("DR_MovedToSpectatorInnerBase","",DR_MovedToSpectatorInnerBase,"DR_MenuInner")

derma.DefineControl("DR_MovedToSpectatorInnerAFK","",DR_MovedToSpectatorInnerAFK,"DR_MovedToSpectatorInnerBase")
derma.DefineControl("DR_MovedToSpectatorInnerReturning","",DR_MovedToSpectatorInnerReturning,"DR_MovedToSpectatorInnerBase")
