
--bagdata
BagData = {} 

--[[
function BagData:new(o, console, database)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self:Init(console, database)
    return o
end
]]

function BagData:Init(console, database)
    self.console = console
    self.database = database
    self.changes = {} 
    if (self.database.itemData == nil) then
        self.database.itemData = {}
    end
    --self.console:Print("self.database.bag type "..type(self.database.bag))
    --self.console:Print("GatheringTrackerDBChr.bagdata.bag type "..type(GatheringTrackerDBChr.bagdata.bag))
    --self.console:Print("|cFFFF0000durring z2|r "..self.database.bag["0"]["2"].itemNumber)
    if (self.database.bag == nil) then
        self.console:Print("initing bag")
        self.database.bag = {}
    end 
end

function BagData:Test()
    self.console:Print("basedata test called")
end

--[[
function BagData:Reset()
    self.database.bag = {}
    BagData.changes = {}
    self.database.itemData = {}
end
]]


function BagData:InitBag(bagId,slotId)
    --self.console:Print("|cFFFF0000DR z2|r "..self.database.bag["0"]["2"].itemNumber)
    --self.console:Print("self.database.bag InitBag type "..type(self.database.bag))
    --self.console:Print("|cFFFF0000self.database.bag[id] InitBag type|r "..type(self.database.bag[tostring(bagId)]))
    
    if (self.database.bag[tostring(bagId)] == nil) then
        self.console:Print("Initialize bag "..bagId)
        self.database.bag[tostring(bagId)] = {}
    end
    --self.console:Print("|cFF00FF00self.database.bag[id][tostring(slotId)] InitBag type|r "..type(self.database.bag[tostring(bagId)][tostring(slotId)]))
    if (self.database.bag[tostring(bagId)][tostring(slotId)] == nil) then
        self.console:Print("Initialize bag "..bagId .." slot id : "..slotId)
        self.database.bag[tostring(bagId)][tostring(slotId)] = {}
        self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber = "empty"
        self.database.bag[tostring(bagId)][tostring(slotId)].itemCount = 0
    end
end

--stores cached data for later
function BagData:ItemDataCache(itemNumber,itemName,texture,itemLink)
    --self.console:Print("Updating ItemDataCache:"..itemNumber.." itemName "..itemName.." texture "..texture.." itemLink "..itemLink)
    local key = tostring(itemNumber)
    if (self.database.itemData == nil) then
        self.database.itemData = {}
    end

    if (self.database.itemData[key] == nil) then
        self.database.itemData[key] = {}
    end
    self.database.itemData[key].itemName = itemName
    self.database.itemData[key].texture = texture
    self.database.itemData[key].itemLink = itemLink
end

function BagData:ItemDataCacheAdd(itemNum,itemCount)
    
    self.database.itemData[itemNum].Count = self:ToZero(self.database.itemData[itemNum].Count) + itemCount
    self.console:Print("new count "..self.database.itemData[itemNum].itemLink .." "..self.database.itemData[itemNum].Count)
end

function BagData:UpdateItem(bagId,slotId,itemNumber,itemCount)
    --self.console:Print("Updating item number:"..itemNumber.." to "..itemCount.." in bag "..bagId.." slot "..slotId)
    self:InitBag(bagId,slotId)
    if (self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber ~= itemNumber) then -- item in slot changed
        --self.console:Print("An item in bag id "..bagId.." slot "..slotId.." was ".." is now "..itemNumber)
        
        local oldItemNumber = self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber
        if (oldItemNumber ~= nil) then -- slot was not empty before empty it and uncount it's contents first
            self:SubtractItem(oldItemNumber,self.database.bag[tostring(bagId)][tostring(slotId)].itemCount)
        end -- end empty slot
        self:AddItem(itemNumber,itemCount)
    else -- adding more to the stack
        local diff = itemCount - self.database.bag[tostring(bagId)][tostring(slotId)].itemCount
        --self.console:Print(itemCount.."-"..self.database.bag[tostring(bagId)][tostring(slotId)].itemCount.."="..diff)
        self:AddItem(itemNumber,diff)
    end -- end changeB
    --save the new item
    self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber = itemNumber
    --if (self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber ~= itemNumber) then
        --self.console:Print("MAJOR ERROR")
    --end
    self.database.bag[tostring(bagId)][tostring(slotId)].itemCount = itemCount
    --self.console:Print("Became "..self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber.." to "..self.database.bag[tostring(bagId)][tostring(slotId)].itemCount.." in bag "..bagId.." slot "..slotId)
end -- end UpdateItem


function BagData:ClearItem(bagId,slotId)
    self:InitBag(bagId,slotId)
    if (self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber == "empty") then
        return -- already blank
    end
    local oldItemNumber = self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber
    if (oldItemNumber ~= nil and oldItemNumber ~= "empty") then -- slot was not empty before
        self.console:Print("removing stack of " .. oldItemNumber)
        self:SubtractItem(oldItemNumber,self.database.bag[tostring(bagId)][tostring(slotId)].itemCount)
        self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber = "empty";
        self.database.bag[tostring(bagId)][tostring(slotId)].itemCount = 0;
        --self.console:Print(oldItemNumber.."*"..self.database.changes[oldItemNumber])
    end -- end empty slot
end

function BagData:AddItem(itemNumber,itemCount)
    local itemNum = tostring(itemNumber)
    if (itemCount ~= 0) then
        --self.console:Print("Adding "..itemCount.." of "..itemNumber)
        self.changes[itemNum] = self:ToZero(self.changes[itemNum]) + itemCount
        --self.console:Print("result "..self.changes[tostring(itemNumber)].." of "..itemNumber)
        if (self.changes[itemNum] == 0) then
            --self.console:Print("zero "..self.changes[tostring(itemNumber)].." of "..itemNumber)
            self.changes[itemNum]  = nil
        end
        --update totals
        self:ItemDataCacheAdd(itemNum,itemCount)
    end
end -- AddItem

function BagData:SubtractItem(itemNumber,itemCount)
    self:AddItem(itemNumber,itemCount * -1)
end -- SubtractItem

function BagData:LogChanges()
    --self.console:Print("LogChanges : ".. #self.database.changes)
    for key,value in pairs(self.changes) do
        if (value > 0) then
            DEFAULT_CHAT_FRAME:AddMessage(self.database.itemData[key].itemLink.."|cFF00FF00 gained |r"..value)
        elseif (value < 0) then
            DEFAULT_CHAT_FRAME:AddMessage(self.database.itemData[key].itemLink.."|cFFFF0000 lost |r"..value)
        end
    end
    --self.console:Print("DONE LogChanges")
end

function BagData:ChangesCount()
  local count = 0
  for _ in pairs(self.changes) do count = count + 1 end
  return count
end

function BagData:AnyChanges()
    return (self:ChangesCount() > 0)
end

function BagData:ClearChanges()
  -- self.console:Print("ClearChanges")
   wipe(self.changes)
end

function BagData:ScanBags()
	for bagId = 0, NUM_BAG_SLOTS do
		self:ScanBag(bagId)
	end
end

function BagData:ScanBank()
    local lastBag = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
	self:ScanBag(BANK_CONTAINER)
	self:ScanBag(REAGENTBANK_CONTAINER)
	for bagId = NUM_BAG_SLOTS + 1, lastBag  do
		self:ScanBag(bagId)
	end
	
	-- see if the scan completed before the window closed, otherwise we don't overwrite with partial data
	--[[if _lastBankBagId ~= nil then
		local itemLink = GetContainerItemLink(lastBag,  GetContainerNumSlots(lastBag))
		if itemLink ~= nil then --still open
            Amr.db.char.BankItems = bankItems
            Amr.db.char.BankItemsAndCounts = itemsAndCounts
		end
	end]]

end

function BagData:ScanBag(bagId)
	local numSlots = GetContainerNumSlots(bagId)
    ret = {}
    --self.console:Print("|cFF00FF00Bag|r "..bagId.." number slots: "..numSlots)
	for slotId = 1, numSlots do
        --self.console:Print("slot:"..slotId)
		local texture, itemCount, _, quality, _, _, itemLink = GetContainerItemInfo(bagId, slotId)
		if itemLink ~= nil then
            local _,_,itemType, itemNumber, itemName = string.find(itemLink,"|%x*|H([^:]*):(%d*):[^|]*|h%[([^%]]*)")
            if (itemType == "item") then
                if (quality >= 1) then-- ignore poor items (trash)
                    --check the current bag item
                    self:ItemDataCache(itemNumber,itemName,texture,itemLink)
                    self:UpdateItem(bagId,slotId,itemNumber,itemCount)
                end -- end quality check
            end -- end item type check
        else -- blank spot
            self:ClearItem(bagId,slotId)
		end --end itemLink check
	end
end


function BagData:ToZero(value)
    if (value == nil) then 
        return 0
    end
    return value
end


