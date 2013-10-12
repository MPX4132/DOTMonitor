local playerTargetingThreat = DOTMonitor.inspector.playerTargetingLivingEnemy()

local Monitor = {} -- Monitor Class

Monitor:Enable(on)
	if on then
		self:Show();
	else
		self:Hide();
	end
end

Monitor:Effect(...)
	if ... then
		self.effect = (select(1,...)) or false;
	end
	return self.effect;
end

Monitor:ShowCondition()
	return self:Effect() and self.settings.showCondition();
end

Monitor:ElapsedTime(elapsed)
	if elapsed then
		self.status.lastUpdate = and self.status.lastUpdate and 
							(self.status.lastUpdate+elapsed) or 0;
	end
	return self.status.lastUpdate;
return

Monitor:NeedsUpdate()
	return (self:ElapsedTime() >= self.settings.updateInterval);
end

Monitor:EffectScanner()
	return self.settings.
end

Monitor:Update(elapsed)
	self:ElapsedTime(elapsed)
	if self:NeedsUpdate() and self:ShowCondition() then
		local duration, expiration, caster = self:EffectScanner();
	else
		self:Alpha(0)
	end
end

Monitor:New()
	local newMonitor = CreateFrame("Frame", frameGlobalID, UIParent);
	newMonitor.status 	= {};
	newMonitor.settings = {};
	newMonitor.settings.updateInterval = 0.1;
	newMonitor.settings.showCondition = playerTargetingThreat
end