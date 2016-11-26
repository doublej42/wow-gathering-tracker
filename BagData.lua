
--bagdata
BagData = {} 

function BagData:new (o, console)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.console = console
    --if (not self.changes) then
        self.changes = {}
    --end
        if (not self.itemData) then
        self.itemData = {}
    end
    if (not self.bag) then
        self.bag = {}
    end 
    return o
end


function BagData:Test()
    self.console:Print("basedata test called")
end

function BagData:Reset()
    self.bag = {}
    self.changes = {}
end



function BagData:InitBag(bagId,slotId)
    if (not self.bag[bagId]) then
        self.bag[bagId] = {}
    end
    if (not self.bag[bagId][slotId]) then
        self.bag[bagId][slotId] = {}
    end
end

--stores cached data for later
function BagData:ItemDataCache(itemNumber,itemName,texture,itemLink)
    --self.console:Print("Updating ItemDataCache:"..itemNumber.." itemName "..itemName.." texture "..texture.." itemLink "..itemLink)
    local key = tostring(itemNumber)
    if (self.itemData[key] == nil) then
        self.itemData[key] = {}
    end
    self.itemData[key].itemName = itemName
    self.itemData[key].texture = texture
    self.itemData[key].itemLink = itemLink
end

function BagData:UpdateItem(bagId,slotId,itemNumber,itemCount)
    --self.console:Print("Updating item number:"..itemNumber.." to "..itemCount.." in bag "..bagId.." slot "..slotId)
    self:InitBag(bagId,slotId)
    --[[
    if (not self.bag[bagId][slotId]) then
        self.console:Print("Was "..self.bag[bagId][slotId].itemNumber.." to "..self.bag[bagId][slotId]["itemCount"].." in bag "..bagId.." slot "..slotId)
    else
        self.console:Print("Was empty in bag "..bagId.." slot "..slotId)
    end
     ]]
    if (self.bag[bagId][slotId].itemNumber ~= itemNumber) then -- item in slot changed
        local oldItemNumber = self.bag[bagId][slotId].itemNumber
        if (oldItemNumber ~= nil) then -- slot was not empty before empty it and uncount it's contents first
            self:SubtractItem(oldItemNumber,self.bag[bagId][slotId].itemCount)
        end -- end empty slot
        self:AddItem(itemNumber,itemCount)
    else -- adding more to the stack
        local diff = itemCount - self.bag[bagId][slotId].itemCount
        --self.console:Print(itemCount.."-"..self.bag[bagId][slotId].itemCount.."="..diff)
        self:AddItem(itemNumber,diff)
    end -- end changeB
    --save the new item
    self.bag[bagId][slotId].itemNumber = itemNumber
    self.bag[bagId][slotId].itemCount = itemCount
    --self.console:Print("Became "..self.bag[bagId][slotId].itemNumber.." to "..self.bag[bagId][slotId].itemCount.." in bag "..bagId.." slot "..slotId)
end -- end UpdateItem


function BagData:ClearItem(bagId,slotId)
    self:InitBag(bagId,slotId)
    if (self.bag[bagId][slotId] == nil) then
        return -- already blank
    end
    local oldItemNumber = self.bag[bagId][slotId].itemNumber
    if (oldItemNumber ~= nil) then -- slot was not empty before
        --self.console:Print("removing stack of " .. oldItemNumber)
        self:SubtractItem(oldItemNumber,self.bag[bagId][slotId].itemCount)
        self.bag[bagId][slotId] = nil;
        --self.console:Print(oldItemNumber.."*"..self.changes[oldItemNumber])
    end -- end empty slot
end

function BagData:AddItem(itemNumber,itemCount)
    --self.console:Print("Adding "..itemCount.." of "..itemNumber)
    self.changes[tostring(itemNumber)] = self:ToZero(self.changes[itemNumber]) + itemCount
    --self.console:Print("AddItem changes: ".. #self.changes)
end -- SubtractItem

function BagData:SubtractItem(itemNumber,itemCount)
    self:AddItem(itemNumber,itemCount * -1)
end -- SubtractItem

function BagData:LogChanges()
    --self.console:Print("LogChanges : ".. #self.changes)
    for key,value in pairs(self.changes) do
        if (value ~= 0) then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000You have recieved |r"..self.itemData[key].itemLink.."x|cFF00FF00"..value.."|r")
        end
    end
    self.changes = {}
    --self.console:Print("DONE LogChanges")
end

function BagData:ToZero(value)
    if (value == nil) then 
        return 0
    end
    return value
end
