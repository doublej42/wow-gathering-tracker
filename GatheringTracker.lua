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
    GatheringTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
    --GatheringTracker:RegisterEvent("ITEM_PUSH")
    if (bagData == nil or bagData.Test == nil) then       
        bagData = BagData:new(bagData,self,GatheringTrackerDBChr.bagdata)
    end
    bagData:Reset()
end

function GatheringTracker:OnEnable()
    self:Print("OnEnable")
    --self:Print(GatheringTracker.db.profile.timeFrame)
    if type(GatheringTracker.db.profile.timeFrame) ~= "number" then
        GatheringTracker.db.profile.timeFrame = 60;
    end -- end if
    --self:Print(bagData.bag["0"]["1"].itemNumber)
    
    --if (GatheringTrackerDBChr.bag ~= nil) then
    --    self:Print(table.getn(GatheringTrackerDBChr.bag))
    --end

    
    bagData:ScanBags()
    if (GatheringTrackerDBChr ~= nil and GatheringTrackerDBChr.bagdata ~= nil and  GatheringTrackerDBChr.bagdata.changes ~= nil) then
        if (table.getn(GatheringTrackerDBChr.bagdata.changes)) then
            self:Print("New items since last login")
            --bagData:LogChanges()
            bagData:ClearChanges()
        else
            self:Print("no new items since last login. Check out the legion app.")
        end
    end
    self.ready = true
    -- Called when the addon is enabled
end

function GatheringTracker:OnDisable()
    -- Called when the addon is disabled
    self.ready = false
end

function GatheringTracker:GetTimeFrame(info)
    return self.db.profile.timeFrame
end

function GatheringTracker:SetTimeFrame(info,input)
    --self:Print("Rate now set to items per "..input.." minutes.")
    self.db.profile.timeFrame = input
end

function GatheringTracker:PLAYER_ENTERING_WORLD(eventName)
    self:Print(eventName)

end

function GatheringTracker:BAG_UPDATE(eventName,bagId)
    self:Print(eventName)
    --self:Print(bagId)
    if (self.ready) then
        --bagData:ScanBag(bagId)
    end
end

function GatheringTracker:BAG_UPDATE_DELAYED(eventName)
    self:Print(eventName)
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



function GatheringTracker:FinalizeTracking()
    --self:Print("FinalizeTracking")
    --bagData:LogChanges()
    --bagData:ClearChanges()
    --self:Print("DONE FinalizeTracking")
end



--- helper funtion


