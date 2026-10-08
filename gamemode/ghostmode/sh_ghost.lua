local IsFirstTimePredicted = IsFirstTimePredicted

local GhostMode = DR.GhostMode
local Notifications = GhostMode.Notifications or {}
GhostMode.Notifications = Notifications

local PlyMeta = FindMetaTable("Player")

--[[
local PlyMetaSetupDataTables = PlyMeta.SetupDataTables or function() end

function PlyMeta:SetupDataTables()
	PlyMetaSetupDataTables(self)

	local ply = self.Player
	print("ply == self.Player",ply == self.Player)

	ply:NetworkVar("Bool","GhostMode")
	ply:NetworkVar("Int","GhostModePrevTeam")
	ply:NetworkVar("Vector","GhostSpawnPos")
	ply:NetworkVar("Angle","GhostSpawnAng")
end

PlyMeta.IsGhost = PlyMeta.GetGhostMode
--]]

function PlyMeta:IsGhost()
	return self:GetNWBool("IsGhost",false)
end

hook.Add("KeyPress","HandlePositionRequest",function(ply,key)
	if
		not (
			IsFirstTimePredicted()
		and	ply:IsGhost()
		)
	then return end

	if key == IN_ATTACK then
		if CLIENT then
			Notifications[#Notifications + 1] = {
				["Text"] = "Position saved",
				["Time"] = 3,
			}
		else
			ply:SetNWVector("Ghost_Spawnpoint_Position",ply:GetPos())
			ply:SetNWAngle("Ghost_Spawnpoint_Angle",ply:EyeAngles())
		end
	elseif key == IN_ATTACK2 then
		local newPos = ply:GetNWVector("Ghost_Spawnpoint_Position")

		if newPos == vector_origin then return end

		if CLIENT then
			Notifications[#Notifications + 1] = {
				["Text"] = "Position loaded",
				["Time"] = 3,
			}
		else
			ply:SetPos(newPos)
			ply:SetEyeAngles(ply:GetNWAngle("Ghost_Spawnpoint_Angle"))
		end
	end
end)
