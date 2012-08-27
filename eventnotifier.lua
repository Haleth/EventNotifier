-- Options

local checkMail = true
local checkEvents = true
local checkGuildEvents = true

-- Addon itself

local numInvites = 0 -- store amount of invites to compare later, and only show banner when invites differ; events fire multiple times
local hasMail = false -- same with mail

local function GetGuildInvites()
	local numGuildInvites = 0
	local _, currentMonth = CalendarGetDate()

	for i = 1, CalendarGetNumGuildEvents() do
		local month, day = CalendarGetGuildEventInfo(i)
		local monthOffset = month - currentMonth
		local numDayEvents = CalendarGetNumDayEvents(monthOffset, day)

		for i = 1, numDayEvents do
			local _, _, _, _, _, _, _, _, inviteStatus = CalendarGetDayEvent(monthOffset, day, i)
			if inviteStatus == 8 then
				numGuildInvites = numGuildInvites + 1
			end
		end
	end

	return numGuildInvites
end

local function toggleCalendar()
	if not CalendarFrame then LoadAddOn("Blizzard_Calendar") end
	Calendar_Toggle()
end

local function alertEvents()
	if CalendarFrame and CalendarFrame:IsShown() then return end
	local num = CalendarGetNumPendingInvites()
	if num ~= numInvites then
		if num > 1 then
			Notifications:Alert(format("You have %s pending calendar invites.", num))
		elseif num > 0 then
			Notifications:Alert("You have 1 pending calendar invite.")
		end
		numInvites = num
	end
end

local function alertGuildEvents()
	if CalendarFrame and CalendarFrame:IsShown() then return end
	local num = GetGuildInvites()
	if num > 1 then
		Notifications:Alert(format("You have %s pending guild events.", num), toggleCalendar)
	elseif num > 0 then
		Notifications:Alert("You have 1 pending guild event.", toggleCalendar)
	end
end

local f = CreateFrame("Frame", nil, frame)
f:RegisterEvent("PLAYER_ENTERING_WORLD")
if checkMail then
	f:RegisterEvent("UPDATE_PENDING_MAIL")
end
if checkGuildEvents then
	f:RegisterEvent("CALENDAR_UPDATE_GUILD_EVENTS")
end

f:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_ENTERING_WORLD" then
		if checkEvents or checkGuildEvents then
			OpenCalendar()
			f:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
		end
		
		if checkEvents then
			alertEvents()
		end
		if checkGuildEvents then
			alertGuildEvents()
		end

		f:UnregisterEvent("PLAYER_ENTERING_WORLD")
	elseif event == "UPDATE_PENDING_MAIL" then
		local newMail = HasNewMail()
		if hasMail ~= newMail then
			hasMail = newMail
			if hasMail then
				Notifications:Alert("You have new mail.")
			end
		end
	elseif event == "CALENDAR_UPDATE_PENDING_INVITES" then
		if checkEvents then
			alertEvents()
		end
		if checkGuildEvents then
			alertGuildEvents()
		end
	else
		alertGuildEvents()
	end
end)