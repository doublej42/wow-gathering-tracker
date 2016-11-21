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
end

function GatheringTracker:OnEnable()
    self:Print("OnEnable")
    self:Print(GatheringTracker.db.profile.timeFrame)
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
    self:Print("Rate now set to items per "..input.." minutes.")
    self.db.profile.timeFrame = input
end

function GatheringTracker:BAG_UPDATE(eventName,bagID)
    self:Print(eventName)
    self:Print(bagID)
end

