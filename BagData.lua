
--bagdata
BagData = {} 

function BagData:new(o, console, database)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.console = console
    self.database = database
    if (self.database == nil) then
        self.database = {}
    end
    --if (not self.database.changes) then
        self.database.changes = {}
    --end
        if (not self.database.itemData) then
        self.database.itemData = {}
    end
    if (not self.database.bag) then
        self.database.bag = {}
    end 
    return o
end


function BagData:Test()
    self.console:Print("basedata test called")
end

function BagData:Reset()
    self.database.bag = {}
    self.database.changes = {}
    self.database.itemData = {}
end



function BagData:InitBag(bagId,slotId)
    if (not self.database.bag[tostring(bagId)]) then
    self.console:Print("Initializing bag "..bagId)
        self.database.bag[tostring(bagId)] = {}
    end
    if (not self.database.bag[tostring(bagId)][tostring(slotId)]) then
    self.console:Print("Initializing bag "..bagId .." slot id : "..slotId)
        self.database.bag[tostring(bagId)][tostring(slotId)] = {}
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

function BagData:UpdateItem(bagId,slotId,itemNumber,itemCount)
    --self.console:Print("Updating item number:"..itemNumber.." to "..itemCount.." in bag "..bagId.." slot "..slotId)
    self:InitBag(bagId,slotId)
    --[[
    if (not self.database.bag[tostring(bagId)][tostring(slotId)]) then
        self.console:Print("Was "..self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber.." to "..self.database.bag[tostring(bagId)][tostring(slotId)]["itemCount"].." in bag "..bagId.." slot "..slotId)
    else
        self.console:Print("Was empty in bag "..bagId.." slot "..slotId)
    end
     ]]
    --self.console.Print(itemNumber)
    if (self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber ~= itemNumber) then -- item in slot changed
        self.console:Print("An item in bag id "..bagId.." slot "..slotId.." was ".." is now "..itemNumber)
        
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
    if (self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber ~= itemNumber) then
        self.console:Print("MAJOR ERROR")
    end
    self.database.bag[tostring(bagId)][tostring(slotId)].itemCount = itemCount
    --self.console:Print("Became "..self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber.." to "..self.database.bag[tostring(bagId)][tostring(slotId)].itemCount.." in bag "..bagId.." slot "..slotId)
end -- end UpdateItem


function BagData:ClearItem(bagId,slotId)
    self:InitBag(bagId,slotId)
    if (self.database.bag[tostring(bagId)][tostring(slotId)] == nil) then
        return -- already blank
    end
    local oldItemNumber = self.database.bag[tostring(bagId)][tostring(slotId)].itemNumber
    if (oldItemNumber ~= nil) then -- slot was not empty before
        --self.console:Print("removing stack of " .. oldItemNumber)
        self:SubtractItem(oldItemNumber,self.database.bag[tostring(bagId)][tostring(slotId)].itemCount)
        self.database.bag[tostring(bagId)][tostring(slotId)] = nil;
        --self.console:Print(oldItemNumber.."*"..self.database.changes[oldItemNumber])
    end -- end empty slot
end

function BagData:AddItem(itemNumber,itemCount)
    --self.console:Print("Adding "..itemCount.." of "..itemNumber)
    self.database.changes[tostring(itemNumber)] = self:ToZero(self.database.changes[itemNumber]) + itemCount
    --self.console:Print("AddItem changes: ".. #self.database.changes)
end -- SubtractItem

function BagData:SubtractItem(itemNumber,itemCount)
    self:AddItem(itemNumber,itemCount * -1)
end -- SubtractItem

function BagData:LogChanges()
    --self.console:Print("LogChanges : ".. #self.database.changes)
    for key,value in pairs(self.database.changes) do
        if (value ~= 0) then
            DEFAULT_CHAT_FRAME:AddMessage(self.database.itemData[key].itemLink.."x|cFF00FF00"..value.."|r")
        end
    end
    --self.console:Print("DONE LogChanges")
end

function BagData:ClearChanges()
    self.database.changes = {}
end

function BagData:ScanBags()
	--for bagId = 0, NUM_BAG_SLOTS do
    for bagId = 0, 1 do
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
   self.console:Print("|cFF00FF00Bag|r"..bagId.." number slots: "..numSlots)
	for slotId = 1, numSlots do
        --self.console:Print("slot:"..slotId)
		local texture, itemCount, _, quality, _, _, itemLink = GetContainerItemInfo(bagId, slotId)
		if itemLink ~= nil then
            local _,_,itemType, itemNumber, itemName = string.find(itemLink,"|%x*|H([^:]*):(%d*):[^|]*|h%[([^%]]*)")
			--self:Print("-------------------------------------------")
            --printable = gsub(itemLink, "|", "||");
            --self:Print(printable)
            --self:Print("ItemType :"..itemType)
            --self:Print("Name:"..itemNumber)
            --self:Print(itemLink.." x"..itemCount)
            --self:Print("texture:"..texture)
            --self:Print("itemCount:"..itemCount)
            --self:Print("quality:"..quality)
            --self:Print("itemLink:"..itemLink)
            if (itemType == "item") then
                if (quality >= 1) then-- ignore poor items (trash)
                    --check the current bag item
                    --self:Print("Calling Bag update")
                    --self.db.char.bagdata:Test()
                    self:ItemDataCache(itemNumber,itemName,texture,itemLink)
                    self:UpdateItem(bagId,slotId,itemNumber,itemCount)
                    --UpdateItem(bagId,slotId,itemName,itemNumber,itemCount,texture)
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


