-- =======================================================================================
-- Class V0.2
-- Simple table "super-class" for WOW
-- =======================================================================================

local Object = {} -- Fundamental Class

function Object:Subclass()
	local newClass = {}
	setmetatable(newClass, {__index = self})
	return newClass
end

function Object:Superclass()
	return getmetatable(self)
end

MPXFoundation_Object = Object