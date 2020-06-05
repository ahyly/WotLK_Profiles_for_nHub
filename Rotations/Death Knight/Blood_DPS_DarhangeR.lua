local data = {"DarhangeR.lua"}

--Convert Abilities
local hornofwinter = GetSpellInfo(57623)
local deathanddecay = GetSpellInfo(49938)
local hysteria = GetSpellInfo(49016)
local bloodstrike = GetSpellInfo(49930)
local icytouch = GetSpellInfo(49909)
local plaguestrike = GetSpellInfo(49921)
local pestilence = GetSpellInfo(50842)
local deathstrike = GetSpellInfo(49924)
local runestrike = GetSpellInfo(56815)
local bloodboil = GetSpellInfo(49941)
local heartstrike = GetSpellInfo(55262)
local deathcoil = GetSpellInfo(49895)

local popup_shown = false;
local queue = {

	"Window",
	"Stutter cast pause",
	"Universal pause",
	"AutoTarget",
	"Blood presence check",
	"Horn of Winter",
	"Combat specific Pause",
	"Pet Attack/Follow",
	"Healthstone (Use)",
	"Potions (Use)",
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Mind Freeze (Interrupt)",
	"Icebound Fort",
	"Vamp Blood",
	"Death and Decay",
	"Hyst",
	"Empower Rune Weapon",
	"Icy Touch",
	"Plague Strike",
	"Pestilence (AoE)",
	"Pestilence (Renew)",
	"Dance Rune",
	"Death Coil (Max runpower)",		
	"Death Strike",
	"Rune Strike",
	"Blood Boil",
	"Heart Strike",
	"Death Coil"
}


local abilities = {
-----------------------------------
	["Universal pause"] = function()
		if IsMounted()
		 or UnitInVehicle("player")
		 or UnitIsDeadOrGhost("target") 
		 or UnitIsDeadOrGhost("player")
		 or UnitChannelInfo("player")
		 or UnitCastingInfo("player")
		 or ni.unit.buff("target", 59301)
		 or ni.unit.buff("player", 430)
		 or ni.unit.buff("player", 433)
		 or (not UnitAffectingCombat("player")
		 and ni.vars.followEnabled) then
			return true
		end
	end,
-----------------------------------
	["Stutter cast pause"] = function()
		if ni.spell.gcd()
		 or ni.vars.CastStarted == true then
			return true
		end
	end,
-----------------------------------
	["AutoTarget"] = function()
		if UnitAffectingCombat("player")
		 and (not UnitExists("target")
		 or (UnitExists("target") and not UnitCanAttack("player", "target"))) then
			ni.player.runtext("/targetenemy")
		end
	end,
-----------------------------------
	["Blood presence check"] = function()
		if not ni.player.buff(48266)
		 and ni.spell.isinstant(48266) 
		 and ni.spell.available(48266) then
			ni.spell.cast(48266)
			return true
		end
	end,
-----------------------------------
	["Horn of Winter"] = function()
		if not ni.player.buff(hornofwinter)
		 and ni.spell.isinstant(hornofwinter) 
		 and ni.spell.available(hornofwinter) then 		
			ni.spell.cast(hornofwinter)
			return true
		end
	end,
-----------------------------------
	["Combat specific Pause"] = function()
		if ni.data.darhanger.meleeStop()
		 or UnitCanAttack("player","target") == nil
		 or (UnitAffectingCombat("target") == nil 
		 and ni.unit.isdummy("target") == nil 
		 and UnitIsPlayer("target") == nil) then 
			return true
		end
	end,
-----------------------------------
	["Pet Attack/Follow"] = function()
		if ni.unit.hp("playerpet") < 20
		 and UnitExists("playerpet")
		 and UnitExists("target")
		 and UnitIsUnit("target", "pettarget")
		 and not UnitIsDeadOrGhost("playerpet") then
			ni.data.darhanger.petFollow()
		 else
		if UnitAffectingCombat("player")
		 and UnitExists("playerpet")
		 and ni.unit.hp("playerpet") > 60
		 and UnitExists("target")
		 and not UnitIsUnit("target", "pettarget")
		 and not UnitIsDeadOrGhost("playerpet") then 
			ni.data.darhanger.petAttack()
			end
		end
	end,
-----------------------------------
	["Healthstone (Use)"] = function()
		local hstones = { 36892, 36893, 36894 }
		for i = 1, #hstones do
			if ni.player.hp() < 30
			 and ni.player.hasitem(hstones[i]) 
			 and ni.player.itemcd(hstones[i]) == 0 then
				ni.player.useitem(hstones[i])
				return true
			end
		end	
	end,
-----------------------------------
	["Potions (Use)"] = function()
		local hpot = { 33447, 43569, 40087, 41166, 40067 }
		for i = 1, #hpot do
			if ni.player.hp() < 35
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
		if ni.data.darhanger.forsaken()
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
		 and IsSpellInRange(GetSpellInfo(49930), "target") == 1 then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if IsSpellInRange(GetSpellInfo(49930), "target") == 1
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
		 and ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and IsSpellInRange(GetSpellInfo(49930), "target") == 1 then
			ni.player.useinventoryitem(10)
			return true
		end
	end,
-----------------------------------
	["Trinkets"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(13)
		 and ni.player.slotcd(13) == 0 
		 and IsSpellInRange(GetSpellInfo(49930), "target") == 1 then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0 
		 and IsSpellInRange(GetSpellInfo(49930), "target") == 1 then
			ni.player.useinventoryitem(14)
			return true
			end
		end
	end,
-----------------------------------
	["Mind Freeze (Interrupt)"] = function()
		if ni.spell.shouldinterrupt("target")
		 and ni.spell.isinstant(47528)
		 and ni.spell.available(47528)
		 and GetTime() - ni.data.darhanger.LastInterrupt > 9
		 and ni.spell.valid("target", 47528, true, true)  then
			ni.spell.castinterrupt("target")
			ni.data.darhanger.LastInterrupt = GetTime()
			return true
		end
	end,
-----------------------------------
	["Icebound Fort"] = function()
		if ni.player.hp() < 45
		 and ni.spell.isinstant(48792)
		 and ni.spell.available(48792) then
			ni.spell.cast(48792)
			return true
		end
	end,
-----------------------------------
	["Vamp Blood"] = function()
		local _, BR = ni.rune.bloodrunecd()
		if BR >= 1
		 and ni.player.hp() < 50
		 and ni.spell.isinstant(55233)
		 and ni.spell.available(55233) then
			ni.spell.cast(55233)
			return true
		end
	end,
-----------------------------------
	["Death and Decay"] = function()
		if ni.vars.combat.aoe
		 and ni.spell.isinstant(deathanddecay) then
			ni.spell.castqueue(deathanddecay, "target")
			return true
		end
	end,
-----------------------------------
	["Hyst"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.spell.isinstant(hysteria)
		 and ni.spell.available(hysteria)
		 and IsSpellInRange(bloodstrike, "target") == 1 then
		  if not UnitExists("focus")
		  and not ni.player.buff(hysteria) then
			ni.spell.cast(hysteria, "player")
			return true
		else
		 if UnitExists("focus")
		 and UnitInRange("focus")
		 and not UnitIsDeadOrGhost("focus")
		 and ni.spell.isinstant(hysteria)
		 and ni.spell.available(hysteria)
		 and not ni.unit.buff("focus", hysteria) then
			ni.spell.cast(hysteria, "focus")
			return true
			     end
			end
		end
	end,
-----------------------------------
	["Empower Rune Weapon"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.rune.available() == 0
		 and ni.spell.isinstant(47568)
		 and ni.spell.available(47568) then
			ni.spell.cast(47568)
			return true
		end
	end,
-----------------------------------
	["Icy Touch"] = function()
		local icy = ni.data.darhanger.dk.icy()
		if ( icy == nil or ( icy - GetTime() <= 2 ) )
		 and ni.spell.available(icytouch)		
		 and ni.spell.isinstant(icytouch)
		 and ni.spell.valid("target", icytouch, true, true) then
			ni.spell.cast(icytouch, "target")
			return true
		end
	end,
-----------------------------------
	["Plague Strike"] = function()
		local plague = ni.data.darhanger.dk.plague()
		if ( plague == nil or ( plague - GetTime() <= 2 ) )
		 and ni.spell.available(plaguestrike)	
		 and ni.spell.isinstant(plaguestrike)
		 and ni.spell.valid("target", plaguestrike, true, true) then
			ni.spell.cast(plaguestrike "target")
			return true
		end
	end,
-----------------------------------
	["Pestilence (AoE)"] = function()
		local icy = ni.data.darhanger.dk.icy()
		local plague = ni.data.darhanger.dk.plague()
		local enemies = ni.unit.enemiesinrange("target", 7)
		local _, BR = ni.rune.bloodrunecd()
		local _, DR = ni.rune.deathrunecd()
		if #enemies >= 1 then
		 if ( BR >= 1 or DR >= 1 )
		 and icy
		 and plague
		 and  UnitExists("target")
		 and UnitCanAttack("player", "target")
		 and ni.spell.isinstant(pestilence)
		 and ni.spell.valid("target", pestilence, true, true) then
		  for i = 1, #enemies do
		   if ni.unit.creaturetype(enemies[i].guid) ~= 8
		    and ni.unit.creaturetype(enemies[i].guid) ~= 11
		    and (not ni.unit.debuff(enemies[i].guid, 55078, "player")
		    or not ni.unit.debuff(enemies[i].guid, 55095, "player")) then
				ni.spell.cast(pestilence)
						return true
					end
				end
			end
		end
	end,
-----------------------------------
	["Pestilence (Renew)"] = function()
		local icy = ni.data.darhanger.dk.icy()
		local plague = ni.data.darhanger.dk.plague()
		local _, BR = ni.rune.bloodrunecd()
		local _, DR = ni.rune.deathrunecd()
		if ( BR >= 1 or DR >= 1 )
		 and ni.player.hasglyph(63334)
		 and ni.spell.valid("target", pestilence, true, true)
		 and ( ( icy ~= nil and icy - GetTime() <= 5 )
		 or ( plague ~= nil and plague - GetTime() <= 5 ) ) then 
			ni.spell.cast(pestilence, "target")
			return true
		end
	end,
-----------------------------------
	["Dance Rune"] = function()
		if ni.spell.available(49028)
		 and ni.spell.isinstant(49028)
		 and ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.spell.valid("target", 49930, true, true) then
			ni.spell.cast(49028, "target")
			return true
		end
	end,
-----------------------------------
	["Death Strike"] = function()
		local _, FR = ni.rune.frostrunecd()
		local _, UR = ni.rune.unholyrunecd()
		local _, DR = ni.rune.deathrunecd()
		local icy = ni.data.darhanger.dk.icy()
		local plague = ni.data.darhanger.dk.plague()
		if ((FR >= 1 and UR >= 1)
		 or (FR >= 1 and DR >= 1)
		 or (DR >= 1 and UR >= 1)
		 or (DR == 2))			 
		 and plague
		 and icy
		 and ni.spell.isinstant(deathstrike)
		 and ni.spell.available(deathstrike)
		 and ni.spell.valid("target", deathstrike, true, true) then
			ni.spell.cast(deathstrike, "target")
			return true
		end
	end,
-----------------------------------
	["Rune Strike"] = function()
		if IsUsableSpell(GetSpellInfo(runestrike))
		 and ni.spell.available(runestrike, true)
		 and not IsCurrentSpell(runestrike)
		 and ni.spell.valid("target", runestrike, true, true) then
			ni.spell.cast(runestrike, "target")
			return true
		end
	end,
-----------------------------------
	["Blood Boil"] = function()
		local _, BR = ni.rune.bloodrunecd()
		local icy = ni.data.darhanger.dk.icy()
		local plague = ni.data.darhanger.dk.plague()
		local enemies = ni.unit.enemiesinrange("target", 7)
		if BR >= 1
		 and #enemies > 2
		 and plague
		 and icy
		 and ni.spell.isinstant(bloodboil)
		 and ni.spell.available(bloodboil)
		 and ni.spell.valid("target", heartstrike, true, true) then
			ni.spell.cast(bloodboil, "target")
			return true
		end
	end,
-----------------------------------
	["Heart Strike"] = function()
		local _, BR = ni.rune.bloodrunecd()
		local icy = ni.data.darhanger.dk.icy()
		local plague = ni.data.darhanger.dk.plague()
		local enemies = ni.unit.enemiesinrange("target", 7)
		if BR >= 1
		 and ( #enemies == 1 or #enemies < 3 )
		 and plague
		 and icy
		 and ni.spell.isinstant(heartstrike)
		 and ni.spell.available(heartstrike)
		 and ni.spell.valid("target", heartstrike, true, true) then
			ni.spell.cast(heartstrike, "target")
			return true
		end
	end,
-----------------------------------
	["Death Coil"] = function()
		if ni.spell.available(deathcoil)
		 and ni.spell.isinstant(deathcoil)
		 and ni.spell.valid("target", deathcoil, true, true) then
			ni.spell.cast(deathcoil, "target")
			return true
		end
	end,
-----------------------------------
	["Death Coil (Max runpower)"] = function()
		if ni.player.power() > 80
		 and ni.spell.available(deathcoil)
		 and ni.spell.isinstant(deathcoil)
		 and ni.spell.valid("target", deathcoil, true, true) then
			ni.spell.cast(deathcoil, "target")
			return true
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		ni.debug.popup("Blood DPS Deathknight by DarhangeR", 
		 "Welcome to Blood DPS Deathknight Profile! Support and more in Discord > https://discord.gg/u4mtjws.\n\n--Profile Function--\n-For use Death and Decay configure AoE Toggle key.\n-Focus ally target for use Hysteria on it.")	
		popup_shown = true;
		end 
	end,
}

ni.bootstrap.rotation("Blood_DPS_DarhangeR", queue, abilities, data)