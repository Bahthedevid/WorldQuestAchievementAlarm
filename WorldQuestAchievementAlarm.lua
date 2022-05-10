local WQAA = LibStub("AceAddon-3.0"):NewAddon("World Quest Achievement Alarm", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")

WQAA.questIds = {59717}
WQAA.mapIds = {1536, 1533}

WQAA.frame = AceGUI:Create("Frame")
WQAA.frame:SetTitle("WQAA's WQ list")
WQAA.frame:SetLayout("List")

function WQAA:CheckAvailableWQs()
	for _, mapId in ipairs(WQAA.mapIds) do
		local mapInfo = C_Map.GetMapInfo(mapId)
		local mapQuests = C_TaskQuest.GetQuestsForPlayerByMapID(mapId)

		local h = AceGUI:Create("Heading")
		h:SetText(mapInfo.name)
		h:SetWidth(200)
		WQAA.frame:AddChild(h)

		for i, info  in pairs(mapQuests) do
			local questTitle, factionID, capped, displayAsObjective = C_TaskQuest.GetQuestInfoByQuestID(info.questId)
			local l = AceGUI:Create("InteractiveLabel")
			l:SetText(questTitle)
			l:SetWidth(200)
			WQAA.frame:AddChild(l)
		end
	end
end

function WQAA:OnEnable()
	WQAA:Print("Enabled")
	WQAA:CheckAvailableWQs()
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end 