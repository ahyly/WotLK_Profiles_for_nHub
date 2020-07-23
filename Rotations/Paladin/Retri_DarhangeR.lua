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
	settingsfile = "DarhangeR_Retri.xml",
	{ type = "title", text = "Retribution Paladin by DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "Main Settings" },
	{ type = "separator" },	
	{ type = "entry", text = "Divine Plea", enabled = true, value = 60, key = "plea" },
	{ type = "entry", text = "Sacred Shield", enabled = true, key = "sacred" },
	{ type = "separator" },
	{ type = "title", text = "Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Flash of Light (Self)", enabled = true, value = 90, key = "flashoflight" },
	{ type = "entry", text = "Lay on Hands (Self)", enabled = true, value = 25, key = "layon" },
	{ type = "entry", text = "Divine Shield", enabled = true, value = 12, key = "divineshield" },
	{ type = "entry", text = "Divine Protection", enabled = true, value = 30, key = "divineprot" },
	{ type = "entry", text = "Hand of Protection (Member)", enabled = true, value = 12, key = "handofprot" },
	{ type = "entry", text = "Hand of Salvation (Member)", enabled = true, key = "salva" },
	{ type = "entry", text = "Healthstone", enabled = true, value = 35, key = "healthstoneuse" },	
	{ type = "entry", text = "Heal Potion", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "entry", text = "Mana Potion", enabled = true, value = 25, key = "manapotionuse" },
	{ type = "separator" },
	{ type = "title", text = "Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Consecration", enabled = true, key = "concentrat" },
	{ type = "entry", text = "Mana threshold for use", value = 30, key = "concentratmana" },
	{ type = "entry", text = "Holy Wrath (Auto Use)", enabled = false, key = "holywrath" },		
	{ type = "separator" },
	{ type = "title", text = "Dispel" },
	{ type = "separator" },
	{ type = "entry", text = "Cleanse (Self)", enabled = true, key = "cleans" },
	{ type = "entry", text = "Cleanse (Member)", enabled = false, key = "cleansmemb" },
	{ type = "entry", text = "Hand of Freedom (Self)", enabled = true, key = "freedom" },
	{ type = "entry", text = "Hand of Freedom (Member)", enabled = false, key = "freedommemb" },
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
	"Universal pause",
	"AutoTarget",
	"Seal of Corruption/Vengeance",
	"Seal of Command",
	"Cancel Righteous Fury",
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Mana Potions (Use)",
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Lay on Hands (Self)",
	"Divine Shield",
	"Divine Protection",
	"Flash of Light (Self)",
	"Hand of Protection (Member)",
	"Hand of Salvation (Member)",
	"Hand of Freedom (Member)",
	"Hand of Freedom (Self)",
	"Divine Plea",
	"Sacred Shield",
	"Avenging Wrath",
	"Hammer of Wrath",	
	"Judgement of Wisdom",
	"Holy Wrath (Auto Use)",	
	"Divine Storm",
	"Crusader Strike",
	"Holy Wrath (AoE)",
	"Cleanse (Member)",	
	"Cleanse (Self)",
	"Consecration",
	"Exorcism",
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
	["Seal of Corruption/Vengeance"] = function()
		if ActiveEnemies() < 2
		 and IsSpellKnown(53736)
		 and ni.spell.available(53736) then
		 if not ni.player.buff(53736)
		 and GetTime() - ni.data.darhanger.paladin.LastSeal > 3
		 and not ni.player.buff(31801) then
			ni.spell.cast(53736)
			ni.data.darhanger.paladin.LastSeal = GetTime()
			return true
		end
	end
		if ActiveEnemies() < 2
		and IsSpellKnown(31801)
		and ni.spell.available(31801) then
		if not ni.player.buff(31801) 
		 and GetTime() - ni.data.darhanger.paladin.LastSeal > 3
		 and not ni.player.buff(53736) then
			ni.spell.cast(31801)
			ni.data.darhanger.paladin.LastSeal = GetTime()
			return true
			end
		end
	end,
-----------------------------------
	["Seal of Command"] = function()
		if ActiveEnemies() > 1	
		 and IsSpellKnown(20375)
		 and ni.spell.available(20375)
		 and GetTime() - ni.data.darhanger.paladin.LastSeal > 3
		 and not ni.player.buff(20375) then 
			ni.spell.cast(20375)
			ni.data.darhanger.paladin.LastSeal = GetTime()
			return true
		end
	end,
-----------------------------------
	["Cancel Righteous Fury"] = function()
		local p="player" for i = 1,40 
		do local _,_,_,_,_,_,_,u,_,_,s=UnitBuff(p,i)
			if u==p and s==25780 then
				CancelUnitBuff(p,i) 
				break;
			end
		end 
	end,
-----------------------------------
	["Combat specific Pause"] = function()
		if ni.data.darhanger.meleeStop("target")
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
		 and IsSpellInRange(GetSpellInfo(35395), "target") == 1 then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if IsSpellInRange(GetSpellInfo(35395), "target") == 1
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
		 and IsSpellInRange(GetSpellInfo(35395), "target") == 1 then
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
		 and IsSpellInRange(GetSpellInfo(35395), "target") == 1 then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0 
		 and ni.data.darhanger.CDsaverTTD("target")
		 and IsSpellInRange(GetSpellInfo(35395), "target") == 1 then
			ni.player.useinventoryitem(14)
			return true
			end
		end
	end,
-----------------------------------
	["Lay on Hands (Self)"] = function()
		local value, enabled = GetSetting("layon");
		local forb = ni.data.darhanger.paladin.forb()
		if enabled
		 and ni.player.hp() < value
		 and not forb
		 and ni.spell.available(48788) then
			ni.spell.cast(48788)
			return true
		end
	end,
-----------------------------------
	["Divine Shield"] = function()
		local value, enabled = GetSetting("divineshield");
		local forb = ni.data.darhanger.paladin.forb()
		if enabled
		 and ni.player.hp() < value
		 and not forb
		 and ni.spell.available(642) then
			ni.spell.cast(642)
			return true
		end
	end,
-----------------------------------
	["Divine Protection"] = function()
		local value, enabled = GetSetting("divineprot");
		local forb = ni.data.darhanger.paladin.forb()
		if enabled
		 and ni.player.hp() < value
		 and not forb
		 and ni.spell.available(498) then
			ni.spell.cast(498)
			return true
		end
	end,
-----------------------------------
	["Flash of Light (Self)"] = function()
		local value, enabled = GetSetting("flashoflight");
		local aow = ni.data.darhanger.paladin.aow()
		if enabled
		 and ni.player.hp() < value
		 and aow
		 and ni.spell.isinstant(48785)
		 and not ni.spell.available(48801)
		 and ni.spell.available(48785) then
			ni.spell.cast(48785, "player")
			return true
		end
	end,
-----------------------------------
	["Hand of Salvation (Member)"] = function()
		local _, enabled = GetSetting("salva")
		if enabled
		 and #ni.members > 1
		 and ni.spell.isinstant(1038)			 
		 and ni.spell.available(1038) then
		  for i = 1, #ni.members do
		   if ni.members[i].threat >= 2
		   and not ni.members[i].istank
		   and not UnitIsDeadOrGhost(ni.members[i].unit)
		   and not ni.unit.buff(ni.members[i].unit, 1038)
		   and not ni.unit.buff(ni.members[i].unit, 6940)
		   and not ni.unit.buff(ni.members[i].unit, 10278)
		   and ni.spell.valid(ni.members[i].unit, 1038, false, true, true) then 
				ni.spell.cast(1038, ni.members[i].unit)
				return true
				end
			end
		end
	end,
-----------------------------------
	["Hand of Protection (Member)"] = function()
		local value, enabled = GetSetting("handprot");
		if enabled
		 and #ni.members > 1
		 and ni.spell.isinstant(10278)		 
		 and ni.spell.available(10278) then
		 for i = 1, #ni.members do
		  if ni.members[i].range
		  and ni.members[i].hp < value
		  and not ni.members[i].istank
		  and not UnitIsDeadOrGhost(ni.members[i].unit)
		  and not ni.unit.buff(ni.members[i].unit, 1038)
		  and not ni.unit.buff(ni.members[i].unit, 6940)
		  and not ni.unit.buff(ni.members[i].unit, 10278)
		  and not ni.unit.debuff(ni.members[i].unit, 25771)
		  and ni.spell.valid(ni.members[i].unit, 10278, false, true, true) then 
				ni.spell.cast(10278, ni.members[i].unit)
				return true
				end
			end
		end
	end,
-----------------------------------
	["Divine Plea"] = function()
		local value, enabled = GetSetting("plea");
		if enabled 
		 and ni.player.power() < value
		 and not ni.player.buff(54428)
		 and ni.spell.isinstant(54428) 		 
		 and ni.spell.available(54428) then
			ni.spell.cast(54428)
			return true
		end
	end,
-----------------------------------
	["Sacred Shield"] = function()
		local _, enabled = GetSetting("sacred")
		if enabled
		 and not ni.player.buff(53601)  
		 and ni.spell.isinstant(53601) 
		 and ni.spell.available(53601) then
			ni.spell.cast(53601, "player")
			return true
		end
	end,
-----------------------------------
	["Avenging Wrath"] = function()
		if ( ni.vars.CD or ni.unit.isboss("target") )
		 and ni.spell.isinstant(31884) 
		 and ni.spell.available(31884)
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ni.spell.valid("target", 35395) then
			ni.spell.cast(31884)
			return true
		end
	end,
-----------------------------------
	["Judgement of Wisdom"] = function()
		if ni.spell.available(53408)
		 and ni.spell.isinstant(53408) 
		 and ni.spell.valid("target", 53408, false, true, true) then
			ni.spell.cast(53408, "target")
			return true
		end
	end,
-----------------------------------
	["Divine Storm"] = function()
		if ni.spell.available(53385)
		 and ni.spell.isinstant(53385) 
		 and ni.spell.valid("target", 35395) then
			ni.spell.cast(53385, "target")
			return true
		end
	end,
-----------------------------------
	["Crusader Strike"] = function()
		if ni.spell.available(35395)
		 and ni.spell.isinstant(35395) 
		 and ni.spell.valid("target", 35395, true, true) then
			ni.spell.cast(35395, "target")
			return true
		end
	end,
-----------------------------------
	["Holy Wrath (Auto Use)"] = function()
		local _, enabled = GetSetting("concentrat")
		if enabled
		 and ni.spell.isinstant(48817)
		 and ni.spell.available(48817)
		 and (ni.unit.creaturetype("target") == 3
		 or ni.unit.creaturetype("target") == 6)
		 and ni.player.distance("target") < 5 then
			ni.spell.cast(48817)
			return true
		end
	end,
-----------------------------------
	["Holy Wrath (AoE)"] = function()
		if ni.vars.combat.aoe
		 and ni.spell.isinstant(48817)
		 and ni.spell.available(48817)
		 and ni.spell.valid("target", 35395, true, true) then
			ni.spell.cast(48817)
			return true
		end
	end,
-----------------------------------
	["Consecration"] = function()
		local _, enabled = GetSetting("concentrat")
		local value = GetSetting("concentratmana") 
        if enabled
		 and ni.player.power() > value
		 and ni.spell.isinstant(48819)
		 and ni.spell.available(48819)
		 and ni.spell.valid("target", 35395) then
			ni.spell.cast(48819, "target")
			return true
		end
	end,
-----------------------------------
	["Exorcism"] = function()
		local aow = ni.data.darhanger.paladin.aow()
		if aow
		 and ni.spell.isinstant(48801)
		 and ni.spell.available(48801)
		 and ni.spell.valid("target", 48801, true, true) then
			ni.spell.cast(48801, "target")
			return true
		end
	end,
-----------------------------------
	["Hammer of Wrath"] = function()
		if (ni.unit.hp("target") <= 20
		 or IsUsableSpell(GetSpellInfo(48806)))
		 and ni.spell.isinstant(48806)
		 and ni.spell.available(48806)
		 and ni.spell.valid("target", 48806, true, true) then
			ni.spell.cast(48806, "target")
			return true
		end
	end,
-----------------------------------	
	["Hand of Freedom (Self)"] = function()
		local _, enabled = GetSetting("freedom")
		if enabled
		 and ni.player.ismoving()
		 and ni.data.darhanger.FreedomUse("player")
		 and ni.spell.isinstant(1044)
		 and ni.spell.available(1044) then
			ni.spell.cast(1044, "player")
			return true
		end
	end,
-----------------------------------
    ["Hand of Freedom (Member)"] = function()
        local _, enabled = GetSetting("freedom")
        if enabled
		 and ni.spell.isinstant(1044)
         and ni.spell.available(1044) then
		  for i = 1, #ni.members do
			local ally = ni.members[i].unit
			 if ni.unit.ismoving(ally)
			  and ni.data.darhanger.FreedomUse(ally)
			  and ni.spell.valid(ally, 1044, false, true, true) then
					ni.spell.cast(1044, ally)
					return true
                end
            end
        end
    end,
-----------------------------------
	["Cleanse (Self)"] = function()
		local _, enabled = GetSetting("cleans")
		if enabled
		 and ni.player.debufftype("Magic|Disease|Poison")
		 and ni.spell.isinstant(4987)
		 and ni.spell.available(4987)
		 and ni.healing.candispel("player")
		 and GetTime() - ni.data.darhanger.LastDispel > 1.5
		 and ni.spell.valid("player", 4987, false, true, true) then
			ni.spell.cast(4987, "player")
			ni.data.darhanger.LastDispel = GetTime()
			return true
		end
	end,
-----------------------------------
	["Cleanse (Member)"] = function()
		local _, enabled = GetSetting("cleansmemb")
		if enabled
		 and ni.spell.isinstant(4987)		
		 and ni.spell.available(4987) then
		  for i = 1, #ni.members do
		  if ni.unit.debufftype(ni.members[i].unit, "Magic|Disease|Poison")
		  and ni.healing.candispel(ni.members[i].unit)
		  and GetTime() - ni.data.darhanger.LastDispel > 1.2
		  and ni.spell.valid(ni.members[i].unit, 4987, false, true, true) then
				ni.spell.cast(4987, ni.members[i].unit)
				ni.data.darhanger.LastDispel = GetTime()
				return true
				end
			end
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Retribution Paladin by DarhangeR for 3.3.5a", 
		 "Welcome to Retribution Paladin Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For use Holy Wrath configure AoE Toggle key.")
		popup_shown = true;
		end 
	end,
}

ni.bootstrap.rotation("Retri_DarhangeR", queue, abilities, data, { [1] = "Retribution Paladin by DarhangeR", [2] = items });