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
			aMonitor:Update(enable)
			aMonitor[(enable and "Show" or "Hide")](aMonitor)
		else
			aMonitor:Hide()
		end
	end
end

function SpellMonitorManager:LockMonitors(lock, count)
	for i, aMonitor in ipairs(self.monitor) do
		if count and i > count then break end
		aMonitor:Draggable((lock ~= nil and (not lock)) and "LeftButton")
	end
end

function SpellMonitorManager:ShowEffectTimers(show)
	for i, aMonitor in ipairs(self.monitor) do
		local timer = aMonitor.icon.digitalMeter
		timer[(show and "Show" or "Hide")](timer)
	end
end

function SpellMonitorManager:ShowCooldownTimers(show)
	for i, aMonitor in ipairs(self.monitor) do
		local timer = aMonitor.icon.digitalCooldown
		timer[(show and "Show" or "Hide")](timer)
	end
end

function SpellMonitorManager:SetDelegate(delegate)
	for i, aMonitor in ipairs(self.monitor) do
		aMonitor:AddDelegateForUpdate(delegate)
	end
end

function SpellMonitorManager:SaveTo(database)
	database.manager = {
		ID = self.ID,
		monitorCount = #self.monitor,
	}

	for i, aMonitor in ipairs(self.monitor) do
		aMonitor:Update(false)
		aMonitor:Show()
		aMonitor.icon:SetMovable(true)
		aMonitor.icon:SetUserPlaced(true)
	end
end

local SpellMonitorManagerDefault = {
	ID = "MPXWOWKit_SpellMonitorManager",
	monitor = {},
	GetMonitor		= SpellMonitorManager.GetMonitor,
	AssureMonitors 	= SpellMonitorManager.AssureMonitors,
	EnableMonitors	= SpellMonitorManager.EnableMonitors,
	LockMonitors	= SpellMonitorManager.LockMonitors,
	ShowEffectTimers = SpellMonitorManager.ShowEffectTimers,
	ShowCooldownTimers = SpellMonitorManager.ShowCooldownTimers,
	SetDelegate		= SpellMonitorManager.SetDelegate,
	SaveTo			= SpellMonitorManager.SaveTo,
}

function SpellMonitorManager:New(ID)
	local spellMonitorManager = {}
	setmetatable(spellMonitorManager, {__index = SpellMonitorManagerDefault})

	spellMonitorManager.ID = ID or spellMonitorManager.ID
	spellMonitorManager.monitor = {} -- Monitor List

	return spellMonitorManager
end

function SpellMonitorManager:Restore(database, backupID)
	local preferences = database and database.manager
	local spellMonitorManager = self:New(preferences and preferences.ID or backupID) -- Default ID
	return spellMonitorManager:AssureMonitors(preferences and preferences.monitorCount)
end


MPXWOWKit_SpellMonitorManager = SpellMonitorManager