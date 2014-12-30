-- =======================================================================================
-- SpellBook V0.1
-- Simple spell book abstraction class for WOW
-- =======================================================================================

local TableSet 	= _G["MPXFoundation_TableSet"]
local Spell		= _G["MPXWOWKit_Spell"]

local SpellBook = {} -- Local Namespace

function SpellBook:Update(player)
	self.player = player or self.player

	local levels = {GetSpecializationSpells(GetSpecialization())}

	self.spells = {}

	for i = 1, #allSpells / 2 do
	   spells[i] = {}
	   spells[i].id = table.remove(allSpells, 1)
	   spells[i].level = table.remove(allSpells, 1)
	end

	for i, s in ipairs(spells) do
	   print(GetSpellInfo(s.id))
	end
	
	


	local name, texture, offset, count = GetSpellTabInfo(2)
	offset = offset
	for spellIndex=offset+1, count+offset do
	   print(GetSpellInfo(spellIndex, "spell"))
	end



	
end

function SpellBook:Spell(index)
	return self.spells[index]
end

function SpellBook:Spells(subset)
	return 
end

function SpellBook:KnownSpells(subset)
end

function SpellBook:Contains(aSpell)
end

function SpellBook:New(player)
	local spellbook = {}
	setmetatable(spellbook, {__index = SpellBook})
	
	self.player = player

	return spellbook
end

MPXWOWKit_SpellBook = SpellBook -- Global Registration