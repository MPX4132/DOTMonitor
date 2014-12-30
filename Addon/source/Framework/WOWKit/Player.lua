-- =======================================================================================
-- Player V0.1
-- Simple player abstraction for WOW
-- =======================================================================================

--local Table 	= _G["MPXFoundation_Table"]
local TableSet 	= _G["MPXFoundation_TableSet"]
local SpellBook	= _G["MPXWOWKit_SpellBook"]
local Spell		= _G["MPXWOWKit_Spell"]

local Player = {} -- Local Namespace

function Player:IsPlayer()
	return UnitIsPlayer(self.subject)
end

function Player:Level()
	return UnitLevel(self.subject)
end

function Player:Class()
	return self.class
end

function Player:RealClass()
	return self.realClass
end

function Player:SupportsSpec()
	return self:Level() >= 10
end

function Player:HasSpec() -- Supports subject "player" only
	return self:SupportsSpec() and GetSpecialization() or false
end

function Player:SpecID()
	if not self:HasSpec() then return false end
	return GetSpecializationInfo(GetSpecialization())
end

function Player:Spec()
	if not self:HasSpec() then return false end
	return (select(2, self:SpecID())) or "NO_SPEC"
end

function Player:Form()
	return GetShapeshiftFormID() or 0
end

function Player:UpdateDebuffs()
	local pastDebuffs 	= self.debuff or TableSet:New()		-- To detect changes

	local classDebuffs 	= _G["DOTMonitor_Debuffs"] and _G["DOTMonitor_Debuffs"][self:RealClass()] or {}
	local specDebuffs	= TableSet:New(classDebuffs[self:HasSpec() and self:SpecID() or "NO_SPEC"])

	self.debuff = TableSet:New() -- Clear it
	for i, aDebuff in ipairs(specDebuffs) do
		aDebuff:Update()
		if aDebuff:IsAvailable(self) then
			self.debuff:AddObject(aDebuff)
		end
	end

	return pastDebuffs ~= self.debuff	-- True if there was a change
end

function Player:GetDebuff(index)
	return index and self.debuff[index] or self.debuff
end

function Player:GetHeals()
	return {} -- Not yet supported
end

function Player:GetInfo()
	return self:IsPlayer(), self:Level(), self:Class(), self:Spec();
end

function Player:Health()
	return UnitHealth(self.subject) / UnitHealthMax(self.subject);
end

function Player:InCombat()
	return UnitAffectingCombat(self.subject);
end

function Player:Power()
	return UnitPower(self.subject) / UnitPowerMax(self.subject);
end

function Player:Status()
	return self:InCombat(), self:Health(), self:Power();
end

function Player:Subject(unit)
	self.subject = (type(unit) == "string") and unit or self.subject;
	return self.subject;
end

function Player:Sync()
	return self, self:UpdateDebuffs()
end

local PlayerDefault = {
	subject = "player",
	debuff = nil,
	heals = {},
	IsPlayer 		= Player.IsPlayer,
	Level			= Player.Level,
	Class			= Player.Class,
	RealClass		= Player.RealClass,
	SupportsSpec	= Player.SupportsSpec,
	HasSpec			= Player.HasSpec,
	SpecID			= Player.SpecID,
	Spec			= Player.Spec,
	Form			= Player.Form,
	UpdateDebuffs 	= Player.UpdateDebuffs,
	GetDebuff		= Player.GetDebuff,
	GetHeals		= Player.GetHeals,
	GetInfo			= Player.GetInfo,
	Health			= Player.Health,
	InCombat		= Player.InCombat,
	Power			= Player.Power,
	Status			= Player.Status,
	Subject			= Player.Subject,
	Sync			= Player.Sync,
}

local playerAbout = function(player)
	local playerSpec = player:Spec()
	return playerSpec and string.format("%s %s", playerSpec, player:Class()) or player:Class()
end

function Player:New(unit)
	local player = {}
	setmetatable(player, {__index = PlayerDefault, __tostring = playerAbout})

	player.subject 	= unit
	player.class, player.realClass = UnitClassBase(player.subject)
	player.class = player.class:gsub("^%l", string.upper) -- Doesn't change
	--player.spellbook = SpellBook:New(player)

	return player:Sync()
end

MPXWOWKit_Player = Player -- Global Registration