include("shared.lua")

SWEP.PrintName = "Unarmed"
SWEP.DrawWeaponInfoBox = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

function SWEP:PreDrawViewModel()
	return true
end

function SWEP:PreDrawWorldModel()
	return true
end
