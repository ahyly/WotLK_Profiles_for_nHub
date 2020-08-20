-- Blacklist table for healers --
local dontdispel = { 60814, 69674, 68786, 34916, 34917, 34919, 48159, 48160, 30404, 30405, 31117, 34438, 35183, 43522, 47841, 47843, 65812, 68154, 68155, 68156, 44461, 55359, 55360, 55361, 55362, 61429, 30108, 34914, 74562, 74792, 70867, 70338, 70405 };
for k, v in pairs(dontdispel) do
    ni.healing.debufftoblacklist(v);
end
-- Shared Stuff for all --
local cbuff = { 30940, 60158, 59301, 642, 31224, 23920, 33786, 19263, 21892, 40733, 45438, 69051, 69056, 20223 };
local mbuff = { 30940, 59301, 45438, 33786, 21892, 40733, 69051 };
local tbuff = { 30940, 59301, 45438, 33786, 21892, 40733, 19263, 1022, 69051 };
local targetdebuff = { 33786, 18647, 10955, 10326, 14327 };
local forsdebuff = { 6215, 8122, 5484, 2637, 5246, 6358, 605, 22686, 74384, 49106, 35280, 36866 };
local pbuff = { 430, 433, 25990, 58984, 11392, 32612, 47585 };
local pdebuff = { 34661, 71289, 33684, 52509, 51750, 35856, 70157, 33173, 33652, 69645 };
local _, class = UnitClass("player");
local control = { 71289, 605 };
local undercontrol = { 33786, 64044, 10890, 12826, 28271, 61025, 61305, 61721, 61780, 20066, 10308, 14311, 47860, 6215, 17928, 51514 };
-- DK Anti-Magic Shell --
local ams = { };
-- Druid Stuff -- 
local flyform = { 33357, 1066, 33943, 40120 };
-- Hunter Stuff --
local creaturetypes = {
  [1] = 1494,
  [2] = 19879,
  [3] = 19878,
  [4] = 19880,
  [5] = 19882,
  [6] = 19884,
  [7] = 19883   
}
-- Mage Fire / Frost Protection -- 
local firedots = { 49233, 42833, 42891, 55360, 22959 };
local frostdots = { 49236, 12494 };
-- Spellsteal 
local stealable = { 57761, 57531, 12043, 44401, 54428, 43242, 31884, 2825, 32182, 1719, 17, 33763, 6940, 67106, 67107, 67108, 66228, 67009, 48068 };
-- Paladin Freedom --
local freedomdebuff = { 60814, 42842, 45524, 1715, 3408, 59638, 20164, 25809, 31589, 51585, 50040, 50041, 31124, 122, 44614, 1604, 339, 45334, 58179, 61391, 19306, 19185, 35101, 5116, 2974, 61394, 54644, 50245, 50271, 54706, 4167, 33395, 55080, 11113, 6136, 120, 116, 44614, 31589, 20170, 31125, 3409, 26679, 64695, 63685, 8056, 8034, 18118, 18223, 63311, 23694, 1715, 12323, 39965, 55536, 13099, 29703, 32859, 32065 };
-- Shaman Purge -- 
local purgebuff = { 38210, 48068, 48066, 61301, 43039, 43020, 48441, 11841, 43046, 18100 };
-- Warlock Shadow Ward --
local shadowdots = { 48125, 48160, 48300, 47864, 47813, 47857, 47855 };
-- Warrior Berserker --
local bersrage = { 6215, 8122, 5484, 2637, 5246, 6358 };
-- Stuff for data.ishealer(t)
local checkheal = { 33891, 20216, 31842, 31834, 55166, 53390, 59891, 63725, 63734, 33151, 64911, 70806, 70757 };
-- Shared stuff for Druid/Warrior --
local bleedUp = { 48564, 48566, 46856 };

local data = { };
data.LastDispel = 0
data.LastInterrupt = 0
	
-- Check Start Fight --
data.CDsaver = function(t)
	if ni.vars.combat.time ~= 0 
	 and GetTime() - ni.vars.combat.time > 7
	 and ni.unit.hp(t) >= 5 then
		return true
	end
	return false
end
				
-- Check Start Fight with TTD --
data.CDsaverTTD = function(t)
	if ni.vars.combat.time ~= 0 
	 and GetTime() - ni.vars.combat.time > 5 
	 and ni.unit.ttd(t) > 35
	 and ni.unit.hp(t) >= 5 then
		return true
	end
	return false
end
				
data.ControlMember = function(t)
	for _, v in ipairs(control) do
		if ni.unit.debuff(t, v) then 
			return true
		end
	end
	return false
end

data.UnderControlMember = function(t)
for _, v in ipairs(undercontrol) do
	if ni.unit.debuff(t, v) then 
		 return true
	end
end
		 return false
end

-- Part of for data.ishealer(t)
data.ishealer = function(t)
for _, v in ipairs(checkheal) do
	if ni.unit.buff(t, v) then 
		 return true
	end
end
		 return false
end
-- Vars for Universal Pause --
data.PlayerBuffs = function(t)
for _, v in ipairs(pbuff) do
	if ni.unit.buff(t, v) then 
		 return true
	end
end
		 return false
end
-- Universal Pause --
data.UniPause = function()
if IsMounted()
 or UnitInVehicle("player")
 or UnitIsDeadOrGhost("target") 
 or UnitIsDeadOrGhost("player")
 or UnitChannelInfo("player") ~= nil
 or UnitCastingInfo("player") ~= nil
 or ni.vars.combat.casting == true
 or data.PlayerBuffs("player")
 or (not UnitAffectingCombat("player")
 and ni.vars.followEnabled) then
		 return true
	end
		 return false
end
-- Vars for Combat Pause --
data.targetDebuffs = function(t)
for _, v in ipairs(targetdebuff) do
	if ni.unit.debuff(t, v) then 
		 return true
	end
end
		 return false
end
data.casterStop = function(t)
for _, v in ipairs(cbuff) do
	if (ni.unit.buff(t, v) 
	or data.targetDebuffs(t)) then 
		 return true
	end
end
		 return false
end
data.meleeStop = function(t)
for _, v in ipairs(mbuff) do
	if (ni.unit.buff(t, v) 
	or data.targetDebuffs(t)) then 
		 return true
	end
end
		 return false
end
data.tankStop = function(t)
for _, v in ipairs(tbuff) do
	if (ni.unit.buff(t, v) 
	or data.targetDebuffs(t)) then 
		 return true
	end
end
		 return false
end
data.PlayerDebuffs = function(t)
for _, v in ipairs(pdebuff) do
		if (ni.unit.debuff(t, v) 
		or ni.player.debuffstacks(69766) == 5
		or (ni.unit.debuff("player", 305131, "EXACT") 
		and ni.unit.debuffremaining("player", 305131, "EXACT") <= 3)) then 
		 return true
	end
end
		 return false
end

-- Will of the Forsaken --
data.forsaken = function(t)
for _, v in ipairs(forsdebuff) do
		if ni.unit.debuff(t, v) then 
		 return true
	end
end
	return false
end

-- Check Instance / Raid --
data.youInInstance = function()
if IsInInstance()
		and select(2, GetInstanceInfo()) == "party" then
		 return true
	end
		 return false
end
data.youInRaid = function(t)
if IsInInstance()
		and select(2, GetInstanceInfo()) == "raid" then
		 return true
	end
		return false
end
		
-- Pet Follow / Attack Function -- 
data.petFollow = function()
	local pet = ni.objects["pet"]
	if not pet:exists() then
		return
	end
	local oldPetDistance = petDistance;
	petDistance = pet:distance("player")
	local distanceThreshold = 1
	if not oldPetDistance 
	 or petDistance - oldPetDistance > distanceThreshold then
		ni.player.runtext("/petfollow");
	end
end

data.petAttack = function()
	local pet = ni.objects["pet"]
	if not pet:exists() then
		return
	end
	if not pet:combat() then
		ni.player.runtext("/petattack")
		petDistance = nil
	end

	if pet:combat() then
		ni.player.runtext("/petattack")
		petDistance = nil
	end
end
-- Check Item Set --
data.checkforSet = function(t, pieces)
	local count = 0
	for _, v in ipairs(t) do
		if IsEquippedItem(v) then
			count = count + 1
		end
	end
	if count >= pieces then
		return true
	else
		return false
	end
end
-- Sirus Stuff --
data.SirusCheck = function()
	if (GetRealmName() == "Frostmourne x1 - 3.3.5+"
	 or GetRealmName() == "Scourge x2 - 3.3.5a+"
	 or GetRealmName() == "Neltharion x3 - 3.3.5a+"
	 or GetRealmName() == "Sirus x10 - 3.3.5a+") then
		return true
	end
		return false
end
local classlower = string.lower(class);
if classlower == "deathknight" then
	classlower = "dk";
end
data[classlower] = { };
if classlower == "dk" then
	data[classlower].LastIcy = 0;
	data[classlower].icy = function()
		return ni.unit.debuffremaining("target", 55095, "player")
	end;
	data[classlower].plague = function() 
		return ni.unit.debuffremaining("target", 55078, "player")
	end;
		-- Sirus Custom T5 --
	data[classlower].itemsetT5DPS = { 
	81241, 80867, 80861, 80927, 82812, 103491, 103492, 103493, 103494, 103495 
	};
	data[classlower].itemsetT4tank = { 
	63462, 55792, 56291, 56323, 56435, 100494, 100488, 100491, 100492, 100493 
	}
	data[classlower].itemsetT4DPS = { 
	55848, 55207, 55254, 55784, 56104, 100489, 100485, 100486, 100487, 100490
	}
elseif classlower == "druid" then
	data[classlower].LastShout = 0;
	data[classlower].LastRegrowth = 0;
	data[classlower].LastNourish = 0;	
	data[classlower].mFaerieFire = function() 
		return ni.unit.debuff("target", 770) 
	end;
	data[classlower].fFaerieFire = function() 
		return ni.unit.debuff("target", 16857) 
	end
	data[classlower].iSwarm = function()
		return select(7, ni.unit.debuff("target", 48468, "player")) 
	end
	data[classlower].mFire = function() 
		return select(7, ni.unit.debuff("target", 48463, "player"))
	end
	data[classlower].lunar = function() 
		return select(7, ni.unit.buff("player", 48517)) 
	end
	data[classlower].solar = function() 
		return select(7, ni.unit.buff("player", 48518)) 
	end
	data[classlower].berserk = function() 
		return ni.unit.buff("player", 50334)
	end
	data[classlower].lacerate = function() 
		return ni.unit.debuffremaining("target", 48568, "player")
	end
	data[classlower].rip = function() 
		return ni.unit.debuffremaining("target", 49800, "player")
	end
	data[classlower].rake = function() 
		return ni.unit.debuffremaining("target", 48574, "player")
	end
	data[classlower].tiger = function() 
		return ni.unit.buff("player", 50213) 
	end
	data[classlower].savage = function() 
		return ni.unit.buffremaining("player", 52610) 
	end
	-- Bleed  Buff --
	data[classlower].BleedBuff = function(t)
		for _, v in ipairs(bleedUp) do
		 if ni.unit.debuff(t, v) then 
		     return true
			end
		end
		     return false
	end
	data[classlower].DruidStuff = function(t)
	for _, v in ipairs(flyform) do
		if ni.unit.buff(t, v) then 
		     return true
		end
	end
		     return false
	end
elseif classlower == "hunter" then
	data[classlower].LastMD = 0;
	data[classlower].LastScat = 0;
	data[classlower].LastTrack = 0;
	data[classlower].LastScare = 0;
	data[classlower].serpstring = function() 
		return ni.unit.debuffremaining("target", 49001, "player")
	end
	data[classlower].viperstring = function() 
		return ni.unit.debuffremaining("target", 3034, "player")
	end
	data[classlower].scorpstring = function() 
		return ni.unit.debuffremaining("target", 3043, "player")
	end
	data[classlower].exploshot = function() 
		return ni.unit.debuff("target", 60053, "player")
	end
	data[classlower].setTracking = function() 
	local creaturetype = ni.unit.creaturetype("target")
	local spellid = creaturetypes[creaturetype]
    if spellid ~= nil 
	 and UnitAffectingCombat("player") 
	 and ni.unit.exists("target") 
	 and ni.spell.isinstant(spellid) 
	 and ni.spell.available(spellid) 
	 and GetTime() - data.hunter.LastTrack > 3 then
			data.hunter.LastTrack = GetTime()
			ni.spell.cast(spellid)
		end
	end
elseif classlower == "mage" then
	data[classlower].LastScorch = 0;
	data[classlower].LBomb = function() 
		return ni.unit.debuff("target", 55360, "player") 
	end
	data[classlower].fnova = function() 
		return ni.unit.debuff("target", 42917, "player") 
	end
	data[classlower].fbite = function() 
		return ni.unit.debuff("target", 12494, "player") 
	end
	data[classlower].freeze = function() 
		return ni.unit.debuff("target", 33395, "player") 
	end
	data[classlower].FoF = function() 
		return ni.player.buff(44545) 
	end
	-- Sirus Custom T4 --
	data[classlower].itemsetT4 = {
		29076, 29077, 29078, 29079, 29080, 100460, 100461, 100462, 100463, 100464 
	};	
	-- Mages Wards --
	data[classlower].FireWard = function()
		for _, v in ipairs(firedots) do
		 if ni.player.debuff(v) then 
		     return true
			end
		end
		     return false
	end	
	data[classlower].FrostWard = function()
		for _, v in ipairs(frostdots) do
		 if ni.player.debuff(v) then 
		     return true
			end
		end
		     return false
	end
	data[classlower].isStealable = function(t)
	for i, v in ipairs(stealable) do
		local _,_,_,_,_,_,_,_,StealableSpell = ni.unit.buff(t, v)
		 if StealableSpell then
		     return true
		end
	end
		     return false
	end
elseif classlower == "paladin" then
	data[classlower].LastSeal = 0;
	data[classlower].LastTrack = 0;
	data[classlower].LastTurn = 0;
	data[classlower].LastHoly = 0;	
	data[classlower].forb = function() 
		return ni.player.debuff(25771) 
	end
	data[classlower].aow = function() 
		return ni.player.buff(59578) 
	end
	data[classlower].itemsetT10 = { 
		51270, 51271, 51272, 51273, 51274, 51165, 51166, 51167, 51168, 51169, 50865, 50866, 50867, 50868, 50869
	};
	-- Sirus Custom T5 (Healer)--
	data[classlower].itemsetT5Heal = { 
		30134, 30135, 30136, 30137, 30138, 103426, 103427, 103428, 103429, 103430
	};	
	data[classlower].HandActive = function(t)
		if ni.unit.buff(t, 1044)
		 or ni.unit.buff(t, 1022)
		 or ni.unit.buff(t, 6940)
		 or ni.unit.buff(t, 1038) then
		     return true
		end
		     return false
	end
	data[classlower].FreedomUse = function(t)
	for _, v in ipairs(freedomdebuff) do
		if ni.unit.debuff(t, v) then 
		     return true
		end
	end
		     return false
	end	
elseif classlower == "priest" then
	data[classlower].LastVamp = 0;
	data[classlower].LastSWP = 0;
	data[classlower].LastPlague = 0;
	data[classlower].LastShackle = 0;
	data[classlower].LastGreater = 0;	
	data[classlower].vamp = function()
		return ni.unit.debuff("target", 48160, "player") 
	end
	data[classlower].SWP = function() 
		return ni.unit.debuff("target", 48125, "player") 
	end
	data[classlower].dplague = function() 
		return ni.unit.debuff("target", 48300, "player")
	end
	-- Sirus Custom T4 --
	data[classlower].itemsetT4DPS = {
		29056, 29057, 29058, 29059, 29060, 100440, 100441, 100442, 100443, 100444 
	};		
		-- Crimson Acolyte's Regalia --
	data[classlower].itemsetT10 = {
		51255, 51256, 51257, 51258, 51259, 51180, 51181, 51182, 51183, 51184, 50391, 50392, 50393, 50394, 50396
	};
elseif classlower == "rogue" then
	data[classlower].SnD = function() 
		return ni.unit.buffremaining("player", 6774)
	end
	data[classlower].Hunger = function() 
		return ni.unit.buffremaining("player", 63848)
	end
	data[classlower].envenom = function() 
		return ni.unit.buff("player", 57993) 
	end
	data[classlower].Rup = function() 
		return ni.unit.debuffremaining("target", 48672, "player") 
	end
	data[classlower].OGar = function() 
		return ni.unit.debuff("target", 48676) 
	end	
elseif classlower == "shaman" then
	data[classlower].LastPurge = 0;
	data[classlower].LastWave = 0;	
	data[classlower].flameshock = function() 
		return ni.unit.debuff("target", 49233, "player") 
	end
	-- Shaman Enchancment T10 --
	data[classlower].itemsetT10Enc = {
		50830, 50831, 50832, 50833, 50834, 51195, 51196, 51197, 51198, 51199, 51240, 51241, 51242, 51243, 51244
	};
	data[classlower].canPurge = function(t)
	for i, v in ipairs(purgebuff) do
		local name, icon, _, _, _, _, _, PurgebleSpell = ni.unit.buff(t, v)
		 if PurgebleSpell then
		     return true
		end
	end
		     return false
	end
elseif classlower == "warlock" then
	data[classlower].LastSummon = 0;
	data[classlower].LastCorrupt = 0;
	data[classlower].LastCurse = 0;
	data[classlower].LastShadowbolt = 0;
	data[classlower].Lastimmolate = 0;
	data[classlower].LastUA = 0;
	data[classlower].LastHaunt = 0;
	data[classlower].LastSeed = 0;
	data[classlower].LastBanish = 0;	
	data[classlower].CotE = function()
		return ni.unit.debuff("target", 47865)
	end
	data[classlower].elem = function()
		return ni.unit.debuff("target", 47865, "player")
	end
	data[classlower].doom = function()
		return ni.unit.debuff("target", 47867, "player")
	end
	data[classlower].agony = function()
		return ni.unit.debuff("target", 47864, "player")
	end
	data[classlower].corruption = function()
		return ni.unit.debuff("target", 47813, "player")
	end
	data[classlower].seed = function()
		return ni.unit.debuff("target", 47836, "player")
	end
	data[classlower].haunt = function()
		return ni.unit.debuff("target", 59164, "player")
	end
	data[classlower].ua = function()
		return ni.unit.debuff("target", 47843, "player")
	end
	data[classlower].immolate = function()
		return ni.unit.debuff("target", 47811, "player")
	end
	data[classlower].eplag = function() 
		return ni.unit.debuff("target", 51735) 
	end
	data[classlower].earmoon = function()
		return ni.unit.debuff("target", 60433) 
	end
	-- Sirus Custom T4 --
	data[classlower].itemsetT4 = {
		28963, 28964, 28966, 28967, 28968, 100400, 100401, 100402, 100403, 100404
	};
	-- Shadow Ward --
	data[classlower].ShadowWard = function()
		for _, v in ipairs(shadowdots) do
		 if ni.player.debuff(v) then 
		     return true
			end
		end
		     return false
	end
elseif classlower == "warrior" then
	data[classlower].LastShout = 0;
	data[classlower].rend = function() 
		return ni.unit.debuffremaining("target", 47465, "player")
	end
	data[classlower].hams = function() 
		return ni.unit.debuffremaining("target", 1715, "player")
	end
	data[classlower].Berserk = function()
	for _, v in ipairs(bersrage) do
            if ni.player.debuff(v) then 
		     return true
		end
	end
		     return false
	end
end
                         
return data;