-- =======================================================================================
-- EventManager V0.1
-- Simple target-action event manager for WOW
-- =======================================================================================

local EventManager = {} -- Local Namespace

function EventManager:AddActionForEvent(action, event)
	if EventManager:IsValidAction(action) and EventManager:IsValidEvent(event) then
		table.insert(self.events[self:AssureEventQueue(event)], action)
	end
end

function EventManager:IsValidAction(action)
	return type(action) == "function"
end

function EventManager:IsValidEvent(event)
	return type(event) == "string"
end

function EventManager:AssureEventQueue(event)
	if not self.events[event] then
		self.updater:RegisterEvent(event)
		self.events[event] = {} -- New event queue
	end
	return event
end

function EventManager:Callback(event, ...)
	for x, action in ipairs(self.events[event] or {}) do
		action(self.delegate, ...)
	end
end

function EventManager:Enable(enabled)
	self.updater[enabled and "Show" or "Hide"](self.updater)
end

function EventManager:UpdaterMake(delegate)
	local updater = CreateFrame("Frame")

	updater:EnableJoystick(false)
	updater:EnableKeyboard(false)
	updater:EnableMouse(false)
	updater:EnableMouseWheel(false)
	updater:SetAlpha(0)

	updater.delegate = delegate

	return updater
end

local EventManagerDefault = {
	updater 	= nil,
	delegate 	= nil,
	events 		= nil,
	AddActionForEvent 	= EventManager.AddActionForEvent,
	--IsValidAction		= EventManager.IsValidAction,			-- Static
	--IsValidEvent		= EventManager.IsValidEvent,			-- Static
	AssureEventQueue	= EventManager.AssureEventQueue,
	Callback			= EventManager.Callback,
	Enable				= EventManager.Enable
}

function EventManager:New(delegate)
	local eventManager = {}
	setmetatable(eventManager, {__index = EventManagerDefault})

	eventManager.delegate 	= delegate
	eventManager.updater 	= self:UpdaterMake(eventManager)
	eventManager.events 	= {}	-- Main Event Queue

	eventManager.updater:SetScript("OnEvent", (function(self, event, ...)
		self.delegate:Callback(event, ...)
	end))

	return eventManager
end


MPXFoundation_EventManager = EventManager -- Global Registration