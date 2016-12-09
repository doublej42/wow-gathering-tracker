GatheringTracker = LibStub("AceAddon-3.0"):NewAddon("Gathering Tracker", "AceConsole-3.0","AceEvent-3.0")


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
    self.db = LibStub("AceDB-3.0"):New("GatheringTrackerDB")
    options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("GatheringTracker", options, {"gt", "GatheringTracker"})
    GatheringTracker:RegisterEvent("BAG_UPDATE")
    GatheringTracker:RegisterEvent("BAG_UPDATE_DELAYED")
    GatheringTracker:RegisterEvent("PLAYER_ENTERING_WORLD")

    if (GatheringTrackerDBChr == nil) then
        self:Print("Firts time setup for character data")
        GatheringTrackerDBChr = {}
        GatheringTrackerDBChr.status = "ready"
        GatheringTrackerDBChr.bagdata = {}
    end
  
    if (type(GatheringTrackerDBChr.bagdata) ~= "table") then
        GatheringTrackerDBChr.bagdata = {}
    end 
    BagData:Init(self,GatheringTrackerDBChr.bagdata)
    ItemFrame:Init(self)
    ItemFrame:Create()
end

function GatheringTracker:OnEnable()
    --self:Print("OnEnable")
    --self:InitReady()
    --self:Print(GatheringTracker.db.profile.timeFrame)
    if type(GatheringTracker.db.profile.timeFrame) ~= "number" then
        GatheringTracker.db.profile.timeFrame = 60;
    end -- end if
    --self:Print(BagData.bag["0"]["1"].itemNumber)
    
    --if (GatheringTrackerDBChr.bag ~= nil) then
    --    self:Print(table.getn(GatheringTrackerDBChr.bag))
    --end

    
    
    
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
    --self:Print(eventName)
    BagData:ScanBags() -- scan bags on login
    if (GatheringTrackerDBChr ~= nil and GatheringTrackerDBChr.bagdata ~= nil and  GatheringTrackerDBChr.bagdata.changes ~= nil) then
        if (BagData:AnyChanges()) then
            self:Print("New items since last login")
            BagData:LogChanges()
            BagData:ClearChanges()
        else
            self:Print("No new items since last login. Check out the legion app.")
        end
    end
    self.ready = true
    --self:InitReady()
end

function GatheringTracker:BAG_UPDATE(eventName,bagId)
    --self:Print(eventName)
    --self:Print(bagId)
    if (self.ready) then
        BagData:ScanBag(bagId)
    end
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



function GatheringTracker:FinalizeTracking()
    --self:Print("FinalizeTracking")
    if (BagData:AnyChanges()) then
            self:Print("Item changes")
            BagData:LogChanges()
            for key,value in pairs(BagData.changes) do
                if (value > 0) then
                    ItemFrame:AddItem(key,GatheringTrackerDBChr.bagdata)
                elseif (value < 0) then
                    --DEFAULT_CHAT_FRAME:AddMessage(self.database.itemData[key].itemLink.."|cFFFF0000 lost |r"..value)
                end
            end
            BagData:ClearChanges()
            ItemFrame:Update(GatheringTrackerDBChr.bagdata)
    end
    
    --self:Print("DONE FinalizeTracking")
end



--- helper funtion


