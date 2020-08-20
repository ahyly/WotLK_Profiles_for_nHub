local enables = {
	afk = true
}
local values = {
}
local inputs = {
}
local menus = {

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
	settingsfile = "ni_anti_afk.xml",
	callback = GUICallback,
	{ type = "title", text = "Anti-AFK Profile" },
	{ type = "separator" },
	{ 
		type = "entry", 
		text = "Anti-AFK",
		enabled = enables["afk"],
		tooltip = "Enable/Disable Anti-AFK",
		key = "afk"
	},
}
local function OnLoad()
	ni.GUI.AddFrame("Anti-AFK", items);
end
local function OnUnload()
	ni.GUI.DestroyFrame("Anti-AFK");
end
local queue = {
	"Anti-AFK"
}
local lastreset = 0;
local abilities = {
	["Anti-AFK"] = function()
		if enables["afk"]
		and GetTime() - lastreset > 30 then
			ni.utils.resetlasthardwareaction();
			lastreset = GetTime();
		end
	end,
}
ni.bootstrap.profile("Anti-AFK", queue, abilities, OnLoad, OnUnload);