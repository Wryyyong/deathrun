local next = next
local tonumber = tonumber

local MsgC = MsgC

local MathRandom = math.random

local NetBroadcast = net.Broadcast
local NetSend = net.Send
local NetStart = net.Start
local NetWriteString = net.WriteString

local PlayerIterator = player.Iterator

local DR = DR

local RoundSystem = DR.RoundSystem

local ColorTurq = DR.Colors.Turq

local CvDeathAvoidPunishment = DR.ConVars.DeathAvoidPunishment

local PlyMeta = FindMetaTable("Player")

local CUSTOMOBS_ROAMING = 1
local CUSTOMOBS_CHASE = 2
local CUSTOMOBS_INEYE = 3

function PlyMeta:Respawn()
	self:KillSilent()
	self:Spawn()
end

function PlyMeta:BeginSpectate()
	local roundState = RoundSystem.GetCurrent()

	if
		self:Team() == DR_TEAM_DEATH
	and	self.VoluntarySpec
	and	(
			roundState == DR_ROUND_PREP
		or	roundState == DR_ROUND_ACTIVE
		)
	and	#DR.GetAllPlaying() > 1
	then
		DR.PunishDeathAvoid(self,CvDeathAvoidPunishment:GetInt())

		DR.ChatBroadcast("Player " .. self:Nick() .. " will be punished for attempting to avoid being on the Death team!")
	end

	self.Spectating = true
	self.ObsMode = 0
	self:Spectate(OBS_MODE_IN_EYE)
	self.VoluntarySpec = false

	if not PS then return end

	--- @diagnostic disable-next-line: undefined-method
	self:PS_PlayerDeath()
end

-- when you want to end spectating immediately
function PlyMeta:StopSpectate()
	self.Spectating = false

	self:UnSpectate()
end

-- set whether they should stay in spectator even when the round starts
--- @param bool boolean
--- @param noSwitch boolean?
function PlyMeta:SetShouldStaySpectating(bool,noSwitch)
	self.StaySpectating = bool

	if
		not bool
	or	noSwitch
	then return end

	self:SetTeam(DR_TEAM_SPECTATOR)
end

-- check if they should respawn
--- @return boolean
function PlyMeta:ShouldStaySpectating()
	return self.StaySpectating or false
end

function PlyMeta:GetSpectate()
	return self.Spectating
end

--- @enum (key) DeathrunSpectateCycle
local SpectateCycle = {
	[CUSTOMOBS_ROAMING] = OBS_MODE_ROAMING,
	[CUSTOMOBS_CHASE] = OBS_MODE_CHASE,
	[CUSTOMOBS_INEYE] = OBS_MODE_IN_EYE,
}

function PlyMeta:ChangeSpectate()
	if not self:GetSpectate() then return end

	local newObs = next(SpectateCycle,self.ObsMode2)

	if not newObs then
		newObs = CUSTOMOBS_ROAMING
	end

	self.ObsMode2 = newObs

	self:Spectate(SpectateCycle[newObs])

	if newObs > CUSTOMOBS_ROAMING then
		-- check if they don't already have a spectator target
		local target = self:GetObserverTarget()

		if not target then
			-- this means we are spectating a player
			local pool = {}

			for _,ply in PlayerIterator() do
				if
					not ply:Alive()
				or	ply:GetSpectate()
				then continue end

				pool[#pool + 1] = ply
			end

			local newTarget = pool[MathRandom(#pool)]

			-- if they don't then give em one
			self:SpectateEntity(newTarget)
			self:SetupHands(newTarget)

			return
		end
	end

	self:SpecModify(0)
	self:SetupHands(self:GetObserverTarget())
end

function PlyMeta:SpecModify(num)
	local idx = self.SpecEntIdx or 1

	local pool = {}

	for _,ply in PlayerIterator() do
		if
			not ply:Alive()
		or	ply:GetSpectate()
		or	ply:IsGhost()
		then continue end

		pool[#pool + 1] = ply
	end

	local plyCount = #pool

	idx = idx + num

	if idx > plyCount then
		idx = 1
	end

	if idx < 1 then
		idx = plyCount
	end

	self.SpecEntIdx = idx

	local specEnt = pool[idx]

	if
		plyCount > 0
	and	specEnt
	then
		self:SpectateEntity(specEnt)

		local target = self:GetObserverTarget()

		if target then
			local pos = target:GetPos()
			pos:Add(target:OBBCenter())

			self:SetPos(target:EyePos() or pos)
			self:SetEyeAngles(target:EyeAngles())
		end

		self:SetupHands(
			self:GetObserverMode() == OBS_MODE_IN_EYE
		and	specEnt
		or	nil
		)

		return
	end

	if self:GetObserverMode() ~= OBS_MODE_IN_EYE then
		self:SetupHands(nil)
	end
end

function PlyMeta:SpecNext()
	self:SpecModify(1)
end

function PlyMeta:SpecPrev()
	self:SpecModify(-1)
end

hook.Add("KeyPress","DeathrunSpectateChangeObserverMode",function(self,key)
	if not self:GetSpectate() then return end

	if key == IN_JUMP then
		self:ChangeSpectate()
	elseif key == IN_ATTACK then
		-- cycle players forward
		self:SpecNext()
	elseif key == IN_ATTACK2 then
		-- cycle players bacwards
		self:SpecPrev()
	end
end)

concommand.Add("deathrun_toggle_spectate",function(ply)
	local isNotSpectating = ply:GetSpectate()

	if isNotSpectating then
		ply:BeginSpectate()
	end

	ply:SetShouldStaySpectating(isNotSpectating)
end)

concommand.Add("deathrun_set_spectate",function(ply,_,args)
	if tonumber(args[1]) == 1 then
		ply:KillSilent()
		ply:SetShouldStaySpectating(true,ply:Team() == DR_TEAM_DEATH)
		ply.VoluntarySpec = true
		ply:BeginSpectate()
	else
		ply:SetShouldStaySpectating(false)

		if RoundSystem.GetCurrent() == DR_ROUND_WAITING then
			ply:SetTeam(DR_TEAM_RUNNER)
			ply:Respawn()
		end
	end
end)

local LastMsg = ""

function PlyMeta:DeathrunChatPrint(msg)
	NetStart("DeathrunChatMessage")
		NetWriteString(msg)
	NetSend(self)

	local printMsg = "Server to " .. self:Nick() .. ": " .. msg .. "\n"
	if printMsg == LastMsg then return end

	MsgC(ColorTurq,printMsg)

	LastMsg = printMsg
end

function DR.ChatBroadcast(msg)
	NetStart("DeathrunChatMessage")
		NetWriteString(msg)
	NetBroadcast()

	MsgC(ColorTurq,"Server Broadcast: " .. msg .. "\n")
end

timer.Create("MoveSpectatorsToCorrectTeam",5,0,function()
	for _,ply in PlayerIterator() do
		if
			ply:Team() == DR_TEAM_SPECTATOR
		or	not ply:ShouldStaySpectating()
		then continue end

		ply:SetTeam(DR_TEAM_SPECTATOR)
	end
end)
