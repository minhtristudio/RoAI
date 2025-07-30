--[[
RoClothes ClickExecute Enhancement Patch v1.0 - NO UI UPDATE
Patch nâng cấp ClickExecute để bảo vệ accessories face/eyes

FEATURES:
- Bảo vệ accessories có từ "face", "eyes" trong tên khi ClickExecute
- Không thay đổi giao diện hiện tại
- Tương thích hoàn toàn với RoClothes gốc

HƯỚNG DẪN:
1. Paste code này vào cuối function RoClothes (trước dòng end cuối)
2. Comment out đoạn MouseDown gốc và thay bằng Enhanced version
]]

-- ==================== ENHANCED CLICKEXECUTE VARIABLES ====================
local ProtectedAccessoryKeywords = {"face", "eyes", "mask", "glasses"} -- Từ khóa bảo vệ
local ClickExecuteCooldown = false

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
    
    for _, accessory in pairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            if Function.IsProtectedAccessory(accessory) then
                protectedCount = protectedCount + 1
                warn("Protected accessory: " .. accessory.Name)
            else
                accessory:Destroy()
                removedCount = removedCount + 1
            end
        end
    end
    
    warn("Removed " .. removedCount .. " accessories, Protected " .. protectedCount .. " face/eyes accessories")
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
        Function.SafeRemoveAccessories(targetModel)
        
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
        
        warn("Enhanced ClickExecute applied to: " .. targetName .. " (Protected face/eyes accessories)")
    end
    
    wait(0.1) -- Cooldown
    ClickExecuteCooldown = false
end

-- ==================== ENHANCED MOUSE HANDLING ====================

-- Enhanced Mouse Down Event - REPLACE THE ORIGINAL MouseDown
function Function.SetupEnhancedClickExecute()
    -- Comment out hoặc xóa MouseDown gốc, sau đó thêm cái này
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
    
    -- Enhanced Right Click for complete reset (bao gồm cả face/eyes)
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
                    warn("Complete reset applied (including face/eyes accessories)")
                end
            end
            ClickExecuteCooldown = false
        end
    end)
    
    table.insert(AllConnect, EnhancedMouseDown)
    table.insert(AllConnect, EnhancedMouseDown2)
    
    warn("Enhanced ClickExecute setup complete!")
    warn("Left Click: Apply clothes (protect face/eyes)")
    warn("Right Click: Complete reset (remove all)")
end

-- ==================== INITIALIZATION ====================
function Function.InitializeEnhancedClickExecute()
    Function.SetupEnhancedClickExecute()
    
    warn("===============================================")
    warn("RoClothes ClickExecute Enhanced v1.0 - LOADED!")
    warn("===============================================")
    warn("✓ Protected accessories: face, eyes, mask, glasses")
    warn("✓ Left Click: Safe apply (protect face/eyes)")
    warn("✓ Right Click: Complete reset")
    warn("✓ No UI changes - same interface")
    warn("===============================================")
end

--[[
INTEGRATION INSTRUCTIONS:

1. Paste this code vào cuối function RoClothes (trước dòng end cuối)

2. Tìm đoạn MouseDown gốc trong script (khoảng dòng 12873):
   local MouseDown = Mouse.Button1Down:Connect(function()
   
   Comment out hoặc xóa toàn bộ đoạn MouseDown gốc

3. Thêm dòng này ở cuối function RoClothes:
   Function.InitializeEnhancedClickExecute()

4. Chạy script và test!

TESTING:
- ClickExecute ON + Left Click: Sẽ bảo vệ face/eyes accessories
- ClickExecute ON + Right Click: Xóa hoàn toàn như cũ
]]