DOTMonitor 				= {} -- Main Addon
DOTMonitor.inspector 	= {} -- Inspector Library
DOTMonitor.utility		= {} -- Utility Library
DOTMonitor.HUD			= {} -- HUD

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

DOTMonitor.utility.getClassName = function()
	return DOTMonitor.utility.capitalize(string.lower(select(2,UnitClass("player")))):gsub(" ", "_")
end

DOTMonitor.utility.getSpellName = function(aDebuff)
	return (type(aDebuff) == "string") and aDebuff or aDebuff[1]
end

DOTMonitor.utility.getAbilityTexture = function(anAblity)
	return (select(3, GetSpellInfo(anAblity)))
end

DOTMonitor.utility.getAbilitesForClassSpec = function(aClass, aSpec)
	local debuffData = getglobal("DOTMonitorDebuffs_"..GetLocale()) or getglobal("DOTMonitorDebuffs_enUS")
	return debuffData[aClass][aSpec], debuffData[aClass].spellIconFor[aSpec]
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
	
	if not DOTMonitor.inspector.canMonitorPlayer() then return false end
	specInfo.id, specInfo.name, specInfo.description = select(1,GetSpecializationInfo(GetSpecialization()))
	specInfo.name = specInfo.name:gsub(" ", "_") -- Death Knights -> Death_Knights
	return specInfo
end

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
		class 		= DOTMonitor.utility.getClassName(), 
		level 		= UnitLevel("player"),
		healthMax 	= UnitHealthMax("player")
	}
end



-- @ Player Methods Implementation
-- ================================================================================
DOTMonitor.PlayerClass = {}
local Player = DOTMonitor.PlayerClass -- Player Class

Player.Synchronize = function(self)
	self.info = DOTMonitor.inspector.getPlayerInfo()
	self.spec = DOTMonitor.inspector.getSpecInfo()
	
	if self.spec then -- Player CAN'T Be Tracked
		status = ("Player: "..(self.info.class).." ("..(self.spec.name)..")")
		local abilities, allAbilities	= DOTMonitor.utility.getAbilitesForClassSpec(self.info.class, self.spec.name)
		self.spec.spells 	= DOTMonitor.inspector.getPossibleAbilities(allAbilities)
		self.spec.textures 	= allAbilities
		self.ready = true
	else
		status = "Missing Specialization!"
		self.ready = false
	end
	
	DOTMonitor.logMessage(status)
end

Player.GetAbilityTexture = function(self, position)
	return self.spec.textures[position]
end

Player.GetAbilities = function(self)
	return self.spec.spells
end

Player.GetAbility = function(self, position)
	return DOTMonitor.utility.getSpellName(self.spec.spells[position]), self:GetAbilityTexture(position)
end

Player.ShowTrackingInfo = function(self)
	local className, classSpec = self.info.class, self.spec.name
	DOTMonitor.printMessage(("adjusting for "..classSpec.." "..className), "info")
	
	for aPos = 1, #self.spec.textures do
		DOTMonitor.printMessage("tracking "..self:GetAbilityTexture(aPos), "info")
	end
end

Player.New = function(self)
	local aPlayer = { -- Player Instance
		info = {
			class			= nil,
			level 			= nil,
			healthMax 		= nil
		},
		spec = {
			name 		= nil,
			id			= nil,
			description = nil,
			spells 		= nil,
			spellTexture= nil
		},
		ready = false,
		
		-- Methods
		Synchronize 		= self.Synchronize,
		GetAbilityTexture 	= self.GetAbilityTexture,
		GetAbilities		= self.GetAbilities,
		GetAbility			= self.GetAbility,
		ShowTrackingInfo	= self.ShowTrackingInfo
	}
	return aPlayer
end




-- @ HUD Methods Implementation
-- ================================================================================
DOTMonitor.HUD.SetPreferences = function(self, ...)
	local preferences = (select(1,...)) or nil
	local defaultPreferences = {
		iconSize 	=   44,
		yOffset 	= -126,
		maxAlpha	=  .60
	}
	self.preferences = (preferences ~= nil) and preferences or defaultPreferences;
	--self.preferences = defaultPreferences
end

DOTMonitor.HUD.SetIconBackground = function(self, position, texturePath)
	local anIcon = self.frame[position]
	
	if not anIcon.texture then
		anIcon.texture = anIcon:CreateTexture(nil, "BACKGROUND")
	end
	anIcon.texture:SetTexture(texturePath)
	anIcon.texture:SetAllPoints(anIcon)
end
-- NOTE: Use only when all spell frames are ready
DOTMonitor.HUD.IconFormalXOffset = function(self, iconIndex)
	local iconSize 		= self.preferences.iconSize
	local spellQuantity	= #self.player:GetAbilities() -- Here's the catch!
	-- Note the + () is due to adjusted to icon center point
	local derivedOrigin = -((spellQuantity * iconSize)/2) + (iconSize/2) 
	local iconOffset 	= (iconSize * (iconIndex-1))
	return derivedOrigin + iconOffset
end

DOTMonitor.HUD.SetIconPosition = function(self, iconIndex, position)
	local pos = position or {x = self:IconFormalXOffset(iconIndex),
							 y = self.preferences.yOffset}
	self.frame[iconIndex]:SetPoint("CENTER", UIParent, "CENTER", pos.x, pos.y)
end

DOTMonitor.HUD.FormalPosition = function(self)
	for aPosition, aFrame in ipairs(self.frame) do
		self:SetIconPosition(aPosition, nil)
	end
end

DOTMonitor.HUD.SetIconAlpha = function(self, iconIndex, ...)
	local alpha = (select(1,...)) or self.preferences.maxAlpha
	self.frame[iconIndex]:SetAlpha(alpha)
end

DOTMonitor.HUD.SetIconDimensions = function(self, iconIndex, width, ...)
	local w = width
	local h = ((select(1,...)) and (select(1,...))) or w
	self.frame[iconIndex]:SetWidth(w)
	self.frame[iconIndex]:SetHeight(h)
end

DOTMonitor.HUD.GetIcons = function(self)
	return self.frame
end

DOTMonitor.HUD.IconID = function(self, iconIndex, iconID)
	if iconID then
		--DOTMonitor.logMessage("Icon\["..iconIndex.."\] = "..iconID)
		self.frame[iconIndex].name = iconID
	end

	-- If ID nil, then return icon name otherwise set!
	return self.frame[iconIndex].name
end

DOTMonitor.HUD.CreateIcon = function(self, position, texture, spellID)
	local iconIndex = (#self.frame + 1)
	local iconSize 		= self.preferences.iconSize
	local frameGlobalID = ("DOTM_HUD_ICON_"..iconIndex)
	
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
	self:IconID(iconIndex, spellID)
end

DOTMonitor.HUD.SetVisible = function(self, visible)
	local alpha = visible and self.preferences.maxAlpha or 0
	for iconIndex = 1, #self.frame do
		self:SetIconAlpha(iconIndex, alpha)
	end
end

DOTMonitor.HUD.SetEnabled = function(self, enabled)
	enabled = self.player.ready and enabled
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

DOTMonitor.HUD.AdjustIconsToSpec = function(self)
	local player = self.player
	local availableSlots, requiredSlots = #self:GetIcons(), #player:GetAbilities()
	
	-- Create Frames If Needed
	if requiredSlots > availableSlots then
		local zeroPoint = {x=0, y=0}
		for i = 1, (requiredSlots-availableSlots) do
			self:CreateIcon(zeroPoint, "[N/A]", "[N/A]")
		end
	end
	
	for aPos = 1, #self.frame do
		if aPos <= requiredSlots then
			local spellName, textureSpellName = player:GetAbility(aPos)
			local iconTexture = DOTMonitor.utility.getAbilityTexture(textureSpellName)
			self:IconID(aPos, spellName)
			self:SetIconBackground(aPos, iconTexture)
		else
			self:SetIconAlpha(aPos, 0)
		end
	end
end

DOTMonitor.HUD.Update = function(self)
	self:SetEnabled(false)
	
	self.player = DOTMonitor.unit.player
	self:AdjustIconsToSpec()
	self:FormalPosition()
end

DOTMonitor.HUD.Initialize = function(self, player, preferences)
	self.frame = {}
	self.player = player
	self:SetPreferences(preferences)
	self:AdjustIconsToSpec()
	self:FormalPosition()
	
	self:SetEnabled(false)
end