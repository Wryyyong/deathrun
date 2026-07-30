local MapSettingsDir = "mapsettings"

if SERVER then
	for _,filePath in ipairs(file.Find("gamemode/mapsettings/*.lua","LUA",0 or {})) do
		AddCSLuaFile(MapSettingsDir .. "/" .. filePath)
	end
end

hook.Add("InitPostEntity","MapSettings",function()
	include(MapSettingsDir .. "/" .. game.GetMap() .. ".lua")
end)
