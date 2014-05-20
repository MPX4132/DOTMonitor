-- =======================================================================================
-- 	Spell := Wrapper for spells
-- ---------------------------------------------------------------------------------------
--	Spell (obj) =
--		(str) icon
-- =======================================================================================


-- =======================================================================================
-- 	Requirements
-- ---------------------------------------------------------------------------------------
local DOTMonitor = _G["DOTMonitor"]
-- =======================================================================================




local Spell = {}

Spell.prototype = {
	attributes = {
		name = nil,
		id = 0,
		icon = nil,
		cost = 0,
		duration = 0,
		castDuration = 0
	}
}

function Spell:ID()
	return self.attributes.id;
end

function Spell:Configure(spellID)
	self.attributes.id = spellID;
	name, rank, icon, powerCost, isFunnel, powerType, castingTime, minRange, maxRange = GetSpellInfo(self:ID());
end

function Spell:New(spellID)

end


-- =======================================================================================
-- 	Registration
-- ---------------------------------------------------------------------------------------
DOTMonitor.framework.Spell = Spell
-- =======================================================================================