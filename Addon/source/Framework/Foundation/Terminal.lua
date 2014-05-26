--
-- Terminal V0.1
-- Simple I/O terminal for WOW
--

local Terminal = {} -- Local Namespace

function Terminal:RegisterInvoker(...)
	self.invokers = ...
	for i, invoker in ipairs(self.invokers) do
		_G["SLASH_" .. self.name .. "_COMMAND" .. i] = "/" .. invoker
	end

	SlashCmdList[self.name .. "_COMMAND"] = (function(aCommand, aSource)
		self:Output(self:Execute(aCommand))
	end)
end

function Terminal:SetOutputStream(os)
	self.outputStream = os
end

function Terminal:Output(aMessage, ...)
	if type(self.outputStream) ~= "nil" then
		self.outputStream:AddMessage(aMessage, ...)
	else
		DEFAULT_CHAT_FRAME:AddMessage(aMessage)
	end
end

function Terminal:SetExecutables(executables, descriptors)
	for aKey, aFunction in pairs(executables) do
		self.executables[aKey] = aFunction
		self.descriptors[aKey] = descriptors[aKey] or "No Help Info."
	end
end

function Terminal:ParseCommand(aCommand)
	local first, last = aCommand:find(" ");

	if type(first) ~= "nil" then
		return aCommand:sub(0, first-1), aCommand:sub(first+1)
	end

	return aCommand, nil
end

function Terminal:HasDirective(aCommand)
	return type(self.executables[aCommand]) == "function"
end

function Terminal:Commands()
	local available = {}
	for command, v in pairs(self.executables) do
		table.insert(available, command)
	end
	return available
end

function Terminal:CommandsInfo()
	--self:Output("\n\n")
   	self:Output("Command Set", "info")
	for aCommand, aMessage in pairs(self.descriptors) do
		self:Output(aCommand .. " -> " .. aMessage)
	end
	return #self:Commands() .. " Commands Available"
end

function Terminal:Execute(aCommand)
	local command, arguments = Terminal:ParseCommand(aCommand:trim())

	self.result = self:HasDirective(command) and self.executables[command](self.delegate, arguments) or self:CommandsInfo()

	return self.result;
end

function Terminal:SetDelegate(delegate)
	self.delegate = delegate
end

local TerminalDefault = {
	delegate = nil,
	name = "terminal",
	invokers = {},
	outputStream = nil,
	executables = {},
	descriptors = {},
	result = nil,
	RegisterInvoker = Terminal.RegisterInvoker,
	SetOutputStream	= Terminal.SetOutputStream,
	Output			= Terminal.Output,
	SetExecutables	= Terminal.SetExecutables,
	ParseCommand 	= Terminal.ParseCommand,
	HasDirective 	= Terminal.HasDirective,
	Commands		= Terminal.Commands,
	CommandsInfo 	= Terminal.CommandsInfo,
	Execute 		= Terminal.Execute,
	SetDelegate 	= Terminal.SetDelegate,
}

function Terminal:New(delegate, name, ...)
	local terminal = {}
	setmetatable(terminal, {__index = TerminalDefault})

	terminal.delegate = delegate
	terminal.name = name
	terminal:RegisterInvoker(...)
	return terminal
end

MPXFoundation_Terminal = Terminal -- Global Registration