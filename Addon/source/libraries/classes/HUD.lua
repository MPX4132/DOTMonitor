local DOTMonitor = getglobal("DOTMonitor") or {}
if not DOTMonitor.library then DOTMonitor.library = {} end

-- @ HUD Methods Implementation
-- ================================================================================
local HUD ={}; DOTMonitor.library.HUD = HUD;

HUD.SetPreferences = function(self, ...)
	self.settings = (select(1, ...)) or {
		iconSize 	=   44,
		yOffset 	= -126,
		maxAlpha	=  .60
	}
end

HUD.SetIconBackground = function(self, iconIndex, spellName)
	local iconTexturePath = DOTMonitor.utility.getAbilityTexture(spellName)
	local anIcon = self.icon[iconIndex]
	
	if not anIcon.texture then
		anIcon.texture = anIcon:CreateTexture(nil, "BACKGROUND")
	end
	anIcon.texture:SetTexture(iconTexturePath)
	anIcon.texture:SetAllPoints(anIcon)
end

HUD.GetFormalIconPosition = function(self, iconIndex)
	local iconSize 		= self.settings.iconSize
	local iconQuantity	= #self:GetIconsEnabled() -- Here's the catch!
	-- Note the + () is due to adjusted to icon center point
	local derivedOrigin = -((iconQuantity * iconSize)/2) + iconSize 
	local iconOffset 	= (iconSize * (iconIndex-1))
	return {x = (derivedOrigin + iconOffset), y = (self.settings.yOffset)}
end

HUD.SetIconPosition = function(self, iconIndex, position)
	local pos = position or self:GetFormalIconPosition(iconIndex)
	self.icon[iconIndex]:SetPoint("CENTER", UIParent, "CENTER", pos.x, pos.y)
end

HUD.FormalPosition = function(self)
	for aPosition, anIcon in ipairs(self.icon) do
		self:SetIconPosition(aPosition, nil)
	end
end

HUD.SetIconAlpha = function(self, iconIndex, ...)
	local alpha = (select(1,...)) or self.settings.maxAlpha
	self.icon[iconIndex]:SetAlpha(alpha)
end

HUD.SetIconDimensions = function(self, iconIndex, width, ...)
	local w = width
	local h = ((select(1,...)) and (select(1,...))) or w
	self.icon[iconIndex]:SetWidth(w)
	self.icon[iconIndex]:SetHeight(h)
end

HUD.IconEffect = function(self, iconIndex, ...)
	if ... then
		self.icon[iconIndex].effect = (select(1,...))
	end
	return self.icon[iconIndex].effect
end

HUD.IconMonitoring = function(self, iconIndex, anEffect)
	self:IconEffect(iconIndex, anEffect or nil)
	self.icon[iconIndex]:SetScript("OnUpdate", (anEffect and DOTMonitor.scanner.debuffMonitor) or nil)
end

HUD.GetIconsEnabled = function(self)
	local active = {}
	for aPos, anIcon in ipairs(self.icon) do
		if anIcon.effect then
			table.insert(active, anIcon)
		end
	end
	return active
end

-- HUD Setting
HUD.Monitoring = function(self, enabled)
	DOTMonitor.logMessage("HUD Monitoring "..(enabled and "on" or "OFF"))
	for aPos, anIcon in ipairs(self:GetIconsEnabled()) do
		anIcon:SetScript("OnUpdate", enabled and DOTMonitor.scanner.debuffMonitor or nil)
	end
end

-- HUD Setting
HUD.SetVisible = function(self, ...)
	local alpha = type((select(1,...))) == "number" and math.abs((select(1,...))) or 0
	for aPos, anIcon in ipairs(self:GetIconsEnabled()) do
		anIcon:SetAlpha(alpha)
	end
	DOTMonitor.logMessage("HUD "..(alpha and "visible" or "INVISIBLE"))
end

-- HUD Setting
HUD.SetEnabled = function(self, enabled)
	DOTMonitor.logMessage((enabled and "Enabling" or "DISABLING").." HUD")

	for aPos, anIcon in ipairs(self:GetIconsEnabled()) do
		local spellName = DOTMonitor.utility.getSpellName(anIcon.effect)
		DOTMonitor.logMessage("ICON \["..aPos.."\] "..spellName.." "..(enabled and "ENABLED" or "DISABLED!!!"))
		if enabled
		then anIcon:Show()
		else anIcon:Hide()
		end
	end
end

HUD.NewFrame = function(self, frameGlobalID, frameLayer)
	local aFrame = CreateFrame("Frame", frameGlobalID, UIParent)
	aFrame:SetFrameStrata(frameLayer)
	--aFrame.owner 	= self
	
	-- Register Frames For MOVEMENT! (HAPPY NOW, PEOPLE?!)
	aFrame:SetScript("OnMouseDown", (function(self, button)
		if button == "LeftButton" and not self.isMoving then
			self:StartMoving();
			self.isMoving = true;
		end
	end))
	
	aFrame:SetScript("OnMouseUp", (function(self, button)
		if button == "LeftButton" and self.isMoving then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
	end))
	
	aFrame:SetScript("OnHide", (function(self)
		if (self.isMoving) then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
	end))
	
	return aFrame
end

HUD.NewIcon = function(self, position, spell, effect)
	local iconIndex = (#self.icon + 1)
	local iconSize	= self.settings.iconSize
	
	if self.icon[iconIndex] then
		DOTMonitor.printMessage("ERROR: OVERWRITING FRAME!", "alert")
		return false
	end
	
	self.icon[iconIndex] = self:NewFrame(("DOTM_HUD_ICON_"..iconIndex), "BACKGROUND")
	
	self.icon[iconIndex].settings = {
		iconSize = self.settings.iconSize,
		maxAlpha = self.settings.maxAlpha
	}
	
	self:SetIconDimensions(iconIndex, iconSize)
	self:SetIconBackground(iconIndex, texture)
	self:SetIconPosition(iconIndex, position)
	self:SetIconAlpha(iconIndex)
	self:IconMonitoring(iconIndex, effect)
end

-- HUD Setting
HUD.Unlock = function(self, movable)
	DOTMonitor.logMessage("Hud now "..(movable and "Unlocking" or "Locking").."==============")
	
	self:Monitoring(not movable)
	DOTMonitor.logMessage("Monitoring set to "..(movable and "Off" or "ON"))
	
	self:SetEnabled(movable)
	DOTMonitor.logMessage("HUD now "..(movable and "Enabled" or "Disabled"))
	
	self:SetVisible(movable and 1 or 0)
	DOTMonitor.logMessage("HUD Alpha("..(movable and 1 or 0)..")")
	
	for aPos, aFrame in ipairs(self:GetIconsEnabled()) do
		aFrame:SetMovable(movable)
		aFrame:EnableMouse(movable)
	end
	DOTMonitor.logMessage("=============================")
end

-- HUD Setting
HUD.SynchronizeWithPlayer = function(self, aPlayer)
	self:AdjustIconsToPlayer(aPlayer)
end

-- HUD Setting
HUD.AdjustIconsToPlayer = function(self, aPlayer)
	if not aPlayer:Ready() then
		DOTMonitor.logMessage("Player hasn't been initialized!")
		return false
	end
	DOTMonitor.logMessage("Adjusting Icons!")
	
	local availableSlots, requiredSlots = #self.icon, #(aPlayer:GetAbilities("debuff")).spell
	
	if availableSlots < requiredSlots then -- Create frames if needed
		local zeroPoint = {x=0,y=0}
		for aPos=1, (requiredSlots-availableSlots) do
			self:NewIcon(zeroPoint, "\[N/A\]", "\[N/A\]")
		end
	end
	
	for aPos = 1, #self.icon do
		if aPos <= requiredSlots then
			local spell, effect = aPlayer:GetAbility("debuff", aPos)
			self:SetIconBackground(aPos, spell)
			self:IconMonitoring(aPos, effect)
		else
			self:SetIconAlpha(aPos, 0)
			self:IconMonitoring(aPos, nil)
		end
	end
end

HUD.New = function(self, preferences)
	local newHUD = {
		icon 		= {},
		settings	= {},
		
		-- Methods
		SetPreferences 			= self.SetPreferences,
		GetIconsEnabled 		= self.GetIconsEnabled,
		SetIconBackground		= self.SetIconBackground,
		GetFormalIconPosition 	= self.GetFormalIconPosition,
		SetIconPosition			= self.SetIconPosition,
		FormalPosition 			= self.FormalPosition,
		SetIconAlpha 			= self.SetIconAlpha,
		SetIconDimensions 		= self.SetIconDimensions,
		IconEffect				= self.IconEffect,
		IconMonitoring 			= self.IconMonitoring,
		SetVisible				= self.SetVisible,
		Monitoring				= self.Monitoring,
		SetEnabled				= self.SetEnabled,
		NewFrame				= self.NewFrame,
		NewIcon					= self.NewIcon,
		Unlock					= self.Unlock,
		SynchronizeWithPlayer 	= self.SynchronizeWithPlayer,
		AdjustIconsToPlayer 	= self.AdjustIconsToPlayer
	}
	
	
	newHUD:SetPreferences(preferences)
	return newHUD
end