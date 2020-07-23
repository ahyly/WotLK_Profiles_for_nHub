local data = {"DarhangeR.lua"}
local popup_shown = false;
local items = {
	settingsfile = "DarhangeR_HolyPaladin.xml",
	{ type = "title", text = "Holy Paladin by DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "tank Settings" },
	{ type = "separator" },	
	{ type = "entry", text = "Divine Plea", enabled = true, value = 60, key = "plea" },
	{ type = "entry", text = "Divine Illumination", enabled = true, value = 35, key = "illumination" },	
	{ type = "separator" },
	{ type = "title", text = "Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Divine Shield", enabled = true, value = 22, key = "divineshield" },
	{ type = "entry", text = "Healthstone", enabled = true, value = 35, key = "healthstoneuse" },	
	{ type = "entry", text = "Heal Potion", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "entry", text = "Mana Potion", enabled = true, value = 25, key = "manapotionuse" },
	{ type = "separator" },
	{ type = "title", text = "Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Exorcism", enabled = false, key = "exorc" },
	{ type = "entry", text = "Non Combat Healing", enabled = true, value = 95, key = "noncombatheal" },
	{ type = "entry", text = "Holy Light", enabled = true, value = 40, key = "light" },
	{ type = "entry", text = "Holy Shock", enabled = true, value = 75, key = "shock" },
	{ type = "entry", text = "Flash of Light", enabled = true, value = 85, key = "flash" },
	{ type = "entry", text = "Non Combat Healing", enabled = true, value = 95, key = "noncombatheal" },
	{ type = "entry", text = "Aura Mastery", enabled = true, key = "auramastery" },
	{ type = "entry", text = "Aura Mastery (Members HP)", value = 30, key = "auramasteryhp" },
	{ type = "entry", text = "Aura Mastery (Members Count)", value = 4, key = "auramasterycount" },
	{ type = "entry", text = "Hand of Sacrifice (Member)", enabled = true, value = 18, key = "handsacrifice" },
	{ type = "entry", text = "Hand of Salvation (Member)", enabled = true, key = "salva" },
	{ type = "entry", text = "Hand of Protection (Member)", enabled = true, value = 20, key = "handprot" },
	{ type = "separator" },
	{ type = "title", text = "Dispel" },
	{ type = "separator" },
	{ type = "entry", text = "Cleanse (Member)", enabled = true, key = "cleans" },
	{ type = "entry", text = "Hand of Freedom (Member)", enabled = true, key = "freedom" },
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
	"Seal of Wisdom/Light",
	"Cancel Righteous Fury",
	"Divine Plea",
	"Non Combat Healing",
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Mana Potions (Use)",
	"Racial Stuff",
	"Divine Shield",
	"Cleanse (Member)",
	"Judgement of Light",
	"Exorcism",
	"Aura Mastery",
	"Hand of Sacrifice (Member)",
	"Hand of Salvation (Member)",
	"Hand of Protection (Member)",
	"Avenging Wrath",
	"Divine Illumination T10",
	"Divine Illumination",
	"Tank Heal",
	"Holy Light",
	"Holy Shock",
	"Flash of Light",
	"Hand of Freedom (Member)",
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
	["Seal of Wisdom/Light"] = function()
		if ni.spell.available(20166)
		 and ni.player.hasglyph(54940)
		 and not ni.player.buff(20166) then 
			ni.spell.cast(20166)
			return true
		end
		if ni.spell.available(20165)
		 and ni.player.hasglyph(54943)
		 and not ni.player.buff(20165) then 
			ni.spell.cast(20165)
			return true
		else
		if not ni.player.hasglyph(54943)
		 and not ni.player.hasglyph(54940)
		 and not ni.player.buff(20166) then
			ni.spell.cast(20166)
		    return true
			end
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
	["Non Combat Healing"] = function()
		local value, enabled = GetSetting("noncombatheal");
		if enabled
		 and not UnitAffectingCombat("player")	 
		 and ni.spell.available(48785) then
		   if ni.members[1].hp < value
		    and not ni.player.ismoving()
		    and ni.spell.valid(ni.members[1].unit, 48785, false, true, true) then
				ni.spell.cast(48785, ni.members[1].unit)
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
		 and ni.spell.valid("target", 20271, false, true, true) then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if ni.spell.valid("target", 20271, false, true, true)
		 and ni.player.hp() < 20
		 and IsSpellKnown(alracial[i])
		 and ni.spell.available(alracial[i]) then 
					ni.spell.cast(alracial[i])
					return true
				end
			end
		end,
-----------------------------------
	["Divine Shield"] = function()
		local value, enabled = GetSetting("divineshield");
		local forb = ni.data.darhanger.paladin.forb()
		if enabled
		 and ni.player.hp() < value
		 and not forb
		 and ni.spell.isinstant(642)
		 and ni.spell.available(642) then
			ni.spell.cast(642)
			return true
		end
	end,
-----------------------------------
	["Judgement of Light"] = function()
		if ni.spell.available(20271)
		 and ni.members[1].hp > 75
		 and ni.spell.isinstant(20271)
		 and ni.unit.debuffremaining("target", 20185, "player") < 2
		 and ni.spell.valid("target", 20271, false, true, true) then
			ni.spell.cast(20271, "target")
			return true
		end
	end,
-----------------------------------
	["Exorcism"] = function()
		local _, enabled = GetSetting("exorc");
		if enabled
		 and ni.members[1].hp > 75
		 and ni.spell.available(48801)
		 and ni.spell.valid("target", 48801, true, true) then
			ni.spell.cast(48801, "target")
			return true
		end
	end,
-----------------------------------
	["Aura Mastery"] = function()
		local _, enabled = GetSetting("auramastery");
		local valueHp = GetSetting("auramasteryhp");
		local valueCount = GetSetting("auramasterycount");
		if enabled
		 and ni.members.averageof(valueCount) < valueHp
		 and ni.spell.isinstant(31821)	
		 and ni.spell.available(31821) then
			ni.spell.cast(31821)
			return true
		end
	end,
-----------------------------------
	["Hand of Sacrifice (Member)"] = function()
		local value, enabled = GetSetting("handsacrifice");
		if enabled
		 and #ni.members > 1
		 and ni.spell.isinstant(6940)	
		 and ni.spell.available(6940) then
		  for i = 1, #ni.members do
		   if ni.members[i].range
		   and ni.members[i].hp < value
		   and not ni.members[i].istank
		   and not UnitIsDeadOrGhost(ni.members[i].unit)
		   and not ni.unit.buff(ni.members[i].unit, 1038)
		   and not ni.unit.buff(ni.members[i].unit, 6940)
		   and not ni.unit.buff(ni.members[i].unit, 10278)
		   and ni.spell.valid(ni.members[i].unit, 6940, false, true, true) then
				ni.spell.cast(6940, ni.members[i].unit)
				return true
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
	["Avenging Wrath"] = function()
		if ni.data.darhanger.youInInstance()
		 and ni.members.averageof(4) < 30
		 and ni.spell.isinstant(31821)
		 and ni.spell.available(31821) then
			ni.spell.cast(31821)
			return true
		end
		if ni.data.darhanger.youInRaid()
		 and ni.members.averageof(7) < 30
		 and ni.spell.isinstant(31821)
		 and ni.spell.available(31821) then
			ni.spell.cast(31821)
			return true
		end
	end,
-----------------------------------
	["Divine Illumination T10"] = function()
		if ni.data.darhanger.checkforSet(ni.data.darhanger.paladin.itemsetT10, 2) then 
		 if ni.data.darhanger.youInInstance()
		 and ni.members.averageof(4) < 45
		 and not ni.player.buff(54428)
		 and ni.spell.isinstant(31842)
		 and ni.spell.available(31842) then
			ni.spell.cast(31842)
			return true
			end
		else
		if ni.data.darhanger.youInRaid()
		 and ni.members.averageof(9) < 45
		 and not ni.player.buff(54428)
		 and ni.spell.isinstant(31842)
		 and ni.spell.available(31842) then
			ni.spell.cast(31842)
			return true
			end
		end
	end,
-----------------------------------
	["Divine Illumination"] = function()
		local value, enabled = GetSetting("plea");
		if enabled
		 and ni.player.power() < value
		 and not ni.player.buff(31842)
		 and not ni.player.buff(54428)
		 and not ni.spell.available(54428)
		 and ni.spell.isinstant(31842)
		 and ni.spell.available(31842) then
			ni.spell.cast(31842)
			return true
		end
	end,
-----------------------------------
	["Tank Heal"] = function()
		local tank = ni.tanks()
		-- Main Tank Heal
		if ni.unit.exists(tank) then
		 local BofLtank, _, _, _, _, _, BofLtank_time = ni.unit.buff(tank, 53563, "player")
		 local SCtank, _, _, _, _, _, SCtank_time = ni.unit.buff(tank, 53601, "player")
		 local SelfSCtank = ni.unit.buff(tank, 53601)
		 local forbtank = ni.unit.debuff(tank, 25771)
		if (not BofLtank
		 or (BofLtank and BofLtank_time - GetTime() < 2))
		 and ni.spell.isinstant(53563)
		 and ni.spell.available(53563)
		 and ni.spell.valid(tank, 53563, false, true, true) then
			ni.spell.cast(53563, tank)
			return true
		end
		 if not SelfSCtank
		 and not (SCtank
		 or (SCtank and SCtank_time - GetTime() < 2))
		 and ni.spell.isinstant(53601)		 
		 and ni.spell.available(53601)
		 and ni.spell.valid(tank, 53601, false, true, true) then
			ni.spell.cast(53601, tank)
			return true
		end
		 if tank ~= nil
		 and ni.unit.hp(tank) < 12
		 and not forbtank
		 and ni.spell.isinstant(48788)
		 and ni.spell.available(48788)
		 and ni.spell.valid(tank, 48788, false, true, true) then
			ni.spell.cast(48788, tank)
			return true
		end
		 if tank ~= nil
		 and ni.unit.hp(tank) < 25
		 and ni.spell.isinstant(20216)
		 and ni.spell.available(20216)
		 and ni.spell.available(48825)
		 and ni.spell.valid(tank, 48825, false, true, true) then
			ni.spell.castspells("20216|48825", tank)
			return true
			end
		end
	end,
-----------------------------------
	["Holy Light"] = function()
		local value, enabled = GetSetting("light");
		if enabled
		 and ni.spell.available(48782)
		 and not ni.player.ismoving() then
		  if ni.members[1].hp < value
		   and ni.spell.valid(ni.members[1].unit, 48782, false, true, true) then
				ni.spell.cast(48782, ni.members[1].unit)
				return true
			end
		end
	end,
-----------------------------------
	["Holy Shock"] = function()
		local value, enabled = GetSetting("shock");
		if enabled
		 and ni.spell.available(48825) 
		 and ni.spell.isinstant(48825) then
		-- Lowest member Tank but one member more need heal
		 if ni.members[1].hp < value
		  and ni.unit.buff(ni.members[1].unit, 53563, "player")
		  and ni.members[2].hp + 12.5 < value
		  and ni.spell.valid(ni.members[2].unit, 48825, false, true, true) then
			ni.spell.cast(48825, ni.members[2].unit)
			return true
		end
		 -- Lowest member Tank and nobody else
		 if ni.members[1].hp < value
		  and ni.unit.buff(ni.members[1].unit, 53563, "player")
		  and ni.members[2].hp + 12.5 >= value
		  and ni.spell.valid(ni.members[1].unit, 48825, false, true, true) then
			ni.spell.cast(48825, ni.members[1].unit)
			return true
		end
		 -- Lowest member isn't Tank
		 if ni.members[1].hp < value
		  and not ni.unit.buff(ni.members[1].unit, 53563, "player")
		  and ni.spell.valid(ni.members[1].unit, 48825, false, true, true) then
			ni.spell.cast(48825, ni.members[1].unit)
			return true
			end
		end
	end,
-----------------------------------
	["Flash of Light"] = function()
		local value, enabled = GetSetting("flash");
		if enabled
		 and ni.spell.available(48785)
		 and not ni.player.ismoving() 
		 or ni.unit.buff("player", 54149) then
		-- Lowest member Tank but one member more need heal
		 if ni.members[1].hp < value
		  and ni.unit.buff(ni.members[1].unit, 53563, "player")
		  and ni.members[2].hp + 5 < value
		  and ni.spell.valid(ni.members[2].unit, 48785, false, true, true) then
			ni.spell.cast(48785, ni.members[2].unit)
			return true
		end
		 -- Lowest member Tank and nobody else
		if ni.members[1].hp < value
		  and ni.unit.buff(ni.members[1].unit, 53563, "player")
		  and ni.members[2].hp + 5 >= value
		  and ni.spell.valid(ni.members[1].unit, 48785, false, true, true) then
			ni.spell.cast(48785, ni.members[1].unit)
			return true
		end
		 -- Lowest member isn't Tank
		if ni.members[1].hp < value
		  and ni.spell.valid(ni.members[1].unit, 48785, false, true, true) then
			ni.spell.cast(48785, ni.members[1].unit)
			return true
			end
		end
	end,
-----------------------------------
	["Cleanse (Member)"] = function()
		local _, enabled = GetSetting("cleans")
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
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Holy Paladin by DarhangeR for 3.3.5a", 
		 "Welcome to Holy Paladin Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For enable priority healing Main Tank put tank name to Tank Overrides and press Enable Main")	
		popup_shown = true;
		end 
	end,
}

ni.bootstrap.rotation("Holy_DarhangeR", queue, abilities, data, { [1] = "Holy Paladin by DarhangeR", [2] = items });