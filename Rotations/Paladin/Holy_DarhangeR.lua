local data = ni.utils.require("DarhangeR");
local popup_shown = false;
local enemies = { };
local build = select(4, GetBuildInfo());
local level = UnitLevel("player");
if build == 30300 and level == 80 and data then
local items = {
	settingsfile = "DarhangeR_HolyPaladin.xml",
	{ type = "title", text = "Holy Paladin by |c0000CED1DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "|cffFFFF00Main Settings" },
	{ type = "separator" },	
	{ type = "entry", text = "Divine Plea", tooltip = "Use spell when player mana < %", enabled = true, value = 60, key = "plea" },
	{ type = "entry", text = "Divine Illumination", tooltip = "Use spell when player mana < %", enabled = true, value = 35, key = "illumination" },	
	{ type = "entry", text = "Debug Printing", tooltip = "Enable for debug if you have problems", enabled = false, key = "Debug" },	
	{ type = "separator" },
	{ type = "page", number = 1, text = "|cff00C957Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Divine Shield", tooltip = "Use spell when player HP < %", enabled = true, value = 22, key = "divineshield" },
	{ type = "entry", text = "Healthstone", tooltip = "Use Warlock Healthstone (if you have) when player HP < %", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", tooltip = "Use Heal Potions (if you have) when player HP < %",  enabled = true, value = 30, key = "healpotionuse" },
	{ type = "entry", text = "Mana Potion", tooltip = "Use Mana Potions (if you have) when player mana < %", enabled = true, value = 25, key = "manapotionuse" },
	{ type = "separator" },
	{ type = "page", number = 2, text = "|cff95f900CD's and important spells" },
	{ type = "separator" },
	{ type = "entry", text = "Exorcism", tooltip = "Use spell when player mana > 75%", enabled = false, key = "exorc" },
	{ type = "entry", text = "Aura Mastery", tooltip = "Enable spell", enabled = true, key = "auramastery" },
	{ type = "entry", text = "Aura Mastery (Members HP)", tooltip = "Use spell when member HP < %", value = 30, key = "auramasteryhp" },
	{ type = "entry", text = "Aura Mastery (Members Count)", tooltip = "Use spell when member count in Party/Raid have low hp", value = 4, key = "auramasterycount" },
	{ type = "entry", text = "Hand of Sacrifice (Member)", tooltip = "Use spell when member HP < %", enabled = true, value = 25, key = "handsacrifice" },
	{ type = "entry", text = "Hand of Salvation (Member)", tooltip = "Auto check member agro and use spell", enabled = true, key = "salva" },
	{ type = "entry", text = "Hand of Protection (Member)", tooltip = "Use spell when member HP < %. Work only on caster clases", enabled = true, value = 20, key = "handofprot" },
	{ type = "entry", text = "Turn Evil (Auto Use)", tooltip = "Auto check and use spell on proper enemies", enabled = false, key = "turn" },	
	{ type = "entry", text = "Auto Control (Member)", tooltip = "Auto check and control member if he mindcontrolled or etc.", enabled = true, key = "control" },		
	{ type = "separator" },
	{ type = "title", text = "Dispel" },
	{ type = "separator" },
	{ type = "entry", text = "Cleanse (Member)", tooltip = "Auto dispel debuffs from members", enabled = true, key = "cleans" },
	{ type = "entry", text = "Hand of Freedom (Member)", tooltip = "Auto cast on member when he have criteria for spell", enabled = true, key = "freedom" },
	{ type = "separator" },
	{ type = "page", number = 3, text = "|cff95f900Healing spells settings" },
	{ type = "separator" },
	{ type = "entry", text = "Non Combat Healing", tooltip = "Heal members after fight when HP < %", enabled = true, value = 95, key = "noncombatheal" },
	{ type = "entry", text = "Holy Light", tooltip = "Use spell when member HP < %", enabled = true, value = 40, key = "light" },
	{ type = "entry", text = "Holy Light (Glyph)", tooltip = "Use spell when you have glyph and member HP < %", enabled = true, value = 55, key = "lightglyph" },	
	{ type = "entry", text = "Holy Shock", tooltip = "Use spell when member HP < %", enabled = true, value = 75, key = "shock" },
	{ type = "entry", text = "Flash of Light", tooltip = "Use spell when member HP < %", enabled = true, value = 85, key = "flash" },
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
	ni.GUI.AddFrame("Holy_DarhangeR", items);
end
local function OnUnLoad()  
	ni.GUI.DestroyFrame("Holy_DarhangeR");
end

local queue = {
	"Window",
	"Universal pause",
	"Seal of Wisdom/Light",
	"Cancel Righteous Fury",
	"Divine Plea",
	"Non Combat Healing",
	"Auto Track Undeads",
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
	"Valithria Heal",
	"Turn Evil (Auto Use)",
	"Control (Member)",	
	"Holy Light (Glyph)",
	"Holy Light",
	"Holy Shock",
	"Flash of Light",
	"Hand of Freedom (Member)",
}
local abilities = {
-----------------------------------
	["Universal pause"] = function()
		if (data.UniPause() 
		 or data.PlayerDebuffs("player")) then
			return true
		end
		ni.vars.debug = select(2, GetSetting("Debug"));
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
	["Judgement of Light"] = function()
		if ni.spell.available(20271)
		 and ni.members[1].hp > 75
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
		 and ni.player.power() > 75
		 and ni.spell.available(48801)
		 and not ni.player.ismoving() 
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
		 and ni.spell.available(6940) then
		   if ni.members[1].range
		   and ni.members[1].hp < value
		   and ni.player.hp() >= 65
		   and not ni.members[1].istank
		   and not data.paladin.HandActive(ni.members[1].unit)
		   and ni.spell.valid(ni.members[1].unit, 6940, false, true, true) then
				ni.spell.cast(6940, ni.members[1].unit)
				return true
			end
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
	["Avenging Wrath"] = function()
		if data.youInInstance()
		 and ni.members.averageof(4) < 30
		 and ni.spell.available(31821) then
			ni.spell.cast(31821)
			return true
		end
		if data.youInRaid()
		 and ni.members.averageof(7) < 30
		 and ni.spell.available(31821) then
			ni.spell.cast(31821)
			return true
		end
	end,
-----------------------------------
	["Divine Illumination T10"] = function()
		if data.checkforSet(data.paladin.itemsetT10, 2) then 
		 if data.youInInstance()
		 and ni.members.averageof(4) < 45
		 and not ni.player.buff(54428)
		 and ni.spell.available(31842) then
			ni.spell.cast(31842)
			return true
			end
		else
		if data.youInRaid()
		 and ni.members.averageof(9) < 45
		 and not ni.player.buff(54428)
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
			-- Put Beacon on MT -- 
		if not ni.unit.exists("boss1") then
		 if (not BofLtank
		 or (BofLtank and BofLtank_time - GetTime() < 2))
		 and ni.spell.available(53563)
		 and ni.spell.valid(tank, 53563, false, true, true) then
			 ni.spell.cast(53563, tank)
			 return true
			end
		end
			-- Put Sacred on MT -- 
		 if not ni.unit.exists("boss1") then
		  if not SelfSCtank
		  and (not SCtank
		  or (SCtank and SCtank_time - GetTime() < 2))	 
		  and ni.spell.available(53601)
		  and ni.spell.valid(tank, 53601, false, true, true) then
			 ni.spell.cast(53601, tank)
			 return true
			end
		end
		  if not ni.unit.exists("boss1") then
		   if SelfSCtank		 
		    and ni.spell.available(53601)
			and not ni.player.buff(53601) then
			 ni.spell.cast(53601, "player")
			 return true
			end			
		end
			-- Heal MT with Lay on Hands --
		 if tank ~= nil
		 and ni.unit.hp(tank) < 12
		 and not forbtank
		 and ni.spell.available(48788)
		 and ni.spell.valid(tank, 48788, false, true, true) then
			ni.spell.cast(48788, tank)
			return true
		end
			-- Heal MT with Holy Light --	
		 if tank ~= nil
		 and ni.unit.hp(tank) < 25
		 and ni.spell.available(20216)
		 and ni.spell.available(48825)
		 and ni.spell.valid(tank, 48825, false, true, true) then
			ni.spell.castspells("20216|48825", tank)
			return true
			end
		end
	end,
-----------------------------------
	["Valithria Heal"] = function()
		local tank = ni.tanks()
		if ni.unit.exists("boss1") then
		 if ni.unit.id("boss1") == 36789 
		  and ni.unit.hp("boss1") < 100 then
		 local BofLBoss, _, _, _, _, _, BofLBoss_time = ni.unit.buff("boss1", 53563, "player")
		 local SCBoss, _, _, _, _, _, SCBoss_time = ni.unit.buff("boss1", 53601, "player")
		 local SCtank, _, _, _, _, _, SCtank_time = ni.unit.buff(tank, 53601, "player")
		 local SelfSCtank = ni.unit.buff(tank, 53601)		
		 local SelfSCBoss = ni.unit.buff("boss1", 53601)
		-- Put Beacon on Boss --         
		if (not BofLBoss
		 or (BofLBoss and BofLBoss_time - GetTime() < 2))
		 and ni.spell.available(53563)
		 and ni.spell.valid("boss1", 53563, false, true, true) then
			ni.spell.cast(53563, "boss1")
			return true
		end
		-- Put Sacred on Boss --
		if (not SelfSCBoss
		 or (SCBoss and SCBoss_time - GetTime() < 2))       
		 and ni.spell.available(53601)
		 and ni.spell.valid("boss1", 53601, false, true, true) then
			ni.spell.cast(53601, "boss1")
			return true
		end
		if SelfSCBoss
		 and ni.unit.exists(tank)
		 and (not SelfSCtank
		 or (SCtank and SCtank_time - GetTime() < 2))        
		 and ni.spell.available(53601)
		 and ni.spell.valid(tank, 53601, false, true, true) then
			ni.spell.cast(53601, tank)
			return true
		end         
		-- Heal Boss with Holy Light --
		if not ni.player.ismoving()
		 and ni.members[1].hp > 80        
		 and ni.spell.available(48782)
		 and not ni.player.ismoving()
		 and GetTime() - data.paladin.LastHoly > 6
		 and ni.spell.valid("boss1", 48782, false, true, true) then
			ni.spell.cast(48782, "boss1")
			data.paladin.LastHoly = GetTime()        
			return true
		end
		-- Heal Boss with Flash of Light --    
		if not ni.player.ismoving()
		 and ni.members[1].hp > 80        
		 and ni.spell.available(48785)
		 and not ni.player.ismoving()
		 and ni.unit.buffremaining("boss1", 66922, "player") < ni.spell.casttime(48785)
		 and ni.spell.valid("boss1", 48785, false, true, true) then
			ni.spell.cast(48785, "boss1")    
			return true
		end
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
	["Holy Light (Glyph)"] = function()
		local value, enabled = GetSetting("lightglyph");
		local friends = ni.members.inrangebelow(ni.members[1].unit, 7, 85) 
		if enabled 
		 and ni.player.hasglyph(54937)
		 and ni.spell.available(48782)
		 and ni.members.averageof(3) < 85
		 and not ni.player.ismoving() then
		  if ni.members[1].hp < value
		   and #friends > 3
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
		 and ni.spell.available(48825) then
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
	["Hand of Freedom (Member)"] = function()
		local _, enabled = GetSetting("freedom")
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
		 ni.debug.popup("Holy Paladin by DarhangeR for 3.3.5a", 
		 "Welcome to Holy Paladin Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For enable priority healing Main Tank put tank name to Tank Overrides and press Enable Main")	
		popup_shown = true;
		end 
	end,
}

	ni.bootstrap.profile("Holy_DarhangeR", queue, abilities, OnLoad, OnUnLoad);
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
    ni.bootstrap.profile("Holy_DarhangeR", queue, abilities);
end