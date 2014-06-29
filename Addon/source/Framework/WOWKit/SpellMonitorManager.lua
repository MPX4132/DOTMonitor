-- =======================================================================================
-- SpellMonitorManager V0.2
-- Simple SpellMonitor management system for WOW
-- =======================================================================================

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
	self:SetDelegate() -- Assure delegate
	return self
end

function SpellMonitorManager:AllMonitors()
	return self.monitor
end

function SpellMonitorManager:AllSpells()
	local allSpells = {}
	for i, aMonitor in ipairs(self.monitor) do
		if aMonitor:GetSpell() then
			table.insert(allSpells, aMonitor:GetSpell())
		end
	end
	return allSpells
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
		aMonitor:DigitalMeter(show)
	end
end

function SpellMonitorManager:ShowCooldownTimers(show)
	for i, aMonitor in ipairs(self.monitor) do
		aMonitor:DigitalCooldown(show)
	end
end

function SpellMonitorManager:SetDelegate(delegate)
	self.delegate = delegate or self.delegate
	for i, aMonitor in ipairs(self.delegate and self.monitor or {}) do
		aMonitor:AddDelegateForUpdate(self.delegate)
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
	AllMonitors		= SpellMonitorManager.AllMonitors,
	AllSpells		= SpellMonitorManager.AllSpells,
	EnableMonitors	= SpellMonitorManager.EnableMonitors,
	LockMonitors	= SpellMonitorManager.LockMonitors,
	ShowEffectTimers = SpellMonitorManager.ShowEffectTimers,
	ShowCooldownTimers = SpellMonitorManager.ShowCooldownTimers,
	SetDelegate		= SpellMonitorManager.SetDelegate,
	SaveTo			= SpellMonitorManager.SaveTo,
}

function SpellMonitorManager:New(ID, delegate)
	local spellMonitorManager = {}
	setmetatable(spellMonitorManager, {__index = SpellMonitorManagerDefault})

	spellMonitorManager.ID 			= ID or spellMonitorManager.ID
	spellMonitorManager.delegate 	= delegate
	spellMonitorManager.monitor 	= {} -- Monitor List

	return spellMonitorManager
end

function SpellMonitorManager:Restore(database, backupID, delegate)
	local preferences = database and database.manager
	local spellMonitorManager = self:New((preferences and preferences.ID or backupID), delegate) -- Default ID
	return spellMonitorManager:AssureMonitors(preferences and preferences.monitorCount)
end


MPXWOWKit_SpellMonitorManager = SpellMonitorManager