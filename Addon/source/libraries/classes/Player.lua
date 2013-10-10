local DOTMonitor = getglobal("DOTMonitor") or {}
if not DOTMonitor.library then DOTMonitor.library = {} end

-- @ Player Methods Implementation
-- ================================================================================
local Player = {}; DOTMonitor.library.Player = Player;

Player.Synchronize = function(self)
	self.info = DOTMonitor.inspector.getPlayerInfo()
	
	if not self.info.spec then 
		DOTMonitor.logMessage("Player wasn't initialized!")
		return nil;
	end-- Player can't be tracked -> Don't Initialize
	
	local allDebuffs = DOTMonitor.utility.getAbilitiesForPlayer("debuffs", self)
	self.spec = {debuff = DOTMonitor.inspector.getPossibleAbilities(allDebuffs)}
	
	self:ShowMonitoringInfo()
	if self:Ready() and self.delegate then self.delegate:SynchronizeWithPlayer(self) end
end

Player.Delegate = function(self, ...)
	if ... then
		self.delegate = (select(1,...))
	else
		return self.delegate
	end
end

Player.Ready = function(self)
	--DOTMonitor.logMessage("spec name: "..self.info.spec.name)
	--DOTMonitor.logMessage("spec is "..(self.spec and "ready" or "empty").." size: "..#self.spec)
	return self.info.spec.name and self.spec and true or false
end
--aPlayer:GetAbilities("debuff")
Player.GetAbilities = function(self, abilityType)
	return self.spec[abilityType]
end

Player.GetAbility = function(self, abilityType, position)
	local playerAbilities = self:GetAbilities(abilityType) 
	return playerAbilities.spell[position], playerAbilities.effect[position]
end

Player.ShowMonitoringInfo = function(self)
	DOTMonitor.printMessage(("adjusted for "..self.info.spec.name.." "..self.info.class), "info")
	for abilityTypePos, anAbilityType in ipairs(self.spec) do
		DOTMonitor.printMessage((anAbilityType:gsub("^%l", string.upper)).." types being monitored:")
		for aPos, aSpell in ipairs(anAbilityType) do
			DOTMonitor.printMessage(("monitoring "..anAbility), "info")
		end
	end
end

Player.New = function(self)
	return { -- Player Instance
		info = {
			class			= nil,
			spec			= nil,
			level 			= nil,
			healthMax 		= nil
		},
		spec = {
			debuff = nil
		},
		delegate = nil,
		
		-- Methods
		Synchronize 		= self.Synchronize,
		Delegate			= self.Delegate,
		Ready				= self.Ready,
		GetAbilities		= self.GetAbilities,
		GetAbility			= self.GetAbility,
		ShowMonitoringInfo	= self.ShowMonitoringInfo
	}
end