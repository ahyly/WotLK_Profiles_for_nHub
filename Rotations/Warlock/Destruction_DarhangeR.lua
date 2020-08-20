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
	settingsfile = "DarhangeR_Destruction.xml",
	{ type = "title", text = "Destruction Warlock by |cff00CED1DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "|cffFFFF00Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Fel Armor", enabled = true, key = "felarmor" },
	{ type = "entry", text = "Demon Armor", enabled = false, key = "demonarmor" },
	{ type = "entry", text = "Soul Stone", tooltip = "Create stone and use it on focus target in focus", enabled = true, key = "soulstone" },
	{ type = "entry", text = "Auto Interrupt", tooltip = "Auto check and interrupt all interruptible spells", enabled = true, key = "autointerrupt" },
	{ type = "entry", text = "Soul Shard Count", tooltip = "Minimal count for use spells", value = 5, key = "soulshards" },	
	{ type = "entry", text = "Debug Printing", tooltip = "Enable for debug if you have problems", enabled = false, key = "Debug" },		
	{ type = "separator" },
	{ type = "page", number = 1, text = "|cff00C957Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Death Coil", tooltip = "Use spell when player HP < %", enabled = true, value = 47, key = "coil" },	
	{ type = "entry", text = "Healthstone", tooltip = "Create and use Healthstone when player HP < %", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", tooltip = "Use Heal Potions (if you have) when player HP < %",  enabled = true, value = 30, key = "healpotionuse" },
	{ type = "entry", text = "Mana Potion", tooltip = "Use Mana Potions (if you have) when player mana < %", enabled = true, value = 25, key = "manapotionuse" },
	{ type = "separator" },
	{ type = "page", number = 2, text = "|cffEE4000Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Shadowflame", tooltip = "Use spell when enemie in range for that", enabled = true, key = "flame" },
	{ type = "entry", text = "Shadowfury (Auto AoE)", tooltip = "Use spell when you have enemies > 2", enabled = false, key = "fury" },
	{ type = "entry", text = "Shadowburn", enabled = false, key = "burn" },
	{ type = "entry", text = "Banish (Auto Use)", tooltip = "Auto check and use spell on proper enemies", enabled = false, key = "banish" },
	{ type = "entry", text = "Auto Control (Member)", tooltip = "Auto check and control member if he mindcontrolled or etc.", enabled = true, key = "control" },		
	{ type = "separator" },
	{ type = "title", text = "Summoning Pets" },
    { type = "dropdown", menu = {
        { selected = true, value = 688, text = "Summon Imp" },
        { selected = false, value = 697, text = "Summon Voidwalker" },
        { selected = false, value = 712, text = "Summon Succubus" },
        { selected = false, value = 691, text = "Summon Felhunter" },
        { selected = false, value = 0, text = "|cffFF0303No pets" },	
    }, key = "Pet" },
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
	ni.GUI.AddFrame("Destruction_DarhangeR", items);
end
local function OnUnLoad()  
	ni.GUI.DestroyFrame("Destruction_DarhangeR");
end
	
local queue = {	
	"Window",
	"AutoTarget",
	"Universal pause",
	"Life Tap (Regen)",
	"Summon pet",
	"Firestone",
	"Soulstone",
	"Healthstone",	
	"Fel Armor",
	"Demon Armor",
	"Fel Domination",
	"Soul Link",
	"Shadow Ward",
	"Combat specific Pause",
	"Pet Attack/Follow",	
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Mana Potions (Use)",		
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Spell Lock (Interrupt)",
	"Soulshatter",
	"Shadowflame",
	"Shadowfury",	
	"Life Tap (Glyph Buff)",
	"Life Tap",
	"Death Coil",
	"Banish (Auto Use)",
	"Control (Member)",
	"Rain of Fire",
	"Incinerate (Non cast)",
	"Shadowburn",
	"Drain Soul (Soul Shard Farm)",
	"Curse of Elements",
	"Curse of Doom",
	"Curse of Agony",
	"Shadow Bolt (Shadow Mastery Check)",
	"Immolate",
	"Immolate AoE",
	"Chaos Bolt",
	"Conflagrate",
	"Life Tap (Moving)",	
	"Corruption",
	"Incinerate",
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
	["Firestone"] = function()
		if not GetWeaponEnchantInfo() 
		 and not ni.player.ismoving()
		 and not UnitAffectingCombat("player") then
		 if not ni.player.hasitem(41174)
		 and IsUsableSpell(GetSpellInfo(60220))
		 and ni.spell.available(60220) then
			ni.spell.cast(60220)
			return true
		 else
			ni.player.useitem(41174)
			ni.player.useinventoryitem(16)
			return true
			end
		end
	end,
-----------------------------------
	["Soulstone"] = function()
		local _, enabled = GetSetting("soulstone")
        if enabled
		 and not ni.player.hasitem(36895)
		 and not ni.player.ismoving()
		 and not UnitAffectingCombat("player")
		 and IsUsableSpell(GetSpellInfo(47884))
		 and ni.spell.available(47884) then
			ni.spell.cast(47884)
			return true
		 else
		 if enabled
		 and ni.unit.exists("focus")
		 and UnitInRange("focus")
		 and ni.player.hasitem(36895)
		 and not UnitIsDeadOrGhost("focus")
		 and not ni.unit.buff("focus", 47883)
		 and not ni.player.ismoving()
		 and ni.player.itemcd(36895) == 0 then
			ni.player.useitem(36895, "focus")
			return true
			end
		end
	end,
-----------------------------------
	["Healthstone"] = function()
		local _, enabled = GetSetting("healthstoneuse")
		local hstones = { 36892, 36893, 36894 };
		local has = false;
		 for k, v in pairs(hstones) do
		  if ni.player.hasitem(v) then
				has = true;
				break;
			end
		end
		if enabled
		 and not has
		 and IsUsableSpell(GetSpellInfo(47878))
		 and ni.spell.available(47878)
		 and not ni.player.ismoving()
		 and not UnitAffectingCombat("player") then
			ni.spell.cast(47878)
			return true
		end
	end,
-----------------------------------
    ["Fel Armor"] = function()
		local _, enabled = GetSetting("felarmor")
        if enabled
         and not ni.player.buff(47893)
         and ni.spell.available(47893) then
            ni.spell.cast(47893)
            return true
        end
    end,
-----------------------------------
    ["Demon Armor"] = function()
		local _, enabled = GetSetting("demonarmor")
        if enabled
         and not ni.player.buff(47889)
         and ni.spell.available(47889) then
            ni.spell.cast(47889)
            return true
        end
    end,
-----------------------------------
	["Fel Domination"] = function()
		local pet = GetSetting("Pet");
		if pet == 0 then 
			return false
		end		
		if not ni.unit.exists("playerpet")
		 and not ni.player.buff(61431)
		 and ni.spell.available(pet)
		 and IsUsableSpell(GetSpellInfo(pet))
		 and ni.spell.available(18708) then
			ni.spell.cast(18708)
			return true
		end
	end,
-----------------------------------
	["Summon pet"] = function()
		local pet = GetSetting("Pet");
		if pet == 0 then 
			return false
		end
		if not ni.unit.exists("playerpet")
		 and not ni.player.buff(61431)
		 and not ni.player.ismoving()
		 and not UnitAffectingCombat("player")
		 and IsUsableSpell(GetSpellInfo(pet))
		 and ni.spell.available(pet)
		 and GetTime() - data.warlock.LastSummon > 2 then
			ni.spell.cast(pet)
			data.warlock.LastSummon = GetTime()
			return true
		end
		local pet = GetSetting("Pet");
		if IsSpellKnown(18708)
		 and ni.spell.available(18708)
		 and not ni.unit.exists("playerpet")
		 and not ni.player.buff(61431)
		 and not ni.player.ismoving()
		 and UnitAffectingCombat("player")
		 and IsUsableSpell(GetSpellInfo(pet))
		 and ni.spell.available(pet)
		 and GetTime() - data.warlock.LastSummon > 2 then
			ni.spell.cast(pet)
			data.warlock.LastSummon = GetTime()
			return true
		end
	end,
-----------------------------------
	["Soul Link"] = function()
		if ni.spell.available(19028)
		 and ni.unit.exists("playerpet")
		 and not ni.player.buff(19028) then
			ni.spell.cast(19028)
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
			data.petFollow()
		 else
		if UnitAffectingCombat("player")
		 and ni.unit.exists("playerpet")
		 and ni.unit.hp("playerpet") > 60
		 and ni.unit.exists("target")
		 and not UnitIsUnit("target", "pettarget")
		 and not UnitIsDeadOrGhost("playerpet") then 
			data.petAttack()
			end
		end
	end,
-----------------------------------
	["Life Tap (Regen)"] = function()
		if not UnitAffectingCombat("player")
		 and ni.player.power() < 85
		 and ni.player.hp() > 35 then
			ni.spell.cast(57946)
			return true
		end
	end,
-----------------------------------
	["Shadow Ward"] = function()
		if data.warlock.ShadowWard()
		 and ni.spell.available(47891) then
		 	ni.spell.cast(47891)
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
		 and ni.spell.valid("target", 47809) then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if ni.spell.valid("target", 47809)
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
		 and ni.spell.valid("target", 47809) then
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
		 and ni.spell.valid("target", 47809) then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0 
		 and data.CDsaverTTD("target")
		 and ni.spell.valid("target", 47809) then
			ni.player.useinventoryitem(14)
			return true
			end
		end
	end,
-----------------------------------	
	["Spell Lock (Interrupt)"] = function()
		local _, enabled = GetSetting("autointerrupt")
		if enabled
		 and ni.spell.shouldinterrupt("target")
		 and IsSpellKnown(19647, true)
		 and GetSpellCooldown(19647) == 0
		 and GetTime() - data.LastInterrupt > 9 then
			ni.spell.castinterrupt("target")
			data.LastInterrupt = GetTime()
			return true
		end
	end,
-----------------------------------	
	["Soulshatter"] = function()
		if #ni.members > 1
		 and ni.unit.threat("player") >= 2
		 and ni.spell.cd(29858) == 0
		 and IsUsableSpell(GetSpellInfo(29858)) then 
			ni.spell.cast(29858)
			return true
		end
	end,
-----------------------------------	
	["Shadowfury"] = function()
		local _, enabled = GetSetting("fury")
		if enabled
		 and ActiveEnemies() >= 2
		 and IsSpellKnown(47847)
		 and ni.spell.available(47847) then
			ni.spell.castat(47847, "target")
			return true
		end
	end,
-----------------------------------	
	["Shadowflame"] = function()	
		local _, enabled = GetSetting("flame")
		if enabled 
		 and ni.player.distance("target") < 6.5
		 and ni.spell.available(61290) then
			ni.spell.cast(61290)
			return true
		end
	end,
-----------------------------------
	["Life Tap (Glyph Buff)"] = function()
		if ni.player.hasglyph(63320)
		 and not ni.player.buff(63321) then
			ni.spell.cast(57946)
			return true
		end
	end,
-----------------------------------
	["Life Tap"] = function()
		if ni.player.power() <= 20
		 and ni.player.hp() > 50 then
			ni.spell.cast(57946)
			return true
		end
	end,
-----------------------------------
	["Life Tap (Moving)"] = function()
		local elem = data.warlock.elem()
		local CotE = data.warlock.CotE()
		local eplag = data.warlock.eplag()
		local earmoon = data.warlock.earmoon()
		local agony = data.warlock.agony()
		local doom = data.warlock.doom()
		if ni.player.ismoving()
		 and ni.player.power() < 75
		 and ni.player.hp() > 50
		 and (elem or CotE or eplag or earmoon or doom or agony)
		 and ni.unit.debuffremaining("target", 47813, "player")
		 and ni.unit.debuffremaining("target", 47811, "player") then
			ni.spell.cast(57946)
			return true
		end
	end,
-----------------------------------
	["Death Coil"] = function()
		local value, enabled = GetSetting("coil");
		if enabled
		 and ni.player.hp() < value
		 and ni.spell.available(47860)
		 and ni.spell.valid("target", 47860, true, true) then
			ni.spell.cast(47860, "target")
			return true
		end
	end,
-----------------------------------
	["Rain of Fire"] = function()
		if ni.vars.combat.aoe
		 and not ni.player.ismoving()
		 and ni.spell.available(47820) then
			ni.spell.castat(47820, "target")
			return true
		end
	end,
-----------------------------------
	["Incinerate (Non cast)"] = function()
		if ni.player.buff(34936)
		 and ni.spell.isinstant(47838)	 	 
		 and ni.spell.available(47838)
		 and ni.spell.valid("target", 47838, true, true) then
			ni.spell.cast(47838, "target")
			return true
		end
	end,
-----------------------------------
	["Shadowburn"] = function()
		local _, enabled = GetSetting("burn")
		if enabled
		 and IsSpellKnown(47827)
		 and IsUsableSpell(GetSpellInfo(47827))
		 and ni.player.ismoving() 
		 and ni.spell.available(47827)
		 and ni.spell.valid("target", 47827, true, true) then
			ni.spell.cast(47827, "target")
			return true
		end
	end,
-----------------------------------
	["Curse of Elements"] = function()
		local elem = data.warlock.elem()
		local CotE = data.warlock.CotE()
		local eplag = data.warlock.eplag()
		local earmoon = data.warlock.earmoon()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") 
		or UnitHealthMax("target") > 450000 )
		 and not (elem or CotE or eplag or earmoon)
		 and ni.spell.available(47865)
		 and data.CDsaver("target")
		 and ni.spell.valid("target", 47865, false, true, true)	
		 and GetTime() - data.warlock.LastCurse > 2 then
			ni.spell.cast(47865, "target")
			data.warlock.LastCurse = GetTime()
			return true
		end
	end,
-----------------------------------
	["Curse of Doom"] = function()
		local elem = data.warlock.elem()
		local CotE = data.warlock.CotE()
		local eplag = data.warlock.eplag()
		local earmoon = data.warlock.earmoon()
		if (ni.unit.isboss("target") 
		or UnitHealthMax("target") > 750000)
		 and ni.unit.ttd("target") > 65
		 and ((CotE and not elem) or eplag or earmoon)
		 and ni.spell.available(47867)
		 and data.CDsaver("target")
		 and ni.spell.valid("target", 47867, false, true, true)	
		 and GetTime() - data.warlock.LastCurse > 1 then
			ni.spell.cast(47867, "target")
			data.warlock.LastCurse = GetTime()
			return true
		end
	end,
-----------------------------------
	["Curse of Agony"] = function()
		local elem = data.warlock.elem()
		local doom = data.warlock.doom()
		local agony = data.warlock.agony()
		if not elem
		 and not doom
		 and not agony
		 and ni.unit.ttd("target") < 60
		 and ni.spell.available(47864)
		 and ni.spell.valid("target", 47864, false, true, true)
		 and GetTime() - data.warlock.LastCurse > 1 then
			ni.spell.cast(47864, "target")
			data.warlock.LastCurse = GetTime()
			return true
		end
	end,
-----------------------------------
	["Shadow Bolt (Shadow Mastery Check)"] = function()
		if select(5, GetTalentInfo(3,1)) >= 4
		 and not ni.unit.debuff("target", 12579) 
		 and not ni.unit.debuff("target", 22959)
		 and not ni.unit.debuff("target", 17800)	 
		 and ni.spell.available(47809)
		 and ni.unit.debuffremaining("target", 17800) < 2.5
		 and ni.spell.valid("target", 47809, true, true)
		 and GetTime() - data.warlock.LastShadowbolt > 3 then
			ni.spell.cast(47809, "target")
			data.warlock.LastShadowbolt = GetTime()
			return true
		end
	end,
-----------------------------------
	["Immolate"] = function()
		if not ni.player.ismoving()
		 and ni.unit.debuffremaining("target", 47811, "player") < ni.spell.casttime(47811)
		 and ni.spell.available(47811)
		 and ni.spell.valid("target", 47811, true, true)
		 and GetTime() - data.warlock.Lastimmolate > 2.1 then
			ni.spell.cast(47811, "target")
			data.warlock.Lastimmolate = GetTime()
			return true
		end
	end,
-----------------------------------
	["Immolate AoE"] = function()
		if ni.rotation.custommod()
		 and ni.unit.exists("target")
		 and ni.spell.available(47811)
		 and UnitCanAttack("player", "target") then
		    table.wipe(enemies);
			enemies = ni.unit.enemiesinrange("target", 15)
			for i = 1, #enemies do
				local tar = enemies[i].guid;
				if ni.unit.creaturetype(enemies[i].guid) ~= 8
				 and ni.unit.creaturetype(enemies[i].guid) ~= 11
				 and not ni.unit.debuffs(tar, "23920||35399||69056", "EXACT")
				 and not ni.unit.debuff(tar, 47811, "player")
				 and ni.spell.valid(enemies[i].guid, 47811, true, true) then
					ni.spell.cast(47811, tar)
					return true
				end
			end
		end
	end,
---------------------------
	["Chaos Bolt"] = function()
		local immolate = data.warlock.immolate()
		if immolate
		 and not ni.player.ismoving()
		 and ni.spell.available(59172)
		 and ni.spell.valid("target", 59172, true, true) then
			ni.spell.cast(59172, "target")
			return true
		end
	end,
-----------------------------------
	["Conflagrate"] = function()
		local immolate = data.warlock.immolate()
		if immolate
		 and IsUsableSpell(GetSpellInfo(17962))
		 and ni.spell.available(17962)
		 and ni.spell.valid("target", 17962, true, true) then
			ni.spell.cast(17962, "target")
			return true
		end
	end,
-----------------------------------
	["Corruption"] = function()
		local corruption = data.warlock.corruption()
		local seed = data.warlock.seed()	
		if ni.spell.available(47813)
		 and not corruption
		 and not seed
		 and ni.spell.valid("target", 47813, false, true, true)
		 and GetTime() - data.warlock.LastCorrupt > 1.5 then
			ni.spell.cast(47813, "target")
			data.warlock.LastCorrupt = GetTime()
			return true
		end
	end,
-----------------------------------
	["Incinerate"] = function()
		local immolate = data.warlock.immolate()
		if immolate
		 and not ni.player.ismoving()
		 and ni.spell.available(47838)
		 and ni.spell.valid("target", 47838, true, true) then
			ni.spell.cast(47838, "target")
			return true
		end
	end,
-----------------------------------
	["Drain Soul (Soul Shard Farm)"] = function()
		local value = GetSetting("soulshards"); 
		if GetItemCount(6265) < value 
		 and not ni.unit.isboss("target")
		 and ni.unit.hp("target") <= 25
		 and ni.spell.available(47855)
		 and not ni.player.ismoving()
		 and ni.spell.valid("target", 47855, true, true) then
			ni.spell.cast(47855, "target")
			return true
		end
	end,
-----------------------------------
	["Banish (Auto Use)"] = function()        
		local _, enabled = GetSetting("banish")
		if enabled 
		 and ni.unit.exists("target")
		 and ni.spell.available(18647)
		 and UnitCanAttack("player", "target") then
		 table.wipe(enemies);
		  enemies = ni.unit.enemiesinrange("player", 25)
		  local dontBanish = false
		  for i = 1, #enemies do
		   local tar = enemies[i].guid; 
		   if (ni.unit.creaturetype(enemies[i].guid) == 3
		    or ni.unit.creaturetype(enemies[i].guid) == 4
		    or ni.unit.aura(enemies[i].guid, 33891))
		    and ni.unit.debuff(tar, 18647, "player") then
			dontBanish = true
			break
		end
        end
		if not dontBanish then
		 for i = 1, #enemies do
		 local tar = enemies[i].guid; 
		 if (ni.unit.creaturetype(enemies[i].guid) == 3
		   or ni.unit.creaturetype(enemies[i].guid) == 4
		   or ni.unit.aura(enemies[i].guid, 33891))
		   and not ni.unit.isboss(tar)
		   and not ni.unit.debuffs(tar, "23920||35399||69056", "EXACT")
		   and not ni.unit.debuff(tar, 18647, "player")
		   and ni.spell.valid(enemies[i].guid, 18647, false, true, true)
		   and GetTime() - data.warlock.LastBanish > 1.5 then
				ni.spell.cast(18647, tar)
				data.warlock.LastBanish = GetTime()
                        return true
					end
				end
			end
		end
	end,
-----------------------------------
	["Control (Member)"] = function()
		local _, enabled = GetSetting("control")
		if enabled
		 and ni.spell.available(6215) then
		  for i = 1, #ni.members do
		   local ally = ni.members[i].unit
		    if data.ControlMember(ally)
			and not data.UnderControlMember(ally)
			and ni.spell.valid(ally, 6215, false, true, true) then
				ni.spell.cast(6215, ally)
				return true
				end
			end
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Destruction Warlock by DarhangeR for 3.3.5a", 
		 "Welcome to Destruction Warlock Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For use Immolate (AoE) mode configure Custom Key Modifier and hold it for put spell on nearest enemies.\n-For use Rain of Fire configure AoE Toggle key.\n-Focus target for use Soulstone.\n-For better experience make Pet passive.")
		popup_shown = true;
		end 
	end,
}

	ni.bootstrap.profile("Destruction_DarhangeR", queue, abilities, OnLoad, OnUnLoad);
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
    ni.bootstrap.profile("Destruction_DarhangeR", queue, abilities);
end