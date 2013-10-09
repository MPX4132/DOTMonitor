SLASH_DOTMonitor_COMMAND1, SLASH_DOTMonitor_COMMAND2 = "/dotmonitor", "/dmon"

local DOTMonitor = getglobal("DOTMonitor") or {}
--DOTMonitor.logMessage 	= function(aMessage)
--DOTMonitor.printMessage 	= function(aMessage, ...)




-- @ Terminal Functions Implementation
-- ================================================================================
local DOTMonitorCommand_setDraggable = (function(canMove)
	local shouldMove = (canMove == "on") or (canMove == "yes")
	DOTMonitor.HUD:SetMovable(shouldMove)
	return "HUD Now "..(shouldMove and "Unlocked" or "Locked")
end)




-- @ Terminal Methods Implementation
-- ================================================================================
DOTMonitorTerminal 			= {} 	-- Main
DOTMonitorTerminal.command 	= nil 	-- The Command
DOTMonitorTerminal.executables = {
	["drag"] = DOTMonitorCommand_setDraggable
}

DOTMonitorTerminal.HasValidCommand = (function(self)
	return (string.len(self.command) >= 4)
end)

DOTMonitorTerminal.GetCommand = (function(self)
	return self:HasValidCommand() and string.sub(self.command, 1, 4) or false
end)

DOTMonitorTerminal.HasFunction = (function(self, aFunction)
	return (type(self.executables[aFunction]) == "function")
end)

DOTMonitorTerminal.HasArguments = (function(self)
	return (string.len(self.command) >= 6)
end)

DOTMonitorTerminal.GetArguments = (function(self)
	return (self:HasArguments() and string.sub(self.command, 6)) or nil
end)


DOTMonitorTerminal.Execute = (function(self, aCommand)
	DOTMonitorTerminal.command = aCommand;
	local aFunction 	= DOTMonitorTerminal:GetCommand()
	local result		= "Invalid Command Given"
	local executable 	= DOTMonitorTerminal:HasFunction(aFunction)
	
	if executable then
		result = self.executables[aFunction](self:GetArguments())
		DOTMonitor.logMessage("Called: "..aFunction.."("..(self:HasArguments() and self:GetArguments() or "")..")")
	end
	
	DOTMonitor.printMessage(result, executable and "info" or "alert")
end)



-- Registration:
SlashCmdList["DOTMonitor_COMMAND"] = (function(aCommand, origin)
	DOTMonitorTerminal:Execute(aCommand);
end)