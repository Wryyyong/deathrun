-- local DR = DR or {}
-- _G["DR"] = DR

local DR = DR

local Colors = DR.Colors

GM.Name = "Deathrun"
GM.Author = "Arizard"
GM.Email = ""
GM.Website = "http://vhs7.tv"

DR.TimeStamp = 1462083778
DR.TimeStampFormatted = os.date("%Y-%m-%d %H:%M:%S",DR.TimeStamp)

sound.Add({
	["name"] = "Deathrun.PlayerDeath",
	["sound"] = {
		"vo/npc/male01/myarm01.wav",
		"vo/npc/male01/myarm02.wav",
		"vo/npc/male01/mygut02.wav",
		"vo/npc/male01/myleg01.wav",
		"vo/npc/male01/myleg02.wav",
		"vo/npc/male01/no01.wav",
		"vo/npc/male01/no02.wav",
		"vo/npc/male01/ohno.wav",
		"vo/npc/male01/ow01.wav",
		"vo/npc/male01/ow02.wav",
		"vo/npc/male01/pain04.wav",
		"vo/npc/male01/pain07.wav",
		"vo/npc/male01/pain08.wav",
		"vo/npc/male01/hacks02.wav",
	},
	["channel"] = CHAN_AUTO,
	["level"] = 400,
})

sound.Add({
	["name"] = "Deathrun.PlayerDrowning",
	["sound"] = {
		"player/pl_drown1.wav",
		"player/pl_drown2.wav",
		"player/pl_drown3.wav",
	},
	["channel"] = CHAN_AUTO,
	["level"] = 400,
})

--- @type string[]
local NotAmusedSounds = {}

for idx = 01,40 do
	local pad = string.format("%02d",idx)

	NotAmusedSounds[#NotAmusedSounds + 1] = "vo/npc/male01/answer" .. pad .. ".wav"
	NotAmusedSounds[#NotAmusedSounds + 1] = "vo/npc/female01/answer" .. pad .. ".wav"
end

sound.Add({
	["name"] = "Deathrun.NotAmused",
	["sound"] = NotAmusedSounds,
	["channel"] = CHAN_VOICE,
	["level"] = 300,
})

function DR.EmptyFunction()
end

--- @param max integer
--- @param min integer?
--- @param signed boolean?
--- @return integer
function DR.CalcMaxBits(max,min,signed)
	local useVal = math.max(max,math.abs(min or 0))

	return
		math.ceil(math.log(useVal + (useVal == max and 1 or 0),2))
	+	(signed and 1 or 0)
end

TEAM_RUNNER = 1
TEAM_DEATH = 2
TEAM_GHOST = 3

TEAM_BITS = DR.CalcMaxBits(TEAM_SPECTATOR)

function GM:CreateTeams()
	team.SetUp(TEAM_RUNNER,"Runners",Colors.RunnerTeam,false)
	team.SetUp(TEAM_DEATH,"Deaths",Colors.DeathTeam,false)
	team.SetUp(TEAM_GHOST,"Ghosts",Colors.GhostTeam,false)

	team.SetSpawnPoint(TEAM_RUNNER,"info_player_counterterrorist")
	team.SetSpawnPoint(TEAM_DEATH,"info_player_terrorist")
	team.SetSpawnPoint(TEAM_GHOST,"info_player_counterterrorist")

	team.SetColor(TEAM_SPECTATOR,Colors.Silver)
end

function DR.GetAllPlaying()
	--- @type Player[]
	local plyPool = {}

	for _,ply in player.Iterator() do
		if
			not IsValid(ply)
		or	ply:ShouldStaySpectating()
		then continue end

		plyPool[#plyPool + 1] = ply
	end

	return plyPool
end

hook.Add("SetupMove","DeathrunDisableSpectatorSpacebar",function(ply,data,cmd)
	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		data:SetButtons(bit.band(data:GetButtons(),bit.bnot(IN_JUMP)))
	end

	if
		not (
			ply:Alive()
		and	ROUND.GetCurrent() == ROUND_PREP
		)
	then return end

	local block = hook.Run("DeathrunPreventPreptimeMovement") or true

	if
		block
	and	ply:Team() == TEAM_RUNNER -- block movement for runners
	then
		data:SetSideSpeed(0)
		data:SetUpSpeed(0)
		data:SetForwardSpeed(0)
	end
end)

--- @param delta number
--- @param from number
--- @param to number
function DR.QuadLerp(delta,from,to)
	return (from - to) * (delta - 1) ^ 2 + to
end

--- @param delta number
--- @param from number
--- @param to number
function DR.InverseLerp(delta,from,to)
	local range = to - from

	if range == 0 then
		return 1
	end

	return (delta - from) / range
end

-- hull sizes
DR.Hulls = {
	["HullMin"] = Vector(-16,-16,0),
	["HullDuck"] = Vector(16,16,43),
	["HullStand"] = Vector(16,16,66),
	["ViewDuck"] = Vector(0,0,41),
	["ViewStand"] = Vector(0,0,64),
}

hook.Add("PlayerSpawn","HullSizes",function(ply)
	ply:SetHull(DR.Hulls.HullMin,DR.Hulls.HullStand)
	ply:SetHullDuck(DR.Hulls.HullMin,DR.Hulls.HullDuck) -- quack quack

	ply:SetViewOffset(DR.Hulls.ViewStand)
	ply:SetViewOffsetDucked(DR.Hulls.ViewDuck) -- quack

	ply:ConCommand("deathrun_reload_hull_client")
end)

-- I uh... "borrowed" this from Gravious. I need it but I don't know why.
-- fixes jump and duck stop
local GroundForce = {}
local VelocitySub = Vector(0,0,0)

function GM:Move(ply,data)
	if not IsValid(ply) then return end

	local plyGroundForce = GroundForce[ply]
	local isOnGround = ply:OnGround()

	if isOnGround then
		if plyGroundForce then
			plyGroundForce = GroundForce[ply] + 1

			if plyGroundForce > 4 then
				ply:SetDuckSpeed(.4)
				ply:SetUnDuckSpeed(.2)
			end
		else
			plyGroundForce = 0
		end

		GroundForce[ply] = plyGroundForce
	end

	if
		isOnGround
	or	not ply:Alive()
	then return end

	GroundForce[ply] = 0

	ply:SetDuckSpeed(0)
	ply:SetUnDuckSpeed(0)

	if CLIENT and ply ~= LocalPlayer() then return end

	local speedSide = data:GetSideSpeed()

	if data:KeyDown(IN_MOVERIGHT) then
		speedSide = speedSide + 500
	end

	if data:KeyDown(IN_MOVELEFT) then
		speedSide = speedSide - 500
	end

	local velocity = data:GetVelocity()
	local aim = data:GetMoveAngles()
	local aimForward = aim:Forward()
	local aimRight = aim:Right()

	aimForward[3] = 0
	aimRight[3] = 0

	aimForward:Normalize()
	aimRight:Normalize()

	aimForward:Mul(data:GetForwardSpeed())
	aimRight:Mul(speedSide)

	aimForward:Add(aimRight)

	local speedWish = aimForward:Length()
	local speedMax = data:GetMaxSpeed()

	if speedWish > speedMax then
		aimForward:Mul(speedMax / speedWish)

		speedWish = speedMax
	end

	speedWish = math.Clamp(speedWish,0,30)
	aimForward:Normalize()

	local speedAdd = speedWish - velocity:Dot(aimForward)

	if speedAdd <= 0 then return end

	local speedAccel = 1000 * FrameTime() * speedWish

	if speedAccel > speedAdd then
		speedAccel = speedAdd
	end

	aimForward:Mul(speedAccel)
	velocity:Add(aimForward)

	local velocityCap = DR.ConVars.AutoJump.VelocityCap:GetFloat()

	ply.SpeedCap =
		(ply.AutoJumpEnabled and DR.ConVars.AutoJump.Allow:GetBool() and velocityCap ~= 0)
	and	velocityCap
	or	99999

	if SERVER then
		local velocityLength2D = velocity:Length2D()

		if velocityLength2D > ply.SpeedCap then
			local diff = velocityLength2D - ply.SpeedCap

			VelocitySub[1] = velocity[1] > 0 and diff or -diff
			VelocitySub[2] = velocity[2] > 0 and diff or -diff

			velocity:Sub(VelocitySub)
		end
	end

	data:SetVelocity(velocity)

	return false
end

hook.Add("SetupMove","AutoHop",function(ply,data)
	if CLIENT then
		local localPly = LocalPlayer()

		localPly.AutoJumpEnabled = DR.ConVars.AutoJump.Enabled:GetBool()

		if ply ~= localPly then return end
	end

	if
		not (
			ply.AutoJumpEnabled
		and	DR.ConVars.AutoJump.Allow:GetBool()
		)
	then return end

	local buttonData = data:GetButtons()

	if
		bit.band(buttonData,IN_JUMP) > 0
	and	ply:WaterLevel() < 2
	and	ply:GetMoveType() ~= MOVETYPE_LADDER
	and	not ply:IsOnGround()
	then
		data:SetButtons(bit.band(buttonData,bit.bnot(IN_JUMP)))
	end
end)

-- get rid of some default hooks
hook.Remove("PlayerTick","TickWidgets")

function DR.GetAccessLevel(ply)
	if not IsValid(ply) then return -1 end

	local access = DR.Ranks[ply:GetUserGroup()] or 1
	local accessPly = DR.PlayerAccess[ply:SteamID64()] or DR.PlayerAccess[ply:SteamID()]

	if accessPly then
		access = accessPly
	end

	return access or 1
end

function DR.CanAccessCommand(ply,cmd)
	return DR.GetAccessLevel(ply) >= (DR.Permissions[cmd] or math.huge)
end
