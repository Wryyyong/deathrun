local IsValid = IsValid
local LocalPlayer = LocalPlayer

local function IsGhost(ply)
	return ply:IsGhost()
end

local function IsNotGhost(ply)
	return not ply:IsGhost()
end

-- shared hooks
hook.Add("PlayerFootstep","RemoveGhostFootstep",IsGhost)

hook.Add("OnEntityCreated","SetCustomCollisionToAllPlayers",function(ent)
	if
		not (
			IsValid(ent)
		and	ent:IsPlayer()
		)
	then return end

	ent:SetCustomCollisionCheck(true)
end)

hook.Add("ShouldCollide","RemoveGhostCollision",function(entA,entB)
	return
		not (
			entA:IsPlayer()
		and	entB:IsPlayer()
		and	(
				entA:IsGhost()
			or	entB:IsGhost()
			)
		)
end)

hook.Add("EntityEmitSound","DisableGhostSound",function(soundInfo)
	local ent = soundInfo.Entity

	if
		(
			CLIENT
		and	ent == LocalPlayer()
		)
	or	not (
			ent:IsPlayer()
		and	ent:IsGhost()
		)
	then return end

	return false
end)

if SERVER then -- server side hooks
	hook.Add("PlayerSpray","DisableGhostSpray",IsGhost)

	hook.Add("PlayerCanPickupWeapon","DisableGhostPickupWeapons",IsNotGhost)
	hook.Add("PlayerUse","DisableGhostPicking",IsNotGhost)
	hook.Add("PlayerSwitchFlashlight","PlayerSwitchFlashlight",IsNotGhost)

	hook.Add("AcceptInput","FixGhostTeleport",function(ent,input,activator,caller,value)
		return
			activator:IsPlayer()
		and	activator:IsGhost()
	end)

	hook.Add("PlayerShouldTakeDamage","RemoveGhostDamage",function(target,dmg)
		return
			target:IsPlayer()
		and	not target:IsGhost()
	end)

	hook.Add("GetFallDamage","RemoveFallDamageSound",function(ply,speed)
		return
			(
				ply:IsPlayer()
			and	ply:IsGhost()
			)
		and	0
		or	nil
	end)
else -- client side hooks
	hook.Add("PrePlayerDraw","DrawGhosts",function(ply)
		return
			not LocalPlayer():IsGhost()
		and	ply:IsGhost()
	end)
end
