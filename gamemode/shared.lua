local IsValid = IsValid
local LocalPlayer = LocalPlayer
local FrameTime = FrameTime
local Vector = Vector

local Bitband = bit.band
local Bitbnot = bit.bnot

local HookRun = hook.Run

local MathClamp = math.Clamp

local PlayerIterator = player.Iterator

local Stringformat = string.format

local DR = DR

local Colors = DR.Colors
local RoundSystem = DR.RoundSystem

local ConVarsAutoJump = DR.ConVars.AutoJump
local CvAutoJump_Allowed = ConVarsAutoJump.Allowed
local CvAutoJump_VelocityCap = ConVarsAutoJump.VelocityCap
local CvAutoJump_Enabled = ConVarsAutoJump.Enabled

local ColorRunner = Colors.RunnerTeam
local ColorDeath = Colors.DeathTeam
local ColorGhost = Colors.GhostTeam
local ColorSilver = Colors.Silver

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

for idx = 1,40 do
	local pad = Stringformat("%02d",idx)
	local count = #NotAmusedSounds

	NotAmusedSounds[count + 1] = "vo/npc/male01/answer" .. pad .. ".wav"
	NotAmusedSounds[count + 2] = "vo/npc/female01/answer" .. pad .. ".wav"
end

sound.Add({
	["name"] = "Deathrun.NotAmused",
	["sound"] = NotAmusedSounds,
	["channel"] = CHAN_VOICE,
	["level"] = 300,
})

function GM:CreateTeams()
	team.SetUp(DR_TEAM_RUNNER,"Runners",ColorRunner,false)
	team.SetUp(DR_TEAM_DEATH,"Deaths",ColorDeath,false)
	team.SetUp(DR_TEAM_GHOST,"Ghosts",ColorGhost,false)

	team.SetSpawnPoint(DR_TEAM_RUNNER,"info_player_counterterrorist")
	team.SetSpawnPoint(DR_TEAM_DEATH,"info_player_terrorist")
	team.SetSpawnPoint(DR_TEAM_GHOST,"info_player_counterterrorist")

	team.SetColor(DR_TEAM_SPECTATOR,ColorSilver)
end

function DR.GetAllPlaying()
	--- @type Player[]
	local plyPool = {}

	for _,ply in PlayerIterator() do
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
		data:SetButtons(Bitband(data:GetButtons(),Bitbnot(IN_JUMP)))
	end

	if
		not (
			ply:Alive()
		and	RoundSystem.GetCurrent() == DR_ROUND_PREP
		)
	then return end

	local block = HookRun("DeathrunPreventPreptimeMovement") or true

	if
		block
	and	ply:Team() == DR_TEAM_RUNNER -- block movement for runners
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

--- @param ply Player
--- @param data CMoveData
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

	-- TODO: Find a way to utilize LengthSqr instead
	local speedWish = aimForward:Length()
	local speedMax = data:GetMaxSpeed()

	if speedWish > speedMax then
		aimForward:Mul(speedMax / speedWish)

		speedWish = speedMax
	end

	speedWish = MathClamp(speedWish,0,30)
	aimForward:Normalize()

	local speedAdd = speedWish - velocity:Dot(aimForward)

	if speedAdd <= 0 then return end

	local speedAccel = 1000 * FrameTime() * speedWish

	if speedAccel > speedAdd then
		speedAccel = speedAdd
	end

	aimForward:Mul(speedAccel)
	velocity:Add(aimForward)

	local velocityCap = CvAutoJump_VelocityCap:GetFloat()

	ply.SpeedCap =
		(ply.AutoJumpEnabled and CvAutoJump_Allowed:GetBool() and velocityCap > 0)
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

		localPly.AutoJumpEnabled = CvAutoJump_Enabled:GetBool()

		if ply ~= localPly then return end
	end

	if
		not (
			ply.AutoJumpEnabled
		and	CvAutoJump_Allowed:GetBool()
		)
	then return end

	local buttonData = data:GetButtons()

	if
		Bitband(buttonData,IN_JUMP) > 0
	and	ply:WaterLevel() < 2
	and	ply:GetMoveType() ~= MOVETYPE_LADDER
	and	not ply:IsOnGround()
	then
		data:SetButtons(Bitband(buttonData,Bitbnot(IN_JUMP)))
	end
end)

-- get rid of some default hooks
hook.Remove("PlayerTick","TickWidgets")

local function GetAccessLevel(ply)
	if not IsValid(ply) then return -1 end

	local access = DR.Ranks[ply:GetUserGroup()] or 1
	local accessPly = DR.PlayerAccess[ply:SteamID64()] or DR.PlayerAccess[ply:SteamID()]

	if accessPly then
		access = accessPly
	end

	return access or 1
end

function DR.CanAccessCommand(ply,cmd)
	return GetAccessLevel(ply) >= (DR.Permissions[cmd] or math.huge)
end
