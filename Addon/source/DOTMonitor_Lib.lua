DOTMonitor 				= {} -- Main Addon
DOTMonitor.inspector 	= {} -- Inspector Library
DOTMonitor.utility		= {} -- Utility Library
DOTMonitor.HUD			= {} -- HUD
DOTMonitor.library		= {} -- Class Library

DOTMonitor.scanner = {
	debuffMonitor = (function(self, elapsed)
		self.lastUpdate = self.lastUpdate and (self.lastUpdate + elapsed) or 0
		if self.lastUpdate >= 0.1 then
		--[[	
			if not DOTMonitor.inspector.playerTargetingLivingEnemy() then
				self:SetAlpha(0) 
				return false
			end
			--]]
	
			local duration, expiration, caster = DOTMonitor.inspector.checkUnitForDebuff("target",self.effect)
	
			local spellIconSize = self.settings.iconSize
			local spellMaxAlpha = self.settings.maxAlpha
	
			if caster == "player" then
				local timeRemaining = (expiration - GetTime())
				local timeFraction 	= (duration ~= 0) and (timeRemaining / duration) or 0

				self:SetHeight(spellIconSize - (timeFraction * spellIconSize))
				self:SetAlpha(spellMaxAlpha	- (timeFraction * spellMaxAlpha))
			else
				self:SetHeight(spellIconSize)
				self:SetAlpha(spellMaxAlpha)
			end
	
			self.lastUpdate = 0
		end
	end)
}

local debugMode = true

-- ///////////////////////////////////////////////////////////////////////////////////////
-- Print Functions
-- printMessage( messageText [, (red, green, blue | info | epic)]) -> prints messageText to DEFAULT_CHAT_FRAME
DOTMonitor.printMessage = (function(aMessage, ...)
	local colorScheme = {
		["none"] 	= {r = 0,	g = 1,	b = 1},
		["info"] 	= {r = 0,	g = 1,	b = 1},
		["epic"] 	= {r = .8,	g = .2,	b = 1},
		["alert"] 	= {r = 1,	g = 0,	b = 0},
		["custom"] 	= {r = 1,	g = 1,	b = 1}
	}
	local colorType = "info";
	
	if (...) then
		local r, g, b = ...
		if type(r) == "number" and type(g) == "number" and type(b) == "number" then
			colorType = "custom";
			colorScheme[colorType] 	= {r=r,g=g,b=b}; 
		elseif type(r) == "string" then
			colorType = r
		end
	end
	
	local color 	= colorScheme[colorType]
	local output 	= (type((select(1,...))) == "string") and ("\[DOTMonitor "..aMessage.."]") or ("\[DOTMonitor] "..aMessage)
	
	DEFAULT_CHAT_FRAME:AddMessage(output, color.r, color.g, color.b)
end)

-- logMessage( messageText ) -> IF debugMode enabled: prints messageText to DEFAULT_CHAT_FRAME
DOTMonitor.logMessage = (function(aMessage)
	if debugMode then
		DEFAULT_CHAT_FRAME:AddMessage("\[DOTMonitor DEBUG\] "..aMessage, 1, 0, 0)
	end
end)
-- ///////////////////////////////////////////////////////////////////////////////////////




-- @ Utility Library Implementation
-- ================================================================================
DOTMonitor.utility.capitalize = function(aString)
	return (aString:gsub("^%l", string.upper))
end

DOTMonitor.utility.getSpellID = function(aSpell)
	local spellInfo = GetSpellLink(aSpell)
	return spellInfo and string.match(spellInfo, "spell:(%d+)") or false
end

DOTMonitor.utility.getSpellName = function(aDebuff)
	return (type(aDebuff) == "string") and aDebuff or aDebuff[1]
end

DOTMonitor.utility.getAbilityTexture = function(anAblity)
	return (select(3, GetSpellInfo(anAblity)))
end

DOTMonitor.utility.getAbilitiesForPlayer = function(abilityType, aPlayer)
	local pClass, pSpec = aPlayer.info.class, aPlayer.spec.name
	abilityType = abilityType:gsub("^%l", string.upper)
	local abilityData = getglobal("DOTMonitor"..abilityType.."_"..GetLocale()) 
					 or getglobal("DOTMonitor"..abilityType.."_enUS")
	
	--return {spell = abilityData[pClass][pSpec],effect = abilityData[pClass].effect[pSpec]}
	return {effect = abilityData[pClass][pSpec],spell = abilityData[pClass].spellIconFor[pSpec]}
end
--[[
DOTMonitor.utility.getAbilitesForClassSpec = function(aClass, aSpec)
	local debuffData = getglobal("DOTMonitorDebuffs_"..GetLocale()) or getglobal("DOTMonitorDebuffs_enUS")
	return debuffData[aClass][aSpec], debuffData[aClass].spellIconFor[aSpec]
end
--]]

DOTMonitor.utility.frameEnabled = function(aFrame, enabled)
	if enabled 
	then aFrame:Show()
	else aFrame:Hide()
	end
end


-- @ Inspector Library Implementation
-- ================================================================================
DOTMonitor.inspector.canMonitorPlayer = function()
	return UnitLevel("player") >= 10 and GetSpecialization() and true
end

DOTMonitor.inspector.getClassName = function()
	return DOTMonitor.utility.capitalize(string.lower(select(2,UnitClass("player")))):gsub(" ", "_")
end

DOTMonitor.inspector.getSpecInfo = function()
	local specInfo = {id = nil, name = nil, description = nil}
	
	if not DOTMonitor.inspector.canMonitorPlayer() then return false end
	specInfo.id, specInfo.name, specInfo.description = select(1,GetSpecializationInfo(GetSpecialization()))
	specInfo.name = specInfo.name:gsub(" ", "_") -- Death Knights -> Death_Knights
	return specInfo
end
--[[
DOTMonitor.inspector.getPossibleAbilities = function(allAbilities)
	local availableAbilities = {}
	
	for atPosition, anAbility in ipairs(allAbilities) do
		local abilityName = DOTMonitor.utility.getSpellName(anAbility)
		DOTMonitor.logMessage("Testing "..abilityName)
		
		if DOTMonitor.utility.getSpellID(abilityName) 
		then table.insert(availableAbilities, anAbility)
		else DOTMonitor.logMessage("Not Supported: "..abilityName) 
		end
	end
	
	return availableAbilities
end
--]]
DOTMonitor.inspector.getPossibleAbilities = function(allAbilities)
	local availableAbilities = {spell = {}, effect = {}}
	
	for atIndex, anAbility in ipairs(allAbilities.spell) do
		DOTMonitor.logMessage("Testing "..anAbility)
		if DOTMonitor.utility.getSpellID(anAbility) then
			table.insert(availableAbilities.spell, anAbility)
			table.insert(availableAbilities.effect, allAbilities.effect[atIndex])
		else
			DOTMonitor.logMessage("Not Supported: "..anAbility) 
		end
	end
end
	

DOTMonitor.inspector.unitIsAlive = function(aUnit)
	return (UnitExists(aUnit) and (not UnitIsDead(aUnit))) or false
end

DOTMonitor.inspector.playerTargetingEnemy = function()
	return UnitIsEnemy("player", "target") or UnitCanAttack("player", "target")
end

DOTMonitor.inspector.playerTargetingLivingEnemy = function()
	local playerIsAlive = DOTMonitor.inspector.unitIsAlive("player")
	local targetIsEnemy = DOTMonitor.inspector.playerTargetingEnemy()
	return (playerIsAlive and targetIsEnemy)
end

DOTMonitor.inspector.checkUnitForDebuff = function(aUnit, debuff)
	local duration, expiration, caster = nil, nil, nil;
	local singleDebuff = type(debuff) == "string"
	if singleDebuff then 
		duration, expiration, caster = select(6, UnitDebuff(aUnit, debuff))
	else
		for aPosition, aDebuff in ipairs(debuff) do
			if UnitDebuff(aUnit, aDebuff) then
				duration, expiration, caster = select(6, UnitDebuff(aUnit, aDebuff))
				break
			end
		end
	end
	return duration, expiration, caster
end

DOTMonitor.inspector.getPlayerInfo = function()
	return {
		class 		= DOTMonitor.inspector.getClassName(),
		spec		= DOTMonitor.inspector.getSpecInfo()
		level 		= UnitLevel("player"),
		healthMax 	= UnitHealthMax("player")
	}
end



-- @ Player Methods Implementation
-- ================================================================================
--DOTMonitor.PlayerClass = {}
--local Player = DOTMonitor.PlayerClass -- Player Class
local Player = {}
Player.Synchronize = function(self)
	self.info = DOTMonitor.inspector.getPlayerInfo()
	
	if not self.info.spec then return nil end-- Player can't be tracked -> Don't Initialize
	
	local allDebuffs = DOTMonitor.utility.getAbilitiesForPlayer("debuffs", self)
	self.spec = {debuff = DOTMonitor.inspector.getPossibleAbilities(allDebuffs)}
	
	--if self.delegate then delegate:PlayerSpecDidChange(self) end
	if self.delegate then self.delegate:SynchronizeWithPlayer(self) end
end

Player.Delegate = function(self, ...)
	if ... then
		self.delegate = (select(1,...))
	else
		return self.delegate
	end
end

Player.Ready = function(self)
	return self.info.spec.name and self.spec and true or false
end

Player.GetAbilities = function(self, abilityType)
	return self.spec[abilityType]
end

Player.GetAbility = function(self, abilityType, position)
	local playerAbilities = self:GetAbilities(abilityType) 
	return playerAbilities.spell[position], playerAbilities.effect[position]
end

Player.ShowMonitoringInfo = function(self)
	DOTMonitor.printMessage(("adjusted for "..self.info.spec.name.." "..self.info.class), "info")
	for abilityTypePos, anAbilityType in ipairs(self.spec) then
		DOTMonitor.printMessage((anAbilityType:gsub("^%l", string.upper)).." types being monitored:")
		for aPos, aSpell in ipairs(anAbilityType) then
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




-- @ HUD Methods Implementation
-- ================================================================================
local HUD ={}
HUD.SetPreferences = function(self, ...)
	self.settings = (select(1, ...)) or {
		iconSize 	=   44,
		yOffset 	= -126,
		maxAlpha	=  .60
	}
end

HUD.GetIconsEnabled = function(self)
	local active = {}
	for aPos, icon in ipairs(self.icon) do
		if anIcon.effect then
			table.insert(active, icon)
		end
	end
	return active
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

-- HUD Setting
HUD.SetVisible = function(self, ...)
	for aPos, anIcon in ipairs(self:GetIconsEnabled()) do
		anIcon:SetAlpha(... and (select(1,...)) or 0)
	end
end

-- HUD Setting
HUD.Monitoring = function(self, enabled)
	for aPos, anIcon in ipairs(self:GetIconsEnabled()) do
		anIcon:SetScript("OnUpdate", (enabled and DOTMonitor.scanner.debuffMonitor) or nil)
	end
end

-- HUD Setting
HUD.SetEnabled = function(self, enabled, ...)
	if enabled and self.ignoringEverything then
		DOTMonitor.logMessage("Ignoring enable request...")
		return false
	end
	for aPos, icon in ipairs(self:GetIconsEnabled()) do
		if enabled
		then icon:Show()
		else icon:Hide()
		end
	end
	if ... then 
		self.ignoringEverything = (select(1,...))
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
	
	self:SetIconDimensions(iconIndex, iconSize)
	self:SetIconBackground(iconIndex, texture)
	self:SetIconPosition(iconIndex, position)
	self:SetIconAlpha(iconIndex)
	self:IconMonitoring(iconIndex, effect)
end

-- HUD Setting
HUD.SetMovable = function(self, movable)
	self:Monitoring(not movable)
	self:SetEnabled(movable)
	self:SetVisible(movable)
	for aPos, aFrame in ipairs(self:GetIconsEnabled()) do
		aFrame:SetMovable(movable)
		aFrame:EnableMouse(movable)
	end
end

-- HUD Setting
HUD.SynchronizeWithPlayer = function(self, aPlayer)
	self:SetEnabled(false, true)
	
	self:AdjustIconsToPlayer(aPlayer)
	
	self:SetEnabled(false, false)
end

-- HUD Setting
HUD.AdjustIconsToPlayer = function(self, aPlayer)
	if not aPlayer:Ready() then return false end
	local availableSlots, requiredSlots = #self.icon, #aPlayer:GetAbilities()
	
	if availableSlots < requiredSlots then -- Create frames if needed
		local zeroPoint = {x=0,y=0}
		for i=0, (requiredSlots-availableSlots) do
			self:NewIcon(zeroPoint, "\[N/A\]", "\[N/A\]")
		end
	end
	
	for aPos = 1, #self.icon do
		if aPos <= requiredSlots then
			local spell, effect = aPlayer:GetAbility(aPos)
			self:SetIconBackground(aPos, spell)
			self:IconMonitoring(aPos, effect)
		else
			self:SetIconAlpha(aPos, 0)
			self:IconMonitoring(aPos, nil)
		end
	end
	self:SetMonitor(true)
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
		SetMovable				= self.SetMovable,
		SynchronizeWithPlayer 	= self.SynchronizeWithPlayer,
		AdjustIconsToPlayer 	= self.AdjustIconsToPlayer
	}
	
	
	newHUD:SetPreferences(preferences)
	--newHUD:SynchronizeWithPlayer(aPlayer)
	--newHUD:FormalPosition()
	return newHUD
end

DOTMonitor.library.Player 	= Player
DOTMonitor.library.HUD		= HUD