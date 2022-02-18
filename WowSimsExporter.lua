-- Author      : generalwrex (Natop on Myzrael)
-- Create Date : 1/28/2022 9:30:08 AM

WowSimsExporter = LibStub("AceAddon-3.0"):NewAddon("WowSimsExporter", "AceConsole-3.0", "AceEvent-3.0")


WowSimsExporter.Character = ""
WowSimsExporter.Link = "https://wowsims.github.io/tbc/"

local AceGUI = LibStub("AceGUI-3.0")
local LibParse = LibStub("LibParse")

local version = "1.3 (ALPHA)"

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


function WowSimsExporter:CreateCharacterStructure(unit)
    local name, realm = UnitFullName(unit)
    local locClass, engClass, locRace, engRace, gender, name, server = GetPlayerInfoByGUID(UnitGUID(unit))
    local level = UnitLevel(unit)

    self.Character = {
        name = name,
        realm = realm,
        race = engRace,
        class = engClass,
		level = tonumber(level),
        talents = "",
		spec  ="",
        gear = { items = {}} 
	}

    return self.Character
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

--{comparator = function(A,B,C) return A > B and A > C end, spec="affliction", class="warlock"},
function WowSimsExporter:CheckCharacterSpec(class)

	local class = class:lower()

	local specs = self.specializations

	T1 = GetNumTalents(1)
	T2 = GetNumTalents(2)
	T3 = GetNumTalents(3)

	local spec = class --if something breaks, send the class as the spec

	for i, character in ipairs(specs) do	
		if character then				
			if (character.class == class) then				
				if (character.comparator(T1,T2,T3) and not character.single) then
					spec = character.spec
					break
				elseif (character.single) then				
					spec = character.spec				
				end						
			end
		end
	end
	return spec
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

function WowSimsExporter:CreateCopyDialog(text)

	local frame = AceGUI:Create("Frame")
	frame:SetTitle("WSE Copy Dialog")
    frame:SetStatusText("Use CTRL+C to copy link")
    frame:SetLayout("Flow")
	frame:SetWidth(400)
	frame:SetHeight(100)
	frame:SetCallback(
        "OnClose",
        function(widget)
            AceGUI:Release(widget)
        end
    )

	local editbox = AceGUI:Create("EditBox")
    editbox:SetText(text)
    editbox:SetFullWidth(true)
    editbox:DisableButton(true)

	editbox:SetFocus()
	editbox:HighlightText()
	
	frame:AddChild(editbox)

end

function WowSimsExporter:CreateWindow(generate)

	self:CreateCharacterStructure("player")
	
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
    jsonbox:SetLabel("Copy and paste into the websites importer!")
    jsonbox:SetFullWidth(true)
    jsonbox:SetFullHeight(true)
    jsonbox:DisableButton(true)
   
	local function l_Generate()
		WowSimsExporter.Character = WowSimsExporter:GetGearEnchantGems("player")
		jsonbox:SetText(LibParse:JSONEncode(WowSimsExporter.Character)) 
		jsonbox:HighlightText()
		jsonbox:SetFocus()

		frame:SetStatusText("Data Generated!")
	end


	if generate then l_Generate() end

    local button = AceGUI:Create("Button")
    button:SetText("Generate Data")
    button:SetWidth(200)
	button:SetCallback("OnClick", function()		
		l_Generate()
	end)
	
	
	local link = WowSimsExporter.Link..(WowSimsExporter.Character.class:lower()).."/?debug"

    local label = AceGUI:Create("Label")
	label:SetFullWidth(true)
    label:SetText([[!THIS ADDON IS IN AN ALPHA STATE!
As this is in a testing phase, the import button his hidden from the website to avoid issues with users not knowing where the addon is!

To find the import button you can see it by going to any of the sims and adding ?debug to the URL. If there is a # in the URL the ?debug has to come first.

This will add a import button to the top right of the page to the right of the report a feature button.

]])

	
	local label2 = AceGUI:Create("InteractiveLabel")
	label2:SetText("Click to copy: "..link.."\r\n")
	label2:SetFullWidth(true)
	label2:SetCallback("OnClick", function()		
		WowSimsExporter:CreateCopyDialog(link)
	end)

	frame:AddChild(label)
	frame:AddChild(label2)
    frame:AddChild(button)
	frame:AddChild(jsonbox)
end

function WowSimsExporter:GetGearEnchantGems(type)
    local gear = {}

	local slotNames = WowSimsExporter.slotNames

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
	self.Character.spec = self:CheckCharacterSpec(self.Character.class)
	self.Character.talents = self:CreateTalentEntry()
	self.Character.gear.items = gear

    return self.Character
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
