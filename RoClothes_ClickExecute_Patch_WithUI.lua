--[[
RoClothes ClickExecute Enhancement Patch v1.0 - WITH UI UPDATE
Patch nâng cấp ClickExecute + Enhanced UI với Tab System

FEATURES:
- Bảo vệ accessories có từ "face", "eyes" trong tên khi ClickExecute  
- Enhanced Tab System với smooth animations
- Improved Tab Content organization
- Modern UI design với better UX
- Protected Accessories Manager
- Visual feedback và notifications

HƯỚNG DẪN:
1. Paste code này vào cuối function RoClothes (trước dòng end cuối)
2. Comment out đoạn MouseDown gốc và UI setup gốc
3. Thêm initialization
]]

-- ==================== ENHANCED CLICKEXECUTE + UI VARIABLES ====================
local ProtectedAccessoryKeywords = {"face", "eyes", "mask", "glasses", "hat"} -- Từ khóa bảo vệ
local ClickExecuteCooldown = false

-- Enhanced UI Variables
local CurrentTab = "Menu"
local TabHistory = {}
local UIAnimationSpeed = 0.3
local NotificationQueue = {}

-- Tab Configuration
local TabConfig = {
    {Name = "Menu", Icon = "🏠", Color = Color3.fromRGB(70, 130, 255)},
    {Name = "Clothes", Icon = "👔", Color = Color3.fromRGB(255, 130, 70)},
    {Name = "Bundles", Icon = "📦", Color = Color3.fromRGB(130, 255, 70)},
    {Name = "Settings", Icon = "⚙️", Color = Color3.fromRGB(255, 70, 130)},
    {Name = "Protection", Icon = "🛡️", Color = Color3.fromRGB(70, 255, 255)} -- New Tab
}

-- ==================== ENHANCED UI OBJECTS ====================
-- Enhanced Tab System Objects
GUIObject.EnhancedTabFrame = Instance.new("Frame")
GUIObject.TabContainer = Instance.new("Frame")
GUIObject.TabContentContainer = Instance.new("Frame")
GUIObject.TabIndicator = Instance.new("Frame")
GUIObject.NotificationFrame = Instance.new("Frame")
GUIObject.ProtectionTab = Instance.new("Frame")
GUIObject.ProtectionSettings = Instance.new("ScrollingFrame")

-- Protection Manager Objects
GUIObject.ProtectedList = Instance.new("ScrollingFrame")
GUIObject.AddKeywordFrame = Instance.new("Frame")
GUIObject.AddKeywordInput = Instance.new("TextBox")
GUIObject.AddKeywordButton = Instance.new("TextButton")
GUIObject.ProtectionToggle = Instance.new("TextButton")
GUIObject.ClickModeFrame = Instance.new("Frame")
GUIObject.ClickModeLabel = Instance.new("TextLabel")

-- ==================== ENHANCED FUNCTIONS ====================

-- Function kiểm tra xem accessory có được bảo vệ không
function Function.IsProtectedAccessory(accessory)
    if not accessory or not accessory.Name then
        return false
    end
    
    local accessoryName = string.lower(accessory.Name)
    
    for _, keyword in pairs(ProtectedAccessoryKeywords) do
        if string.find(accessoryName, string.lower(keyword)) then
            return true
        end
    end
    
    return false
end

-- Function xóa accessories nhưng bảo vệ face/eyes
function Function.SafeRemoveAccessories(character)
    if not character then return end
    
    local removedCount = 0
    local protectedCount = 0
    local protectedNames = {}
    
    for _, accessory in pairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            if Function.IsProtectedAccessory(accessory) then
                protectedCount = protectedCount + 1
                table.insert(protectedNames, accessory.Name)
            else
                accessory:Destroy()
                removedCount = removedCount + 1
            end
        end
    end
    
    -- Show notification
    Function.ShowNotification(
        "Protected " .. protectedCount .. " accessories", 
        "Removed " .. removedCount .. " accessories",
        Color3.fromRGB(70, 255, 130)
    )
    
    return removedCount, protectedCount, protectedNames
end

-- Enhanced ClickExecute function
function Function.EnhancedClickExecute(targetModel)
    if ClickExecuteCooldown then return end
    ClickExecuteCooldown = true
    
    if not targetModel or not targetModel:FindFirstChild("Humanoid") then
        ClickExecuteCooldown = false
        return
    end
    
    local targetName = targetModel.Name
    local isPlayer = game.Players:GetPlayerFromCharacter(targetModel) ~= nil
    
    if Function.IsCharacter(targetModel) then
        -- Sử dụng safe remove thay vì CharacterReset
        local removed, protected, protectedNames = Function.SafeRemoveAccessories(targetModel)
        
        if not isPlayer and PlayerData[SelectPlayer] ~= nil then
            -- Handle NPC
            local NPCData = math.random(0, 999999999) .. targetModel.Name
            if Function.TableFind(NPCs, targetModel) == nil then
                NPCs[NPCData] = targetModel
            else
                NPCData = Function.TableFind(NPCs, targetModel)
            end
            local cDataTable = Function.TableClone(PlayerData[SelectPlayer])
            cDataTable.CurrentPartList = Function.PlayerDataDefault().CurrentPartList
            PlayerData[NPCData] = cDataTable
            Function.CharacterExecute(targetModel, NPCData)
        else
            -- Handle Player
            Function.CharacterExecute(targetModel, targetName)
        end
        
        Function.ShowNotification(
            "Applied to " .. targetName,
            "Protected face/eyes accessories",
            Color3.fromRGB(70, 130, 255)
        )
    end
    
    wait(0.1) -- Cooldown
    ClickExecuteCooldown = false
end

-- ==================== ENHANCED UI FUNCTIONS ====================

-- Show notification system
function Function.ShowNotification(title, message, color)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Parent = GUIObject.NotificationFrame
    notification.BackgroundColor3 = color or Color3.fromRGB(40, 40, 40)
    notification.BorderSizePixel = 0
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.Position = UDim2.new(0, 0, 1, 0)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = notification
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Parent = notification
    messageLabel.BackgroundTransparency = 1
    messageLabel.Position = UDim2.new(0, 10, 0, 25)
    messageLabel.Size = UDim2.new(1, -20, 0, 15)
    messageLabel.Font = Enum.Font.SourceSans
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextScaled = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Animate in
    local tween1 = TS:Create(notification, 
        TweenInfo.new(UIAnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(1, 0, 0, 50), Position = UDim2.new(0, 0, 1, -60)}
    )
    tween1:Play()
    
    -- Auto remove after 3 seconds
    wait(3)
    local tween2 = TS:Create(notification,
        TweenInfo.new(UIAnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(1, 0, 1, -60), Transparency = 1}
    )
    tween2:Play()
    
    tween2.Completed:Connect(function()
        notification:Destroy()
    end)
end

-- Switch tab function with animation
function Function.SwitchTab(tabName)
    if CurrentTab == tabName then return end
    
    -- Add to history
    table.insert(TabHistory, CurrentTab)
    if #TabHistory > 5 then
        table.remove(TabHistory, 1)
    end
    
    CurrentTab = tabName
    
    -- Hide all tab contents with animation
    for _, content in pairs(GUIObject.TabContentContainer:GetChildren()) do
        if content:IsA("Frame") then
            local tween = TS:Create(content,
                TweenInfo.new(UIAnimationSpeed/2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Transparency = 1, Position = UDim2.new(0, -50, 0, 0)}
            )
            tween:Play()
            tween.Completed:Connect(function()
                content.Visible = false
            end)
        end
    end
    
    -- Show target tab content
    wait(UIAnimationSpeed/2)
    local targetContent = GUIObject.TabContentContainer:FindFirstChild(tabName)
    if targetContent then
        targetContent.Visible = true
        targetContent.Transparency = 1
        targetContent.Position = UDim2.new(0, 50, 0, 0)
        
        local tween = TS:Create(targetContent,
            TweenInfo.new(UIAnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Transparency = 0, Position = UDim2.new(0, 0, 0, 0)}
        )
        tween:Play()
    end
    
    -- Update tab indicator
    Function.UpdateTabIndicator(tabName)
    
    Function.ShowNotification("Switched to " .. tabName, "Tab changed successfully", Color3.fromRGB(70, 130, 255))
end

-- Update tab indicator position
function Function.UpdateTabIndicator(tabName)
    local tabButton = GUIObject.TabContainer:FindFirstChild(tabName .. "Tab")
    if tabButton then
        local tween = TS:Create(GUIObject.TabIndicator,
            TweenInfo.new(UIAnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, tabButton.Position.X.Offset, 1, -3)}
        )
        tween:Play()
    end
end

-- Update protected accessories list
function Function.UpdateProtectedList()
    -- Clear existing list
    for _, child in pairs(GUIObject.ProtectedList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Add current keywords
    for i, keyword in pairs(ProtectedAccessoryKeywords) do
        local item = Instance.new("Frame")
        item.Name = "ProtectedItem" .. i
        item.Parent = GUIObject.ProtectedList
        item.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        item.BorderSizePixel = 0
        item.Size = UDim2.new(1, -10, 0, 30)
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = item
        
        local label = Instance.new("TextLabel")
        label.Parent = item
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Size = UDim2.new(1, -80, 1, 0)
        label.Font = Enum.Font.Code
        label.Text = '"' .. keyword .. '"'
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local removeBtn = Instance.new("TextButton")
        removeBtn.Parent = item
        removeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        removeBtn.BorderSizePixel = 0
        removeBtn.Position = UDim2.new(1, -65, 0, 5)
        removeBtn.Size = UDim2.new(0, 60, 0, 20)
        removeBtn.Font = Enum.Font.SourceSansBold
        removeBtn.Text = "Remove"
        removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        removeBtn.TextScaled = true
        
        local removeCorner = Instance.new("UICorner")
        removeCorner.CornerRadius = UDim.new(0, 3)
        removeCorner.Parent = removeBtn
        
        removeBtn.MouseButton1Click:Connect(function()
            table.remove(ProtectedAccessoryKeywords, i)
            Function.UpdateProtectedList()
            Function.ShowNotification("Removed keyword", '"' .. keyword .. '" no longer protected', Color3.fromRGB(255, 130, 70))
        end)
    end
end

-- Initialize Enhanced UI
function Function.InitializeEnhancedUI()
    -- Enhanced Tab Frame
    GUIObject.EnhancedTabFrame.Name = "EnhancedTabFrame"
    GUIObject.EnhancedTabFrame.Parent = GUIObject.Screen
    GUIObject.EnhancedTabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    GUIObject.EnhancedTabFrame.BorderSizePixel = 0
    GUIObject.EnhancedTabFrame.Position = UDim2.new(0, 10, 0, 10)
    GUIObject.EnhancedTabFrame.Size = UDim2.new(0, 500, 0, 400)
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = GUIObject.EnhancedTabFrame
    
    -- Tab Container
    GUIObject.TabContainer.Name = "TabContainer"
    GUIObject.TabContainer.Parent = GUIObject.EnhancedTabFrame
    GUIObject.TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    GUIObject.TabContainer.BorderSizePixel = 0
    GUIObject.TabContainer.Position = UDim2.new(0, 0, 0, 0)
    GUIObject.TabContainer.Size = UDim2.new(1, 0, 0, 50)
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 15)
    tabCorner.Parent = GUIObject.TabContainer
    
    -- Tab Indicator
    GUIObject.TabIndicator.Name = "TabIndicator"
    GUIObject.TabIndicator.Parent = GUIObject.TabContainer
    GUIObject.TabIndicator.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    GUIObject.TabIndicator.BorderSizePixel = 0
    GUIObject.TabIndicator.Position = UDim2.new(0, 0, 1, -3)
    GUIObject.TabIndicator.Size = UDim2.new(0, 100, 0, 3)
    
    -- Create Tab Buttons
    for i, tab in pairs(TabConfig) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tab.Name .. "Tab"
        tabBtn.Parent = GUIObject.TabContainer
        tabBtn.BackgroundTransparency = 1
        tabBtn.Position = UDim2.new(0, (i-1) * 100, 0, 0)
        tabBtn.Size = UDim2.new(0, 100, 1, -3)
        tabBtn.Font = Enum.Font.SourceSansBold
        tabBtn.Text = tab.Icon .. " " .. tab.Name
        tabBtn.TextColor3 = CurrentTab == tab.Name and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        tabBtn.TextScaled = true
        
        tabBtn.MouseButton1Click:Connect(function()
            Function.SwitchTab(tab.Name)
        end)
    end
    
    -- Tab Content Container
    GUIObject.TabContentContainer.Name = "TabContentContainer"
    GUIObject.TabContentContainer.Parent = GUIObject.EnhancedTabFrame
    GUIObject.TabContentContainer.BackgroundTransparency = 1
    GUIObject.TabContentContainer.Position = UDim2.new(0, 10, 0, 60)
    GUIObject.TabContentContainer.Size = UDim2.new(1, -20, 1, -70)
    
    -- Create Protection Tab Content
    Function.CreateProtectionTab()
    
    -- Notification Frame
    GUIObject.NotificationFrame.Name = "NotificationFrame"
    GUIObject.NotificationFrame.Parent = GUIObject.Screen
    GUIObject.NotificationFrame.BackgroundTransparency = 1
    GUIObject.NotificationFrame.Position = UDim2.new(1, -320, 0, 10)
    GUIObject.NotificationFrame.Size = UDim2.new(0, 300, 1, -20)
    
    warn("Enhanced UI initialized with Tab System!")
end

-- Create Protection Tab Content
function Function.CreateProtectionTab()
    GUIObject.ProtectionTab.Name = "Protection"
    GUIObject.ProtectionTab.Parent = GUIObject.TabContentContainer
    GUIObject.ProtectionTab.BackgroundTransparency = 1
    GUIObject.ProtectionTab.Size = UDim2.new(1, 0, 1, 0)
    GUIObject.ProtectionTab.Visible = false
    
    -- Protection Title
    local title = Instance.new("TextLabel")
    title.Parent = GUIObject.ProtectionTab
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.SourceSansBold
    title.Text = "🛡️ Accessory Protection Manager"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Click Mode Frame
    GUIObject.ClickModeFrame.Parent = GUIObject.ProtectionTab
    GUIObject.ClickModeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    GUIObject.ClickModeFrame.BorderSizePixel = 0
    GUIObject.ClickModeFrame.Position = UDim2.new(0, 0, 0, 40)
    GUIObject.ClickModeFrame.Size = UDim2.new(1, 0, 0, 60)
    
    local modeCorner = Instance.new("UICorner")
    modeCorner.CornerRadius = UDim.new(0, 10)
    modeCorner.Parent = GUIObject.ClickModeFrame
    
    GUIObject.ClickModeLabel.Parent = GUIObject.ClickModeFrame
    GUIObject.ClickModeLabel.BackgroundTransparency = 1
    GUIObject.ClickModeLabel.Position = UDim2.new(0, 10, 0, 5)
    GUIObject.ClickModeLabel.Size = UDim2.new(1, -20, 0, 25)
    GUIObject.ClickModeLabel.Font = Enum.Font.SourceSansBold
    GUIObject.ClickModeLabel.Text = "Click Mode: Left = Safe Apply | Right = Complete Reset"
    GUIObject.ClickModeLabel.TextColor3 = Color3.fromRGB(70, 255, 130)
    GUIObject.ClickModeLabel.TextScaled = true
    GUIObject.ClickModeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Add Keyword Frame
    GUIObject.AddKeywordFrame.Parent = GUIObject.ProtectionTab
    GUIObject.AddKeywordFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    GUIObject.AddKeywordFrame.BorderSizePixel = 0
    GUIObject.AddKeywordFrame.Position = UDim2.new(0, 0, 0, 110)
    GUIObject.AddKeywordFrame.Size = UDim2.new(1, 0, 0, 40)
    
    local addCorner = Instance.new("UICorner")
    addCorner.CornerRadius = UDim.new(0, 8)
    addCorner.Parent = GUIObject.AddKeywordFrame
    
    GUIObject.AddKeywordInput.Parent = GUIObject.AddKeywordFrame
    GUIObject.AddKeywordInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    GUIObject.AddKeywordInput.BorderSizePixel = 0
    GUIObject.AddKeywordInput.Position = UDim2.new(0, 10, 0, 5)
    GUIObject.AddKeywordInput.Size = UDim2.new(1, -120, 0, 30)
    GUIObject.AddKeywordInput.Font = Enum.Font.Code
    GUIObject.AddKeywordInput.PlaceholderText = "Enter keyword to protect..."
    GUIObject.AddKeywordInput.Text = ""
    GUIObject.AddKeywordInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    GUIObject.AddKeywordInput.TextScaled = true
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 5)
    inputCorner.Parent = GUIObject.AddKeywordInput
    
    GUIObject.AddKeywordButton.Parent = GUIObject.AddKeywordFrame
    GUIObject.AddKeywordButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    GUIObject.AddKeywordButton.BorderSizePixel = 0
    GUIObject.AddKeywordButton.Position = UDim2.new(1, -100, 0, 5)
    GUIObject.AddKeywordButton.Size = UDim2.new(0, 90, 0, 30)
    GUIObject.AddKeywordButton.Font = Enum.Font.SourceSansBold
    GUIObject.AddKeywordButton.Text = "Add"
    GUIObject.AddKeywordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GUIObject.AddKeywordButton.TextScaled = true
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = GUIObject.AddKeywordButton
    
    -- Protected List
    GUIObject.ProtectedList.Parent = GUIObject.ProtectionTab
    GUIObject.ProtectedList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    GUIObject.ProtectedList.BorderSizePixel = 0
    GUIObject.ProtectedList.Position = UDim2.new(0, 0, 0, 160)
    GUIObject.ProtectedList.Size = UDim2.new(1, 0, 1, -160)
    GUIObject.ProtectedList.ScrollBarThickness = 5
    GUIObject.ProtectedList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = GUIObject.ProtectedList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = GUIObject.ProtectedList
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    
    -- Setup Events
    GUIObject.AddKeywordButton.MouseButton1Click:Connect(function()
        local keyword = GUIObject.AddKeywordInput.Text:lower()
        if keyword ~= "" and not table.find(ProtectedAccessoryKeywords, keyword) then
            table.insert(ProtectedAccessoryKeywords, keyword)
            GUIObject.AddKeywordInput.Text = ""
            Function.UpdateProtectedList()
            Function.ShowNotification("Added keyword", '"' .. keyword .. '" is now protected', Color3.fromRGB(70, 255, 130))
        end
    end)
    
    Function.UpdateProtectedList()
end

-- ==================== ENHANCED MOUSE HANDLING ====================

-- Enhanced Mouse Down Event - REPLACE THE ORIGINAL MouseDown
function Function.SetupEnhancedClickExecute()
    local EnhancedMouseDown = Mouse.Button1Down:Connect(function()
        IsMouseDown = true
        MouseDownStart = UIS:GetMouseLocation()
        GuiPositionStart = GUIObject.MainFrame.Position

        if ClickExecute == true and not ClickExecuteCooldown then
            local Part = Mouse.Target

            if Part and Part:FindFirstAncestorOfClass("Model") ~= nil then
                Function.EnhancedClickExecute(Part:FindFirstAncestorOfClass("Model"))
            end
        end
    end)
    
    -- Enhanced Right Click for complete reset
    local EnhancedMouseDown2 = Mouse.Button2Down:Connect(function()
        if ClickExecute == true and not ClickExecuteCooldown then
            ClickExecuteCooldown = true
            local Part = Mouse.Target

            if Part and Part:FindFirstAncestorOfClass("Model") ~= nil then
                if Function.IsCharacter(Part:FindFirstAncestorOfClass("Model")) then
                    if game.Players:GetPlayerFromCharacter(Part:FindFirstAncestorOfClass("Model")) then
                        Function.CharacterReset(Part:FindFirstAncestorOfClass("Model").Name, true)
                    else
                        Function.CharacterReset(Part:FindFirstAncestorOfClass("Model"), true)
                    end
                    Function.ShowNotification("Complete Reset", "Removed all accessories including protected ones", Color3.fromRGB(255, 130, 70))
                end
            end
            ClickExecuteCooldown = false
        end
    end)
    
    table.insert(AllConnect, EnhancedMouseDown)
    table.insert(AllConnect, EnhancedMouseDown2)
end

-- ==================== INITIALIZATION ====================
function Function.InitializeEnhancedClickExecuteWithUI()
    Function.InitializeEnhancedUI()
    Function.SetupEnhancedClickExecute()
    Function.SwitchTab("Protection") -- Start with protection tab
    
    warn("===============================================")
    warn("RoClothes ClickExecute Enhanced v1.0 WITH UI - LOADED!")
    warn("===============================================")
    warn("✓ Protected accessories: face, eyes, mask, glasses, hat")
    warn("✓ Enhanced Tab System with smooth animations")
    warn("✓ Protection Manager with keyword management")
    warn("✓ Visual notifications and feedback")
    warn("✓ Left Click: Safe apply (protect keywords)")
    warn("✓ Right Click: Complete reset (remove all)")
    warn("✓ Modern UI with better UX")
    warn("===============================================")
end

--[[
INTEGRATION INSTRUCTIONS:

1. Paste this code vào cuối function RoClothes (trước dòng end cuối)

2. Comment out hoặc xóa:
   - Original MouseDown events (dòng ~12873)
   - Original UI setup cho tabs (nếu có)

3. Thêm dòng này ở cuối function RoClothes:
   Function.InitializeEnhancedClickExecuteWithUI()

4. Chạy script và enjoy enhanced UI!

FEATURES:
- Modern Tab System với smooth animations
- Protection Manager để quản lý keywords
- Visual notifications
- Better UX/UI design
- Safe ClickExecute với keyword protection
]]