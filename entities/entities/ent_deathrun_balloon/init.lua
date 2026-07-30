local CurTime = CurTime
local EffectData = EffectData
local HSVToColor = HSVToColor

local MathRandom = math.random

local UtilEffect = util.Effect

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local ColorCount = 0
local ColorTable = {}

for hue = 1,360,6 do
	ColorCount = ColorCount + 1

	ColorTable[ColorCount] = HSVToColor(hue,1,1)
end

local ForceCenterCache = Vector()
local StartCache = Vector()

function ENT:Initialize_Realm()
	local models = self.Models

	self:SetModel(models[MathRandom(#models)])
	self:SetColor(ColorTable[MathRandom(ColorCount)])
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	ForceCenterCache[3] = self:GetLifespan()

	local phys = self:GetPhysicsObject()
	phys:EnableGravity(false)
	phys:ApplyForceCenter(ForceCenterCache)

	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

function ENT:DoExplosion()
	local effect = EffectData()
	local color = self:GetColor()

	StartCache:SetUnpacked(
		color.r,
		color.g,
		color.b
	)

	effect:SetOrigin(self:GetPos())
	effect:SetStart(StartCache)

	UtilEffect("balloon_pop",effect)

	self:Remove()
end

function ENT:Think()
	if self:GetBornTime() + self:GetLifespan() >= CurTime() then return end

	self:DoExplosion()
end

ENT.OnTakeDamage = ENT.DoExplosion
