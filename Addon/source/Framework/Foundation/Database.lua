--
-- Database V0.1
-- A simple database with session persistence for WOW
--

local Database = {} -- Local Namespace


function Database:Serialize()
	_G[self.ID] = self -- Store to global
end

function Database:Reset()
	wipe(self)
	self = nil
end

local DatabaseDefault = {
	Serialize	= Database.Serialize,
	Reset		= Database.Reset,
}

function Database:New(ID, version, backupDatabase)
	--[[
	local database = _G[ID] or backupDatabase or {ID = ID}
	setmetatable(database, {__index = DatabaseDefault})

	if backupDatabase then
		database.ID = ID
	end

--	database:Save()

	return database
	--]]
	local newDatabase = nil
	local oldDatabase = _G[ID]

	if 	oldDatabase
	and oldDatabase.version
	and type(oldDatabase.version) 	== type(version)
	and oldDatabase.version 		== version
	then newDatabase = oldDatabase
	elseif backupDatabase
	then newDatabase = backupDatabase
	else newDatabase = {} -- A real new database
	end

	newDatabase.ID 		= ID
	newDatabase.version = version

	setmetatable(newDatabase, {__index = DatabaseDefault})

	return newDatabase
end

MPXFoundation_Database = Database -- Global Registration