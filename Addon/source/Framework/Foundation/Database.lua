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

function Database:New(ID, backupDatabase)
	local database = _G[ID] or backupDatabase or {ID = ID}
	setmetatable(database, {__index = DatabaseDefault})

	if backupDatabase then
		database.ID = ID
	end

--	database:Save()

	return database
end

MPXFoundation_Database = Database -- Global Registration