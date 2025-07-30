--[[
RoClothes Enhanced Demo Script
Tạo demo để test các tính năng mới

Features to test:
- Target selection UI
- Mobile touch controls  
- Model/Player detection
- Highlight system
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Demo Variables
local DemoGUI = {}
local CurrentTarget = nil
local TargetHighlight = nil
local MobileMode = not UserInputService.KeyboardEnabled

-- Create Demo GUI
function CreateDemoGUI()
    -- Screen GUI
    DemoGUI.Screen = Instance.new("ScreenGui")
    DemoGUI.Screen.Name = "RoClothesEnhancedDemo"
    DemoGUI.Screen.Parent = Player:WaitForChild("PlayerGui")
    
    -- Main Demo Frame
    DemoGUI.MainFrame = Instance.new("Frame")
    DemoGUI.MainFrame.Name = "DemoFrame"
    DemoGUI.MainFrame.Parent = DemoGUI.Screen
    DemoGUI.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    DemoGUI.MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    DemoGUI.MainFrame.BorderSizePixel = 0
    DemoGUI.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    DemoGUI.MainFrame.Size = UDim2.new(0, 400, 0, 300)
    
    -- Add corner to main frame
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = DemoGUI.MainFrame
    
    -- Title
    DemoGUI.Title = Instance.new("TextLabel")
    DemoGUI.Title.Name = "Title"
    DemoGUI.Title.Parent = DemoGUI.MainFrame
    DemoGUI.Title.BackgroundTransparency = 1
    DemoGUI.Title.Position = UDim2.new(0, 0, 0, 10)
    DemoGUI.Title.Size = UDim2.new(1, 0, 0, 40)
    DemoGUI.Title.Font = Enum.Font.SourceSansBold
    DemoGUI.Title.Text = "RoClothes Enhanced Demo"
    DemoGUI.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    DemoGUI.Title.TextScaled = true
    
    -- Current Target Label
    DemoGUI.TargetLabel = Instance.new("TextLabel")
    DemoGUI.TargetLabel.Name = "TargetLabel"
    DemoGUI.TargetLabel.Parent = DemoGUI.MainFrame
    DemoGUI.TargetLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    DemoGUI.TargetLabel.BorderSizePixel = 0
    DemoGUI.TargetLabel.Position = UDim2.new(0, 20, 0, 60)
    DemoGUI.TargetLabel.Size = UDim2.new(1, -40, 0, 30)
    DemoGUI.TargetLabel.Font = Enum.Font.Code
    DemoGUI.TargetLabel.Text = "Target: " .. Player.Name .. " (Self)"
    DemoGUI.TargetLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    DemoGUI.TargetLabel.TextScaled = true
    
    local targetCorner = Instance.new("UICorner")
    targetCorner.CornerRadius = UDim.new(0, 5)
    targetCorner.Parent = DemoGUI.TargetLabel
    
    -- Instructions
    DemoGUI.Instructions = Instance.new("TextLabel")
    DemoGUI.Instructions.Name = "Instructions"
    DemoGUI.Instructions.Parent = DemoGUI.MainFrame
    DemoGUI.Instructions.BackgroundTransparency = 1
    DemoGUI.Instructions.Position = UDim2.new(0, 20, 0, 100)
    DemoGUI.Instructions.Size = UDim2.new(1, -40, 0, 120)
    DemoGUI.Instructions.Font = Enum.Font.Code
    DemoGUI.Instructions.TextColor3 = Color3.fromRGB(200, 200, 200)
    DemoGUI.Instructions.TextScaled = true
    DemoGUI.Instructions.TextWrapped = true
    DemoGUI.Instructions.TextXAlignment = Enum.TextXAlignment.Left
    DemoGUI.Instructions.TextYAlignment = Enum.TextYAlignment.Top
    
    if MobileMode then
        DemoGUI.Instructions.Text = [[Mobile Controls:
• Tap on any character to select
• Target will be highlighted in cyan
• Long press (0.5s) for actions
• Works with players and NPCs]]
    else
        DemoGUI.Instructions.Text = [[PC Controls:
• Click on any character to select
• Target will be highlighted in cyan
• Right-click for additional actions
• Works with players and NPCs]]
    end
    
    -- Close Button
    DemoGUI.CloseButton = Instance.new("TextButton")
    DemoGUI.CloseButton.Name = "CloseButton"
    DemoGUI.CloseButton.Parent = DemoGUI.MainFrame
    DemoGUI.CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    DemoGUI.CloseButton.BorderSizePixel = 0
    DemoGUI.CloseButton.Position = UDim2.new(0, 20, 1, -50)
    DemoGUI.CloseButton.Size = UDim2.new(1, -40, 0, 30)
    DemoGUI.CloseButton.Font = Enum.Font.SourceSansBold
    DemoGUI.CloseButton.Text = "Close Demo"
    DemoGUI.CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DemoGUI.CloseButton.TextScaled = true
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = DemoGUI.CloseButton
    
    -- Mobile Touch Indicator
    if MobileMode then
        DemoGUI.TouchIndicator = Instance.new("Frame")
        DemoGUI.TouchIndicator.Name = "TouchIndicator"
        DemoGUI.TouchIndicator.Parent = DemoGUI.Screen
        DemoGUI.TouchIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
        DemoGUI.TouchIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        DemoGUI.TouchIndicator.BackgroundTransparency = 0.5
        DemoGUI.TouchIndicator.BorderSizePixel = 0
        DemoGUI.TouchIndicator.Size = UDim2.new(0, 50, 0, 50)
        DemoGUI.TouchIndicator.Visible = false
        
        local touchCorner = Instance.new("UICorner")
        touchCorner.CornerRadius = UDim.new(0.5, 0)
        touchCorner.Parent = DemoGUI.TouchIndicator
    end
end

-- Create Target Highlight
function CreateTargetHighlight(target)
    if TargetHighlight then
        TargetHighlight:Destroy()
    end
    
    if target and target:FindFirstChild("Humanoid") then
        TargetHighlight = Instance.new("Highlight")
        TargetHighlight.Parent = target
        TargetHighlight.FillColor = Color3.fromRGB(0, 255, 255)
        TargetHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        TargetHighlight.FillTransparency = 0.7
        TargetHighlight.OutlineTransparency = 0
        TargetHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
end

-- Set Current Target
function SetCurrentTarget(target)
    CurrentTarget = target
    
    if target then
        local targetName = target.Name
        local targetType = "Model"
        
        if game.Players:GetPlayerFromCharacter(target) then
            targetType = "Player"
        end
        
        DemoGUI.TargetLabel.Text = "Target: " .. targetName .. " (" .. targetType .. ")"
        CreateTargetHighlight(target)
        
        print("Selected target:", targetName, "(" .. targetType .. ")")
    else
        DemoGUI.TargetLabel.Text = "Target: None"
        if TargetHighlight then
            TargetHighlight:Destroy()
            TargetHighlight = nil
        end
    end
end

-- Handle Mouse Click
function HandleMouseClick()
    local target = Mouse.Target
    if target then
        local model = target:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChild("Humanoid") then
            SetCurrentTarget(model)
        end
    end
end

-- Handle Mobile Touch
function HandleTouch(input, processed)
    if processed then return end
    
    if input.UserInputType == Enum.UserInputType.Touch then
        if input.UserInputState == Enum.UserInputState.Begin then
            -- Show touch indicator
            if DemoGUI.TouchIndicator then
                DemoGUI.TouchIndicator.Position = UDim2.new(0, input.Position.X - 25, 0, input.Position.Y - 25)
                DemoGUI.TouchIndicator.Visible = true
                
                -- Animate touch indicator
                local tween = TweenService:Create(DemoGUI.TouchIndicator, 
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(0, 100, 0, 100), BackgroundTransparency = 0.8}
                )
                tween:Play()
            end
            
        elseif input.UserInputState == Enum.UserInputState.End then
            -- Raycast to find target
            local camera = workspace.CurrentCamera
            local ray = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {Player.Character}
            
            local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            
            if raycastResult then
                local hitPart = raycastResult.Instance
                local hitModel = hitPart:FindFirstAncestorOfClass("Model")
                
                if hitModel and hitModel:FindFirstChild("Humanoid") then
                    SetCurrentTarget(hitModel)
                end
            end
            
            -- Hide touch indicator
            if DemoGUI.TouchIndicator then
                DemoGUI.TouchIndicator.Visible = false
                DemoGUI.TouchIndicator.Size = UDim2.new(0, 50, 0, 50)
                DemoGUI.TouchIndicator.BackgroundTransparency = 0.5
            end
        end
    end
end

-- Setup Event Connections
function SetupEvents()
    -- Mouse click for PC
    Mouse.Button1Down:Connect(HandleMouseClick)
    
    -- Touch input for mobile
    if MobileMode then
        UserInputService.InputBegan:Connect(HandleTouch)
    end
    
    -- Close button
    DemoGUI.CloseButton.MouseButton1Click:Connect(function()
        DemoGUI.Screen:Destroy()
        if TargetHighlight then
            TargetHighlight:Destroy()
        end
    end)
end

-- Initialize Demo
function InitializeDemo()
    CreateDemoGUI()
    SetupEvents()
    SetCurrentTarget(Player.Character)
    
    print("==============================================")
    print("RoClothes Enhanced Demo Started!")
    print("==============================================")
    print("Platform:", MobileMode and "Mobile" or "PC")
    print("Instructions:")
    if MobileMode then
        print("- Tap on any character to select them")
        print("- Character will be highlighted in cyan")
        print("- Works with both players and NPCs")
    else
        print("- Click on any character to select them") 
        print("- Character will be highlighted in cyan")
        print("- Works with both players and NPCs")
    end
    print("==============================================")
end

-- Start the demo
InitializeDemo()