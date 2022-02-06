-- Author      : generalwrex (Natop on Myzrael)
-- Create Date : 1/28/2022 9:30:08 AM

WowSimsExporter = LibStub("AceAddon-3.0"):NewAddon("WowSimsExporter", "AceConsole-3.0", "AceEvent-3.0")

WowSimsExporter.Json = ""

local AceGUI = LibStub("AceGUI-3.0")
local LibParse = LibStub("LibParse")

local version = "1.0"

local defaults = {
	profile = {
		updateGearChange = true,
	},
}

local options = { 
	name = "WowSimsExporter",
	handler = WowSimsExporter,
	type = "group",
	args = {
		updateGearChange = {
			type = "toggle",
			name = "Update on Gear Change",
			desc = "Update your data when you change gear pieces.",
			get = "isGearChangeSet",
			set = "setGearChange"
		},
		openExporterButton = {
			type = "execute",
			name = "Open Exporter Window",
			desc = "Opens the exporter window",
			func = function() WowSimsExporter:CreateWindow() end

		},
	},
}


function WowSimsExporter:CreateCharacterStructure(type, gearIn)
    local name, realm = UnitFullName(type)
    local locClass, engClass, locRace, engRace, gender, name, server = GetPlayerInfoByGUID(UnitGUID(type))
    local level = UnitLevel(type)

    local character = {
        name = name,
        realm = realm,
        race = engRace,
        class = engClass,
		level = level,
        talents = self:CreateTalentEntry(),
        gear = gearIn
    }

    return character
end

function WowSimsExporter:CreateTalentEntry()
    local talents = {}

    local numTabs = GetNumTalentTabs()
    for t = 1, numTabs do
        local numTalents = GetNumTalents(t)
        for i = 1, numTalents do
            local nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(t, i)

            table.insert(talents, tostring(currRank))
        end
        if (t < 3) then
            table.insert(talents, "-")
        end
    end

    return table.concat(talents)
end


function WowSimsExporter:SlashCommand(input)
    if not input or input:trim() == "" then

        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)

    elseif (input == "export" or input == "e") then        
        self:CreateWindow()
    end
end


function WowSimsExporter:CreateWindow()

    local frame = AceGUI:Create("Frame")
    frame:SetCallback(
        "OnClose",
        function(widget)
            AceGUI:Release(widget)
        end
    )
    frame:SetTitle("WowSimsExporter V" .. version .. "")
    frame:SetStatusText("Status Bar")
    frame:SetLayout("Flow")

    local jsonbox = AceGUI:Create("MultiLineEditBox")
    jsonbox:SetLabel("Copy and paste into the websites importer at https://wowsims.github.io/tbc/.")
    jsonbox:SetFullWidth(true)
    jsonbox:SetFullHeight(true)
    jsonbox:DisableButton(true)
    jsonbox:HighlightText()

	if not(self.Json == "") then
		jsonbox:SetText(LibParse:JSONEncode(self.Json)) 
	end

    frame:AddChild(jsonbox)

    local button = AceGUI:Create("Button")
    button:SetText("Generate Data")
    button:SetWidth(200)
	button.OnClick = function() 
		self.Json = self:GetGearEnchantGems("player")
		jsonbox:SetText(LibParse:JSONEncode(self.Json)) 
	end
    frame:AddChild(button)
end

function WowSimsExporter:GetGearEnchantGems(type)
    local gear = {}

    for slotNum = 1, #slotNames do
        local slotId = GetInventorySlotInfo(slotNames[slotNum])
        local itemLink = GetInventoryItemLink("player", slotId)

        if itemLink then
            local Id, Enchant, Gem1, Gem2, Gem3, Gem4 = self:ParseItemLink(itemLink)

            table.insert(
                gear,
                slotNum,
                {
                    item = Id,
                    enchant = Enchant,
                    gems = {Gem1, Gem2, Gem3, Gem4}
                }
            )
        end
    end

    return self:CreateCharacterStructure(type, gear)
end

function WowSimsExporter:ParseItemLink(itemLink)
    local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name =
        string.find(
        itemLink,
        "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?"
    )
    return Id, Enchant, Gem1, Gem2, Gem3, Gem4
end

function WowSimsExporter:OnInitialize()

	self.db = LibStub("AceDB-3.0"):New("WSEDB", defaults, true)

	LibStub("AceConfig-3.0"):RegisterOptionsTable("WowSimsExporter", options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WowSimsExporter", "WowSimsExporter")

	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("WowSimsExporter_Profiles", profiles)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WowSimsExporter_Profiles", "Profiles", "WowSimsExporter")

    self:RegisterChatCommand("wse", "SlashCommand")
    self:RegisterChatCommand("wowsimsexporter", "SlashCommand")
    self:RegisterChatCommand("wsexporter", "SlashCommand")

    self:Print("WowSimsExporter v" .. version .. " Initialized. use /wse For Window.")

end



function WowSimsExporter:OnEnable()
end

function WowSimsExporter:OnDisable()
end

function WowSimsExporter:isGearChangeSet(info)
	return self.db.profile.updateGearChange
end

function WowSimsExporter:setGearChange(info, value)
	self.db.profile.updateGearChange = value
end
