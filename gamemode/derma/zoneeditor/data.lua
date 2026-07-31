local Iterator = ipairs({})

local DrawSimpleText = draw.SimpleText

local ColorGrey = DR.Colors.Grey

--- @class DR_ZoneData : DPanel
--- @field ZoneEdit DR_ZoneEditComboBox
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

local TextSize = 16
local Height = #InfoCache_Default * TextSize

function DR_ZoneData:Init()
	self.InfoCache = setmetatable({},InfoCache_Meta)

	self:SetSize(
		self:GetParent():GetWide(),
		Height
	)
end

function DR_ZoneData:Paint()
	for idx,info in Iterator,self.InfoCache,0 do
		local offset = idx - 1

		DrawSimpleText(info,"Deathrun_Derma_ExtraSmall",0,TextSize * offset,ColorGrey)
	end
end

derma.DefineControl("DR_ZoneData","",DR_ZoneData,"DPanel")
