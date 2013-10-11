DOTMonitor = {debugMode = true} -- Main Addon

DOTMonitor.scanner = {
	debuffMonitor = (function(self, elapsed)
		self.lastUpdate = self.lastUpdate and (self.lastUpdate + elapsed) or 0
		if self.lastUpdate >= 0.1 then
			if not DOTMonitor.inspector.playerTargetingLivingEnemy() then
				self:SetAlpha(0) 
				return false
			end
	
			local duration, expiration, caster = DOTMonitor.inspector.checkUnitForDebuff("target",self.effect)
	
			local spellIconSize = self.settings.iconSize
			local spellMaxAlpha = self.settings.maxAlpha
	
			if caster == "player" then
				local timeRemaining = (expiration - GetTime())
				local timeFraction 	= (duration ~= 0) and (timeRemaining / duration) or 0

				self:SetHeight(spellIconSize - (timeFraction * spellIconSize))
				self:SetWidth(spellIconSize - (timeFraction * spellIconSize))
				self:SetAlpha(spellMaxAlpha	- (timeFraction * spellMaxAlpha))
			else
				self:SetHeight(spellIconSize)
				self:SetWidth(spellIconSize)
				self:SetAlpha(spellMaxAlpha)
			end
	
			self.lastUpdate = 0
		end
	end)
}