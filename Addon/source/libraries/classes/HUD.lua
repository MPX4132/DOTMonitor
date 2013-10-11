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
	local derivedOrigin = -((iconQuantity * iconSize)/2) + (iconSize/2) 
	local iconOffset 	= (iconSize * (iconIndex-1))
	return {x = (derivedOrigin + iconOffset), y = (self.settings.yOffset)}
end

HUD.SetIconPosition = function(self, iconIndex, position)
	local pos = position or self:GetFormalIconPosition(iconIndex)
	self.icon[iconIndex]:SetPoint("CENTER", UIParent, "CENTER", pos.x, pos.y)
end

HUD.FormalPosition = function(self)
	for aPosition, anIcon in ipairs(self.icon) do
		if not anIcon:IsUserPlaced() then
			self:SetIconPosition(aPosition, nil)
		else
			DOTMonitor.logMessage("Frame "..aPosition.." set to USER VALUE!")
		end
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

HUD.Permuting = function(self, ...)
	if (... ~= nil) then
		self.status.modding = (select(1,...))
		DOTMonitor.logMessage("HUD "..(self.status.modding and "PERMUTING" or "NOT Permuting"))
	end
	return self.status.modding
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

HUD.RestoreIconSize = function(self)
	for aPos=1, #self.icon do
		self:SetIconDimensions(aPos,self.settings.iconSize)
	end
end

HUD.RestoreIconPosition = function(self)
	DOTMonitor.logMessage("Restoring Icons!")
	if not self.settings.iconPosition then return false end
	for anIndex, anIcon in ipairs(self.GetIconsEnabled()) do
		local aPosition = self.settings.iconPosition["icon_"..aPos] or nil
		self:SetIconPosition(anIndex, aPosition)
	end
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
	DOTMonitor.logMessage("HUD"..":Alpha("..alpha..")")
end

-- HUD Setting
HUD.SetEnabled = function(self, enabled)
	DOTMonitor.logMessage((enabled and "Enabling" or "DISABLING").." HUD")
	self:RestoreIconSize()
	for aPos, anIcon in ipairs(self:GetIconsEnabled()) do
		if enabled
		then anIcon:Show()
		else anIcon:Hide()
		end
	end
end

HUD.NewFrame = function(self, frameGlobalID, frameLayer)
	local aFrame = getglobal(frameGlobalID) or CreateFrame("Frame", frameGlobalID, UIParent)
	aFrame:SetFrameStrata(frameLayer)
	
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
	--self:SetIconPosition(iconIndex, position)
	self:SetIconAlpha(iconIndex)
	self:IconMonitoring(iconIndex, effect)
end

-- HUD Setting
HUD.Unlock = function(self, movable)
	DOTMonitor.logMessage("HUD "..(movable and "Unlocked" or "Locked"))
	self:RestoreIconSize()
	self:Permuting(movable)
	self:Monitoring(not movable)
	self:SetEnabled(movable)
	self:SetVisible(movable and 1 or 0)
	
	for aPos, aFrame in ipairs(self:GetIconsEnabled()) do
		aFrame:SetMovable(movable)
		aFrame:EnableMouse(movable)
	end
end

-- HUD Setting
HUD.SynchronizeWithPlayer = function(self, aPlayer)
	self:Unlock(false)
	self:AdjustIconsToPlayer(aPlayer)
	self:RestoreIconPosition()
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
	
	self:RestoreIconSize()
end

HUD.RetrivePositions = function(self)
	local positions = {}
	for aPos, anIcon in ipairs(self.icon) do
		if anIcon:IsUserPlaced() then
			local _, _, _, xOffset, yOffset = anIcon:GetPoint()
			positions["icon_"..aPos] = {x = xOffset, y = yOffset}
		end
	end
	return positions
end

HUD.GetPreferences = function(self)
	self.settings.iconPosition = self:RetrivePositions();
	return self.settings
end

HUD.New = function(self, preferences)
	local newHUD = {
		icon 		= {},
		settings	= {},
		status		= {modding = false},
		
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
		RestoreIconSize			= self.RestoreIconSize,
		RestoreIconPosition		= self.RestoreIconPosition,
		Monitoring				= self.Monitoring,
		SetEnabled				= self.SetEnabled,
		Permuting				= self.Permuting,
		NewFrame				= self.NewFrame,
		NewIcon					= self.NewIcon,
		Unlock					= self.Unlock,
		SynchronizeWithPlayer 	= self.SynchronizeWithPlayer,
		AdjustIconsToPlayer 	= self.AdjustIconsToPlayer,
		RetrivePositions		= self.RetrivePositions,
		GetPreferences			= self.GetPreferences
	}
	
	newHUD:SetPreferences(preferences)
	return newHUD
end