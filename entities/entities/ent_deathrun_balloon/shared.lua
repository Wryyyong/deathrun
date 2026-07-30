local CurTime = CurTime

local MathRand = math.Rand

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = true

ENT.Models = {
	Model("models/balloons/balloon_classicheart.mdl"),
	Model("models/balloons/balloon_dog.mdl"),
	Model("models/balloons/balloon_star.mdl"),
}

function ENT:SetupDataTables()
	self:NetworkVar("Float","BornTime")
	self:NetworkVar("Int","Lifespan")
end

function ENT:Initialize_Realm()
end

function ENT:Initialize()
	self:SetBornTime(CurTime())
	self:SetLifespan(10 + MathRand(-2,2))

	self:Initialize_Realm()
end
