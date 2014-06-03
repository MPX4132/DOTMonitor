-- =======================================================================================
-- Console V0.1
-- Simple standard logging and output console for WOW
-- =======================================================================================

local Console = {} -- Local Namespace

function Console:ParseColor(...)
	local colorType = "info";

	if ... then
		local r, g, b = ...
		if type(r) == "number" and type(g) == "number" and type(b) == "number" then
			colorType = "custom";
			self.colorScheme[colorType] = {r = r, g = g, b = b};
		elseif type(r) == "string" then
			colorType = r
		end
	end

	return self.colorScheme[colorType]
end

function Console:Print(aMessage, ...)
	local color = self:ParseColor(...)
	-- type(...) selects the first element and gets its type
	local output = string.format((type(... or false) == "string") and "[%s %s]" or "[%s] %s", self.identifier, aMessage)
	self.outputStream:AddMessage(output, color.r, color.g, color.b)
end

function Console:AddMessage(aMessage, ...)
	self:Print(aMessage, ...)
end

function Console:Log(aMessage)
	if not self.logging then return end
	local d = date("*t")
	local time = string.format("%02d:%02d:%02d", d.hour, d.min, d.sec)
	local log = string.format("[ LOG (%s) | %s] %s", time, self.identifier, aMessage)
	self.outputStream:AddMessage(log, 1, 0, 0)
	--self.outputStream:AddMessage("[ LOG | "..self.identifier.." ("..GetTime()..")] "..aMessage, 1, 0, 0)
end

function Console:EnableLog(show)
	if type(show) == "boolean" then
		self.logging = show
	end
end

function Console:SetOutputStream(outputStream)
	if type(outputStream) == "table" and type(outputStream["AddMessage"]) == "function" then
		self.outputStream = outputStream
	end
end

local ConsoleDefault = {
	outputStream 	= DEFAULT_CHAT_FRAME,
	logging 		= false,
	colorScheme = {
		["none"] 	= {r = 0,	g = 1,	b = 1},
		["info"] 	= {r = 0,	g = 1,	b = 1},	-- This one is required
		["epic"] 	= {r = .8,	g = .2,	b = 1},
		["alert"] 	= {r = 1,	g = 0,	b = 0},
		["custom"] 	= {r = 1,	g = 1,	b = 1}
	},
	ParseColor 		= Console.ParseColor,
	Print			= Console.Print,
	AddMessage		= Console.AddMessage,
	Log				= Console.Log,
	EnableLog		= Console.EnableLog,
	SetOutputStream = Console.SetOutputStream
}

function Console:New(identifier)
	local console = {}
	setmetatable(console, {__index = ConsoleDefault})

	console.identifier = identifier
	return console
end

MPXFoundation_Console = Console -- Global Registration