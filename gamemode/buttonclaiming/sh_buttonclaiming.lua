--- @alias ButtonEntData {
--- 	Claimed: boolean,
--- 	ClaimingPlayer: Player | NULL,
--- 	Position: Vector,
--- }

local ButtonClaimSystem = DR.ButtonClaimSystem or {
	--- @type table<number,ButtonEntData>
	["ButtonEnts"] = {},
	["ClaimRadius"] = 75 ^ 2, -- if you can knife it, you can claim it.
	["EntBits"] = 32, -- Initial safe value
}
DR.ButtonClaimSystem = ButtonClaimSystem
