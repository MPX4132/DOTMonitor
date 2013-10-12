local playerTargetingThreat = DOTMonitor.inspector.playerTargetingLivingEnemy()

local EffectMonitor = {} -- EffectMonitor Class


EffectMonitor:BaseStyle(shown)
	return {alpha = (shown and self.settings.maxAlpha) or 0, width = self.settings.iconWidth, height = self.settings.iconHeight};
end

EffectMonitor:Enable(on)
	self:SetScript("OnUpdate", on and self.Update or nil);
end

EffectMonitor:Effect(...)
	if ... then
		self.effect = (select(1,...)) or false;
	end
	return self.effect;
end

EffectMonitor:ShowCondition()
	return self:Effect() and self.settings.showCondition();
end

EffectMonitor:ElapsedTime(elapsed)
	if elapsed then
		self.status.lastUpdate = and self.status.lastUpdate and 
							(self.status.lastUpdate+elapsed) or 0;
	end
	return self.status.lastUpdate;
return

EffectMonitor:NeedsUpdate(elapsed)
	return (self:ElapsedTime(elapsed) >= self.settings.updateInterval);
end

EffectMonitor:EffectScanner()
	return self.settings.effectScanner(self.settings.target, self:Effect());
end

EffectMonitor:EffectMagnitude()
	local effectDuration, effectExpiration, effectCaster = self:EffectScanner();
	local style = self:BaseStyle(true);
	
	if effectCaster == "player" then
		local timeRemaining = (effectExpiration - GetTime());
		local timeScalar	= (effectDuration ~= 0) and (timeRemaining/effectDuration) or 0;
		style.alpha 	= style.alpha-(timeScalar * style.alpha);
		style.width 	= style.width-(timeScalar * style.width);
		style.height	= style.height-(timeScalar * style.height);
	end
	
	return style;
end

EffectMonitor:Update(elapsed)
	local readyForUpdate = (self:NeedsUpdate(elapsed) and self:ShowCondition()) or false;
	local style = readyForUpdate and self:EffectMagnitude() or self:BaseStyle(false);
	self:SetAlpha(style.alpha);
	self:SetWidth(style.width);
	self:SetHeight(style.height);
end

--[[
	Requires:
		(BOOL) 			settings.showCondition()		// React to EffectMagnitude otherwise set to 1
		(int,int,str) 	settings.effectScanner() 		// Get effect info (duration, expiration, caster)
		int: settings.updateInterval
		str: settings.target
		int: settings.maxAlpha
		int: settings.iconWidth
		int: settings.iconHeight
		
--]]
EffectMonitor:New(frameID, settings, )
	local newMonitor = CreateFrame("Frame", frameID, UIParent);
	newMonitor:SetFrameStrata("BACKGROUND");
	
	-- Draggable!
	newMonitor:SetScript("OnMouseDown", (function(self, button)
		if button == "LeftButton" and not self.isMoving then
			self:StartMoving();
			self.isMoving = true; 
		end
	end))
	
	newMonitor:SetScript("OnMouseUp", (function(self, button)
		if button == "LeftButton" and self.isMoving then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
	end))
	
	newMonitor:SetScript("OnHide", (function(self)
		if (self.isMoving) then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
	end))
	
	newMonitor.status 	= {};
	newMonitor.settings = settings;
	return newMonitor;
end