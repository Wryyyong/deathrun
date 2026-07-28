--- @class DR_Scoreboard : DPanel
local DR_Scoreboard = {
	["Distance"] = 0,
	["LastThink"] = -1,
	["IsOpen"] = false,

	["Paint"] = DR.EmptyFunction,
}

local Duration = .2

function DR_Scoreboard:Init()
	local height = DR.ScreenHeight

	self:SetSize(
		DR.ScreenWidth * .5,
		height - 100
	)
	self:SetY(height + 50)
	self:CenterHorizontal()

	self.Distance = 0
	self.LastThink = CurTime()
end

function DR_Scoreboard:Think()
	local height = DR.ScreenHeight
	local isOpen = self.IsOpen
	local curTime = CurTime()
	local yOld = self:GetY()

	local time = curTime - self.LastThink
	local newDist = math.Clamp(self.Distance + (isOpen and time or -time),0,Duration)

	self:SetY(DR.QuadLerp(math.Clamp(DR.InverseLerp(newDist,0,Duration),0,1),height + 50,50))

	self.LastThink = curTime
	self.Distance = newDist

	if
		isOpen
	or	yOld <= height
	then return end

	self:Remove()
end

derma.DefineControl("DR_Scoreboard","",DR_Scoreboard,"DPanel")
