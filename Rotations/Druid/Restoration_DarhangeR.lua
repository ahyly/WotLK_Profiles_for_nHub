local data = {"DarhangeR.lua"}
local popup_shown = false;
local items = {
	settingsfile = "DarhangeR_Druid_Resto.xml",
	{ type = "title", text = "Restoration Druid by DarhangeR" },
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
	{ type = "separator" },
	{ type = "title", text = "Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Non Combat Healing", enabled = true, value = 95, key = "noncombatheal" },
	{ type = "entry", text = "Nourish", enabled = true, value = 75, key = "nourish" },
	{ type = "entry", text = "Rejuvenation (All Members)", enabled = true, value = 99, key = "rejuall" },	
	{ type = "entry", text = "Swiftmend", enabled = true, value = 55, key = "swift" },
	{ type = "entry", text = "Nature Swiftness", enabled = true, value = 40, key = "natureswift" },
	{ type = "entry", text = "Tranquility", enabled = true, key = "tranquil" },
	{ type = "entry", text = "Tranquility (Members HP)", value = 35, key = "tranquilhp" },
	{ type = "entry", text = "Tranquility (Members Count)", value = 9, key = "tranquilcount" },
	{ type = "separator" },
	{ type = "title", text = "Dispel" },
	{ type = "separator" },
	{ type = "entry", text = "Remove Curse (Member)", enabled = true, key = "removecurse" },
	{ type = "entry", text = "Ambolish Poison (Member)", enabled = true, key = "ambolishpoison" },	
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
	"Gift of the Wild",
	"Thorns",
	"Tree of Life",
	"Non Combat Healing",
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Mana Potions (Use)",
	"Racial Stuff",
	"Innervate",
	"Barkskin",
	"Tank Heal",
	"Tranquility",
	"Nature's Swiftness",
	"Swiftmend",
	"Wild Growth",
	"Rejuvenation",		
	"Nourish",
	"Wild Growth all",
	"Remove Curse (Member)",
	"Abolish Poison (Member)",	
	"Rejuvenation (All Members)",
}
local abilities = {
-----------------------------------
	["Universal pause"] = function()
		if (ni.data.darhanger.UniPause() 
		 or ni.data.darhanger.PlayerDebuffs("player")) then
			return true
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
		 and not ni.data.darhanger.DruidStuff("player")	then
			ni.spell.cast(48470)	
			return true
		end
	end,
-----------------------------------
	["Thorns"] = function()
		if not ni.player.buff(53307)
		 and ni.spell.available(53307)
		 and ni.spell.isinstant(53307)
		 and not ni.data.darhanger.DruidStuff("player")	then
			ni.spell.cast(53307)
			return true
		end
	end,
-----------------------------------
	["Tree of Life"] = function()
		local _, enabled = GetSetting("autoform");
		if enabled
		 and ni.spell.available(33891)
		 and not ni.player.buff(33891) 
		 and not ni.data.darhanger.DruidStuff("player")	then
			ni.spell.cast(33891)
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
	["Non Combat Healing"] = function()
		local value, enabled = GetSetting("noncombatheal");
		if enabled
		 and not UnitAffectingCombat("player")
		 and ni.spell.available(48441)
		 and ni.spell.isinstant(48441)		 
		 and ni.spell.available(48443) 
		 and not ni.data.darhanger.DruidStuff("player")	then
		   if ni.members[1].hp < value
		    and not ni.unit.buff(ni.members[1].unit, 48441, "player")
		    and ni.spell.valid(ni.members[1].unit, 48441, false, true, true) then
				ni.spell.cast(48441, ni.members[1].unit)
				return true
			end
		   if ni.members[1].hp < value
		    and not ni.player.ismoving()
		    and not ni.unit.buff(ni.members[1].unit, 48443, "player")
		    and ni.spell.valid(ni.members[1].unit, 48443, false, true, true) then
				ni.spell.cast(48443, ni.members[1].unit)
				return true
			end
		end
	end,
-----------------------------------
	["Combat specific Pause"] = function()
		if UnitAffectingCombat("player") then
			return false
		end
		for i = 1, #ni.members do
		if UnitAffectingCombat(ni.members[i].unit) then
			return false
			end
		end
			return true
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
	["Tank Heal"] = function()
		local mainTank, offTank = ni.tanks()
		-- Main Tank Heal
		if ni.unit.exists(tank) then
		 local lbtank, _, _, lbtank_count, _, _, lbtank_time = ni.unit.buff(mainTank, 48451, "player")
		 local rgtank, _, _, _, _, _, rgtank_time = ni.unit.buff(mainTank, 48443, "player")
		 local rjtank, _, _, _, _, _, rjtank_time = ni.unit.buff(mainTank, 48441, "player")
		-- Buff Thorns on MT -- 
		if ni.spell.available(53307)
		 and ni.spell.isinstant(53307)
		 and not ni.unit.buff(mainTank, 53307)
		 and ni.spell.valid(mainTank, 53307, false, true, true) then
			ni.spell.cast(53307, mainTank)
			return true
		end
		-- Heal MT with Lifebloom --
		if ni.spell.available(48451)
		 and ni.spell.isinstant(48451)
		 and (not lbtank
		 or (lbtank and lbtank_count < 3))
		 and ni.spell.valid(mainTank, 48451, false, true, true) then
			ni.spell.cast(48451, mainTank)
			return true
		end
		-- Heal MT with Regrowth --
		if ni.spell.available(48443)
		 and ni.unit.hp(mainTank) < 55
		 and (not rgtank
		 or (rgtank and rgtank_time - GetTime() < 2))
		 and GetTime() - ni.data.darhanger.druid.lastRegrowth > 2
		 and not ni.player.ismoving() 
		 and ni.spell.valid(mainTank, 48443, false, true, true) then
			ni.data.darhanger.druid.lastRegrowth = GetTime()
			ni.spell.cast(48443, mainTank)
			return true
		end
		-- Heal MT with Rejuvenation --
		if ni.spell.available(48441)
		 and ni.spell.isinstant(48441)
		 and (not rjtank
		 or (rjtank and rjtank_time - GetTime() < 2))
		 and ni.spell.valid(mainTank, 48441, false, true, true) then
			ni.spell.cast(48441, mainTank)
			return true
			end
		end
		-- Off Tank heal
		if offTank ~= nil
		 and ni.unit.exists(offTank) then
		 local rgotank, _, _, _, _, _, rgotank_time = ni.unit.buff(offTank, 48443, "player")
		 local rjotank, _, _, _, _, _, rjotank_time = ni.unit.buff(offTank, 48441, "player")
		 -- Buff Thorns on OT -- 
		if ni.spell.available(53307)
		 and ni.spell.isinstant(53307)
		 and not ni.unit.buff(offTank, 53307)
		 and ni.spell.valid(offTank, 53307, false, true, true) then
			ni.spell.cast(53307, offTank)
			return true
		end
		-- Heal OT with Regrowth --
		if ni.spell.available(48443)
		 and ni.unit.hp(offTank) < 55
		 and (not rgotank
		 or (rgotank and rgotank_time - GetTime() < 2))
		 and GetTime() - ni.data.darhanger.druid.lastRegrowth > 2
		 and not ni.player.ismoving() 
		 and ni.spell.valid(offTank, 48443, false, true, true) then
			ni.data.darhanger.druid.lastRegrowth = GetTime()
			ni.spell.cast(48443, offTank)
			return true
		end
		-- Heal OT with Rejuvenation --
		if ni.spell.available(48441)
		 and ni.spell.isinstant(48441)
		 and (not rjotank
		 or (rjotank and rjotank_time - GetTime() < 2))
		 and ni.spell.valid(offTank, 48441, false, true, true) then
			ni.spell.cast(48441, offTank)
			return true
			end
		end
	end,
-----------------------------------
	["Tranquility"] = function()
		local _, enabled = GetSetting("tranquil");
		local valueHp = GetSetting("tranquilhp");
		local valueCount = GetSetting("tranquilcount");	
		if enabled
		 and ni.members.averageof(valueCount) < valueHp
		 and not ni.player.ismoving()
		 and ni.spell.available(48447) 
		 and UnitChannelInfo("player") == nil then
			ni.spell.cast(48447)
			return true
		end
	end,
-----------------------------------
	["Nature's Swiftness"] = function()
		local value, enabled = GetSetting("natureswift");
		if enabled
		 and ni.spell.isinstant(17116)
		 and ni.spell.available(17116)
		 and ni.spell.available(48378) then
		  for i = 1, #ni.members do
		   if ni.members[i].hp < value
		    and ni.spell.valid(ni.members[i].unit, 48378, false, true, true) then
				ni.spell.cast(17116)
				ni.spell.cast(48378, ni.members[i].unit)
				return true
				end
			end
		end
	end,
-----------------------------------
	["Swiftmend"] = function()
		local value, enabled = GetSetting("swift");
		if enabled
		 and ni.spell.available(18562)
		 and ni.spell.isinstant(18562) then
		  for i = 1, #ni.members do
		   if ni.members[i].hp < value
		    and (ni.unit.buff(ni.members[i].unit, 48441, "player")
		    or ni.unit.buff(ni.members[i].unit, 48443, "player")) 
			and ni.spell.valid(ni.members[i].unit, 18562, false, true, true) then
				ni.spell.cast(18562, ni.members[i].unit)
				return true
				end
			end
		end
	end,
-----------------------------------
	["Wild Growth"] = function()
		if ni.members.averageof(4) < 95
		 and ni.spell.available(53251)
		 and ni.spell.isinstant(18562)
		 and ni.spell.valid(ni.members[1].unit, 53251, false, true, true) then
			ni.spell.cast(53251, ni.members[1].unit)
			return true
		end
	end,
-----------------------------------
	["Rejuvenation"] = function()
		if ni.spell.available(48441)
		 and ni.spell.isinstant(48441) then
		  for i = 1, #ni.members do
		   if ni.members[i].hp < 95
		    and not ni.unit.buff(ni.members[i].unit, 48441, "player")
		    and ni.spell.valid(ni.members[i].unit, 48441, false, true, true) then
					ni.spell.cast(48441, ni.members[i].unit)
					return true
				end
			end
		end
	end,
-----------------------------------
	["Nourish"] = function()
		local value, enabled = GetSetting("nourish");
		 if enabled
		 and not ni.player.ismoving()
		 and ni.spell.available(50464) then
		  for i = 1, #ni.members do
		   if ni.members[i].hp < value
		    and (ni.unit.buff(ni.members[i].unit, 48441, "player")
		    or ni.unit.buff(ni.members[i].unit, 48443, "player")
		    or ni.unit.buff(ni.members[i].unit, 48451, "player")
		    or ni.unit.buff(ni.members[i].unit, 53251, "player"))
		    and ni.spell.valid(ni.members[i].unit, 50464, false, true, true) then
				ni.spell.cast(50464, ni.members[i].unit)
				return true
				end
			end
		end
	end,
-----------------------------------
	["Wild Growth all"] = function()
		if ni.members.averageof(6) < 100
		 and ni.spell.available(53251)
		 and ni.spell.isinstant(53251)
		 and ni.spell.valid(ni.members[1].unit, 53251, false, true, true) then
			ni.spell.cast(53251, ni.members[1].unit)
			return true
		end
	end,
-----------------------------------
	["Remove Curse (Member)"] = function()
		local _, enabled = GetSetting("removecurse")
		if enabled
		 and ni.spell.available(2782)
		 and ni.spell.isinstant(2782) then
		  for i = 1, #ni.members do
		   if ni.unit.debufftype(ni.members[i].unit, "Curse")	 
		    and ni.healing.candispel(ni.members[i].unit)
		    and GetTime() - ni.data.darhanger.LastDispel > 1.2
		    and ni.spell.valid(ni.members[i].unit, 2782, false, true, true) then
				ni.spell.cast(2782, ni.members[i].unit)
				ni.data.darhanger.LastDispel = GetTime()
				return true
				end
			end
		end
	end,
-----------------------------------
	["Abolish Poison (Member)"] = function()
		local _, enabled = GetSetting("ambolishpoison")		
		if enabled
		 and ni.spell.available(2893)
		 and ni.spell.isinstant(2893) then
		  for i = 1, #ni.members do
		   if ni.unit.debufftype(ni.members[i].unit, "Poison")	 
		   and ni.healing.candispel(ni.members[i].unit)
		   and GetTime() - ni.data.darhanger.LastDispel > 1.2
		   and not ni.unit.buff(ni.members[i].unit, 2893)
		   and ni.spell.valid(ni.members[i].unit, 2893, false, true, true) then
				ni.spell.cast(2893, ni.members[i].unit)
				ni.data.darhanger.LastDispel = GetTime()
				return true
				end
			end
		end
	end,
-----------------------------------
	["Rejuvenation (All Members)"] = function()
		local value, enabled = GetSetting("rejuall");
		 if enabled
		 and ni.spell.available(48411)
		 and ni.spell.isinstant(48411) then
		  for i = 1, #ni.members do
		   if ni.members[i].hp <= value
		    and not ni.unit.buff(ni.members[i].unit, 48441, "player")
		    and ni.spell.valid(ni.members[i].unit, 48441, false, true, true) then
				ni.spell.cast(48441, ni.members[i].unit)
				return true
				end
			end
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Restoration Druid by DarhangeR for 3.3.5a", 
		 "Welcome to Restoration Druid Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For enable priority healing Main Tank & Off Tank put tank name to Tank Overrides and press Enable Main/Off")
		popup_shown = true;
		end 
	end,
}

ni.bootstrap.rotation("Restoration_DarhangeR", queue, abilities, data, { [1] = "Restoration Druid by DarhangeR", [2] = items });