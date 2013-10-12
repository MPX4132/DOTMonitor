local DOTMonitor = getglobal("DOTMonitor") or {}
if not DOTMonitor.library then DOTMonitor.library = {} end

-- @ Player Methods Implementation
-- ================================================================================
local Player = {}

function Player:Spec()
	return (type(self.info.spec) == "table") or nil;
end

function Player:Ready()
	return self:Spec();
end

function Player:Delegate(...)
	if ... then
		self.delegate = (select(1, ...));
	end
	return self.delegate or false;
end

function Player:NotifyDelegate()
	if self:Ready() and self:Delegate() then
		self.delegate:PlayerDidSynchronize(self);
	end
end

function Player:GetAbilities(aType)
	return self.ability[aType];
end

function Player:GetAbility(aType, abilityPosition)
	local ability = self:GetAbilities(aType)[abilityPosition];
	return ability.spell, ability.effect;
end

function Player:ShowInformation()
	for aType, abilities in pairs(self.ability) do
		DOTMonitor.printMessage(aType.." abilities:")
		for aPos, anAbility in pairs(abilities) do
			DOTMonitor.printMessage("\["..aPos.."> "..anAbility.spell, "info");
		end
	end
end

function Player:IsFighting(...)
	if ... then
		self.status.inFight = (select(1,...)) and true or false;
	end
	return self.status.inFight;
end

function Player:Synchronize()
	self.info = DOTMonitor.inspector.getPlayerInfo();
	
	if not self:Spec() then
		DOTMonitor.logMessage("Player missing specialization.");
		return nil;
	end
	
	self.ability.debuff = DOTMonitor.utility.getAbilitiesForPlayer("debuffs", self);
	self:NotifyDelegate();
end

function Player:New()
	local newPlayer = {delegate = nil}
	newPlayer.info = { 		-- to keep player's info
		class 		= nil,
		level 		= nil,
		maxHealth	= nil,
		spec		= nil,
		
		-- Saving Methods for instances
		Spec 		= self.Spec,
		Ready		= self.Ready,
		Delegate	= self.Delegate,
		NotifyDelegate = self.NotifyDelegate,
		GetAbilities = self.GetAbilities,
		GetAbility	= self.GetAbility,
		ShowInformation = self.ShowInformation,
		IsFighting	= self.IsFighting,
		Synchronize	= self.Synchronize
	}
	newPlayer.status 	= {}	-- to keep player's stats
	newPlayer.ability 	= {}	-- to keep player's spells
	
	return newPlayer
end
