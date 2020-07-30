local dontdispel = { 69674, 68786, 34916, 34917, 34919, 48159, 48160, 30404, 30405, 31117, 34438, 35183, 43522, 47841, 47843, 65812, 68154, 68155, 68156, 44461, 55359, 55360, 55361, 55362, 61429, 30108, 34914, 74562, 74792, 70867, 70338, 70405 };
for k, v in pairs(dontdispel) do
    ni.healing.debufftoblacklist(v);
end
local cbuff = { 30940, 60158, 59301, 642, 31224, 23920, 33786, 19263, 21892, 40733, 45438, 69051, 69056, 20223 };
local mbuff = { 30940, 59301, 45438, 33786, 21892, 40733, 69051 };
local tbuff = { 30940, 59301, 45438, 33786, 21892, 40733, 19263, 1022, 69051 };
local targetdebuff = { 33786, 18647, 10955 };
local forsdebuff = { 6215, 8122, 5484, 2637, 5246, 6358, 605, 22686, 74384, 49106, 35280, 36866 };
local pbuff = { 430, 433, 25990, 58984, 11392, 32612 };
local pdebuff = { 52509, 51750, 35856, 70157, 305131, 33173 };
local shadowdots = { 48125, 48160, 48300, 47864, 47813, 47857, 47855 };
local firedots = { 49233, 42833, 42891, 55360, 22959 };
local frostdots = { 49236, 12494 };
local ams = { };
local bersrage = { 6215, 8122, 5484, 2637, 5246, 6358 };
local stealable = { 43242, 31884, 2825, 32182, 1719, 17, 33763, 6940, 67108, 67107, 66228, 67009, 48068 };
local freedomdebuff = { 45524, 1715, 3408, 59638, 20164, 25809, 31589, 51585, 50040, 50041, 31124, 122, 44614, 1604, 339, 45334, 58179, 61391, 19306, 19185, 35101, 5116, 2974, 61394, 54644, 50245, 50271, 54706, 4167, 33395, 55080, 11113, 6136, 120, 116, 44614, 31589, 20170, 31125, 3409, 26679, 64695, 63685, 8056, 8034, 18118, 18223, 63311, 23694, 1715, 12323, 39965, 55536, 13099, 29703, 32859, 32065 };
local flyform = { 33357, 1066, 33943, 40120 };
local checkheal = { 33891, 20216, 31842, 31834, 55166, 53390, 59891, 63725, 63734, 33151, 64911, 70806, 70757 };
local purgebuff = {48068, 48066, 61301, 43039, 43020, 48441, 11841, 43046, 18100 };
local _, class = UnitClass("player");

	-- Debuger -- 
local function changedebug(msg)
	if msg == "on" then
	 ni.vars.debug = true;
	elseif msg == "off" then
	 ni.vars.debug = false;
	 else
	 print("Only commands are on/off\nFor example:\n/dardebug on\n/dardebug off");
	end
end
SLASH_DARDEBUG1 = "/dardebug";
SlashCmdList["DARDEBUG"] = changedebug;

ni.data.darhanger = {
	LastDispel = 0, 
	LastInterrupt = 0,
	
		-- Check Start Fight --
	CDsaver = function(t)
	if ni.vars.combat.time ~= 0 
	 and GetTime() - ni.vars.combat.time > 7
	 and ni.unit.hp(t) >= 5 then
		     return true
		end
		     return false
	end,
				
		-- Check Start Fight with TTD --
	CDsaverTTD = function(t)
	if ni.vars.combat.time ~= 0 
	 and GetTime() - ni.vars.combat.time > 5 
	 and ni.unit.ttd(t) > 35
	 and ni.unit.hp(t) >= 5 then
		     return true
		end
		     return false
	end,
		
		-- Vars for Universal Pause --
	PlayerBuffs = function(t)
	for _, v in ipairs(pbuff) do
		if ni.unit.buff(t, v) then 
		     return true
		end
	end
		     return false
	end,

	isStealable = function(t)
	for i, v in ipairs(stealable) do
		local _,_,_,_,_,_,_,_,StealableSpell = ni.unit.buff(t, v)
		 if StealableSpell then
		     return true
		end
	end
		     return false
	end,

	canPurge = function(t)
	for i, v in ipairs(purgebuff) do
		local name, icon, _, _, _, _, _, PurgebleSpell = ni.unit.buff(t, v)
		 if PurgebleSpell then
		     return true
		end
	end
		     return false
	end,
	
	FreedomUse = function(t)
	for _, v in ipairs(freedomdebuff) do
		if ni.unit.debuff(t, v, "EXACT") then 
		     return true
		end
	end
		     return false
	end,
	
	DruidStuff = function(t)
	for _, v in ipairs(flyform) do
		if ni.unit.buff(t, v) then 
		     return true
		end
	end
		     return false
	end,
	
	ishealer = function(t)
	for _, v in ipairs(checkheal) do
		if ni.unit.buff(t, v) then 
		     return true
		end
	end
		     return false
	end,
	
		-- Universal Pause --
	UniPause = function()
	if IsMounted()
	 or UnitInVehicle("player")
	 or UnitIsDeadOrGhost("target") 
	 or UnitIsDeadOrGhost("player")
	 or UnitChannelInfo("player") ~= nil
	 or UnitCastingInfo("player") ~= nil
	 or ni.vars.combat.casting == true
	 or ni.data.darhanger.PlayerBuffs("player")
	 or (not UnitAffectingCombat("player")
	 and ni.vars.followEnabled) then
		     return true
		end
		     return false
	end,
	
		-- Vars for Combat Pause --
	targetDebuffs = function(t)
	for _, v in ipairs(targetdebuff) do
		if ni.unit.debuff(t, v) then 
		     return true
		end
	end
		     return false
	end,
	
	casterStop = function(t)
	for _, v in ipairs(cbuff) do
		if (ni.unit.buff(t, v) 
		or ni.data.darhanger.targetDebuffs("target")) then 
		     return true
		end
	end
		     return false
	end,
	
	meleeStop = function(t)
	for _, v in ipairs(mbuff) do
		if (ni.unit.buff(t, v) 
		or ni.data.darhanger.targetDebuffs("target")) then 
		     return true
		end
	end
		     return false
	end,
	
	tankStop = function(t)
	for _, v in ipairs(tbuff) do
		if (ni.unit.buff(t, v) 
		or ni.data.darhanger.targetDebuffs("target")) then 
		     return true
		end
	end
		     return false
	end,

	SindragosaCheck = function()
	local Instability, _, _, Instability_stacks = ni.player.debuff(69766)
            if Instability_stacks == 5 then
		     return true
		end
		     return false
	end,
	
	PlayerDebuffs = function(t)
	for _, v in ipairs(pdebuff) do
            if (ni.unit.debuff(t, v) 
            or ni.data.darhanger.SindragosaCheck()) then 
		     return true
		end
	end
		     return false
	end,
	
	Berserk = function(t)
	for _, v in ipairs(bersrage) do
            if ni.unit.debuff(t, v) then 
		     return true
		end
	end
		     return false
	end,
	
		-- Will of the Forsaken --
	forsaken = function(t)
	for _, v in ipairs(forsdebuff) do
            if ni.unit.debuff(t, v) then 
		     return true
		end
	end
		     return false
	end,
	
		-- Check Instance / Raid --
	youInInstance = function()
	if IsInInstance()
            and select(2, GetInstanceInfo()) == "party" then
		     return true
		end
		     return false
	end,

	youInRaid = function(t)
	if IsInInstance()
            and select(2, GetInstanceInfo()) == "raid" then
		     return true
		end
		    return false
	end,
			
		-- Pet Follow / Attack Function -- 
	petFollow = function()
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
	end,
	
	petAttack = function()
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
	end,
		-- Check Item Set --
	checkforSet = function(t, pieces)
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
}
local classlower = string.lower(class);
if classlower == "deathknight" then
	classlower = "dk";
end
ni.data.darhanger[classlower] = { };
if classlower == "dk" then
	ni.data.darhanger[classlower].LastIcy = 0;
	ni.data.darhanger[classlower].icy = function()
		return select(7, ni.unit.debuff("target", 55095, "player")) 
	end;
	ni.data.darhanger[classlower].plague = function() 
		return select(7, ni.unit.debuff("target", 55078, "player")) 
	end;
		-- Sirus Custom T5 --
	ni.data.darhanger[classlower].itemsetT5 = { 
	81241, 80867, 80861, 80927, 82812, 103491, 103492, 103493, 103494, 103495 
	};
	ni.data.darhanger[classlower].itemsetT4Tank = { 
	63462, 55792, 56291, 56323, 56435, 100494, 100488, 100491, 100492, 100493 
	}
elseif classlower == "druid" then
	ni.data.darhanger[classlower].LastShout = 0;
	ni.data.darhanger[classlower].lastRegrowth = 0;
	ni.data.darhanger[classlower].mFaerieFire = function() 
		return select(7, ni.unit.debuff("target", 770)) 
	end;
	ni.data.darhanger[classlower].fFaerieFire = function() 
		return select(7, ni.unit.debuff("target", 16857)) 
	end
	ni.data.darhanger[classlower].iSwarm = function()
		return select(7, ni.unit.debuff("target", 48468, "player")) 
	end
	ni.data.darhanger[classlower].mFire = function() 
		return select(7, ni.unit.debuff("target", 48463, "player")) 
	end
	ni.data.darhanger[classlower].lunar = function() 
		return select(7, ni.unit.buff("player", 48517)) 
	end
	ni.data.darhanger[classlower].solar = function() 
		return select(7, ni.unit.buff("player", 48518)) 
	end
	ni.data.darhanger[classlower].berserk = function() 
		return select(11, ni.unit.buff("player", 50334))
	end
	ni.data.darhanger[classlower].bmangle = function()
		return select(7, ni.unit.debuff("target", 48564))
	end
	ni.data.darhanger[classlower].lacerate = function() 
		return select(7, ni.unit.debuff("target", 48568, "player"))
	end
	ni.data.darhanger[classlower].mangle = function() 
		return select(7, ni.unit.debuff("target", 48566)) 
	end
	ni.data.darhanger[classlower].rip = function() 
		return select(7, ni.unit.debuff("target", 49800, "player")) 
	end
	ni.data.darhanger[classlower].rake = function() 
		return select(7, ni.unit.debuff("target", 48574, "player"))
	end
	ni.data.darhanger[classlower].tiger = function() 
		return ni.unit.buff("player", 50213) 
	end
	ni.data.darhanger[classlower].savage = function() 
		return select(7, ni.unit.buff("player", 52610)) 
	end
elseif classlower == "hunter" then
	ni.data.darhanger[classlower].LastMD = 0;
	ni.data.darhanger[classlower].LastScat = 0;
	ni.data.darhanger[classlower].serpstring = function() 
		return select(7, ni.unit.debuff("target", 49001, "player")) 
	end
	ni.data.darhanger[classlower].viperstring = function() 
		return select(7, ni.unit.debuff("target", 3034, "player")) 
	end
	ni.data.darhanger[classlower].scorpstring = function() 
		return select(7, ni.unit.debuff("target", 3043, "player")) 
	end
	ni.data.darhanger[classlower].exploshot = function() 
		return select(7, ni.unit.debuff("target", 60053, "player")) 
	end
elseif classlower == "mage" then
	ni.data.darhanger[classlower].LastScorch = 0;
	ni.data.darhanger[classlower].Scorch = function()
		return ni.unit.debuff("target", 22959, "player")
	end
	ni.data.darhanger[classlower].LBomb = function() 
		return ni.unit.debuff("target", 55360, "player") 
	end
	ni.data.darhanger[classlower].fnova = function() 
		return ni.unit.debuff("target", 42917, "player") 
	end
	ni.data.darhanger[classlower].fbite = function() 
		return ni.unit.debuff("target", 12494, "player") 
	end
	ni.data.darhanger[classlower].freeze = function() 
		return ni.unit.debuff("target", 33395, "player") 
	end
	ni.data.darhanger[classlower].FoF = function() 
		return ni.player.buff(44545) 
	end
	-- Sirus Custom T4 --
	ni.data.darhanger[classlower].itemsetT4 = {
		29076, 29077, 29078, 29079, 29080, 100460, 100461, 100462, 100463, 100464 
	};	
	-- Mages Wards --
	ni.data.darhanger[classlower].FireWard = function()
		for _, v in ipairs(firedots) do
		 if ni.unit.debuff("player", v) then 
		     return true
			end
		end
		     return false
	end
	
	ni.data.darhanger[classlower].FrostWard = function()
		for _, v in ipairs(frostdots) do
		 if ni.unit.debuff("player", v) then 
		     return true
			end
		end
		     return false
	end
elseif classlower == "paladin" then
	ni.data.darhanger[classlower].LastSeal = 0;
	ni.data.darhanger[classlower].forb = function() 
		return ni.player.debuff(25771) 
	end
	ni.data.darhanger[classlower].aow = function() 
		return ni.player.buff(59578) 
	end
	ni.data.darhanger[classlower].itemsetT10 = { 
		51270, 51271, 51272, 51273, 51274, 51165, 51166, 51167, 51168, 51169, 50865, 50866, 50867, 50868, 50869
	};
elseif classlower == "priest" then
	ni.data.darhanger[classlower].lastvamp = 0;
	ni.data.darhanger[classlower].lastSWP = 0;
	ni.data.darhanger[classlower].lastPlague = 0;
	ni.data.darhanger[classlower].lastShackle = 0;	
	ni.data.darhanger[classlower].vamp = function()
		return select(7, ni.unit.debuff("target", 48160, "player")) 
	end
	ni.data.darhanger[classlower].SWP = function() 
		return select(7, ni.unit.debuff("target", 48125, "player")) 
	end
	ni.data.darhanger[classlower].dplague = function() 
		return select(7, ni.unit.debuff("target", 48300, "player")) 
	end
		-- Crimson Acolyte's Regalia --
	ni.data.darhanger[classlower].itemsetT10 = {
		51255, 51256, 51257, 51258, 51259, 51180, 51181, 51182, 51183, 51184, 50391, 50392, 50393, 50394, 50396
	};
elseif classlower == "rogue" then
	ni.data.darhanger[classlower].SnD = function() 
		return select(7, ni.player.buff(6774))
	end
	ni.data.darhanger[classlower].Hunger = function() 
		return select(7, ni.player.buff(63848)) 
	end
	ni.data.darhanger[classlower].envenom = function() 
		return select(7, ni.player.buff(57993)) 
	end
	ni.data.darhanger[classlower].Rup = function() 
		return select(7, ni.unit.debuff("target", 48672, "player")) 
	end
	ni.data.darhanger[classlower].Gar = function() 
		return select(7, ni.unit.debuff("target", 48676, "player")) 
	end
	ni.data.darhanger[classlower].OGar = function() 
		return select(7, ni.unit.debuff("target", 48676)) 
	end	
elseif classlower == "shaman" then
	ni.data.darhanger[classlower].LastPurge = 0;
	ni.data.darhanger[classlower].flameshock = function() 
		return select(7, ni.unit.debuff("target", 49233, "player")) 
	end
	-- Shaman Enchancment T10 --
	ni.data.darhanger[classlower].itemsetT10Enc = {
		50830, 50831, 50832, 50833, 50834, 51195, 51196, 51197, 51198, 51199, 51240, 51241, 51242, 51243, 51244
	};
elseif classlower == "warlock" then
	ni.data.darhanger[classlower].LastSummon = 0;
	ni.data.darhanger[classlower].LastCorrupt = 0;
	ni.data.darhanger[classlower].LastCurse = 0;
	ni.data.darhanger[classlower].LastShadowbolt = 0;
	ni.data.darhanger[classlower].Lastimmolate = 0;
	ni.data.darhanger[classlower].LastUA = 0;
	ni.data.darhanger[classlower].LastHaunt = 0;
	ni.data.darhanger[classlower].LastSeed = 0;
	ni.data.darhanger[classlower].LastBanish = 0;	
	ni.data.darhanger[classlower].CotE = function()
		return select(7, ni.unit.debuff("target", 47865))
	end
	ni.data.darhanger[classlower].elem = function()
		return select(7, ni.unit.debuff("target", 47865, "player"))
	end
	ni.data.darhanger[classlower].doom = function()
		return select(7, ni.unit.debuff("target", 47867, "player"))
	end
	ni.data.darhanger[classlower].agony = function()
		return select(7, ni.unit.debuff("target", 47864, "player"))
	end
	ni.data.darhanger[classlower].corruption = function()
		return select(7, ni.unit.debuff("target", 47813, "player"))
	end
	ni.data.darhanger[classlower].seed = function()
		return select(7, ni.unit.debuff("target", 47836, "player"))
	end
	ni.data.darhanger[classlower].haunt = function()
		return select(7, ni.unit.debuff("target", 59164, "player"))
	end
	ni.data.darhanger[classlower].ua = function()
		return select(7, ni.unit.debuff("target", 47843, "player"))
	end
	ni.data.darhanger[classlower].immolate = function()
		return select(7, ni.unit.debuff("target", 47811, "player"))
	end
	ni.data.darhanger[classlower].eplag = function() 
		return  ni.unit.debuff("target", 51735) 
	end
	ni.data.darhanger[classlower].earmoon = function()
		return ni.unit.debuff("target", 60433) 
	end
	-- Sirus Custom T4 --
	ni.data.darhanger[classlower].itemsetT4 = {
		28963, 28964, 28966, 28967, 28968, 100400, 100401, 100402, 100403, 100404
	};
	-- Shadow Ward --
	ni.data.darhanger[classlower].ShadowWard = function()
		for _, v in ipairs(shadowdots) do
		 if ni.unit.debuff("player", v) then 
		     return true
			end
		end
		     return false
	end
elseif classlower == "warrior" then
	ni.data.darhanger[classlower].LastShout = 0;
	ni.data.darhanger[classlower].rend = function() 
		return select(7, ni.unit.debuff("target", 47465, "player"))
	end
	ni.data.darhanger[classlower].hams = function() 
		return select(7, ni.unit.debuff("target", 1715, "player")) 
	end
end