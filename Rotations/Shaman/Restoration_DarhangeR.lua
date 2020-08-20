local data = ni.utils.require("DarhangeR");
local popup_shown = false;
local enemies = { };
local build = select(4, GetBuildInfo());
local level = UnitLevel("player");
if build == 30300 and level == 80 and data then
local items = {
	settingsfile = "DarhangeR_Shaman_Resto.xml",
	{ type = "title", text = "Restoration Shaman by |c0000CED1DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "|cffFFFF00Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Auto Interrupt", tooltip = "Auto check and interrupt all interruptible spells", enabled = true, key = "autointerrupt" },
	{ type = "entry", text = "Debug Printing", tooltip = "Enable for debug if you have problems", enabled = false, key = "Debug" },	
	{ type = "separator" },
	{ type = "page", number = 1, text = "|cff00C957Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "Healthstone", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "Heal Potion", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "entry", text = "Mana Potion", enabled = true, value = 25, key = "manapotionuse" },
	{ type = "separator" },
	{ type = "page", number = 2, text = "|cff95f900CD's and important spells" },
	{ type = "separator" },
	{ type = "entry", text = "Auto Control (Member)", tooltip = "Auto check and control member if he mindcontrolled or etc.", enabled = true, key = "control" },	
	{ type = "entry", text = "Purge", tooltip = "Purge proper spell. You can edit table in Data file.", enabled = true, key = "purge" },
	{ type = "entry", text = "Flame Shock", tooltip = "Use spell when player mana > 75%", enabled = false, key = "flame" },
	{ type = "entry", text = "Nature Swiftness", enabled = true, value = 40, key = "natureswift" },
	{ type = "entry", text = "Tidal Force", enabled = true, key = "tidal" },
	{ type = "entry", text = "Tidal Force (Members HP)", value = 37, key = "tidalhp" },
	{ type = "entry", text = "Tidal Force (Members Count)", value = 4, key = "tidalcount" },
	{ type = "separator" },
	{ type = "title", text = "Dispel" },
	{ type = "separator" },
	{ type = "entry", text = "Cure Toxins (Member)", tooltip = "Auto dispel debuffs from members", enabled = false, key = "toxinsmemb" },
	{ type = "entry", text = "Cleanse Spirit (Member)", tooltip = "Auto dispel debuffs from members", enabled = true, key = "spiritmemb" },	
	{ type = "separator" },
	{ type = "page", number = 3, text = "|cff95f900Healing spells settings" },
	{ type = "separator" },
	{ type = "entry", text = "Non Combat Healing", tooltip = "Heal members after fight when HP < %", enabled = true, value = 95, key = "noncombatheal" },	
	{ type = "entry", text = "Riptide", tooltip = "Use spell when member HP < %", enabled = true, value = 89, key = "riptide" },	
	{ type = "entry", text = "Lesser Healing Wave", tooltip = "Use spell when member HP < %", enabled = true, value = 40, key = "leserhealing" },
	{ type = "entry", text = "Healing Wave", tooltip = "Use spell when member HP < %", enabled = true, value = 70, key = "healingwave" },
	{ type = "entry", text = "Chain Heal", tooltip = "Use spell when member HP < %", enabled = true, value = 83, key = "сhain" },	
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
	ni.GUI.AddFrame("Restoration_DarhangeR", items);
end
local function OnUnLoad()  
	ni.GUI.DestroyFrame("Restoration_DarhangeR");
end

local queue = {
	"Window",
	"Universal pause",
	"Enchant Weapon",
	"Water Shield",
	"Non Combat Healing",
	"Combat specific Pause",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Mana Potions (Use)",
	"Racial Stuff",
	"Wind Shear (Interrupt)",
	"Control (Member)",
	"Tank Heal",
	"Valithria Heal",
	"Tidal Force",
	"Nature's Swiftness",
	"Flame Shock",	
	"Lesser Healing Wave",
	"Chain Heal Spam",
	"Chain Heal",
	"Riptide",
	"Cleanse Spirit (Member)",
	"Cure Toxins (Member)",
	"Purge",
	"Healing Wave",
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
	["Enchant Weapon"] = function()
		local mh, _, _, oh = GetWeaponEnchantInfo()
		if not mh
		 and ni.spell.available(51994) then
			ni.spell.cast(51994)
			return true
		end
	end,
-----------------------------------
	["Water Shield"] = function()
		if not ni.player.buff(57960)
		 and ni.spell.available(57960) then
			ni.spell.cast(57960)
			return true
		end
	end,
-----------------------------------
	["Non Combat Healing"] = function()
		local value, enabled = GetSetting("noncombatheal");
		if enabled
		 and not UnitAffectingCombat("player")
		 and ni.spell.available(61301)		 
		 and ni.spell.available(49276) then
		   if ni.members[1].hp < value
		    and not ni.unit.buff(ni.members[1].unit, 61301, "player")
		    and ni.spell.valid(ni.members[1].unit, 61301, false, true, true) then
				ni.spell.cast(61301, ni.members[1].unit)
				return true
			end
		   if ni.members[1].hp < value
		    and not ni.player.ismoving()
		    and ni.spell.valid(ni.members[1].unit, 49276, false, true, true) then
				ni.spell.cast(49276, ni.members[1].unit)
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
		 and ni.spell.valid("target", 49238, true, true) then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if ni.spell.valid("target", 49238, true, true)
		 and ni.player.hp() < 20
		 and IsSpellKnown(alracial[i])
		 and ni.spell.available(alracial[i]) then 
					ni.spell.cast(alracial[i])
					return true
				end
			end
		end,
-----------------------------------
	["Wind Shear (Interrupt)"] = function()
		local _, enabled = GetSetting("autointerrupt")
		if enabled
		 and ni.spell.shouldinterrupt("target")
		 and ni.spell.available(57994)
		 and GetTime() - data.LastInterrupt > 9
		 and ni.spell.valid("target", 57994, true, true)  then
			ni.spell.castinterrupt("target")
			data.LastInterrupt = GetTime()
			return true
		end
	end,
-----------------------------------
	["Tank Heal"] = function()
		local tank = ni.tanks()
		-- Main Tank Heal
		if ni.unit.exists(tank) then
		 local EarthTank, _, _, _, _, _, EarthTank_time = ni.unit.buff(tank, 49284, "player")
		 local OthEarthTank = ni.unit.buff(tank, 49284)
		 -- Put Earth Shield on MT
		if not ni.unit.exists("boss1") then
		if not OthEarthTank
		 and not EarthTank		 
		 and ni.spell.available(49284)
		 and ni.spell.valid(tank, 49284, false, true, true) then
			ni.spell.cast(49284, tank)
			return true
			end
		end
		if tank ~= nil
		 and ni.unit.hp(tank) < 30
		 and ni.spell.available(16188)
		 and ni.spell.available(49273)
		 and ni.spell.valid(tank, 49273, false, true, true) then
			ni.spell.cast(16188)
			ni.spell.cast(49273, tank)			
			return true
			end
		end
	end,
-----------------------------------
	["Valithria Heal"] = function()
		local friends = ni.members.inrangebelow(ni.members[1].unit, 9, 79)
		local tank = ni.tanks()
		if ni.unit.exists("boss1") then
		 if ni.unit.id("boss1") == 36789 
		  and ni.unit.hp("boss1") < 100 then
		 local ReptideBoss, _, _, _, _, _, ReptideBoss_time = ni.unit.buff("boss1", 61301, "player")		 
		 local EarthBoss, _, _, _, _, _, EarthBoss_time = ni.unit.buff("boss1", 49284, "player")	
		 local SelfEarthBoss = ni.unit.buff("boss1", 49284)
		-- Put Earth Shield on Boss --
		if (not SelfEarthBoss
		 or (EarthBoss and EarthBoss_time - GetTime() < 2))       
		 and ni.spell.available(49284)
		 and ni.spell.valid("boss1", 49284, false, true, true) then
			ni.spell.cast(49284, "boss1")
			return true
		end
		-- Heal Boss with Reptide 
		if ni.spell.available(61301)
		 and (not ReptideBoss
		 or (ReptideBoss and ReptideBoss_time - GetTime() < 2))
		 and ni.spell.valid("boss1", 61301, false, true, true) then
			ni.spell.cast(61301, "boss1")
			return true
		end		
		-- Heal Boss with Chain --
		if not ni.player.ismoving()
		 and ni.spell.available(55459)
		 and #friends > 1
		 and ni.spell.valid("boss1", 55459, false, true, true) then
			ni.spell.cast(55459, "boss1")
			return true
		end	
		-- Heal Boss with Healing Wave --
		if not ni.player.ismoving()
		 and ni.members[1].hp > 80        
		 and ni.spell.available(49273)
		 and not ni.player.ismoving()
		 and GetTime() - data.shaman.LastWave > 4.5
		 and ni.spell.valid("boss1", 49273, false, true, true) then
			ni.spell.cast(49273, "boss1")
			data.shaman.LastWave = GetTime()        
			return true
		end
			end
		end
	end,
-----------------------------------
	["Tidal Force"] = function()
		local _, enabled = GetSetting("tidal");
		local valueHp = GetSetting("tidalhp");
		local valueCount = GetSetting("tidalcount");	
		if enabled
		 and ni.members.averageof(valueCount) < valueHp
		 and not ni.player.ismoving()
		 and ni.spell.available(55198) then
			ni.spell.cast(55198)
			return true
		end
	end,
-----------------------------------
	["Nature's Swiftness"] = function()
		local value, enabled = GetSetting("natureswift");
		if enabled
		 and ni.spell.available(16188)
		 and ni.spell.available(49273) then
		  for i = 1, #ni.members do
		   if ni.members[i].hp < value
		    and ni.spell.valid(ni.members[i].unit, 49273, false, true, true) then
				ni.spell.cast(16188)
				ni.spell.cast(49273, ni.members[i].unit)
				return true
				end
			end
		end
	end,
-----------------------------------
	["Lesser Healing Wave"] = function()
		local value, enabled = GetSetting("leserhealing");
		 if enabled
		 and ni.spell.available(49276)
		 and not ni.player.ismoving() then
		  for i = 1, #ni.members do
		   if ni.members[i].hp < value
		   and ni.spell.valid(ni.members[i].unit, 49276, false, true, true) then
				ni.spell.cast(49276, ni.members[i].unit)
				return true
				end
			end
		end
	end,
-----------------------------------
	["Riptide"] = function()
		local value, enabled = GetSetting("riptide");
		if enabled
		 and ni.spell.available(61301) then
		-- Lowest member Tank but one member more need heal
		 if ni.members[1].hp < value
		  and ni.unit.buff(ni.members[1].unit, 49284, "player")
		  and ni.members[2].hp + 12.5 < value
		  and ni.spell.valid(ni.members[2].unit, 61301, false, true, true) then
			ni.spell.cast(61301, ni.members[2].unit)
			return true
		end
		 -- Lowest member Tank and nobody else
		 if ni.members[1].hp < value
		  and ni.unit.buff(ni.members[1].unit, 49284, "player")
		  and ni.members[2].hp + 12.5 >= value
		  and ni.spell.valid(ni.members[1].unit, 61301, false, true, true) then
			ni.spell.cast(61301, ni.members[1].unit)
			return true
		end
		 -- Lowest member isn't Tank
		 if ni.members[1].hp < value
		  and not ni.unit.buff(ni.members[1].unit, 49284, "player")
		  and ni.spell.valid(ni.members[1].unit, 61301, false, true, true) then
			ni.spell.cast(61301, ni.members[1].unit)
			return true
			end
		end
	end,
-----------------------------------
	["Healing Wave"] = function()
		local value, enabled = GetSetting("healingwave");
		if enabled 
		 and ni.spell.available(49273)
		 and not ni.player.ismoving() then
		-- Lowest member Tank but one member more need heal
		 if ni.members[1].hp < value
		  and ni.unit.buff(ni.members[1].unit, 49284, "player")
		  and ni.members[2].hp + 5 < value
		  and ni.spell.valid(ni.members[2].unit, 49273, false, true, true) then
			ni.spell.cast(49273, ni.members[2].unit)
			return true
		end
		 -- Lowest member Tank and nobody else
		if ni.members[1].hp < value
		  and ni.unit.buff(ni.members[1].unit, 49284, "player")
		  and ni.members[2].hp + 5 >= value
		  and ni.spell.valid(ni.members[1].unit, 49273, false, true, true) then
			ni.spell.cast(49273, ni.members[1].unit)
			return true
		end
		 -- Lowest member isn't Tank
		if ni.members[1].hp < value
		  and ni.spell.valid(ni.members[1].unit, 49273, false, true, true) then
			ni.spell.cast(49273, ni.members[1].unit)
			return true
			end
		end
	end,
-----------------------------------
	["Cleanse Spirit (Member)"] = function()
		local _, enabled = GetSetting("spiritmemb")
		if enabled
		 and ni.spell.available(51886) then
		  for i = 1, #ni.members do
		  if ni.unit.debufftype(ni.members[i].unit, "Poison|Disease|Curse")
		   and ni.healing.candispel(ni.members[i].unit)
		   and GetTime() - data.LastDispel > 1.5
		   and ni.spell.valid(ni.members[i].unit, 51886, false, true, true) then
				ni.spell.cast(51886, ni.members[i].unit)
				data.LastDispel = GetTime()
				return true
				end
			end
		end
	end,
-----------------------------------
	["Cure Toxins (Member)"] = function()
		local _, enabled = GetSetting("toxinsmemb")
		if enabled
		 and not IsSpellKnown(51886)
		 and ni.spell.available(526) then
		  for i = 1, #ni.members do
		  if ni.unit.debufftype(ni.members[i].unit, "Disease|Poison")
		   and ni.healing.candispel(ni.members[i].unit)
		   and GetTime() - data.LastDispel > 1.5
		   and ni.spell.valid(ni.members[i].unit, 526, false, true, true) then
				ni.spell.cast(526, ni.members[i].unit)
				data.LastDispel = GetTime()
				return true
				end
			end
		end
	end,
-----------------------------------
	["Purge"] = function()
		local _, enabled = GetSetting("purge")
		if enabled
		 and data.shaman.canPurge("target")
		 and ni.spell.available(8012)
		 and ni.spell.valid("player", 8012, true, true)
		 and GetTime() - data.shaman.LastPurge > 2.5 then
			ni.spell.cast(8012, "target")
			data.shaman.LastPurge = GetTime()
			return true
		end
	end,
-----------------------------------
	["Chain Heal"] = function()
		local value, enabled = GetSetting("сhain");
		local friends = ni.members.inrangebelow(ni.members[1].unit, 9, value)
		local riptidetarget = ni.members[1].unit
		for i = 1, #friends do
		 if ni.unit.buff(friends[i].guid, "Riptide", "player") then
				riptidetarget = friends[i].guid
				break
			end
		end
		if enabled
		 and ni.spell.available(55459) 
		 and not ni.player.ismoving() then
		-- Heal party/raid with Chain Heal
		if #friends > 3
		 and ni.player.hasglyph(55437)
		 and ni.members[1].hp < value 
		 and ni.spell.valid(riptidetarget, 55459, false, true, true) then
				ni.spell.cast(55459, riptidetarget)
				return true
		end
		-- Heal party/raid with Chain Heal    
		if #friends > 1
		 and ni.members[1].hp < value
		 and ni.spell.valid(riptidetarget, 55459, false, true, true) then
				ni.spell.cast(55459, riptidetarget)
				return true
			end
		end
	end,
-----------------------------------
	["Chain Heal Spam"] = function()
		local friends = ni.members.inrange(ni.members[1].unit, 9)
		if ni.vars.combat.aoe
		 and ni.spell.available(55459) 
		 and not ni.player.ismoving() then
		-- Heal party/raid with Chain Heal	
		if ni.members.averageof(2) < 90
		 and ni.members[1].hp < 95
		 and #friends > 1
		 and ni.spell.valid(ni.members[1].unit, 55459, false, true, true) then
				ni.spell.cast(55459, ni.members[1].unit)
				return true
			end
		end
	end,
-----------------------------------
	["Flame Shock"] = function()	
		local _, enabled = GetSetting("flame");
		local flameshock = data.shaman.flameshock()		
		if enabled
		 and ni.members[1].hp > 75
		 and ni.player.power() > 75
		 and not flameshock
		 and ni.spell.available(49233)
		 and ni.spell.valid("target", 49233, true, true) then
			ni.spell.cast(49233, "target")
			return true
		end
	end,
-----------------------------------
	["Control (Member)"] = function()
		local _, enabled = GetSetting("control")
		if enabled
		 and ni.spell.available(51514) then
		  for i = 1, #ni.members do
		   local ally = ni.members[i].unit
		    if data.ControlMember(ally)
			and not data.UnderControlMember(ally)
			and ni.spell.valid(ally, 51514, false, true, true) then
				ni.spell.cast(51514, ally)
				return true
				end
			end
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Restoration Shaman by DarhangeR for 3.3.5a", 
		 "Welcome to Restoration Shaman Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For enable priority healing Main Tank put tank name to Tank Overrides and press Enable Main.\n-For enable Chain of Heal Spam  configure AoE Toggle key.")		
		popup_shown = true;
		end 
	end,
}

	ni.bootstrap.profile("Restoration_DarhangeR", queue, abilities, OnLoad, OnUnLoad);
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
    ni.bootstrap.profile("Restoration_DarhangeR", queue, abilities);
end