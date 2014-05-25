local Foundation 	= _G["MPXFoundation"]
local SpellMonitor 	= _G["MPXWOWKit_SpellMonitor"]
local Spell 		= _G["MPXWOWKit_Spell"]
local Player 		= _G["MPXWOWKit_Player"]

local DOTMonitor = {} -- Local Namespace
local debugging = true

function DOTMonitor:SyncToPlayer(player)
	self.console:Log("Syncing Player")
	self.player = player or self.player

	if not self.player then
		self.console:Log("No Player Found.")
	end

	self.player:Sync()
	self.enabled = self.player:HasSpec()
	self.console:Print("Adjusted for " .. tostring(self.player), "info")

	for i, aDebuffSpell in pairs(self.player:GetDebuff()) do
		self.console:Print("Tracking " .. tostring(aDebuffSpell))
		self.monitor[i] = self.monitor[i] or SpellMonitor:New(aDebuffSpell)
	end
end

function DOTMonitor:EnableMonitors(show)
	self:StopMonitors()
	self.console:Log((show and "Enabling" or "Disabling") .. " Monitors")
	for index, aMonitor in ipairs(self.monitor) do
		if index > #self.player:GetDebuff() then break end
		aMonitor:Monitor(show)
		aMonitor:Enable(show)
	end
end

function DOTMonitor:StopMonitors()
	for anIndex, aMonitor in ipairs(self.monitor) do
		aMonitor:Monitor(false)
		aMonitor:Enable(false)
	end
end

function DOTMonitor:StartMonitors()
	for anIndex, aMonitor in ipairs(self.monitor) do
		aMonitor:Enable(true)
	end
end

function DOTMonitor:HUDLock(lock)
	if lock ~= nil then
		self.locked = lock
		for i, aMonitor in ipairs(self.monitor) do
			aMonitor:Monitor(lock)
			aMonitor:Enable(not lock)
			aMonitor.icon:Draggable((not lock) and "LeftButton")
		end
	end

	return self.locked
end

function DOTMonitor:HUDRun(run)
	if self.enabled then
		local meetsShowCriteria = false
		if run then
			meetsShowCriteria = UnitExists("target") and (UnitIsEnemy("player", "target")
													  or  UnitCanAttack("player", "target"))
		end
		self:EnableMonitors(meetsShowCriteria)
	else
		self:EnableMonitors(false)
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
	HUDLock			= DOTMonitor.HUDLock,
	HUDRun			= DOTMonitor.HUDRun,
}

function DOTMonitor:New()
	local dotMonitor = {}
	setmetatable(dotMonitor, {__index = DOTMonitorDefault})

	dotMonitor.monitor = {} -- Monitor holder

	dotMonitor.terminal	= Foundation.Terminal:New(dotMonitor, "DOTMonitor", {"dotmonitor", "dmon"})
	dotMonitor.console 	= Foundation.Console:New("DOTMonitor")
	dotMonitor.terminal:SetOutputStream(dotMonitor.console)
	dotMonitor.console:EnableLog(debugging)

	local commands = {
		lock = function(self, arguments)
			self:HUDLock(true)
			return "HUD Locked"
		end,
		unlock = function(self, arguments)
			self:HUDLock(false)
			return "HUD Unlocked"
		end,
	}

	local info = {
		lock = "Locks the HUD",
		unlock = "Unlocks the HUD",
	}

	dotMonitor.terminal:SetExecutables(commands, info)


	dotMonitor.player = Player:New()

	dotMonitor.eventListener = Foundation.EventManager:New(dotMonitor)

	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:HUDRun(true)
	end), "PLAYER_REGEN_DISABLED")

	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:HUDRun(false)
	end), "PLAYER_REGEN_ENABLED")


	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:SyncToPlayer(nil)
	end), "PLAYER_LEVEL_UP")

	dotMonitor.eventListener:AddActionForEvent((function(self, ...)
		self:SyncToPlayer(nil) -- Default player is "Player"
		self.console:Print("Ready", "epic")
	end), "PLAYER_ENTERING_WORLD")

	return dotMonitor
end

_G["DOTMonitor"] = DOTMonitor:New()