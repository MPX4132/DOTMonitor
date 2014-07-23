-- =======================================================================================
-- TableSet V0.2
-- Simple [table] set "super-class" for WOW
-- =======================================================================================

local Table		= MPXFoundation_Table
local TableSet 	= Table:Subclass()

function TableSet:Union(tbl)		-- + Addition
	for k, v in pairs(tbl) do
		self:AddObject(v)
	end
	return self
end

function TableSet:Complement(tbl)	-- - Subtraction
	for k, v in pairs(tbl) do
		self:RemoveObject(v)
	end
	return self
end

function TableSet:AddKeyObject(key, value)
	if not self:ContainsObject(value) then
		rawset(self, key, value)
	end
end

function TableSet:AddObject(value)
	self:AddKeyObject(#self+1, value)
end

function TableSet:RemoveObject(value)
	local key = self:ContainsObject(value)
	if key then
		local value = self[key]
		self[key] = nil -- Remove it
		return value
	end
end

function TableSet:New(tSet)
	local newTableSet = tSet or {}
	setmetatable(newTableSet, {
		__index 	= TableSet,
		__newindex 	= TableSet.AddKeyObject,
		__eq	 	= TableSet.Equals,
		__add		= TableSet.Union,
		__sub		= TableSet.Complement,
	})
	return newTableSet
end

MPXFoundation_TableSet = TableSet