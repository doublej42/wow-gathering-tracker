ItemFrame = {} 


function ItemFrame:new(o, console)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.console = console
    return o
end

function ItemFrame:Create()
    self.Frame = CreateFrame("Frame","ItemFrame",UIParent);
    self.Frame:ClearAllPoints();
    self.Frame:SetPoint("CENTER");
    self.Frame:SetSize(100,100);
    self.Frame:SetMovable(true);
    self.Frame:EnableMouse(true);
    self.Frame:SetBackdrop ({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    --bgFile = "Interface/Artifacts/ArtifactUIPriest",
    --tile = true, 
    --tileSize = 16,
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
    });
    self.Frame:SetBackdropColor(0,0,0,0.5);
    self.Frame:SetScript("OnMouseDown", function(self, button)
        self.console.Print(button);
        if button == "LeftButton" and not self.isMoving then
        self:StartMoving();
        self.isMoving = true;
        end
    end)
    self.Frame:SetScript("OnMouseUp", function(self, button)
        self.console.Print(button);
        if button == "LeftButton" and self.isMoving then
        self:StopMovingOrSizing();
        self.isMoving = false;
        end
    end)

    self.Frame:SetScript("OnHide", function(self)
        self.console.Print(button);
        if ( self.isMoving ) then
        self:StopMovingOrSizing();
        self.isMoving = false;
        end
    end)
    self.Frame:Show();
end

function ItemFrame:AddItem(ItemNumber, DagData)
    self.console.Print(ItemNumber)
end
