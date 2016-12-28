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
    self.StartTime = math.floor(GetTime())
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
    local maxTimeGap = 60*5
    --self:Print("FinalizeTracking")
    if (BagData:AnyChanges()) then
            --self:Print("Item changes")
            BagData:LogChanges()
            for key,value in pairs(BagData.changes) do
                --self:Print(key.." ^ "..value)
                if (value > 0) then
                    --self:Print("About to add Item")
                    
                    local timeSinceLastGather = GatheringTracker:AddItem(key,value)
                    if (timeSinceLastGather < maxTimeGap) then
                        local timeToGoal,rate = GatheringTracker:GetTimes(key,100)
                        local tooltip = "Time to next multiple of 100 gathered " .. GatheringTracker.to_hms_string(timeToGoal)
                        ItemFrame:AddItem(key,GatheringTrackerDBChr.bagdata,tooltip, GatheringTracker.to_hms_string(timeToGoal))
                    end
                    --self:Print("added item")
                elseif (value < 0) then
                    --DEFAULT_CHAT_FRAME:AddMessage(GatheringTrackerDBChr.bagdata.itemData[key].itemLink.."|cFFFF0000 lost |r"..value)
                end
            end
            BagData:ClearChanges()
            ItemFrame:Update(GatheringTrackerDBChr.bagdata)
    end
    --self:Print("DONE FinalizeTracking")
end

-- Given a Key,goal, with return:
-- Time in seconds till the goal is hit
-- Amount sense starting gathered in average self.db.profile.timeFrame
function GatheringTracker:GetTimes(Key,goal)
    local rateSeconds = 60
    local maxTrackingGap = 60*10
    local lastTime = 0 - maxTrackingGap --so even if an item is at zero seconds it's ignored
    local timeStamps = {}
    local itemTimes = self.ChangesData[Key]
    for aTime in pairs(itemTimes) do 
        table.insert(timeStamps, aTime) 
    end
    table.sort(timeStamps)
    local totalTime = 0
    local totalCount = 0
    for _, aTime in ipairs(timeStamps) do 
        print(aTime, itemTimes[aTime])
        local timeGap = aTime - lastTime
        self:Print("timeGap:"..timeGap)
        self:Print("itemTimes[aTime]:"..itemTimes[aTime])
        if timeGap < maxTrackingGap then
            --this time stamp is less than the max gap in seconds. If it is more than the max gap then ignore this gather it's just an incidental collection
            totalTime = totalTime + timeGap
            totalCount = totalCount + itemTimes[aTime]
            --self:Print("Total Time:"..GatheringTracker.to_hms_string(totalTime))
        end
        lastTime = aTime
    end
    local timeToGoal = 24*60*60
    local rate = 0
    if (totalTime > 0) then
        --some time was found, this should always be true
        local ratePerSecond = totalCount / totalTime
        self:Print("totalCount:"..totalCount)
        self:Print("totalTime:"..totalTime)
        self:Print("Rate per second:"..ratePerSecond)
        rate = rateSeconds * ratePerSecond
        local remainingTillGoal = goal-(totalCount%goal)
        self:Print("Remaining Till Goal:"..remainingTillGoal)
        timeToGoal =  remainingTillGoal / ratePerSecond
    end
    return timeToGoal,rate

end

--return time sense last changeb
function GatheringTracker:AddItem(Key,Amount)
    local CurrentTime = math.floor(GetTime())
    self:Print("Adding Item to gt :"..Key)
    if type(self.ChangesData) ~= "table" then
        self.ChangesData = {}
    end
    if type(self.ChangesData[Key]) ~= "table" then
        self.ChangesData[Key] = {}
    end
    local lastTime = 0
    for seconds,amount in pairs(self.ChangesData[Key]) do
        if (seconds > lastTime) then
            lastTime = seconds
        end
    end -- end for loop for last time
    self.ChangesData[Key][CurrentTime] = Amount
    if lastTime == 0 then
        return 24*60*60 -- one day, incase they turn onthe computer and get an item within 5 minutes 
    end
    return CurrentTime - lastTime
end


--- helper funtions


function GatheringTracker.to_hms(seconds)
    hours = math.floor (seconds / 3600)
    seconds = seconds - (hours * 3600)
    minutes = math.floor (seconds / 60)
    seconds = math.floor (seconds - (minutes * 60))
    return hours,minutes,seconds
end --to_hms


function GatheringTracker.to_ms(seconds)
    minutes = math.floor (seconds / 60)
    seconds = math.floor (seconds - (minutes * 60))
    return minutes,seconds
end --to_hms


function GatheringTracker.to_hms_string(seconds)
    if (seconds > (60*60)) then
        return string.format("%d:%.2d:%.2d", GatheringTracker.to_hms(seconds))
    else
        return string.format("%.2d:%.2d", GatheringTracker.to_ms(seconds))
    end
end --to_hms_string
