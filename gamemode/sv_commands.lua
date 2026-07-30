local Iterator = ipairs({})

local print = print
local tonumber = tonumber

local CurTime = CurTime
local IsValid = IsValid
local MsgC = MsgC

local GameCleanUpMap = game.CleanUpMap

local NetSend = net.Send
local NetStart = net.Start
local NetWriteTable = net.WriteTable

local PlayerGetAll = player.GetAll
local PlayerIterator = player.Iterator

local UtilTraceHull = util.TraceHull

local DR = DR

local Hulls = DR.Hulls
local RoundSystem = DR.RoundSystem
local Stats = DR.Stats

local ColorTurq = DR.Colors.Turq

local CvUnstuckCooldown = DR.ConVars.UnstuckCooldown

--- @alias DeathrunChatCommandCallback fun(ply: Player,args: string[])

-- chat commands
--- @type table<string,DeathrunChatCommandCallback>
local ChatCommands = DR.ChatCommands or {}
DR.ChatCommands = ChatCommands

-- returns a table of players with name matching nick
--- @param nick string
--- @return Player[]
local function FindPlayersByName(nick)
	if
		not nick
	or	nick == "^"
	then
		return {}
	elseif nick == "*" then
		return PlayerGetAll()
	end

	--- @type Player[]
	local plyList = {}
	local nickLower = nick:lower()

	for _,ply in PlayerIterator() do
		if not ply:Nick():lower():find(nickLower) then continue end

		plyList[#plyList + 1] = ply
	end

	return plyList
end

--- @param ply Player?
---	@param msg string
function DR.SafeChatPrint(ply,msg)
	if IsValid(ply) then
		ply:DeathrunChatPrint(msg)
	else
		MsgC(ColorTurq,msg .. "\n")
	end
end

-- console commands
concommand.Add("deathrun_respawn",function(ply,cmd,args)
	local name = args[1]
	local canAccess = DR.CanAccessCommand(ply,cmd)
	local msg

	if name then
		if canAccess then
			local targetList = FindPlayersByName(args[1])
			local playersStr = ""

			if #targetList > 0 then
				for _,target in Iterator,targetList,0 do
					target:Respawn()

					playersStr = (playersStr ~= "" and ", " or playersStr) .. target:Nick()
				end
			end

			msg = "Respawned " .. playersStr .. "."
		else
			msg = "You are not allowed to do that."
		end
	else
		if
			(
				canAccess
			or	RoundSystem.GetCurrent() == DR_ROUND_WAITING
			)
		and	ply:Team() ~= DR_TEAM_SPECTATOR
		then
			ply:Respawn()

			msg = "Respawned yourself."
		else
			msg = "You can't do that right now."
		end
	end

	DR.SafeChatPrint(ply,msg)
end,nil,nil,FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("deathrun_cleanup",function(ply,cmd,args)
	local msg

	if
		DR.CanAccessCommand(ply,cmd)
	or	RoundSystem.GetCurrent() == DR_ROUND_WAITING
	then
		GameCleanUpMap()

		msg = "Cleaned up the map and reset entities."
	else
		msg = "You are not allowed to do that."
	end

	DR.SafeChatPrint(ply,msg)
end,nil,nil,FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("deathrun_get_stats",function(ply,cmd,args)
	local name = args[1]
	local msg

	if name then
		local targetList = FindPlayersByName(args[1])
		local targetCount = #targetList

		if targetCount == 1 then
			local target = targetList[1]

			NetStart("DeathrunSendStats")
				local data = Stats.ReturnStats(target)
				data.Name = target:Nick()

				NetWriteTable(data)
			NetSend(ply)
		elseif targetCount > 1 then
			msg = "One player at a time, please."
		else
			msg = "No targets found with that name."
		end
	else
		NetStart("DeathrunSendStats")
			local data = Stats.ReturnStats(ply)
			data.Name = ply:Nick()

			NetWriteTable(data)
		NetSend(ply)
	end

	if not msg then return end

	DR.SafeChatPrint(ply,msg)
end)

local ValidPrefixes = {
	["!"] = true,
	["/"] = true,
}

hook.Add("PlayerSay","ProcessDeathrunChat",function(ply,text)
	local args = text:Split(" ")
	local cmdArg = args[1]

	local prefix = cmdArg:sub(1,1)
	if not ValidPrefixes[prefix] then return end

	local func = ChatCommands[cmdArg:sub(2,-1)]
	if not func then return end

	--- @type string[]
	local newArgs = {}
	local argCount = #args

	if argCount > 1 then
		for idx = 2,argCount do
			newArgs[idx - 1] = args[idx]
		end
	end

	func(ply,newArgs)

	return ""
end)

-- unstuck command
local UnstuckTraceCache = {
	["start"] = vector_origin,
	["endpos"] = vector_origin,
	["mins"] = Hulls.HullMin,
	["maxs"] = Hulls.HullStand,
	["mask"] = MASK_SHOT_HULL,
}
local UnstuckOnCooldown = {}

hook.Add("EntityTakeDamage","DeathrunUnstuckBlocker",function(ply)
	if not ply:IsPlayer() then return end

	UnstuckOnCooldown[ply] = CurTime()
end)

concommand.Add("deathrun_unstuck",function(ply,cmd,args)
	local curTime = CurTime()

	if
		not (
			DR.CanAccessCommand(ply,cmd)
		and	ply:Alive()
		and	ply:GetObserverMode() == OBS_MODE_NONE
		and	curTime > (UnstuckOnCooldown[ply] or 0) + CvUnstuckCooldown:GetInt()
		)
	then
		ply:DeathrunChatPrint("You can't use that right now.")

		return
	end

	local eyePos = ply:EyePos()
	local aimVec = ply:GetAimVector()
	aimVec:Mul(20)
	aimVec:Add(eyePos)

	UnstuckTraceCache.start = eyePos
	UnstuckTraceCache.endpos = aimVec
	UnstuckTraceCache.filter = ply

	local trace = UtilTraceHull(UnstuckTraceCache)
	local hitPos = trace.HitPos

	eyePos:Sub(ply:GetPos())
	hitPos:Sub(eyePos)

	ply:SetPos(hitPos)

	UnstuckOnCooldown[ply] = CurTime()

	DR.ChatBroadcast(ply:Nick() .. " attempted to free themselves from the clutches of a bugged trap.")
end)

concommand.Add("deathrun_punish",function(ply,cmd,args)
	local name = args[1]
	local rounds = tonumber(args[2]) or 1
	local msg

	if
		DR.CanAccessCommand(ply,cmd)
	and	name
	then
		local targetList = FindPlayersByName(name)
		local targetCount = #targetList

		if targetCount == 1 then
			local target = targetList[1]

			DR.PunishDeathAvoid(target,rounds)

			msg = "Punishing " .. target:Nick() .. " for another " .. DR.GetDeathAvoiderRounds(target) .. " rounds."
		elseif targetCount > 1 then
			msg = "Too many targets to punish."
		else
			msg = "No targets to punish."
		end
	else
		msg = "You are not allowed to do that."
	end

	DR.SafeChatPrint(ply,msg)
end)

--- @param cmd string
--- @param func DeathrunChatCommandCallback
function DR.AddChatCommand(cmd,func)
	ChatCommands[cmd] = func

	print("Deathrun - Added chat command " .. cmd)
end

--- @param cmd string
--- @param alias string
function DR.AddChatCommandAlias(cmd,alias)
	ChatCommands[alias] = ChatCommands[cmd]

	print("Deathrun - Added chat command alias " .. alias .. " -> " .. cmd)
end

DR.AddChatCommand("respawn",function(ply,args)
	ply:ConCommand("deathrun_respawn " .. (args[1] or ""))
end)

DR.AddChatCommand("cleanup",function(ply)
	ply:ConCommand("deathrun_cleanup")
end)

DR.AddChatCommand("crosshair",function(ply)
	ply:ConCommand("deathrun_open_crosshair_creator")
end)

DR.AddChatCommand("help",function(ply)
	ply:ConCommand("deathrun_open_help")
end)

DR.AddChatCommand("settings",function(ply)
	ply:ConCommand("deathrun_open_settings")
end)

DR.AddChatCommand("zones",function(ply)
	ply:ConCommand("deathrun_open_zone_editor")
end)

DR.AddChatCommand("info",function(ply)
	ply:ConCommand("deathrun_open_quickinfo")
end)

DR.AddChatCommand("1p",function(ply)
	ply:ConCommand("deathrun_thirdperson_enabled 0")
end)

DR.AddChatCommand("3p",function(ply)
	ply:ConCommand("deathrun_thirdperson_enabled 1")
end)

DR.AddChatCommand("firstperson",function(ply)
	ply:ConCommand("deathrun_toggle_thirdperson")
end)

DR.AddChatCommand("thirdperson",function(ply)
	ply:ConCommand("deathrun_toggle_thirdperson")
end)

DR.AddChatCommand("stats",function(ply,args)
	ply:ConCommand("deathrun_get_stats " .. (args[1] or ""))
end)

DR.AddChatCommand("spec",function(ply,args)
	ply:ConCommand("deathrun_spectate_only " .. (ply:ShouldStaySpectating() and 1 or 0))
end)

DR.AddChatCommand("stuck",function(ply,args)
	ply:ConCommand("deathrun_unstuck")
end)

DR.AddChatCommand("punish",function(ply,args)
	ply:ConCommand("deathrun_punish " .. (args[1] or "") .. " " .. (args[2] or ""))
end)

DR.AddChatCommandAlias("respawn","r")
DR.AddChatCommandAlias("stuck","unstuck")
