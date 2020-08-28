local data = ni.utils.require("DarhangeR");
if data then
local ores = { 2770, 2771, 2772, 3858, 10620, 23424, 23425, 36909, 36912, 36910 };
local herbs = { 2447, 765, 2449, 785, 2452, 2450, 3820, 2453, 3369, 3355, 3356, 3357, 3818, 3358, 3819, 8831, 8836, 8838, 8845, 8839, 8846, 13464, 13463, 13465, 13466, 13467, 22789, 22785, 22787, 22790, 22793, 22792, 22791, 37921, 36907, 36904, 36901, 36903, 36906, 36905 };
local MultiQueue = {
	"Anti-AFK",
	"Universal pause",
	"Lookat",	
	"Auto-Loot",
	"Skinning",	
	"Prospecting (All)",
	"Prospecting (Specific ore)",	
	"Milling (All)",
	"Milling (Specific herb)",
};
local FishQueue = {
	"Anti-AFK",
	"Fishing pause",	
	"Action Check",
	"Combat Check",
	"Lure Apply",
	"Fishing",
};
local enables = {
	Debug = false,
	AntiAFK = true,	
	LookAt = false,	
	AutoLoot = true,	
	prospAll = false,
	prospSpec = false,
	millAll = false,
	milSpec = false,
	AutoSkin = false,
	FishBot = false,
	lure = false,
	weapon_swap = false,
	pole_check = false,
}
local values = {
	lure = 6532,
}
local inputs = {
	SpecOre = "",
	SpecHerb = "",
	pole = "6256",
	main = "",
	off = "",
	bobber = "Fishing Bobber",
	pool = "School"
}
local menus = {
	full_bags = "AFK",
}
local function GUICallback(key, item_type, value)
	if item_type == "enabled" then
		enables[key] = value;
	elseif item_type == "value" then
		values[key] = value;
	elseif item_type == "input" then
		inputs[key] = value;
	elseif item_type == "menu" then
		menus[key] = value;
	end
end
local items = {
	settingsfile = "GnomTool.xml",
	callback = GUICallback,
	{ type = "title", text = "Gnomish Multitool Profile by |cff00CED1DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "Main Settings" },
	{ type = "separator" },
	{ 
		type = "entry",
		text = "Anti AFK",
		enabled = enables["AntiAFK"],
		tooltip = "Prevent player to go AFK",
		value = values["AntiAFK"],
		width = 50,
		key = "AntiAFK",
	},	
	{ 
		type = "entry",
		text = "Lookat Target (TEST Function)",
		enabled = enables["LookAt"],
		tooltip = "Lookat on your target when you in combat. Function on test.",
		value = values["LookAt"],
		width = 50,
		key = "LookAt",
	},	
	{ 
		type = "entry",
		text = "Auto-Loot",
		enabled = enables["AutoLoot"],
		tooltip = "Auto-loot (Mobs only!)",
		value = values["AutoLoot"],
		width = 50,
		key = "AutoLoot",
	},	
	{ 
		type = "entry",
		text = "|cffFF0303Debug Printing",
		enabled = enables["Debug"],
		tooltip = "Enable for debug if you have problems",
		value = values["Debug"],
		width = 50,
		key = "Debug",
	},
	{ type = "separator" },	
	{ type = "page", number = 1, text = "|cfffffb0fJewelcrafting" },
	{ type = "separator" },	
	{ 
		type = "entry",
		text = "Prospecting (Auto)",
		enabled = enables["prospAll"],
		tooltip = "Prospecting all suitable ore in inventory",
		value = values["prospAll"],
		width = 50,
		key = "prospAll",
	},
	{ 
		type = "entry",
		text = "Prospecting Specific Ores",
		enabled = enables["prospSpec"],
		tooltip = "Prospecting specific ore in inventory. Need enter item ID bellow",
		value = values["prospSpec"],
		width = 50,
		key = "prospSpec",
	},
	{ type = "title", text = "Prospecting Ore ID" },
	{
		type = "input",
		value = inputs["SpecOre"],
		widht = 100,
		height = 15,
		key = "SpecOre"
	},
	{ type = "page", number = 2, text = "|cffffbf73Inscription" },
	{ type = "separator" },	
	{ 
		type = "entry",
		text = "Milling (Auto)",
		enabled = enables["millAll"],
		tooltip = "Milling all suitable herbs in inventory",
		value = values["millAll"],
		width = 50,
		key = "millAll",
	},
	{ 
		type = "entry",
		text = "Milling Specific Herb",
		enabled = enables["milSpec"],
		tooltip = "Milling specific herb in inventory. Need enter item ID bellow",
		value = values["milSpec"],
		width = 50,
		key = "milSpec",
	},
	{ type = "title", text = "Milling Herb ID" },
	{
		type = "input",
		value = inputs["SpecHerb"],
		widht = 100,
		height = 15,
		key = "SpecHerb"
	},
	{ type = "page", number = 3, text = "|cff919191Skinning" },
	{ type = "separator" },		
	{ 
		type = "entry",
		text = "Skinning (Auto)",
		enabled = enables["AutoSkin"],
		tooltip = "Auto use Skinning on target.",
		value = values["AutoSkin"],
		width = 50,
		key = "AutoSkin",
	},
	{ type = "page", number = 4, text = "Fishing" },
	{ type = "separator" },
	{ 
		type = "entry",
		text = "Activate Fishing",
		enabled = enables["FishBot"],
		tooltip = "Activate Fishing Bot. Other function will be deactivated exept Anti-AFK",
		value = values["FishBot"],
		width = 50,
		key = "FishBot",
	},	
	{ 
		type = "entry",
		text = "Auto Lure",
		enabled = enables["lure"],
		tooltip = "Enable/Disable to automatically use the lure id specified",
		value = values["lure"],
		width = 50,
		key = "lure",
	},
	{ 
		type = "entry", 
		text = "Auto Swap Weapons for Combat",
		enabled = enables["weapon_swap"],
		tooltip = "Enable/Disable this for the profile to swap weapons to the id's you specifiy below",
		key = "weapon_swap"
	},
	{ type = "title", text = "Fishing Pool/School Name" },
	{
		type = "input",
		value = inputs["pool"],
		width = 140,
		height = 15,
		key = "pool"
	},
	{ type = "title", text = "Fishing Bobber Name" },
	{
		type = "input",
		value = inputs["bobber"],
		width = 140,
		height = 15,
		key = "bobber"
	},
	{
		type = "entry",
		text = "Check if pole equipped",
		tooltip = "This is for checking if you have the pole equipped before trying to cast the fishing spell",
		enabled = enables["pole_check"],
		key = "pole_check"
	},
	{ type = "title", text = "Fishing Pole ID" },
	{
		type = "input",
		value = inputs["pole"],
		widht = 100,
		height = 15,
		key = "pole"
	},
	{ type = "title", text = "Main Hand ID" },
	{
		type = "input",
		value = inputs["main"],
		widht = 100,
		height = 15,
		key = "main"
	},
	{ type = "title", text = "Off Hand ID" },
	{
		type = "input",
		value = inputs["off"],
		widht = 100,
		height = 15,
		key = "off"
	},
	{ type = "title", text = "What to do on full bags?" },
	{
		type = "dropdown",
		menu = {
			{ selected = (menus["full_bags"] == "AFK"), value = "AFK" },
			{ selected = (menus["full_bags"] == "Hearthstone"), value = "Hearthstone" },
			{ selected = (menus["full_bags"] == "Logout"), value = "Logout" },
		},
		key = "full_bags",
	},
}

local function OnLoad()
	ni.GUI.AddFrame("Gnomish Multitool Profile", items);
end
local function OnUnload()
	ni.GUI.DestroyFrame("Gnomish Multitool Profile");
end
	-- Stuff for fishing
local function FullBags()
	local fullbags = 0;
	for i = 0, 4 do
		if GetContainerNumFreeSlots(i) == 0 then
			fullbags = fullbags + 1
		end
	end
	return fullbags == 5
end
	-- DO NOT TOUCH!
local offset;
if ni.vars.build == 40300 then
	offset = 0xD4;
elseif ni.vars.build > 40300 then
	offset = 0xCC;
else
	offset = 0xBC;
end
	-- Spells localized -- 
local prospecting = GetSpellInfo(31252);
local milling = GetSpellInfo(51005);
local skinning = GetSpellInfo(8613);
local Fishing = GetSpellInfo(7620);
local LastReset = 0;
local LastInteract = 0;
local LastLoot = 0;
local functionsent = 0;
local lure_applied = 0;
local abilities = {
-----------------------------------
	["Anti-AFK"] = function()
		if enables["AntiAFK"]
		 and GetTime() - LastReset > 30 then
			ni.utils.resetlasthardwareaction();
			LastReset = GetTime();
		end
	end,
-----------------------------------
	["Universal pause"] = function()
		if data.UniPause() then
			return true
		end
		ni.vars.debug = enables["Debug"]
	end,
-----------------------------------
	["Fishing pause"] = function()
		if IsMounted()
		 or UnitInVehicle("player")
		 or UnitIsDeadOrGhost("player")
		 or UnitCastingInfo("player")
		 or UnitAffectingCombat("player")
		 or ni.player.ismoving() then
			return true;
		end
		ni.vars.debug = enables["Debug"]
	end,
-----------------------------------
	["Lookat"] = function()
		local _, class = UnitClass("player")
		if (class == "DRUID"
		 and ni.player.aura(24858))
		 or class == "HUNTER"
		 or class == "MAGE"
		 or class == "PRIEST"
		 or class == "SHAMAN"
		 or class == "WARLOCK" then
		  if enables["LookAt"]
		   and UnitAffectingCombat("player") then
		    if not ni.unit.exists("playerpet") then
				TargetUnit("targetplayer")
				ni.player.lookat("target")
			end
		    if ni.unit.exists("playerpet") then
				TargetUnit("playerpettarget")
				ni.player.lookat("target")
				end
			end
		end
	end,
-----------------------------------
    ["Auto-Loot"] = function()
        if UnitAffectingCombat("player") then
            return false;
        end
        if ni.unit.islooting("player") 
		 and GetNumLootItems() > 0 then
          local slots = GetNumLootItems();
           for i = slots, 1, -1 do
            local _, _, _, _, locked, questItem = GetLootSlotInfo(i);
             if not locked then
                    LootSlot(i);
                    ConfirmLootSlot(i);
                end
            end
        end
        for k, v in pairs(ni.objects) do
         if enables["AutoLoot"]
		  and type(k) == "string" 
		  and type(v) == "table" then
           if ni.unit.islootable(k)
            and v:distance() < 2.2
			and GetTime() - LastLoot > 0.5
            and not ni.unit.islooting("player") then
                    ni.player.interact(k);
					LastLoot = GetTime();
                    return true;
                end
            end 
        end
    end,
-----------------------------------
    ["Skinning"] = function()
        if UnitAffectingCombat("player") then
            return false;
        end
		for k, v in pairs(ni.objects) do
         if enables["AutoSkin"]
		  and ni.spell.available(skinning)
		  and type(k) == "string" 
		  and type(v) == "table" then
           if ni.unit.isskinnable(k)
            and v:distance() < 4.2
			and GetTime() - LastInteract > 2.3
            and not ni.unit.islooting("player") then
                    ni.player.interact(k);
					LastInteract = GetTime();
                    return true;
                end
            end 
        end
	end,
-----------------------------------
	["Prospecting (All)"] = function()
		if enables["prospAll"]
		 and ni.spell.available(prospecting) then
		  for i = 1, #ores do
		   if GetItemCount(ores[i], false, false) > 4 then
				ni.spell.delaycast(prospecting, nil, 2);
				ni.player.useitem(ores[i]);
				return true;
				end
			end
		end
	end,
-----------------------------------
	["Prospecting (Specific ore)"] = function()
		local SpecOre = tonumber(inputs["SpecOre"]);		
		if enables["prospSpec"]
		 and ni.spell.available(prospecting)
		 and GetItemCount(SpecOre, false, false) > 4 then
				ni.spell.delaycast(prospecting, nil, 2);
				ni.player.useitem(SpecOre);
			return true;
		end
	end,
-----------------------------------
	["Milling (All)"] = function()
		if enables["millAll"]
		 and ni.spell.available(milling) then
		  for i = 1, #herbs do
		   if GetItemCount(herbs[i], false, false) > 4 then
				ni.spell.delaycast(milling, nil, 1.5);				
				ni.player.useitem(herbs[i]);
				return true;
				end
			end
		end
	end,
-----------------------------------
	["Milling (Specific herb)"] = function()
		local SpecHerb = tonumber(inputs["SpecHerb"]);		
		if enables["milSpec"]
		 and ni.spell.available(milling)
		 and GetItemCount(SpecHerb, false, false) > 4 then
				ni.spell.delaycast(milling, nil, 1.5);	
				ni.player.useitem(SpecHerb);
			return true;
		end
	end,
-----------------------------------
	["Action Check"] = function()
		if FullBags() then
			local action = menus["full_bags"];
			if action == "AFK" then
				ni.frames.floatingtext:message("Bags are full, time to AFK!");
				ni.vars.profiles.enabled = false;
			elseif action == "Hearthstone" then
				if not UnitAffectingCombat("player")
				 and not UnitCastingInfo("player")
				 and not UnitChannelInfo("player") then
					ni.player.useitem(6948);
					ni.frames.floatingtext:message("Bags are full, time to go home!");
					ni.vars.profiles.enabled = false;
				end
			elseif action == "Logout" then
				if not UnitAffectingCombat("player") then
					ni.player.runtext("/logout");
					ni.frames.floatingtext:message("Bags are full, time to logout!");
					ni.vars.profiles.enabled = false;
				end
			end
		end
	end,
-----------------------------------
	["Combat Check"] = function()
		if enables["weapon_swap"] and not UnitIsDeadOrGhost("player") then
			local pole = tonumber(inputs["pole"]);
			local mh = tonumber(inputs["main"]);
			local oh = tonumber(inputs["off"]);
			if pole and mh then
				if UnitAffectingCombat("player") then
					if IsEquippedItem(pole) then
						EquipItemByName(mh);
						if oh then
							EquipItemByName(oh);
						end
						return true;
					end
				else
					if not IsEquippedItem(pole) then
						EquipItemByName(pole);
						return true;
					end
				end
			end
		end
	end,
-----------------------------------
	["Lure Apply"] = function()
		local pole = tonumber(inputs["pole"]);
		if enables["lure"] and pole then
			if GetTime() - lure_applied < 4 then
				return false;
			end
			local lure_enchant = GetWeaponEnchantInfo();
			if IsEquippedItem(pole)
			 and not lure_enchant
			 and not UnitAffectingCombat("player")
			 and ni.player.hasitem(values["lure"]) then
				lure_applied = GetTime();
				ni.spell.stopcasting();
				ni.spell.stopchanneling();
				ni.player.useitem(values["lure"]);
				ni.player.useinventoryitem(16);
				ni.player.runtext("/click StaticPopup1Button1");
				return true;
			end
		end
	end,
-----------------------------------
	["Fishing"] = function()
		if enables["pole_check"] then
			local pole = tonumber(inputs["pole"]);
			if not IsEquippedItem(pole) then
				return;
			end
		end
		if ni.player.islooting() then
			return
		end
		if UnitChannelInfo("player") then
			if GetTime() - functionsent > 1 then
				local playerguid = UnitGUID("player");
				for k, v in pairs(ni.objects) do
					if type(k) ~= "function" and (type(k) == "string" and type(v) == "table") then
						if v.name == inputs["bobber"] then
							local creator = v:creator();
							if creator == playerguid then
								local ptr = ni.memory.objectpointer(v.guid);
								if ptr then
									local result = ni.memory.read("byte", ptr, offset);
									if result == 1 then
										ni.player.interact(v.guid);
										functionsent = GetTime();
										return true;
									end
								end
							end 
						end
					end
				end
			end
		else
			for k, v in pairs(ni.objects) do
				if type(v) ~= "function" 
				 and v.name ~= nil 
				 and string.match(v.name, inputs["pool"]) then
					local dist = ni.player.distance(k);
					if dist ~= nil and dist < 20 then
						ni.player.lookat(k);
						break;
					end
				end
			end
			ni.spell.delaycast(Fishing, nil, 1.5);
			ni.utils.resetlasthardwareaction();
		end
	end,	
}
local function mainqueue()
	if enables["FishBot"] then
	  return FishQueue;
	end
	  return MultiQueue;
end
	ni.bootstrap.profile("Gnomish Multitool Profile", mainqueue, abilities, OnLoad, OnUnload);
else
    local queue = {
        "Error",
    }
    local abilities = {
        ["Error"] = function()
            ni.vars.profiles.enabled = false;
            if data == nil then
              ni.frames.floatingtext:message("Data file is missing or corrupted!")
            end
        end,
    }
    ni.bootstrap.profile("Gnomish Multitool Profile", queue, abilities);
end