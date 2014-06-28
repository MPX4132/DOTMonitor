-- =======================================================================================
-- Spell V0.1
-- Simple spell abstraction for WOW
-- =======================================================================================

local Spell = {} -- Local Namespace

function Spell:ID()
	return self.id
end

function Spell:Set(ID, effect)
	if type(ID) == "string" then
		local link = self:Link(ID)
		ID = link and link:match("spell:(%d+)") or false
		if not ID then return end
	end

	self.id 	= ID
	self.effect = effect or ID
	self.name, self.rank, self.icon, self.cost, self.funnel,
	self.power, self.castTime, self.range.min, self.range.max = GetSpellInfo(ID)
end

function Spell:IsReady()
	-- IsSpellKnown is notorious for giving out false info
	-- return self.name ~= nil and IsSpellKnown(self.id)

	-- Using hack to see if anything's returned from spell info
	return GetSpellInfo(self.name) ~= nil
end

function Spell:IsInstant()
	return self.castTime == 0
end

function Spell:CastTime()
	return self.castTime
end

function Spell:GetCooldown()
	return GetSpellCooldown(self.id or self.name);
end

function Spell:IsHarmful()
	--return IsHarmfulSpell(self.name) and true or false
	return true -- The function above is bullshit, it's faulty
end

function Spell:IsHelpful()
	return IsHelpfulSpell(self.name) and true or false
end

function Spell:IsMisc()
	return not self:IsHarmful() and not self:IsHelpful()
end

function Spell:Type(aType)
	local spellType = (self:IsHarmful() and "harmful") or (self:IsHelpful() and "helpful") or "misc"
	return (aType and aType == spellType) or spellType
end

-- WARNING BELOW
function Spell:EffectIsInstant()
	return false -- TO DO
end

function Spell:IsDOT()
	return self:Type("harmful") and not self:EffectIsInstant()
end

function Spell:IsHOT()
	return self:Type("helpful") and not self:EffectIsInstant()
end

function Spell:HasMultipleEffects()
	return type(self.effect) == "table" and true or false
end

function Spell:Effects()
	return self:HasMultipleEffects() and self.effect or {self.effect}
end

function Spell:AffectingUnit(unit)
	return select(3, self:TimeOnUnit(unit or "target")) ~= nil
end

function Spell:TimeOnUnit(unit)
	local duration, expiration, caster = nil, nil, nil

	for i, effectID in ipairs(self:Effects()) do
		local name = (type(effectID) == "string" and effectID) or Spell:GetName(effectID)

		duration, expiration, caster = select(6, _G[self:IsHarmful() and "UnitDebuff" or "UnitBuff"](unit or "target", name))

		if duration ~= nil or expiration ~= nil or caster ~= nil then
			break
		end
	end

	return duration, expiration, caster
end

function Spell:InRange(unit)
	return IsSpellInRange(self.name, unit or "target")
end

function Spell:Equals(spell)
	return self.id == spell.id
end

function Spell:Link(ID)
	return GetSpellLink(ID or self.id)
end

function Spell:GetName(ID)
	return (GetSpellInfo(ID))
end

local SpellDefault = {
	id = -1,
	name = nil,
	rank = 0,
	icon = nil,
	cost = 0,
	funnel = false,
	power = nil,
	castTime = 0,
	range = {
		min = 0,
		max = 0
	},
	ID					= Spell.ID,
	Set 				= Spell.Set,
	IsReady				= Spell.IsReady,
	IsInstant			= Spell.IsInstant,
	CastTime			= Spell.CastTime,
	GetCooldown			= Spell.GetCooldown,
	IsHarmful			= Spell.IsHarmful,
	IsHelpful			= Spell.IsHelpful,
	IsMisc				= Spell.IsMisc,
	Type 				= Spell.Type,
	EffectIsInstant 	= Spell.EffectIsInstant,
	IsDOT				= Spell.IsDOT,
	IsHOT				= Spell.IsHOT,
	HasMultipleEffects 	= Spell.HasMultipleEffects,
	Effects				= Spell.Effects,
	AffectingUnit 		= Spell.AffectingUnit,
	TimeOnUnit			= Spell.TimeOnUnit,
	InRange				= Spell.InRange,
	Equals				= Spell.Equals,
	Link				= Spell.Link,
	GetName				= Spell.GetName

}

local spellName = function(spell)
	return spell.name
end

function Spell:New(ID, effect)
	local spell = {}
	setmetatable(spell, {__index = SpellDefault, __tostring = spellName, __eq = self.Equals})

	if ID then
		spell:Set(ID, effect)
	end

	return spell
end

MPXWOWKit_Spell = Spell -- Global Registration