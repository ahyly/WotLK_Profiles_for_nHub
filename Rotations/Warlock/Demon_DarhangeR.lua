local data = {"DarhangeR.lua"}
local popup_shown = false;
local enemies = { };
local items = {
	settingsfile = "DarhangeR_Demon.xml",
	{ type = "title", text = "Demonology Warlock by DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Fel Armor", enabled = true, key = "felarmor" },
	{ type = "entry", text = "Demon Armor", enabled = false, key = "demonarmor" },
	{ type = "entry", text = "Soul Stone", enabled = true, key = "soulstone" },
	{ type = "entry", text = "Auto Interrupt", enabled = true, key = "autointerrupt" },
	{ type = "entry", text = "Soul Shard Count", value = 5, key = "soulshards" },	
	{ type = "separator" },
	{ type = "title", text = "Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Death Coil", enabled = true, value = 47, key = "coil" },
	{ type = "entry", text = "Healthstone", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "entry", text = "Mana Potion", enabled = true, value = 25, key = "manapotionuse" },
	{ type = "separator" },
	{ type = "title", text = "Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Shadowflame", enabled = true, key = "flame" },
	{ type = "entry", text = "Demon Charge", enabled = false, key = "charge" },	
	{ type = "entry", text = "Shadow Cleave", enabled = false, key = "cleave" },	
	{ type = "entry", text = "Immolation Aura", enabled = true, key = "aura" },
	{ type = "entry", text = "Banish (Auto Use)", enabled = false, key = "banish" },
	{ type = "separator" },
	{ type = "title", text = "Summoning Pets" },
    { type = "dropdown", menu = {
        { selected = false, value = 688, text = "Summon Imp" },
        { selected = false, value = 697, text = "Summon Voidwalker" },
        { selected = false, value = 712, text = "Summon Succubus" },
        { selected = false, value = 691, text = "Summon Felhunter" },
        { selected = true, value = 30146, text = "Summon Felguard" },
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

local queue = {
	"Window",
	"AutoTarget",
	"Universal pause",
	"Life Tap (Regen)",
	"Summon pet",
	"Firestone/Spellstone",
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
	"Life Tap (Glyph Buff)",
	"Life Tap",
	"Death Coil",
	"Banish (Auto Use)",
	"Rain of Fire",
	"Shadow Bolt (Non cast)",
	"Drain Soul (Soul Shard Farm)",
	"Metamorphosis",
	"Demon Charge",
	"Immolation Aura",
	"Shadow Cleave",
	"Demonic Empowerment",
	"Curse of Elements",
	"Curse of Doom",
	"Curse of Agony",
	"Corruption AoE",
	"Shadow Bolt (Shadow Mastery Check)",
	"Life Tap (Moving)",
	"Corruption",
	"Immolate",		
	"Soul Fire (Decimination + Molten Core)",
	"Soul Fire (Decimination)",
	"Incinerate (No Decimination)",
	"Incinerate",
	"Shadow Bolt",
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
	["Firestone/Spellstone"] = function()
		if GetCombatRating(20) > 1450
		 and not GetWeaponEnchantInfo() 
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
		if GetCombatRating(20) < 1450
		 and not GetWeaponEnchantInfo() 
		 and not ni.player.ismoving()
		 and not UnitAffectingCombat("player") then
		 if not ni.player.hasitem(41196)
		 and IsUsableSpell(GetSpellInfo(47888))
		 and ni.spell.available(47888) then
			ni.spell.cast(47888)
			return true
		 else
			ni.player.useitem(41196)
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
         and ni.spell.available(47893)
         and ni.spell.isinstant(47893) then
            ni.spell.cast(47893)
            return true
        end
    end,
-----------------------------------
    ["Demon Armor"] = function()
		local _, enabled = GetSetting("demonarmor")
        if enabled
         and not ni.player.buff(47889)
         and ni.spell.available(47889)
         and ni.spell.isinstant(47889) then
            ni.spell.cast(47889)
            return true
        end
    end,
-----------------------------------
	["Fel Domination"] = function()
		local pet = GetSetting("Pet");
		if not ni.unit.exists("playerpet")
		 and ni.spell.isinstant(18708)
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
		if not ni.unit.exists("playerpet")
		 and not ni.player.buff(61431)
		 and not ni.player.ismoving()
		 and not UnitAffectingCombat("player")
		 and IsUsableSpell(GetSpellInfo(pet))
		 and ni.spell.available(pet)
		 and GetTime() - ni.data.darhanger.warlock.LastSummon > 2 then
			ni.spell.cast(pet)
			ni.data.darhanger.warlock.LastSummon = GetTime()
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
		 and GetTime() - ni.data.darhanger.warlock.LastSummon > 2 then
			ni.spell.cast(pet)
			ni.data.darhanger.warlock.LastSummon = GetTime()
			return true
		end
	end,
-----------------------------------
	["Soul Link"] = function()
		if ni.spell.available(19028)
		and ni.unit.exists("playerpet")
		and not ni.player.buff(19028)
		and ni.spell.isinstant(19028) then
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
	["Life Tap (Regen)"] = function()
		if not UnitAffectingCombat("player")
		 and ni.player.power() < 85
		 and ni.player.hp() > 35
		 and ni.spell.isinstant(19028) then
			ni.spell.cast(57946)
			return true
		end
	end,
-----------------------------------
	["Shadow Ward"] = function()
		if ni.data.darhanger.warlock.ShadowWard()
		 and ni.spell.isinstant(47891)
		 and ni.spell.available(47891) then
		 	ni.spell.cast(47891)
			return true
		end
	end,
-----------------------------------
	["Combat specific Pause"] = function()
		if ni.data.darhanger.casterStop("target")
		 or ni.data.darhanger.PlayerDebuffs("player")
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
		 and ni.data.darhanger.CDsaverTTD("target")
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
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ni.spell.valid("target", 47809) then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0 
		 and ni.data.darhanger.CDsaverTTD("target")
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
		 and GetTime() - ni.data.darhanger.LastInterrupt > 9 then
			ni.spell.castinterrupt("target")
			ni.data.darhanger.LastInterrupt = GetTime()
			return true
		end
	end,
-----------------------------------	
	["Soulshatter"] = function()
		if #ni.members > 1
		 and ni.unit.threat("player") >= 2
		 and ni.spell.cd(29858) == 0
		 and ni.spell.isinstant(29858) 
		 and IsUsableSpell(GetSpellInfo(29858)) then 
			ni.spell.cast(29858)
			return true
		end
	end,
-----------------------------------
	["Shadowflame"] = function()	
		local _, enabled = GetSetting("flame")
		if enabled 
		 and ni.player.distance("target") < 6.5
		 and ni.spell.available(61290)
		 and ni.spell.isinstant(61290) then
			ni.spell.cast(61290)
			return true
		end
	end,
-----------------------------------
	["Life Tap (Glyph Buff)"] = function()
		if ni.player.hasglyph(63320)
		 and not ni.player.buff(63321)
		 and ni.spell.isinstant(57946) then
			ni.spell.cast(57946)
			return true
		end
	end,
-----------------------------------
	["Life Tap"] = function()
		if ni.player.power() <= 20
		 and ni.player.hp() > 50
		 and ni.spell.isinstant(57946) then
			ni.spell.cast(57946)
			return true
		end
	end,
-----------------------------------
	["Life Tap (Moving)"] = function()
		local elem = ni.data.darhanger.warlock.elem()
		local CotE = ni.data.darhanger.warlock.CotE()
		local eplag = ni.data.darhanger.warlock.eplag()
		local earmoon = ni.data.darhanger.warlock.earmoon()
		local agony = ni.data.darhanger.warlock.agony()
		local doom = ni.data.darhanger.warlock.doom()
		if ni.player.ismoving()
		 and ni.player.power() < 75
		 and ni.player.hp() > 50
		 and (elem or CotE or eplag or earmoon or doom or agony)
		 and ni.unit.debuffremaining("target", 47813, "player")
		 and ni.unit.debuffremaining("target", 47811, "player")
		 and ni.spell.isinstant(57946) then
			ni.spell.cast(57946)
			return true
		end
	end,
-----------------------------------
	["Death Coil"] = function()
		local value, enabled = GetSetting("coil");
		if enabled
		 and ni.player.hp() < value
		 and ni.spell.isinstant(47860)
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
	["Shadow Bolt (Non cast)"] = function()
		if ( ni.player.buff(17941) 
		 or ni.player.buff(34936) )
		 and ni.spell.available(47809)
		 and ni.spell.valid("target", 47809, true, true) then
			ni.spell.cast(47809, "target")
			return true
		end
	end,
-----------------------------------
	["Metamorphosis"] = function()
		local corruption = ni.data.darhanger.warlock.corruption()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and corruption
		 and ni.spell.available(47241)
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ni.spell.valid("target", 47809) then
			ni.spell.cast(47241)
			return true
		end
	end,
-----------------------------------
	["Demon Charge"] = function()	
		local _, enabled = GetSetting("charge")
		if enabled  
		 and ni.player.buff(47241)
		 and ni.spell.available(54785)
		 and ni.spell.valid("target", 54785, true, true) then
			ni.spell.cast(54785, "target")
			return true
		end
	end,
-----------------------------------
	["Shadow Cleave"] = function()	
		local _, enabled = GetSetting("cleave")
		if enabled 
		 and ni.player.distance("target") < 1.9
		 and ni.player.buff(47241)
		 and not IsCurrentSpell(50581) 
		 and ni.spell.available(50581, true) then
			ni.spell.cast(50581, "target")
			return true
		end
	end,
-----------------------------------
	["Immolation Aura"] = function()	
		local _, enabled = GetSetting("aura")
		if enabled  
		 and ni.player.distance("target") < 3
		 and ni.player.buff(47241)
		 and ni.spell.isinstant(50589)
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ni.spell.available(50589) then
			ni.spell.cast(50589)
			return true
		end
	end,
-----------------------------------
	["Demonic Empowerment"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.unit.exists("playerpet")
		 and ni.spell.available(47193)
		 and ni.spell.isinstant(47193)
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ni.spell.valid("target", 47809) then
			ni.spell.cast(47193)
			return true
		end
	end,
-----------------------------------
	["Curse of Elements"] = function()
		local elem = ni.data.darhanger.warlock.elem()
		local CotE = ni.data.darhanger.warlock.CotE()
		local eplag = ni.data.darhanger.warlock.eplag()
		local earmoon = ni.data.darhanger.warlock.earmoon()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") 
		or UnitHealthMax("target") > 450000 )
		 and not (elem or CotE or eplag or earmoon)
		 and ni.spell.available(47865)
		 and ni.spell.isinstant(47865)
		 and ni.data.darhanger.CDsaver("target")
		 and ni.spell.valid("target", 47865, false, true, true)	
		 and GetTime() - ni.data.darhanger.warlock.LastCurse > 2 then
			ni.spell.cast(47865, "target")
			ni.data.darhanger.warlock.LastCurse = GetTime()
			return true
		end
	end,
-----------------------------------
	["Curse of Doom"] = function()
		local elem = ni.data.darhanger.warlock.elem()
		local CotE = ni.data.darhanger.warlock.CotE()
		local eplag = ni.data.darhanger.warlock.eplag()
		local earmoon = ni.data.darhanger.warlock.earmoon()
		if (ni.unit.isboss("target") 
		or UnitHealthMax("target") > 750000)
		 and ni.unit.ttd("target") > 65
		 and ((CotE and not elem) or eplag or earmoon)
		 and ni.spell.available(47867)
		 and ni.spell.isinstant(47867)
		 and ni.data.darhanger.CDsaver("target")
		 and ni.spell.valid("target", 47867, false, true, true)	
		 and GetTime() - ni.data.darhanger.warlock.LastCurse > 1 then
			ni.spell.cast(47867, "target")
			ni.data.darhanger.warlock.LastCurse = GetTime()
			return true
		end
	end,
-----------------------------------
	["Curse of Agony"] = function()
		local elem = ni.data.darhanger.warlock.elem()
		local doom = ni.data.darhanger.warlock.doom()
		local agony = ni.data.darhanger.warlock.agony()
		if not elem
		 and not doom
		 and not agony
		 and ni.unit.ttd("target") < 60
		 and ni.spell.available(47864)
		 and ni.spell.isinstant(47864)
		 and ni.spell.valid("target", 47864, false, true, true)
		 and GetTime() - ni.data.darhanger.warlock.LastCurse > 1 then
			ni.spell.cast(47864, "target")
			ni.data.darhanger.warlock.LastCurse = GetTime()
			return true
		end
	end,
-----------------------------------
	["Corruption AoE"] = function()
		if ni.rotation.custommod()
		 and ni.unit.exists("target")
		 and ni.spell.available(47813)
		 and ni.spell.isinstant(47813)
		 and UnitCanAttack("player", "target") then
		    table.wipe(enemies); 
			enemies = ni.unit.enemiesinrange("target", 15)
			for i = 1, #enemies do
				local tar = enemies[i].guid;
				if ni.unit.creaturetype(enemies[i].guid) ~= 8
				 and ni.unit.creaturetype(enemies[i].guid) ~= 11
				 and not ni.unit.debuffs(tar, "23920||35399||69056", "EXACT")
				 and not ni.unit.debuff(tar, 47813, "player") 
				 and ni.spell.valid(enemies[i].guid, 47813, false, true, true) then
					ni.spell.cast(47813, tar)
					return true
				end
			end
		end
	end,
-----------------------------------
	["Shadow Bolt (Shadow Mastery Check)"] = function()
		local winterChill, _, _, winterChill_stacks = ni.unit.debuff("target", 12579)
		if select(5, GetTalentInfo(3,1)) >= 4
		 and (not winterChill or winterChill_stacks == 5)
		 and not ni.unit.debuff("target", 22959)
		 and not ni.unit.debuff("target", 17800)		 
		 and ni.spell.available(47809)
		 and ni.unit.debuffremaining("target", 17800) < 2.5
		 and ni.spell.valid("target", 47809, true, true)
		 and GetTime() - ni.data.darhanger.warlock.LastShadowbolt > 3 then
			ni.spell.cast(47809, "target")
			ni.data.darhanger.warlock.LastShadowbolt = GetTime()
			return true
		end
	end,
-----------------------------------
	["Immolate"] = function()
		if not ni.player.ismoving()
		 and ni.unit.debuffremaining("target", 47811, "player") < ni.spell.casttime(47811)
		 and ni.spell.available(47811)
		 and ni.spell.valid("target", 47811, true, true)
		 and GetTime() - ni.data.darhanger.warlock.Lastimmolate > 2.1 then
			ni.spell.cast(47811, "target")
			ni.data.darhanger.warlock.Lastimmolate = GetTime()
			return true
		end
	end,
-----------------------------------
	["Corruption"] = function()
		local corruption = ni.data.darhanger.warlock.corruption()
		local seed = ni.data.darhanger.warlock.seed()	
		if ni.spell.available(47813)
		 and not corruption
		 and not seed
		 and ni.spell.isinstant(47813)
		 and ni.spell.valid("target", 47813, false, true, true)
		 and GetTime() - ni.data.darhanger.warlock.LastCorrupt > 1.5 then
			ni.spell.cast(47813, "target")
			ni.data.darhanger.warlock.LastCorrupt = GetTime()
			return true
		end
	end,
-----------------------------------
	["Soul Fire (Decimination + Molten Core)"] = function()	
		if ni.player.buff(63167)
		 and ni.unit.buffremaining("player", 63167) > ni.spell.casttime(47825)
		 and ni.player.buff(71165)
		 and not ni.player.ismoving()
		 and ni.spell.available(47825)
		 and ni.spell.valid("target", 47825, true, true) then
			ni.spell.cast(47825, "target")
			return true
		end
	end,
-----------------------------------
	["Soul Fire (Decimination)"] = function()	
		if ni.player.buff(63167)
		 and ni.unit.buffremaining("player", 63167) > ni.spell.casttime(47825)
		 and not ni.player.ismoving()
		 and ni.spell.available(47825)
		 and ni.spell.valid("target", 47825, true, true) then
			ni.spell.cast(47825, "target")
			return true
		end
	end,	
-----------------------------------
	["Incinerate (No Decimination)"] = function()
		local immolate = ni.data.darhanger.warlock.immolate()
		if ni.player.buff(71165)
		 and immolate
		 and (not ni.player.buff(63167)
		 or ni.unit.buffremaining("player", 63167) <= ni.spell.casttime(47825))
		 and ni.unit.hp("target") < 35
		 and not ni.player.ismoving()
		 and ni.spell.available(47838)
		 and ni.spell.valid("target", 47838, true, true) then
			ni.spell.cast(47838, "target")
			return true
		end
	end,
-----------------------------------
	["Incinerate"] = function()	
		local immolate = ni.data.darhanger.warlock.immolate()
		if ni.player.buff(71165)
		 and immolate
		 and ni.unit.hp("target") > 35
		 and not ni.player.ismoving()
		 and ni.spell.available(47838)
		 and ni.spell.valid("target", 47838, true, true) then
			ni.spell.cast(47838, "target")
			return true
		end
	end,
-----------------------------------
	["Shadow Bolt"] = function()		
		if (not ni.player.buff(63167)
		 or ni.unit.buffremaining("player", 63167) <= ni.spell.casttime(47825))
		 and not ni.player.buff(71165)
		 and not ni.player.ismoving()
		 and ni.spell.available(47809)
		 and ni.spell.valid("target", 47809, true, true) then
			ni.spell.cast(47809, "target")
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
		    or ni.unit.creaturetype(enemies[i].guid) == 4)
		    and ni.unit.debuff(tar, 18647, "player") then
			dontBanish = true
			break
		end
        end
		if not dontBanish then
		 for i = 1, #enemies do
		 local tar = enemies[i].guid; 
		  if (ni.unit.creaturetype(enemies[i].guid) == 3
		   or ni.unit.creaturetype(enemies[i].guid) == 4)
		   and not ni.unit.isboss(tar)
		   and not ni.unit.debuffs(tar, "23920||35399||69056", "EXACT")
		   and not ni.unit.debuff(tar, 18647, "player")
		   and ni.spell.valid(enemies[i].guid, 18647, false, true, true)
		   and GetTime() - ni.data.darhanger.warlock.LastBanish > 1.5 then
				ni.spell.cast(18647, tar)
				ni.data.darhanger.warlock.LastBanish = GetTime()
                        return true
					end
				end
			end
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Demonology Warlock by DarhangeR for 3.3.5a", 
		 "Welcome to Demonology Warlock Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For use Corruption (AoE) mode configure Custom Key Modifier and hold it for put spell on nearest enemies.\n-For use Rain of Fire configure AoE Toggle key.\n-Focus target for use Soulstone.\n-For better experience make Pet passive.")
		popup_shown = true;
		end 
	end,
}
  
ni.bootstrap.rotation("Demon_DarhangeR", queue, abilities, data, { [1] = "Demonology Warlock by DarhangeR", [2] = items });