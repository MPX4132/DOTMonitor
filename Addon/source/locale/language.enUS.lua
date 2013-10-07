-- The following specs/combos will be tracked by DOTMonitor
DOTMonitorDebuffs_enUS = {
	["Death_knight"] = {},

	["Druid"] = {
		["Balance"] = {
			"Moonfire",
			"Sunfire",
			"Weakened Armor",
		},
		["Feral"] = {
			"Weakened Armor",
			"Weakened Blows",
		},
		["Guardian"] = {
			"Weakened Blows",
			"Weakened Armor",
		},
		["Restoration"] = {},
		spellIconFor = {
			["Balance"] = {
				"Moonfire",
				"Sunfire",
				"Faerie Fire",
			},
			["Feral"] = {
				"Faerie Fire",
				"Thrash",
			},
			["Guardian"] = {
				"Thrash",
				"Faeries Fire",
			},
			["Restoration"] = {}
		}
	},
	
	["Hunter"] = {
		["Beast_Mastery"] = {
			"Hunter's Mark",
			"Serpent Sting",
		},
		["Marksmanship"] = {
			"Hunter's Mark",
			"Serpent Sting",
		},
		["Survival"] = {
			"Hunter's Mark",
			"Serpent Sting",
		},
		spellIconFor = {
			["Beast_Mastery"] = {
				"Hunter's Mark",
				"Serpent Sting",
			},
			["Marksmanship"] = {
				"Hunter's Mark",
				"Serpent Sting",
			},
			["Survival"] = {
				"Hunter's Mark",
				"Serpent Sting",
			}
		}
	},
	
	["Mage"] = {
		["Arcane"] = {
			"Nether Tempest",
			"Living Bomb",
		},
		["Fire"] = {
			"Nether Tempest",
			"Living Bomb",
		},
		["Frost"] = {
			"Nether Tempest",
			"Living Bomb",
		},
		spellIconFor = {
			["Arcane"] = {
				"Nether Tempest",
				"Living Bomb",
			},
			["Fire"] = {
				"Nether Tempest",
				"Living Bomb",
			},
			["Frost"] = {
				"Nether Tempest",
				"Living Bomb",
			}
		}
	},
	
	["Monk"] = {
		["Brewmaster"] = {
			"Blackout Kick",
			"Dizzying Haze",
			"Breath of Fire",
		},
		["Mistweaver"] = {
			"Blackout Kick",
		},
		["Windwalker"] = {
			"Rising Sun Kick",
			"Blackout Kick",
		},
		spellIconFor = {
			["Brewmaster"] = {
				"Blackout Kick",
				"Dizzing Haze",
				"Breath of Fire",
			},
			["Mistweaver"] = {
				"Blackout Kick",
			},
			["Windwalker"] = {
				"Rising Sun Kick",
				"Blackout Kick",
			}
		}
	},
	
	["Paladin"] = {
		["Holy"] = {},
		["Protection"] = {
			"Weakened Blows",
		},
		["Retribution"] = {
			"Weakened Blows",
			"Physical Vulnerability",
		},
		spellIconFor = {
			["Holy"] = {},
			["Protection"] = {
				"Hammer of the Righteous",
			},
			["Retribution"] = {
				"Hammer of the Righteous",
				"Judgments of the Bold",
			}
		}
	},
	
	["Priest"] = {
		["Dicipline"] = {},
		["Holy"] = {},
		["Shadow"] = {
			"Shadow Word: Pain",
			"Vampiric Touch",
		},
		spellIconFor = {
			["Dicipline"] = {},
			["Holy"] = {},
			["Shadow"] = {
				"Shadow Word: Pain",
				"Vampiric Touch",
			}
		}
	},
	
	["Rouge"] = {
		["Assassination"] = {
			"Weakened Armor",
		},
		["Combat"] = {
			"Weakened Armor",
		},
		["Subtlety"] = {
			"Weakened Armor",
		},
		spellIconsFor = {
			["Assassination"] = {
				"Expose Armor",
			},
			["Combat"] = {
				"Expose Armor",
			},
			["Subtlety"] = {
				"Expose Armor",
			}
		}
	},
	
	["Shaman"] = {
		["Elemental"] = {
			"Flame Shock",
			"Weakened Blows",
		},
		["Enhancement"] = {
			"Flame Shock",
			"Weakened Blows",
		},
		["Restoration"] = {},
		spellIconFor = {
			["Elemental"] = {
				"Flame Shock",
				"Earth Shock",
			},
			["Enhancement"] = {
				"Flame Shock",
				"Earth Shock",
			},
			["Restoration"] = {}
		}
	},
	
	["Warlock"] = { -- Best Class Ever... :D
		["Affliction"] = {
			"Agony",
			"Corruption",
			"Unstable Affliction",
			{"Curse of the Elements", "Curse of Enfeeblement"},
			{"Curse of Enfeeblement", "Curse of the Elements"},
		},
		["Demonology"] = {
			"Corruption",
			"Doom",
			{"Curse of the Elements", "Curse of Enfeeblement"},
			{"Curse of Enfeeblement", "Curse of the Elements"},
			{"Shadowflame", "Chaos Wave"},
		},
		["Destruction"] = {
			"Immolate",
			"Curse of the Elements",
		},
		spellIconFor = {
			["Affliction"] = {
				"Agony",
				"Corruption",
				"Unstable Affliction",
				"Curse of the Elements",
				"Curse of Enfeeblement",
			},
			["Demonology"] = {
				"Corruption",
				"Metamorphosis: Doom",
				"Curse of the Elements",
				"Curse of Enfeeblement",
				"Hand of Gul'dan",
			},
			["Destruction"] = {
				"Immolate",
				"Curse of the Elements",
			}
		}
	},
	
	["Warrior"] = {
		["Arms"] = {
			"Weakened Blows",
			"Physical Vulnerability",
			"Shattering Throw",
			"Mortal Wounds",
		},
		["Fury"] = {
			"Weakened Blows",
			"Physical Vulnerability",
			"Shattering Throw",
			"Mortal Wounds",
		},
		["Protection"] = {
			"Weakened Blows",
			"Deep Wounds",
			"Shattering Throw",
			"Weakened Armor",
		},
		spellIconFor = {
			["Arms"] = {
				"Thunder Clap",
				"Colossus Smash",
				"Shattering Throw",
				"Wild Strike",
			},
			["Fury"] = {
				"Thunder Clap",
				"Colossus Smash",
				"Shattering Throw",
				"Wild Strike",
			},
			["Protection"] = {
				"Thunder Clap",
				"Blood and Thunder",
				"Shattering Throw",
				"Devastate",
			}
		}
	}
}