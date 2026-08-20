local setmetatable = setmetatable

local HookRun = hook.Run

local MathMax = math.max

local TimerCreate = timer.Create

local DR = DR

local RoundSystem = DR.RoundSystem

-- heheh
--- @type RoundState[]
local States = RoundSystem.States or {}
RoundSystem.States = States

-- for the round timer
-- have a shared ROUND_TIMER variable which continuously counts down each .2 second
-- timer going every .2s updating ROUND_TIMER so we have a precision of 1/5th of a second ?????
-- network each time the timer is set, but calculate the timer on server and client individually
RoundSystem.RoundTimer = RoundSystem.RoundTimer or 0

--- @param state integer
--- @return RoundState
function RoundSystem.UpdateState(state)
	local stateNew = RoundSystem.States[state]
	if not stateNew then return end

	RoundSystem.CurrentState = state
	RoundSystem.CurrentStateData = stateNew

	return stateNew
end

-- keep thinking for the current round, i.e. to check for living players
hook.Add("Think","DeathrunRoundThink",function()
	RoundSystem.CurrentStateData:Think()
end)

function RoundSystem.GetTimer()
	return RoundSystem.RoundTimer or 0
end

local TimerInterval = .2

TimerCreate("DeathrunRoundTimerCalculate",TimerInterval,0,function()
	RoundSystem.RoundTimer = MathMax(0,RoundSystem.RoundTimer - TimerInterval)
end)

RoundSystem.RoundsPlayed = RoundSystem.RoundsPlayed or 0

function RoundSystem.GetRoundsPlayed()
	return RoundSystem.RoundsPlayed
end

--- @class RoundState
local RoundState_Default = {
	["ID"] = DR_ROUND_INVALID,
	["EnterHook"] = "DeathrunBeginInvalid",

	["EnterShared"] = DR.EmptyFunction,
	["EnterRealm"] = DR.EmptyFunction,

	["ThinkShared"] = DR.EmptyFunction,
	["ThinkRealm"] = DR.EmptyFunction,

	["ExitShared"] = DR.EmptyFunction,
	["ExitRealm"] = DR.EmptyFunction,
}
local RoundState_Meta = {
	["__index"] = RoundState_Default,
}
RoundState_Default["BaseClass"] = RoundState_Default

-- Create round state constants
RoundSystem.CurrentState = RoundSystem.CurrentState or DR_ROUND_INVALID
RoundSystem.CurrentStateData = RoundSystem.CurrentStateData or RoundState_Default

function RoundState_Default:Enter()
	HookRun(self.EnterHook)

	self:EnterShared()
	self:EnterRealm()
end

function RoundState_Default:Think()
	self:ThinkShared()
	self:ThinkRealm()
end

function RoundState_Default:Exit()
	self:ExitShared()
	self:ExitRealm()
end

local SearchDir = "gamemodes/deathrun/gamemode/roundsystem/states/"

local _,dirs = file.Find(SearchDir .. "*","GAME")

local OldState = ROUNDSTATE

for _,state in ipairs(dirs) do
	local stateDir = state .. "/"
	local statePath = "states/" .. stateDir
	local statePathFull = SearchDir .. stateDir

	--- @type (instance) RoundState
	local newState = {}
	ROUNDSTATE = newState

	local fileSharedBase = "sh_state.lua"
	local fileSharedRel = statePath .. fileSharedBase

	if not file.Exists(statePathFull .. fileSharedBase,"GAME") then
		ErrorNoHaltWithStack("RoundState ",state," lacks a Shared script")

		continue
	end

	AddCSLuaFile(fileSharedRel)
	include(fileSharedRel)

	local fileClientBase = "cl_state.lua"
	local fileClientRel = statePath .. fileSharedBase

	if file.Exists(statePathFull .. fileClientBase,"GAME") then
		if SERVER then
			AddCSLuaFile(fileClientRel)
		else
			include(fileClientRel)
		end
	end

	local fileServerBase = "sv_state.lua"

	if SERVER and file.Exists(statePathFull .. fileServerBase,"GAME") then
		include(statePath .. fileServerBase)
	end

	setmetatable(newState,RoundState_Meta)

	local stateId = newState.ID

	if stateId == DR_ROUND_INVALID then
		ErrorNoHaltWithStack("RoundState ",state," does not set its own constant ID")

		continue
	end

	RoundSystem.States[stateId] = newState
end

ROUNDSTATE = OldState
