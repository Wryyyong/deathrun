--[[---------------------------------------------------------
   Initializes the effect. The data is a table of data
   which was passed from the server.
---------------------------------------------------------]]--
sound.Add({
	["name"] = "Deathrun.BalloonPop",
	["sound"] = "garrysmod/balloon_pop_cute.wav",
	["channel"] = CHAN_AUTO,
	["level"] = 90,
	["pitch"] = {90,120},
})

local ParticleCount = 32
local Gravity = Vector(0,0,-300)

local PosCache = Vector()
local VelocityCache = Vector()
local AngleCache = Angle()

function EFFECT:Init(data)
	local offset = data:GetOrigin()
	local start = data:GetStart()

	local emitter = ParticleEmitter(offset,true)

	for _ = 1,ParticleCount do
		local size = math.Rand(1,3)
		local darkness = math.Rand(.8,1)

		AngleCache:SetUnpacked(
			math.Rand(-160,160),
			math.Rand(-160,160),
			math.Rand(-160,160)
		)
		PosCache:SetUnpacked(
			math.Rand(-1,1),
			math.Rand(-1,1),
			math.Rand(-1,1)
		)
		VelocityCache:Set(PosCache)
		VelocityCache:Mul(500)

		PosCache:Mul(8)
		PosCache:Add(offset)

		local particle = emitter:Add("particles/balloon_bit",PosCache)

		particle:SetGravity(Gravity)
		particle:SetVelocity(VelocityCache)
		particle:SetAngleVelocity(AngleCache)

		particle:SetColor(
			start[1] * darkness,
			start[2] * darkness,
			start[3] * darkness
		)

		particle:SetLifeTime(0)
		particle:SetDieTime(10)

		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)

		particle:SetStartSize(size)
		particle:SetEndSize(0)

		particle:SetRoll(math.Rand(0,360))
		particle:SetRollDelta(math.Rand(-2,2))

		particle:SetAirResistance(100)
		particle:SetBounce(1)

		particle:SetCollide(true)
		particle:SetLighting(true)
	end

	sound.Play("Deathrun.BalloonPop",offset)

	emitter:Finish()
end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think()
	return false
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()
end
