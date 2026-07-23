local DR = DR

--- @alias ButtonEntData {
--- 	Claimed: boolean,
--- 	ClaimingPlayer: Player | NULL,
--- 	Position: Vector,
--- }

local ButtonClaims = DR.ButtonClaims or {
	--- @type table<number,ButtonEntData>
	["ButtonEnts"] = {},
	["ClaimRadius"] = 75 ^ 2, -- if you can knife it, you can claim it.
	["EntBits"] = 32, -- Initial safe value
}
DR.ButtonClaims = ButtonClaims
