local data = {"DarhangeR.lua"}
local popup_shown = false;
local items = {
	settingsfile = "DarhangeR_Combat.xml",
	{ type = "title", text = "Combat Rogue by DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Auto Interrupt", enabled = true, key = "autointerrupt" },	
	{ type = "separator" },
	{ type = "title", text = "Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Healthstone", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "separator" },
	{ type = "title", text = "Build Settings" },
    { type = "dropdown", menu = {
        { selected = true, value = 1, text = "Eviscerate Build" },
        { selected = false, value = 2, text = "Rapture Build" },
    }, key = "builds" },
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

local EviscerateBuild = {
	"Window",
	"Universal pause",
	"AutoTarget",
	"Poison Weapon",
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Kick (Interrupt)",
	"Tricks of the Trade",
	"Fan of Knives",
	"Riposte",
	"Adrenaline Rush",
	"Blade Flurry",
	"Killing Spree",
	"Slice and Dice",
	"Sinister Strike",
	"Eviscerate",
}
local RaptureBuild = {
	"Window",
	"Universal pause",
	"AutoTarget",
	"Poison Weapon",
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Kick (Interrupt)",
	"Tricks of the Trade",
	"Fan of Knives",
	"Riposte",
	"Adrenaline Rush",
	"Blade Flurry",
	"Killing Spree",
	"Slice and Dice",
	"Sinister Strike",
	"Rupture",
	"Eviscerate Dump",
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
    ["Poison Weapon"] = function()
		local mh, _, _, oh = GetWeaponEnchantInfo()
		if applypoison 
		 and GetTime() - applypoison > 4 then 
			applypoison = nil 
		end
		if not UnitAffectingCombat("player") 
		and applypoison == nil then
		applypoison = GetTime()
		if mh == nil 
		 and ni.player.hasitem(43231) then
			ni.player.useitem(43231)
			ni.player.useinventoryitem(16)
			return true
		end
		if oh == nil
		 and ni.player.hasitem(43233) then
			ni.player.useitem(43233)
			ni.player.useinventoryitem(17)
			return true
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
		 and IsSpellInRange(GetSpellInfo(48638), "target") == 1 then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if IsSpellInRange(GetSpellInfo(48638), "target") == 1
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
		 and IsSpellInRange(GetSpellInfo(48638), "target") == 1 then
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
		 and IsSpellInRange(GetSpellInfo(48638), "target") == 1 then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0
		 and ni.data.darhanger.CDsaverTTD("target")
		 and IsSpellInRange(GetSpellInfo(48638), "target") == 1 then
			ni.player.useinventoryitem(14)
			return true
			end
		end
	end,
-----------------------------------	
	["Kick (Interrupt)"] = function()
		local _, enabled = GetSetting("autointerrupt")
		if enabled	
		 and ni.spell.shouldinterrupt("target")
		 and ni.spell.available(1766)
		 and ni.spell.isinstant(1766)
		 and GetTime() - ni.data.darhanger.LastInterrupt > 9
		 and ni.spell.valid("target", 1766, true, true)  then
			ni.spell.castinterrupt("target")
			ni.data.darhanger.LastInterrupt  = GetTime()
			return true
		end
	end,
-----------------------------------	
	["Tricks of the Trade"] = function()
		if ( ni.unit.threat("player") >= 2
		 or ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.unit.exists("focus")
		 and ni.spell.available(57934)
		 and ni.spell.valid("focus", 57934, false, true, true) then
			ni.spell.cast(57934, "focus")
			return true
		else 
		local tank = ni.tanks()
		if ( ni.unit.threat("player") >= 2
		 or ni.vars.combat.cd or ni.unit.isboss("target") )
		  and not ni.unit.exists("focus")
		  and ni.spell.available(57934)
		  and ni.data.darhanger.youInInstance() 
		  and ni.spell.valid(tank, 57934, false, true, true) then
			ni.spell.cast(57934, tank)
			return true
			end
		end
	end,
-----------------------------------
	["Fan of Knives"] = function()
		if ni.vars.combat.aoe
		 and ni.spell.available(51723)
		 and ni.spell.isinstant(51723)
		 and ni.spell.valid("target", 48638, true, true) then
			ni.spell.castat(51723, "target")
			ni.player.runtext("/targetlasttarget")
			return true
		end
	end,
-----------------------------------
	["Riposte"] = function()
		if IsSpellKnown(14251)
		 and IsUsableSpell(GetSpellInfo(14251)) 
		 and ni.spell.isinstant(14251)
		 and ni.spell.available(14251)
		 and ni.spell.valid("target", 14251, true, true) then
			ni.spell.castqueue(14251, "target")
			return true
		end
	end,
-----------------------------------
	["Blade Flurry"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") or ni.vars.combat.aoe )
		 and ni.spell.available(13877)
		 and ni.spell.isinstant(13877)
		 and not ni.spell.available(51690)
		 and ni.data.darhanger.CDsaverTTD("target")
		 and IsSpellInRange(GetSpellInfo(48638), "target") == 1 then
			ni.spell.cast(13877)
			return true
		end
	end,
-----------------------------------
	["Adrenaline Rush"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.power() < 35
		 and ni.spell.isinstant(13750)
		 and ni.spell.available(13750)
		 and not ni.spell.available(51690)
		 and ni.data.darhanger.CDsaverTTD("target")
		 and IsSpellInRange(GetSpellInfo(48638), "target") == 1 then
			ni.spell.cast(13750)
			return true
		end
	end,
-----------------------------------
	["Killing Spree"] = function()
		local SnD = ni.data.darhanger.rogue.SnD()
		if SnD
		 and ni.spell.isinstant(51690)
		 and ni.spell.available(51690)
		 and ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and IsSpellInRange(GetSpellInfo(48638), "target") == 1 then
			ni.spell.cast(51690, "target")
			return true
		end
	end,
-----------------------------------
	["Slice and Dice"] = function()
		local SnD = ni.data.darhanger.rogue.SnD()
		if GetComboPoints("player") > 3
		 and( SnD == nil or ( SnD - GetTime() <= 4 ) )
		 and ni.spell.isinstant(6774)
		 and ni.spell.available(6774)
		 and ni.spell.valid("target", 48638) then
			ni.spell.cast(6774)
			return true
		end
	end,
-----------------------------------
	["Sinister Strike"] = function()
		if GetComboPoints("player") < 5
		 and ni.spell.isinstant(48638)
		 and ni.spell.available(48638)
		 and ni.spell.valid("target", 48638, true, true) then
			ni.spell.cast(48638, "target")
			return true
		end
	end,
-----------------------------------
	["Rupture"] = function()
		local SnD = ni.data.darhanger.rogue.SnD()
		local Rup = ni.data.darhanger.rogue.Rup()
		if  GetComboPoints("player") == 5
		 and ( Rup == nil or ( Rup - GetTime() <= 3 ) )
		 and ( SnD and ( SnD - GetTime() > 5 ) )
		 and ni.spell.isinstant(48672)
		 and ni.spell.available(48672)
		 and ni.spell.valid("target", 48672, true, true) then
			ni.spell.cast(48672, "target")
			return true
		end
	end,
-----------------------------------
	["Eviscerate Dump"] = function()
		local SnD = ni.data.darhanger.rogue.SnD()
		local Rup = ni.data.darhanger.rogue.Rup()
		if  GetComboPoints("player") == 5
		 and Rup
		 and ( SnD and ( SnD - GetTime() > 5 ) )
		 and ni.spell.isinstant(48668)
		 and ni.spell.available(48668)
		 and ni.spell.valid("target", 48668, true, true) then
			ni.spell.cast(48668, "target")
			return true
		end
	end,
-----------------------------------
	["Eviscerate"] = function()
		local SnD = ni.data.darhanger.rogue.SnD()
		if  GetComboPoints("player") == 5
		 and ( SnD and ( SnD - GetTime() > 5 ) )
		 and ni.spell.isinstant(48668)
		 and ni.spell.available(48668)
		 and ni.spell.valid("target", 48668, true, true) then
			ni.spell.cast(48668, "target")
			return true
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Combat Rogue by DarhangeR for 3.3.5a", 
		 "Welcome to Combat Rogue Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-Focus ally target for use TofT on it or put tank name to Tank Overrides and press Enable Main.\n-Rotation developed for Rupture or Eviscerate builds.\n-For chose build select it in GUI menu.\n-For use Fan of Knives configure AoE Toggle key.")
		popup_shown = true;
		end 
	end,
}

local function queue()
	local build = GetSetting("builds")
	 if build == 1 then
	  return EviscerateBuild;
	elseif build == 2 then
	  return RaptureBuild;
	end
end

ni.bootstrap.rotation("Combat_DarhangeR", queue, abilities, data, { [1] = "Combat Rogue by DarhangeR", [2] = items });	