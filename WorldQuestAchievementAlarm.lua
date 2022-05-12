local WQAA = LibStub("AceAddon-3.0"):NewAddon("WorldQuestAchievementAlarm", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")

WQAA.questIds = {59717, 52798, 51957, 51983, 51173, 50665, 50717, 50899, 51977, 51947, 51974, 51976, 51978, 54415, 54689, 63972, 63836, 63837, 63945, 63846, 63773, 64016, 63989, 64017, 59705}
WQAA.mapIds = {1536, 1533, 1565, 1525, 863, 864, 942, 896, 1961, 1960}

function WQAA:CheckAvailableWQs()
	local availableQuests = {}
	for _, mapId in ipairs(WQAA.mapIds) do
		local mapInfo = C_Map.GetMapInfo(mapId)
		local mapQuests = C_TaskQuest.GetQuestsForPlayerByMapID(mapId)

		local availableMapQuests = {}
		for _, info in pairs(mapQuests) do
			if WQAA:isInTable(WQAA.questIds, info.questId) == true then
				local questTitle, factionID, capped, displayAsObjective = C_TaskQuest.GetQuestInfoByQuestID(info.questId)
				table.insert(availableMapQuests, questTitle)
			end
		end
		
		if next(availableMapQuests) ~= nil then
			availableQuests[mapInfo.name] = availableMapQuests
		end
	end
	
	if next(availableQuests) ~= nil then
		local frame = AceGUI:Create("Frame")
		frame:SetTitle("WQAA's WQ list")
		frame:SetLayout("List")
		frame:SetWidth(225)
		frame:SetHeight(200)

		for mapName, quests in pairs(availableQuests) do
			WQAA:Print(quests[1])
			local h = AceGUI:Create("Heading")
			h:SetText(mapName)
			h:SetWidth(200)
			frame:AddChild(h)

			for _, quest in pairs(quests) do
				local l = AceGUI:Create("InteractiveLabel")
				l:SetText(quest)
				l:SetWidth(200)
				l:SetColor(0, 255, 0)
				frame:AddChild(l)
			end
		end
	else
		WQAA:Print("There are no tracked WQs available right now :(")
	end
end

function WQAA:OnEnable()
	WQAA:Print("Enabled")
	WQAA:CheckAvailableWQs()
	--	WQAA:ToastFakeAchievement()
end

function WQAA:isInTable(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end 

function WQAA:ToastFakeAchievement()
	if (Kiosk.IsEnabled()) then
	  return;
	end
	if ( not AchievementFrame ) then
	  AchievementFrame_LoadUI();
	end

	WQAA.AlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("WQAAAlertFrameTemplate", WQAAAlertFrame_SetUp, 4, math.huge)
	  
	WQAA.AlertSystem:AddAlert()
  
  end

  
local function WQAAAlertFrame_SetUp(frame)
	-- An alert flagged as alreadyEarned has more space for the text to display since there's no shield+points icon.
	local ret = AchievementAlertFrame_SetUp(frame, 5208, false)
	frame.Name:SetText("test title")
	frame.Unlocked:SetText("toptext")
	frame.onClick = function()
		Calendar_LoadUI()
		if (Calendar_Show) then  Calendar_Show();  end
	end
	frame.delay = 0

	frame.Icon.Texture:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
	frame.Background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Background")
	--frame.OldAchievement:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders")
	frame.OldAchievement:Hide()
end