local data = {"DarhangeR.lua"}
local popup_shown = false;
local items = {
	settingsfile = "DarhangeR_Balance.xml",
	{ type = "title", text = "Balance Druid by DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Auto Form", enabled = true, key = "autoform" },	
	{ type = "entry", text = "Innervate (Self)", enabled = true, value = 34, key = "innervate" },
	{ type = "entry", text = "Innervate (Auto-Cast on Healers)", enabled = false, value = 35, key = "innervateheal" },
	{ type = "separator" },
	{ type = "title", text = "Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Barkskin", enabled = true, value = 40, key = "barkskin" },
	{ type = "entry", text = "Healthstone", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "entry", text = "Mana Potion", enabled = true, value = 25, key = "manapotionuse" },
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
    end
end	

local queue = {
	"Window",
	"Universal pause",
	"AutoTarget",
	"Gift of the Wild",
	"Thorns",
	"Moonkin Form",		
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Mana Potions (Use)",		
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Innervate",
	"Barkskin",
	"Faerie Fire",
	"Hurricane",
	"Eclipses",
	"Starfall",
	"Force of Nature",	
	"Insect Swarm",
	"Moonfire",
	"Wrath",
	"Starfire",
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
		 or not IsUsableSpell(GetSpellInfo(48470)) then 
		 return false
	end
		if ni.spell.available(48470)
		 and ni.spell.isinstant(48470) 
		 and not ni.data.darhanger.DruidStuff("player") then
			ni.spell.cast(48470)	
			return true
		end
	end,
-----------------------------------
	["Thorns"] = function()
		if not ni.player.buff(53307)
		 and ni.spell.available(53307)
		 and ni.spell.isinstant(53307) then
			ni.spell.cast(53307)
			return true
		end
	end,
-----------------------------------
	["Moonkin Form"] = function()
		local _, enabled = GetSetting("autoform");
		if enabled
		 and not ni.player.buff(24858)
		 and ni.spell.available(24858)
		 and not ni.data.darhanger.DruidStuff("player") then
			ni.spell.cast(24858)
			return true
		end
	end,
-----------------------------------
	["Innervate"] = function()
		local value, enabled = GetSetting("innervate");
		local valueH, enabledH = GetSetting("innervateheal");
		if enabled
		 and ni.player.power() < value
		 and not ni.player.buff(29166)
		 and ni.spell.isinstant(29166)
		 and ni.spell.available(29166) 
		 and not ni.data.darhanger.DruidStuff("player")	then
			ni.spell.cast(29166)
			return true
		end
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
		 and ni.spell.valid("target", 48461) then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if ni.spell.valid("target", 48461)
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
		 and ni.spell.valid("target", 48461) then
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
		 and ni.spell.valid("target", 48461) then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ni.spell.valid("target", 48461) then
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
	["Faerie Fire"] = function()
		local mFaerieFire = ni.data.darhanger.druid.mFaerieFire() 
		local fFaerieFire = ni.data.darhanger.druid.fFaerieFire() 
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and not fFaerieFire
		 and not mFaerieFire
		 and ni.spell.isinstant(770)
		 and ni.spell.available(770) then
			ni.spell.cast(770)
			return true
		end
	end,
-----------------------------------
	["Hurricane"] = function()
		if ni.vars.combat.aoe
		 and not ni.player.ismoving()
	         and ni.spell.available(48467) then
			ni.spell.castat(48467, "target")
			return true
		end
	end,
-----------------------------------
	["Starfall"] = function()
		if ni.rotation.custommod()
		 and ni.spell.isinstant(53201)
		 and ni.spell.available(53201)
		 and ni.spell.valid("target", 48461) then
			ni.spell.cast(53201)
			return true
		end
	end,
-----------------------------------
	["Force of Nature"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		and ni.spell.isinstant(33831)
		and ni.data.darhanger.CDsaverTTD("target")
		and ni.spell.available(33831) then
			ni.spell.castat(33831, "target")
			return true
		end
	end,
-----------------------------------
	["Moonfire"] = function()
		local mFire = ni.data.darhanger.druid.mFire()
		local solar = ni.data.darhanger.druid.solar()
		if ni.spell.available(48463)
		 and (ni.player.ismoving()
		 and (not mFire
		 or (mFire and mFire - GetTime() < 6 )))
		 or ((not solar 
		 or (solar and solar - GetTime() > 5))
		 and not mFire)
		 and ni.spell.isinstant(48463)
		 and ni.spell.valid("target", 48463, true, true) then
			ni.spell.cast(48463, "target")
			return true
		end
	end,
-----------------------------------
	["Insect Swarm"] = function()
		local iSwarm = ni.data.darhanger.druid.iSwarm()
		local lunar = ni.data.darhanger.druid.lunar()
		if ni.spell.available(48468)
		 and (ni.player.ismoving()
		 and (not iSwarm
		 or (iSwarm and iSwarm - GetTime() < 2 )))
		 or ((not lunar 
		 or (lunar and lunar - GetTime() > 1))
		 and not iSwarm)
		 and ni.spell.isinstant(48468)
		 and ni.spell.valid("target", 48468, false, true, true) then
			ni.spell.cast(48468, "target")
			return true
		end
	end,
-----------------------------------
	["Eclipses"] = function()
		if not eclipse 
		 then eclipse = "solar" 
		 end

		if ni.player.buff(48517)
		 then eclipse = "solar"
		 elseif ni.player.buff(48518)
		 then eclipse = "lunar" 
		end
	end,
-----------------------------------
	["Wrath"] = function()
		if eclipse == "solar"
		 and not ni.player.ismoving()
		 and ni.spell.available(48468)
		 and ni.spell.valid("target", 48461, true, true) then
			ni.spell.cast(48461, "target")
			return true
		end
	end,
-----------------------------------
	["Starfire"] = function()
		if eclipse == "lunar"
		 and not ni.player.ismoving() 
		 and ni.spell.available(48465)
		 and ni.spell.valid("target", 48465, true, true) then
			ni.spell.cast(48465, "target")
			return true
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Balance Druid by DarhangeR for 3.3.5a", 
		 "Welcome to Balance Druid Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For use Hurricane configure AoE Toggle key.\n-For use Starfall configure Custom Key Modifier and hold it for use it.")
		popup_shown = true;
		end 
	end,
}

ni.bootstrap.rotation("Balance_DarhangeR", queue, abilities, data, { [1] = "Balance Druid by DarhangeR", [2] = items });