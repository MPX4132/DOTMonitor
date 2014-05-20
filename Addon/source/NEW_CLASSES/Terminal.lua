-- Global Player Class
MPX_Class = _G["MPX_Class"] or {};
local MPX = MPX_Class;

-- Allocation & Local Reference
MPX.Terminal = {debug = true};
local Terminal = MPX.Terminal;


--SLASH_DOTMonitor_COMMAND1, SLASH_DOTMonitor_COMMAND2 = "/dotmonitor", "/dmon"

-- ///////////////////////////////////////////////////////////////////////////////////////
-- Print Functions
-- printMessage( messageText [, (red, green, blue | info | epic)]) -> prints messageText to DEFAULT_CHAT_FRAME
function Terminal:Print(aMessage, ...)
	local colorScheme = {
		["none"] 	= {r = 0,	g = 1,	b = 1},
		["info"] 	= {r = 0,	g = 1,	b = 1},
		["epic"] 	= {r = .8,	g = .2,	b = 1},
		["alert"] 	= {r = 1,	g = 0,	b = 0},
		["custom"] 	= {r = 1,	g = 1,	b = 1}
	}
	local colorType = "info";
	local addonID 	= self.addonID;

	if (...) then
		local r, g, b = ...
		if type(r) == "number" and type(g) == "number" and type(b) == "number" then
			colorType = "custom";
			colorScheme[colorType] 	= {r=r,g=g,b=b};
		elseif type(r) == "string" then
			colorType = r
		end
	end

	local color 	= colorScheme[colorType]
	local output 	= (type((select(1,...))) == "string") and ("\["..addonID.." "..aMessage.."\]") or ("\["..addonID.."\] "..aMessage);

	DEFAULT_CHAT_FRAME:AddMessage(output, color.r, color.g, color.b);
end

function Terminal:Log(aMessage)
	if self.debug then
		DEFAULT_CHAT_FRAME:AddMessage("\["..self.addonID.." DEBUG\] "..aMessage, 1, 0, 0);
	end
end
-- ///////////////////////////////////////////////////////////////////////////////////////


function Terminal:ClearInvokeCommands()
	for k, v in pairs(self.invokeCommand) do
		self.invokeCommand[k] = nil;
	end
end

function Terminal:RegisterInvokeCommands()
	for pos, cmd in ipairs(self.invokeCommand) do
		_G["SLASH_"..self.addonID.."_COMMAND"..pos] = ("/"..cmd);
	end
end

function Terminal:InvokeCommand(command)
	self:ClearInvokeCommands();
	if type(command) == "table" then
		-- Adding multiple invocation commands
		for pos, cmd in ipairs(command) do
			table.insert(self.invokeCommand, cmd);
		end
		self:RegisterInvokeCommands();
	elseif type(command) == "string" then
		_G["SLASH_"..self.addonID.."_COMMAND1"] = ("/"..command);
	end
end

function Terminal:GetCommandHelp(command)
	self:Print("=============================================");
	self:Print("|  The following directives are recognized  |");
	self:Print("=============================================");
	for directive, executable in pairs(self.executable) do
		self:Print(directive.." -> "..self.executableHelp[directive]);
	end
	self:Print("=============================================");
	self:Print(("\"" .. (select(1, self:GetDirective(command))).."\" is an invalid directive.") or "\[Invalid Directive\]");
end

function Terminal:SetExecutables(executables, directiveHelp)
	self.executable, self.executableHelp = {}, {};
	for directive, executable in pairs(executables) do
		self.executable[directive] = executable;
		self.executableHelp[directive] = directiveHelp[directive] or "\[No Documentation\]";
	end
end

function Terminal:HasDirective(directive)
	--[[
	for pos, cmd in pairs(self.executable) do
		if cmd == directive then
			return true;
		end
	end
	return false;]]
	return (type(self.executable[directive]) ~= nil);
end

function Terminal:CanExecute(directive)
	return (type(self.executable[directive]) == "function");
end

function Terminal:GetDirective(command)
	local dirEnd, argStart = command:find(" ");
	if dirEnd then
		return command:sub(1, dirEnd-1), command:sub(argStart+1);
	else
		return command, nil;
	end
end

function Terminal:Execute(command)
	local directive, arguments = self:GetDirective(command);
	local result = nil;

	if self:CanExecute(directive) then
		result = self.executable[directive](arguments);
		self:Log("Called: " .. directive .. "(" .. (arguments or "nil") .. ")");
	else
		result = self:GetCommandHelp(command);
	end

	self:Log(result or "\[Success!\]", "info");
end

function Terminal:New(addonID)
	local terminal = {
		["Print"]	= self.Print,
		["Log"]		= self.Log,
		["ClearInvokeCommands"] = self.ClearInvokeCommands,
		["RegisterInvokeCommands"] = self.RegisterInvokeCommands,
		["InvokeCommand"] 	= self.InvokeCommand,
		["GetCommandHelp"] 	= self.GetCommandHelp,
		["SetExecutables"] 	= self.SetExecutables,
		["HasDirective"]	= self.HasDirective,
		["CanExecute"]		= self.CanExecute,
		["GetDirective"]	= self.GetDirective,
		["Execute"]	= self.Execute
	}
	terminal.debug 		= true;
	terminal.addonID 	= addonID;
	terminal.invokeCommand = {};

	SlashCmdList[addonID .. "_COMMAND"] = (function(aCommand, origin)
		terminal:Execute(aCommand);
	end)

	return terminal;
end