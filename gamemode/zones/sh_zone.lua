local Vector = Vector

local DR = DR

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
ZoneSystem.MapZones = ZoneSystem.MapZones or {}

function DR.VectorMinMax(vec1,vec2)
	local min = Vector()
	local max = Vector()

	if vec1[1] > vec2[1] then
		max[1] = vec1[1]
		min[1] = vec2[1]
	else
		max[1] = vec2[1]
		min[1] = vec1[1]
	end

	if vec1[2] > vec2[2] then
		max[2] = vec1[2]
		min[2] = vec2[2]
	else
		max[2] = vec2[2]
		min[2] = vec1[2]
	end

	if vec1[3] > vec2[3] then
		max[3] = vec1[3]
		min[3] = vec2[3]
	else
		max[3] = vec2[3]
		min[3] = vec1[3]
	end

	return min,max
end
