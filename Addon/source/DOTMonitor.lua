DOTMonitor = {debugMode = false} -- Main Addon

local iconIntensity = function(magnitude)
	BorderTheme = {"Interface\\AddOns\\DOTMonitor\\graphics\\icon_border_white", "Interface\\AddOns\\DOTMonitor\\graphics\\icon_border_effect_over"}
	return BorderTheme[((magnitude >= 0.95 and 2) or 1)]
end

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
				local sizeMagnitude = spellIconSize 	- (timeFraction * spellIconSize)
				local alphaMagnitude = spellMaxAlpha 	- (timeFraction * spellMaxAlpha)
				
				self:SetHeight(sizeMagnitude)
				self:SetWidth(sizeMagnitude)
				self:SetAlpha(alphaMagnitude)
				
				
				
				self.border:SetTexture(iconIntensity(alphaMagnitude))
			else
				self:SetHeight(spellIconSize)
				self:SetWidth(spellIconSize)
				self:SetAlpha(spellMaxAlpha)
			end
	
			self.lastUpdate = 0
		end
	end)
}