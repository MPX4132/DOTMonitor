DOTMonitor 				= {} -- Main Addon
DOTMonitor.inspector 	= {} -- Inspector Library
DOTMonitor.utility		= {} -- Utility Library
DOTMonitor.HUD			= {} -- HUD


-- ///////////////////////////////////////////////////////////////////////////////////////
-- Print Functions
-- printMessage( messageText [, (red, green, blue | info | epic)]) -> prints messageText to DEFAULT_CHAT_FRAME
DOTMonitor.printMessage = (function(aMessage, ...)
	local colorScheme = {
		["none"] 	= {r = 0,	g = 1,	b = 1},
		["info"] 	= {r = 0,	g = 1,	b = 1},
		["epic"] 	= {r = .8,	g = .2,	b = 1},
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
	
	local color = colorScheme[colorType]
	DEFAULT_CHAT_FRAME:AddMessage("\[DOTMonitor "..aMessage, color.r, color.g, color.b)
end)

-- logMessage( messageText ) -> IF debugMode enabled: prints messageText to DEFAULT_CHAT_FRAME
DOTMonitor.logMessage = (function(aMessage)
	if DOTMonitor.debugMode then
		DEFAULT_CHAT_FRAME:AddMessage("\[DOTMonitor DEBUG\] "..aMessage, 1, 0, 0)
	end
end)
-- ///////////////////////////////////////////////////////////////////////////////////////




-- @ Utility Library Implementation
-- ================================================================================
DOTMonitor.utility.capitalize = function(aString)
	return (aString:gsub("^%l", string.upper))
end

DOTMonitor.utility.replaceCharInString = function(aString, aChar)
	return aString:gsub(" ", "_")
end

DOTMonitor.utility.getSpellID = function(aSpell)
	local spellInfo = GetSpellLink(aSpell)
	return spellInfo and string.match(spellInfo, "spell:(%d+)") or false
end

DOTMonitor.utility.getClassName = function()
	return DOTMonitor.utility.capitalize(string.lower(select(2,UnitClass("player")))):gsub(" ", "_")
end

DOTMonitor.utility.getSpellName = function(aDebuff)
	return (type(aDebuff) == "string") and aDebuff or aDebuff[1]
end

DOTMonitor.utility.getAbilityTexture = function(source, ability)
	return source[ability] and (select(3, GetSpellInfo(source[ability]))) or false
end

DOTMonitor.utility.getAbilitesForClassSpec = function(aClass, aSpec)
	local debuffData = getglobal("DOTMonitorDebuffs_"..GetLocale()) or getglobal("DOTMonitorDebuffs_enUS")
	return debuffData[aClass][aSpec]
end

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

DOTMonitor.inspector.getSpecInfo = function()
	local specInfo = {id = nil, name = nil, description = nil}
	
	if not DOTMonitor.inspector.canMonitorPlayer() return false end
	specInfo.id, specInfo.name, specInfo.description = select(1,GetSpecializationInfo(GetSpecialization()))
	specInfo.name = specInfo.name:gsub(" ", "_") -- Death Knights -> Death_Knights
	return specInfo
end

DOTMonitor.inspector.getPossibleAbilities = function(allAbilities)
	local availableAbilities = {}
	
	for atPosition, anAbility in ipairs(allAbilities) do
		local abilityName = DOTMonitor.utility.getSpellName(anAbility)
		
		if DOTMonitor.utility.getSpellID(abilityName) 
		then table.insert(availableAbilities, anAbility)
		else DOTMonitor.logMessage("Not Supported: "..abilityName) 
		end
	end
	
	return availableAbilities
end

DOTMonitor.inspector.unitIsAlive = function(aUnit)
	return (UnitExists(aUnit) and (not UnitIsDead(aUnit))) or false
end

DOTMonitor.inspector.playerTargetingEnemy = function()
	return UnitIsEnemy("player", "target") or UnitCanAttack("player", "target")
end

DOTMonitor.inspector.playerTargetingLivingEnemy = function()
	local playerIsAlive = DOTMonitor.utility.unitIsAlive("player")
	local targetIsEnemy = DOTMonitor.utility.playerTargetingEnemy()
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
	local standardPlayerInfo = {
		class 		= DOTMonitor.utility.getClassName(), 
		level 		= UnitLevel("player"),
		healthMax 	= UnitHealthMax("player")
	}
	return standardPlayerInfo
end



-- @ Player Methods Implementation
-- ================================================================================
local Player = { -- Player Instance
	info = {
		class			= nil,
		level 			= nil,
		healthMax 		= nil
	},
	spec = {
		name 		= nil,
		id			= nil,
		description = nil,
		spells = {
		
		}
	},
	ready = false
}
Player.Synchronize = function(self)
	self.info = DOTMonitor.inspector.getPlayerInfo()
	self.spec = DOTMonitor.inspector.getSpecInfo()
	
	if self.spec then -- Player CAN'T Be Tracked
		status = ("Player: "..(self.info.class).." ("..(self.spec.name)..")")
		local allAbilities 	= DOTMonitor.utility.getAbilitesForClassSpec(self.info.class, self.spec.name)
		self.spec.spells 	= DOTMonitor.inspector.getPossibleAbilities(allAbilities)
		self.ready = true
	else
		status = "UNSUPPORTED UNIT"
		self.ready = false
	end
	
	DOTMonitor.logMessage(result)
end

DOTMonitor.unit.player = Player




-- @ HUD Methods Implementation
-- ================================================================================
DOTMonitor.HUD.SetPreferences = function(self, preferences)
	local defaultPreferences = {
		iconSize 	=   44,
		yOffset 	= -126,
		maxAlpha	=  .60
	}
	self.preferences = (preferences ~= nil) and preferences
						or defaultPreferences;
end

DOTMonitor.HUD.SetIconBackground = function(self, index, texturePath)
	local anIcon 		= self.frame[index]
	local needsTexture 	= (anIcon.texture == nil)
	
	if needsTexture then
		local backgroundTexture = anIcon:CreateTexture(nil, "BACKGROUND")
		anIcon.texture = backgroundTexture:SetAllPoints(anIcon)
	end
	
	anIcon.texture:SetTexture(texturePath)
end
-- NOTE: Use only when all spell frames are ready
DOTMonitor.HUD.IconFormalXOffset = function(self, iconIndex)
	local iconSize 		= self.preferences.iconSize
	local spellQuantity	= #self.frame -- Here's the catch!
	local derivedOrigin = -((spellQuantity * iconSize)/2) + (spellIconSize/2) -- Note the + () is due to adjusted to icon center point
	local iconOffset 	= (iconSize * (iconIndex-1))
	return derivedOrigin + iconOffset
end

DOTMonitor.HUD.SetIconPosition = function(self, iconIndex, position)
	local pos = position and position or {x = self:IconFormalXOffset(iconIndex),
										  y = self.preferences.yOffset}
	self.frame[iconIndex]:SetPoint("CENTER", UIParent, "CENTER", pos.x, pos.y)
end

DOTMonitor.HUD.SetIconAlpha = function(self, iconIndex, ...)
	local alpha = ((select(1,...)) and (select(1,...))) or self.preferences.maxAlpha
	self.frame[iconIndex]:SetAlpha(alpha)
end

DOTMonitor.HUD.SetIconDimensions = function(self, iconIndex, width, ...)
	local w = width
	local h = ((select(1,...)) and (select(1,...))) or w
	self.frame[iconIndex]:SetWidth(w)
	self.frame[iconIndex]:SetHeight(h)
end

DOTMonitor.HUD.IconID = function(self, iconIndex, ...)
	local iconID = (select(1, ...))
	-- If ID nil, then return icon name otherwise set!
	if iconID then self.frame[iconIndex].name = iconID; end
	return self.frame[iconIndex].name
end

DOTMonitor.HUD.CreateIcon = function(self, position, texture, identifier)
	local iconIndex = (#self.frame + 1)
	local iconSize 		= self.preferences.iconSize
	local frameGlobalID = ("DOTM_HUD_ICON_"..index)
	
	if 
	
	local aFrame = CreateFrame("Frame", frameGlobalID, UIParent)
	aFrame:SetFrameStrata("BACKGROUND")
	
	
	-- Register Frames For MOVEMENT! (THERE NOW BE HAPPY PEOPLE!)
	aFrame:SetScript("OnMouseDown", (function(self, button)
		if button == "LeftButton" and not self.isMoving then
			self:StartMoving(); 		self.isMoving = true;
		end
	end))
	
	aFrame:SetScript("OnMouseUp", (function(self, button)
		if button == "LeftButton" and self.isMoving then
			self:StopMovingOrSizing(); 	self.isMoving = false;
		end
	end))
	
	aFrame:SetScript("OnHide", (function(self)
		if (self.isMoving) then
			self:StopMovingOrSizing(); 	self.isMoving = false;
		end
	end))
	
	table.insert(self.frame, aFrame)
	
	self:SetIconDimensions(iconIndex, iconSize)
	self:SetIconBackground(iconIndex, texture)
	self:SetIconPosition(iconIndex, position)
	self:SetIconAlpha(iconIndex)
	self:IconID(iconIndex, identifier)
end

DOTMonitor.HUD.SetVisible = function(self, visible)
	local alpha = visible and self.preferences.maxAlpha or 0
	for iconIndex = 1, #self.frame do
		self:SetIconAlpha(iconIndex, alpha)
	end
end

DOTMonitor.HUD.SetEnabled = function(self, enabled)
	for pos, aFrame in ipairs(self.frame) do
		if enabled 
		then aFrame:Show()
		else aFrame:Hide()
		end
	end
end

DOTMonitor.HUD.SetMovable = function(self, movable)
	self:SetEnabled(movable)
	self:SetVisible(movable)
	for aPos, aFrame in ipairs(self.frame) do
		aFrame:SetMovable(movable)
		aFrame:EnableMouse(movable)
	end
end

DOTMonitor.HUD.Update = function(self)
	self:SetEnabled(false)
	self:SetVisible(false)
	
	for aPos, aFrame in ipairs(self.frame) do
		aFrame:SetMovable(movable)
		aFrame:EnableMouse(movable)
	end
	
	self:SetVisible(true)
	self:SetEnabled(true)
end
