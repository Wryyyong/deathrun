local ZoneSystem = DR.ZoneSystem

--- @class DR_ZoneEditComboBox : DComboBox
local DR_ZoneEditComboBox = {}

function DR_ZoneEditComboBox:Init()
	self:SetSize(
		self:GetParent():GetWide(),
		18
	)
	self:SetValue(LocalPlayer().LastSelectZone or "Select Zone")

	for name in next,ZoneSystem.MapZones do
		self:AddChoice(name)
	end
end

function DR_ZoneEditComboBox:OnSelect(_,value)
	LocalPlayer().LastSelectZone = value

	local zoneData = self.ZoneData
	if not zoneData then return end

	local zone = ZoneSystem.MapZones[value]
	local cache = zoneData.InfoCache
	local color = zone.color

	cache[1] = "Zone Name: " .. value
	cache[2] = "Zone Type: " .. zone.type
	cache[3] = "Pos1: " .. tostring(zone.pos1)
	cache[4] = "Pos2: " .. tostring(zone.pos2)
	cache[5] = "Dir: " .. tostring(zone.dir)
	cache[6] = "Color: " .. color.r .. " " .. color.g .. " " .. color.b .. " " .. color.a
end

derma.DefineControl("DR_ZoneEditComboBox","",DR_ZoneEditComboBox,"DComboBox")
