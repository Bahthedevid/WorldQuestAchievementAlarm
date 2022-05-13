local WorldQuestAchievementAlarm = LibStub("AceAddon-3.0"):NewAddon("WorldQuestAchievementAlarm", "AceConsole-3.0")

local WQAA = WorldQuestAchievementAlarm

WQAA.questIds = {58207, 58437, 59717, 52798, 51957, 51983, 51173, 50665, 50717, 50899, 51977, 51947, 51974, 51976, 51978, 54415, 54689, 63972, 63836, 63837, 63945, 63846, 63773, 64016, 63989, 64017, 59705}
WQAA.mapIds = {1536, 1533, 1565, 1525, 863, 864, 942, 896, 1961, 1960}

function WQAA:OnInitialize()
	WQAA:RegisterChatCommand("wqaa", "SlashHandler")

	if WQAA.Frame == nil then
		WQAA.frame = CreateFrame("Frame", "WQAAList", UIParent, "DialogBoxFrame")

		WQAA.frame:SetPoint("CENTER")
		WQAA.frame:SetSize(600, 500)
		WQAA.frame:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true, tileSize = 16, edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
		WQAA.frame:SetBackdropColor(0, 0, 0, 1);
		WQAA.frame:SetMovable(true)
		WQAA.frame:SetClampedToScreen(true)
		WQAA.frame:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				self:StartMoving()
			end
		end)
		WQAA.frame:SetScript("OnMouseUp", WQAA.frame.StopMovingOrSizing)

		-- ScrollFrame
		local sf = CreateFrame("ScrollFrame", "WQAAListScrollFrame", WQAAList, "UIPanelScrollFrameTemplate")
		sf:SetPoint("LEFT", 16, 0)
		sf:SetPoint("RIGHT", -32, 0)
		sf:SetPoint("TOP", 0, -16)
		sf:SetPoint("BOTTOM", WQAAListButton, "TOP", 0, 0)

		-- EditBox
		local eb = CreateFrame("EditBox", "WQAAListEditBox", WQAAListScrollFrame)
		eb:SetSize(sf:GetSize())
		eb:SetMultiLine(true)
		eb:SetAutoFocus(false) -- dont automatically focus
		eb:SetFontObject("ChatFontNormal")
		eb:SetScript("OnEscapePressed", function() WQAA.frame:Hide() end)
		WQAAListButton:SetScript("OnClick", function (self, button, down)
			if self:GetParent().OnClick then
				self:GetParent().OnClick(WQAAListEditBox:GetText());
			end
			self:GetParent():Hide();
		end);
		sf:SetScrollChild(eb)

		-- Resizable
		WQAA.frame:SetResizable(true)
		WQAA.frame:SetMinResize(150, 100)

		local rb = CreateFrame("Button", "WQAAListResizeButton", WQAAList)
		rb:SetPoint("BOTTOMRIGHT", -6, 7)
		rb:SetSize(16, 16)

		rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
		rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

		rb:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				WQAA.frame:StartSizing("BOTTOMRIGHT")
				self:GetHighlightTexture():Hide() -- more noticeable
			end
		end)
		rb:SetScript("OnMouseUp", function(self, button)
			f:StopMovingOrSizing()
			self:GetHighlightTexture():Show()
			eb:SetWidth(sf:GetWidth())
		end)
		WQAA.frame:Show()
    end
end

function WQAA:CheckAvailableWQs()
	local availableQuests = {}
	for _, mapId in ipairs(WQAA.mapIds) do
		WQAA:Print("Getting map info")
		local mapInfo = C_Map.GetMapInfo(mapId)
		WQAA:Print("Getting quests by map ID")
		local mapQuests = C_TaskQuest.GetQuestsForPlayerByMapID(mapId)
		WQAA:Print(mapQuests)
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
		WQAA:Print("Available quests: ")
		WQAA:Print(availableQuests)
		for mapName, quests in pairs(availableQuests) do
			WQAA:Print(quests[1])
			for index, quest in pairs(quests) do
				local fontString = WQAA.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
				fontString:SetText(quest)
				fontString:SetJustifyH("LEFT")
				fontString:SetJustifyV("TOP")
	
				fontString:SetPoint("LEFT", 11, 0)
				fontString:SetPoint("RIGHT", -12, 0)
				if index > 1 then
					-- Change the second 0 if you want some vertical spacing:
					fontString:SetPoint("TOP", frame.fontStrings[i-1], "BOTTOM", 0, 5)
				else
					-- Use the frame's background inset for the vertical offset:
					fontString:SetPoint("TOP", 0, -12)
				end
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

function WQAA:SlashHandler(input)
    if WQAA.Frame:IsShown() then
        WQAA.Close()
    else
        WQAA.Open()
    end
end

function WQAA:Close()
    WQAA.Frame:Hide()
end

function WQAA.Open()
    WQAA.Frame:Show()
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