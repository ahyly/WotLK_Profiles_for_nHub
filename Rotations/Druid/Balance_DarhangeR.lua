local data = ni.utils.require("DarhangeR");
local popup_shown = false;
local build = select(4, GetBuildInfo());
local level = UnitLevel("player");
if build == 30300 and level == 80 and data then
local items = {
	settingsfile = "DarhangeR_Balance.xml",
	{ type = "title", text = "Balance Druid by |c0000CED1DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "|cffFFFF00Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Auto Form", tooltip = "Auto use proper form", enabled = true, key = "autoform" },	
	{ type = "entry", text = "Innervate (Self)", tooltip = "Use spell when player mana < %", enabled = true, value = 34, key = "innervate" },
	{ type = "entry", text = "Innervate (Auto-Cast on Healers)", tooltip = "Auto check healears and use spell when they mana < %", enabled = false, value = 35, key = "innervateheal" },
	{ type = "entry", text = "Debug Printing", tooltip = "Enable for debug if you have problems", enabled = false, key = "Debug" },		
	{ type = "separator" },
	{ type = "title", text = "|cff00C957Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Barkskin", tooltip = "Use spell when player HP < %", enabled = true, value = 40, key = "barkskin" },
	{ type = "entry", text = "Healthstone", tooltip = "Use Warlock Healthstone (if you have) when player HP < %", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", tooltip = "Use Heal Potions (if you have) when player HP < %",  enabled = true, value = 30, key = "healpotionuse" },
	{ type = "entry", text = "Mana Potion", tooltip = "Use Mana Potions (if you have) when player mana < %", enabled = true, value = 25, key = "manapotionuse" },
	{ type = "separator" },
	{ type = "title", text = "|cffEE4000Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Auto Control (Member)", tooltip = "Auto check and control member if he mindcontrolled or etc.", enabled = true, key = "control" },	
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
	ni.GUI.AddFrame("Balance_DarhangeR", items);
end
local function OnUnLoad()  
	ni.GUI.DestroyFrame("Balance_DarhangeR");
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
	"Control (Member)",
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
		 and ni.spell.available(53307) then
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
		 and not data.druid.DruidStuff("player") then
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
		 and ni.spell.available(29166) 
		 and not data.druid.DruidStuff("player")	then
			ni.spell.cast(29166)
			return true
		end
		if enabledH
		 and ni.spell.available(29166) then
		  for i = 1, #ni.members do
		  local ally = ni.members[i].unit
		   if data.ishealer(ally)
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
		if data.casterStop("target")
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
		 and data.CDsaverTTD("target")
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
		 and data.CDsaverTTD("target")
		 and ni.spell.valid("target", 48461) then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0
		 and data.CDsaverTTD("target")
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
		 and ni.spell.available(22812) 
		 and not ni.player.buff(22812) then
			ni.spell.cast(22812)
			return true
		end
	end,
-----------------------------------
	["Faerie Fire"] = function()
		local mFaerieFire = data.druid.mFaerieFire() 
		local fFaerieFire = data.druid.fFaerieFire() 
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and not fFaerieFire
		 and not mFaerieFire
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
		 and ni.spell.available(53201)
		 and ni.spell.valid("target", 48461) then
			ni.spell.cast(53201)
			return true
		end
	end,
-----------------------------------
	["Force of Nature"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		and data.CDsaverTTD("target")
		and ni.spell.available(33831) then
			ni.spell.castat(33831, "target")
			return true
		end
	end,
-----------------------------------
	["Moonfire"] = function()
		local mFire = data.druid.mFire()
		local solar = data.druid.solar()
		if ni.spell.available(48463)
		 and (ni.player.ismoving()
		 and (not mFire
		 or (mFire and mFire - GetTime() < 6 )))
		 or ((not solar 
		 or (solar and solar - GetTime() > 5))
		 and not mFire)
		 and ni.spell.valid("target", 48463, true, true) then
			ni.spell.cast(48463, "target")
			return true
		end
	end,
-----------------------------------
	["Insect Swarm"] = function()
		local iSwarm = data.druid.iSwarm()
		local lunar = data.druid.lunar()
		if ni.spell.available(48468)
		 and (ni.player.ismoving()
		 and (not iSwarm
		 or (iSwarm and iSwarm - GetTime() < 2 )))
		 or ((not lunar 
		 or (lunar and lunar - GetTime() > 1))
		 and not iSwarm)
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
	["Control (Member)"] = function()
		local _, enabled = GetSetting("control")
		if enabled
		 and ni.spell.available(33786) then
		  for i = 1, #ni.members do
		   local ally = ni.members[i].unit
		    if data.ControlMember(ally)
			and not data.UnderControlMember(ally)
			and ni.spell.valid(ally, 33786, false, true, true) then
				ni.spell.cast(33786, ally)
				return true
				end
			end
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

	ni.bootstrap.profile("Balance_DarhangeR", queue, abilities, OnLoad, OnUnLoad);
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
    ni.bootstrap.profile("Balance_DarhangeR", queue, abilities);
end