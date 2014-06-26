-- =======================================================================================
-- Table V0.1
-- Simple table "super-class" for WOW
-- =======================================================================================

local Table = {} -- Pun intended

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

local TableDefault = {
	Count 	= Table.Count,
	Keys 	= Table.Keys,
	Values 	= Table.Values
}

function Table:New(t)
	local newTable = t or {}
	setmetatable(newTable, {__index = TableDefault, __eq = self.Equals})

	return newTable
end

MPXFoundation_Table = Table