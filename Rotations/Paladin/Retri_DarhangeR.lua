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
	settingsfile = "DarhangeR_Retri.xml",
	{ type = "title", text = "Retribution Paladin by |c0000CED1DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "|cffFFFF00Main Settings" },
	{ type = "separator" },	
	{ type = "entry", text = "Divine Plea", tooltip = "Use spell when player mana < %", enabled = true, value = 60, key = "plea" },
	{ type = "entry", text = "Sacred Shield", tooltip = "Enable/Disable spell for cast on player", enabled = true, key = "sacred" },
	{ type = "entry", text = "Debug Printing", tooltip = "Enable for debug if you have problems", enabled = false, key = "Debug" },	
	{ type = "separator" },
	{ type = "page", number = 1, text = "|cff00C957Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Flash of Light (Self)", tooltip = "Use spell when player HP < %", enabled = true, value = 90, key = "flashoflight" },
	{ type = "entry", text = "Lay on Hands (Self)", tooltip = "Use spell when player HP < %", enabled = true, value = 25, key = "layon" },
	{ type = "entry", text = "Divine Shield", tooltip = "Use spell when player HP < %", enabled = true, value = 12, key = "divineshield" },
	{ type = "entry", text = "Divine Protection", tooltip = "Use spell when player HP < %", enabled = true, value = 30, key = "divineprot" },
	{ type = "entry", text = "Hand of Protection (Member)", tooltip = "Use spell when member HP < %. Work only on caster clases", enabled = true, value = 25, key = "handofprot" },
	{ type = "entry", text = "Hand of Salvation (Member)", tooltip = "Auto check member agro and use spell", enabled = true, key = "salva" },
	{ type = "entry", text = "Healthstone", tooltip = "Use Warlock Healthstone (if you have) when player HP < %", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", tooltip = "Use Heal Potions (if you have) when player HP < %",  enabled = true, value = 30, key = "healpotionuse" },
	{ type = "entry", text = "Mana Potion", tooltip = "Use Mana Potions (if you have) when player mana < %", enabled = true, value = 25, key = "manapotionuse" },
	{ type = "separator" },
	{ type = "page", number = 2, text = "|cffEE4000Rotation Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Consecration", tooltip = "Enable/Disable spell for using in rotation", enabled = true, key = "concentrat" },
	{ type = "entry", text = "Mana threshold for use", tooltip = "Use Consecration spell when player mana > %", value = 30, key = "concentratmana" },
	{ type = "entry", text = "Holy Wrath (Auto Use)", tooltip = "Auto check and use spell on proper enemies", enabled = false, key = "holywrath" },
	{ type = "entry", text = "Turn Evil (Auto Use)", tooltip = "Auto check and use spell on proper enemies", enabled = false, key = "turn" },	
	{ type = "entry", text = "Auto Control (Member)", tooltip = "Auto check and control member if he mindcontrolled or etc.", enabled = true, key = "control" },	
	{ type = "separator" },
	{ type = "title", text = "Dispel" },
	{ type = "separator" },
	{ type = "entry", text = "Cleanse (Self)", tooltip = "Auto dispel debuffs from player", enabled = true, key = "cleans" },
	{ type = "entry", text = "Cleanse (Member)", tooltip = "Auto dispel debuffs from members", enabled = false, key = "cleansmemb" },
	{ type = "entry", text = "Hand of Freedom (Self)", tooltip = "Auto cast on player when you have criteria for spell", enabled = true, key = "freedom" },
	{ type = "entry", text = "Hand of Freedom (Member)", tooltip = "Auto cast on member when he have criteria for spell", enabled = false, key = "freedommemb" },
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
	ni.GUI.AddFrame("Retri_DarhangeR", items);
end
local function OnUnLoad()  
	ni.GUI.DestroyFrame("Retri_DarhangeR");
end

local queue = {
	"Window",
	"Universal pause",
	"AutoTarget",
	"Seal of Corruption/Vengeance",
	"Seal of Command",
	"Cancel Righteous Fury",
	"Auto Track Undeads",	
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Mana Potions (Use)",
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Lay on Hands (Self)",
	"Divine Shield",
	"Divine Protection",
	"Flash of Light (Self)",
	"Hand of Protection (Member)",
	"Hand of Salvation (Member)",
	"Hand of Freedom (Member)",
	"Hand of Freedom (Self)",
	"Divine Plea",
	"Sacred Shield",
	"Avenging Wrath",
	"Turn Evil (Auto Use)",
	"Control (Member)",
	"Hammer of Wrath",	
	"Judgement of Wisdom",
	"Holy Wrath (Auto Use)",	
	"Divine Storm",
	"Crusader Strike",
	"Holy Wrath (AoE)",
	"Cleanse (Member)",	
	"Cleanse (Self)",
	"Consecration",
	"Exorcism",
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
	["Auto Track Undeads"] = function()
		if ni.player.hasglyph(57947) then
		 if not UnitAffectingCombat("player") 
		  and GetTime() - data.paladin.LastTrack > 3 then
				SetTracking(nil);	
		 end
			-- Undead --				
		 if UnitAffectingCombat("player")
		  and ni.unit.exists("target")
		  and ni.unit.creaturetype("target") == 6
		  and ni.spell.available(5502) 
		  and GetTime() - data.paladin.LastTrack > 3 then 
				data.paladin.LastTrack = GetTime()		  
				ni.spell.cast(5502)
			end				
		end
	end,
-----------------------------------
	["Seal of Corruption/Vengeance"] = function()
		if ActiveEnemies() < 2
		 and IsSpellKnown(53736)
		 and ni.spell.available(53736) then
		 if not ni.player.buff(53736)
		 and GetTime() - data.paladin.LastSeal > 3
		 and not ni.player.buff(31801) then
			ni.spell.cast(53736)
			data.paladin.LastSeal = GetTime()
			return true
		end
	end
		if ActiveEnemies() < 2
		and IsSpellKnown(31801)
		and ni.spell.available(31801) then
		if not ni.player.buff(31801) 
		 and GetTime() - data.paladin.LastSeal > 3
		 and not ni.player.buff(53736) then
			ni.spell.cast(31801)
			data.paladin.LastSeal = GetTime()
			return true
			end
		end
	end,
-----------------------------------
	["Seal of Command"] = function()
		if ActiveEnemies() > 1	
		 and IsSpellKnown(20375)
		 and ni.spell.available(20375)
		 and GetTime() - data.paladin.LastSeal > 3
		 and not ni.player.buff(20375) then 
			ni.spell.cast(20375)
			data.paladin.LastSeal = GetTime()
			return true
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
		 and IsSpellInRange(GetSpellInfo(35395), "target") == 1 then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if IsSpellInRange(GetSpellInfo(35395), "target") == 1
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
		 and IsSpellInRange(GetSpellInfo(35395), "target") == 1 then
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
		 and IsSpellInRange(GetSpellInfo(35395), "target") == 1 then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0 
		 and data.CDsaverTTD("target")
		 and IsSpellInRange(GetSpellInfo(35395), "target") == 1 then
			ni.player.useinventoryitem(14)
			return true
			end
		end
	end,
-----------------------------------
	["Lay on Hands (Self)"] = function()
		local value, enabled = GetSetting("layon");
		local forb = data.paladin.forb()
		if enabled
		 and ni.player.hp() < value
		 and not forb
		 and ni.spell.available(48788) then
			ni.spell.cast(48788)
			return true
		end
	end,
-----------------------------------
	["Divine Shield"] = function()
		local value, enabled = GetSetting("divineshield");
		local forb = data.paladin.forb()
		if enabled
		 and ni.player.hp() < value
		 and not forb
		 and ni.spell.available(642) then
			ni.spell.cast(642)
			return true
		end
	end,
-----------------------------------
	["Divine Protection"] = function()
		local value, enabled = GetSetting("divineprot");
		local forb = data.paladin.forb()
		if enabled
		 and ni.player.hp() < value
		 and not forb
		 and ni.spell.available(498)
		 and not ni.player.buff(498)  then
			ni.spell.cast(498)
			return true
		end
	end,
-----------------------------------
	["Flash of Light (Self)"] = function()
		local value, enabled = GetSetting("flashoflight");
		local aow = data.paladin.aow()
		if enabled
		 and ni.player.hp() < value
		 and aow
		 and ni.spell.isinstant(48785)
		 and not ni.spell.available(48801)
		 and ni.spell.available(48785) then
			ni.spell.cast(48785, "player")
			return true
		end
	end,
-----------------------------------
	["Hand of Salvation (Member)"] = function()
		local _, enabled = GetSetting("salva")
		if enabled
		 and #ni.members > 1		 
		 and ni.spell.available(1038) then
		  if ni.members[1].threat >= 2
		   and not ni.members[1].istank
		   and not data.paladin.HandActive(ni.members[1].unit)		    
		   and ni.spell.valid(ni.members[1].unit, 1038, false, true, true) then 
				ni.spell.cast(1038, ni.members[1].unit)
				return true
			end
		end
	end,
-----------------------------------
	["Hand of Protection (Member)"] = function()
		local value, enabled = GetSetting("handofprot");
		if enabled
		 and #ni.members > 1		 
		 and ni.spell.available(10278) then
		  if ni.members[1].range
		  and ni.members[1].hp < value
		  and not ni.members[1].istank
		  and ni.members[1].threat >= 2
		  and ni.members[1].class ~= "DEATHKNIGHT"
		  and not (ni.members[1].class == "DRUID"
		  and ni.unit.buff(ni.members[1].unit, 768))
		  and ni.members[1].class ~= "HUNTER"
		  and ni.members[1].class ~= "PALADIN"
		  and ni.members[1].class ~= "ROGUE"
		  and ni.members[1].class ~= "WARRIOR"
		  and not data.paladin.HandActive(ni.members[1].unit)
		  and not ni.unit.debuff(ni.members[1].unit, 25771)
		  and ni.spell.valid(ni.members[1].unit, 10278, false, true, true) then 
				ni.spell.cast(10278, ni.members[1].unit)
				return true
			end
		end
	end,
-----------------------------------
	["Divine Plea"] = function()
		local value, enabled = GetSetting("plea");
		if enabled 
		 and ni.player.power() < value
		 and not ni.player.buff(54428)		 
		 and ni.spell.available(54428) then
			ni.spell.cast(54428)
			return true
		end
	end,
-----------------------------------
	["Sacred Shield"] = function()
		local _, enabled = GetSetting("sacred")
		if enabled
		 and not ni.player.buff(53601)  
		 and ni.spell.available(53601) then
			ni.spell.cast(53601, "player")
			return true
		end
	end,
-----------------------------------
	["Avenging Wrath"] = function()
		if ( ni.vars.CD or ni.unit.isboss("target") )
		 and ni.spell.available(31884)
		 and data.CDsaverTTD("target")
		 and ni.spell.valid("target", 35395) then
			ni.spell.cast(31884)
			return true
		end
	end,
-----------------------------------
	["Judgement of Wisdom"] = function()
		if ni.spell.available(53408)
		 and ni.spell.valid("target", 53408, false, true, true) then
			ni.spell.cast(53408, "target")
			return true
		end
	end,
-----------------------------------
	["Divine Storm"] = function()
		if ni.spell.available(53385)
		 and ni.spell.valid("target", 35395) then
			ni.spell.cast(53385, "target")
			return true
		end
	end,
-----------------------------------
	["Crusader Strike"] = function()
		if ni.spell.available(35395)
		 and ni.spell.valid("target", 35395, true, true) then
			ni.spell.cast(35395, "target")
			return true
		end
	end,
-----------------------------------
	["Holy Wrath (Auto Use)"] = function()
		local _, enabled = GetSetting("concentrat")
		if enabled
		 and ni.spell.available(48817)
		 and (ni.unit.creaturetype("target") == 3
		 or ni.unit.creaturetype("target") == 6)
		 and ni.player.distance("target") < 5 then
			ni.spell.cast(48817)
			return true
		end
	end,
-----------------------------------
	["Holy Wrath (AoE)"] = function()
		if ni.vars.combat.aoe
		 and ni.spell.available(48817)
		 and ni.spell.valid("target", 35395, true, true) then
			ni.spell.cast(48817)
			return true
		end
	end,
-----------------------------------
	["Consecration"] = function()
		local _, enabled = GetSetting("concentrat")
		local value = GetSetting("concentratmana") 
		if enabled
		 and ni.player.power() > value
		 and ni.spell.available(48819)
		 and ni.spell.valid("target", 35395) then
			ni.spell.cast(48819)
			return true
		end
	end,
-----------------------------------
	["Exorcism"] = function()
		local aow = data.paladin.aow()
		if aow
		 and ni.spell.isinstant(48801)
		 and ni.spell.available(48801)
		 and ni.spell.valid("target", 48801, true, true) then
			ni.spell.cast(48801, "target")
			return true
		end
	end,
-----------------------------------
	["Hammer of Wrath"] = function()
		if (ni.unit.hp("target") <= 20
		 or IsUsableSpell(GetSpellInfo(48806)))
		 and ni.spell.available(48806)
		 and ni.spell.valid("target", 48806, true, true) then
			ni.spell.cast(48806, "target")
			return true
		end
	end,
-----------------------------------	
	["Hand of Freedom (Self)"] = function()
		local _, enabled = GetSetting("freedom")
		if enabled
		 and ni.player.ismoving()
		 and data.paladin.FreedomUse("player")
		 and not data.paladin.HandActive("player")
		 and ni.spell.available(1044) then
			ni.spell.cast(1044, "player")
			return true
		end
	end,
-----------------------------------
	["Hand of Freedom (Member)"] = function()
		local _, enabled = GetSetting("freedommemb")
		if enabled
		 and ni.spell.available(1044) then
		  for i = 1, #ni.members do
		   local ally = ni.members[i].unit
		    if ni.unit.ismoving(ally)
		     and data.paladin.FreedomUse(ally)
		     and not data.paladin.HandActive(ally)
		     and ni.spell.valid(ally, 1044, false, true, true) then
					ni.spell.cast(1044, ally)
					return true
				end
                   end
		end
	end,
-----------------------------------
	["Cleanse (Self)"] = function()
		local _, enabled = GetSetting("cleans")
		if enabled
		 and ni.player.debufftype("Magic|Disease|Poison")
		 and ni.spell.available(4987)
		 and ni.healing.candispel("player")
		 and GetTime() - data.LastDispel > 1.5
		 and ni.spell.valid("player", 4987, false, true, true) then
			ni.spell.cast(4987, "player")
			data.LastDispel = GetTime()
			return true
		end
	end,
-----------------------------------
	["Cleanse (Member)"] = function()
		local _, enabled = GetSetting("cleansmemb")
		if enabled	
		 and ni.spell.available(4987) then
		  for i = 1, #ni.members do
		  if ni.unit.debufftype(ni.members[i].unit, "Magic|Disease|Poison")
		  and ni.healing.candispel(ni.members[i].unit)
		  and GetTime() - data.LastDispel > 1.2
		  and ni.spell.valid(ni.members[i].unit, 4987, false, true, true) then
				ni.spell.cast(4987, ni.members[i].unit)
				data.LastDispel = GetTime()
				return true
				end
			end
		end
	end,
-----------------------------------
	["Turn Evil (Auto Use)"] = function()        
		local _, enabled = GetSetting("turn")
		if enabled 
		 and ni.unit.exists("target")
		 and ni.spell.available(10326)
		 and UnitCanAttack("player", "target") then
		 table.wipe(enemies);
		  enemies = ni.unit.enemiesinrange("player", 25)
		  local dontTurn = false
		  for i = 1, #enemies do
		   local tar = enemies[i].guid; 
		   if (ni.unit.creaturetype(enemies[i].guid) == 3
		    or ni.unit.creaturetype(enemies[i].guid) == 6
		    or ni.unit.aura(enemies[i].guid, 49039))
		    and ni.unit.debuff(tar, 10326, "player") then
			dontTurn = true
			break
		end
        end
		if not dontTurn then
		 for i = 1, #enemies do
		 local tar = enemies[i].guid; 
		  if (ni.unit.creaturetype(enemies[i].guid) == 3
		   or ni.unit.creaturetype(enemies[i].guid) == 6
		   or ni.unit.aura(enemies[i].guid, 49039))
		   and not ni.unit.isboss(tar)
		   and not ni.unit.debuffs(tar, "23920||35399||69056", "EXACT")
		   and not ni.unit.debuff(tar, 10326, "player")
		   and ni.spell.valid(enemies[i].guid, 10326, false, true, true)
		   and GetTime() - data.paladin.LastTurn > 1.5 then
				ni.spell.cast(10326, tar)
				data.paladin.LastTurn = GetTime()
                        return true
					end
				end
			end
		end
	end,
-----------------------------------
	["Control (Member)"] = function()
		local _, enabled = GetSetting("control")
		if enabled
		 and ni.spell.available(20066) then
		  for i = 1, #ni.members do
		   local ally = ni.members[i].unit
		    if data.ControlMember(ally)
			and not data.UnderControlMember(ally)
			and ni.spell.valid(ally, 20066, false, true, true) then
				ni.spell.cast(20066, ally)
				return true
				end
			end
		end
		if not ni.spell.available(20066)
		 and ni.spell.available(10308) then 
		  for i = 1, #ni.members do
		   local ally = ni.members[i].unit
		    if data.ControlMember(ally)
			and not data.UnderControlMember(ally)
			and ni.spell.valid(ally, 10308, false, true, true) then
				ni.spell.cast(10308, ally)
				return true
				end
			end
		end		
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Retribution Paladin by DarhangeR for 3.3.5a", 
		 "Welcome to Retribution Paladin Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For use Holy Wrath configure AoE Toggle key.")
		popup_shown = true;
		end 
	end,
}

	ni.bootstrap.profile("Retri_DarhangeR", queue, abilities, OnLoad, OnUnLoad);
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
    ni.bootstrap.profile("Retri_DarhangeR", queue, abilities);
end