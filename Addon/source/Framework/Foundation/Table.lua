-- =======================================================================================
-- Table V0.2
-- Simple table "super-class" for WOW
-- =======================================================================================

local Object	= MPXFoundation_Object
local Table 	= Object:Subclass()

function Table:Array()
	local newArray = {}
	for k, v in pairs(self) do
		table.insert(newArray, v)
	end
	return newArray
end


function Table:Copy()
	local newTable = Table:New()
	for k, v in pairs(self) do
		newTable[k] = v
	end
	return newTable
end

function Table:Count()
	local counter = 0
	for k, v in pairs(self) do
		counter = counter + 1
	end
	return counter
end

function Table:Keys()
	local keys = {}
	for k, v in pairs(self) do
		table.insert(keys, k)
	end
	return keys
end

function Table:Values(keys)
	local values = {}
	for i, aKey in ipairs(keys or {}) do
		table.insert(values, self[aKey])
	end
	return values
end

function Table:Equals(tbl)
	if self:Count() ~= tbl:Count() then
		return false
	end

	for k, v in pairs(self) do
		if not tbl[k] or tbl[k] ~= v then
			return false
		end
	end
	return true
end

function Table:ContainsObject(value)
	for k, v in pairs(self) do	-- Simple sequential search, expect small lists
		if value == v then
			return k
		end
	end
	return nil
end

function Table:New(t)
	local newTable = t or {}
	setmetatable(newTable, {__index = Table, __eq = Table.Equals})

	return newTable
end

MPXFoundation_Table = Table