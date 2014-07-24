local Spell	= _G["MPXWOWKit_Spell"]

-- The following spec/debuff combos will be monitored by DOTMonitor
-- Remember to place the form/stance specific spells at the end of the list to prevent
-- dynamic icons from replacing the other static icons' position when updated.
DOTMonitor_Debuffs = {
	["DEATHKNIGHT"] = {
		[250] = { 	-- "Blood"
			-- "Outbreak" 		: "Blood Plague", "Frost Fever"
			Spell:New(77575, {55078, 55095}, "DOT"),
			-- "Icy Touch" 		: "Frost Fever"
			Spell:New(45477, 55095, "DOT"),
			-- "Plague Strike"	: "Blood Plague"
			Spell:New(45462, 55078, "DOT"),
		},
		[251] = { 	-- "Frost"
			-- "Outbreak" 		: "Blood Plague", "Frost Fever"
			Spell:New(77575, {55078, 55095}, "DOT"),
			-- "Icy Touch" 		: "Frost Fever"
			Spell:New(45477, 55095, "DOT"),
			-- "Plague Strike"	: "Blood Plague"
			Spell:New(45462, 55078, "DOT"),
		},
		[252] = { 	-- "Unholy"
			-- "Outbreak" 		: "Blood Plague", "Frost Fever"
			Spell:New(77575, {55078, 55095}, "DOT"),
			-- "Icy Touch" 		: "Frost Fever"
			Spell:New(45477, 55095, "DOT"),
			-- "Plague Strike"	: "Blood Plague"
			Spell:New(45462, 55078, "DOT"),
		},
		["NO_SPEC"] = {
			-- "Outbreak" 		: "Blood Plague", "Frost Fever"
			Spell:New(77575, {55078, 55095}, "DOT"),
			-- "Icy Touch" 		: "Frost Fever"
			Spell:New(45477, 55095, "DOT"),
			-- "Plague Strike"	: "Blood Plague"
			Spell:New(45462, 55078, "DOT"),
		},
	},

	["DRUID"] = {
		[102] = {	-- "Balance"
			-- "Moonfire"		: "Moonfire"
			Spell:New(8921,		8921,	"DOT"),
			-- "Sunfire"		: "Sunfire"
			Spell:New(93402,	93402,	"DOT"),
			-- "Lacerate"		: "Lacerate"
			Spell:New(33745,	33745,	"DOT", 	{5}),	-- Only on bear form
			-- "Pounce"			: "Pounce"
			Spell:New(9005,		9005,	"DOT", 	{1}),	-- Only on cat form
			-- "Rake"			: "Rake"
			Spell:New(1822,		1822,	"DOT", 	{1}),	-- Only on cat form
		},
		[103] = { 	-- "Feral"
			-- "Moonfire"		: "Moonfire"
			Spell:New(8921,		8921,	"DOT"),
			-- "Thrash"			: "Thrash"
			Spell:New(77758,	77758,	"DOT", 	{1}),	-- Only on cat form
			-- "Lacerate"		: "Lacerate"
			Spell:New(33745,	33745,	"DOT", 	{5}),	-- Only on bear form
			-- "Pounce"			: "Pounce"
			Spell:New(9005,		9005,	"DOT", 	{1}),	-- Only on cat form
			-- "Rake"			: "Rake"
			Spell:New(1822,		1822,	"DOT", 	{1}),	-- Only on cat form
		},
		[104] = { 	-- "Guardian"
			-- "Moonfire"		: "Moonfire"
			Spell:New(8921,		8921,	"DOT"),
			-- "Thrash"			: "Thrash"
			Spell:New(77758,	77758,	"DOT",  {1}),	-- Only on cat form
			-- "Lacerate"		: "Lacerate"
			Spell:New(33745,	33745,	"DOT", 	{5}),	-- Only on bear form
			-- "Pounce"			: "Pounce"
			Spell:New(9005,		9005,	"DOT", 	{1}),	-- Only on cat form
			-- "Rake"			: "Rake"
			Spell:New(1822,		1822,	"DOT", 	{1}),	-- Only on cat form
		},
		[105] = { 	-- "Restoration"
			-- "Moonfire"		: "Moonfire"
			Spell:New(8921,		8921,	"DOT"),
			-- "Lacerate"		: "Lacerate"
			Spell:New(33745,	33745,	"DOT", 	{5}),	-- Only on bear form
			-- "Pounce"			: "Pounce"
			Spell:New(9005,		9005,	"DOT", 	{1}),	-- Only on cat form
			-- "Rake"			: "Rake"
			Spell:New(1822,		1822,	"DOT", 	{1}),	-- Only on cat form
		},
		["NO_SPEC"] = {
			-- "Moonfire"		: "Moonfire"
			Spell:New(8921,		8921,	"DOT"),
			-- "Lacerate"		: "Lacerate"
			Spell:New(33745,	33745,	"DOT", 	{5}),	-- Only on bear form
			-- "Pounce"			: "Pounce"
			Spell:New(9005,		9005,	"DOT", 	{1}),	-- Only on cat form
			-- "Rake"			: "Rake"
			Spell:New(1822,		1822,	"DOT", 	{1}),	-- Only on cat form
		},
	},

	["HUNTER"] = {
		[253] = { 	-- "Beast_Mastery"
			-- "Serpent Sting"	: "Serpent Sting"
			Spell:New(1978,		1978,	"DOT"),
			-- "Glaive Toss" 	: "Glaive Toss"
			Spell:New(117050,	117050,	"DOT"),
			-- "Widow Venom"	: "Widow Venom"
			Spell:New(82654,	82654,	"DOT"),
		},
		[254] = {	-- "Marksmanship"
			-- "Serpent Sting"	: "Serpent Sting"
			Spell:New(1978,		1978,	"DOT"),
			-- "Glaive Toss" 	: "Glaive Toss"
			Spell:New(117050,	117050,	"DOT"),
			-- "Widow Venom"	: "Widow Venom"
			Spell:New(82654,	82654,	"DOT"),
		},
		[255] = { 	-- "Survival"
			-- "Serpent Sting"	: "Serpent Sting"
			Spell:New(1978,		1978,	"DOT"),
			-- "Widow Venom"	: "Widow Venom"
			Spell:New(82654,	82654,	"DOT"),
			-- "Glaive Toss" 	: "Glaive Toss"
			Spell:New(117050,	117050,	"DOT"),
			-- "Black Arrow"	: "Black Arrow"
			Spell:New(3674,		3674,	"DOT"),
		},
		["NO_SPEC"] = {
			-- "Serpent Sting"	: "Serpent Sting"
			Spell:New(1978,		1978,	"DOT"),
			-- "Widow Venom"	: "Widow Venom"
			Spell:New(82654,	82654,	"DOT"),
		},
	},

	["MAGE"] = {
		[62] = { 	-- "Arcane"
			-- "Frost Bomb"		: "Frost Bomb"
			Spell:New(112948,	112948,	"DOT"),
			-- "Living Bomb"	: "Living Bomb"
			Spell:New(44457,	44457,	"DOT"),
			-- "Nether Tempest"	: "Nether Tempest"
			Spell:New(114923,	114923,	"DOT"),
		},
		[63] = { 	-- "Fire"
			-- "Pyroblast" 		: "Pyroblast"
			Spell:New(11366,	11366,	"DOT"),
			-- "Mastery: Ignite": "Ignite"
			Spell:New(12846,	12654,	"DOT"),
			-- "Combustion"		: "Combustion Impact"
			Spell:New(11129,	118271,	"DOT"),
			-- "Dragon's Breath": "Dragon's Breath"
			Spell:New(31661,	29964,	"DOT"),
			-- "Frost Bomb"		: "Frost Bomb"
			Spell:New(112948,	112948,	"DOT"),
			-- "Living Bomb"	: "Living Bomb"
			Spell:New(44457,	44457,	"DOT"),
			-- "Nether Tempest"	: "Nether Tempest"
			Spell:New(114923,	114923,	"DOT"),
		},
		[64] = { 	-- "Frost"
			-- "Frozen Orb"		: "Frozen Orb"
			Spell:New(84714,	84714,	"DOT"),
			-- "Frost Bomb"		: "Frost Bomb"
			Spell:New(112948,	112948,	"DOT"),
			-- "Living Bomb"	: "Living Bomb"
			Spell:New(44457,	44457,	"DOT"),
			-- "Nether Tempest"	: "Nether Tempest"
			Spell:New(114923,	114923,	"DOT"),
		},
		["NO_SPEC"] = {
		},
	},

	["MONK"] = {
		[268] = { 	-- "Brewmaster"
			-- "Keg Smash"		: "Weakened Blows", "Dizzying Haze"
			Spell:New(121253,	{115798, 123727},	"DOT"),
			-- "Dizzying Haze"	: "Dizzying Haze"
			Spell:New(123727,	123727,	"DOT"),
			-- "Breath of Fire"	: "Breath of Fire"
			Spell:New(115181,	115181,	"DOT"),
		},
		[269] = { 	-- "Windwalker"
			-- "Rising Sun Kick": "Mortal Wounds"
			Spell:New(107428,	115804,	"DOT"),
		},
		[270] = { 	-- "Mistweaver"
		},
		["NO_SPEC"] = {
		},
	},

	["PALADIN"] = {
		[65] = {}, 	-- "Holy"
		[66] = {	-- "Protection"
			-- "Hammer of the Righteous"	: "Weakened Blows"
			Spell:New(53595, 	115798,	"DOT"),
		},
		[70] = { 	-- "Retribution"
			-- "Hammer of the Righteous"	: "Weakened Blows"
			Spell:New(53595, 	115798,	"DOT"),
			-- "Judgments of the Bold" 		: "Physical Vulnerability"
			Spell:New(111529, 	81326, 	"DOT"),
		},
		["NO_SPEC"] = {
		},
	},

	["PRIEST"] = {
		[256] = {}, -- "Dicipline"
		[257] = {}, -- "Holy"
		[258] = { 	-- "Shadow"
			-- "Shadow Word: Pain" 	: "Shadow Word: Pain"
			Spell:New(589, 		589, 	"DOT"),
			-- "Vampiric Touch"		: "Vampiric Touch"
			Spell:New(34914, 	34914,	"DOT"),
		},
		["NO_SPEC"] = {
		},
	},

	["ROGUE"] = {
		[259] = { 	-- "Assassination"
			-- "Expose Armor"		: "Weakened Armor"
			Spell:New(8647, 	113746, "DOT"),
		},
		[260] = { 	-- "Combat"
			-- "Revealing Strike" 	: "Revealing Strike"
			Spell:New(84617, 	84617,	"DOT"),
			-- "Expose Armor"		: "Weakened Armor"
			Spell:New(8647, 	113746, "DOT"),
		},
		[261] = { 	-- "Subtlety"
			-- "Hemorrhage"			: "Hemorrhage"
			Spell:New(16511, 	16511,	"DOT"),
			-- "Expose Armor"		: "Weakened Armor"
			Spell:New(8647, 	113746, "DOT"),
		},
		["NO_SPEC"] = {
			-- "Expose Armor"		: "Weakened Armor"
			Spell:New(8647, 	113746, "DOT"),
		},
	},

	["SHAMAN"] = {
		[262] = { 	-- "Elemental"
			-- "Flame Shock"		: "Flame Shock"
			Spell:New(8050, 	8050, 	"DOT"),
			-- "Earth Shock"		: "Weakened Blows"
			Spell:New(8042, 	115798, "DOT"),
		},
		[263] = {	-- "Enhancement"
			-- "Flame Shock"		: "Flame Shock"
			Spell:New(8050, 	8050, 	"DOT"),
			-- "Earth Shock"		: "Weakened Blows"
			Spell:New(8042, 	115798, "DOT"),
		},
		[264] = {},	-- "Restoration"
		["NO_SPEC"] = {
			-- "Flame Shock"		: "Flame Shock"
			Spell:New(8050, 	8050, 	"DOT"),
			-- "Earth Shock"		: "Weakened Blows"
			Spell:New(8042, 	115798, "DOT"),
		},
	},

	["WARLOCK"] = {
		[265] = { 	-- "Affliction"
			-- "Curse of Enfeeblement" 	: "Curse of Enfeeblement", "Curse of the Elements", "Curse of Exhaustion"
			Spell:New(109466, 	{109466, 1490, 18223}, "DOT"),
			-- "Corruption" 			: "Corruption"
			Spell:New(172, 		146739, "DOT"),
			-- "Haunt"					: "Haunt"
			Spell:New(48181, 	48181, 	"DOT"),
			-- "Seed of Corruption"		: "Seed of Corruption"
			-- Spell:New(44141, 	44141, 	"DOT"), -- If you need this spell, remove the first "--"
			-- "Curse of the Elements" 	: "Curse of the Elements", "Curse of Enfeeblement", "Curse of Exhaustion"
			Spell:New(1490, 	{1490, 109466, 18223}, "DOT"),
			-- "Agony" 					: "Agony"
			Spell:New(980, 		980, 	"DOT"),
			-- "Unstable Affliction" 	: "Unstable Affliction"
			Spell:New(131736, 	131736, "DOT"),
			-- "Curse of Exhaustion" 	: "Curse of Exhaustion", "Curse of Enfeeblement", "Curse of the Elements"
			Spell:New(18223, 	{18223, 109466, 1490}, "DOT"),
		},
		[266] = {	-- "Demonology"
			-- "Corruption" 			: "Corruption"
			Spell:New({172}, 	146739, "DOT"),
			-- "Curse of the Elements" 	: "Curse of the Elements", "Curse of Enfeeblement", "Aura of the Elements"
			Spell:New(1490, 	{1490, 109466, 116202}, "DOT"),
			-- "Metamorphosis: Doom" 	: "Doom"
			Spell:New(124913, 	603, 	"DOT"),
			-- "Curse of Enfeeblement" 	: "Curse of Enfeeblement", "Curse of the Elements", "Aura of the Elements"
			Spell:New(109466, 	{109466, 1490, 116202}, "DOT"),
			-- "Hand of Gul'dan"		: "Shadowflame", "Chaos Wave"
			Spell:New(105174, 	{47960, 124915}, 		"DOT"),
		},
		[267] = { 	-- "Destruction"
			-- "Immolate" 				: "Immolate"
			Spell:New(348, 		348, 	"DOT"),
			-- "Curse of the Elements"	: "Curse of the Elements"
			Spell:New(1490, 	1490, 	"DOT"),
		},
		["NO_SPEC"] = {
			-- "Corruption" 			: "Corruption"
			Spell:New({172}, 	146739, "DOT"),
		},
	},

	["WARRIOR"] = {
		[71] = { 	-- "Arms"
			-- "Mortal Strike"		: "Mortal Wounds"
			Spell:New(12294, 	115804, "DOT"),
			-- "Thunder Clap"		: "Weakened Blows"
			Spell:New(6343, 	115798, "DOT"),
			-- "Colossus Smash"		: "Colossus Smash"
			Spell:New(86346, 	86346, 	"DOT"),
			-- "Shattering Throw"	: "Shattering Throw"
			Spell:New(64382, 	64382, 	"DOT"),
		},
		[72] = { 	-- "Fury"
			-- "Bloodthirst"		: "Deep Wounds"
			Spell:New(23881, 	115768, "DOT"),
			-- "Wild Strike"		: "Mortal Wounds"
			Spell:New(100130, 	115804, "DOT"),
			-- "Colossus Smash"		: "Colossus Smash"
			Spell:New(86346, 	86346, 	"DOT"),
			-- "Shattering Throw"	: "Shattering Throw"
			Spell:New(64382, 	64382, 	"DOT"),
		},
		[73] = {	-- "Protection"
			-- "Devastate"			: "Weakened Armor"
			Spell:New(20243, 	113746, "DOT"),
			-- "Thunder Clap"		: "Weakened Blows"
			Spell:New(6343, 	115798, "DOT"),
			-- "Shattering Throw"	: "Shattering Throw"
			Spell:New(64382, 	64382, 	"DOT"),
		},
		["NO_SPEC"] = {
			-- "Thunder Clap"		: "Weakened Blows"
			Spell:New(6343, 	115798, "DOT"),
			-- "Shattering Throw"	: "Shattering Throw"
			Spell:New(64382, 	64382, 	"DOT"),
		},
	}
}