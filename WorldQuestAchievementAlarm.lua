local WorldQuestAchievementAlarm = LibStub("AceAddon-3.0"):NewAddon("WorldQuestAchievementAlarm", "AceConsole-3.0")
local WQAA = WorldQuestAchievementAlarm

local dialogFrame = CreateFrame("Frame", "MainWindow", UIParent, "BackdropTemplate")
local addTrackerDialog = CreateFrame("Frame", "AddTrackerDialog", dialogFrame, "BackdropTemplate")

local function AddToFrame(QuestTitle)
	local text = dialogFrame:CreateFontString(dialogFrame, "OVERLAY", "GameTooltipText")
	text:SetPoint("CENTER", 0, 0)
	text:SetText(QuestTitle)
end

local function SeeIfWorldQuestIsActive(questID)
	local QuestTitle, _, _, _ = C_TaskQuest.GetQuestInfoByQuestID(questID)
	local isActive = C_TaskQuest.IsActive(questID)
	if (isActive) then
		-- Add world quest to frame
		AddToFrame(QuestTitle)
		WQAA:Print(QuestTitle .. " is currently active!")
	end
end

local function ScanAchievements()
	for key, value in pairs(WQAAQuestData) do
		local _, _, _, Completed, _, _, _, _, _, _, _, _ = GetAchievementInfo(key)
		WQAA:Print("VALUES: " .. key .. " " .. value)
		if (Completed == false) then
			SeeIfWorldQuestIsActive(value)
		end
	end
end

-----------------------------------------
-- UI STUFF START -----------------------
-----------------------------------------

local function OnCloseButtonPressed(self)
	self:GetParent():Hide();
end

local function MarkWindowForMovement(frame)
	-- Enable moving the dialog
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetScript("OnHide", frame.StopMovingOrSizing)
end

local function setupStandardFrame(frame, strata, xSize, ySize, point, backgroundAlpha)
	frame:SetFrameStrata(strata)
	frame:SetSize(xSize, ySize)
	frame:SetPoint(point)
	frame:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeSize = 1,
	})
	frame:SetBackdropColor(0, 0, 0, backgroundAlpha)
	frame:SetBackdropBorderColor(0, 0, 0)
end

local function AddMainUIFrame()
	-- Main UI frame
	setupStandardFrame(dialogFrame, "HIGH", 800, 500, "CENTER", 0.75)

	-- Main UI frame title:
	local title = dialogFrame:CreateFontString(dialogFrame, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOP", 0, -4)
	title:SetText("World Quest Achievement Alarm")
	-- Make it easy to access:
	dialogFrame.Title = title

	MarkWindowForMovement(dialogFrame)

	-- Scrollframe
	-- local scrollFrame = CreateFrame("ScrollFrame", "WQAAScrollFrame", dialogFrame, "UIPanelScrollFrameTemplate")
	-- scrollFrame:SetPoint("LEFT", 16, 0)
	-- scrollFrame:SetPoint("RIGHT", -32, 0)
	-- scrollFrame:SetPoint("TOP", 0, -16)
	-- scrollFrame:SetPoint("BOTTOM", dialogFrame, "TOP", 0, 0)
	
	-- Close button
	dialogFrame.CloseButton = CreateFrame("Button", nil, dialogFrame, "UIPanelCloseButton")
	dialogFrame.CloseButton:SetPoint("TOPRIGHT", dialogFrame, "TOPRIGHT", 4, 3);
	dialogFrame.CloseButton:SetScript("OnClick", OnCloseButtonPressed);
end

local function OpenAddWindow()
	addTrackerDialog:Show()
end

local function AddNewTrackedObjectDialog()
	-- Add new tracked quest dialog
	setupStandardFrame(addTrackerDialog, "DIALOG", 400, 200, "CENTER", 1)
	addTrackerDialog:Hide()

	-- Add new tracked WQ dialog title:
	local title = addTrackerDialog:CreateFontString(addTrackerDialog, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOP", 0, -4)
	title:SetText("Add new tracked world quest")
	-- Make it easy to access:
	addTrackerDialog.Title = title

	MarkWindowForMovement(addTrackerDialog)

	-- Input fields
	local achievInput = CreateFrame("EditBox", "achievInput", addTrackerDialog, "ChatFrameEditBoxTemplate")
	achievInput:SetPoint("LEFT", addTrackerDialog, 20, 0)
	achievInput:SetPoint("RIGHT", addTrackerDialog, -20, 0)
	achievInput:SetMultiLine(false)
	achievInput:SetAutoFocus(true)
	achievInput:SetScript("OnEscapePressed", function() addTrackerDialog:Hide() end)

	-- Close button
	addTrackerDialog.CloseButton = CreateFrame("Button", nil, addTrackerDialog, "UIPanelCloseButton")
	addTrackerDialog.CloseButton:SetPoint("TOPRIGHT", addTrackerDialog, "TOPRIGHT", 4, 3);
	addTrackerDialog.CloseButton:SetScript("OnClick", OnCloseButtonPressed);
	
	-- TrackNew button
	local TrackNew = CreateFrame("Button", "TrackNew", dialogFrame, "UIPanelButtonTemplate")
	TrackNew:SetWidth(50)
	TrackNew:SetHeight(25)
	TrackNew:SetPoint("BOTTOMLEFT", 5, 5)
	TrackNew:SetText("Add")
	TrackNew:RegisterForClicks("AnyUp")
	TrackNew:SetScript("OnClick", OpenAddWindow)
end

local function Close()
    dialogFrame:Hide()
end

local function Open()
    dialogFrame:Show()
end

-----------------------------------------
-- UI STUFF END -------------------------
-----------------------------------------

function WQAA:SlashHandler()
    if dialogFrame:IsShown() then
        Close()
    else
		Open()
    end
end

function WQAA:OnInitialize()
	WQAA:RegisterChatCommand("wqaa", "SlashHandler")

	AddMainUIFrame()
	AddNewTrackedObjectDialog()
end

function WQAA:OnEnable()
	WQAA:Print("Enabled")
	ScanAchievements()
end