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
	settingsfile = "DarhangeR_ProtоWarrior.xml",
	{ type = "title", text = "Protection Warrior by DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Battle Shout", enabled = false, key = "battleshout" },
	{ type = "entry", text = "Commanding Shout", enabled = true, key = "commandshout" },
	{ type = "entry", text = "Auto Interrupt", enabled = true, key = "autointerrupt" },
	{ type = "separator" },
	{ type = "title", text = "Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Berserker Rage (Anti-Contol)", enabled = true, key = "bersrage" },
	{ type = "entry", text = "Last Stand + Enraged Regeneration", enabled = true, value = 27, key = "regen" },
	{ type = "entry", text = "Shield Wall", enabled = true, value = 37, key = "wall" },
	{ type = "entry", text = "Healthstone", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "separator" },
	{ type = "title", text = "Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Taunt (Auto Agro)", enabled = false, key = "tau" },
	{ type = "entry", text = "Rend (Boss only)", enabled = true, key = "rend" },
	{ type = "entry", text = "Thunder Clap (AoE)", enabled = true, key = "thunder" },
	{ type = "entry", text = "Heroic Strike/Cleave minimal rage", value = 35, key = "heroiccleave" },
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
	"Defensive Stance",
	"Commanding Shout",
	"Battle Shout",
	"Vigilance",
	"Berserker Rage",
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Racial Stuff",
	"Shield Bash (Interrupt)",
	"Last Stand",
	"Enraged Regeneration",
	"Shield Wall",
	"Taunt",
	"Taunt (Ally)",
	"Mocking Blow",
	"Demoralizing Shout",
	"Heroic Strike + Cleave (Filler)",
	"Revenge",
	"Rend",
	"Shield Block",
	"Shield Slam",
	"Thunder Clap (AoE)",
	"Devastate",
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
	["Defensive Stance"] = function()
		local DS = GetShapeshiftForm()
		if DS ~= 2 then 
			ni.spell.cast(71)
			return true
		end
	end,
-----------------------------------
	["Battle Shout"] = function()
		local _, enabled = GetSetting("battleshout")
		if ni.player.buffs("47436||48932||48934") then 
		 return false
	end
		if enabled
		 and ni.spell.available(47436)
		 and ni.spell.isinstant(47436) then
			ni.spell.cast(47436)	
			return true
		end
	end,		 
-----------------------------------
	["Commanding Shout"] = function()
		local _, enabled = GetSetting("commandshout")
		if ni.player.buffs("47440||47440") then 
		 return false
	end
		if enabled
		 and ni.spell.available(47440) 
		 and ni.spell.isinstant(47440) then
			ni.spell.cast(47440)	
			return true
		end
	end,
-----------------------------------
	["Vigilance"] = function()
		if ni.unit.exists("focus")
		 and UnitInRange("focus")
		 and not UnitIsDeadOrGhost("focus")
		 and not ni.unit.buff("focus", 50720) 
		 and ni.spell.valid("focus", 50720, false, true, true) then
			ni.spell.cast(50720, "focus")
			return true
		end
	end,	
-----------------------------------
	["Berserker Rage"] = function()
		local _, enabled = GetSetting("bersrage")
		if enabled
		 and ni.data.darhanger.Berserk("player")
		 and ni.spell.isinstant(18499) 
	     and ni.spell.available(18499) then
		    ni.spell.cast(18499)
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
	["Shield Bash (Interrupt)"] = function()
		local _, enabled = GetSetting("autointerrupt")
		if enabled	
		 and ni.spell.shouldinterrupt("target")
		 and ni.spell.isinstant(72) 
		 and ni.spell.available(72)
		 and GetTime() - ni.data.darhanger.LastInterrupt > 9
		 and ni.spell.valid("target", 72)  then
			ni.spell.castinterrupt("target")
			ni.data.darhanger.LastInterrupt  = GetTime()
			return true
		end
	end,
-----------------------------------
	["Last Stand"] = function()
		local value, enabled = GetSetting("regen");
		if enabled
		 and ni.player.hp() < value
		 and ni.spell.isinstant(12975) 
		 and ni.spell.available(12975) then
			ni.spell.cast(12975)
			return true
		end
	end,		 
-----------------------------------
	["Enraged Regeneration"] = function()
		local enrage = { 18499, 12292, 29131, 14204, 57522 }
		if ni.player.buff(12975)
		 and ni.spell.isinstant(55694) 
		 and ni.spell.available(55694) then
		  for i = 1, #enrage do
		   if ni.player.buff(enrage[i]) then
		       ni.spell.cast(55694)
		else
		 if not ni.player.buff(enrage[i])
		  and ni.spell.cd(2687) == 0
		  and ni.spell.isinstant(2687) then
		       ni.spell.castspells("2687|55694")
					return true
					end
			    end
			end
		end
	end,
-----------------------------------
	["Shield Wall"] = function()
		local value, enabled = GetSetting("wall");
		if enabled
		 and ni.player.hp() < value
		 and ni.spell.isinstant(871) 
		 and ni.spell.available(871) then
			ni.spell.cast(871)
			return true
		end
	end,		 
-----------------------------------
	["Taunt"] = function()
		if ni.unit.exists("targettarget") 
		 and not UnitIsDeadOrGhost("targettarget")
		 and UnitAffectingCombat("player")
		 and (ni.unit.debuff("targettarget", 72410) 
		 or ni.unit.debuff("targettarget", 72411) 
		 or ni.unit.threat("player", "target") < 2 )
		 and ni.spell.isinstant(355) 
		 and ni.spell.available(355)
		 and ni.data.darhanger.youInInstance()
		 and ni.spell.valid("target", 355, false, true, true) then
			ni.spell.cast(355)
			return true
		end
	end,
-----------------------------------
	["Taunt (Ally)"] = function()
		local _, enabled = GetSetting("grow")
   		if ni.spell.available(355)
		 and ni.spell.isinstant(355)
		 and (ni.data.darhanger.youInInstance()
		 or enabled) then
		 table.wipe(enemies);
		 local enemies = ni.unit.enemiesinrange("player", 30)
		  for i = 1, #enemies do
		  local threatUnit = enemies[i].guid
   		   if ni.unit.threat("player", threatUnit) ~= nil 
   		    and ni.unit.threat("player", threatUnit) <= 2
   		    and UnitAffectingCombat(threatUnit) 
   		    and ni.spell.valid(threatUnit, 355, false, true, true) then
				ni.spell.cast(355, threatUnit)
				return true
				end
			end
		end
	end,
-----------------------------------
	["Mocking Blow"] = function()
		if ni.unit.exists("targettarget") 
		 and not UnitIsDeadOrGhost("targettarget")
		 and UnitAffectingCombat("player")
		 and (ni.unit.debuff("targettarget", 72410) 
		 or ni.unit.debuff("targettarget", 72411) 
		 or ni.unit.threat("player", "target") < 2)
		 and ni.spell.cd(355) ~= 0
		 and ni.spell.isinstant(694) 
		 and ni.spell.available(694)
		 and ni.data.darhanger.youInInstance()
		 and ni.spell.valid("target", 694, true, true) then
			ni.spell.cast(694)
			return true
		end
	end,
-----------------------------------
	["Revenge"] = function()
		if IsUsableSpell(GetSpellInfo(57823))
		 and ni.spell.isinstant(57823) 
		 and ni.spell.available(57823, true)
		 and ni.spell.valid("target", 57823, true, true) then
			ni.spell.cast(57823, "target")
			return true
		end
	end,
-----------------------------------
	["Rend"] = function()
		local _, enabled = GetSetting("rend")
		local rend = ni.data.darhanger.warrior.rend()
		if enabled
		 and ni.unit.isboss("target")
		 and (rend == nil or (rend - GetTime() <= 2))
		 and ni.spell.isinstant(47465) 
		 and ni.spell.available(47465, true)
		 and ni.spell.valid("target", 47465, true, true) then
			ni.spell.cast(47465)
			return true
		end
	end,
-----------------------------------
	["Shield Block"] = function()
		if ni.player.hp() < 80
		 and ni.spell.available(2565, true)
		 and ni.spell.valid("target", 47498) then
			ni.spell.cast(2565)
			return true
		end
	end,		 
-----------------------------------
	["Shield Slam"] = function()
		if ni.spell.available(47488, true)
		 and ni.spell.isinstant(47488) 
		 and ni.spell.valid("target", 47488, true, true) then
			ni.spell.cast(47488)
			return true
		end
	end,
-----------------------------------
	["Thunder Clap (AoE)"] = function()
		local _, enabled = GetSetting("thunder")
		if enabled
		 and ActiveEnemies() >= 1
		 and ni.spell.available(47502, true)
		 and ni.spell.valid("target", 47465, true, true) then
			ni.spell.cast(47502)
			return true
		end
	end,
-----------------------------------
	["Demoralizing Shout"] = function()
		if ni.unit.exists("target")
		 and UnitCanAttack("player", "target") then
			table.wipe(enemies);
			enemies = ni.unit.enemiesinrange("target", 8)
			for i = 1, # enemies do
				local tar = enemies[i].guid;
				if ni.unit.creaturetype(enemies[i].guid) ~= 8 
				 and not ni.unit.debuff(tar, 47437)
				 and GetTime() - ni.data.darhanger.warrior.LastShout > 4
				 and ni.spell.available(47437) then
					ni.spell.cast(47437, tar)
					ni.data.darhanger.warrior.LastShout = GetTime()
					return true
				end
			end
		end
	end,
-----------------------------------
	["Devastate"] = function()
		if ni.spell.available(47498, true)
		 and ni.spell.isinstant(47498) 
		 and ni.spell.valid("target", 47498, true, true) then
			ni.spell.cast(47498)
			return true
		end
	end,
-----------------------------------
	["Heroic Strike + Cleave (Filler)"] = function()
		local value = GetSetting("heroiccleave");
		if IsSpellInRange(GetSpellInfo(47475), "target") == 1
		 and ni.spell.cd(47486) ~= 0 
		 and ni.player.power() > value then
			if ActiveEnemies() >= 1	
			 and ni.spell.available(47520, true) 
			 and not IsCurrentSpell(47520) then
				ni.spell.cast(47520, "target")
			return true
		else
			if ActiveEnemies() == 0
			 and ni.spell.available(47450, true)
			 and not IsCurrentSpell(47450) then
				ni.spell.cast(47450, "target")
			return true
				end
			end
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Protection Warrior by DarhangeR for 3.3.5a", 
		 "Welcome to Protection Warrior Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-Focus ally target for use Vigilance on it")
		popup_shown = true;
		end 
	end,
}

ni.bootstrap.rotation("Protection_DarhangeR", queue, abilities, data, { [1] = "Protection Warrior by DarhangeR", [2] = items });