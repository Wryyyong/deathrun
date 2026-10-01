--- @diagnostic disable: undefined-field
local ipairs = ipairs({})

local DR = DR

local PlayerFilters = DR.PlayerFilters

local ConVarsPointShop = DR.ConVars.PointShop

local CvFinishReward = ConVarsPointShop.FinishReward
local CvKillReward = ConVarsPointShop.KillReward
local CvWinReward = ConVarsPointShop.WinReward
local CvRewardMessage = ConVarsPointShop.RewardMessage

local HasPointShop = PS ~= nil
local HasPointShop2 = Pointshop2 ~= nil
local HasRedactedHub = RS ~= nil

--- @param amount integer
--- @param reason string
function DR.RewardPlayer(ply,amount,reason)
	amount = amount or 0

	if HasPointShop then
		ply:PS_GivePoints(amount)

		if CvRewardMessage:GetBool() then
			ply:PS_Notify("You were given " .. amount .. " points for " .. (reason or "playing") .. "!")
		end
	elseif HasPointShop2 then
		ply:PS2_AddStandardPoints(amount,"You were given " .. amount .. " points for " .. (reason or "playing") .. "!",true)
	elseif HasRedactedHub then
		local storedMoney = RS:GetStoreMoney() or 0
		local msg

		if amount <= storedMoney then
			ply:AddMoney(amount)
			RS:SubStoreMoney(amount)

			msg = "You were given " .. amount .. " points for " .. (reason or "playing") .. "!"
		else
			msg = "Unfortunately, the store does not have enough points to reward you."
		end

		if CvRewardMessage:GetBool() then
			ply:DeathrunChatPrint(msg)
		end
	end
end

hook.Add("DeathrunPlayerFinishMap","PointshopRewards",function(ply)
	DR.RewardPlayer(ply,CvFinishReward:GetInt(),"Finishing the map")
end)

hook.Add("PlayerDeath","PointshopRewards",function(ply,_,attacker)
	if
		not attacker:IsPlayer()
	or	ply:Team() == attacker:Team()
	then return end

	DR.RewardPlayer(attacker,CvKillReward:GetInt(),"Killing " .. ply:Nick())
end)

--- @param winningTeam integer
hook.Add("DeathrunRoundWin","PointshopRewards",function(winningTeam)
	for _,ply in ipairs,PlayerFilters.WinningTeams[winningTeam]:GetPlayers(),0 do
		DR.RewardPlayer(ply,CvWinReward:GetInt(),"Winning the round")
	end
end)
