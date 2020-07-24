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
	settingsfile = "DarhangeR_ProtoPaladin.xml",
	{ type = "title", text = "Protection Paladin by DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "Main Settings" },
	{ type = "separator" },	
	{ type = "entry", text = "Divine Plea", enabled = true, key = "plea" },
	{ type = "entry", text = "Sacred Shield", enabled = true, key = "sacred" },
	{ type = "separator" },
	{ type = "title", text = "Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Lay on Hands (Self)", enabled = true, value = 20, key = "layon" },
	{ type = "entry", text = "Divine Protection", enabled = true, value = 35, key = "divineprot" },
	{ type = "entry", text = "Divine Sacrifice", enabled = true, key = "sacrifice" },
	{ type = "entry", text = "Divine Sacrifice (Members HP)", value = 45, key = "sacrificehp" },
	{ type = "entry", text = "Divine Sacrifice (Members Count)", value = 4, key = "sacrificecount" },
	{ type = "entry", text = "Hand of Salvation (Member)", enabled = true, key = "salva" },
	{ type = "entry", text = "Healthstone", enabled = true, value = 35, key = "healthstoneuse" },	
	{ type = "entry", text = "Heal Potion", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "entry", text = "Mana Potion", enabled = true, value = 25, key = "manapotionuse" },
	{ type = "separator" },
	{ type = "title", text = "Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Hand of Reckoning (Auto Agro)", enabled = false, key = "hand" },
	{ type = "entry", text = "Righteous Defence (Auto Agro)", enabled = true, key = "def" },	
	{ type = "entry", text = "Consecration", enabled = true, key = "concentrat" },
	{ type = "entry", text = "Mana threshold for use", value = 30, key = "concentratmana" },
	{ type = "separator" },
	{ type = "title", text = "Dispel" },
	{ type = "separator" },
	{ type = "entry", text = "Cleanse (Self)", enabled = true, key = "cleans" },
	{ type = "entry", text = "Hand of Freedom (Self)", enabled = true, key = "freedom" },
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
	"Righteous Fury",
	"Sacred Shield",
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Mana Potions (Use)",
	"Racial Stuff",
	"Lay on Hands (Self)",
	"Divine Protection",
	"Divine Sacrifice",
	"Divine Plea",
	"Hand of Reckoning (Ally)",
	"Hand of Reckoning",
	"Righteous Defence",
	"Hand of Salvation (Member)",
	"Avenging Wrath",
	"Holy Wrath",
	"Consecration",
	"Avenger's Shield",
	"Judgements (PRO)",
	"Holy Shield",	
	"Hammer of the Righteous",
	"Hand of Freedom (Self)",
	"Cleanse (Self)",
	"Shield of Righteousness",
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
		local enemies = ni.unit.enemiesinrange("target", 5)
		if #enemies < 1
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
		if #enemies < 1
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
		local enemies = ni.unit.enemiesinrange("target", 5)
		if #enemies > 1	
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
	["Righteous Fury"] = function()
		if not ni.player.buff(25780)
		 and ni.spell.isinstant(25780)
		 and ni.spell.available(25780) then 		
			ni.spell.cast(25780)
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
		 and ni.spell.valid("target", 53595, true, true) then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if ni.spell.valid("target", 53595, true, true)
		 and ni.player.hp() < 20
		 and IsSpellKnown(alracial[i])
		 and ni.spell.available(alracial[i]) then 
					ni.spell.cast(alracial[i])
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
	["Divine Sacrifice"] = function()
		local _, enabled = GetSetting("sacrifice");
		local valueHp = GetSetting("sacrificehp");
		local valueCount = GetSetting("sacrificecount");
		if enabled
		 and ni.player.hp() > 30
		 and ni.members.averageof(valueCount) < valueHp
		 and ni.spell.isinstant(64205)
		 and ni.spell.available(64205) then
			ni.spell.cast(64205)
			return true
		end
	end,
-----------------------------------
	["Divine Plea"] = function()
		local _, enabled = GetSetting("plea");
		if enabled
		 and not ni.player.buff(54428)
		 and ni.spell.isinstant(54428) 		 
		 and ni.spell.available(54428) then
			ni.spell.cast(54428)
			return true
		end
	end,
-----------------------------------
	["Hand of Reckoning"] = function()
		if ni.unit.exists("targettarget") 
		 and not UnitIsDeadOrGhost("targettarget")
		 and UnitAffectingCombat("player")
		 and (ni.unit.debuff("targettarget", 72410) 
		 or ni.unit.debuff("targettarget", 72411) 
		 or ni.unit.threat("player", "target") < 2 )
  		 and ni.spell.available(62124)
		 and ni.spell.isinstant(62124)
		 and ni.data.darhanger.youInInstance()
		 and ni.spell.valid("target", 62124, false, true, true) then
			ni.spell.cast(62124)
			return true
		end
	end,
-----------------------------------
	["Hand of Reckoning (Ally)"] = function()
		local _, enabled = GetSetting("hand")
   		if ni.spell.available(62124)
		 and ni.spell.isinstant(62124)
		 and (ni.data.darhanger.youInInstance()
		 or enabled) then
		 table.wipe(enemies);
		 local enemies = ni.unit.enemiesinrange("player", 30)
		  for i = 1, #enemies do
		  local threatUnit = enemies[i].guid
   		   if ni.unit.threat("player", threatUnit) ~= nil 
   		    and ni.unit.threat("player", threatUnit) <= 2
   		    and UnitAffectingCombat(threatUnit) 
   		    and ni.spell.valid(threatUnit, 62124, false, true, true) then
				ni.spell.cast(62124, threatUnit)
				return true
				end
			end
		end
	end,
-----------------------------------
	["Righteous Defence"] = function()
		local _, enabled = GetSetting("def")		
		if (ni.data.darhanger.youInInstance()
		 or enabled)
		 and ni.spell.available(31789)
		 and ni.spell.isinstant(31789) then
		 for i = 1, #ni.members do
		  if not UnitIsDeadOrGhost(ni.members[i].unit) then
		   local tarCount = #ni.unit.unitstargeting(ni.members[i].guid)
		   if tarCount ~= nil 
		    and tarCount >= 1
		    and not ni.members[i].istank
		    and ni.unit.threat(ni.members[i].guid) >= 2
		    and ni.spell.valid(ni.members[i].unit, 31789, false, true, true) then
					ni.spell.cast(31789, ni.members[i].unit)
					return true
					end
				end
			end
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
	["Holy Wrath"] = function()
		if ni.vars.combat.aoe
		 and ni.spell.available(48817)
		 and ni.spell.isinstant(48817)
		 and ni.spell.valid("target", 53595) then
			ni.spell.cast(48817, "target")
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
		 and ni.spell.valid("target", 53595) then
			ni.spell.cast(48819)
			return true
		end
	end,
-----------------------------------
	["Avenger's Shield"] = function()
		if ActiveEnemies() > 1
		 and ni.spell.isinstant(48827)
		 and ni.spell.available(48827)
		 and ni.spell.valid("target", 48827) then
			ni.spell.cast(48827, "target")
			return true
		end
	end,
-----------------------------------
	["Judgements (PRO)"] = function()
		if ni.spell.available(20271)
		 and ni.spell.isinstant(20271)		
		 and ni.spell.valid("target", 20271, false, true, true) then
			if ni.player.power() < 30
			and ni.player.hp() >= 70 then
				ni.spell.cast(53408, "target")
			else
				ni.spell.cast(20271, "target")
				return true
			end
		end
	end,
-----------------------------------
	["Holy Shield"] = function()
		if not ni.player.buff(48952)
		 and ni.spell.isinstant(48952)
		 and ni.spell.available(48952)
		 and ni.spell.valid("target", 53595) then
			ni.spell.cast(48952, "target")
			return true
		end
	end,
-----------------------------------
	["Hammer of the Righteous"] = function()
		if ni.spell.available(53595)
		 and ni.spell.isinstant(53595)
		 and ni.spell.valid("target", 53595, true, true) then
			ni.spell.cast(53595, "target")
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
	["Shield of Righteousness"] = function()
		if ni.spell.available(61411)
		 and ni.spell.isinstant(61411)
		 and ni.spell.valid("target", 61411, true, true) then
			ni.spell.cast(61411, "target")
			return true
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Protection Paladin by DarhangeR for 3.3.5a", 
		 "Welcome to Protection Paladin Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For use Holy Wrath configure AoE Toggle key.")
		popup_shown = true;
		end 
	end,
}

ni.bootstrap.rotation("Protection_DarhangeR", queue, abilities, data, { [1] = "Protection Paladin by DarhangeR", [2] = items });