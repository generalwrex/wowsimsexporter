-- Author      : generalwrex (Natop on Myzrael)
-- Create Date : 1/28/2022 9:30:08 AM

WowSimsExporter = LibStub("AceAddon-3.0"):NewAddon("WowSimsExporter", "AceConsole-3.0", "AceEvent-3.0")

WowSimsExporter.Json = ""

local AceGUI = LibStub("AceGUI-3.0")
local LibParse = LibStub("LibParse")

local version = "1.2 (ALPHA)"

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

function WowSimsExporter:ParseUnfilteredCombatLog()

end



function WowSimsExporter:CreateGroupStructure()

end


function WowSimsExporter:CreateCharacterStructure(unit, gearIn)
    local name, realm = UnitFullName(unit)
    local locClass, engClass, locRace, engRace, gender, name, server = GetPlayerInfoByGUID(UnitGUID(unit))
    local level = UnitLevel(unit)

    local character = {
        name = name,
        realm = realm,
        race = engRace,
        class = engClass,
		level = tonumber(level),
        talents = self:CreateTalentEntry(),
        gear = { 
			items = gearIn 
			} 
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

    elseif (input=="open" or input=="show") then        
        self:CreateWindow()
	elseif (input == "export") then        
        self:CreateWindow(true)
    end
end


function WowSimsExporter:CreateWindow(generate)

    local frame = AceGUI:Create("Frame")
    frame:SetCallback(
        "OnClose",
        function(widget)
            AceGUI:Release(widget)
        end
    )
    frame:SetTitle("WowSimsExporter V" .. version .. "")
    frame:SetStatusText("Click 'Generate Data' to display exportable data")
    frame:SetLayout("Flow")
    local jsonbox = AceGUI:Create("MultiLineEditBox")
    jsonbox:SetLabel("Copy and paste into the websites importer at https://wowsims.github.io/tbc/.")
    jsonbox:SetFullWidth(true)
    jsonbox:SetFullHeight(true)
    jsonbox:DisableButton(true)
   

	local function l_Generate()
		WowSimsExporter.Json = WowSimsExporter:GetGearEnchantGems("player")
		jsonbox:SetText(LibParse:JSONEncode(WowSimsExporter.Json)) 
		jsonbox:HighlightText()
		jsonbox:SetFocus()
	end
	if generate then l_Generate() end

    local button = AceGUI:Create("Button")
    button:SetText("Generate Data")
    button:SetWidth(200)
	button:SetCallback("OnClick", function()
		l_Generate()
	end)
	
    local label = AceGUI:Create("Label")
    label:SetText([[!THIS ADDON IS IN AN ALPHA STATE!
As this is in a testing phase, the import button his hidden from the website to avoid issues with users not knowing where the addon is!

To find the import button you can see it by going to any of the sims and adding ?debug to the URL. If there is a # in the URL the ?debug has to come first.

This will add a import button to the top right of the page to the right of the report a feature button.




]])
	label:SetFullWidth(true)


	local label2 = AceGUI:Create("Label")
	label2:SetText("Generate Data from Equipped Gear")

	frame:AddChild(label)
	frame:AddChild(label2)
    frame:AddChild(button)
	frame:AddChild(jsonbox)
end

function WowSimsExporter:GetGearEnchantGems(type)
    local gear = {}

    for slotNum = 1, #slotNames do
        local slotId = GetInventorySlotInfo(slotNames[slotNum])
        local itemLink = GetInventoryItemLink("player", slotId)

        if itemLink then
            local Id, Enchant, Gem1, Gem2, Gem3, Gem4 = self:ParseItemLink(itemLink)

			item = {}
			item.id = Id
			item.enchant = tonumber(Enchant)
			item.gems = {tonumber(Gem1), tonumber(Gem2), tonumber(Gem3), tonumber(Gem4)}
			gear[slotNum] = item

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
