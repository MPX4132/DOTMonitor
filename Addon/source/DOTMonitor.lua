local DOTMonitorInterfaceYOffset = -126
local DOTMonitorInterfaceOpacity = 1 -- (0 - 1)
local DOTMonitorIconBuildupOpacity = .60
local spellIconSize = 44
local alert = {
	targetPlayerHealthThreshold = 35,
	selfHealthThreshold = 30,
	victorySoundPath = "Interface\\AddOns\\DOTMonitor\\sound\\Exciting_Suspense.mp3",
	playSoundAlerts = false
}
-- DOTMonitor functions lib
DOTMonitor 	= {} -- Main Library
DOTMonitor.update 		= {} -- Secondary Libraries
DOTMonitor.initialize 	= {}
DOTMonitor.frame 		= {} -- Spell frames data
DOTMonitor.frame.spell 	= {} -- Spell frames
DOTMonitor.active 		= false
DOTMonitor.debugMode	= true

DOTMonitor.inspector = {} -- Player Tools Library


local castableDebuffsForClass = getglobal("DOTMonitorDebuffs_"..GetLocale()) or getglobal("DOTMonitorDebuffs_enUS")

local player = {
	info = {
		class,
		spec
	},
	status = {
		inCombat,
		inDanger,
		maxHealth,
		targetMaxHealth
	},
	availableSpells
}
DOTMonitor.sound = {
	isPlaying = {
		impendingVictory = false
	},
	timer = {
		masterUpdater = 0,
		impendingVictoryTracker = 0
	}
}

-- ///////////////////////////////////////////////////////////////////////////////////////
-- Print Functions
-- printMessage( messageText [, (red, green, blue | info | epic)]) -> prints messageText to DEFAULT_CHAT_FRAME
DOTMonitor.printMessage = (function(aMessage, ...)
	if not (...) then
		DEFAULT_CHAT_FRAME:AddMessage("\[DOTMonitor\] "..aMessage, 0, 1, 1)
	else
		local red, green, blue = ...
		if type(red) == "number" and type(green) == "number" and type(blue) == "number" then
			DEFAULT_CHAT_FRAME:AddMessage("\[DOTMonitor\] "..aMessage, red, green, blue)
		else
			if red == "info" then
				DEFAULT_CHAT_FRAME:AddMessage("\[DOTMonitor "..aMessage, 0, 1, 1)
			elseif red == "epic" then
				DEFAULT_CHAT_FRAME:AddMessage("\[DOTMonitor "..aMessage, .8, .2, 1)
			end
		end
	end
end)

-- logMessage( messageText ) -> IF debugMode enabled: prints messageText to DEFAULT_CHAT_FRAME
DOTMonitor.logMessage = (function(aMessage)
	if DOTMonitor.debugMode then
		DEFAULT_CHAT_FRAME:AddMessage("\[DOTMonitor DEBUG\] "..aMessage, 1, 0, 0)
	end
end)
-- ///////////////////////////////////////////////////////////////////////////////////////

-- capitalize( aString ) -> capitalizes the string
DOTMonitor.capitalize = (function(aString)
    return (aString:gsub("^%l", string.upper))
end)

-- getSpellName( (aString | aTable) ) -> string
DOTMonitor.getSpellName = (function(aDebuff)
	return type(aDebuff) == "string" and aDebuff or aDebuff[1]
end)

DOTMonitor.getTextureForAbility = (function(anAbility)
	if not player.info then return false end
	for atPosition, theDebuff in ipairs(castableDebuffsForClass[player.info.class][player.info.spec.Name]) do
		local aDebuff = DOTMonitor.getSpellName(theDebuff)
		if aDebuff == anAbility then return (select(3, GetSpellInfo(castableDebuffsForClass[player.info.class].spellIconFor[player.info.spec.Name][atPosition]))) end
	end
	return false
end)

-- checkTargetForDebuff( aString ) -> number, number, string
DOTMonitor.checkTargetForDebuff = (function(debuff)
	local duration, expiration, caster
	
	if type(debuff) == "string" then
		duration, expiration, caster = select(6, UnitDebuff("target", debuff))
	else
		for aPosition, aDebuff in ipairs(debuff) do
			if UnitDebuff("target", aDebuff) then
				duration, expiration, caster = select(6, UnitDebuff("target", aDebuff))
				break
			end
		end
	end
	return duration, expiration, caster
end)

-- abilitiesChanged() -> Boolean
DOTMonitor.inspector.abilitiesChanged = (function()	
	for atIndex=1, #player.availableSpells do
		local frameName, theDebuffName = ("icon_"..atIndex), DOTMonitor.getSpellName(player.availableSpells[atIndex])
		if (DOTMonitor.frame.spell[frameName] == nil) or (DOTMonitor.frame.spell[frameName].name ~= theDebuffName) then
			return true
		end
	end
	return false
end)

-- getSpellID( aString ) -> string
DOTMonitor.inspector.getSpellID = (function(spellName)
	local spellInfo = GetSpellLink(spellName)
	local spellID = spellInfo and string.match(spellInfo, "spell:(%d+)") or false
	return spellID
end)

-- canMonitorPlayer() -> Boolean
DOTMonitor.inspector.canMonitorPlayer = (function()
	return UnitLevel("player") >= 10 and GetSpecialization() and true
end)

-- getPossibleAbilities( aString, aString ) -> table
DOTMonitor.inspector.getPossibleAbilities = (function(className, specName)
	
	local availableAbilities, allAbilities = {}, castableDebuffsForClass[className].spellIconFor[specName]
	local anAbilityName = ""
	for atPosition, anAbility in ipairs(allAbilities) do
		anAbilityName = DOTMonitor.getSpellName(anAbility)
		--if anAbilityName and IsSpellKnown(DOTMonitor.inspector.getSpellID(anAbilityName)) then
		if DOTMonitor.inspector.getSpellID(anAbilityName) then
			table.insert(availableAbilities, castableDebuffsForClass[className][specName][atPosition])
		else
			DOTMonitor.logMessage("NOT SUPPORTED: "..anAbilityName)
		end
	end
	return availableAbilities
end)


-- GOT ALL ABOVE THIS LINE WITH THE EXCEPTION OF THE IMPLEMENTATION OF abilitiesChanged

DOTMonitor.initialize.playerVariables = (function()
	DOTMonitor.logMessage("setting player variables")
	
	if DOTMonitor.inspector.canMonitorPlayer() then
		DOTMonitor.logMessage("Will track Player!")
		local specInfo = {}
	
		-- Get Player Info
		specInfo.ID, specInfo.Name, specInfo.Description = select(1,GetSpecializationInfo(GetSpecialization()))
		specInfo.Name = specInfo.Name:gsub(" ", "_")

		player.info.class 		= DOTMonitor.capitalize():gsub(" ", "_")

		-- Set Player Info
		player.info.spec 		= specInfo
		player.availableSpells 	= DOTMonitor.inspector.getPossibleAbilities(player.info.class, player.info.spec.Name)
		DOTMonitor.playerInfoReady = true
	else
		DOTMonitor.logMessage("CANNOT TRACK PLAYER!")
		DOTMonitor.playerInfoReady = false
	end
end)


-- ///////////////////////////////////////////////////////////////////////////////////////
-- Implementation
DOTMonitor.frame.enableAll = (function(shouldEnable)
	for atIndex=1, #player.availableSpells do
		local frameName = ("icon_"..atIndex)
		if shouldEnable then
			--DOTMonitor.logMessage("Frames ON!")
			DOTMonitor.frame.spell[frameName]:Show()
		else
			--DOTMonitor.logMessage("Frames OFF!!!")
			DOTMonitor.frame.spell[frameName]:Hide()
		end
	end
	DOTMonitor.logMessage(shouldEnable and "Frames ON!" or "Frames OFF!!!")
end)

DOTMonitor.frame.displayFrames = (function(shouldDisplay)
	local opacity = shouldDisplay and DOTMonitorInterfaceOpacity or 0
	for atIndex=1, #player.availableSpells do
		DOTMonitor.frame.spell[("icon_"..atIndex)]:SetAlpha(opacity)
	end
end)

DOTMonitor.frame.spellMeter = (function(self, elapsed)
	lastMeterUpdate = lastMeterUpdate and lastMeterUpdate + elapsed or 0
	DOTMonitor.sound.timer.masterUpdater = DOTMonitor.sound.timer.masterUpdater and DOTMonitor.sound.timer.masterUpdater + elapsed or 0
	
	if DOTMonitor.active and DOTMonitor.playerTargettingPotentialEnemy then
	
		if lastMeterUpdate >= 0.1 then
			for atPosition, aDebuff in ipairs(player.availableSpells) do
				local spellFrame = DOTMonitor.frame.spell[("icon_"..atPosition)]
				local duration, expiration, caster = DOTMonitor.checkTargetForDebuff(aDebuff)
				
				if caster == "player" then
					local timeRemaining = expiration - GetTime() 
					local timeFraction = (duration ~= 0) and (timeRemaining / duration) or 0

					spellFrame:SetHeight(spellIconSize - (timeFraction * spellIconSize))
					spellFrame:SetAlpha(DOTMonitorIconBuildupOpacity - (timeFraction * DOTMonitorIconBuildupOpacity))
				else
					spellFrame:SetHeight(spellIconSize)
					spellFrame:SetAlpha(DOTMonitorInterfaceOpacity)
				end
			end
			lastMeterUpdate = 0
		end
		
		-- Sound
		if playSoundAlerts and DOTMonitor.sound.timer.masterUpdater >= 0.25 then -- Update sound monitor
			
			--if ((UnitHealth("target") * 100) / player.status.targetMaxHealth) <= alert.targetPlayerHealthThreshold and ((UnitHealth("player") * 100) / player.status.maxHealth) >= alert.selfHealthThreshold and (not DOTMonitor.sound.isPlaying.impendingVictory) then
			local playerHealthPercentage = (UnitHealth("player") / UnitHealthMax("player")) * 100
			local targetHealthPercentage = (UnitHealth("target") / UnitHealthMax("target")) * 100
			local notifyForTarget = UnitIsPlayer("target")
			
			if notifyForTarget and targetHealthPercentage <= alert.targetPlayerHealthThreshold and playerHealthPercentage >= alert.selfHealthThreshold and (not DOTMonitor.sound.isPlaying.impendingVictory) then
				PlaySoundFile(alert.victorySoundPath, "Master")
				DOTMonitor.sound.isPlaying.impendingVictory = true
				DOTMonitor.sound.timer.impendingVictoryTracker = GetTime() + 37
			elseif DOTMonitor.sound.timer.impendingVictoryTracker <= GetTime() then
				DOTMonitor.sound.isPlaying.impendingVictory = false
				DOTMonitor.sound.timer.impendingVictoryTracker = 0
			end
			DOTMonitor.sound.timer.masterUpdater = 0
		end
	else
		DOTMonitor.frame.displayFrames(false)
	end
end)

DOTMonitor.frame.adjustAll = (function()

	local numberOfSpells, spellOffset = #player.availableSpells, -((spellIconSize * #player.availableSpells) / 2) + (spellIconSize / 2)
	local isNewSpec = DOTMonitor.inspector.abilitiesChanged()
	
	if isNewSpec then DOTMonitor.printMessage("adjusting for "..player.info.spec.Name.."\]", "info") end
	
	for atPosition, theDebuff in ipairs(player.availableSpells) do
		local aDebuff = DOTMonitor.getSpellName(theDebuff)
		if isNewSpec then
			local frameID, frameGlobalID, frameBackgroundTexture = ("icon_"..atPosition), ("DOTMFrame_"..atPosition), nil
			-- Trouble line below
			local iconPath = DOTMonitor.getTextureForAbility(aDebuff)
			local globalSpellFrame = getglobal(frameGlobalID)
			
			if not globalSpellFrame then -- No frame, create one!
				DOTMonitor.logMessage("CREATING FRAME FOR \["..aDebuff.."\]")--tostring((select(1, GetSpellInfo(aDebuff)))).."\]")
				DOTMonitor.frame.spell[frameID] = CreateFrame("Frame", frameGlobalID, UIParent)
				DOTMonitor.frame.spell[frameID]:SetFrameStrata("BACKGROUND")
				
				frameBackgroundTexture = DOTMonitor.frame.spell[frameID]:CreateTexture(nil, "BACKGROUND")
				
				
				-- FRAME METER SETSCRIPT
				if atPosition == 1 then
					DOTMonitor.frame.spell[frameID]:SetScript("OnUpdate", DOTMonitor.frame.spellMeter)
				end
			end
			
			-- FRAME SPELL NAME ASSIGNMENT
			DOTMonitor.frame.spell[frameID].name = aDebuff
			
			-- FRAME SPELL ICON DIMENSIONS
			DOTMonitor.frame.spell[frameID]:SetWidth(spellIconSize)
			DOTMonitor.frame.spell[frameID]:SetHeight(spellIconSize)
			
			if not DOTMonitor.frame.spell[frameID].texture then
				frameBackgroundTexture:SetTexture(iconPath)
				frameBackgroundTexture:SetAllPoints(DOTMonitor.frame.spell[frameID])
				
				DOTMonitor.frame.spell[frameID].texture = frameBackgroundTexture
			else
				DOTMonitor.frame.spell[frameID].texture:SetTexture(iconPath)
			end
			
			DOTMonitor.frame.spell[frameID]:SetAlpha(DOTMonitorInterfaceOpacity)
			DOTMonitor.frame.spell[frameID]:SetPoint("CENTER", UIParent, "CENTER", spellOffset + (spellIconSize * (atPosition - 1)), DOTMonitorInterfaceYOffset)
			
			DOTMonitor.logMessage("\[frame updated for "..aDebuff.."\]")
			DOTMonitor.printMessage("tracking: "..aDebuff.."\]", "info")
		end
	end
end)




local DOTMonitorEventManager = (function(self, event, ...)
	player.status.inCombat = UnitAffectingCombat("player") or false
	
	if event == "PLAYER_TARGET_CHANGED" then
	
		local unitIsAlive = (UnitExists("target") and (not UnitIsDead("target"))) or false
		DOTMonitor.playerTargettingPotentialEnemy = (unitIsAlive and (UnitIsEnemy("player", "target") or UnitCanAttack("player", "target"))) and true or false
		player.status.maxHealth = UnitHealthMax("player") or false
		player.status.targetMaxHealth = UnitHealthMax("target") or false
		DOTMonitor.logMessage("target changed: "..(unitIsAlive and UnitName("target") or "No Target"))
	elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
		DOTMonitor.frame.enableAll((event == "PLAYER_REGEN_DISABLED")) 
	elseif event == "PLAYER_TALENT_UPDATE" or event == "PLAYER_LEVEL_UP" then
		DOTMonitor.active = false
		DOTMonitor.frame.enableAll(false)
		DOTMonitor.initialize.playerVariables()
		DOTMonitor.frame.adjustAll()
		DOTMonitor.active = true
	elseif event == "PLAYER_ENTERING_WORLD" then
		DOTMonitor.active = false
		DOTMonitor.initialize.playerVariables()
		if DOTMonitor.playerInfoReady then
			DOTMonitor.frame.adjustAll()
			DOTMonitor.initialize.monitors()
			DOTMonitor.frame.enableAll(false)
			DOTMonitor.active = true
			DEFAULT_CHAT_FRAME:AddMessage("\[DOTMonitor: Ready\]", .8, .2, 1)
		else
		
			DOTMonitor.printMessage("requires a specialization!\]")
		end
	end
end)

-- Event Handlers
local DOTMonitorEventCenter = CreateFrame("Frame")
DOTMonitorEventCenter:SetScript("OnEvent", DOTMonitorEventManager)
DOTMonitorEventCenter:SetAlpha(0)

DOTMonitor.initialize.monitors = (function()

	-- initialization	
	DOTMonitorEventCenter:RegisterEvent("PLAYER_TARGET_CHANGED")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_REGEN_DISABLED")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_REGEN_ENABLED")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_TALENT_UPDATE")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_LEVEL_UP")
	
	DOTMonitor.logMessage("initialized!")
	DOTMonitor.active = true
end)

DOTMonitorEventCenter:RegisterEvent("PLAYER_ENTERING_WORLD")

-- End!  =D