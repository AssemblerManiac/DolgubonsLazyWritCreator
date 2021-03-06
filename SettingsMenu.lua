-----------------------------------------------------------------------------------
-- Addon Name: Dolgubon's Lazy Writ Crafter
-- Creator: Dolgubon (Joseph Heinzle)
-- Addon Ideal: Simplifies Crafting Writs as much as possible
-- Addon Creation Date: March 14, 2016
--
-- File Name: SettingsMenu.lua
-- File Description: Contains the information for the settings menu
-- Load Order Requirements: None (April, after language files)
-- 
-----------------------------------------------------------------------------------

local checks = {}
local validLanguages = 
{
	["en"]=true,["de"] = true,["fr"] = true,["jp"] = true, ["ru"] = false, ["zh"] = false, ["pl"] = false,
}
if true then
	EVENT_MANAGER:RegisterForEvent("WritCrafterLocalizationError", EVENT_PLAYER_ACTIVATED, function()
		if not WritCreater.languageInfo then 
			local language = GetCVar("language.2")
			if validLanguages[language] == nil then
				d("Dolgubon's Lazy Writ Crafter: Your language is not supported for this addon. If you are looking to translate the addon, check the lang/en.lua file for more instructions.")
			elseif validLanguages[language] == false then
				d("Dolgubon's Lazy Writ Crafter: The Localization file could not be loaded.")
				d("Troubleshooting:")
				d("1. Your language is supported by a patch for the Writ Crafter. Please make sure you have downloaded the appropriate patch")
				d("2. Uninstall and then reinstall the Writ Crafter, and the patch")
				d("3. If you still have issues, contact the author of the patch")
			else
				d("Dolgubon's Lazy Writ Crafter: The Localization file could not be loaded.")
				d("Troubleshooting:")
				d("1. Try to uninstall and then reinstall the addon")
				d("2. If the error persists, contact @Dolgubon in-game or at tinyurl.com/WritCrafter")
			end
		end
		EVENT_MANAGER:UnregisterForEvent("WritCrafterLocalizationError", EVENT_PLAYER_ACTIVATED)
	end)
end


WritCreater.styleNames = {}

for i = 1, GetNumValidItemStyles() do

	local styleItemIndex = GetValidItemStyleId(i)
	local  itemName = GetItemStyleName(styleItemIndex)
	local styleItem = GetSmithingStyleItemInfo(styleItemIndex)
	if styleItemIndex ~=36 then
		table.insert(WritCreater.styleNames,{styleItemIndex,itemName, styleItem})
	end
end

function WritCreater:GetSettings()
	if self.savedVars.useCharacterSettings then
		return self.savedVars
	else
		return self.savedVarsAccountWide.accountWideProfile
	end
end

--[[{
			type = "dropbox",
			name = "Autoloot Behaviour",
			tooltip = "Choose when the addon will autoloot writ reward containers",
			choices = {"Copy the", "Autoloot", "Never Autoloot"},
			choicesValues = {1,2,3},
			getFunc = function() if WritCreater:GetSettings().ignoreAuto then return 1 elseif WritCreater:GetSettings().autoLoot then return 2 else return 3 end end,
			setFunc = function(value) 
				if value == 1 then 
					WritCreater:GetSettings().ignoreAuto = false
				elseif value == 2 then  
					WritCreater:GetSettings().autoLoot = true
					WritCreater:GetSettings().ignoreAuto = true
				elseif value == 3 then
					WritCreater:GetSettings().ignoreAuto = true
					WritCreater:GetSettings().autoLoot = false
				end
			end,
		},]]

local function mypairs(tableIn)
	local t = {}
	for k,v in pairs(tableIn) do
		t[#t + 1] = {k,v}
	end
	table.sort(t, function(a,b) return a[1]<b[1] end)

	return t
end

local optionStrings = WritCreater.optionStrings
local function styleCompiler()
	local submenuTable = {}
	local styleNames = WritCreater.styleNames
	for k,v in ipairs(styleNames) do

		local option = {
			type = "checkbox",
			name = zo_strformat("<<1>>", v[2]),
			tooltip = optionStrings["style tooltip"](v[2], v[3]),
			getFunc = function() return WritCreater:GetSettings().styles[v[1]] end,
			setFunc = function(value)
				WritCreater:GetSettings().styles[v[1]] = value  --- DO NOT CHANGE THIS! If you have 'or nil' then the ZO_SavedVars will set it to true.
				end,
		}
		submenuTable[#submenuTable + 1] = option
	end
	local imperial = table.remove(submenuTable, 34)
	table.insert(submenuTable, 10, imperial)
	return submenuTable
end

function WritCreater.Options() --Sentimental

	local function WipeThatFrownOffYourFace(override)
		if WritCreater.alternateUniverse and (override or WritCreater.savedVarsAccountWide.alternateUniverse) then
			local stations, stationNames = WritCreater.alternateUniverse()
			local crafts, craftNames = WritCreater.alternateUniverseCrafts()
			local quests, questNames = WritCreater.alternateUniverseQuests()
			local items, itemNames = WritCreater.alternateUniverseItems()
			local oneOff, oneOffNames = WritCreater.alternateUniverseCoffers()
			local function setupReplacement(object, functionName, positionOfText, types, stationOrNot, case, x)
				local usingOld, usingNames
				if stationOrNot==nil then
					usingOld, usingNames = stations, stationNames
				elseif stationOrNot == 1 then
					usingOld, usingNames = crafts, craftNames
				elseif stationOrNot == 2 then
					usingOld, usingNames = quests, questNames
				elseif stationOrNot == 3 then
					usingOld, usingNames = items, itemNames
				elseif stationOrNot == 4 then
					usingOld, usingNames = oneOff, oneOffNames
				end

				local stationsToCheck = {}
				if types then
					stationsToCheck = usingOld
				else
					for i = 1, #types do 
						stationsToCheck[types] = usingOld[types]
					end
				end
				local original = object[functionName]
				object[functionName] = function(self, ...)
					local parameters = {...}
					if x then d(parameters) end
					local text = parameters[positionOfText]
					if positionOfText == 0 then text = self end
					if type(text )~="string" then original(self, ...) return end
					for i, stationOriginalName in pairs(stationsToCheck) do 
						if case =="u" then d(text, string.upper(usingOld[i]) ) d(string.find(text, usingOld[i]) or (case == "u" and string.find(text, string.upper(usingOld[i]) ))) end
						if string.find(text, usingOld[i]) or (case == "u" and string.find(text, string.upper(usingOld[i]) )) then
							local newText = string.gsub(text, usingOld[i], usingNames[i] or text or "")
							parameters[positionOfText] = newText
							if positionOfText == 0 then self = newText end
							if case== "u" then
								local newText = string.gsub(text, string.upper(usingOld[i]), string.upper(usingNames[i]) or text or "")
								parameters[positionOfText] = newText
								if positionOfText == 0 then self = newText end
							end
							return original(self, unpack(parameters))
						end
					end
					return original(self, ...)
				end
			end
			local function interceptReplacement(object, functionName, positionOfText, types, stationOrNot)
				local usingOld, usingNames
				if stationOrNot==nil then
					usingOld, usingNames = stations, stationNames
				elseif stationOrNot == 1 then
					usingOld, usingNames = crafts, craftNames
				elseif stationOrNot == 2 then
					usingOld, usingNames = quests, questNames
				elseif stationOrNot == 3 then
					usingOld, usingNames = items, itemNames
				elseif stationOrNot == 4 then
					usingOld, usingNames = oneOff, oneOffNames
				end
				local stationsToCheck = {}
				if types then
					stationsToCheck = usingOld
				else
					for i = 1, #types do 
						stationsToCheck[types] = usingOld[types]
					end
				end
				local original = object[functionName]
				object[functionName] = function(self, ...)
					local results = {original(self, ...)}
					local text = results[positionOfText]
					if type(text )~="string" then return unpack(results) end
					for i, stationOriginalName in pairs(stationsToCheck) do 
						if string.find(text, usingOld[i]) then
							local newText = string.gsub(text, usingOld[i], usingNames[i] or text or "")
							results[positionOfText] = newText
							return unpack(results)
						end
					end
					return unpack(results)
				end
			end

			interceptReplacement(_G, "GetJournalQuestInfo",2,true, 3)
			interceptReplacement(_G, "GetItemLinkName",1,true, 4)
			
			-- interceptReplacement(LOOT_HISTORY_KEYBOARD, "InsertOrQueue", 1, true, 4)

			local original = LOOT_HISTORY_KEYBOARD.InsertOrQueue
			LOOT_HISTORY_KEYBOARD.InsertOrQueue = function(self, newEntry) 
				for k, v in pairs(newEntry.lines) do
					local text = v.text
					if type(text )~="string" then return original(self, newEntry)  end
					for i, stationOriginalName in pairs(oneOff) do 
						if string.find(text, oneOff[i]) then
							local newText = string.gsub(text, oneOff[i], oneOffNames[i] or text or "")
							v.text = newText
							return original(self, newEntry)
						end
					end
					return original(self, newEntry)
				end
			end

			local original = ZO_PlayerInventoryList.dataTypes[1].pool.AcquireObject
			ZO_PlayerInventoryList.dataTypes[1].pool.AcquireObject = function (...) 
				local c,b = original(...)
				abctestwrit = c
				local label  = c:GetNamedChild("Name")
				if not label.isAlternatedUniverse and label.SetText then
					label.isAlternatedUniverse = true

					setupReplacement(label, "SetText",1,true,4)
					label:SetText(label:GetText())
				end
				return c,b
			end

			-- The quest labels in the journal

			local o = QUEST_JOURNAL_KEYBOARD.navigationTree.AddNode
			QUEST_JOURNAL_KEYBOARD.navigationTree.AddNode = function (...) 
				local c,b = o(...)
				local label  = c:GetControl()
				if not label.isAlternatedUniverse and label.SetText then
					label.isAlternatedUniverse = true

					setupReplacement(label, "SetText",1,true,2)
					label:SetText(label:GetText())
				end
				return c,b
			end
			-- ZO_CraftBagTabsActive
			setupReplacement(ZO_CraftBagTabsActive, "SetText",1,true,1)
			for j = 3, 9 do 
				local text = ZO_CraftBagTabs:GetNamedChild("Button"..j).m_object.m_buttonData.tooltipText
				if type(text )=="string" then 
					for i, stationOriginalName in pairs(crafts) do 
						if string.find(text, crafts[i]) then
							local newText = string.gsub(text, crafts[i], craftNames[i] or text or "")
							ZO_CraftBagTabs:GetNamedChild("Button"..j).m_object.m_buttonData.tooltipText = newText
						end
					end
				end
			end

			QUEST_JOURNAL_KEYBOARD:RefreshQuestMasterList()
			QUEST_JOURNAL_KEYBOARD:RefreshQuestList()
			-- Refresh so the changes appear

			setupReplacement(ZO_CenterScreenAnnounce_GetEventHandlers(), EVENT_QUEST_ADDED,1,true,2)
			setupReplacement(ZO_CenterScreenAnnounce_GetEventHandlers(), EVENT_QUEST_COMPLETE,0,true,2)
			setupReplacement(ZO_LootTitle, "SetText",1,true,4)

			setupReplacement(ZO_AlchemyTopLevelSkillInfoName,"SetText", 2, true, 1,"u")

			setupReplacement(ZO_ProvisionerTopLevelSkillInfoName,"SetText", 2, true, 1,"u")

			setupReplacement(ZO_EnchantingTopLevelSkillInfoName,"SetText", 2, true, 1,"u")
			EVENT_MANAGER:RegisterForEvent("AlternateUniversalCraftStudios",EVENT_PLAYER_ACTIVATED,function()
			ZO_Skills_TieSkillInfoHeaderToCraftingSkill(ENCHANTING.control:GetNamedChild("SkillInfo"),CRAFTING_TYPE_ENCHANTING)
			ZO_Skills_TieSkillInfoHeaderToCraftingSkill(ALCHEMY.control:GetNamedChild("SkillInfo"),CRAFTING_TYPE_ALCHEMY)
			ZO_Skills_TieSkillInfoHeaderToCraftingSkill(PROVISIONER.control:GetNamedChild("SkillInfo"),CRAFTING_TYPE_PROVISIONING) 
			setupReplacement(ZO_FocusedQuestTrackerPanelContainerQuestContainerTrackedHeader1,"SetText", 1, true, 2)
			ZO_FocusedQuestTrackerPanelContainerQuestContainerTrackedHeader1:SetText(ZO_FocusedQuestTrackerPanelContainerQuestContainerTrackedHeader1:GetText())

			end , 1000)

			interceptReplacement(_G, "GetSkillLineInfo", 1, true, 1)
			interceptReplacement(ZO_SkillLineData,"GetFormattedNameWithNumPointsAllocated", 1, true, 1)
			interceptReplacement(ZO_SkillLineData,"GetFormattedName", 1, true, 1)
			for i = 1, 10 do 
				setupReplacement(GetControl("ZO_ChatterOption",i), "SetText",1, true, 2)
			end
			

			-- unstuck yourself prompts do use the string overwrite functions
			SafeAddString(SI_CUSTOMER_SERVICE_UNSTUCK_COST_PROMPT,string.gsub(GetString(SI_CUSTOMER_SERVICE_UNSTUCK_COST_PROMPT_TELVAR), stations[9], stationNames[9]), 2)
			SafeAddString(SI_CUSTOMER_SERVICE_UNSTUCK_COST_PROMPT_TELVAR, string.gsub(GetString(SI_CUSTOMER_SERVICE_UNSTUCK_COST_PROMPT_TELVAR), stations[9], stationNames[9]), 2)

			setupReplacement(ZO_ReticleContainerInteractContext, "SetText", 1, true) -- reticle
			setupReplacement(ZO_ReticleContainerInteractContext, "SetText", 1, true,2) -- reticle, but for writ turnin
			setupReplacement(ZO_InteractWindowTargetAreaTitle, "SetText", 1, true,2) -- turnin titles
			setupReplacement(ZO_InteractWindowTargetAreaBodyText, "SetText", 1, true,2) -- turnin text of body
			setupReplacement(ZO_InteractWindowTargetAreaBodyText, "SetText", 1, true,1) -- turnin text of body

			local original = INTERACTION.givenRewardPool.AcquireObject
			INTERACTION.givenRewardPool.AcquireObject = function(...) 
				local c,b = original(...)
				if not c.isAlternatedUniverse then
					c.isAlternatedUniverse = true
					setupReplacement(c:GetNamedChild("Name"), "SetText",1,true,4)
				end
				return c,b
			end			

			setupReplacement(InformationTooltip, "AddLine", 1, true) -- tooltips
			setupReplacement(ZO_CompassCenterOverPinLabel, "SetText", 1, {9}) -- compass words
			setupReplacement(ZO_Dialog1Text, "SetText", 1, {9}) -- dialog porting box
			setupReplacement(_G, "ZO_Alert", 2, {9}) -- location change notification (top right of screen)
			setupReplacement(ZO_DeathReleaseOnlyButton1NameLabel, "SetText", 1, {9}) -- when you only have one port option on death
			setupReplacement(ZO_DeathTwoOptionButton2NameLabel, "SetText", 1, {9}) -- when you can revive here or go to wayshrine
			local original = ZO_MapLocationTooltip.labelPool.AcquireObject
			ZO_MapLocationTooltip.labelPool.AcquireObject = function(...) 
				local control,b = original(...)
				if not control.hasAprilStarted then 
					control.hasAprilStarted = true 
					setupReplacement(control, "SetText", 1, true)
				end
				return control,b
			end
			-- Someone Else's Bank
			-- Bank of Hoarding

			-- checkboxes to show wayshrines on map. This one needs to be delayed because the map is not initialized at first
			local runOnce = {}
			SCENE_MANAGER.scenes['worldMap']:RegisterCallback("StateChange", function(old, new) 
				if new ~= "shown" then return end
				if not runOnce['worldMap'] then 
					runOnce['worldMap'] = true
					setupReplacement(ZO_WorldMapFiltersPvECheckBox2Label, "SetText", 1, {9})
					ZO_WorldMapFiltersPvECheckBox2Label:SetText(ZO_WorldMapFiltersPvECheckBox2Label:GetText()) 
				end  
			end)
		end
	end
	WipeThatFrownOffYourFace(GetDisplayName()=="@Dolgubon")
	local g = getmetatable(WritCreater) or {}
	g.__index = g.__index or {}
	g.__index.WipeThatFrownOffYourFace = WipeThatFrownOffYourFace
	g.__metatable = "Only Sheogorath Certified Cheese Enthusiasts are allowed to see this table!"
	
	local options =  {
		{
			type = "header",
			name = function() 
				local profile = WritCreater.optionStrings.accountWide
				if WritCreater.savedVars.useCharacterSettings then
					profile = WritCreater.optionStrings.characterSpecific
				end
				return  string.format(WritCreater.optionStrings.nowEditing, profile)  
			end, -- or string id or function returning a string
		},

		{
			type = "checkbox",
			name = WritCreater.optionStrings.useCharacterSettings,
			tooltip = WritCreater.optionStrings.useCharacterSettingsTooltip,
			getFunc = function() return WritCreater.savedVars.useCharacterSettings end,
			setFunc = function(value) 
				WritCreater.savedVars.useCharacterSettings = value
			end,
		},
		{
			type = "divider",
			height = 15,
			alpha = 0.5,
			width = "full",
		},
		{
			type = "checkbox",
			name = optionStrings["show craft window"],
			tooltip =WritCreater.optionStrings["show craft window tooltip"],
			getFunc = function() return WritCreater:GetSettings().showWindow end,
			setFunc = function(value) 
				WritCreater:GetSettings().showWindow = value
				if value == false then
					WritCreater:GetSettings().autoCraft = true
				end
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings["autocraft"]  ,
			tooltip = WritCreater.optionStrings["autocraft tooltip"] ,
			getFunc = function() return WritCreater:GetSettings().autoCraft end,
			disabled = function() return not WritCreater:GetSettings().showWindow end,
			setFunc = function(value) 
				WritCreater:GetSettings().autoCraft = value 
			end,
		},
		
		
		{
			type = "checkbox",
			name = WritCreater.optionStrings["master"],--"Master Writs",
			tooltip = WritCreater.optionStrings["master tooltip"],--"Craft Master Writ Items",
			getFunc = function() return WritCreater.savedVarsAccountWide.masterWrits end,
			setFunc = function(value) 
			WritCreater.savedVarsAccountWide.masterWrits = value
			WritCreater.savedVarsAccountWide.rightClick = not value
			WritCreater.LLCInteraction:cancelItem()
				if value  then
					
					for i = 1, 25 do WritCreater.MasterWritsQuestAdded(1, i,GetJournalQuestName(i)) end
				end
				
				
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings["right click to craft"],--"Master Writs",
			tooltip = WritCreater.optionStrings["right click to craft tooltip"],--"Craft Master Writ Items",
			getFunc = function() return WritCreater.savedVarsAccountWide.rightClick end,
			setFunc = function(value) 
			WritCreater.savedVarsAccountWide.masterWrits = not value
			WritCreater.savedVarsAccountWide.rightClick = value
			WritCreater.LLCInteraction:cancelItem()
				if not value  then
					
					for i = 1, 25 do WritCreater.MasterWritsQuestAdded(1, i,GetJournalQuestName(i)) end
				end
			end,
		},
			
	}
----------------------------------------------------
----- TIMESAVERS SUBMENU

	local timesaverOptions =
	{
		{
			type = "checkbox",
			name = WritCreater.optionStrings["automatic complete"],
			tooltip = WritCreater.optionStrings["automatic complete tooltip"],
			getFunc = function() return WritCreater:GetSettings().autoAccept end,
			setFunc = function(value) WritCreater:GetSettings().autoAccept = value end,
		},		
		{
			type = "checkbox",
			name = WritCreater.optionStrings["exit when done"],
			tooltip = WritCreater.optionStrings["exit when done tooltip"],
			getFunc = function() return WritCreater:GetSettings().exitWhenDone end,
			setFunc = function(value) WritCreater:GetSettings().exitWhenDone = value end,
		},
		{
			type = "dropdown",
			name = WritCreater.optionStrings["autoloot behaviour"]	,
			tooltip = WritCreater.optionStrings["autoloot behaviour tooltip"],
			choices = WritCreater.optionStrings["autoloot behaviour choices"],
			choicesValues = {1,2,3},
			getFunc = function() if not WritCreater:GetSettings().ignoreAuto then return 1 elseif WritCreater:GetSettings().autoLoot then return 2 else return 3 end end,
			setFunc = function(value) 
				if value == 1 then 
					WritCreater:GetSettings().ignoreAuto = false
				elseif value == 2 then  
					WritCreater:GetSettings().autoLoot = true
					WritCreater:GetSettings().ignoreAuto = true
				elseif value == 3 then
					WritCreater:GetSettings().ignoreAuto = true
					WritCreater:GetSettings().autoLoot = false
				end
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings["new container"],
			tooltip = WritCreater.optionStrings["new container tooltip"],
			getFunc = function() return WritCreater:GetSettings().keepNewContainer end,
			setFunc = function(value) 
			WritCreater:GetSettings().keepNewContainer = value			
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings["loot container"],
			tooltip = WritCreater.optionStrings["loot container tooltip"],
			getFunc = function() return WritCreater:GetSettings().lootContainerOnReceipt end,
			setFunc = function(value) 
			WritCreater:GetSettings().lootContainerOnReceipt = value					
			end,
		},
		--[[{
			type = "slider",
			name = WritCreater.optionStrings["container delay"],
			tooltip = WritCreater.optionStrings["container delay tooltip"]    ,
			min = 0,
			max = 5,
			getFunc = function() return WritCreater:GetSettings().containerDelay end,
			setFunc = function(value)
			WritCreater:GetSettings().containerDelay = value
			end,
			disabled = function() return not WritCreater:GetSettings().lootContainerOnReceipt end,
		  },--]]
		{
			type = "checkbox",
			name = WritCreater.optionStrings["master writ saver"],
			tooltip = WritCreater.optionStrings["master writ saver tooltip"],
			getFunc = function() return WritCreater:GetSettings().preventMasterWritAccept end,
			setFunc = function(value) 
			WritCreater:GetSettings().preventMasterWritAccept = value					
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings["loot output"],--"Master Writs",
			tooltip = WritCreater.optionStrings["loot output tooltip"],--"Craft Master Writ Items",
			getFunc = function() return WritCreater:GetSettings().lootOutput end,
			setFunc = function(value) 
			WritCreater:GetSettings().lootOutput = value					
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings['reticleColour'],--"Master Writs",
			tooltip = WritCreater.optionStrings['reticleColourTooltip'],--"Craft Master Writ Items",
			getFunc = function() return  WritCreater:GetSettings().changeReticle end,
			setFunc = function(value) 
				WritCreater:GetSettings().changeReticle = value
			end,
		},
		{
			type = "checkbox",
			name = WritCreater.optionStrings['autoCloseBank'],
			tooltip = WritCreater.optionStrings['autoCloseBankTooltip'],
			getFunc = function() return  WritCreater:GetSettings().autoCloseBank end,
			setFunc = function(value) 
				WritCreater:GetSettings().autoCloseBank = value
			end,
		},
		
	}
	
----------------------------------------------------
----- CRAFTING SUBMENU

	local craftSubmenu = {{
		type = "checkbox",
		name = WritCreater.optionStrings["blackmithing"]   ,
		tooltip = WritCreater.optionStrings["blacksmithing tooltip"] ,
		getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_BLACKSMITHING] end,
		setFunc = function(value) 
			WritCreater:GetSettings()[CRAFTING_TYPE_BLACKSMITHING] = value 
		end,
	},
	{
		type = "checkbox",
		name = WritCreater.optionStrings["clothing"]  ,
		tooltip = WritCreater.optionStrings["clothing tooltip"] ,
		getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_CLOTHIER] end,
		setFunc = function(value) 
			WritCreater:GetSettings()[CRAFTING_TYPE_CLOTHIER] = value 
		end,
	},
	{
	  type = "checkbox",
	  name = WritCreater.optionStrings["woodworking"]    ,
	  tooltip = WritCreater.optionStrings["woodworking tooltip"],
	  getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_WOODWORKING] end,
	  setFunc = function(value) 
		WritCreater:GetSettings()[CRAFTING_TYPE_WOODWORKING] = value 
	  end,
	},
	{
	  type = "checkbox",
	  name = WritCreater.optionStrings["jewelry crafting"]    ,
	  tooltip = WritCreater.optionStrings["jewelry crafting tooltip"],
	  getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_JEWELRYCRAFTING] end,
	  setFunc = function(value) 
		WritCreater:GetSettings()[CRAFTING_TYPE_JEWELRYCRAFTING] = value 
	  end,
	},

	{
		type = "checkbox",
		name = WritCreater.optionStrings["enchanting"],
		tooltip = WritCreater.optionStrings["enchanting tooltip"]  ,
		getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_ENCHANTING] end,
		setFunc = function(value) 
			WritCreater:GetSettings()[CRAFTING_TYPE_ENCHANTING] = value 
		end,
	},
	{
		type = "checkbox",
		name = WritCreater.optionStrings["provisioning"],
		tooltip = WritCreater.optionStrings["provisioning tooltip"]  ,
		getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_PROVISIONING] end,
		setFunc = function(value) 
			WritCreater:GetSettings()[CRAFTING_TYPE_PROVISIONING] = value 
		end,
	},
	{
		type = "checkbox",
		name = WritCreater.optionStrings["alchemy"],
		tooltip = WritCreater.optionStrings["alchemy tooltip"]  ,
		getFunc = function() return WritCreater:GetSettings()[CRAFTING_TYPE_ALCHEMY] end,
		setFunc = function(value) 
			WritCreater:GetSettings()[CRAFTING_TYPE_ALCHEMY] = value 
		end,
	},}

  if WritCreater.lang ~="jp" then
  table.insert(options, {
	type = "checkbox",
	name = WritCreater.optionStrings["writ grabbing"] ,
	tooltip = WritCreater.optionStrings["writ grabbing tooltip"] ,
	getFunc = function() return WritCreater:GetSettings().shouldGrab end,
	setFunc = function(value) WritCreater:GetSettings().shouldGrab = value end,
  })
  --[[table.insert(options,{
	type = "slider",
	name = WritCreater.optionStrings["delay"],
	tooltip = WritCreater.optionStrings["delay tooltip"]    ,
	min = 10,
	max = 2000,
	getFunc = function() return WritCreater:GetSettings().delay end,
	setFunc = function(value)
	WritCreater:GetSettings().delay = value
	end,
	disabled = function() return not WritCreater:GetSettings().shouldGrab end,
  })]]
  end

	if false --[[GetWorldName() == "NA Megaserver" and WritCreater.lang =="en" ]] then
	  table.insert(options,8, {
	  type = "checkbox",
	  name = WritCreater.optionStrings["send data"],
	  tooltip =WritCreater.optionStrings["send data tooltip"] ,
	  getFunc = function() return WritCreater.savedVarsAccountWide.sendData end,
	  setFunc = function(value) WritCreater.savedVarsAccountWide.sendData = value  end,
	}) 
	end
	table.insert(options,{
	  type = "submenu",
	  name = WritCreater.optionStrings["timesavers submenu"],
	  tooltip = WritCreater.optionStrings["timesavers submenu tooltip"],
	  controls = timesaverOptions,
	  reference = "WritCreaterTimesaverSubmenu",
	})
	table.insert(options,{
	  type = "submenu",
	  name =WritCreater.optionStrings["style stone menu"],
	  tooltip = WritCreater.optionStrings["style stone menu tooltip"]  ,
	  controls = styleCompiler(),
	  reference = "WritCreaterStyleSubmenu",
	})

	table.insert(options,{
	  type = "submenu",
	  name = WritCreater.optionStrings["crafting submenu"],
	  tooltip = WritCreater.optionStrings["crafting submenu tooltip"],
	  controls = craftSubmenu,
	  reference = "WritCreaterMasterWritSubMenu",
	})
	if WritCreater.alternateUniverse then
		table.insert(options,1, {
				type = "checkbox",
				name = WritCreater.optionStrings["alternate universe"],
				tooltip =WritCreater.optionStrings["alternate universe tooltip"] ,
				getFunc = function() return WritCreater.savedVarsAccountWide.alternateUniverse end,
				setFunc = function(value) 
					WritCreater.savedVarsAccountWide.alternateUniverse = value 
					WritCreater.savedVarsAccountWide.completeImmunity = not value end,
				
			})
	end

	return options
end
