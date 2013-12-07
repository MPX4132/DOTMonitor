local DOTMonitor = getglobal("DOTMonitor") or {}
if not DOTMonitor.library then DOTMonitor.library = {} end

-- @ Player Methods Implementation
-- ================================================================================
local Player = {}; DOTMonitor.library.Player = Player;

-- 	Spec()		-> tbl | bol
--		> bol	- Returns the spec, otherwise false if no spec found
function Player:Spec()
	return (type(self.info.spec) == "table") and self.info.spec or false;
end

--	Ready()		-> bol
--		> bol	- Returns if there exists a spec, otherwise false
function Player:Ready()
	return type(self:Spec()) ~= "undefined";
end

--	Delegate(...)		-> tbl | bol
--		< table			- Denotes a delegate object
--		> tbl | bol - Returns delegate if available, otherwise false
function Player:Delegate(...)
	self.delegate = (type(...) == "undefined") and self.delegate or (select(1, ...));
	return self.delegate or false;
end

--	NofityDelegate()	-> void
function Player:NotifyDelegate()
	if self:Ready() and self:Delegate() then
		self.delegate:PlayerDidSynchronize(self);
	end
end

--	GetAbilities(aType)	-> tbl
--		> tbl			- Returns a table containing abilities of certain type
function Player:GetAbilities(aType)
	return self.ability[aType];
end

--	GetAbility(aType, abilityPosition) 	-> str, str
--		> str, str						- str_1 is the spell name, str_2 is the effect
function Player:GetAbility(aType, abilityPosition)
	local ability = self:GetAbilities(aType)[abilityPosition];
	return ability.spell, ability.effect;
end

--	ShowInformation()	-> void
function Player:ShowInformation()
	for aType, abilities in pairs(self.ability) do
		DOTMonitor.printMessage(aType.." abilities:")
		for aPos, anAbility in pairs(abilities) do
			DOTMonitor.printMessage("\["..aPos.."> "..anAbility.spell, "info");
		end
	end
end

--	IsFighting(...)		-> bol
--		> bol			- Denotes if the player is fighting or not
function Player:IsFighting(...)
	local fighting = (type(...) ~= "undefined") and select(1,...) or self.status.inFight;
	return (self.status.inFight = fighting);
end

--	Synchronize() 		-> void
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
		Spec 			= self.Spec,
		Ready			= self.Ready,
		Delegate		= self.Delegate,
		NotifyDelegate 	= self.NotifyDelegate,
		GetAbilities 	= self.GetAbilities,
		GetAbility		= self.GetAbility,
		ShowInformation = self.ShowInformation,
		IsFighting		= self.IsFighting,
		Synchronize		= self.Synchronize
	}
	newPlayer.status 	= {}	-- to keep player's stats
	newPlayer.ability 	= {}	-- to keep player's spells

	return newPlayer
end
