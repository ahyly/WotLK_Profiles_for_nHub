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
	settingsfile = "DarhangeR_FeralBear.xml",
	{ type = "title", text = "Feral Bear Druid by DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Auto Form", enabled = true, key = "autoform" },	
	{ type = "separator" },
	{ type = "title", text = "Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Barkskin", enabled = true, value = 35, key = "barkskin" },
	{ type = "entry", text = "Survival Instincts", enabled = true, value = 30, key = "survivial" },
	{ type = "entry", text = "Healthstone", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "separator" },
	{ type = "title", text = "Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Growl (Auto Agro)", enabled = false, key = "grow" },
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
	"Bear Form",
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Racial Stuff",
	"Barkskin",
	"Frenzied Regeneration",
	"Survival Instincts",
	"Growl",
	"Growl (Ally)",
	"Faerie Fire",
	"Enrage",
	"Demoralizing Roar",
	"Mangle (Bear)",
	"Swipe (Bear)",
	"Lacerate",
	"Maul",
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
		 and not UnitAffectingCombat("player")
		 and not ni.data.darhanger.DruidStuff("player") then
			ni.spell.cast(53307)
			return true
		end
	end,
-----------------------------------
	["Bear Form"] = function()
		local _, enabled = GetSetting("autoform");
		if enabled
		 and not ni.player.buff(9634)
		 and ni.spell.isinstant(9634)
		 and ni.spell.available(9634)
		 and not ni.data.darhanger.DruidStuff("player") then
			ni.spell.cast(9634)
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
	["Frenzied Regeneration"] = function()
		if ni.player.buff(61336)
		 and ni.spell.isinstant(22842)
		 and ni.spell.available(22842) then
			ni.spell.cast(22842)
			return true
		end
	end,
-----------------------------------
	["Enrage"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.power() < 65
		 and ni.spell.isinstant(5229)
		 and ni.spell.available(5229)
		 and IsSpellInRange(GetSpellInfo(48564), "target") == 1 then
			ni.spell.cast(5229)
			return true
		end
	end,
-----------------------------------
	["Growl"] = function()
		if ni.unit.exists("targettarget") 
		 and not UnitIsDeadOrGhost("targettarget")
		 and UnitAffectingCombat("player")
		 and (ni.unit.debuff("targettarget", 72410) 
		 or ni.unit.debuff("targettarget", 72411) 
		 or ni.unit.threat("player", "target") < 2 )
		 and ni.spell.available(6795)
		 and ni.spell.isinstant(6795)
		 and ni.data.darhanger.youInInstance()
		 and ni.spell.valid("target", 6795, false, true, true) then
			ni.spell.cast(6795)
			return true
		end
	end,
-----------------------------------
	["Growl (Ally)"] = function()
		local _, enabled = GetSetting("grow")
   		if ni.spell.available(6795)
		 and ni.spell.isinstant(6795)
		 and (ni.data.darhanger.youInInstance()
		 or enabled) then
		 table.wipe(enemies);
		 local enemies = ni.unit.enemiesinrange("player", 30)
		  for i = 1, #enemies do
		  local threatUnit = enemies[i].guid
   		   if ni.unit.threat("player", threatUnit) ~= nil 
   		    and ni.unit.threat("player", threatUnit) <= 2
   		    and UnitAffectingCombat(threatUnit) 
   		    and ni.spell.valid(threatUnit, 6795, false, true, true) then
				ni.spell.cast(6795, threatUnit)
				return true
				end
			end
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
	["Swipe (Bear)"] = function()
		if ni.spell.available(48562)
		 and ActiveEnemies() >= 1
		 and IsSpellInRange(GetSpellInfo(48564), "target") == 1 then
			if ni.spell.available(48480, true)
			 and not IsCurrentSpell(48480) then 
				ni.spell.cast(48480, "target")
		end
				ni.spell.cast(48562, "target")
			return true;
		end
	end,
-----------------------------------
	["Mangle (Bear)"] = function()
		if ni.spell.available(48564)
		 and ni.spell.isinstant(48564)
		 and ni.spell.valid("target", 48564, true, true) then
			ni.spell.cast(48564, "target")
			return true
		end
	end,		
-----------------------------------
	["Lacerate"] = function()
		local lacerate, _, _, count = ni.unit.debuff("target", 48568, "player")
		local bmangle = ni.data.darhanger.druid.bmangle()  
		if (lacerate == nil
		 or count < 5 or ni.unit.debuffremaining("target", 48568, "player") < 3)
		 and bmangle
		 and ni.spell.isinstant(48568)
		 and ni.spell.available(48568)
		 and ni.spell.valid("target", 48568, true, true) then 
			ni.spell.cast(48568, "target")
			return true
		end
	end,
-----------------------------------
	["Demoralizing Roar"] = function()
		if ni.unit.exists("target")
		 and UnitCanAttack("player", "target") then
			table.wipe(enemies);
			enemies = ni.unit.enemiesinrange("target", 8)
			for i = 1, # enemies do
				local tar = enemies[i].guid;
				if ni.unit.creaturetype(enemies[i].guid) ~= 8 
				 and not ni.unit.debuff(tar, 48560)
				 and GetTime() - ni.data.darhanger.druid.LastShout > 4
				 and ni.spell.available(48560) then
					ni.spell.cast(48560, tar)
					ni.data.darhanger.druid.LastShout = GetTime()
					return true
				end
			end
		end
	end,
-----------------------------------
	["Maul"] = function()
		if ni.spell.available(48480, true)
		 and not IsCurrentSpell(48480)
		 and IsSpellInRange(GetSpellInfo(48564), "target") == 1 then
			ni.spell.cast(48480, "target")
			return true
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Feral Bear Druid by DarhangeR for 3.3.5a", 
		 "Welcome to Feral Bear Druid Profile! Support and more in Discord > https://discord.gg/TEQEJYS.")
		popup_shown = true;
		end 
	end,
}

ni.bootstrap.rotation("Feral_Bear_DarhangeR", queue, abilities, data, { [1] = "Feral Bear Druid by DarhangeR", [2] = items });