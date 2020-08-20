local data = ni.utils.require("DarhangeR");
local popup_shown = false;
local build = select(4, GetBuildInfo());
local level = UnitLevel("player");
if build == 30300 and level == 80 and data then
local items = {
	settingsfile = "DarhangeR_Assasin.xml",
	{ type = "title", text = "Assassination Rogue by |c0000CED1DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "|cffFFFF00Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Auto Interrupt", tooltip = "Auto check and interrupt all interruptible spells", enabled = true, key = "autointerrupt" },
	{ type = "entry", text = "Debug Printing", tooltip = "Enable for debug if you have problems", enabled = false, key = "Debug" },		
	{ type = "separator" },
	{ type = "title", text = "|cff00C957Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Healthstone", tooltip = "Use Warlock Healthstone (if you have) when player HP < %", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", tooltip = "Use Heal Potions (if you have) when player HP < %", enabled = true, value = 30, key = "healpotionuse" },
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
	ni.GUI.AddFrame("Assassination_DarhangeR", items);
end
local function OnUnLoad()  
	ni.GUI.DestroyFrame("Assassination_DarhangeR");
end

local queue = {
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
	"Garrote/Ambush",
	"Cold Blood",
	"Vanish",
	"Rupture Dump",
	"Hunger For Blood",
	"Mutilate",
	"Slice and Dice",
	"Envenom",
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
    ["Poison Weapon"] = function()
		local mh, _, _, oh = GetWeaponEnchantInfo()
		if applypoison 
		 and GetTime() - applypoison > 4 then 
			applypoison = nil 
		end
		if not UnitAffectingCombat("player") 
		and not applypoison then
		applypoison = GetTime()
		if not mh 
		 and ni.player.hasitem(43231) then
			ni.player.useitem(43231)
			ni.player.useinventoryitem(16)
			return true
		end
		if not oh
		 and ni.player.hasitem(43233) then
			ni.player.useitem(43233)
			ni.player.useinventoryitem(17)
			return true
			end
		end
	end,
-----------------------------------
	["Combat specific Pause"] = function()
		if data.meleeStop("target")
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
		 and data.CDsaverTTD("target")
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
		 and data.CDsaverTTD("target")
		 and IsSpellInRange(GetSpellInfo(48638), "target") == 1 then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0
		 and data.CDsaverTTD("target")
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
		 and GetTime() - data.LastInterrupt > 9
		 and ni.spell.valid("target", 1766, true, true)  then
			ni.spell.castinterrupt("target")
			data.LastInterrupt  = GetTime()
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
		  and data.youInInstance() 
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
		 and ni.spell.available(14251)
		 and ni.spell.valid("target", 14251, true, true) then
			ni.spell.castqueue(14251, "target")
			return true
		end
	end,
-----------------------------------
	["Garrote/Ambush"] = function()
		local OGar = data.rogue.OGar()
		if ni.player.buff(1784)
		 and ( ni.vars.combat.cd or ni.unit.isboss("target") ) then
		  if not OGar
		   and ni.player.isbehind("target")
		   and ni.spell.available(48676)
		   and ni.spell.valid("target", 48676, true, true) then
			  ni.spell.cast(48676, "target")
			  return true
		end
		  if OGar
		   and ni.player.isbehind("target")
		   and ni.spell.available(48691)
		   and ni.spell.valid("target", 48691, true, true) then
			  ni.spell.cast(48691, "target")
			  return true
			end
		end
	end,
-----------------------------------
	["Vanish"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") ) 
		 and not ni.player.buff(58427)
		 and ni.spell.available(26889)
		 and IsSpellInRange(GetSpellInfo(48638), "target") == 1 then
			ni.spell.cast(26889)
			return true
		end
	end,
-----------------------------------
	["Cold Blood"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and GetComboPoints("player") == 5
		 and IsUsableSpell(GetSpellInfo(57993))
		 and ni.spell.available(14177)
		 and ni.spell.available(57993)
		 and ni.spell.valid("target", 57993, true, true) then
			ni.spell.castspells("14177|57993")
			return true
		end
	end,
-----------------------------------
	["Rupture Dump"] = function()
	--Use Rapture when Hunger not usable
		local Rup = data.rogue.Rup()
		local Hunger = data.rogue.Hunger()
		 if GetComboPoints("player") > 1
		 and not IsUsableSpell(GetSpellInfo(51662))
		 and ( not Hunger or ( Hunger <= 7 ) )
		 and ( not ni.player.buff(1784)
		 and not ni.spell.available(26889) 
		 or not IsUsableSpell(GetSpellInfo(51662)))
		 and ni.spell.valid("target", 48672, true, true) then
			ni.spell.cast(48672, "target")
			return true
		end
	end,
-----------------------------------
	["Hunger For Blood"] = function()
		local Hunger = data.rogue.Hunger()
		if IsUsableSpell(GetSpellInfo(51662))
		 and ni.spell.available(51662)
		 and( not Hunger or ( Hunger <= 3 ) )
		 and IsSpellInRange(GetSpellInfo(48638), "target") == 1  then
			ni.spell.cast(51662)
			return true
		end
	end,
-----------------------------------
	["Mutilate"] = function()
		if GetComboPoints("player") < 5
		 and ni.spell.available(48666)
		 and ni.spell.valid("target", 48666, true, true) then
			ni.spell.cast(48666, "target")
			return true
		end
	end,
-----------------------------------
	["Slice and Dice"] = function()
		local SnD = data.rogue.SnD()
		if GetComboPoints("player") > 3
		 and( not SnD or ( SnD <= 4 ) )
		 and ni.spell.available(6774)
		 and IsSpellInRange(GetSpellInfo(48638), "target") == 1  then
			ni.spell.cast(6774)
			return true
		end
	end,
-----------------------------------
	["Envenom"] = function()
		local Hunger = data.rogue.Hunger()
		local envenom = data.rogue.envenom()
		local SnD = data.rogue.SnD()
		if ni.spell.available(57993)
		 and Hunger
		 and IsUsableSpell(GetSpellInfo(57993)) 
		 and ni.spell.valid("target", 57993, true, true) then
		  if GetComboPoints("player") == 5
		  and not envenom then
			ni.spell.cast(57993, "target")
			return true
          end
		  if GetComboPoints("player") == 5
		  and ni.player.power() > 80 then
			ni.spell.cast(57993, "target")
			return true
          end
		  if GetComboPoints("player") >= 2
		  and ( SnD and SnD < 4 ) then
			ni.spell.cast(57993, "target")
			return true
			end
		end
	end,	  
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Assassination Rogue by DarhangeR for 3.3.5a", 
		 "Welcome to Assassination Rogue Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-Focus ally target for use TofT on it or put tank name to Tank Overrides and press Enable Main.\n-For use Fan of Knives configure AoE Toggle key.")		
		popup_shown = true;
		end 
	end,
}

	ni.bootstrap.profile("Assassination_DarhangeR", queue, abilities, OnLoad, OnUnLoad);
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
    ni.bootstrap.profile("Assassination_DarhangeR", queue, abilities);
end