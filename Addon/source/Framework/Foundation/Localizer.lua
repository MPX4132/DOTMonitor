-- =======================================================================================
-- Localizer V0.1
-- Simple text lookup table for WOW
-- =======================================================================================

local Localizer = {} -- Pun intended

function Localizer:Translator(...)
	local output = {}
	for i, aMsg in ipairs({...}) do
		table.insert(output, self[aMsg] or aMsg)
	end
	return unpack(output)
end

function Localizer:New(database)
	local newLocalizer = database or {}
	setmetatable(newLocalizer, {__call = self.Translator})
	return newLocalizer
end

MPXFoundation_Localizer = Localizer