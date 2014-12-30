-- =======================================================================================
-- Localization Database
-- =======================================================================================
local LocaleDatabase		= _G["DOTMonitorLocalization"]

-- =======================================================================================
-- Foundation
-- =======================================================================================
local Terminal				= _G["MPXFoundation_Terminal"]
local Localizer				= _G["MPXFoundation_Localizer"]
local EventManager			= _G["MPXFoundation_EventManager"]
local Database				= _G["MPXFoundation_Database"]
local TableSet				= _G["MPXFoundation_TableSet"]

-- =======================================================================================
-- UIKit & WOWKit
-- =======================================================================================
local Spell 				= _G["MPXWOWKit_Spell"]
local SpellMonitor 			= _G["MPXWOWKit_SpellMonitor"]
local SpellMonitorManager 	= _G["MPXWOWKit_SpellMonitorManager"]
local Player 				= _G["MPXWOWKit_Player"]


local DOTMonitor = {} -- Local Namespace
local debugging  = false

function DOTMonitor:SyncToPlayer(player)
	self.terminal.outputStream:Log("Syncing Player")
	self.player 	= player or self.player

	self.enabled 	= self.player and true

	if self.enabled then
		local _, spellUpdate = self.player:Sync()
		self.manager:TrackSpells(self:PlayerDebuffs():Array())
		if spellUpdate then
			self:ToggleHUD()
		end
	end
end

function DOTMonitor:IgnoredDebuffs()
	local ignoredDebuffs = TableSet:New()
	for i, debuffID in pairs(self.database.spells.ignored) do
		ignoredDebuffs:AddObject(Spell:New(debuffID))
	end
	return ignoredDebuffs
end

function DOTMonitor:PlayerDebuffs()
	if self.enabled then
		local availableDebuffs 	= self.player:GetDebuff():Copy()
		local ignoredDebuffs 	= self:IgnoredDebuffs()
		return availableDebuffs - ignoredDebuffs
	else
		return TableSet:New()
	end
end

function DOTMonitor:PrintSpells(showClass, showID)
	if self.enabled then
		if showClass then
			self.terminal.outputStream:Print(tostring(self.player), "epic")
		end
		for i, aSpell in pairs(self:PlayerDebuffs()) do
			if aSpell:IsAvailable(self.player) then
				local msg = showID and string.format("> (ID:%06d) %s", aSpell:ID(), tostring(aSpell)) or
									   string.format("> %s", tostring(aSpell))
				self.terminal.outputStream:Print(msg, 100/255, 1, 0)
			end
		end
		for i, aSpell in pairs(self:IgnoredDebuffs()) do
			if aSpell:IsAvailable(self.player) then
				local msg = showID and string.format("- (ID:%06d) %s", aSpell:ID(), tostring(aSpell)) or
									   string.format("- %s", tostring(aSpell))
				self.terminal.outputStream:Print(msg, 0.50, 0.50, 0.50)
			end
		end
	end
end

function DOTMonitor:PrintFault(fault)
	if not fault then
		if not self.player then
			self.terminal:Output(self.localize("player unavailable!"), "critical")
		else
			self.terminal:Output(self.localize("an error has occured, something broke!!!"), "critical")
		end
	else
		self.terminal:Output(self.localize(fault), "warning")
	end
end

function DOTMonitor:Update(monitor, effectDuration, effectExpiration, effectCaster, cooldownStart, cooldownDuration, cooldownEnabled)
	local iconAlpha	= 1

	if effectCaster == "player" then
		if effectDuration ~= 0 then
			iconAlpha = 1 - ((effectExpiration - GetTime()) / effectDuration)
		else
			iconAlpha = (effectExpiration > 0) and 1 or 0
		end
	end

	monitor.icon:SetBorder("Interface\\AddOns\\DOTMonitor\\Graphics\\" .. (((UnitPower("player") < monitor.spell.cost) and "IconBorderDark")
																	or ((iconAlpha >= 0.90) and "IconBorderMarked"  or "IconBorder")))
	monitor:Scale(iconAlpha)
	monitor:SetAlpha(iconAlpha)
	monitor.icon.digitalCooldown:SetAlpha(iconAlpha > 0.50 and 1 or 0)
end

function DOTMonitor:HUDAutoLayout()
	local f = function(x) return ((13 / 1) * math.pow(x, 2) - 180) end
	local position 	= {}
	local count	 	= self:PlayerDebuffs():Count()
	local padding 	= 80
	local start		= -(padding * (count - 1)) / 2
	for x = 1, count do
		position[x] = {x = start + (padding * (x-1)), y = f(x - (1+(count/2)) + 0.5)}
	end
	return position
end

function DOTMonitor:ToggleHUD()
	self.terminal.outputStream:Log("Attempting to change HUD")
	if self.enabled then
		local run = self.player:InCombat()
		self.terminal.outputStream:Log(run and "Running HUD" or "Stopping HUD")
		self.manager:EnableMonitors(run, self:PlayerDebuffs():Count())
	else
		self.terminal.outputStream:Log("HUD Disabled, Ignoring")
		self.manager:EnableMonitors(false)
	end
end

function DOTMonitor:LoadSpecLayout()
	if not self.enabled then return end
	local defaultLayout = self:HUDAutoLayout()
	local customLayout 	= self.database.layout[self.player:Spec() or "NO_SPEC"]
	local formLayout 	= customLayout and (customLayout[self.player:Form()] or customLayout[0]) -- Try humanoid form if no form-specific layout
	for atIndex, aDefaultPosition in ipairs(defaultLayout) do
		local aMonitor = self.manager:GetMonitor(atIndex)
		local position = formLayout and formLayout[atIndex] or aDefaultPosition
		aMonitor.icon:SetCenter(position.x, position.y)
	end
end

function DOTMonitor:SaveSpecLayout()
	if not self.enabled then return end
	local spec = self.player:Spec() or "NO_SPEC"
	local form = self.player:Form()
	self.database.layout[spec] = self.database.layout[spec] or {}
	self.database.layout[spec][form] = self.database.layout[spec][form] or {}
	for i, aMonitor in ipairs(self.manager.monitor) do -- Want to save ALL custom locations
		local iconX, iconY = aMonitor.icon:GetCenterRelativeToPoint("CENTER")
		self.database.layout[spec][form][i] = {x = iconX, y = iconY}
	end
end

function DOTMonitor:LoadSpecSetup()
	if self.enabled then
		self:LoadSpecLayout()

		self.manager:ShowEffectTimers(self.database.label.timers or false)
		self.manager:ShowCooldownTimers(self.database.label.cooldowns or false)
	end
end

function DOTMonitor:ResetHUD()
	if self.enabled then
		self.manager:LockMonitors(true)	-- Lock them to disable user I/O
		self.database.spells.ignored = TableSet:New()
		self.database.layout[self.player:Spec()] = nil
		self.database.label = {} -- clear it
		self:SyncToPlayer()
		self:PrintSpells(true)
		self:LoadSpecSetup()
		self:ToggleHUD()
		return self.localize("HUD was reset!")
	else
		return self.localize("HUD is disabled!")
	end
end

local DOTMonitorDefault = {
	player 	= nil,
	monitor = nil,
	locked 	= true,
	enabled = false,
	SyncToPlayer 	= DOTMonitor.SyncToPlayer,
	IgnoredDebuffs	= DOTMonitor.IgnoredDebuffs,
	PlayerDebuffs	= DOTMonitor.PlayerDebuffs,
	PrintSpells		= DOTMonitor.PrintSpells,
	PrintFault		= DOTMonitor.PrintFault,
	Update			= DOTMonitor.Update,
	HUDAutoLayout	= DOTMonitor.HUDAutoLayout,
	EnableMonitors 	= DOTMonitor.EnableMonitors,
	StopMonitors 	= DOTMonitor.StopMonitors,
	StartMonitors 	= DOTMonitor.StartMonitors,
	ToggleHUD		= DOTMonitor.ToggleHUD,
	LoadSpecLayout	= DOTMonitor.LoadSpecLayout,
	SaveSpecLayout	= DOTMonitor.SaveSpecLayout,
	LoadSpecSetup	= DOTMonitor.LoadSpecSetup,
	ResetHUD		= DOTMonitor.ResetHUD,
}

function DOTMonitor:New(databaseID)
	local dotMonitor = {databaseID = databaseID}
	setmetatable(dotMonitor, {__index = DOTMonitorDefault})

	-- Localization instantiation
	dotMonitor.localize = Localizer:New(LocaleDatabase)


	-- Terminal and Console instantiation
	dotMonitor.terminal	= Terminal:New(dotMonitor, "DOTMonitor", {"dotmonitor", "dmon"})
	dotMonitor.terminal.outputStream:EnableLog(debugging)


	-- Terminal Command Setup
	local command 	= {} -- Terminal functions holder
	local info 		= {} -- Terminal short help text
	-- ===================================================================================
	-- Monitors Custom Position Options
	-- ===================================================================================
	-- Lock Command ----------------------------------------------------------------------
	info[dotMonitor.localize("lock")] = dotMonitor.localize("Locks the monitor icons")
	command[dotMonitor.localize("lock")] = function(self, arguments)
		self.manager:LockMonitors(true) -- Want to lock everything
		self:SaveSpecLayout()
		self:ToggleHUD()
		return self.localize("HUD Locked")
	end

	-- Unlock Command --------------------------------------------------------------------
	info[dotMonitor.localize("unlock")] = dotMonitor.localize("Unlocks the monitor icons")
	command[dotMonitor.localize("unlock")] = function(self, arguments)
		self.manager:LockMonitors(false, self:PlayerDebuffs():Count())
		return self.localize("HUD Unlocked")
	end
	-- ===================================================================================




	-- ===================================================================================
	-- Digital Meter Options
	-- ===================================================================================
	-- Show Command ----------------------------------------------------------------------
	info[dotMonitor.localize("show")] 	= dotMonitor.localize("Show either cooldowns or timers")
	command[dotMonitor.localize("show")] = function(self, arguments)
		if self.localize("cooldowns") == arguments then
			self.manager:ShowCooldownTimers(true)
			self.database.label.cooldowns = true
			return self.localize("Cooldowns now visible")
		elseif self.localize("timers") == arguments then
			self.manager:ShowEffectTimers(true)
			self.database.label.timers = true
			return self.localize("Timers now visible")
		end

		-- No matching argument, show some help
		if arguments then
			self.terminal:Output(string.format(self.localize("Invalid command: \"%s\""), arguments), "warning")
		end

		self.terminal:Output(self.localize("Valid commands are:"))
		self.terminal:Output("> " .. self.localize("cooldowns"))
		self.terminal:Output("> " .. self.localize("timers"))

		return self.localize("Usage: show (cooldowns | timers)")
	end

	-- Hide Command ----------------------------------------------------------------------
	info[dotMonitor.localize("hide")] = dotMonitor.localize("Hide either cooldowns or timers")
	command[dotMonitor.localize("hide")] = function(self, arguments)
		if arguments == self.localize("cooldowns") then
			self.manager:ShowCooldownTimers(false)
			self.database.label.cooldowns = nil
			return self.localize("Cooldowns now hidden")
		elseif arguments == self.localize("timers") then
			self.manager:ShowEffectTimers(false)
			self.database.label.timers = nil
			return self.localize("Timers now hidden")
		end

		-- No matching argument, show some help
		if arguments then
			self.terminal:Output(string.format(self.localize("Invalid command: \"%s\""), arguments), "warning")
		end

		self.terminal:Output(self.localize("Valid commands are:"))
		self.terminal:Output("> " .. self.localize("cooldowns"))
		self.terminal:Output("> " .. self.localize("timers"))

		return self.localize("Usage: hide (cooldowns | timers)")
	end
	-- ===================================================================================




	-- ===================================================================================
	-- Spell Monitoring Options
	-- ===================================================================================
	-- Spells Command --------------------------------------------------------------------
	info[dotMonitor.localize("spells")] = dotMonitor.localize("Show spells being monitored")
	command[dotMonitor.localize("spells")] = function(self, arguments)
		self:PrintSpells(true)
		return self.localize("Spell Overview")
	end

	-- Command: Ignore Spell -------------------------------------------------------------
	info[dotMonitor.localize("ignore")] = dotMonitor.localize("Ignore a spell, stop monitoring it")
	command[dotMonitor.localize("ignore")] = function(self, arguments)
		if arguments then
			local playerDebuffs = self.player:GetDebuff()
			local targetDebuff 	= Spell:New(arguments)
			if playerDebuffs:ContainsObject(targetDebuff) then
				self.database.spells.ignored:AddObject(targetDebuff:ID())
				self:SyncToPlayer()
				self:LoadSpecSetup()
				self:ToggleHUD()
				self.terminal:Output(self.localize("Spell Overview"), "info")
				self:PrintSpells()
				return string.format(self.localize("Ignoring %s"), arguments)
			end
		end

		self.terminal:Output(self.localize("only the green may be ignored"), "warning")
		self:PrintSpells(false, true)
		return self.localize("Attempted to Ignore: ") .. (arguments or "[N/A]")
	end

	-- Command: Monitor Spell ------------------------------------------------------------
	info[dotMonitor.localize("monitor")] = dotMonitor.localize("Monitor a spell which isn't being monitored")
	command[dotMonitor.localize("monitor")] = function(self, arguments)
		if arguments then
			local targetDebuff = Spell:New(arguments)
			if self.database.spells.ignored:RemoveObject(targetDebuff:ID()) then
				self:SyncToPlayer()
				self:LoadSpecSetup()
				self:ToggleHUD()
				self.terminal:Output(self.localize("Spell Overview"), "info")
				self:PrintSpells()
				return string.format(self.localize("Monitoring %s"), arguments)
			end
		end

		self.terminal:Output(self.localize("only the gray may be monitored"), "warning")
		self:PrintSpells(false, true)
		return self.localize("Attempted to Monitor: ") .. (arguments or "[N/A]")
	end
	-- ===================================================================================




	-- ===================================================================================
	-- Global Settings Reset
	-- ===================================================================================
	-- Reset Command ---------------------------------------------------------------------
	info[dotMonitor.localize("reset")] = dotMonitor.localize("Resets the HUD")
	command[dotMonitor.localize("reset")] = function(self, arguments)
		return self:ResetHUD()
	end
	-- ===================================================================================


	-- Populate the terminal executables
	dotMonitor.terminal:SetExecutables(command, info)




	-- Event Listeners Setup
	dotMonitor.eventListener = EventManager:New(dotMonitor)

	-- Player In / Out of Combat
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:ToggleHUD()
	end), "PLAYER_REGEN_DISABLED")
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:ToggleHUD()
	end), "PLAYER_REGEN_ENABLED")


	-- Player Updates
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self.terminal.outputStream:Log("Spell Change:")
		self:SyncToPlayer(nil)
		self:LoadSpecSetup()
	end), "SPELLS_CHANGED")


	-- Restoration
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self.terminal.outputStream:Log("Player Entering World:")
		self:SyncToPlayer(Player:New()) -- Default player is "Player"
		self:LoadSpecSetup()
		self:PrintSpells(true)
		if self.enabled then
			self.terminal:Output(self.localize("ready"), "epic")
		else
			self:PrintFault()
			self.terminal:Output(self.localize("pending"), "epic")
		end
	end), "PLAYER_ENTERING_WORLD")

	-- Addon Load Setup
	dotMonitor.eventListener:AddActionForEvent((function(self, addon)
		if addon ~= "DOTMonitor" then return end
		-- Attempt to reload the database, otherwise the backup database passed in is used
		local database 	= {layout = {}, label = {}, spells = {}} -- Backup database
		self.database 	= Database:New(self.databaseID, "0.4.0", database)
		self.database.spells.ignored = TableSet:New(self.database.spells.ignored)
		self.manager 	= SpellMonitorManager:Restore(self.database, "DOTMonitor", self)
	end), "ADDON_LOADED")


	-- Saving
	dotMonitor.eventListener:AddActionForEvent((function(self, addon)
		self.manager:SaveTo(self.database)
		self.database:Serialize()
	end), "PLAYER_LOGOUT")

	return dotMonitor
end

-- The following line creates a new object of the DOTMonitor class,
-- and is where the DOTMonitor code will begin its execution.
-- The add-on claims the global identifier "DOTMonitor" as its own,
-- this is mainly for simplicity and extensibility, that is, in case
-- another add-on decides to call the methods or modify this add-on.
_G["DOTMonitor"] = DOTMonitor:New("DOTMonitorPreferences")