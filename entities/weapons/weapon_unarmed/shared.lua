SWEP.Base = "weapon_base"
SWEP.Slot = 6
SWEP.SlotPos = 0

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:CanPrimaryAttack()
	return false
end

function SWEP:CanSecondaryAttack()
	return false
end
