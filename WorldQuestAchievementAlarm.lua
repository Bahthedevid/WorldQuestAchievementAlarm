local WorldQuestAchievementAlarm = LibStub("AceAddon-3.0"):NewAddon("WorldQuestAchievementAlarm", "AceConsole-3.0")
local WQAA = WorldQuestAchievementAlarm

local mainWindow = CreateFrame("Frame", "MainWindow", UIParent, "BackdropTemplate")
local mainWindowTitle = mainWindow:CreateFontString(mainWindow, "OVERLAY", "GameFontNormal")
local scrollFrame = CreateFrame("ScrollFrame", "WQAAScrollFrame", mainWindow, "UIPanelScrollFrameTemplate")
local addNewWindow = CreateFrame("Frame", "AddTrackerDialog", mainWindow, "BackdropTemplate")
local mainWindowAddNewButton = CreateFrame("Button", "AddNew", mainWindow, "UIPanelButtonTemplate")
local addNewWindowAddButton = CreateFrame("Button", "DialogAdd", addNewWindow, "UIPanelButtonTemplate")


local function CreateListElement()
	local firstListEntry = scrollFrame:CreateFontString(scrollFrame, "OVERLAY", "GameFontNormal")
	firstListEntry:SetPoint("LEFT", scrollFrame, "LEFT")
	firstListEntry:SetPoint("RIGHT", scrollFrame, "RIGHT")
	firstListEntry:SetJustifyH("LEFT")
	return firstListEntry
end

local function BuildListOfActiveWorldQuests(questList)
	local firstListElement = CreateListElement()
	firstListElement:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT")
	local previousFrame = firstListElement
	for key, value in pairs(questList) do
		WQAA:Print("MAP: " .. key .. " " .. value)
		listEntry = CreateListElement()
		listEntry:SetText(key)
		listEntry:SetPoint("TOP", previousFrame, "BOTTOM", 0, -8)
		listEntry:SetPoint("LEFT", scrollFrame, "LEFT")
		tabbedListEntry = scrollFrame:CreateFontString(scrollFrame, "OVERLAY", "GameFontNormal")
		tabbedListEntry:SetText(value)
		tabbedListEntry:SetPoint("TOPLEFT", listEntry, "BOTTOMLEFT", 15, -4)
		previousFrame = tabbedListEntry
	end
end

local function WorldQuestIsActive(questID)
	return C_TaskQuest.IsActive(questID)
end

local function ScanAchievements()
	local activeUnfinishedQuests = {}
	for key, value in pairs(WQAAQuestData) do
		local _, name, _, completed, _, _, _, _, _, _, _, _ = GetAchievementInfo(key)
		local questTitle, _, _, _ = C_TaskQuest.GetQuestInfoByQuestID(value)
		WQAA:Print("VALUES: " .. key .. " " .. value)
		if (completed == false) then
			if (WorldQuestIsActive(value)) then
				activeUnfinishedQuests[name] = questTitle
			end
		end
	end
	BuildListOfActiveWorldQuests(activeUnfinishedQuests)
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

local function OpenAddWindow()
	addNewWindow:Show()
end

local function AddMainUIFrame()
	-- Main frame
	setupStandardFrame(mainWindow, "MEDIUM", 300, 500, "CENTER", 0.75)

	-- Main frame title:
	mainWindowTitle:SetPoint("TOP", mainWindow, "TOP", 0, -6)
	mainWindowTitle:SetText("World Quest Achievement Alarm")
	mainWindowTitle:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
	-- Make it easy to access:
	mainWindow.Title = mainWindowTitle

	MarkWindowForMovement(mainWindow)

	-- Scrollframe
	scrollFrame:SetPoint("TOPLEFT", mainWindowTitle, "BOTTOMLEFT", -10, -10)
	scrollFrame:SetPoint("TOPRIGHT", mainWindowTitle, "BOTTOMRIGHT", -5, -10)
	scrollFrame:SetPoint("BOTTOMLEFT", mainWindowAddNewButton, "TOPLEFT", 0, 10)
	scrollFrame:SetPoint("BOTTOMRIGHT", mainWindowAddNewButton, "TOPRIGHT", 0, 10)

	-- Close button
	mainWindow.CloseButton = CreateFrame("Button", nil, mainWindow, "UIPanelButtonTemplate")
	mainWindow.CloseButton:SetPoint("BOTTOMLEFT", mainWindow, "BOTTOM", 10, 10);
	mainWindow.CloseButton:SetPoint("TOPRIGHT", mainWindow, "BOTTOMRIGHT", -10, 30);
	mainWindow.CloseButton:SetScript("OnClick", OnCloseButtonPressed);
	mainWindow.CloseButton:SetText("Close")

	-- Add-new button
	mainWindowAddNewButton:SetPoint("TOPLEFT", mainWindow, "BOTTOMLEFT", 10, 30)
	mainWindowAddNewButton:SetPoint("BOTTOMRIGHT", mainWindow, "BOTTOM", -10, 10)
	mainWindowAddNewButton:SetText("Add")
	mainWindowAddNewButton:RegisterForClicks("AnyUp")
	mainWindowAddNewButton:SetScript("OnClick", OpenAddWindow)
end

local function AddNewTrackedObjectDialog()
	-- Add-new dialog
	setupStandardFrame(addNewWindow, "HIGH", 400, 200, "CENTER", 1)
	addNewWindow:Hide()

	-- Add-new dialog title:
	local title = addNewWindow:CreateFontString(addNewWindow, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOP", 0, -4)
	title:SetText("Add new tracked world quest")
	-- Make it easy to access:
	addNewWindow.Title = title

	MarkWindowForMovement(addNewWindow)

	-- Input fields
	local achievInput = CreateFrame("EditBox", "achievInput", addNewWindow, "ChatFrameEditBoxTemplate")
	achievInput:SetFrameStrata("DIALOG")
	achievInput:SetPoint("LEFT", addNewWindow, 20, 0)
	achievInput:SetPoint("RIGHT", addNewWindow, -20, 0)
	achievInput:SetHeight(24)
	achievInput:SetMultiLine(false)
	achievInput:SetAutoFocus(true)
	achievInput:SetScript("OnEscapePressed", function() addNewWindow:Hide() end)

	-- Input field labels
	local text = addNewWindow:CreateFontString(addNewWindow, "OVERLAY", "GameTooltipText")
	text:SetPoint("LEFT", achievInput, 0, 10)
	text:SetText("Achievement name:")

	-- Close button
	addNewWindow.CloseButton = CreateFrame("Button", nil, addNewWindow, "UIPanelButtonTemplate")
	addNewWindow.CloseButton:SetPoint("BOTTOMLEFT", addNewWindow, "BOTTOM", 10, 10);
	addNewWindow.CloseButton:SetPoint("TOPRIGHT", addNewWindow, "BOTTOMRIGHT", -10, 30);
	addNewWindow.CloseButton:SetScript("OnClick", OnCloseButtonPressed);
	addNewWindow.CloseButton:SetText("Close")
	
	-- Dialog add button
	addNewWindowAddButton:SetPoint("TOPLEFT", addNewWindow, "BOTTOMLEFT", 10, 30)
	addNewWindowAddButton:SetPoint("BOTTOMRIGHT", addNewWindow, "BOTTOM", -10, 10)
	addNewWindowAddButton:SetText("Add")
	addNewWindowAddButton:RegisterForClicks("AnyUp")
	addNewWindowAddButton:SetScript("OnClick", OpenAddWindow)
end

local function Close()
    mainWindow:Hide()
end

local function Open()
    mainWindow:Show()
end

-----------------------------------------
-- UI STUFF END -------------------------
-----------------------------------------

function WQAA:SlashHandler()
    if mainWindow:IsShown() then
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