-- =======================================================================================
-- TableSet V0.1
-- Simple [table] set "super-class" for WOW
-- =======================================================================================

local TableSet = {}

function TableSet:Count()
	local counter = 0
	for k, v in pairs(self) do
		counter = counter + 1
	end
	return counter
end

function TableSet:Keys()
	local keys = {}
	for k, v in pairs(self) do
		table.insert(keys, k)
	end
	return keys
end

function TableSet:Values(keys)
	local values = {}
	for i, aKey in ipairs(keys or {}) do
		table.insert(values, self[aKey])
	end
	return values
end

function TableSet:Equals(tbl)
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

function TableSet:AddObject(value)
	self:AddKeyObject(#self+1, value)
end

function TableSet:AddKeyObject(key, value)
	if not self:ContainsObject(value) then
		rawset(self, key, value)
	end
end

function TableSet:RemoveObject(value)
	local key = self:ContainsObject(value)
	if key then
		self[key] = nil -- Remove it
	end
end

function TableSet:ContainsObject(value)
	for k, v in pairs(self) do	-- Simple sequential sort since it'll be a small list
		if value == v then
			return k
		end
	end
	return nil
end

local TableSetDefault = {
	Count 			= TableSet.Count,
	Keys 			= TableSet.Keys,
	Values 			= TableSet.Values,
	Equals 			= TableSet.Equals,
	AddObject		= TableSet.AddObject,
	AddKeyObject 	= TableSet.AddKeyObject,
	RemoveObject	= TableSet.RemoveObject,
	ContainsObject 	= TableSet.ContainsObject,
}

function TableSet:New(tSet)
	local newTableSet = tSet or {}
	setmetatable(newTableSet, {
		__index 	= TableSetDefault,
		__newindex 	= self.AddKeyObject,
		__eq	 	= self.Equals,
	})

	return newTableSet
end

MPXFoundation_TableSet = TableSet