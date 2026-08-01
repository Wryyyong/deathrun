local Vector = Vector

--- @alias Zone {
--- 	type: string,
--- 	color: Color,
--- 	pos1: Vector,
--- 	pos2: Vector,
--- 	dir: Vector,
--- }

-- zone format
-- table containing the following
-- name (unique identifier)
-- corner1
-- corner2
-- color
-- type <start|end>
local ZoneSystem = DR.ZoneSystem

ZoneSystem.ZoneTypes = {
	"start",
	"end",

	"deny",
	"deny_team_death",
	"deny_team_runner",

	"custom1",
	"custom2",
	"custom3",
}

--- @type table<string,Zone>
local MapZones = ZoneSystem.MapZones or {}
ZoneSystem.MapZones = MapZones

local ZonesExtraData = ZoneSystem.ZonesExtraData or {}
ZoneSystem.ZonesExtraData = ZonesExtraData

local ZoneBorder = Vector(20,20,20)

function ZoneSystem.CreateZonesExtraData()
	for name,zone in next,MapZones do
		local posMin = Vector(zone.pos1)
		local posMax = Vector(zone.pos2)

		OrderVectors(posMin,posMax)

		local posMinBorder = Vector(posMin)
		local posMaxBorder = Vector(posMax)

		local posCentre = Vector()

		ZonesExtraData[name] = {
			["min"] = posMin,
			["max"] = posMax,
			["minBorder"] = posMinBorder,
			["maxBorder"] = posMaxBorder,
			["centre"] = posCentre,
		}

		posMinBorder:Sub(ZoneBorder)
		posMaxBorder:Add(ZoneBorder)

		posCentre:Add(posMin)
		posCentre:Add(posMax)
		posCentre:Mul(.5)
	end
end
