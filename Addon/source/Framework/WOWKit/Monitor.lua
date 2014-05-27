-- =======================================================================================
--	Monitor 0.1V
--	Simple monitoring class for the World of Warcraft environment.
-- =======================================================================================

local Monitor = {} -- Local Namespace

function Monitor:SetCondition(aCondition)
	assert(type(aCondition) == "function")
	self.RunCondition = aCondition
end

function Monitor:CanMonitor()
	return self.icon and self:RunCondition()
end

function Monitor:SetLogic(logic)
	assert(type(logic) == "function")
	self.logic = logic
end

function Monitor:SetIcon(icon)

end

local MonitorDefault = {
	SetCondition 	= Monitor.SetCondition,
	CanMonitor		= Monitor.CanMonitor,
	RunCondition 	= (function(self) return false end),
	SetIcon			= Monitor.SetIcon,
}

function Monitor:New(delegate, icon)
	local monitor = {}
	setmetatable(monitor, MonitorDefault)

	return monitor
end

MPXWOWKit_Monitor = Monitor