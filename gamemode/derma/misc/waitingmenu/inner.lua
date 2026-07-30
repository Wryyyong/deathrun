local DR = DR

local Colors = DR.Colors
local ColorClouds = Colors.Clouds
local ColorGrey = Colors.Grey

local TextWidth = 600 - 24
local TextFont = "Deathrun_DefaultHUD_MediumLight"
local MenuText = DR.GetWordWrapText(
	[[Welcome to the server! Currently there are no players online.
This means that you can explore the map at your own pace
from the safety of godmode, so you can practice
your bunnyhopping and check for auto-traps with ease.\n\n
Some useful commands:\n
\t\b !respawn (or !r) — Respawn yourself\n
\t\b !cleanup — Reset and clean up the map\n
\t\b !help — View the help menu\n\n
Enjoy, and have fun!]],
	TextWidth,
	TextFont
)

--- @class DR_WaitingMenuInner : DR_MenuInner
local DR_WaitingMenuInner = {}

function DR_WaitingMenuInner:Paint(width,height)
	surface.SetDrawColor(ColorClouds)
	surface.DrawRect(
		0,
		0,
		width,
		height
	)

	DR.ShadowText(
		MenuText,
		TextFont,
		8,
		8,
		ColorGrey,
		nil,
		nil,
		0
	)
end

derma.DefineControl("DR_WaitingMenuInner","",DR_WaitingMenuInner,"DR_MenuInner")
