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
	-- Main frame
	setupStandardFrame(dialogFrame, "MEDIUM", 300, 500, "CENTER", 0.75)

	-- Main frame title:
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
	-- Add-new dialog
	setupStandardFrame(addTrackerDialog, "HIGH", 400, 200, "CENTER", 1)
	addTrackerDialog:Hide()

	-- Add-new dialog title:
	local title = addTrackerDialog:CreateFontString(addTrackerDialog, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOP", 0, -4)
	title:SetText("Add new tracked world quest")
	-- Make it easy to access:
	addTrackerDialog.Title = title

	MarkWindowForMovement(addTrackerDialog)

	-- Input fields
	local achievInput = CreateFrame("EditBox", "achievInput", addTrackerDialog, "ChatFrameEditBoxTemplate")
	achievInput:SetFrameStrata("DIALOG")
	achievInput:SetPoint("LEFT", addTrackerDialog, 20, 0)
	achievInput:SetPoint("RIGHT", addTrackerDialog, -20, 0)
	achievInput:SetHeight(24)
	achievInput:SetMultiLine(false)
	achievInput:SetAutoFocus(true)
	achievInput:SetScript("OnEscapePressed", function() addTrackerDialog:Hide() end)

	-- Input field labels
	local text = addTrackerDialog:CreateFontString(addTrackerDialog, "OVERLAY", "GameTooltipText")
	text:SetPoint("LEFT", achievInput, 0, 10)
	text:SetText("Achievement name:")

	-- Close button
	addTrackerDialog.CloseButton = CreateFrame("Button", nil, addTrackerDialog, "UIPanelCloseButton")
	addTrackerDialog.CloseButton:SetPoint("TOPRIGHT", addTrackerDialog, "TOPRIGHT", 4, 3);
	addTrackerDialog.CloseButton:SetScript("OnClick", OnCloseButtonPressed);
	
	-- Add-new button
	local AddNew = CreateFrame("Button", "AddNew", dialogFrame, "UIPanelButtonTemplate")
	AddNew:SetPoint("TOPLEFT", dialogFrame, "BOTTOMLEFT", 10, 30)
	AddNew:SetPoint("BOTTOMRIGHT", dialogFrame, "BOTTOMRIGHT", -10, 10)
	AddNew:SetText("Add")
	AddNew:RegisterForClicks("AnyUp")
	AddNew:SetScript("OnClick", OpenAddWindow)
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