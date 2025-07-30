# RoClothes Enhanced - Integration Guide

## Tính năng mới đã thêm

### 1. **Hệ thống chọn Model/Player**
- Click để chọn bất kỳ model/player nào có Humanoid
- Hiển thị target hiện tại trên UI
- Highlight visual cho target được chọn

### 2. **Hỗ trợ Mobile/Touch**
- Touch controls cho mobile devices
- Short tap: Chọn target (khi selection mode bật)
- Long press (0.5s): Execute trên target (khi click execute bật)
- Touch indicator animation

### 3. **Enhanced UI**
- Target selection frame ở top màn hình
- Target list dropdown với tất cả players/models
- Mobile target button cho touch devices
- Mode toggle cho selection mode

## Cách tích hợp vào RoClothes gốc

### Bước 1: Thêm Enhanced Variables

Sau dòng `local Function = {Spring = {}}`, thêm:

```lua
-- Enhanced Target Selection Variables (NEW)
local TargetSelectionMode = false
local CurrentTarget = nil
local CurrentTargetName = Player.Name
local TargetHighlight = nil
local SelectionConnections = {}
local MobileMode = not UIS.KeyboardEnabled

-- Enhanced Mobile Support Variables (NEW)
local TouchConnections = {}
local LastTouchPosition = nil
local TouchStartTime = 0
local TOUCH_HOLD_TIME = 0.5 -- Time to hold for selection
```

### Bước 2: Thêm Enhanced GUI Objects

Trong phần tạo GUIObject, thêm:

```lua
-- Target Selection Frame (NEW)
GUIObject.TargetFrame = Instance.new("Frame")
GUIObject.TargetLabel = Instance.new("TextLabel")
GUIObject.TargetSelectButton = Instance.new("TextButton")
GUIObject.TargetModeButton = Instance.new("TextButton")
GUIObject.TargetList = Instance.new("ScrollingFrame")
GUIObject.TargetUICorner = Instance.new("UICorner")
GUIObject.TargetUIGradient = Instance.new("UIGradient")
GUIObject.TargetUIListLayout = Instance.new("UIListLayout")

-- Mobile Support Elements (NEW)
GUIObject.MobileTargetButton = Instance.new("ImageButton")
GUIObject.MobileTargetFrame = Instance.new("Frame")
GUIObject.TouchIndicator = Instance.new("Frame")
```

### Bước 3: Thêm Enhanced Functions

Thêm các functions sau vào phần Function:

1. `Function.CreateTargetHighlight(target)`
2. `Function.SetCurrentTarget(target, targetName)`
3. `Function.GetAllSelectableTargets()`
4. `Function.UpdateTargetList()`
5. `Function.HandleTouch(input, processed)`
6. `Function.ExecuteOnTarget(targetModel)`
7. `Function.InitializeEnhancedUI()`
8. `Function.SetupEnhancedInput()`

### Bước 4: Modify Mouse Event Handling

Thay thế mouse event handling gốc với enhanced version:

```lua
local MouseDown = Mouse.Button1Down:Connect(function()
    IsMouseDown = true
    MouseDownStart = UIS:GetMouseLocation()
    GuiPositionStart = GUIObject.MainFrame.Position
    
    if ClickExecute == true then
        local Part = Mouse.Target
        if Part and Part:FindFirstAncestorOfClass("Model") ~= nil then
            Function.ExecuteOnTarget(Part:FindFirstAncestorOfClass("Model"))
        end
    elseif TargetSelectionMode then
        local Part = Mouse.Target
        if Part and Part:FindFirstAncestorOfClass("Model") ~= nil then
            local targetModel = Part:FindFirstAncestorOfClass("Model")
            if targetModel:FindFirstChild("Humanoid") then
                Function.SetCurrentTarget(targetModel)
            end
        end
    end
end)
```

### Bước 5: Initialize Enhanced Features

Sau khi setup UI gốc, thêm:

```lua
-- Initialize the enhanced system
Function.InitializeEnhancedUI()
Function.SetupEnhancedInput()
Function.SetCurrentTarget(Player.Character, Player.Name)
```

## Hướng dẫn sử dụng

### PC/Desktop:
1. **Target Selection Mode**: Click nút "Mode" để bật/tắt selection mode
2. **Select Target**: Khi selection mode bật, click vào character để chọn
3. **Target List**: Click nút "Select" để mở danh sách tất cả targets
4. **Execute**: Bật Click Execute và click vào target để apply clothes

### Mobile/Touch:
1. **Mobile Target Button**: Touch nút tròn ở góc phải để mở target list
2. **Short Tap**: Tap nhanh vào character để chọn (khi selection mode bật)
3. **Long Press**: Giữ 0.5s để execute trên target (khi click execute bật)
4. **Touch Indicator**: Hiệu ứng visual khi touch

## Các thay đổi chính

### Enhanced Mouse Handling:
- Thêm target selection logic
- Cải thiện execute function để hỗ trợ cả model và player
- Mobile touch support với raycast

### Enhanced UI:
- Target selection frame hiển thị target hiện tại
- Dropdown list với tất cả available targets
- Mobile-friendly buttons và controls
- Visual feedback với highlights và animations

### Enhanced Functionality:
- Automatic model/player detection
- NPC data management
- Cross-platform compatibility
- Visual target highlighting

## Compatibility Notes

- Tương thích với tất cả chức năng gốc của RoClothes
- Không break existing functionality
- Mobile-first design cho touch devices
- Automatic detection of input method (keyboard vs touch)

## Testing

Test trên:
- PC with mouse/keyboard
- Mobile devices (iOS/Android)
- Different screen sizes
- Multiple players/NPCs in workspace