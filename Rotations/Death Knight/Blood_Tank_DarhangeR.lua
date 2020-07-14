local data = {"DarhangeR.lua"}
local popup_shown = false;
local enemies = { };
local function ActiveEnemies()
	table.wipe(enemies);
	enemies = ni.unit.enemiesinrange("target", 7);
	for k, v in ipairs(enemies) do
		if ni.player.threat(v.guid) == -1 then
			table.remove(enemies, k);
		end
	end
	return #enemies;
end
local items = {
	settingsfile = "DarhangeR_TANK_Blood.xml",
	{ type = "title", text = "Blood DK TANK by DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Death Strike (Lich)", enabled = true, value = 75, key = "deathstrike" },
	{ type = "entry", text = "Auto Interrupt", enabled = true, key = "autointerrupt" },	
	{ type = "separator" },
	{ type = "title", text = "Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Rune Tap", enabled = true, value = 55, key = "runetap" },
	{ type = "entry", text = "Vampiric Blood", enabled = true, value = 75, key = "vampblood" },
	{ type = "entry", text = "Mark of Blood", enabled = true, value = 35, key = "markofblood" },
	{ type = "entry", text = "Icebound Fortitude", enabled = true, value = 20, key = "iceboundfort" },
	{ type = "entry", text = "Healthstone", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "separator" },
	{ type = "title", text = "Presence's" },
	{ type = "dropdown", menu = {
		{ selected = false, value = 48266, text = "Blood Presence" },
		{ selected = true, value = 48263, text = "Frost Presence" },
		{ selected = false, value = 48265, text = "Unholy Presence" },
	}, key = "Presence" },
};
local function GetSetting(name)
    for k, v in ipairs(items) do
        if v.type == "entry"
         and v.key ~= nil
         and v.key == name then
            return v.value, v.enabled
        end
        if v.type == "dropdown"
         and v.key ~= nil
         and v.key == name then
            for k2, v2 in pairs(v.menu) do
                if v2.selected then
                    return v2.value
                end
            end
        end
    end
end

local queue = {
	"Window",
	"Universal pause",
	"AutoTarget",
	"Use Presence",
	"Horn of Winter",
	"Combat specific Pause",
	"Pet Attack/Follow",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Racial Stuff",
	"Mind Freeze (Interrupt)",
	"Hysteria",
	"Empower Rune Weapon",
	"Icebound Fortitude",
	"Mark of Blood",
	"Rune Tap",
	"Vampiric Blood",
	"Dark Command",
	"Dark Command (Ally)",
	"Death Grip (Ally)",
	"Death and Decay",
	"Icy Touch",
	"Plague Strike",
	"Icy Touch (Agro)",
	"Pestilence (AoE)",
	"Pestilence (Renew)",
	"Death Strike (Lich)",
	"Death Strike",
	"Death Coil (Max runpower)",
	"Rune Strike",
	"Blood Boil",
	"Blood Strike",
	"Heart Strike",
	"Death Coil",
}
local abilities = {
-----------------------------------
	["Universal pause"] = function()
		if ni.data.darhanger.UniPause() then
			return true
		end
	end,
-----------------------------------
	["AutoTarget"] = function()
		if UnitAffectingCombat("player")
		 and ((ni.unit.exists("target")
		 and UnitIsDeadOrGhost("target")
		 and not UnitCanAttack("player", "target")) 
		 or not ni.unit.exists("target")) then
			ni.player.runtext("/targetenemy")
		end
	end,
-----------------------------------
	["Use Presence"] = function()
		local presence = GetSetting("Presence");		
		if not ni.player.buff(presence)
		 and ni.spell.isinstant(presence)
		 and ni.spell.available(presence) then
			ni.spell.cast(presence)
			return true
		end
	end,
-----------------------------------
	["Horn of Winter"] = function()
		if not ni.player.buff(57623)
		 and ni.spell.isinstant(57623) 
		 and ni.spell.available(57623) then 		
			ni.spell.cast(57623)
			return true
		end
	end,
-----------------------------------
	["Combat specific Pause"] = function()
		if ni.data.darhanger.tankStop("target")
		 or ni.data.darhanger.PlayerDebuffs("player")
		 or UnitCanAttack("player","target") == nil
		 or (UnitAffectingCombat("target") == nil 
		 and ni.unit.isdummy("target") == nil 
		 and UnitIsPlayer("target") == nil) then 
			return true
		end
	end,
-----------------------------------
	["Pet Attack/Follow"] = function()
		if ni.unit.hp("playerpet") < 20
		 and ni.unit.exists("playerpet")
		 and ni.unit.exists("target")
		 and UnitIsUnit("target", "pettarget")
		 and not UnitIsDeadOrGhost("playerpet") then
			ni.data.darhanger.petFollow()
		 else
		if UnitAffectingCombat("player")
		 and ni.unit.exists("playerpet")
		 and ni.unit.hp("playerpet") > 60
		 and ni.unit.exists("target")
		 and not UnitIsUnit("target", "pettarget")
		 and not UnitIsDeadOrGhost("playerpet") then 
			ni.data.darhanger.petAttack()
			end
		end
	end,
-----------------------------------
	["Healthstone (Use)"] = function()
		local value, enabled = GetSetting("healthstoneuse");
		local hstones = { 36892, 36893, 36894 }
		for i = 1, #hstones do
			if enabled
			 and ni.player.hp() < value
			 and ni.player.hasitem(hstones[i]) 
			 and ni.player.itemcd(hstones[i]) == 0 then
				ni.player.useitem(hstones[i])
				return true
			end
		end	
	end,
-----------------------------------
	["Heal Potions (Use)"] = function()
		local value, enabled = GetSetting("healpotionuse");
		local hpot = { 33447, 43569, 40087, 41166, 40067 }
		for i = 1, #hpot do
			if enabled
			 and ni.player.hp() < value
			 and ni.player.hasitem(hpot[i])
			 and ni.player.itemcd(hpot[i]) == 0 then
				ni.player.useitem(hpot[i])
				return true
			end
		end
	end,
-----------------------------------
	["Racial Stuff"] = function()
		local hracial = { 33697, 20572, 33702, 26297 }
		local alracial = { 20594, 28880 }
		--- Undead
		if ni.data.darhanger.forsaken("player")
		 and IsSpellKnown(7744)
		 and ni.spell.available(7744) then
				ni.spell.cast(7744)
				return true
		end
		--- Horde race
		for i = 1, #hracial do
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and IsSpellKnown(hracial[i])
		 and ni.spell.available(hracial[i])
		 and ni.data.darhanger.CDsaverTTD("target")
		 and IsSpellInRange(GetSpellInfo(49930), "target") == 1 then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if IsSpellInRange(GetSpellInfo(49930), "target") == 1
		 and ni.player.hp() < 20
		 and IsSpellKnown(alracial[i])
		 and ni.spell.available(alracial[i]) then 
					ni.spell.cast(alracial[i])
					return true
				end
			end
		end,
-----------------------------------
	["Mind Freeze (Interrupt)"] = function()
		local _, enabled = GetSetting("autointerrupt")
		if enabled	
		 and ni.spell.shouldinterrupt("target")
		 and ni.spell.isinstant(47528)
		 and ni.spell.available(47528)
		 and GetTime() - ni.data.darhanger.LastInterrupt > 9
		 and ni.spell.valid("target", 47528, true, true)  then
			ni.spell.castinterrupt("target")
			ni.data.darhanger.LastInterrupt = GetTime()
			return true
		end
	end,
-----------------------------------
	["Icebound Fortitude"] = function()
		local value, enabled = GetSetting("iceboundfort");
		if enabled
		 and ni.player.hp() < value
		 and ni.spell.isinstant(48792)
		 and ni.spell.available(48792) then
			ni.spell.cast(48792)
			return true
		end
	end,
-----------------------------------
	["Vampiric Blood"] = function()
		local value, enabled = GetSetting("vampblood");
		local _, BR = ni.rune.bloodrunecd()
		if enabled
		 and ni.player.hp() < value
		 and BR >= 1
		 and ni.spell.isinstant(55233)
		 and ni.spell.available(55233) then
			ni.spell.cast(55233)
			return true
		end
	end,
-----------------------------------
	["Mark of Blood"] = function()
		local value, enabled = GetSetting("markofblood");
		local _, BR = ni.rune.bloodrunecd()
		if enabled
		 and BR >= 1
		 and ni.player.hp() < value
		 and ni.spell.isinstant(49005)
		 and ni.spell.available(49005) then
			ni.spell.cast(49005, "target")
			return true
		end
	end,
-----------------------------------
	["Rune Tap"] = function()
		local value, enabled = GetSetting("runetap");
		if enabled
		 and ni.player.hp() < value
		 and ni.spell.isinstant(48982) then
		  local _, BR = ni.rune.bloodrunecd()
		  local _, DR = ni.rune.deathrunecd()
		   if ( BR == 0 or DR == 0 )
		   and ni.spell.isinstant(45529)
		   and ni.spell.cd(45529) == 0 then 
				ni.spell.cast(45529)
                ni.spell.cast(48982)
            return true
                else
		        ni.spell.cast(48982)
			return true
			end
		end
	end,
-----------------------------------
	["Empower Rune Weapon"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.rune.available() == 0
		 and ni.spell.isinstant(47568)
		 and ni.spell.available(47568) then
			ni.spell.cast(47568)
			return true
		end
	end,
-----------------------------------
	["Death and Decay"] = function()
		if ni.vars.combat.aoe
		 and ni.spell.isinstant(49938) 
		 and ni.spell.available(49938) then
			ni.spell.castatqueue(49938, "target")
			return true
		end
	end,
-----------------------------------
	["Hysteria"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.spell.isinstant(49016)
		 and ni.spell.available(49016)
		 and ni.data.darhanger.CDsaverTTD("target")
		 and IsSpellInRange(GetSpellInfo(49930), "target") == 1 then
		  if not ni.unit.exists("focus")
		  and not ni.player.buff(49016) then
			ni.spell.cast(49016, "player")
			return true
		else
		if ni.spell.isinstant(49016)
		 and ni.spell.available(49016) then
		  if ni.unit.exists("focus")
		  and not UnitIsDeadOrGhost("focus")
		  and ni.data.darhanger.CDsaverTTD("target")
		  and not ni.unit.buff("focus", 49016)
		  and ni.spell.valid("focus", 49016, false, true, true) then
					ni.spell.cast(49016, "focus")
					return true
					end
			    end
			end
		end
	end,
-----------------------------------
	["Icy Touch"] = function()
		local icy = ni.data.darhanger.dk.icy()
		if ( icy == nil or ( icy - GetTime() < 2 ) )
		 and ni.spell.available(49909)
		 and ni.spell.isinstant(49909)
		 and ni.spell.valid("target", 49909, true, true) then
			ni.spell.cast(49909, "target")
			ni.data.darhanger.dk.LastIcy = GetTime()
			return true
		end
	end,
-----------------------------------
	["Plague Strike"] = function()
		local plague = ni.data.darhanger.dk.plague()
		if ( plague == nil or ( plague - GetTime() < 2 ) )
		 and ni.spell.available(49921)
		 and ni.spell.isinstant(49921)
		 and ni.spell.valid("target", 49921, true, true) then
			ni.spell.cast(49921, "target")
			return true
		end
	end,
-----------------------------------
	["Icy Touch (Agro)"] = function()
		if ni.unit.isboss("target")
		 and ni.spell.available(49909)
		 and ni.spell.isinstant(49909)
		 and GetTime() - ni.data.darhanger.dk.LastIcy > 25
		 and ni.spell.valid("target", 49909, true, true) then
			ni.spell.cast(49909, "target")
			ni.data.darhanger.dk.LastIcy = GetTime()
			return true
		end
	end,
-----------------------------------
	["Pestilence (AoE)"] = function()
		local icy = ni.data.darhanger.dk.icy()
		local plague = ni.data.darhanger.dk.plague()
		local enemies = ni.unit.enemiesinrange("target", 7)
		local _, BR = ni.rune.bloodrunecd()
		local _, DR = ni.rune.deathrunecd()
		if ActiveEnemies() >= 1 then
		 if ( BR >= 1 or DR >= 1 )
		 and icy
		 and plague
		 and ni.unit.exists("target")
		 and UnitCanAttack("player", "target")
		 and ni.spell.isinstant(50842)
		 and ni.spell.valid("target", 50842, true, true) then
		  for i = 1, #enemies do
		   if ni.unit.creaturetype(enemies[i].guid) ~= 8
		    and ni.unit.creaturetype(enemies[i].guid) ~= 11
		    and (not ni.unit.debuff(enemies[i].guid, 55078, "player")
		    or not ni.unit.debuff(enemies[i].guid, 55095, "player")) then
				ni.spell.cast(50842)
						return true
					end
				end
			end
		end
	end,
-----------------------------------
	["Pestilence (Renew)"] = function()
		local icy = ni.data.darhanger.dk.icy()
		local plague = ni.data.darhanger.dk.plague()
		local _, BR = ni.rune.bloodrunecd()
		local _, DR = ni.rune.deathrunecd()
		 if ni.player.hasglyph(63334)
		 and ni.spell.valid("target", 50842, true, true)
		 and ( ( icy ~= nil and icy - GetTime() <= 5 )
		 or ( plague ~= nil and plague - GetTime() <= 5 ) ) then
			if BR == 0 and DR == 0
			and ni.spell.cd(45529) == 0 then
				ni.spell.cast(45529)
				ni.spell.cast(50842)
			return true
		else
				ni.spell.cast(50842)
			return true
			end
		end
	end,
-----------------------------------
	["Dark Command"] = function()
        table.wipe(enemies);
		if ni.unit.exists("targettarget") 
		 and not UnitIsDeadOrGhost("targettarget")
		 and UnitAffectingCombat("player")
		 and (ni.unit.debuff("targettarget", 72410) 
		 or ni.unit.debuff("targettarget", 72411) 
		 or ni.unit.threat("player", "target") < 2 )
		 and not ni.spell.available(49576)
  		 and ni.spell.available(56222)
		 and ni.spell.isinstant(56222)
		 and ni.data.darhanger.youInInstance()
		 and ni.spell.valid("target", 56222, false, true, true) then
			ni.spell.cast(56222)
			return true
		end
	end,
-----------------------------------
	["Dark Command (Ally)"] = function()
        table.wipe(enemies);
		local enemies = ni.unit.enemiesinrange("player", 30)
		for i = 1, #enemies do
		local threatUnit = enemies[i].guid
   		 if ni.unit.threat("player", threatUnit) ~= nil 
   		  and ni.unit.threat("player", threatUnit) <= 2
   		  and UnitAffectingCombat(threatUnit) 
   		  and not ni.spell.available(49576)
  		  and ni.spell.available(56222)
		  and ni.spell.isinstant(56222)
		  and ni.data.darhanger.youInInstance()
		  and not ni.unit.debuff(threatUnit, 49560)
   		  and ni.spell.valid(threatUnit, 56222, false, true, true) then
			ni.spell.cast(56222, threatUnit)
			return true
			end
		end
	end,
-----------------------------------
	["Death Grip (Ally)"] = function()
        table.wipe(enemies);
		local enemies = ni.unit.enemiesinrange("player", 30)
		for i = 1, #enemies do
		local threatUnit = enemies[i].guid
   		 if ni.unit.threat("player", threatUnit) ~= nil 
   		  and ni.unit.threat("player", threatUnit) <= 2
   		  and UnitAffectingCombat(threatUnit) 
   		  and ni.spell.available(49576)
		  and ni.spell.isinstant(49576)
		  and ni.data.darhanger.youInInstance()
   		  and ni.spell.valid(threatUnit, 49576, true, true) then
			ni.spell.cast(49576, threatUnit)
			return true
			end
		end
	end,
-----------------------------------
	["Death Strike (Lich)"] = function()
		local value, enabled = GetSetting("deathstrike"); 
		local _, FR = ni.rune.frostrunecd()
		local _, UR = ni.rune.unholyrunecd()
		local _, DR = ni.rune.deathrunecd()
		local icy = ni.data.darhanger.dk.icy()
		local plague = ni.data.darhanger.dk.plague()
		if enabled
		 and ni.player.hp() < value 
		 and ((FR >= 1 and UR >= 1)
		 or (FR >= 1 and DR >= 1)
		 or (DR >= 1 and UR >= 1)
		 or (DR == 2))			 
		 and plague
		 and icy
		 and ni.spell.isinstant(49924)
		 and ni.spell.available(49924)
		 and ni.spell.valid("target", 49924, true, true) then
			ni.spell.cast(49924, "target")
			return true
		end
	end,
-----------------------------------
	["Death Strike"] = function()
		local _, FR = ni.rune.frostrunecd()
		local _, UR = ni.rune.unholyrunecd()
		local _, DR = ni.rune.deathrunecd()
		local icy = ni.data.darhanger.dk.icy()
		local plague = ni.data.darhanger.dk.plague()
		if ((FR >= 1 and UR >= 1)
		 or (FR >= 1 and DR >= 1)
		 or (DR >= 1 and UR >= 1)
		 or (DR == 2))			 
		 and plague
		 and icy
		 and ni.spell.isinstant(49924)
		 and ni.spell.available(49924)
		 and ni.spell.valid("target", 49924, true, true) then
			ni.spell.cast(49924, "target")
			return true
		end
	end,
-----------------------------------
	["Rune Strike"] = function()
		if IsUsableSpell(GetSpellInfo(56815))
		 and ni.spell.available(56815, true)
		 and not IsCurrentSpell(56815)
		 and ni.spell.valid("target", 56815, true, true) then
			ni.spell.cast(56815, "target")
			return true
		end
	end,
-----------------------------------
	["Blood Boil"] = function()
		local _, BR = ni.rune.bloodrunecd()
		local icy = ni.data.darhanger.dk.icy()
		local plague = ni.data.darhanger.dk.plague()
		if BR >= 1
		 and ActiveEnemies() > 1
		 and plague
		 and icy
		 and ni.spell.isinstant(55262)
		 and ni.spell.available(55262)
		 and ni.spell.valid("target", 55262, true, true) then
			ni.spell.cast(49941, "target")
			return true
		end
	end,
-----------------------------------
	["Blood Strike"] = function()
		local _, BR = ni.rune.bloodrunecd()
		local icy = ni.data.darhanger.dk.icy()
		local plague = ni.data.darhanger.dk.plague()
		if not IsSpellKnown(55262)
		 and BR >= 1
		 and ( ActiveEnemies() == 1 or ActiveEnemies() < 2 )
		 and plague
		 and icy
		 and ni.spell.isinstant(49930)
		 and ni.spell.available(49930)
		 and ni.spell.valid("target", 49930, true, true) then
			ni.spell.cast(49930, "target")
			return true
		end
	end,	
-----------------------------------
	["Heart Strike"] = function()
		local _, BR = ni.rune.bloodrunecd()
		local icy = ni.data.darhanger.dk.icy()
		local plague = ni.data.darhanger.dk.plague()
		if BR >= 1
		 and ( ActiveEnemies() == 1 or ActiveEnemies() < 2 )
		 and plague
		 and icy
		 and ni.spell.isinstant(55262)
		 and ni.spell.available(55262)
		 and ni.spell.valid("target", 55262, true, true) then
			ni.spell.cast(55262, "target")
			return true
		end
	end,
-----------------------------------
	["Death Coil"] = function()
		if ni.spell.available(49895)
		 and ni.spell.isinstant(49895)
		 and not (IsUsableSpell(GetSpellInfo(56815))
		 or not IsSpellInRange(GetSpellInfo(56815), "target") == 1 )
		 and ni.spell.valid("target", 49895, true, true) then
			ni.spell.cast(49895, "target")
			return true
		end
	end,
-----------------------------------
	["Death Coil (Max runpower)"] = function()
		if ni.player.power() > 80
		 and ni.spell.isinstant(49895)
		 and ni.spell.available(49895)
		 and ni.spell.valid("target", 49895, true, true) then
			ni.spell.cast(49895, "target")
			return true
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Blood Tank Deathknight by DarhangeR for 3.3.5a", 
		 "Welcome to Blood Tank Deathknight Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For use Death and Decay configure AoE Toggle key.")
		popup_shown = true;
		end 
	end,
}

ni.bootstrap.rotation("Blood_Tank_DarhangeR", queue, abilities, data, { [1] = "Blood DK TANK by DarhangeR", [2] = items });