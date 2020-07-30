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
	settingsfile = "DarhangeR_FeralCat.xml",
	{ type = "title", text = "Feral Cat Druid by DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Auto Form", enabled = true, key = "autoform" },
	{ type = "entry", text = "Innervate (Auto-Cast on Healers)", enabled = false, value = 35, key = "innervateheal" },
	{ type = "separator" },
	{ type = "title", text = "Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Barkskin", enabled = true, value = 35, key = "barkskin" },
	{ type = "entry", text = "Survival Instincts", enabled = true, value = 30, key = "survivial" },
	{ type = "entry", text = "Healthstone", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", enabled = true, value = 30, key = "healpotionuse" },
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
	"Gift of the Wild",
	"Thorns",
	"Cat Form",
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Innervate",
	"Barkskin",
	"Survival Instincts",
	"Faerie Fire",
	"Berserk",
	"Tigers Fury",		
	"Savage Roar",
	"Swipe (Cat)",
	"Rip",
	"Savage Roar()",
	"Mangle (Cat)",
	"Rake",
	"Shred",
	"Ferocious Bite",
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
	["Gift of the Wild"] = function()
		if ni.player.buff(48470)
		 or not IsUsableSpell(GetSpellInfo(48470)) 
		 and not ni.data.darhanger.DruidStuff("player") then 
		 return false
	end
		if ni.spell.available(48470)
		 and ni.spell.isinstant(48470) then
			ni.spell.cast(48470)	
			return true
		end
	end,
-----------------------------------
	["Thorns"] = function()
		if not ni.player.buff(53307)
		 and ni.spell.available(53307)
		 and ni.spell.isinstant(53307)
		 and not ni.data.darhanger.DruidStuff("player") then
			ni.spell.cast(53307)
			return true
		end
	end,
-----------------------------------
	["Cat Form"] = function()
		local _, enabled = GetSetting("autoform");
		if enabled
		 and not ni.player.buff(768)
		 and ni.spell.isinstant(768)
		 and ni.spell.available(768) 
		 and not ni.data.darhanger.DruidStuff("player") then
			ni.spell.cast(768)
			return true
		end
	end,
-----------------------------------
	["Innervate"] = function()
		local valueH, enabledH = GetSetting("innervateheal");
		if enabledH
		 and ni.spell.isinstant(29166)
		 and ni.spell.available(29166) then
		  for i = 1, #ni.members do
		  local ally = ni.members[i].unit
		   if ni.data.darhanger.ishealer(ally)
		    and ni.unit.power(ally) < valueH
		    and not ni.unit.buff(ally, 29166)
			and not ni.unit.buff(ally, 54428)
			and ni.spell.valid(ally, 29166, false, true, true) then
				ni.spell.cast(29166, ally)
				return true
				end
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
		 and IsSpellInRange(GetSpellInfo(49800), "target") == 1 then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if IsSpellInRange(GetSpellInfo(49800), "target") == 1
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
		 and IsSpellInRange(GetSpellInfo(49800), "target") == 1 then
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
		 and IsSpellInRange(GetSpellInfo(49800), "target") == 1 then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0
		 and ni.data.darhanger.CDsaverTTD("target")
		 and IsSpellInRange(GetSpellInfo(49800), "target") == 1 then
			ni.player.useinventoryitem(14)
			return true
			end
		end
	end,
-----------------------------------
	["Barkskin"] = function()
		local value, enabled = GetSetting("barkskin");
		if enabled
		 and ni.player.hp() < value
		 and ni.spell.isinstant(22812)
		 and ni.spell.available(22812) then
			ni.spell.cast(22812)
			return true
		end
	end,
-----------------------------------
	["Survival Instincts"] = function()
		local value, enabled = GetSetting("survivial");
		if enabled
		 and ni.player.hp() < value
		 and ni.spell.isinstant(61336)
		 and ni.spell.available(61336) then
			ni.spell.cast(61336)
			return true
		end
	end,
-----------------------------------
	["Faerie Fire"] = function()
		local mFaerieFire = ni.data.darhanger.druid.mFaerieFire() 
		local fFaerieFire = ni.data.darhanger.druid.fFaerieFire() 
		if not fFaerieFire
		 and not mFaerieFire
		 and ni.spell.isinstant(16857)
		 and ni.spell.available(16857) then
			ni.spell.cast(16857, "target")
			return true
		end
	end,
-----------------------------------
	["Tigers Fury"] = function()
		local berserk = ni.data.darhanger.druid.berserk()
		if berserk == nil
		 and ni.spell.isinstant(50213)
		 and ni.spell.available(50213)
		 and ni.player.power() < 30 then
			ni.spell.cast(50213)
			return true
		end
	end,
-----------------------------------
	["Berserk"] = function()
		local berserk = ni.data.darhanger.druid.berserk()
		local savage = ni.data.darhanger.druid.savage() 
		local tiger = ni.data.darhanger.druid.tiger() 
		local rip = ni.data.darhanger.druid.rip()
		local BleedBuff = ni.data.darhanger.druid.BleedBuff()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and tiger == nil
		 and BleedBuff
		 and ni.spell.isinstant(50334)
		 and ni.spell.available(50334)
		 and ni.player.power() < 35
		 and ( savage ~= nil and savage - GetTime() > 8 )
		 and ( rip ~= nil and rip - GetTime() > 8 ) 
		 and ni.data.darhanger.CDsaverTTD("target") then
			ni.spell.cast(50334)
			return true
		end
	end,
-----------------------------------
	["Ferocious Bite"] = function()
		local savage = ni.data.darhanger.druid.savage() 
		local rip = ni.data.darhanger.druid.rip()
		local BleedBuff = ni.data.darhanger.druid.BleedBuff()
		if ni.spell.available(48577)
		 and BleedBuff
		 and ( savage ~= nil and ( savage - GetTime() > 11 ) )
		 and ( rip ~= nil and ( rip - GetTime() > 8 ) )
		 and ni.spell.isinstant(48577)
		 and GetComboPoints("player") >= 5
		 and ni.spell.valid("target", 48574, true, true) then
			ni.spell.cast(48577, "target")
			return true
		end
	end,
-----------------------------------
	["Savage Roar"] = function()
		local savage = ni.data.darhanger.druid.savage() 
		local BleedBuff = ni.data.darhanger.druid.BleedBuff()
		if ni.spell.available(52610)
		 and BleedBuff
		 and ( savage == nil or ( savage - GetTime() <= 2 ) )
		 and GetComboPoints("player") >= 1
		 and ni.spell.isinstant(48574)
		 and ni.spell.valid("target", 48574, true, true) then
			ni.spell.cast(52610)
			return true
		end
	end,
-----------------------------------
	["Rip"] = function()
		local BleedBuff = ni.data.darhanger.druid.BleedBuff()
		local rip = ni.data.darhanger.druid.rip()
		if GetComboPoints("player") >= 5
		 and ni.spell.available(52610)
		 and BleedBuff
		 and ( rip == nil or ( rip - GetTime() <= 2 ) )
		 and ni.spell.isinstant(49800)
		 and ni.spell.valid("target", 49800, true, true) then
			ni.spell.cast(49800, "target")
			return true
		end
	end,
-----------------------------------
	["Savage Roar()"] = function()
		local savage = ni.data.darhanger.druid.savage() 
		local BleedBuff = ni.data.darhanger.druid.BleedBuff()
		local rip = ni.data.darhanger.druid.rip()
		if ni.spell.available(52610)
		 and GetComboPoints("player") >= 3
		 and BleedBuff
		 and ( savage == nil or ( savage - GetTime() <= 8 ) )
		 and ( savage == nil or ( savage and rip == nil ) 
		 or ( savage and rip and rip - GetTime() >= -3 ) ) 
		 and ni.spell.isinstant(52610)
		 and ni.spell.valid("target", 48574, true, true) then
			ni.spell.cast(52610)
			return true
		end
	end,
-----------------------------------
	["Mangle (Cat)"] = function()
		local BleedBuff = ni.data.darhanger.druid.BleedBuff()
		if ni.spell.available(48566)
		 and BleedBuff == nil
		 and ni.spell.isinstant(48566)		 
		 and ni.spell.valid("target", 48566, true, true) then
			ni.spell.cast(48566, "target")
			return true
		end
	end,
-----------------------------------
	["Swipe (Cat)"] = function()
		if ni.spell.available(62078)
		 and ActiveEnemies() > 1
		 and ni.spell.isinstant(62078)	
		 and ni.spell.valid("target", 48566, true, true) then
			ni.spell.cast(62078, "target")
			return true
		end
	end,
-----------------------------------
	["Rake"] = function()
		local BleedBuff = ni.data.darhanger.druid.BleedBuff()
		local rake = ni.data.darhanger.druid.rake()
		if ni.spell.available(48574)
		 and BleedBuff
		 and ni.spell.isinstant(48574)	
		 and ( rake == nil or ( rake - GetTime() <= 1 ) )
		 and ni.spell.valid("target", 48574, true, true) then
			ni.spell.cast(48574, "target")
			return true
		end
	end,
-----------------------------------
	["Shred"] = function()
		local savage = ni.data.darhanger.druid.savage()
		local BleedBuff = ni.data.darhanger.druid.BleedBuff()
		local rake = ni.data.darhanger.druid.rake()
		local rip = ni.data.darhanger.druid.rip()
		local berserk = ni.data.darhanger.druid.berserk()
		if ni.spell.available(48572)
		 and BleedBuff
		 and ((GetComboPoints("player") <= 4
		 or ( rip - GetTime() <= 1 ) )
		 and rake ~= nil
		 and rake - GetTime() > 0.5
		 and ( ni.player.power() >= 80 or berserk
		 or (ni.spell.cd(50213) == 0
		 or ni.spell.cd(50213) <= 3 ) )
		 or ( GetComboPoints("player") <= 0 
		 and ( savage == nil 
		 or ( savage - GetTime() <= 2 ) ) ) ) 
		 and ni.spell.valid("target", 48566) then 
			if ni.player.isbehind("target") then
				ni.spell.cast(48572, "target")
				return true
			else
				ni.spell.cast(48566, "target")
				return true
			end
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Feral Cat Druid by DarhangeR for 3.3.5a", 
		 "Welcome to Feral Cat Druid Profile! Support and more in Discord > https://discord.gg/TEQEJYS.")
		popup_shown = true;
		end 
	end,
}

ni.bootstrap.rotation("Feral_Cat_DarhangeR", queue, abilities, data, { [1] = "Feral Cat Druid by DarhangeR", [2] = items });