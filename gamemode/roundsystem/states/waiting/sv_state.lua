local Iterator = ipairs({})

local GameCleanUpMap = game.CleanUpMap

local TimerCreate = timer.Create
local TimerRemove = timer.Remove

local DR = DR
local RoundSystem = DR.RoundSystem

local function WaitingStateCheck()
	if #DR.GetAllPlaying() < 2 then return end

	RoundSystem.RoundSwitch(DR_ROUND_PREP)

	TimerRemove("DeathrunWaitingStateCheck")
end

function ROUNDSTATE:EnterRealm()
	GameCleanUpMap()

	for _,ply in Iterator,DR.GetAllPlaying(),0 do
		ply:StripWeapons()
		ply:RemoveAllAmmo()
		ply:SetTeam(DR_TEAM_RUNNER)
		ply:Spawn()
	end

	TimerCreate("DeathrunWaitingStateCheck",5,0,WaitingStateCheck)
end
