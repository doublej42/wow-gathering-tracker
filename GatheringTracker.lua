GatheringTracker = LibStub("AceAddon-3.0"):NewAddon("GatheringTracker", "AceConsole-3.0","AceEvent-3.0")


local options = {
    name = "Gathering Tracker",
    handler = GatheringTracker,
    type = 'group',
    args = {
        Rate = {
            type = 'input',
            name = 'Default time frame in minutes',
            desc = 'Rate is based on how many items will likely be gathered in this many minutes. Defalt is 60 or rate per hour.',
            set = 'SetTimeFrame',
            get = 'GetTimeFrame',
        },
    },
}




function GatheringTracker:OnInitialize()
  -- Code that you want to run when the addon is first loaded goes here.
    self:Print("OnInitialize")
    self.db = LibStub("AceDB-3.0"):New("GatheringTrackerDB")
    options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("GatheringTracker", options, {"gt", "GatheringTracker"})
    GatheringTracker:RegisterEvent("BAG_UPDATE")
    GatheringTracker:RegisterEvent("BAG_UPDATE_DELAYED")
    --GatheringTracker:RegisterEvent("ITEM_PUSH")
     if (self.db.char.bagdata == nil or self.db.char.bagdata.Test == nil) then
        self.db.char.bagdata = BagData:new(self.db.char.bagdata,self)
    end
    self.db.char.bagdata:Reset()
end

function GatheringTracker:OnEnable()
    self:Print("OnEnable")
    --self:Print(GatheringTracker.db.profile.timeFrame)
    if type(GatheringTracker.db.profile.timeFrame) ~= "number" then
        GatheringTracker.db.profile.timeFrame = 60;
    end -- end if
    -- Called when the addon is enabled
end

function GatheringTracker:OnDisable()
    -- Called when the addon is disabled
end

function GatheringTracker:GetTimeFrame(info)
    return self.db.profile.timeFrame
end

function GatheringTracker:SetTimeFrame(info,input)
    --self:Print("Rate now set to items per "..input.." minutes.")
    self.db.profile.timeFrame = input
end


function GatheringTracker:BAG_UPDATE(eventName,bagId)
    --self:Print(eventName)
    --self:Print(bagId)
    self:ScanBag(bagId)
end

function GatheringTracker:BAG_UPDATE_DELAYED(eventName)
    --self:Print(eventName)
    self:FinalizeTracking()
end
--[[]
function GatheringTracker:ITEM_PUSH(eventName,bagId,icon)
    self:Print(eventName)
    self:Print(bagId)
    self:Print("Icon"..  bagId)
    self:ScanBag(bagId)
end
]]



--return any new items in the form of an array 
function GatheringTracker:ScanBag(bagId)
	local numSlots = GetContainerNumSlots(bagId)
    ret = {}
   
	for slotId = 1, numSlots do
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
                    self.db.char.bagdata:ItemDataCache(itemNumber,itemName,texture,itemLink)
                    self.db.char.bagdata:UpdateItem(bagId,slotId,itemNumber,itemCount)
                    --UpdateItem(bagId,slotId,itemName,itemNumber,itemCount,texture)
                end -- end quality check
            end -- end item type check
        else -- blank spot
            self.db.char.bagdata:ClearItem(bagId,slotId)
            
		end --end itemLink check
	end
end


function GatheringTracker:FinalizeTracking()
    --self:Print("FinalizeTracking")
    self.db.char.bagdata:LogChanges()
    --self:Print("DONE FinalizeTracking")
end



--- helper funtion


