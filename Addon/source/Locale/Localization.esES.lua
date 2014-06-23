if GetLocale() == "esES" then
	DOTMonitorLocalization = DOTMonitorLocalization or {}

	DOTMonitorLocalization["Player Unavailable!"] 	= "¡Jugador No Disponible!"
	DOTMonitorLocalization["Player not ready due to low level"] = "Jugador no está listo debido a su bajo nivel"
	DOTMonitorLocalization["Player not ready due to no spec"] = "Jugador no está listo debido a ninguna especialización"

	DOTMonitorLocalization["Adjusted for"] 			= "Ajustado para"
	DOTMonitorLocalization["Tracking"]				= "Monitoreando"

	DOTMonitorLocalization["HUD Reset!"]			= "HUD Restablecido"
	DOTMonitorLocalization["HUD is disabled!"]		= "¡HUD esta deshabilitado!"
	DOTMonitorLocalization["HUD Locked"]			= "HUD bloqueado"
	DOTMonitorLocalization["HUD Unlocked"]			= "HUD desbloqueado"

	DOTMonitorLocalization["Cooldowns now visible"] = "Tiempo de reutilización ahora visible"
	DOTMonitorLocalization["Cooldowns now hidden"]	= "Tiempo de reutilización ahora oculto"

	DOTMonitorLocalization["Timers now visible"] 	= "Temporizadores ahora visibles"
	DOTMonitorLocalization["Timers now hidden"]		= "Temporizadores ahora ocultos"

	DOTMonitorLocalization["Usage: show (cooldowns | timers)"] = "Uso: muestra (tiempo de reutilización | temporizadores)"
	DOTMonitorLocalization["Usage: hide (cooldowns | timers)"] = "Uso: oculta (tiempo de reutilización | temporizadores)"

	DOTMonitorLocalization["Ready"] 				= "Listo"
	DOTMonitorLocalization["Pending"]				= "Pendiente"

	-- ================================================================
	DOTMonitorLocalization["lock"]					= "bloquea"
	DOTMonitorLocalization["unlock"]				= "desbloquea"
	DOTMonitorLocalization["show"]					= "muestra"
	DOTMonitorLocalization["hide"]					= "oculta"
	DOTMonitorLocalization["reset"]					= "restablece"

	DOTMonitorLocalization["cooldowns"]				= "tiempo de reutilización"
	DOTMonitorLocalization["timers"]				= "temporizadores"

	DOTMonitorLocalization["Locks the monitor icons"] = "Bloquea los iconos de los monitores"
	DOTMonitorLocalization["Unlocks the monitor icons"] = "Desbloquea los iconos de los monitores"
	DOTMonitorLocalization["Show either cooldowns or timers"] = "Muestra el tiempo de reutilización o los temporizadores"
	DOTMonitorLocalization["Hide either cooldowns or timers"] = "Oculta el tiempo de reutilización o los temporizadores"
	DOTMonitorLocalization["Resets the HUD"] = "Restablece el HUD"
end