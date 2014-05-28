local Foundation 			= _G["MPXFoundation"]
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
		local reason = (((self.player:Level() < 10) and "low level") or (not self:HasSpec() and "no spec") or "not loaded")
		self.terminal.outputStream:Print("Player not ready due to " .. reason)
		return false
	end

	self.player:Sync()

	self.terminal.outputStream:Print("Adjusted for " .. tostring(self.player), "info")
	for atIndex, aDebuff in ipairs(self.player:GetDebuff()) do
		local aMonitor = self.manager:GetMonitor(atIndex)
		self.terminal.outputStream:Print("Tracking " .. aMonitor:TrackSpell(aDebuff))
	end
end

function DOTMonitor:SetShowCondition(condition)
	if type(condition) == "function" then
		self.ShowCondition = condition
	end
end

function DOTMonitor:ShowCondition() -- Default show condition
	return UnitExists("target") and (UnitIsEnemy("player", "target")
								or   UnitCanAttack("player", "target"))
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
	self.terminal.outputStream:Log("Attempting to run HUD")
	if self.enabled then
		self.terminal.outputStream:Log("Running HUD")
		self.manager:EnableMonitors(meetsShowCriteria, #self.player:GetDebuff())
		self.manager:EnableMonitors(run and self:ShowCondition() or false, #self.player:GetDebuff())
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
			local icon = self.manager.monitor[i].icon
			if icon then
				icon:SetCenter(position.x, position.y)
			end
		end
	end
end

function DOTMonitor:ResetHUD()
	if self.enabled then
		self.database.layout[self.player:Spec()] = nil
		self:LoadSpecSetup()
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
	SetShowCondition = DOTMonitor.SetShowCondition,
	ShowCondition	= DOTMonitor.ShowCondition,
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

	-- Terminal and Console instantiation
	dotMonitor.terminal	= Foundation.Terminal:New(dotMonitor, "DOTMonitor", {"dotmonitor", "dmon"})
	dotMonitor.terminal.outputStream:EnableLog(debugging)


	-- Terminal Setup
	local commands = {
		lock = function(self, arguments)
			self.manager:LockMonitors(true) -- Want to lock everything
			self:SaveSpecSetup()
			return "HUD Locked"
		end,
		unlock = function(self, arguments)
			self.manager:LockMonitors(false, #self.player:GetDebuff())
			return "HUD Unlocked"
		end,
		reset = function(self, arguments)
			return self:ResetHUD()
		end,
	}

	local info = {
		lock 	= "Locks the monitor icons",
		unlock 	= "Unlocks the monitor icons",
		reset	= "Resets DOTMonitor's HUD",
	}

	dotMonitor.terminal:SetExecutables(commands, info)


	-- Player In / Out of Combat
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
		self.manager:LockMonitors(true) -- Want to lock everything
		self:SyncToPlayer(nil)
		self:LoadSpecSetup()
	end), "ACTIVE_TALENT_GROUP_CHANGED")


	-- Restoration
	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:SyncToPlayer(Player:New()) -- Default player is "Player"
		self:LoadSpecSetup()
		self.terminal.outputStream:Print(self.enabled and "Ready" or "Pending", "epic")
	end), "PLAYER_ENTERING_WORLD")
	dotMonitor.eventListener:AddActionForEvent((function(self, addon)
		if addon ~= "DOTMonitor" then return end
		-- Attempt to reload the database, otherwise the backup database passed in is used
		self.database 	= Foundation.Database:New(self.databaseID, {layout = {}})
		self.manager 	= SpellMonitorManager:Restore(self.database, "DOTMonitor")
	end), "ADDON_LOADED")


	-- Saving
	dotMonitor.eventListener:AddActionForEvent((function(self, addon)
		self.manager:SaveTo(self.database)
		self.database:Serialize()
	end), "PLAYER_LOGOUT")

	return dotMonitor
end

_G["DOTMonitor"] = DOTMonitor:New("DOTMonitorPreferences")