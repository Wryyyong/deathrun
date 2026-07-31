local next = next
local tostring = tostring

local LocalPlayer = LocalPlayer

local ZoneSystem = DR.ZoneSystem

--- @class DR_ZoneEditComboBox : DComboBox
local DR_ZoneEditComboBox = {}

function DR_ZoneEditComboBox:Init()
	self:SetSize(
		self:GetParent():GetWide(),
		18
	)

	for name in next,ZoneSystem.MapZones do
		self:AddChoice(name)
	end

	self:SetSortItems(false)
end

function DR_ZoneEditComboBox:OnSelect(_,value)
	LocalPlayer().LastSelectZone = value

	local zoneData = self.ZoneData
	if not zoneData then return end

	local zone = ZoneSystem.MapZones[value]
	if not zone then return end

	self.CurrentZone = zone

	local cache = zoneData.InfoCache
	local color = zone.color

	cache[1] = "Zone Name: " .. value
	cache[2] = "Zone Type: " .. zone.type
	cache[3] = "Pos1: " .. tostring(zone.pos1)
	cache[4] = "Pos2: " .. tostring(zone.pos2)
	cache[5] = "Dir: " .. tostring(zone.dir)
	cache[6] = "Color: " .. color.r .. " " .. color.g .. " " .. color.b .. " " .. color.a

	self:UpdatePosWangs(1)
	self:UpdatePosWangs(2)
end

--- @param num 1 | 2
function DR_ZoneEditComboBox:UpdatePosWangs(num)
	local zone = self.CurrentZone

	--- @type Vector
	local posVec = zone["pos" .. num]
	--- @type DR_ZoneEditorButtonSetPosWangBase
	local wangs = self["Pos" .. num .. "Wangs"]

	if
		not (
			zone
		and posVec
		and wangs
		)
	then return end

	wangs.PosWangX:SetValue(posVec[1])
	wangs.PosWangY:SetValue(posVec[2])
	wangs.PosWangZ:SetValue(posVec[3])
end

derma.DefineControl("DR_ZoneEditComboBox","",DR_ZoneEditComboBox,"DComboBox")
