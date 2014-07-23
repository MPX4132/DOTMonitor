if GetLocale() == "esES" then
	DOTMonitorLocalization = DOTMonitorLocalization or {}

	DOTMonitorLocalization["player unavailable!"] 	= "¡jugador no disponible!"
	DOTMonitorLocalization["player not ready due to low level"] = "jugador no está listo debido a su bajo nivel"
	DOTMonitorLocalization["player not ready due to no spec"] = "jugador no está listo debido a ninguna especialización"

	DOTMonitorLocalization["HUD was reset!"]		= "HUD Restablecido"
	DOTMonitorLocalization["HUD is disabled!"]		= "¡HUD esta deshabilitado!"
	DOTMonitorLocalization["HUD Locked"]			= "HUD Bloqueado"
	DOTMonitorLocalization["HUD Unlocked"]			= "HUD Desbloqueado"

	DOTMonitorLocalization["Cooldowns now visible"] = "Tiempo de reutilización ahora visible"
	DOTMonitorLocalization["Cooldowns now hidden"]	= "Tiempo de reutilización ahora oculto"

	DOTMonitorLocalization["Timers now visible"] 	= "Temporizadores ahora visibles"
	DOTMonitorLocalization["Timers now hidden"]		= "Temporizadores ahora ocultos"

	DOTMonitorLocalization["Invalid Command: \"%s\""] = "Comando no válido: \"%s\""
	DOTMonitorLocalization["Valid Commands are:"]	= "Comandos válidos son:"

	DOTMonitorLocalization["Usage: show (cooldowns | timers)"] = "Uso: muestra (tiempo de reutilización | temporizadores)"
	DOTMonitorLocalization["Usage: hide (cooldowns | timers)"] = "Uso: oculta (tiempo de reutilización | temporizadores)"

	DOTMonitorLocalization["Now Ignoring: "] = "Ahora ignorando: "
	DOTMonitorLocalization["Only the following may be ignored"] = "Solo los siguientes pueden ser ignorados"
	DOTMonitorLocalization["Attempted to Ignore: "] = "Se intentó ignorar: "

	DOTMonitorLocalization["Now Monitoring: "] = "Ahora Supervisando: "
	DOTMonitorLocalization["Only the following may be monitored"] = "Sólo los siguientes pueden ser supervisados"
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
	DOTMonitorLocalization["Show spells being monitored"] = "Muestra hechizos siendo monitoreados"
	DOTMonitorLocalization["Ignore a spell, stop monitoring it"] = "Ignora un hechizo, detener la supervisión"
	DOTMonitorLocalization["Monitor a spell which isn't being monitored"] = "Monitorear un hechizo que no se está supervisando"
	DOTMonitorLocalization["Resets the HUD"] = "Restablece el HUD"
end