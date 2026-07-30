local DR = DR

local ZoneSystem = DR.ZoneSystem
local MapZones = ZoneSystem.MapZones

local CvRenderZones = DR.ConVars.RenderZones

local MatLine = Material("color.vmt")

net.Receive("DeathrunSendZones",function()
	table.CopyFromTo(net.ReadTable(),MapZones)
end)

local BaseBeamWidth = 2
local BeamPointCache = {
	Vector(),
	Vector(),
	Vector(),
	Vector(),
	Vector(),
	Vector(),
	Vector(),
	Vector(),
}

function ZoneSystem.DrawCuboid(pos1,pos2,col,alt)
	local posMin,posMax = DR.VectorMinMax(pos1,pos2)

	local rangeX = posMax[1] - posMin[1]
	local rangeY = posMax[2] - posMin[2]

	local point1 = BeamPointCache[1]
	local point2 = BeamPointCache[2]
	local point3 = BeamPointCache[3]
	local point4 = BeamPointCache[4]
	local point5 = BeamPointCache[5]
	local point6 = BeamPointCache[6]
	local point7 = BeamPointCache[7]
	local point8 = BeamPointCache[8]

	point1:Set(posMin)

	-- top level
	point2:SetUnpacked(rangeX,0,0)
	point2:Add(posMin)

	point3:SetUnpacked(0,rangeY,0)
	point3:Add(point2)

	point4:SetUnpacked(0,rangeY,0)
	point4:Add(posMin)

	point5:SetUnpacked(0,0,posMax[3] - posMin[3])
	point5:Add(posMin)

	point6:SetUnpacked(rangeX,0,0)
	point6:Add(point5)

	point7:SetUnpacked(0,rangeY,0)
	point7:Add(point6)

	point8:SetUnpacked(0,rangeY,0)
	point8:Add(point5)

	render.SetMaterial(MatLine)

	render.DrawBeam(point1,point2,BaseBeamWidth,1,1,col)
	render.DrawBeam(point2,point3,BaseBeamWidth,1,1,col)
	render.DrawBeam(point3,point4,BaseBeamWidth,1,1,col)
	render.DrawBeam(point4,point1,BaseBeamWidth,1,1,col) -- top level
	render.DrawBeam(point5,point6,BaseBeamWidth,1,1,col) -- bottom level
	render.DrawBeam(point6,point7,BaseBeamWidth,1,1,col)
	render.DrawBeam(point7,point8,BaseBeamWidth,1,1,col)
	render.DrawBeam(point8,point5,BaseBeamWidth,1,1,col)

	-- Vertical connectors
	render.DrawBeam(point1,point5,BaseBeamWidth,1,1,col)
	render.DrawBeam(point2,point6,BaseBeamWidth,1,1,col)
	render.DrawBeam(point3,point7,BaseBeamWidth,1,1,col)
	render.DrawBeam(point4,point8,BaseBeamWidth,1,1,col)

	if not alt then return end

	local widthBoost = BaseBeamWidth * .5 * (1 + math.floor(CurTime() * 4) % 2)

	render.DrawBeam(point1,point3,widthBoost,1,1,col)
	render.DrawBeam(point2,point4,widthBoost,1,1,col)
	render.DrawBeam(point1,point6,widthBoost,1,1,col)
	render.DrawBeam(point2,point5,widthBoost,1,1,col)
	render.DrawBeam(point4,point7,widthBoost,1,1,col)
	render.DrawBeam(point3,point8,widthBoost,1,1,col)
	render.DrawBeam(point3,point6,widthBoost,1,1,col)
	render.DrawBeam(point2,point7,widthBoost,1,1,col)
	render.DrawBeam(point1,point8,widthBoost,1,1,col)
	render.DrawBeam(point4,point5,widthBoost,1,1,col)
	render.DrawBeam(point5,point7,widthBoost,1,1,col)
	render.DrawBeam(point6,point8,widthBoost,1,1,col)
end

local RenderCache = Vector()
local ColorCache = color_white:Copy()
local MaxRenderDist = 1000 ^ 2
local MinRenderDist = 400 ^ 2

hook.Add("PostDrawTranslucentRenderables","DeathrunZoneCuboidDrawing",function()
	if not CvRenderZones:GetBool() then return end

	local localPly = LocalPlayer()
	local pos = localPly:GetPos()

	local team = localPly:Team()
	local isRunner = team == DR_TEAM_RUNNER
	local isDeath = team == DR_TEAM_DEATH

	for name,zone in pairs(MapZones) do
		local type = zone.type
		if not type then return end

		local pos1 = zone.pos1
		local pos2 = zone.pos2
		RenderCache:SetUnpacked(0,0,0)
		RenderCache:Add(pos1)
		RenderCache:Add(pos2)
		RenderCache:Mul(.5)

		local dist = pos:DistToSqr(RenderCache)
		if dist >= MaxRenderDist then continue end

		local color = zone.color
		ColorCache:SetUnpacked(
			color.r,
			color.g,
			color.b,
			color.a * math.Clamp(DR.InverseLerp(dist,MaxRenderDist,MinRenderDist),0,1)
		)

		ZoneSystem.DrawCuboid(
			pos1,
			pos2,
			ColorCache,

				type == "deny"
			or	type == "deny_team_runner" and isRunner
			or	type == "deny_team_death" and isDeath
		)
	end
end)
