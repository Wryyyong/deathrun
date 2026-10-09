--- @alias ButtonEntData {
--- 	Active: boolean,
--- 	Claimed: boolean,
--- 	ClaimingPlayer: Player | NULL,
---		Entity: Entity,
--- 	Position: Vector,
--- }

local ButtonClaimSystem = DR.ButtonClaimSystem

--- @type table<number,ButtonEntData>
ButtonClaimSystem.ButtonEnts = ButtonClaimSystem.ButtonEnts or {}
ButtonClaimSystem.ClaimRadius = 75 ^ 2 -- if you can knife it, you can claim it.
ButtonClaimSystem.EntBits = ButtonClaimSystem.EntBits or 32 -- Initial safe value
