local data = ni.utils.require("DarhangeR");
local popup_shown = false;
local enemies = { };
local build = select(4, GetBuildInfo());
local level = UnitLevel("player");
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
if build == 30300 and level == 80 and data then
local items = {
	settingsfile = "DarhangeR_Fury.xml",
	{ type = "title", text = "Fury Warrior by |c0000CED1DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "|cffFFFF00Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Auto Stence", tooltip = "Auto use proper stence", enabled = false, key = "stence" },		
	{ type = "entry", text = "Battle Shout", enabled = true, key = "battleshout" },
	{ type = "entry", text = "Commanding Shout", enabled = false, key = "commandshout" },
	{ type = "entry", text = "Auto Interrupt", tooltip = "Auto check and interrupt all interruptible spells", enabled = true, key = "autointerrupt" },
	{ type = "entry", text = "Debug Printing", tooltip = "Enable for debug if you have problems", enabled = false, key = "Debug" },		
	{ type = "separator" },
	{ type = "page", number = 1, text = "|cff00C957Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Enraged Regeneration", tooltip = "Use spell when player HP < %", enabled = true, value = 37, key = "regen" },
	{ type = "entry", text = "Berserker Rage (Anti-Contol)", enabled = true, key = "bersrage" },
	{ type = "entry", text = "Healthstone", tooltip = "Use Warlock Healthstone (if you have) when player HP < %", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", tooltip = "Use Heal Potions (if you have) when player HP < %",  enabled = true, value = 30, key = "healpotionuse" },
	{ type = "separator" },
	{ type = "page", number = 2, text = "|cffEE4000Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Sunder Armor", tooltip = "Work only on bosses", enabled = false, key = "sunder" },	
	{ type = "entry", text = "Heroic Strike/Cleave", tooltip = "Minimal rage threshold for use spells", value = 45, key = "heroiccleave" },
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
        if v.type == "input"
         and v.key ~= nil
         and v.key == name then
            return v.value
        end
    end
end;
local function OnLoad()
	ni.GUI.AddFrame("Fury_DarhangeR", items);
end
local function OnUnLoad()  
	ni.GUI.DestroyFrame("Fury_DarhangeR");
end

local queue = {
	"Window",
	"Universal pause",
	"AutoTarget",
	"Berserker Stance",
	"Battle Shout",
	"Commanding Shout",
	"Enraged Regeneration",
	"Berserker Rage",
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Pummel (Interrupt)",
	"Victory Rush",	
	"Bloodrage",
	"Heroic Strike + Cleave (Filler)",
	"Bloodthirst",
	"Whirlwind",	
	"Death Wish",
	"Recklessness",
	"Execute",
	"Slam",
	"Sunder Armor",
}
local abilities = {
-----------------------------------
	["Universal pause"] = function()
		if data.UniPause() then
			return true
		end
		ni.vars.debug = select(2, GetSetting("Debug"));
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
	["Berserker Stance"] = function()
		local _, enabled = GetSetting("stence")
		if enabled 
		 and not ni.player.aura(2458)
		 and ni.spell.available(2458) then 
			ni.spell.cast(2458)
			return true
		end
	end,
-----------------------------------
	["Battle Shout"] = function()
		local _, enabled = GetSetting("battleshout")
		if ni.player.buffs("47436||48932||48934") then 
		 return false
	end
		if enabled
		 and ni.spell.available(47436) then
			ni.spell.cast(47436)	
			return true
		end
	end,		 
-----------------------------------
	["Commanding Shout"] = function()
		local _, enabled = GetSetting("commandshout")
		if ni.player.buffs("47440||47440") then 
		 return false
	end
		if enabled
		 and ni.spell.available(47440) then
			ni.spell.cast(47440)	
			return true
		end
	end,
-----------------------------------
	["Enraged Regeneration"] = function()
		local value, enabled = GetSetting("regen");
		local enrage = { 18499, 12292, 29131, 14204, 57522 }
		if enabled
		 and ni.spell.available(55694)
		 and ni.player.hp() < value then
		  for i = 1, #enrage do
		   if ni.player.buff(enrage[i]) then
		       ni.spell.cast(55694)
		else
		 if not ni.player.buff(enrage[i])
		  and ni.spell.cd(2687) == 0 then
		       ni.spell.castspells("2687|55694")
					return true
					end
			    end
			end
		end
	end,		 
-----------------------------------
	["Berserker Rage"] = function()
		local _, enabled = GetSetting("bersrage")
		if enabled
		 and data.warrior.Berserk()
		 and ni.spell.available(18499) 
		 and not ni.player.buff(18499) then
			ni.spell.cast(18499)
			return true
		end
	end,	 
-----------------------------------
	["Combat specific Pause"] = function()
		if data.meleeStop("target")
		 or data.PlayerDebuffs("player")
		 or UnitCanAttack("player","target") == nil
		 or (UnitAffectingCombat("target") == nil 
		 and ni.unit.isdummy("target") == nil 
		 and UnitIsPlayer("target") == nil) then 
			return true
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
		if data.forsaken("player")
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
		 and data.CDsaverTTD("target")
		 and ni.spell.valid("target", 47465) then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if ni.spell.valid("target", 47465) 
		 and ni.player.hp() < 20
		 and IsSpellKnown(alracial[i])
		 and ni.spell.available(alracial[i]) then 
					ni.spell.cast(alracial[i])
					return true
				end
			end
		end,
-----------------------------------
	["Use enginer gloves"] = function()
		if ni.player.slotcastable(10)
		 and ni.player.slotcd(10) == 0
		 and data.CDsaverTTD("target")
		 and ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and IsSpellInRange(GetSpellInfo(47465), "target") == 1 then
			ni.player.useinventoryitem(10)
			return true
		end
	end,
-----------------------------------
	["Trinkets"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(13)
		 and ni.player.slotcd(13) == 0
		 and data.CDsaverTTD("target")
		 and IsSpellInRange(GetSpellInfo(47465), "target") == 1 then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0 
		 and data.CDsaverTTD("target")
		 and IsSpellInRange(GetSpellInfo(47465), "target") == 1 then
			ni.player.useinventoryitem(14)
			return true
			end
		end
	end,
-----------------------------------	
	["Pummel (Interrupt)"] = function()
		local _, enabled = GetSetting("autointerrupt")
		if enabled	
		 and ni.spell.shouldinterrupt("target")
		 and ni.spell.available(6552)
		 and GetTime() - data.LastInterrupt > 9
		 and ni.spell.valid("target", 6552, true, true)  then
			ni.spell.castinterrupt("target")
			data.LastInterrupt  = GetTime()
			return true
		end
	end,
-----------------------------------	
	["Death Wish"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.spell.available(12292)
		 and data.CDsaverTTD("target")
		 and IsSpellInRange(GetSpellInfo(47465), "target") == 1 then
			ni.spell.cast(12292)
			return true
		end
	end,
-----------------------------------
	["Recklessness"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.spell.available(1719)
		 and data.CDsaverTTD("target")
		 and IsSpellInRange(GetSpellInfo(47465), "target") == 1 then
			ni.spell.cast(1719)
			return true
		end
	end,
-----------------------------------
	["Bloodrage"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.power() < 65
		 and ni.player.hasglyph(58096)
		 and ni.spell.available(2687)
		 and IsSpellInRange(GetSpellInfo(47465), "target") == 1 then
			ni.spell.cast(2687)
			return true
		end
	end,
-----------------------------------
	["Victory Rush"] = function()
		if IsUsableSpell(GetSpellInfo(34428))
		 and ni.spell.valid("target", 34428, true, true) then
			ni.spell.cast(34428, "target")
			return true
		end
	end,
-----------------------------------
	["Execute"] = function()
		if ni.player.power() > 30
		 and (ni.unit.hp("target") <= 20
		 or IsUsableSpell(GetSpellInfo(47471)))
		 and ni.spell.valid("target", 47471, true, true) then
			ni.spell.cast(47471, "target")
			return true
		end
	end,
-----------------------------------
	["Slam"] = function()
		if ni.player.buff(46916)
		 and ni.spell.cd(1680) ~= 0	
		 and ni.spell.cd(23881) ~= 0
		 and ni.spell.available(47475, true)
		 and ni.spell.valid("target", 47475, true, true) then
			ni.spell.cast(47475, "target")
			return true
		end
	end,
-----------------------------------
	["Bloodthirst"] = function()
		if ni.spell.available(23881, true)
		 and ni.spell.valid("target", 23881, true, true) then
			ni.spell.cast(23881, "target")
			return true
		end
	end,
-----------------------------------
	["Whirlwind"] = function()
		if ni.spell.available(1680, true)
		 and ni.spell.valid("target", 23881, true, true) then	
			ni.spell.cast(1680, "target")
			return true
		end
	end,
-----------------------------------	
	["Sunder Armor"] = function()
		local sunder, _, _, count = ni.unit.debuff("target", 7386)
		local _, enabled = GetSetting("sunder")
		if enabled
		 and ni.unit.isboss("target")
		 and not ni.unit.debuff("target", 8647)
		 and (not sunder
		 or count < 5 or ni.unit.debuffremaining("target", 7386, "player") < 3 )
		 and ni.spell.available(7386)
		 and ni.spell.valid("target", 7386, true, true) then 
			ni.spell.cast(7386, "target")
			return true
		end
	end,	
-----------------------------------
	["Heroic Strike + Cleave (Filler)"] = function()
		local value = GetSetting("heroiccleave");
		if IsSpellInRange(GetSpellInfo(47475), "target") == 1
		 and ni.spell.cd(47486) ~= 0 
		 and ni.player.power() > value then
			if ni.vars.combat.aoe
			 and ni.spell.available(47520, true) 
			 and not IsCurrentSpell(47520) then
				ni.spell.cast(47520, "target")
			return true
		else
			if not ni.vars.combat.aoe
			 and ni.spell.available(47450, true)
			 and not IsCurrentSpell(47450) then
				ni.spell.cast(47450, "target")
			return true
				end
			end
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Fury Warrior by DarhangeR for 3.3.5a", 
		 "Welcome to Fury Warrior Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For enable Heroic Strike / Cleave (AoE)  configure AoE Toggle key.")		
		popup_shown = true;
		end 
	end,
}

	ni.bootstrap.profile("Fury_DarhangeR", queue, abilities, OnLoad, OnUnLoad);
else
    local queue = {
        "Error",
    }
    local abilities = {
        ["Error"] = function()
            ni.vars.profiles.enabled = false;
            if build > 30300 then
              ni.frames.floatingtext:message("This profile is meant for WotLK 3.3.5a! Sorry!")
            elseif level < 80 then
              ni.frames.floatingtext:message("This profile is meant for level 80! Sorry!")
            elseif data == nil then
              ni.frames.floatingtext:message("Data file is missing or corrupted!");
            end
        end,
    }
    ni.bootstrap.profile("Fury_DarhangeR", queue, abilities);
end