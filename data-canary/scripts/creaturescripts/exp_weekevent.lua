local events_by_day = {
	['Monday'] = {
		['LOOT'] = 2.0,
	},
	['Tuesday'] = {
		['SKILL'] = 5.3,
	},
	['Wednesday'] = {
		['EXP'] = 5.3,
	},
	['Thursday'] = {
		['LOOT'] = 5.3,
	},
	['Friday'] = {
		['LOOT'] = 50000.0,
		['SKILL'] = 50000.0,
		['EXP'] = 5000.0,
	},
	['Saturday'] = {
		['EXP'] = 50000.0,
		['SKILL'] = 50000.0,
	},
	['Sunday'] = {
		['LOOT'] = 50000.0,
		['SKILL'] = 50000.0,
		['EXP'] = 50000.0,
	},
}

local function activeCustomEvent(type, multiplier)
	if not type then return false end
	if not CustomWeeklyEvents then
		CustomWeeklyEvents = {}
	end
	CustomWeeklyEvents[type] = multiplier
	-- warn event
	Spdlog.info("Today, weekly event is: " .. type .. " " .. multiplier .. "x")
end

local eventosSemanaisStartup = GlobalEvent("eventosSemanaisStartup")

function eventosSemanaisStartup.onStartup()
	local day = os.date('%A')
	
	local todayEvents = events_by_day[day]
	for type, multiplier in pairs(todayEvents) do
		activeCustomEvent(type, multiplier)
	end
end


eventosSemanaisStartup:register()