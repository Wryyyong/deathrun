local Iterator = ipairs({})

local ColorGrey = DR.Colors.Grey

--- @class DR_ZoneData : DPanel
local DR_ZoneData = {
	["InfoCache"] = {},
}

local InfoCache_Default = {
	"Zone Name: ---------",
	"Zone Type: ---------",
	"Pos1: --- --- ---",
	"Pos2: --- --- ---",
	"Dir: --- --- ---",
	"Color: --- --- --- ---",
}
local InfoCache_Meta = {
	["__index"] = InfoCache_Default,
}

function DR_ZoneData:Init()
	self.InfoCache = setmetatable({},InfoCache_Meta)

	self:SetSize(
		self:GetParent():GetWide(),
		85
	)
end

function DR_ZoneData:Paint()
	for idx,info in Iterator,self.InfoCache,0 do
		local offset = idx - 1

		draw.SimpleText(info,"Deathrun_Derma_ExtraSmall",0,14 * offset,ColorGrey)
	end
end

derma.DefineControl("DR_ZoneData","",DR_ZoneData,"DPanel")
