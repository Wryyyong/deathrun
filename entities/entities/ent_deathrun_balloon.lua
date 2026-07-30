AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Balloon"
ENT.Author = "Arizard"
ENT.Contact = "Don't"
ENT.Category = "Deathrun"
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.Models = {
	Model("models/balloons/balloon_classicheart.mdl"),
	Model("models/balloons/balloon_dog.mdl"),
	Model("models/balloons/balloon_star.mdl"),
}

local ColorCount = 0
local ColorTable = {}

for hue = 1,360,6 do
	ColorCount = ColorCount + 1
	ColorTable[ColorCount] = HSVToColor(hue,1,1)
end

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)

	self:NetworkVar("Float","BornTime")
	self:NetworkVar("Int","Lifespan")
end

function ENT:Initialize()
	local models = self.Models

	self:SetModel(models[math.random(#models)])
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local lifespan = 10 + math.random(-2,2)
	self:SetBornTime(CurTime())
	self:SetLifespan(lifespan)

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()

		phys:EnableGravity(false)
		phys:ApplyForceCenter(Vector(0,0,lifespan))

		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end

	self:SetColor(ColorTable[math.random(#ColorCount)])
end

if SERVER then
	function ENT:DoExplosion()
		local effect = EffectData()
		local color = self:GetColor()

		effect:SetOrigin(self:GetPos())
		effect:SetStart(Vector(color.r,color.g,color.b))

		util.Effect("balloon_pop",effect)

		self:Remove()
	end

	function ENT:Think()
		if self:GetBornTime() + self:GetLifespan() >= CurTime() then return end

		self:DoExplosion()
	end

	ENT.OnTakeDamage = ENT.DoExplosion
else
	function ENT:Draw()
		self:DrawModel()
	end
end
