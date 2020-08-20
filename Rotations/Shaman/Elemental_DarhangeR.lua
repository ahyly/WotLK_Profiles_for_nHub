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
	settingsfile = "DarhangeR_Elemental.xml",
	{ type = "title", text = "Elemental Shaman by |c0000CED1DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "|cffFFFF00Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Thunderstorm (Regen Mana)", tooltip = "Use spell when player mana < % and no enemies in range", enabled = true, value = 80, key = "thunder" },
	{ type = "entry", text = "Auto Interrupt", tooltip = "Auto check and interrupt all interruptible spells", enabled = true, key = "autointerrupt" },
	{ type = "entry", text = "Debug Printing", tooltip = "Enable for debug if you have problems", enabled = false, key = "Debug" },		
	{ type = "separator" },
	{ type = "page", number = 1, text = "|cff00C957Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Healing Wave (Self)", tooltip = "Use spell when player HP < %", enabled = false, value = 55, key = "wave" },
	{ type = "entry", text = "Healthstone", tooltip = "Use Warlock Healthstone (if you have) when player HP < %", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", tooltip = "Use Heal Potions (if you have) when player HP < %",  enabled = true, value = 30, key = "healpotionuse" },
	{ type = "entry", text = "Mana Potion", tooltip = "Use Mana Potions (if you have) when player mana < %", enabled = true, value = 25, key = "manapotionuse" },
	{ type = "separator" },
	{ type = "page", number = 2, text = "|cffEE4000Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Auto Control (Member)", tooltip = "Auto check and control member if he mindcontrolled or etc.", enabled = true, key = "control" },	
	{ type = "entry", text = "Purge", tooltip = "Purge proper spell. You can edit table in Data file.", enabled = true, key = "purge" },	
	{ type = "entry", text = "Pull Totems (Auto)", tooltip = "Auto pull totem", enabled = true, key = "totempull" },	
	{ type = "separator" },
	{ type = "title", text = "Dispel" },
	{ type = "separator" },
	{ type = "entry", text = "Cure Toxins", tooltip = "Auto dispel debuffs from player", enabled = true, key = "toxins" },
	{ type = "entry", text = "Cure Toxins (Member)", tooltip = "Auto dispel debuffs from members", enabled = false, key = "toxinsmemb" },	
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
	ni.GUI.AddFrame("Elemental_DarhangeR", items);
end
local function OnUnLoad()  
	ni.GUI.DestroyFrame("Elemental_DarhangeR");
end

local queue = {
	"Window",	
	"Universal pause",
	"AutoTarget",
	"Enchant Weapon",
	"Water Shield",
	"Thunderstorm (Regen Mana)",
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Mana Potions (Use)",
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Wind Shear (Interrupt)",
	"Pull Totems (Auto)",
	"Lava Burst",
	"Elemental Mastery",
	"Control (Member)",
	"Flame Shock",
	"Earth Shock",
	"Healing Wave (Self)",	
	"Chain Lightning",
	"Cure Toxins (Member)",
	"Cure Toxins (Self)",
	"Purge",
	"Lightning Bolt",
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
	["Enchant Weapon"] = function()
		local mh = GetWeaponEnchantInfo()
		if not mh 
		 and ni.spell.available(58790) then
			ni.spell.cast(58790)
			return true
		end
	end,
-----------------------------------
	["Water Shield"] = function()
		if not ni.player.buff(57960)
		 and ni.spell.available(57960) then
			ni.spell.cast(57960)
			return true
		end
	end,
-----------------------------------
	["Thunderstorm (Regen Mana)"] = function()
        table.wipe(enemies);		
		local enemies = ni.unit.enemiesinrange("player", 15)
		local value, enabled = GetSetting("thunder");
		if enabled
		 and #enemies == 0
		 and not UnitAffectingCombat("player")
		 and ni.player.power() < value
		 and ni.spell.available(59159) then
			ni.spell.cast(59159)
			return true
		end
	end,
-----------------------------------
	["Combat specific Pause"] = function()
		if data.casterStop("target")
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
	["Mana Potions (Use)"] = function()
		local value, enabled = GetSetting("manapotionuse");
		local mpot = { 33448, 43570, 40087, 42545, 39671 }
		for i = 1, #mpot do
			if enabled
			 and ni.player.power() < value
			 and ni.player.hasitem(mpot[i])
			 and ni.player.itemcd(mpot[i]) == 0 then
				ni.player.useitem(mpot[i])
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
		 and ni.spell.valid("target", 49238, true, true) then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if ni.spell.valid("target", 49238, true, true)
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
		 and ni.spell.valid("target", 49238) then
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
		 and ni.spell.valid("target", 49238) then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0 
		 and data.CDsaverTTD("target")
		 and ni.spell.valid("target", 49238) then
			ni.player.useinventoryitem(14)
			return true
			end
		end
	end,
-----------------------------------		
	["Wind Shear (Interrupt)"] = function()
		local _, enabled = GetSetting("autointerrupt")
		if enabled
		 and ni.spell.shouldinterrupt("target")
		 and ni.spell.available(57994)
		 and GetTime() - data.LastInterrupt > 9
		 and ni.spell.valid("target", 57994, true, true)  then
			ni.spell.castinterrupt("target")
			data.LastInterrupt = GetTime()
			return true
		end
	end,
-----------------------------------	
	["Pull Totems (Auto)"] = function()
		local _, enabled = GetSetting("totempull")
		if enabled
		 and not tContains(UnitName("target"), ni.IgnoreUnits) then
		 local fireTotem = select(2, GetTotemInfo(1))
		 local totem_distance = ni.unit.distance("target", "totem1")
		 local target_distance = ni.player.distance("target")
		 if ni.spell.valid("target", 49238)
		 and (fireTotem == ""
		 or (fireTotem ~= ""
		 and target_distance ~= nil
		 and target_distance < 36
		 and totem_distance ~= nil
		 and totem_distance > 40))
		 and not ni.player.ismoving() then
			ni.spell.cast(66842)
			return true
			end
		end
	end,
-----------------------------------
	["Elemental Mastery"] = function()
	    local flameshock = data.shaman.flameshock()
	    if ( ni.vars.CD or ni.unit.isboss("target") )
		 and flameshock
		 and not ni.spell.available(60043)
		 and ni.spell.available(16166)
		 and data.CDsaverTTD("target")
		 and ni.spell.valid("target", 49238, true, true) then
			ni.spell.castspells("16166|49238")
			return true
		end
	end,
-----------------------------------
	["Flame Shock"] = function()
		if ni.unit.debuffremaining("target", 49233, "player") < 2
		 and ni.spell.available(49233)
		 and ni.spell.valid("target", 49233, true, true) then
			ni.spell.cast(49233, "target")
			return true
		end
	end,
-----------------------------------
	["Earth Shock"] = function()
		local flameshock = data.shaman.flameshock()
		if ni.player.ismoving()
		 and flameshock
		 and ni.spell.available(49231)
		 and ni.spell.valid("target", 49231, true, true) then
			ni.spell.cast(49231, "target")
			return true
		end
	end,
-----------------------------------
	["Lava Burst"] = function()
		local flameshock = data.shaman.flameshock()
		if flameshock
		 and not ni.player.ismoving()
		 and ni.spell.available(60043)
		 and ni.spell.valid("target", 60043, true, true) then
			ni.spell.cast(60043, "target")
			return true
		end
	end,
-----------------------------------	
	["Healing Wave (Self)"] = function()
		local value, enabled = GetSetting("manapotionuse");
		if enabled
		 and ni.player.hp() < value
		 and ni.spell.available(49273)
		 and not ni.player.ismoving() then
			ni.spell.cast(49273, "player")
			return true
		end
	end,
-----------------------------------
	["Chain Lightning"] = function()
		if ( ActiveEnemies() > 1 or ActiveEnemies() == 1 ) 
		 and ni.spell.available(49271)
		 and not ni.player.ismoving()
		 and ni.spell.valid("target", 49271, true, true) then
			ni.spell.cast(49271, "target")
			return true
		end
	end,
-----------------------------------
	["Cure Toxins (Self)"] = function()
		local _, enabled = GetSetting("toxins")
		if enabled
		  and ni.player.debufftype("Disease|Poison")
		  and ni.spell.available(526)
		  and ni.healing.candispel("player")
		  and GetTime() - data.LastDispel > 1.5
		  and ni.spell.valid("player", 526, false, true, true) then
			ni.spell.cast(526, "player")
			data.LastDispel = GetTime()
			return true
		end
	end,
-----------------------------------
	["Cure Toxins (Member)"] = function()
		local _, enabled = GetSetting("toxinsmemb")
		if enabled
		 and ni.spell.available(526) then
		  for i = 1, #ni.members do
		  if ni.unit.debufftype(ni.members[i].unit, "Disease|Poison")
		   and ni.healing.candispel(ni.members[i].unit)
		   and GetTime() - data.LastDispel > 1.5
		   and ni.spell.valid(ni.members[i].unit, 526, false, true, true) then
				ni.spell.cast(526, ni.members[i].unit)
				data.LastDispel = GetTime()
				return true
				end
			end
		end
	end,
-----------------------------------
	["Purge"] = function()
		local _, enabled = GetSetting("purge")
		if enabled
		 and data.shaman.canPurge("target")
		 and ni.spell.available(8012)
		 and ni.spell.valid("player", 8012, true, true)
		 and GetTime() - data.shaman.LastPurge > 2.5 then
			ni.spell.cast(8012, "target")
			data.shaman.LastPurge = GetTime()
			return true
		end
	end,
-----------------------------------
	["Lightning Bolt"] = function()
		if ni.spell.available(49238)
		 and not ni.player.ismoving()
		 and ni.spell.valid("target", 49238, true, true) then
			ni.spell.cast(49238, "target")
			return true
		end
	end,
-----------------------------------
	["Control (Member)"] = function()
		local _, enabled = GetSetting("control")
		if enabled
		 and ni.spell.available(51514) then
		  for i = 1, #ni.members do
		   local ally = ni.members[i].unit
		    if data.ControlMember(ally)
			and not data.UnderControlMember(ally)
			and ni.spell.valid(ally, 51514, false, true, true) then
				ni.spell.cast(51514, ally)
				return true
				end
			end
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Elemental Shaman by DarhangeR for 3.3.5a", 
		 "Welcome to Elemental Shaman Profile! Support and more in Discord > https://discord.gg/TEQEJYS.")
		popup_shown = true;
		end 
	end,
}

	ni.bootstrap.profile("Elemental_DarhangeR", queue, abilities, OnLoad, OnUnLoad);
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
    ni.bootstrap.profile("Elemental_DarhangeR", queue, abilities);
end