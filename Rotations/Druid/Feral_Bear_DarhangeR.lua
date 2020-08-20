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
	settingsfile = "DarhangeR_FeralBear.xml",
	{ type = "title", text = "Feral Bear Druid by |c0000CED1DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "|cffFFFF00Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Auto Form", tooltip = "Auto use proper form", enabled = true, key = "autoform" },	
	{ type = "entry", text = "Debug Printing", tooltip = "Enable for debug if you have problems", enabled = false, key = "Debug" },		
	{ type = "separator" },
	{ type = "title", text = "|cff00C957Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Barkskin", tooltip = "Use spell when player HP < %", enabled = true, value = 35, key = "barkskin" },
	{ type = "entry", text = "Survival Instincts", tooltip = "Use spell when player HP < %", enabled = true, value = 30, key = "survivial" },
	{ type = "entry", text = "Healthstone", tooltip = "Use Warlock Healthstone (if you have) when player HP < %", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", tooltip = "Use Heal Potions (if you have) when player HP < %", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "separator" },
	{ type = "title", text = "|cffEE4000Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Growl (Auto Agro)", tooltip = "Auto use spell to agro enemies in 30 yard radius", enabled = false, key = "grow" },
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
	ni.GUI.AddFrame("Feral_Bear_DarhangeR", items);
end
local function OnUnLoad()  
	ni.GUI.DestroyFrame("Feral_Bear_DarhangeR");
end

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
	["Gift of the Wild"] = function()
		if ni.player.buff(48470)
		 or not IsUsableSpell(GetSpellInfo(48470)) 
		 and not data.druid.DruidStuff("player") then 
		 return false
	end
		if ni.spell.available(48470) then
			ni.spell.cast(48470)	
			return true
		end
	end,
-----------------------------------
	["Thorns"] = function()
		if not ni.player.buff(53307)
		 and ni.spell.available(53307)
		 and not UnitAffectingCombat("player")
		 and not data.druid.DruidStuff("player") then
			ni.spell.cast(53307)
			return true
		end
	end,
-----------------------------------
	["Bear Form"] = function()
		local _, enabled = GetSetting("autoform");
		if enabled
		 and not ni.player.buff(9634)
		 and ni.spell.available(9634)
		 and not data.druid.DruidStuff("player") then
			ni.spell.cast(9634)
			return true
		end
	end,
-----------------------------------
	["Combat specific Pause"] = function()
		if data.tankStop("target")
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
		 and ni.spell.available(22812) 
		 and not ni.player.buff(22812) then
			ni.spell.cast(22812)
			return true
		end
	end,
-----------------------------------
	["Survival Instincts"] = function()
		local value, enabled = GetSetting("survivial");
		if enabled
		 and ni.player.hp() < value
		 and ni.spell.available(61336)
		 and not ni.player.buff(61336) then
			ni.spell.cast(61336)
			return true
		end
	end,
-----------------------------------
	["Frenzied Regeneration"] = function()
		if ni.player.buff(61336)
		 and ni.spell.available(22842) then
			ni.spell.cast(22842)
			return true
		end
	end,
-----------------------------------
	["Enrage"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.power() < 65
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
		 and data.youInInstance()
		 and ni.spell.valid("target", 6795, false, true, true) then
			ni.spell.cast(6795)
			return true
		end
	end,
-----------------------------------
	["Growl (Ally)"] = function()
		local _, enabled = GetSetting("grow")
   		if ni.spell.available(6795)
		 and (data.youInInstance()
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
		local mFaerieFire = data.druid.mFaerieFire() 
		local fFaerieFire = data.druid.fFaerieFire() 
		if not fFaerieFire
		 and not mFaerieFire
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
		 and ni.spell.valid("target", 48564, true, true) then
			ni.spell.cast(48564, "target")
			return true
		end
	end,		
-----------------------------------
	["Lacerate"] = function()
		local lacerate, _, _, count = ni.unit.debuff("target", 48568, "player")
		local BleedBuff = data.druid.BleedBuff("target")
		if (not lacerate
		 or count < 5 or ni.unit.debuffremaining("target", 48568, "player") < 3 )
		 and BleedBuff
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
				 and GetTime() - data.druid.LastShout > 4
				 and ni.spell.available(48560) then
					ni.spell.cast(48560, tar)
					data.druid.LastShout = GetTime()
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

	ni.bootstrap.profile("Feral_Bear_DarhangeR", queue, abilities, OnLoad, OnUnLoad);
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
    ni.bootstrap.profile("Feral_Bear_DarhangeR", queue, abilities);
end