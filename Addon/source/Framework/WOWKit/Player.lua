--
-- Player V0.1
-- Simple player abstraction for WOW
--

local Table = _G["MPXFoundation_Table"]
local Spell	= _G["MPXWOWKit_Spell"]

local Player = {} -- Local Namespace

function Player:IsPlayer()
	return UnitIsPlayer(self.subject)
end

function Player:Level()
	return UnitLevel(self.subject)
end

function Player:Class()
	return self.class;
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
	return (select(2, GetSpecializationInfo(GetSpecialization())))
end

function Player:UpdateDebuffs()
	local allDebuffs 	= _G["DOTMonitor_Debuffs_"..GetLocale()] or _G["DOTMonitor_Debuffs_enUS"]

	local specDebuffs 	= self:HasSpec() and Table:New(allDebuffs[self:Class():gsub(" ", "_")][self:Spec():gsub(" ", "_")]) or Table:New({})
	local debuffSpell	= specDebuffs:Keys()
	local debuffEffect	= specDebuffs:Values(debuffSpell)

	self.debuff = {} -- Clear it
	for i = 0, specDebuffs:Count() do
		local spell = Spell:New(debuffSpell[i], debuffEffect[i])
		if spell:IsReady() then
			table.insert(self.debuff, spell)
		end
	end
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
	-- Load Debuffs
	self:UpdateDebuffs()
	return self
end

local PlayerDefault = {
	subject = "player",
	debuff = nil,
	heals = {},
	IsPlayer 		= Player.IsPlayer,
	Level			= Player.Level,
	Class			= Player.Class,
	SupportsSpec	= Player.SupportsSpec,
	HasSpec			= Player.HasSpec,
	SpecID			= Player.SpecID,
	Spec			= Player.Spec,
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
	return string.format("%s %s", player:Spec(), player:Class())
end

function Player:New(unit)
	local player = {}
	setmetatable(player, {__index = PlayerDefault, __tostring = playerAbout})

	player.subject 	= unit
	player.class 	= UnitClass(player.subject):gsub("^%l", string.upper) -- Doesn't change

	return player:Sync()
end

MPXWOWKit_Player = Player -- Global Registration