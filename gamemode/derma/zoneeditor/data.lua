local ipairs = ipairs({})

local DrawSimpleText = draw.SimpleText

local ColorGrey = DR.Colors.Grey

--- @class DR_ZoneData : DPanel
--- @field ZoneEdit DR_ZoneEditComboBox
local DR_ZoneData = {
	["InfoCache"] = {},
}

local TextSize = 16

local InfoCache_Default = {
	"Zone Name: ---------",
	"Enabled: ---------",
	"Zone Type: ---------",
	"Pos1: --- --- ---",
	"Pos2: --- --- ---",
	"Dir: --- --- ---",
	"Color: --- --- --- ---",
}
local InfoCache_Meta = {
	["__index"] = InfoCache_Default,
}

local Height = #InfoCache_Default * TextSize
local OffsetCache = {}

for idx in ipairs,InfoCache_Default,0 do
	OffsetCache[idx] = TextSize * (idx - 1)
end

function DR_ZoneData:Init()
	self.InfoCache = setmetatable({},InfoCache_Meta)

	self:SetSize(
		self:GetParent():GetWide(),
		Height
	)
end

function DR_ZoneData:Paint()
	for idx,info in ipairs,self.InfoCache,0 do
		DrawSimpleText(info,"Deathrun_Derma_ExtraSmall",0,OffsetCache[idx],ColorGrey)
	end
end

derma.DefineControl("DR_ZoneData","",DR_ZoneData,"DPanel")
