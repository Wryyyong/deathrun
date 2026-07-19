print("Loaded pointshop support...")
local hasPointshop = false
local hasPointshop2 = false
local hadRedactedHub = false
if PS then hasPointshop = true end
if RS then hasRedactedHub = true end
if Pointshop2 then hasPointshop2 = true end
local CvFinishReward = DR.ConVars.PointShop.FinishReward
local CvKillReward = DR.ConVars.PointShop.KillReward
local CvWinReward = DR.ConVars.PointShop.WinReward
local CvRewardMessage = DR.ConVars.PointShop.RewardMessage
if SERVER then
	function DR:RewardPlayer(ply,amt,reason)
		amt = amt or 0
		if hasPointshop then
			ply:PS_GivePoints(amt)
			if CvRewardMessage:GetBool() then ply:PS_Notify("You were given " .. tostring(amt) .. " points for " .. (reason or "playing") .. "!") end
		end

		if hasRedactedHub then
			local storemoney = RS:GetStoreMoney() or 0
			if amt <= storemoney then
				ply:AddMoney(amt)
				RS:SubStoreMoney(amt)
				if CvRewardMessage:GetBool() then ply:DeathrunChatPrint("You were given " .. tostring(amt) .. " points for " .. (reason or "playing") .. "!") end
			else
				if CvRewardMessage:GetBool() then ply:DeathrunChatPrint("Unfortunately the store does not have enough points to reward you.") end
			end
		end

		if hasPointshop2 then
			--if PointshopRewardMessage:GetBool() then
			ply:PS2_AddStandardPoints(amt,"You were given " .. tostring(amt) .. " points for " .. (reason or "playing") .. "!",true)
		end
	end

	hook.Add("DeathrunPlayerFinishMap","PointshopRewards",function(ply,zname,z,place) DR:RewardPlayer(ply,CvFinishReward:GetInt(),"finishing the map") end)
	hook.Add("PlayerDeath","PointshopRewards",function(ply,inflictor,attacker) if attacker:IsPlayer() then if ply:Team() ~= attacker:Team() then DR:RewardPlayer(attacker,CvKillReward:GetInt(),"killing " .. ply:Nick()) end end end)
	hook.Add("DeathrunRoundWin","PointshopRewards",function(winner)
		for k,v in ipairs(player.GetAllPlaying()) do
			if v:Team() == winner then DR:RewardPlayer(v,CvWinReward:GetInt(),"winning the round") end
		end
	end)
end
