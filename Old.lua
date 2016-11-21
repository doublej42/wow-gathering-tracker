local gatherTrackerObj = {};

local GatheringTracker = CreateFrame("Frame","GatheringTracker",UIParent);
GatheringTracker:ClearAllPoints();
GatheringTracker:SetPoint("CENTER");



GatheringTracker:SetSize(100,100);
GatheringTracker:SetMovable(true);
GatheringTracker:EnableMouse(true);

GatheringTracker:SetBackdrop ({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    --bgFile = "Interface/Artifacts/ArtifactUIPriest",
    --tile = true, 
    --tileSize = 16,
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
    });
GatheringTracker:SetBackdropColor(0,0,0,0.5);
GatheringTracker:SetScript("OnMouseDown", function(self, button)
  print(button);
  if button == "LeftButton" and not self.isMoving then
   self:StartMoving();
   self.isMoving = true;
  end
end)
GatheringTracker:SetScript("OnMouseUp", function(self, button)
  print(button);
  if button == "LeftButton" and self.isMoving then
   self:StopMovingOrSizing();
   self.isMoving = false;
  end
end)

GatheringTracker:SetScript("OnHide", function(self)
  print(button);
  if ( self.isMoving ) then
   self:StopMovingOrSizing();
   self.isMoving = false;
  end
end)


GatheringTracker:Show();

GatheringTracker:RegisterEvent("ADDON_LOADED");
GatheringTracker:RegisterEvent("PLAYER_LOGIN");
GatheringTracker:RegisterEvent("ITEM_PUSH")





GatheringTracker:SetScript("OnEvent",
function(self,event,...) 
	if gatherTrackerObj[event] and type(gatherTrackerObj[event]) == "function" then
        print(event);
		return gatherTrackerObj[event](gatherTrackerObj,...);
	end
end)

--This will fire everytime an item is added to a bag except when it is a buyback andpossibly other cases. Gathering can be done via a spell cast (traditional gathering) or a mob that spawns on gathering that you kill to get the loot (ie withered with starlight rose and foxes with foxflower)
function gatherTrackerObj:BAG_UPDATE(bag)
    print(bag);
end

function gatherTrackerObj:ADDON_LOADED(...)
	local addon = ...;
    if addon == "GatheringTracker" then
        print("Scanning Bags");
        self:scanBags
        
	end -- end if
end



function gatherTrackerObj:PLAYER_LOGIN(...)
	
end



local function scanBags()

	local bagItems = {}
	local itemsAndCounts = {}
	
	scanBag(BACKPACK_CONTAINER, false, bagItems, itemsAndCounts) -- backpack
	for bagId = 1, NUM_BAG_SLOTS do
		scanBag(bagId, false, bagItems, itemsAndCounts)
	end
	
	Amr.db.char.BagItems = bagItems
	Amr.db.char.BagItemsAndCounts = itemsAndCounts
end

local function scanBag(bagId, isBank, bagTable, bagItemsWithCount)
	local numSlots = GetContainerNumSlots(bagId)
	for slotId = 1, numSlots do
		local _, itemCount, _, _, _, _, itemLink = GetContainerItemInfo(bagId, slotId)
		if itemLink ~= nil then
			local itemData = Amr.Serializer.ParseItemLink(itemLink)
			if itemData ~= nil then
			
				-- only add equippable items to bag data
				--if IsEquippableItem(itemLink) or Amr.SetTokenIds[itemData.id] then
	                if isBank then
                    	_lastBankBagId = bagId
                    	_lastBankSlotId = slotId
                	end
										
                	table.insert(bagTable, itemLink)
                --end
				
				-- all items and counts, used for e.g. shopping list and reagents, etc.
                if bagItemsWithCount then
                	if bagItemsWithCount[itemData.id] then
                		bagItemsWithCount[itemData.id] = bagItemsWithCount[itemData.id] + itemCount
                	else
                		bagItemsWithCount[itemData.id] = itemCount
                	end
                end
            end
		end
	end
end


local function scanBank()

	local bankItems = {}
	local itemsAndCounts = {}

	scanBag(BANK_CONTAINER, true, bankItems, itemsAndCounts)
	scanBag(REAGENTBANK_CONTAINER, true, bankItems, itemsAndCounts)
	for bagId = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
		scanBag(bagId, true, bankItems, itemsAndCounts)
	end
	
	-- see if the scan completed before the window closed, otherwise we don't overwrite with partial data
	if _lastBankBagId ~= nil then
		local itemLink = GetContainerItemLink(_lastBankBagId, _lastBankSlotId)
		if itemLink ~= nil then --still open
            Amr.db.char.BankItems = bankItems
            Amr.db.char.BankItemsAndCounts = itemsAndCounts
		end
	end

end