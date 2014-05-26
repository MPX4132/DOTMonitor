--
-- SpellMonitorManager V0.1
-- Simple SpellMonitor management system for WOW
--

local SpellMonitor = _G["MPXWOWKit_SpellMonitor"]

local SpellMonitorManager = {} -- Local Namespace

function SpellMonitorManager:GetMonitor(anIndex)
	self:AssureMonitors(anIndex)
	return self.monitor[anIndex]
end

function SpellMonitorManager:AssureMonitors(aSize)
	if aSize and aSize >= 1 and #self.monitor < aSize then
		for anIndex = 1, aSize do
			self.monitor[anIndex] = self.monitor[anIndex] or SpellMonitor:New((self.ID .. "_SPELLMONITOR" .. anIndex))
		end
	end
	return self
end

function SpellMonitorManager:EnableMonitors(enable, count)

	local monitorsToEnable = count or #self.monitor

	for i, aMonitor in ipairs(self.monitor) do
		if i <= monitorsToEnable then
			aMonitor:Monitor(enable)
			aMonitor:Enable(enable)
		else
			aMonitor:Enable(false)
		end
	end
end

function SpellMonitorManager:EnableDragging(draggable)
	self:LockMonitors(not draggable)
end

function SpellMonitorManager:LockMonitors(lock)
	for i, aMonitor in ipairs(self.monitor) do
		aMonitor:Draggable((lock ~= nil and (not lock)) and "LeftButton")
	end
end

function SpellMonitorManager:Save(settings)
	settings["spellManagerSettings"] = {
		ID = self.ID,
		monitorCount = #self.monitor,
	}
	self:EnableDragging("LeftButton")
end

local SpellMonitorManagerDefault = {
	ID = "MPXWOWKit_SpellMonitorManager",
	monitor = {},
	GetMonitor		= SpellMonitorManager.GetMonitor,
	AssureMonitors 	= SpellMonitorManager.AssureMonitors,
	EnableMonitors	= SpellMonitorManager.EnableMonitors,
	EnableDragging	= SpellMonitorManager.EnableDragging,
	LockMonitors	= SpellMonitorManager.LockMonitors,
	Save			= SpellMonitorManager.Save,
}

function SpellMonitorManager:New(ID)
	local spellMonitorManager = {}
	setmetatable(spellMonitorManager, {__index = SpellMonitorManagerDefault})

	spellMonitorManager.ID = ID or spellMonitorManager.ID
	spellMonitorManager.monitor = {} -- Monitor List

	return spellMonitorManager
end

function SpellMonitorManager:Restore(settings, backupID)
	local preferences = settings and settings["spellManagerSettings"]
	local spellMonitorManager = self:New(settings and preferences.ID or backupID) -- Default ID
	return spellMonitorManager:AssureMonitors(settings and preferences.monitorCount)
end


MPXWOWKit_SpellMonitorManager = SpellMonitorManager