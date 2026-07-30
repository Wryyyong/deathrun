--- @alias ButtonEntData {
--- 	Claimed: boolean,
--- 	ClaimingPlayer: Player | NULL,
--- 	Position: Vector,
--- }

local ButtonClaimSystem = DR.ButtonClaimSystem

--- @type table<number,ButtonEntData>
ButtonClaimSystem.ButtonEnts = {}
ButtonClaimSystem.ClaimRadius = 75 ^ 2 -- if you can knife it, you can claim it.
ButtonClaimSystem.EntBits = 32 -- Initial safe value
