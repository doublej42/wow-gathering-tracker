ItemFrame = {} 
ItemFrame.IconSize = 37
ItemFrame.SidePadding = 10


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



function ItemFrame:AddItem(itemNumber, bagData,tooltipLine,topLabelText,bottomLabelText)
    local itemNum = tostring(itemNumber)
    --self.console:Print("Adding item to frame number:"..itemNum)
    local item = bagData.itemData[itemNum]
    if (item ~= nil) then
        --self.console:Print(item.itemLink) 
        --self.console:Print(item.Count)
        if (self.Buttons[itemNum] ~= nil) then
            local itemButton = self.Buttons[itemNum]
            --button found 
            --self.console:Print("countLabel"..self.Buttons[itemNum].countLabel)
            --self.Buttons[itemNum].countLabel:SetText(item.Count)
            SetItemButtonCount(itemButton,item.Count)
            itemButton.toolLine = tooltipLine
            itemButton.bottomLabel:SetText(topLabelText)
            itemButton.topLabel:SetText(bottomLabelText)
        else
            local buttonCount = ItemFrame:ButtonCount() +1
            --self.console:Print("buttonCount"..buttonCount)
            
            
            local sizePerIcon = ItemFrame.IconSize + (2 * ItemFrame.SidePadding)
            --self.console:Print("sizePerIcon"..(sizePerIcon*buttonCount))
            --itemButton:SetSize(ItemFrame.IconSize,ItemFrame.IconSize);
            local leftPosition = sizePerIcon * (buttonCount-1)
            if (buttonCount == 1) then
                leftPosition = ItemFrame.SidePadding
            end
            ItemFrame.Frame:SetSize((sizePerIcon * buttonCount),ItemFrame.IconSize+32)
            local itemButton = CreateFrame("Button","ItemFrame"..itemNum,self.Frame,"ItemButtonTemplate");
            itemButton:SetPoint("LEFT",ItemFrame.Frame,"LEFT",leftPosition,0)
            SetItemButtonTexture(itemButton,item.texture)
            itemButton.itemLink = item.itemLink
            itemButton.itemNumber = ItemNumber
            itemButton.toolLine = tooltipLine
            itemButton:SetScript("OnEnter",ItemFrame_OnEnter)
            itemButton:SetScript("OnLeave",ItemFrame_OnLeave)
            itemButton:Show()
            SetItemButtonCount(itemButton,item.Count)
            itemButton.bottomLabel = itemButton:CreateFontString(nil,"OVERLAY","GameTooltipText")
            itemButton.bottomLabel:SetPoint("TOP", itemButton,"BOTTOM",0,0)
            itemButton.bottomLabel:SetText(topLabelText)
            itemButton.topLabel = itemButton:CreateFontString(nil,"OVERLAY","GameTooltipText")
            itemButton.topLabel:SetPoint("BOTTOM", itemButton,"TOP",0,0)
            itemButton.topLabel:SetText(bottomLabelText)
            self.Buttons[itemNum] = itemButton
        end
    end
end

function ItemFrame_OnEnter(self, motion)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    local itemLink = self.itemLink
	GameTooltip:SetHyperlink(itemLink)
    GameTooltip:AddLine(self.toolLine)
    GameTooltip:Show()
end

function ItemFrame_OnLeave()
    GameTooltip:Hide()
end

function ItemFrame:ButtonCount()
  local count = 0
  for _ in pairs(self.Buttons) do count = count + 1 end
  return count
end


function ItemFrame:Update(bagData)
    for itemNumber,button in pairs(self.Buttons) do
        local item = bagData.itemData[itemNumber]
        --value.countLabel:SetText(item.Count)
            SetItemButtonCount(button,item.Count)
    end
end