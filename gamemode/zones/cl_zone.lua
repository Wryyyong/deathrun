local CurTime = CurTime
local LocalPlayer = LocalPlayer

local MathClamp = math.Clamp
local MathFloor = math.floor

local NetReadBool = net.ReadBool
local NetReadColor = net.ReadColor
local NetReadDouble = net.ReadDouble
local NetReadString = net.ReadString

local RenderDrawBeam = render.DrawBeam
local RenderSetMaterial = render.SetMaterial

local TableCopyFromTo = table.CopyFromTo

local DR = DR

local ZoneSystem = DR.ZoneSystem

local MapZones = ZoneSystem.MapZones
local ZonesExtraData = ZoneSystem.ZonesExtraData

local CvRenderZones = DR.ConVars.RenderZones

local MatLine = Material("color.vmt")

net.Receive("DeathrunSendZones",function(len)
	local newData = {}

	while NetReadBool() do
		local zone = {}
		newData[NetReadString()] = zone

		zone.type = NetReadString()
		zone.color = NetReadColor(true)
		zone.pos1 = Vector(
			NetReadDouble(),
			NetReadDouble(),
			NetReadDouble()
		)
		zone.pos2 = Vector(
			NetReadDouble(),
			NetReadDouble(),
			NetReadDouble()
		)
		zone.dir = Vector(
			NetReadDouble(),
			NetReadDouble(),
			NetReadDouble()
		)
	end

	TableCopyFromTo(newData,MapZones)

	ZoneSystem.CreateZonesExtraData()
end)

local BaseBeamWidth = 2
local BeamPointCached1 = Vector()
local BeamPointCached2 = Vector()
local BeamPointCached3 = Vector()
local BeamPointCached4 = Vector()
local BeamPointCached5 = Vector()
local BeamPointCached6 = Vector()
local BeamPointCached7 = Vector()
local BeamPointCached8 = Vector()

function ZoneSystem.DrawCuboid(posMin,posMax,col,alt)
	local rangeX = posMax[1] - posMin[1]
	local rangeY = posMax[2] - posMin[2]

	BeamPointCached1:Set(posMin)

	-- top level
	BeamPointCached2:SetUnpacked(rangeX,0,0)
	BeamPointCached2:Add(posMin)

	BeamPointCached3:SetUnpacked(0,rangeY,0)
	BeamPointCached3:Add(BeamPointCached2)

	BeamPointCached4:SetUnpacked(0,rangeY,0)
	BeamPointCached4:Add(posMin)

	BeamPointCached5:SetUnpacked(0,0,posMax[3] - posMin[3])
	BeamPointCached5:Add(posMin)

	BeamPointCached6:SetUnpacked(rangeX,0,0)
	BeamPointCached6:Add(BeamPointCached5)

	BeamPointCached7:SetUnpacked(0,rangeY,0)
	BeamPointCached7:Add(BeamPointCached6)

	BeamPointCached8:SetUnpacked(0,rangeY,0)
	BeamPointCached8:Add(BeamPointCached5)

	RenderSetMaterial(MatLine)

	RenderDrawBeam(BeamPointCached1,BeamPointCached2,BaseBeamWidth,1,1,col)
	RenderDrawBeam(BeamPointCached2,BeamPointCached3,BaseBeamWidth,1,1,col)
	RenderDrawBeam(BeamPointCached3,BeamPointCached4,BaseBeamWidth,1,1,col)
	RenderDrawBeam(BeamPointCached4,BeamPointCached1,BaseBeamWidth,1,1,col) -- top level
	RenderDrawBeam(BeamPointCached5,BeamPointCached6,BaseBeamWidth,1,1,col) -- bottom level
	RenderDrawBeam(BeamPointCached6,BeamPointCached7,BaseBeamWidth,1,1,col)
	RenderDrawBeam(BeamPointCached7,BeamPointCached8,BaseBeamWidth,1,1,col)
	RenderDrawBeam(BeamPointCached8,BeamPointCached5,BaseBeamWidth,1,1,col)

	-- Vertical connectors
	RenderDrawBeam(BeamPointCached1,BeamPointCached5,BaseBeamWidth,1,1,col)
	RenderDrawBeam(BeamPointCached2,BeamPointCached6,BaseBeamWidth,1,1,col)
	RenderDrawBeam(BeamPointCached3,BeamPointCached7,BaseBeamWidth,1,1,col)
	RenderDrawBeam(BeamPointCached4,BeamPointCached8,BaseBeamWidth,1,1,col)

	if not alt then return end

	local widthBoost = BaseBeamWidth * .5 * (1 + MathFloor(CurTime() * 4) % 2)

	RenderDrawBeam(BeamPointCached1,BeamPointCached3,widthBoost,1,1,col)
	RenderDrawBeam(BeamPointCached2,BeamPointCached4,widthBoost,1,1,col)
	RenderDrawBeam(BeamPointCached1,BeamPointCached6,widthBoost,1,1,col)
	RenderDrawBeam(BeamPointCached2,BeamPointCached5,widthBoost,1,1,col)
	RenderDrawBeam(BeamPointCached4,BeamPointCached7,widthBoost,1,1,col)
	RenderDrawBeam(BeamPointCached3,BeamPointCached8,widthBoost,1,1,col)
	RenderDrawBeam(BeamPointCached3,BeamPointCached6,widthBoost,1,1,col)
	RenderDrawBeam(BeamPointCached2,BeamPointCached7,widthBoost,1,1,col)
	RenderDrawBeam(BeamPointCached1,BeamPointCached8,widthBoost,1,1,col)
	RenderDrawBeam(BeamPointCached4,BeamPointCached5,widthBoost,1,1,col)
	RenderDrawBeam(BeamPointCached5,BeamPointCached7,widthBoost,1,1,col)
	RenderDrawBeam(BeamPointCached6,BeamPointCached8,widthBoost,1,1,col)
end

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

	for name,zone in next,MapZones do
		local type = zone.type
		if not type then return end

		local exData = ZonesExtraData[name]

		local dist = pos:DistToSqr(exData.centre)
		if dist >= MaxRenderDist then continue end

		local color = zone.color
		ColorCache:SetUnpacked(
			color.r,
			color.g,
			color.b,
			color.a * MathClamp(DR.InverseLerp(dist,MaxRenderDist,MinRenderDist),0,1)
		)

		local posMin = exData.min
		local posMax = exData.max

		ZoneSystem.DrawCuboid(
			posMin,
			posMax,
			ColorCache,

				type == "deny"
			or	type == "deny_team_runner" and isRunner
			or	type == "deny_team_death" and isDeath
		)
	end
end)
