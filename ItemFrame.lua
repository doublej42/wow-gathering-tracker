ItemFrame = {} 
ItemFrame.IconSize = 32
ItemFrame.SidePadding = 6


function ItemFrame:new(o, console)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.console = console
    return o
end

function ItemFrame:Init(console)
    self.console = console
    self.Buttons = {}
end



function ItemFrame:Create()
    self.Frame = CreateFrame("Frame","ItemFrame",UIParent)
    self.Frame:ClearAllPoints()
    self.Frame:SetPoint("TOP",UIParent,"TOP",0,0)
    --self.Frame:SetPoint("CENTER")
    self.Frame:SetSize(64,64)
    self.Frame:SetMovable(true)
    self.Frame:EnableMouse(true)
    self.Frame:SetClampedToScreen(true)
    self.Frame:SetUserPlaced(true)
    self.Frame:SetBackdrop ({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    --bgFile = "Interface/Artifacts/ArtifactUIPriest",
    --tile = true, 
    --tileSize = 16,
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
    });
    self.Frame:SetBackdropColor(0,0,0,0.5)
    self.Frame:SetScript("OnMouseDown", function(self, button)
        --ItemFrame.console:Print(button)
        if button == "LeftButton" and not self.isMoving then
        self:StartMoving()
        self.isMoving = true
        end
    end)
    self.Frame:SetScript("OnMouseUp", function(self, button)
        --ItemFrame.console:Print(button)
        if button == "LeftButton" and self.isMoving then
        self:StopMovingOrSizing()
        self.isMoving = false
        end
    end)

    self.Frame:SetScript("OnHide", function(self)
        --self.console.Print(button)
        if ( self.isMoving ) then
        self:StopMovingOrSizing()
        self.isMoving = false
        end
    end)
    self.Frame:Show()
end



function ItemFrame:AddItem(ItemNumber, bagData)
    local itemNum = tostring(ItemNumber)
    --self.console:Print(itemNum)
    local item = bagData.itemData[itemNum]
    if (item ~= nil) then
        --self.console:Print(item.itemLink) 
        --self.console:Print(item.Count)
        if (self.Buttons[itemNum] ~= nil) then
            --button found 
            --self.console:Print("countLabel"..self.Buttons[itemNum].countLabel)
            self.Buttons[itemNum].countLabel:SetText(item.Count)
        else
            local buttonCount = ItemFrame:ButtonCount() +1
            --self.console:Print("buttonCount"..buttonCount)
            local newButton = CreateFrame("Button","ItemFrame"..itemNum,self.Frame);
            local sizePerIcon = ItemFrame.IconSize + (2 * ItemFrame.SidePadding)
            --self.console:Print("sizePerIcon"..(sizePerIcon*buttonCount))
            newButton:SetSize(ItemFrame.IconSize,ItemFrame.IconSize);
            newButton:SetPoint("LEFT",ItemFrame.Frame,"LEFT",(ItemFrame.SidePadding) + ((ItemFrame.SidePadding+ItemFrame.IconSize) * (buttonCount-1)),0)
            ItemFrame.Frame:SetSize(sizePerIcon* buttonCount ,ItemFrame.IconSize+32)
            --ItemFrame.Frame:SetSize(96,96)
            newButton:SetNormalTexture(item.texture)
            newButton:SetText(item.itemLink)
            newButton:Show()
            newButton.countLabel = newButton:CreateFontString(nil,"OVERLAY","GameTooltipText")
            newButton.countLabel:SetPoint("BOTTOM", newButton,"TOP",0,0)
            newButton.countLabel:SetText(item.Count)
            newButton.mainLabel = newButton:CreateFontString(nil,"OVERLAY","GameTooltipText")
            newButton.mainLabel:SetPoint("TOP", newButton,"BOTTOM",0,0)
            newButton.mainLabel:SetText("")
            self.Buttons[itemNum] = newButton
        end
    end
end

function ItemFrame:ButtonCount()
  local count = 0
  for _ in pairs(self.Buttons) do count = count + 1 end
  return count
end


function ItemFrame:Update(bagData)
    for key,value in pairs(self.Buttons) do
        local item = bagData.itemData[key]
        value.countLabel:SetText(item.Count)
    end
end