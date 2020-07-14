local data = {"DarhangeR.lua"}
local popup_shown = false;
local enemies = { };
local items = {
	settingsfile = "DarhangeR_Shadow.xml",
	{ type = "title", text = "Shadow Priest by DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Auto Form", enabled = true, key = "autoform" },
	{ type = "entry", text = "Fear Ward (Self)", enabled = false, key = "fearward" },
	{ type = "entry", text = "Fear Ward (Focus)", enabled = false, key = "fearwardmemb" },
	{ type = "entry", text = "Auto Interrupt", enabled = true, key = "autointerrupt" },
	{ type = "separator" },
	{ type = "title", text = "Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Dispersion", enabled = true, key = "disp" },
	{ type = "entry", text = "Dispersion (HP threshold)", value = 20, key = "disphp" },
	{ type = "entry", text = "Dispersion (Mana threshold)", value = 20, key = "dispmana" },
	{ type = "entry", text = "Healthstone", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "entry", text = "Mana Potion", enabled = true, value = 25, key = "manapotionuse" },
	{ type = "separator" },
	{ type = "title", text = "Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Shackle Undead (Auto Use)", enabled = false, key = "shackundead" },
	{ type = "separator" },
	{ type = "title", text = "Dispel" },
	{ type = "separator" },
	{ type = "entry", text = "Dispel Magic (Self)", enabled = false, key = "dispelmag" },
	{ type = "entry", text = "Dispel Magic (Member)", enabled = false, key = "dispelmagmemb" },
	{ type = "entry", text = "Abolish Disease (Self)", enabled = false, key = "abolish" },
	{ type = "entry", text = "Abolish Disease (Member)", enabled = false, key = "abolishmb" },
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

local Rotation4T10 = {
	"Window",	
	"AutoTarget",
	"Universal pause",
	"Inner Fire",
	"Prayer of Fortitude",
	"Prayer of Spirit",
	"Prayer of Shadow Protection",
	"Fear Ward",		
	"Vampiric Embrace",	
	"Shadowform",
	"Combat specific Pause",
	"Pet Attack/Follow",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Mana Potions (Use)",		
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Silence (Interrupt)",
	"Fade",
	"Shackle Undead (Auto Use)",
	"Dispersion",
	"Shadowfiend",		
	"Shadow Word: Death",
	"Mind Sear",
	"Shadow Word: Pain",
	"SWP AoE",
	"Dispel Magic (Self)",
	"Abolish Disease (Self)",
	"Dispel Magic (Member)",
	"Abolish Disease (Member)",
	"Vampiric Touch",
	"Devouring Plague",
	"Mind Flay",
}
local StandartRotation = {
	"Window",
	"AutoTarget",
	"Universal pause",
	"Inner Fire",
	"Prayer of Fortitude",
	"Prayer of Spirit",
	"Prayer of Shadow Protection",
	"Fear Ward",		
	"Vampiric Embrace",	
	"Shadowform",
	"Combat specific Pause",
	"Pet Attack/Follow",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Mana Potions (Use)",		
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Silence (Interrupt)",
	"Fade",
	"Shackle Undead (Auto Use)",
	"Dispersion",
	"Shadowfiend",		
	"Shadow Word: Death",
	"Mind Sear",
	"Shadow Word: Pain",
	"SWP AoE",
	"Dispel Magic (Self)",
	"Abolish Disease (Self)",
	"Dispel Magic (Member)",
	"Abolish Disease (Member)",
	"Vampiric Touch",
	"Devouring Plague",
	"Mind Blast",
	"Mind Flay",
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
	["Inner Fire"] = function()
		if not ni.player.buff(48168)
		 and ni.spell.isinstant(48168) 
		 and ni.spell.available(48168) then
			ni.spell.cast(48168)
			return true
		end
	end,
-----------------------------------
	["Prayer of Fortitude"] = function()
		if ni.player.buff(48162)
		 or not IsUsableSpell(GetSpellInfo(48162)) then 
		 return false
	end
		if ni.spell.available(48162)
		 and ni.spell.isinstant(48162) then
			ni.spell.cast(48162)	
			return true
		end
	end,
-----------------------------------
	["Prayer of Spirit"] = function()
		if ni.player.buffs("48074||57567")
		 or not IsUsableSpell(GetSpellInfo(48074)) then 
		 return false
	end
		if ni.spell.available(48074)
		 and ni.spell.isinstant(48074) then
			ni.spell.cast(48074)	
			return true
		end
	end,
-----------------------------------
	["Prayer of Shadow Protection"] = function()
		if ni.player.buff(48170)
		 or not IsUsableSpell(GetSpellInfo(48170)) then 
		 return false
	end
		if ni.spell.available(48170)
		 and ni.spell.isinstant(48170) then
			ni.spell.cast(48170)	
			return true
		end
	end,
-----------------------------------
	["Fear Ward"] = function()
		local _, enabled = GetSetting("fearward")
		local _, enabledM = GetSetting("fearwardmemb")
        if enabled
		 and not ni.player.buff(6346)
		 and ni.spell.isinstant(6346) 
		 and ni.spell.available(6346) then
			ni.spell.cast(6346, "player")
			return true
		end
		if enabledM
		 and ni.unit.exists("focus")
		 and not ni.unit.buff("focus", 6346)
		 and ni.spell.isinstant(6346) 
		 and ni.spell.available(6346)
		 and ni.spell.valid("focus", 6346, false, true, true) then
			ni.spell.cast(6346, "focus")
			return true
		end
	end,
-----------------------------------
	["Vampiric Embrace"] = function()
		if not ni.player.buff(15286)
		 and ni.spell.isinstant(15286) 
		 and ni.spell.available(15286) then
			ni.spell.cast(15286)
			return true
		end
	end,
-----------------------------------
	["Shadowform"] = function()
		local _, enabled = GetSetting("autoform")
		if enabled 
		 and not ni.player.buff(15473)
		 and ni.spell.isinstant(15473) 
		 and ni.spell.available(15473) then
			ni.spell.cast(15473)
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
		 and ni.spell.valid("target", 48125, true, true) then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if ni.spell.valid("target", 48125, true, true)
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
		 and ni.spell.valid("target", 48125) then
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
		 and ni.spell.valid("target", 48125) then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0 
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ni.spell.valid("target", 48125) then
			ni.player.useinventoryitem(14)
			return true
			end
		end
	end,
-----------------------------------	
	["Silence (Interrupt)"] = function()
		local _, enabled = GetSetting("autointerrupt")
		if enabled 
		 and ni.spell.shouldinterrupt("target")
		 and ni.spell.available(15487)
		 and ni.spell.isinstant(15487)
		 and GetTime() - ni.data.darhanger.LastInterrupt > 9
		 and ni.spell.valid("target", 15487, true, true)  then
			ni.spell.castinterrupt("target")
			ni.data.darhanger.LastInterrupt = GetTime()
			return true
		end
	end,
-----------------------------------
	["Fade"] = function()
		if #ni.members > 1 
		 and ni.unit.threat("player") >= 2
		 and not ni.player.buff(586)
		 and ni.spell.isinstant(586) 
		 and ni.spell.available(586) then
			ni.spell.cast(586)
			return true
		end
	end,
-----------------------------------
	["Dispersion"] = function()
		if ( ni.player.power() < 20
		 or ni.player.hp() < 20 )
		 and ni.spell.isinstant(47585) 
		 and ni.spell.available(47585) then
			ni.spell.cast(47585)
			return true
		end
	end,
-----------------------------------
	["Shadowfiend"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.spell.isinstant(34433)
		 and ni.data.darhanger.CDsaverTTD("target")
		 and ni.spell.available(34433) then
			ni.spell.cast(34433, "target")
			return true
		end
	end,
-----------------------------------
	["Shadow Word: Death"] = function()
		if ni.unit.hp("target") <= 35
		 and ni.spell.available(48158)
		 and ni.spell.isinstant(48158)
		 and ni.spell.valid("target", 48158, false, true, true) then
			ni.spell.cast(48158, "target")
			return true
		end
	end,
-----------------------------------
	["Mind Sear"] = function()
		if ni.vars.combat.aoe
		 and ni.spell.available(53023)
		 and not ni.player.ismoving() then
			ni.spell.cast(53023, "target")
			return true
		end
	end,
-----------------------------------
	["Shadow Word: Pain"] = function()
		local SWP = ni.data.darhanger.priest.SWP()		
		local sWeaving, _, _, count = ni.player.buff(15258)
		if not SWP
		 and sWeaving
		 and count == 5
		 and ni.spell.available(48125)
		 and ni.spell.isinstant(48125)
		 and ni.spell.valid("target", 48125, false, true, true)
		 and GetTime() - ni.data.darhanger.priest.lastSWP > 1 then
			ni.spell.cast(48125, "target")
			ni.data.darhanger.priest.lastSWP = GetTime()
			return true
		end
	end,
-----------------------------------
	["SWP AoE"] = function()
		if ni.rotation.custommod()
		 and ni.unit.exists("target")
		 and ni.spell.available(48125)
		 and ni.spell.isinstant(48125)
		 and UnitCanAttack("player", "target") then
		 table.wipe(enemies);
			enemies = ni.unit.enemiesinrange("target", 15)
			for i = 1, #enemies do
				local tar = enemies[i].guid; 
				if ni.unit.creaturetype(enemies[i].guid) ~= 8
				 and ni.unit.creaturetype(enemies[i].guid) ~= 11
				 and not ni.unit.debuffs(tar, "23920||35399||69056||10955", "EXACT")
				 and not ni.unit.debuff(tar, 48125, "player")
				 and ni.spell.valid(enemies[i].guid, 48125, false, true, true) then
					ni.spell.cast(48125, tar)
					return true
				end
			end
		end
	end,
-----------------------------------
	["Shackle Undead (Auto Use)"] = function()        
		local _, enabled = GetSetting("shackundead")
		if enabled 
		 and ni.unit.exists("target")
		 and ni.spell.available(10955)
		 and UnitCanAttack("player", "target") then
		 table.wipe(enemies);
		  enemies = ni.unit.enemiesinrange("player", 25)
		  local dontShackle = false
		  for i = 1, #enemies do
		   local tar = enemies[i].guid; 
		   if ni.unit.creaturetype(enemies[i].guid) == 6
		    and ni.unit.debuff(tar, 10955, "player") then
			dontShackle = true
			break
		end
        end
		if not dontShackle then
		 for i = 1, #enemies do
		 local tar = enemies[i].guid; 
		  if ni.unit.creaturetype(enemies[i].guid) == 6
		   and not ni.unit.isboss(tar)
		   and not ni.unit.debuffs(tar, "23920||35399||69056", "EXACT")
		   and not ni.unit.debuff(tar, 10955, "player")
		   and ni.spell.valid(enemies[i].guid, 10955, false, true, true)
		   and GetTime() - ni.data.darhanger.priest.lastShackle > 1.5 then
				ni.spell.cast(10955, tar)
				ni.data.darhanger.priest.lastShackle = GetTime()
                        return true
					end
				end
			end
		end
	end,
-----------------------------------
	["Vampiric Touch"] = function()
		if not ni.player.ismoving()
		 and ni.unit.debuffremaining("target", 48160, "player") < ni.spell.casttime(48160)
		 and ni.spell.available(48160)
		 and ni.spell.valid("target", 48160, false, true, true)
		 and GetTime() - ni.data.darhanger.priest.lastvamp > 2 then
			ni.spell.cast(48160, "target")
			ni.data.darhanger.priest.lastvamp = GetTime()
			return true
		end
	end,
-----------------------------------
	["Devouring Plague"] = function()
		if ni.spell.available(48300)
		 and ni.spell.isinstant(48300)
		 and ni.unit.debuffremaining("target", 48300, "player") < 2.7
		 and ni.spell.valid("target", 48300, false, true, true) then  
			ni.spell.cast(48300, "target")
			return true
		end
	end,
-----------------------------------
	["Mind Blast"] = function()
		if not ni.player.ismoving()
		 and ni.spell.available(48127)
		 and ni.spell.valid("target", 48127, true, true) then
			ni.spell.cast(48127, "target")
			return true
		end
	end,
-----------------------------------
	["Mind Flay"] = function()
		if ni.spell.cd(48127)
		 and not ni.player.ismoving()
		 and ni.spell.available(48156)
		 and ni.spell.valid("target", 48127, true, true) then
			ni.spell.cast(48156, "target")
			return true
		end
	end,
-----------------------------------
	["Dispel Magic (Self)"] = function()
		local _, enabled = GetSetting("dispelmag")
		if enabled
		 and ni.unit.debufftype("player", "Magic")
		 and ni.spell.isinstant(988)
		 and ni.spell.available(988)
		 and ni.healing.candispel("player")
		 and GetTime() - ni.data.darhanger.LastDispel > 1.2
		 and ni.spell.valid("player", 988, false, true, true) then
			ni.spell.cast(988, "player")
			ni.data.darhanger.LastDispel = GetTime()
			return true
		end
	end,
-----------------------------------
	["Dispel Magic (Member)"] = function()
		local _, enabled = GetSetting("dispelmagmemb")
		if enabled
		 and ni.spell.available(988)
		 and ni.spell.isinstant(988) then
		  for i = 1, #ni.members do
		   if ni.unit.debufftype(ni.members[i].unit, "Magic")
		   and ni.healing.candispel(ni.members[i].unit)
		   and GetTime() - ni.data.darhanger.LastDispel > 1.2
		   and ni.spell.valid(ni.members[i].unit, 988, false, true, true) then
				ni.spell.cast(988, ni.members[i].unit)
				ni.data.darhanger.LastDispel = GetTime()
				return true
				end
			end
		end
	end,
-----------------------------------
	["Abolish Disease (Self)"] = function()
		local _, enabled = GetSetting("abolish")
		if enabled
		 and ni.unit.debufftype("player", "Disease")
		 and ni.spell.isinstant(552)
		 and ni.spell.available(552)
		 and ni.healing.candispel("player")
		 and GetTime() - ni.data.darhanger.LastDispel > 1.2
		 and not ni.unit.buff("player", 552)
		 and ni.spell.valid("player", 552, false, true, true) then
			ni.spell.cast(552, "player")
			ni.data.darhanger.LastDispel = GetTime()
			return true
		end
	end,
-----------------------------------
	["Abolish Disease (Member)"] = function() 
		local _, enabled = GetSetting("abolishmb")
		if enabled
		and ni.spell.available(552)
		and ni.spell.isinstant(552) then
		 for i = 1, #ni.members do
		  if ni.unit.debufftype(ni.members[i].unit, "Disease")
		  and ni.healing.candispel(ni.members[i].unit)
		  and GetTime() - ni.data.darhanger.LastDispel > 1.2
		  and not ni.unit.buff(ni.members[i].unit, 552)
		  and ni.spell.valid(ni.members[i].unit, 552, false, true, true) then
				ni.spell.cast(552, ni.members[i].unit)
				ni.data.darhanger.LastDispel = GetTime()
				return true
				end
			end
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Shadow Priest by DarhangeR for 3.3.5a", 
		 "Welcome to Shadow Priest Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For use Mind Sear configure AoE Toggle key.\n-For use Shadow Word:Pain AoE mode configure Custom Key Modifier and hold it for put spell on nearest enemies.")
		popup_shown = true;
		end 
	end,
}

local function queue()
    if ni.data.darhanger.checkforSet(ni.data.darhanger.priest.itemsetT10, 4) then
        return Rotation4T10
    end
		return StandartRotation
end

ni.bootstrap.rotation("Shadow_DarhangeR", queue, abilities, data, { [1] = "Shadow Priest by DarhangeR", [2] = items });