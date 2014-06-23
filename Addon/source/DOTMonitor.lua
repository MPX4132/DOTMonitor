-- ================================================================
-- Localization Database
-- ================================================================
local LocaleDatabase		= _G["DOTMonitorLocalization"]

-- ================================================================
-- Foundation
-- ================================================================
local Terminal				= _G["MPXFoundation_Terminal"]
local Localizer				= _G["MPXFoundation_Localizer"]
local EventManager			= _G["MPXFoundation_EventManager"]
local Database				= _G["MPXFoundation_Database"]

-- ================================================================
-- UIKit & WOWKit
-- ================================================================
local Spell 				= _G["MPXWOWKit_Spell"]
local SpellMonitor 			= _G["MPXWOWKit_SpellMonitor"]
local SpellMonitorManager 	= _G["MPXWOWKit_SpellMonitorManager"]
local Player 				= _G["MPXWOWKit_Player"]


local DOTMonitor = {} -- Local Namespace
local debugging  = false

function DOTMonitor:SyncToPlayer(player)
	self.terminal.outputStream:Log("Syncing Player")
	self.player = player or self.player

	self.enabled = self.player and self.player:HasSpec()

	if not self.enabled then
		if self.player then
			local msg = (self.player:Level() < 10 and self.localize("Player not ready due to low level"))
						   or (not self:HasSpec() and self.localize("Player not ready due to no spec"))
			self.terminal.outputStream:Print(msg, "warning")
		else
			self.terminal.outputStream:Log(self.localize("Player Unavailable!"))
		end
		return false
	end

	self.player:Sync()

	self.terminal.outputStream:Print(self.localize("Adjusted for") .. " " .. tostring(self.player), "info")
	for atIndex, aDebuff in ipairs(self.player:GetDebuff()) do
		local aMonitor = self.manager:GetMonitor(atIndex)
		self.terminal.outputStream:Print(self.localize("Tracking") .. " " .. aMonitor:TrackSpell(aDebuff))
	end
end

function DOTMonitor:Update(monitor, effectDuration, effectExpiration, effectCaster, cooldownStart, cooldownDuration, cooldownEnabled)
	local iconAlpha	= 1

	if effectCaster == "player" then
		iconAlpha = 1 - ((effectDuration ~= 0) and ((effectExpiration - GetTime()) / effectDuration) or 0)
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
	local count	 	= #self.player:GetDebuff()
	local padding 	= 80
	local start		= -(padding * (count - 1)) / 2
	for x = 1, count do
		position[x] = {x = start + (padding * (x-1)), y = f(x - (1+(count/2)) + 0.5)}
	end
	return position
end

function DOTMonitor:HUDRun(run)
	self.terminal.outputStream:Log("Attempting to change HUD")
	if self.enabled then
		self.terminal.outputStream:Log(run and "Running HUD" or "Stopping HUD")
		self.manager:EnableMonitors(run, #self.player:GetDebuff())
	else
		self.terminal.outputStream:Log("Unable to run HUD")
		self.manager:EnableMonitors(false)
	end
end

function DOTMonitor:SaveSpecSetup()
	if self.enabled then
		local spec = self.player:Spec()
		self.database.layout[spec] = self.database.layout[spec] or {}

		for anIndex, aMonitor in ipairs(self.manager.monitor) do
			local iconX, iconY = aMonitor.icon:GetCenterRelativeToPoint("CENTER")
			self.database.layout[spec][anIndex] = {x = iconX, y = iconY}
		end
	end
end

function DOTMonitor:LoadSpecSetup()
	if self.enabled then
		local spec = self.player:Spec()
		for i, position in ipairs(self.database.layout[spec] or self:HUDAutoLayout()) do
			local monitor = self.manager.monitor[i]
			if monitor then
				monitor.icon:SetCenter(position.x, position.y)
			end
		end

		self.manager:ShowEffectTimers(self.database.label.timers or false)
		self.manager:ShowCooldownTimers(self.database.label.cooldowns or false)
	end
end

function DOTMonitor:ResetHUD()
	if self.enabled then
		self.database.layout[self.player:Spec()] = nil
		self.database.label = {} -- clear it
		self:LoadSpecSetup()
		return self.localize("HUD Reset!")
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
	Update			= DOTMonitor.Update,
	HUDAutoLayout	= DOTMonitor.HUDAutoLayout,
	EnableMonitors 	= DOTMonitor.EnableMonitors,
	StopMonitors 	= DOTMonitor.StopMonitors,
	StartMonitors 	= DOTMonitor.StartMonitors,
	HUDRun			= DOTMonitor.HUDRun,
	SaveSpecSetup	= DOTMonitor.SaveSpecSetup,
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


	-- Terminal Setup
	local commands = {
		[dotMonitor.localize("lock")] = function(self, arguments)
			self.manager:LockMonitors(true) -- Want to lock everything
			self:SaveSpecSetup()
			return self.localize("HUD Locked")
		end,
		[dotMonitor.localize("unlock")] = function(self, arguments)
			self.manager:LockMonitors(false, #self.player:GetDebuff())
			return self.localize("HUD Unlocked")
		end,
		[dotMonitor.localize("show")] = function(self, arguments)
			if arguments == self.localize("cooldowns") then
				self.manager:ShowCooldownTimers(true)
				self.database.label.cooldowns = true
				return self.localize("Cooldowns now visible")
			elseif arguments == self.localize("timers") then
				self.manager:ShowEffectTimers(true)
				self.database.label.timers = true
				return self.localize("Timers now visible")
			end
			return self.localize("Usage: show (cooldowns | timers)")
		end,
		[dotMonitor.localize("hide")] = function(self, arguments)
			if arguments == self.localize("cooldowns") then
				self.manager:ShowCooldownTimers(false)
				self.database.label.cooldowns = nil
				return self.localize("Cooldowns now hidden")
			elseif arguments == self.localize("timers") then
				self.manager:ShowEffectTimers(false)
				self.database.label.timers = nil
				return self.localize("Timers now hidden")
			end
			return self.localize("Usage: hide (cooldowns | timers)")
		end,
		[dotMonitor.localize("reset")] = function(self, arguments)
			return self:ResetHUD()
		end,
	}

	local info = {
		[dotMonitor.localize("lock")] 	= dotMonitor.localize("Locks the monitor icons"),
		[dotMonitor.localize("unlock")] 	= dotMonitor.localize("Unlocks the monitor icons"),
		[dotMonitor.localize("show")] 	= dotMonitor.localize("Show either cooldowns or timers"),
		[dotMonitor.localize("hide")]		= dotMonitor.localize("Hide either cooldowns or timers"),
		[dotMonitor.localize("reset")]	= dotMonitor.localize("Resets the HUD"),
	}

	dotMonitor.terminal:SetExecutables(commands, info)


	-- Player In / Out of Combat
	dotMonitor.eventListener = EventManager:New(dotMonitor)
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:HUDRun(true)
	end), "PLAYER_REGEN_DISABLED")
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:HUDRun(false)
	end), "PLAYER_REGEN_ENABLED")


	-- Player Updates
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:SyncToPlayer(nil)
		self:LoadSpecSetup()
	end), "PLAYER_LEVEL_UP")
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:SyncToPlayer(nil)
		self:LoadSpecSetup()
	end), "PLAYER_TALENT_UPDATE")
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self.manager:LockMonitors(true) -- Want to lock everything
		self:SyncToPlayer(nil)
		self:LoadSpecSetup()
	end), "ACTIVE_TALENT_GROUP_CHANGED")


	-- Restoration
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:SyncToPlayer(Player:New()) -- Default player is "Player"
		self:LoadSpecSetup()
		self.terminal.outputStream:Print(self.enabled and self.localize("Ready") or self.localize("Pending"), "epic")
	end), "PLAYER_ENTERING_WORLD")
	dotMonitor.eventListener:AddActionForEvent((function(self, addon)
		if addon ~= "DOTMonitor" then return end
		-- Attempt to reload the database, otherwise the backup database passed in is used
		self.database 	= Database:New(self.databaseID, "0.2.2", {layout = {}, label = {}})
		self.manager 	= SpellMonitorManager:Restore(self.database, "DOTMonitor", self)
	end), "ADDON_LOADED")


	-- Saving
	dotMonitor.eventListener:AddActionForEvent((function(self, addon)
		self.manager:SaveTo(self.database)
		self.database:Serialize()
	end), "PLAYER_LOGOUT")

	return dotMonitor
end

_G["DOTMonitor"] = DOTMonitor:New("DOTMonitorPreferences")