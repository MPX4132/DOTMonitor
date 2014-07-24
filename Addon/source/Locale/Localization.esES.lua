if GetLocale() == "esES" then
	DOTMonitorLocalization = DOTMonitorLocalization or {}

	DOTMonitorLocalization["player unavailable!"] 	= "¡jugador no disponible!"
	DOTMonitorLocalization["an error has occured, something broke!!!"] = "ha ocurrido un error, algo se rompió!"

	DOTMonitorLocalization["HUD was reset!"]		= "HUD Restablecido"
	DOTMonitorLocalization["HUD is disabled!"]		= "¡HUD esta deshabilitado!"
	DOTMonitorLocalization["HUD Locked"]			= "HUD Bloqueado"
	DOTMonitorLocalization["HUD Unlocked"]			= "HUD Desbloqueado"

	DOTMonitorLocalization["Cooldowns now visible"] = "Tiempo de reutilización ahora visible"
	DOTMonitorLocalization["Cooldowns now hidden"]	= "Tiempo de reutilización ahora oculto"

	DOTMonitorLocalization["Timers now visible"] 	= "Temporizadores ahora visibles"
	DOTMonitorLocalization["Timers now hidden"]		= "Temporizadores ahora ocultos"

	DOTMonitorLocalization["Invalid command: \"%s\""] = "Comando no válido: \"%s\""
	DOTMonitorLocalization["Valid commands are:"]	= "Comandos válidos son:"

	DOTMonitorLocalization["Usage: show (cooldowns | timers)"] = "Uso: muestra (tiempo de reutilización | temporizadores)"
	DOTMonitorLocalization["Usage: hide (cooldowns | timers)"] = "Uso: oculta (tiempo de reutilización | temporizadores)"

	DOTMonitorLocalization["Spell Overview"] = "visión general de hechizos"

	DOTMonitorLocalization["Ignoring %s"] = "Ignorando %s"
	DOTMonitorLocalization["only the green may be ignored"] = "sólo los hechizos verdes pueden ser ignorados"
	DOTMonitorLocalization["Attempted to Ignore: "] = "Se intentó ignorar: "

	DOTMonitorLocalization["Monitoring %s"] = "Supervisando %s"
	DOTMonitorLocalization["only the gray may be monitored"] = "sólo los hechizos grises pueden ser monitoreados"
	DOTMonitorLocalization["Attempted to Monitor: "] = "Se intentó supervisar: "

	DOTMonitorLocalization["ready"] 				= "listo"
	DOTMonitorLocalization["pending"]				= "pendiente"

	-- ================================================================
	DOTMonitorLocalization["lock"]					= "bloquea"
	DOTMonitorLocalization["unlock"]				= "desbloquea"
	DOTMonitorLocalization["show"]					= "muestra"
	DOTMonitorLocalization["hide"]					= "oculta"
	DOTMonitorLocalization["spells"] 				= "hechizos"
	DOTMonitorLocalization["ignore"]				= "ignora"
	DOTMonitorLocalization["monitor"] 				= "supervisa"
	DOTMonitorLocalization["reset"]					= "restablece"

	DOTMonitorLocalization["cooldowns"]				= "tiempo de reutilización"
	DOTMonitorLocalization["timers"]				= "temporizadores"

	DOTMonitorLocalization["Locks the monitor icons"] = "Bloquea los iconos de los monitores"
	DOTMonitorLocalization["Unlocks the monitor icons"] = "Desbloquea los iconos de los monitores"
	DOTMonitorLocalization["Show either cooldowns or timers"] = "Muestra el tiempo de reutilización o los temporizadores"
	DOTMonitorLocalization["Hide either cooldowns or timers"] = "Oculta el tiempo de reutilización o los temporizadores"
	DOTMonitorLocalization["Show spells being monitored"] = "Muestra hechizos siendo supervisados"
	DOTMonitorLocalization["Ignore a spell, stop monitoring it"] = "Ignora un hechizo, detener la supervisión"
	DOTMonitorLocalization["Monitor a spell which isn't being monitored"] = "Monitorear un hechizo que no se está supervisando"
	DOTMonitorLocalization["Resets the HUD"] = "Restablece el HUD"
end