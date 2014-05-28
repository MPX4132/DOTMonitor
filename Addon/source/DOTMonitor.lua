local Foundation 			= _G["MPXFoundation"]
local Spell 				= _G["MPXWOWKit_Spell"]
local SpellMonitor 			= _G["MPXWOWKit_SpellMonitor"]
local SpellMonitorManager 	= _G["MPXWOWKit_SpellMonitorManager"]
local Player 				= _G["MPXWOWKit_Player"]


local DOTMonitor = {} -- Local Namespace
local debugging  = false

function DOTMonitor:SyncToPlayer(player)
	self.console:Log("Syncing Player")
	self.player = player or self.player

	self.enabled = self.player and self.player:HasSpec()

	if not self.enabled then
		local reason = (self.player:Level() < 10) and "low level" or (not self:HasSpec() and "no spec") or "not loaded"
		self.console:Print("Player not ready due to " .. reason)
		return false
	end

	self.player:Sync()

	self.console:Print("Adjusted for " .. tostring(self.player), "info")
	for atIndex, aDebuff in ipairs(self.player:GetDebuff()) do
		local aMonitor = self.manager:GetMonitor(atIndex)
		self.console:Print("Tracking " .. aMonitor:TrackSpell(aDebuff))
	end
end

function DOTMonitor:HUDRun(run)
	if self.enabled then
		local meetsShowCriteria = false
		if run then
			meetsShowCriteria = UnitExists("target") and (UnitIsEnemy("player", "target")
													  or  UnitCanAttack("player", "target"))
		end
		self.manager:EnableMonitors(meetsShowCriteria, #self.player:GetDebuff())
	else
		self.manager:EnableMonitors(false)
	end
end

function DOTMonitor:SaveSpecSetup()
	if self.enabled then
		local spec = self.player:Spec()
		self.database.layout[spec] = self.database.layout[spec] or {}

		for anIndex, aMonitor in ipairs(self.manager.monitor) do
			local iconX, iconY = aMonitor.icon:GetCenter()
			self.database.layout[spec][anIndex] = {x = iconX, y = iconY}
		end
	end
end

function DOTMonitor:LoadSpecSetup()
	if self.enabled then
		local spec = self.player:Spec()
--		local monitorsToPosition = #self.manager.monitor > self.preferences
		for i, position in ipairs(self.database.layout[spec] or {}) do
			local icon = self.manager.monitor[i].icon
			if icon then
				icon:SetPoint("CENTER", icon:GetParent(), "BOTTOMLEFT", position.x, position.y)
			end
		end
	end
end

function DOTMonitor:ResetHUD()
	if self.enabled then
		for atIndex, aDebuff in ipairs(self.player:GetDebuff()) do
			local aMonitor = self.manager:GetMonitor(atIndex)
			aMonitor.icon:SetPoint("CENTER", 0, 0)
--			self.console:Print("Tracking " .. aMonitor:TrackSpell(aDebuff))
		end
		return "HUD Reset!"
	else
		return "HUD is disabled!"
	end
end

local DOTMonitorDefault = {
	player 	= nil,
	monitor = nil,
	locked 	= true,
	enabled = false,
	SyncToPlayer 	= DOTMonitor.SyncToPlayer,
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


	dotMonitor.terminal	= Foundation.Terminal:New(dotMonitor, "DOTMonitor", {"dotmonitor", "dmon"})
	dotMonitor.console 	= Foundation.Console:New("DOTMonitor")
	dotMonitor.terminal:SetOutputStream(dotMonitor.console)
	dotMonitor.console:EnableLog(debugging)

	local commands = {
		lock = function(self, arguments)
			self.manager:LockMonitors(true)
			self:SaveSpecSetup()
			return "HUD Locked"
		end,
		unlock = function(self, arguments)
			self.manager:LockMonitors(false)
			return "HUD Unlocked"
		end,
		reset = function(self, arguments)
			return self:ResetHUD()
		end,
		reload = function(self, arguments)
			return "Done Loading"
		end
	}

	local info = {
		lock 	= "Locks the monitor icons",
		unlock 	= "Unlocks the monitor icons",
		reset	= "Resets DOTMonitor's HUD",
	}

	dotMonitor.terminal:SetExecutables(commands, info)


	dotMonitor.eventListener = Foundation.EventManager:New(dotMonitor)
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:HUDRun(true)
	end), "PLAYER_REGEN_DISABLED")
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:HUDRun(false)
	end), "PLAYER_REGEN_ENABLED")


	-- Player Updates
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:SyncToPlayer(nil)
	end), "PLAYER_LEVEL_UP")
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:SyncToPlayer(nil)
		self:LoadSpecSetup()
	end), "ACTIVE_TALENT_GROUP_CHANGED")


	-- Restoration
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:SyncToPlayer(Player:New()) -- Default player is "Player"
		--self:LoadSpecSetup()
		self.console:Print(self.enabled and "Ready" or "Pending", "epic")
	end), "PLAYER_ENTERING_WORLD")
	dotMonitor.eventListener:AddActionForEvent((function(self, addon)
		if addon ~= "DOTMonitor" then return end
		--local preferences = _G["DOTMonitorPreferences"]
		self.database = Foundation.Database:New(self.databaseID, {layout = {}})
		self.manager = SpellMonitorManager:Restore(self.database, "DOTMonitor")
	end), "ADDON_LOADED")


	-- Saving
	dotMonitor.eventListener:AddActionForEvent((function(self, addon)
		self.manager:SaveTo(self.database)
		self.database:Save()
	end), "PLAYER_LOGOUT")

	return dotMonitor
end

_G["DOTMonitor"] = DOTMonitor:New("DOTMonitorPreferences")