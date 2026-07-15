if DR.FontsInitialized then return end

for fontName,fontData in pairs({
	-- Derma
	["Deathrun_Derma_ExtraSmall"] = {
		["font"] = "Roboto Regular",
		["size"] = 18,
		["antialias"] = true,
		["weight"] = 500,
	},
	["Deathrun_Derma_Small"] = {
		["font"] = "Roboto Medium",
		["size"] = 24,
		["antialias"] = true,
	},
	["Deathrun_Derma_Medium"] = {
		["font"] = "Roboto Medium",
		["size"] = 34,
		["weight"] = 200,
	},
	["Deathrun_Derma_Large"] = {
		["font"] = "Roboto Black",
		["size"] = 45,
		["antialias"] = true,
	},
	["Deathrun_Derma_WindowTitle"] = {
		["font"] = "Roboto Black",
		["size"] = 18,
		["antialias"] = true,
	},

	-- 3D2D elements
	["Deathrun_3D2D_Small"] = {
		["font"] = "Roboto Black",
		["size"] = 50,
		["antialias"] = true,
	},
	["Deathrun_3D2D_Large"] = {
		["font"] = "Roboto Black",
		["size"] = 80,
		["antialias"] = true,
	},

	-- Default HUD
	["Deathrun_DefaultHUD_Small"] = {
		["font"] = "Roboto Bold",
		["size"] = 14,
		["antialias"] = true,
	},
	["Deathrun_DefaultHUD_MediumLight"] = {
		["font"] = "Roboto Regular",
		["size"] = 20,
		["antialias"] = true,
	},
	["Deathrun_DefaultHUD_Medium"] = {
		["font"] = "Roboto Bold",
		["size"] = 20,
		["antialias"] = true,
		["weight"] = 800
	},
	["Deathrun_DefaultHUD_Large"] = {
		["font"] = "Roboto Bold",
		["size"] = 48,
		["antialias"] = true,
		["weight"] = 800
	},
	["Deathrun_DefaultHUD_ExtraLarge"] = {
		["font"] = "Roboto Bold",
		["size"] = 48,
		["antialias"] = true,
		["weight"] = 1200
	},

	-- Classic HUD
	-- Taken from Mr. Gash's gamemode
	["Deathrun_ClassicHUD_Small"] = {
		["font"] = "Trebuchet18",
		["size"] = 14,
		["weight"] = 700,
		["antialias"] = true
	},
--[[
	["Deathrun_ClassicHUD_Medium"] = {
		["font"] = "Trebuchet18",
		["size"] = 24,
		["weight"] = 700,
		["antialias"] = true
	},
--]]
	["Deathrun_ClassicHUD_Large"] = {
		["font"] = "Trebuchet18",
		["size"] = 34,
		["weight"] = 700,
		["antialias"] = true
	},

	-- Sass HUD
--[[
	["Deathrun_SassHUD_ExtraSmall"] = {
		["font"] = "Coolvetica",
		["size"] = 12,
		["antialias"] = true,
		["weight"] = 500,
	},
--]]
	["Deathrun_SassHUD_Small"] = {
		["font"] = "Coolvetica",
		["size"] = 20,
		["antialias"] = true,
		["weight"] = 500,
	},
--[[
	["Deathrun_SassHUD_Medium"] = {
		["font"] = "Coolvetica",
		["size"] = 36,
		["antialias"] = true,
		["weight"] = 100,
	},
--]]
	["Deathrun_SassHUD_Large"] = {
		["font"] = "Coolvetica",
		["size"] = 56,
		["antialias"] = true,
	},

	-- CS:S SWEP icons
	["CSKillIcons"] = {
		["font"] = "csd",
		["weight"] = 500,
		["size"] = ScreenScale(30),
		["antialiasing"] = true,
		["additive"] = true
	},
	["CSSelectIcons"] = {
		["font"] = "csd",
		["weight"] = 500,
		["size"] = ScreenScale(60),
		["antialiasing"] = true,
		["additive"] = true
	},
}) do
	surface.CreateFont(fontName,fontData)
end

DR.FontsInitialized = true
