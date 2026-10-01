local Vector = Vector

local NetReadDouble = net.ReadDouble
local NetWriteDouble = net.WriteDouble

--- @param vector Vector
--- @realm shared
--- @[net_payload("write", "double")]
--- @[net_payload("write", "double")]
--- @[net_payload("write", "double")]
function net.WriteVectorFull(vector)
	NetWriteDouble(vector[1])
	NetWriteDouble(vector[2])
	NetWriteDouble(vector[3])
end

--- @return Vector
--- @realm shared
--- @[net_payload("read", "double")]
--- @[net_payload("read", "double")]
--- @[net_payload("read", "double")]
function net.ReadVectorFull()
	return Vector(NetReadDouble(),NetReadDouble(),NetReadDouble())
end
