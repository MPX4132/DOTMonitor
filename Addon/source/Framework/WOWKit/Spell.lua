-- =======================================================================================
-- Spell V0.2
-- Simple spell abstraction for WOW
-- =======================================================================================

local TableSet = _G["MPXFoundation_TableSet"]

local Spell = {} -- Local Namespace

function Spell:ID()
	return self.id
end

function Spell:Set(ID, effect)
	self:SetDynamicTexture(ID)
	ID = self:HasDynamicTexture() and ID or ID[1]

	if type(ID) == "string" then
		local link = self:Link(ID)
		ID = link and link:match("spell:(%d+)") or false
		if not ID then return end
	end

	self.id 	= ID
	self.effect = effect or ID

	self:Update()
end

function Spell:Update()
	self.name, self.rank, newTexture, self.cost, self.funnel,
	self.power, self.castTime, self.range.min, self.range.max = GetSpellInfo(self:ID())

	self.icon = (self:HasDynamicTexture() and newTexture) or self.icon or newTexture
end


function Spell:SetDynamicTexture(isDynamic)
	if type(isDynamic) == "boolean" then
		self.dynamicTexture = isDynamic
	else
	 	self.dynamicTexture = type(isDynamic) ~= "table"
	end
end

function Spell:HasDynamicTexture()
	return self.dynamicTexture or false
end

function Spell:HasRequiredForm()
	if not self.requiredForm and
		return true -- Assume it's supported
	end

	self.requiredForm:Contains(GetShapeshiftFormID() or 0)
end

function Spell:IsAvailable()
	-- IsSpellKnown is notorious for giving out false info
	-- return self.name ~= nil and IsSpellKnown(self.id)

	-- Using hack to see if anything's returned from spell info
	return GetSpellInfo(self.name) ~= nil and self:HasRequiredForm() -- Check for a name & stance
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
	return self:IsDOT()
end

function Spell:IsHelpful()
	--return IsHelpfulSpell(self.name) and true or false
	return self:IsHOT()
end

function Spell:IsMisc()
	return not self:IsHarmful() and not self:IsHelpful()
end

function Spell:Type(aType)
	return self.effectType
end

-- WARNING BELOW
function Spell:EffectIsInstant()
	return false -- TO DO
end

function Spell:IsDOT()
	return self.effectType == "DOT"
end

function Spell:IsHOT()
	return self.effectType == "HOT"
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
	Update				= Spell.Update,
	SetDynamicTexture 	= Spell.SetDynamicTexture,
	HasDynamicTexture	= Spell.HasDynamicTexture,
	HasRequiredForm		= Spell.HasRequiredForm,
	IsAvailable			= Spell.IsAvailable,
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

function Spell:New(ID, effect, effectType, requiredForm)
	local spell = {}
	setmetatable(spell, {__index = SpellDefault, __tostring = spellName, __eq = self.Equals})

	if ID then
		spell:Set(ID, effect)
	end

	spell.effectType 	= effectType or "GENERIC"
	spell.requiredForm 	= requiredForm and TableSet:New(requiredForm)

	return spell
end

MPXWOWKit_Spell = Spell -- Global Registration