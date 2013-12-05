local playerTargetingThreat = DOTMonitor.inspector.playerTargetingLivingEnemy();

local EffectMonitor = {}; -- EffectMonitor Class




-- ================================================================
-- Class Methods' logic
-- ================================================================

--	BaseStyle(shown)	-> void
--		< bol: shown	- true to enable updating, false otherwise
--		> obj 			- returns {maxAlpha, iconWidth, iconHeight}
function EffectMonitor:BaseStyle(shown)
	return {alpha = (shown and self.settings.maxAlpha) or 0, width = self.settings.iconWidth, height = self.settings.iconHeight};
end

--	Enable(on) 		-> void
--		< bol: on	- true to enable updating, false otherwise
function EffectMonitor:Enable(on)
	self:SetScript("OnUpdate", on and self.Update or nil);
end

--	ShowCondition() -> bol
--		> int: int 	- true if the target meets condition, false otherwise
function EffectMonitor:ShowCondition()
	return self:Effect() and self.settings.showCondition(self:Effect());
end




-- ================================================================
-- Updater logic
-- ================================================================

--	ElapsedTime(elapsed) 	-> int
--		< int: elapsed 	- time elapsed since the last update to total
--		> int 			- total time including the new elapsed time
function EffectMonitor:ElapsedTime(elapsed)
	-- Since self.status.totalElapsed is initialized to 0, no need to check
	return elapsed and (self.status.totalElapsed = self.status.totalElapsed+elapsed)
					or  self.status.totalElapsed;
return

--	NeedsUpdate(elapsed) 	-> bol
--		< int: elapsed 	- time elapsed since the last update to total
--		> bol			- true if time elapsed is greater than interval
function EffectMonitor:NeedsUpdate(elapsed)
	return (self:ElapsedTime(elapsed) >= self.settings.updateInterval);
end

--	Update(elapsed) 	-> void
--		< int: elapsed 	- time elapsed since the last update to total
function EffectMonitor:Update(elapsed)
	local readyForUpdate = (self:NeedsUpdate(elapsed) and self:ShowCondition()) or false;
	local style = readyForUpdate and self:EffectMagnitude() or self:BaseStyle(false);
	self:SetAlpha(style.alpha);
	self:SetWidth(style.width);
	self:SetHeight(style.height);
end




-- ================================================================
-- Effect Scanner logic
-- ================================================================

--	Effect(effect) 		-> str
-- 		< obj | str: 	- either an obj containing a set of effects or a string denoting the effect name
--		> str			- the effect name (localized)
function EffectMonitor:Effect(effect)
	return (type(effect) == "object") and effect[1] or effect;
end


--[[
function EffectMonitor:Effect(...)
	if ... then
		self.effect = (select(1,...)) or false;
	end
	return self.effect;
end
--]]

--	EffectScanner() 	-> void
--		> obj			- returns duration, expiration, caster source
function EffectMonitor:EffectScanner()
	return self.settings.effectScanner(self:Effect(), self.settings.target);
end

--	EffectMagnitude() 	-> void
--		> obj			- returns a style {alpha, width, height}
function EffectMonitor:EffectMagnitude()
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


--[[
	Requires:
		(BOOL) 			settings.showCondition()	// React to EffectMagnitude otherwise set to 1
		(int,int,str) 	settings.effectScanner()	// Get effect info (duration, expiration, caster)
		int: settings.updateInterval
		str: settings.target
		int: settings.maxAlpha
		int: settings.iconWidth
		int: settings.iconHeight

--]]

-- New(frameID, settings)	-> Obj:EffectMonitor
--		< str: frameID		- Denotes the frame ID
--		< arr: settings		- Denotes the settings for the effect monitor object
--			- int: updateInterval	- the time interval for max elapsed time before next cycle
--			- str: target			- the target, player or target
--			- int: maxAlpha			- the maximum alpha (opacity)
--			- int: iconWidth		- icon width
-- 			- int: iconHeight		- icon height
--			- fun: showCondition(effect)			-> bol
--			- fun: effectScanner(effect, target) 	-> arr
--				< str: effect	- the effect name, id (localized)
--				< str: target	- the target (player or target)
--				> arr			- returns {duration, expiration, caster source}
function EffectMonitor:New(frameID, settings)
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

	newMonitor.status = {
		totalElapsed = 0
	};

	newMonitor.settings = settings;
	return newMonitor;
end