-- =======================================================================================
-- Database V0.2
-- A simple database with session persistence for WOW
-- =======================================================================================

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
	local newDatabase = nil
	local oldDatabase = _G[ID] -- Attempt to load old database

	if oldDatabase
	and type(oldDatabase.version) 	== type(version)
	and oldDatabase.version 		== version then
		newDatabase = oldDatabase
	else
		newDatabase = backupDatabase or {} -- Either backup or a whole new Database
	end

	newDatabase["ID"] 		= ID
	newDatabase["version"] 	= version

	setmetatable(newDatabase, {__index = DatabaseDefault})

	return newDatabase
end

MPXFoundation_Database = Database -- Global Registration