-- The following spec/debuff combos will be monitored by DOTMonitor
DOTMonitor_Debuffs = {
	["DEATHKNIGHT"] = {
		[250] = { 	-- "Blood"
			-- "Outbreak" 		: "Blood Plague", "Frost Fever"
			[77575] = {55078, 55095},
			-- "Icy Touch" 		: "Frost Fever"
			[45477]	= 55095,
			-- "Plague Strike"	: "Blood Plague"
			[45462]	= 55078,
			-- "Scarlet Fever"	: "Weakened Blows"
			[81132] = 115798,
		},
		[251] = { 	-- "Frost"
			-- "Outbreak" 		: "Blood Plague", "Frost Fever"
			[77575] = {55078, 55095},
			-- "Icy Touch" 		: "Frost Fever"
			[45477]	= 55095,
			-- "Plague Strike"	: "Blood Plague"
			[45462]	= 55078,
		},
		[252] = { 	-- "Unholy"
			-- "Outbreak" 		: "Blood Plague", "Frost Fever"
			[77575] = {55078, 55095},
			-- "Icy Touch" 		: "Frost Fever"
			[45477]	= 55095,
			-- "Plague Strike"	: "Blood Plague"
			[45462]	= 55078,
		}
	},

	["DRUID"] = {
		[102] = {	-- "Balance"
			-- "Moonfire"		: "Moonfire"
			[8921] 	= 8921,
			-- "Sunfire"		: "Sunfire"
			[93402]	= 93402,
			-- "Lacerate"		: "Lacerate"
			[33745]	= 33745,
			-- "Pounce"			: "Pounce"
			[9005]	= 9005,
			-- "Rake"			: "Rake"
			[1822]	= 1822,
		},
		[103] = { 	-- "Feral"
			-- "Moonfire"		: "Moonfire"
			[8921] 	= 8921,
			-- "Thrash"			: "Thrash"
			[77758]	= 77758,
			-- "Lacerate"		: "Lacerate"
			[33745]	= 33745,
			-- "Pounce"			: "Pounce"
			[9005]	= 9005,
			-- "Rake"			: "Rake"
			[1822]	= 1822,
		},
		[104] = { 	-- "Guardian"
			-- "Moonfire"		: "Moonfire"
			[8921] 	= 8921,
			-- "Thrash"			: "Thrash"
			[77758]	= 77758,
			-- "Lacerate"		: "Lacerate"
			[33745]	= 33745,
			-- "Pounce"			: "Pounce"
			[9005]	= 9005,
			-- "Rake"			: "Rake"
			[1822]	= 1822,
		},
		[105] = { 	-- "Restoration"
			-- "Moonfire"		: "Moonfire"
			[8921] 	= 8921,
			-- "Lacerate"		: "Lacerate"
			[33745]	= 33745,
			-- "Pounce"			: "Pounce"
			[9005]	= 9005,
			-- "Rake"			: "Rake"
			[1822]	= 1822,
		}
	},

	["HUNTER"] = {
		[253] = { 	-- "Beast_Mastery"
			-- "Serpent Sting"	: "Serpent Sting"
			[1978]	= 1978,
			-- "Widow Venom"	: "Widow Venom"
			[82654] = 82654,
			-- "Hunter's Mark" 	: "Hunter's Mark"
			--[1130] = 1130,
			-- "Glaive Toss" 	: "Glaive Toss"
			[117050] = 117050,
		},
		[254] = {	-- "Marksmanship"
			-- "Serpent Sting"	: "Serpent Sting"
			[1978]	= 1978,
			-- "Widow Venom"	: "Widow Venom"
			[82654] = 82654,
			-- "Glaive Toss" 	: "Glaive Toss"
			[117050] = 117050,
		},
		[255] = { 	-- "Survival"
			-- "Serpent Sting"	: "Serpent Sting"
			[1978]	= 1978,
			-- "Widow Venom"	: "Widow Venom"
			[82654] = 82654,
			-- "Black Arrow"	: "Black Arrow"
			[3674]	= 3674,
			-- "Glaive Toss" 	: "Glaive Toss"
			[117050] = 117050,
		}
	},

	["MAGE"] = {
		[62] = { 	-- "Arcane"
			-- "Mage Bomb"		: "Mage Bomb"
			[125430] = {114923, 113092, 44461}
		},
		[63] = { 	-- "Fire"
			-- "Pyroblast" 		: "Pyroblast"
			[11366] = 11366,
			-- "Mastery: Ignite": "Ignite"
			[12846] = 12654,
			-- "Combustion"		: "Combustion Impact"
			[11129]	= 118271,
			-- "Dragon's Breath": "Dragon's Breath"
			[31661] = 29964,
			-- "Mage Bomb"		: "Mage Bomb"
			[125430] = {114923, 113092, 44461}
		},
		[64] = { 	-- "Frost"
			-- "Frozen Orb"		: "Frozen Orb"
			[84714] = 84714,
			-- "Mage Bomb"		: "Mage Bomb"
			[125430] = {114923, 113092, 44461}
		}
	},

	["MONK"] = {
		[268] = { 	-- "Brewmaster"
			-- "Keg Smash"		: "Weakened Blows", "Dizzying Haze"
			[121253] = {115798, 123727},
			-- "Dizzying Haze"	: "Dizzying Haze"
			[123727] = 123727,
			-- "Breath of Fire"	: "Breath of Fire"
			[115181] 	= 115181,
		},
		[269] = { 	-- "Mistweaver"
		},
		[270] = { 	-- "Windwalker"
			-- "Rising Sun Kick": "Mortal Wounds"
			[107428] = 115804,
		}
	},

	["PALADIN"] = {
		[65] = {}, 	-- "Holy"
		[66] = {	-- "Protection"
			-- "Hammer of the Righteous"	: "Weakened Blows"
			[53595] = 115798,
		},
		[70] = { 	-- "Retribution"
			-- "Hammer of the Righteous"	: "Weakened Blows"
			[53595]	= 115798,
			-- "Judgments of the Bold" 		: "Physical Vulnerability"
			[111529] = 81326,
		}
	},

	["PRIEST"] = {
		[256] = {}, -- "Dicipline"
		[257] = {}, -- "Holy"
		[258] = { 	-- "Shadow"
			-- "Shadow Word: Pain" 	: "Shadow Word: Pain"
			[589] = 589,
			-- "Vampiric Touch"		: "Vampiric Touch"
			[34914] = 34914,
		}
	},

	["ROGUE"] = {
		[259] = { 	-- "Assassination"
			-- "Expose Armor"		: "Weakened Armor"
			[8647] 	= 113746,
		},
		[260] = { 	-- "Combat"
			-- "Revealing Strike" 	: "Revealing Strike"
			[84617] = 84617,
			-- "Expose Armor"		: "Weakened Armor"
			[8647] 	= 113746,
		},
		[261] = { 	-- "Subtlety"
			-- "Hemorrhage"			: "Hemorrhage"
			[16511]	= 16511,
			-- "Expose Armor"		: "Weakened Armor"
			[8647] 	= 113746,
		}
	},

	["SHAMAN"] = {
		[262] = { 	-- "Elemental"
			-- "Flame Shock"		: "Flame Shock"
			[8050] 	= 8050,
			-- "Earth Shock"		: "Weakened Blows"
			[8042]	= 115798,
		},
		[263] = {	-- "Enhancement"
			-- "Flame Shock"		: "Flame Shock"
			[8050] 	= 8050,
			-- "Earth Shock"		: "Weakened Blows"
			[8042]	= 115798,
		},
		[264] = {} 	-- "Restoration"
	},

	["WARLOCK"] = {
		[265] = { 	-- "Affliction"
			-- "Agony" 					: "Agony"
			[980] 	= 980,
			-- "Corruption" 			: "Corruption"
			[172] 	= 146739,
			-- "Haunt"					: "Haunt"
			[48181] = 48181,
			-- "Unstable Affliction" 	: "Unstable Affliction"
			[131736] = 131736,
			-- "Seed of Corruption"		: "Seed of Corruption"
			[44141]	= 44141,
			-- "Curse of the Elements" 	: "Curse of the Elements", "Curse of Enfeeblement"
			[1490]	= {1490, 109466},
			-- "Curse of Enfeeblement" 	: "Curse of Enfeeblement", "Curse of the Elements"
			[109466] = {109466, 1490},
		},
		[266] = {	-- "Demonology"
			-- "Corruption" 			: "Corruption"
			[172] 	= 146739,
			-- "Curse of the Elements" 	: "Curse of the Elements", "Curse of Enfeeblement"
			[1490]	= {1490, 109466},
			-- "Metamorphosis: Doom" 	: "Doom"
			[124913] = 603,
			-- "Curse of Enfeeblement" 	: "Curse of Enfeeblement", "Curse of the Elements"
			[109466] = {109466, 1490},
			-- "Hand of Gul'dan"		: "Shadowflame", "Chaos Wave"
			[105174] = {47960, 124917},
		},
		[267] = { 	-- "Destruction"
			-- "Immolate" 				: "Immolate"
			[348] = 348,
			-- "Curse of the Elements"	: "Curse of the Elements"
			[1490]	= 1490,
		}
	},

	["WARRIOR"] = {
		[71] = { 	-- "Arms"
			-- "Mortal Strike"		: "Mortal Wounds"
			[12294] = 115804,
			-- "Thunder Clap"		: "Weakened Blows"
			[6343]	= 115798,
			-- "Colossus Smash"		: "Colossus Smash"
			[86346] = 86346,
			-- "Shattering Throw"	: "Shattering Throw"
			[64382]	= 64382,
		},
		[72] = { 	-- "Fury"
			-- "Bloodthirst"		: "Deep Wounds"
			[23881] = 115768,
			-- "Wild Strike"		: "Mortal Wounds"
			[100130] = 115804,
			-- "Colossus Smash"		: "Colossus Smash"
			[86346] = 86346,
			-- "Shattering Throw"	: "Shattering Throw"
			[64382]	= 64382,
		},
		[73] = {	-- "Protection"
			-- "Devastate"			: "Weakened Armor"
			[20243] = 113746,
			-- "Thunder Clap"		: "Weakened Blows"
			[6343]	= 115798,
			-- "Shattering Throw"	: "Shattering Throw"
			[64382]	= 64382,
		}
	}
}