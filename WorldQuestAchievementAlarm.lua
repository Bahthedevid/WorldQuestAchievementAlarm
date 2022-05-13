local WQAA = LibStub("AceAddon-3.0"):NewAddon("WorldQuestAchievementAlarm", "AceConsole-3.0")

WQAA.questIds = {59717, 52798, 51957, 51983, 51173, 50665, 50717, 50899, 51977, 51947, 51974, 51976, 51978, 54415, 54689, 63972, 63836, 63837, 63945, 63846, 63773, 64016, 63989, 64017, 59705}
WQAA.mapIds = {1536, 1533, 1565, 1525, 863, 864, 942, 896, 1961, 1960}

function WQAA:CheckAvailableWQs()
	-- Check if ther are any tracked WQs available
	local availableQuests = {}
	for _, mapId in ipairs(WQAA.mapIds) do
		local mapInfo = C_Map.GetMapInfo(mapId)
		local mapQuests = C_TaskQuest.GetQuestsForPlayerByMapID(mapId)

		local availableMapQuests = {}
		for _, info in pairs(mapQuests) do
			if WQAA:isInTable(WQAA.questIds, info.questId) == true then
				local questTitle, factionID, capped, displayAsObjective = C_TaskQuest.GetQuestInfoByQuestID(info.questId)
				table.insert(availableMapQuests, {questTitle, info.questId})
			end
		end
		
		if next(availableMapQuests) ~= nil then
			availableQuests[mapInfo.name] = availableMapQuests
		end
	end
	
	-- Show frame with available WQs or just print that there are none in chat window
	if next(availableQuests) ~= nil then
		local frame = AceGUI:Create("Frame")
		frame:SetTitle("WQAA's WQ list")
		frame:SetLayout("List")
		frame:SetWidth(225)
		frame:SetHeight(200)

		for mapName, quests in pairs(availableQuests) do
			local h = AceGUI:Create("Heading")
			h:SetText(mapName)
			h:SetWidth(200)
			frame:AddChild(h)

			for _, quest in pairs(quests) do
				local l = AceGUI:Create("InteractiveLabel")
				l:SetText(quest[1] .. " " .. quest[2])
				l:SetWidth(200)
				l:SetColor(0, 255, 0)
				l:SetCallback("OnClick", function() C_QuestLog.AddWorldQuestWatch(quest[2]) end)
				frame:AddChild(l)
			end
		end
	else
		WQAA:Print("There are no tracked WQs available right now :(")
	end
end

function WQAA:SlashCommand()
	WQAA:CheckAvailableWQs()
end

function WQAA:OnInitialize()
	self:RegisterChatCommand("wqaa", "SlashCommand")
end

function WQAA:OnEnable()
	WQAA:Print("Enabled")
--	WQAA:CheckAvailableWQs()
end

-- Check if value is in hash table
function WQAA:isInTable(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end 
