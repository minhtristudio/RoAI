--[[
RoClothes Enhancement Patch v0.7.5
Patch để thêm chức năng Model/Player Selection + Mobile Support vào RoClothes gốc

Hướng dẫn sử dụng:
1. Copy toàn bộ code này
2. Paste vào cuối script RoClothes gốc, trước dòng cuối cùng (trước end của function RoClothes)
3. Thêm dòng gọi initialization ở cuối function RoClothes

ENHANCED FEATURES:
- Click to select any model/player with Humanoid
- Mobile touch support (short tap = select, long press = execute)
- Target selection UI showing current target
- Visual highlighting of selected target
- Target list dropdown
]]

-- ==================== ENHANCED VARIABLES ====================
local TargetSelectionMode = false
local CurrentTarget = nil
local CurrentTargetName = Player.Name
local TargetHighlight = nil
local SelectionConnections = {}
local MobileMode = not UIS.KeyboardEnabled
local TouchConnections = {}
local LastTouchPosition = nil
local TouchStartTime = 0
local TOUCH_HOLD_TIME = 0.5

-- ==================== ENHANCED GUI OBJECTS ====================
-- Target Selection Frame
GUIObject.TargetFrame = Instance.new("Frame")
GUIObject.TargetLabel = Instance.new("TextLabel") 
GUIObject.TargetSelectButton = Instance.new("TextButton")
GUIObject.TargetModeButton = Instance.new("TextButton")
GUIObject.TargetList = Instance.new("ScrollingFrame")
GUIObject.TargetUICorner = Instance.new("UICorner")
GUIObject.TargetUIGradient = Instance.new("UIGradient")
GUIObject.TargetUIListLayout = Instance.new("UIListLayout")

-- Mobile Support Elements
GUIObject.MobileTargetButton = Instance.new("ImageButton")
GUIObject.MobileTargetFrame = Instance.new("Frame") 
GUIObject.TouchIndicator = Instance.new("Frame")

-- ==================== ENHANCED FUNCTIONS ====================

-- Create visual highlight for selected target
function Function.CreateTargetHighlight(target)
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

-- Set current target and update UI
function Function.SetCurrentTarget(target, targetName)
	CurrentTarget = target
	CurrentTargetName = targetName or (target and target.Name) or Player.Name
	SelectPlayer = CurrentTargetName
	
	-- Update UI
	if GUIObject.TargetLabel then
		local targetType = "Player"
		if target and not game.Players:GetPlayerFromCharacter(target) then
			targetType = "Model"
		end
		GUIObject.TargetLabel.Text = "Target: " .. CurrentTargetName .. " (" .. targetType .. ")"
	end
	
	-- Create highlight
	Function.CreateTargetHighlight(target)
	
	-- Update player execute textbox
	if GUIObject.PlayerExecute then
		GUIObject.PlayerExecute.Text = CurrentTargetName
	end
	
	warn("Target selected: " .. CurrentTargetName .. " (" .. (target and "Model" or "Player") .. ")")
end

-- Get all selectable targets in workspace
function Function.GetAllSelectableTargets()
	local targets = {}
	
	-- Add all players
	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			table.insert(targets, {
				Name = player.Name,
				Character = player.Character,
				Type = "Player"
			})
		end
	end
	
	-- Add all NPCs/Models with humanoids
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(obj) then
			table.insert(targets, {
				Name = obj.Name,
				Character = obj,
				Type = "Model"
			})
		end
	end
	
	return targets
end

-- Update the target selection list
function Function.UpdateTargetList()
	-- Clear existing buttons
	for _, child in pairs(GUIObject.TargetList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	local targets = Function.GetAllSelectableTargets()
	
	for i, target in pairs(targets) do
		local button = Instance.new("TextButton")
		button.Name = "TargetButton_" .. target.Name
		button.Parent = GUIObject.TargetList
		button.Size = UDim2.new(1, -10, 0, 30)
		button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		button.BorderSizePixel = 0
		button.Font = Enum.Font.Code
		button.Text = target.Name .. " (" .. target.Type .. ")"
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextScaled = true
		
		-- Add corner
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 5)
		corner.Parent = button
		
		-- Button click
		button.MouseButton1Click:Connect(function()
			Function.SetCurrentTarget(target.Character, target.Name)
			GUIObject.TargetList.Visible = false
		end)
		
		-- Highlight current target
		if target.Name == CurrentTargetName then
			button.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
		end
	end
end

-- Handle mobile touch input
function Function.HandleTouch(input, processed)
	if processed then return end
	
	if input.UserInputType == Enum.UserInputType.Touch then
		if input.UserInputState == Enum.UserInputState.Begin then
			LastTouchPosition = input.Position
			TouchStartTime = tick()
			
			-- Show touch indicator
			if GUIObject.TouchIndicator then
				GUIObject.TouchIndicator.Position = UDim2.new(0, input.Position.X - 25, 0, input.Position.Y - 25)
				GUIObject.TouchIndicator.Visible = true
				
				-- Animate touch indicator
				local tween = TS:Create(GUIObject.TouchIndicator, 
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{Size = UDim2.new(0, 100, 0, 100), BackgroundTransparency = 0.8}
				)
				tween:Play()
			end
			
		elseif input.UserInputState == Enum.UserInputState.End then
			local touchDuration = tick() - TouchStartTime
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
					if touchDuration >= TOUCH_HOLD_TIME then
						-- Long press - execute on target
						if ClickExecute then
							Function.ExecuteOnTarget(hitModel)
						end
					else
						-- Short tap - select target
						if TargetSelectionMode then
							Function.SetCurrentTarget(hitModel)
						end
					end
				end
			end
			
			-- Hide touch indicator
			if GUIObject.TouchIndicator then
				GUIObject.TouchIndicator.Visible = false
				GUIObject.TouchIndicator.Size = UDim2.new(0, 50, 0, 50)
				GUIObject.TouchIndicator.BackgroundTransparency = 0.5
			end
		end
	end
end

-- Enhanced execute function for targets
function Function.ExecuteOnTarget(targetModel)
	if not targetModel or not targetModel:FindFirstChild("Humanoid") then
		return
	end
	
	local targetName = targetModel.Name
	local isPlayer = game.Players:GetPlayerFromCharacter(targetModel) ~= nil
	
	if Function.IsCharacter(targetModel) then
		Function.CharacterReset(targetModel)
		
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
		
		warn("Executed on target: " .. targetName)
	end
end

-- Initialize enhanced UI elements
function Function.InitializeEnhancedUI()
	-- Target Selection Frame
	GUIObject.TargetFrame.Name = "TargetFrame"
	GUIObject.TargetFrame.Parent = GUIObject.Screen
	GUIObject.TargetFrame.AnchorPoint = Vector2.new(0.5, 0)
	GUIObject.TargetFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	GUIObject.TargetFrame.BorderSizePixel = 0
	GUIObject.TargetFrame.Position = UDim2.new(0.5, 0, 0, 10)
	GUIObject.TargetFrame.Size = UDim2.new(0, 400, 0, 50)
	
	GUIObject.TargetUICorner.CornerRadius = UDim.new(0, 10)
	GUIObject.TargetUICorner.Parent = GUIObject.TargetFrame
	
	GUIObject.TargetUIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.0, Color3.fromRGB(40, 40, 40)),
		ColorSequenceKeypoint.new(1.0, Color3.fromRGB(20, 20, 20))
	})
	GUIObject.TargetUIGradient.Rotation = 90
	GUIObject.TargetUIGradient.Parent = GUIObject.TargetFrame
	
	-- Target Label
	GUIObject.TargetLabel.Name = "TargetLabel"
	GUIObject.TargetLabel.Parent = GUIObject.TargetFrame
	GUIObject.TargetLabel.BackgroundTransparency = 1
	GUIObject.TargetLabel.Position = UDim2.new(0, 10, 0, 5)
	GUIObject.TargetLabel.Size = UDim2.new(1, -120, 1, -10)
	GUIObject.TargetLabel.Font = Enum.Font.Code
	GUIObject.TargetLabel.Text = "Target: " .. Player.Name .. " (Player)"
	GUIObject.TargetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	GUIObject.TargetLabel.TextScaled = true
	GUIObject.TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Target Select Button
	GUIObject.TargetSelectButton.Name = "TargetSelectButton"
	GUIObject.TargetSelectButton.Parent = GUIObject.TargetFrame
	GUIObject.TargetSelectButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
	GUIObject.TargetSelectButton.BorderSizePixel = 0
	GUIObject.TargetSelectButton.Position = UDim2.new(1, -100, 0, 5)
	GUIObject.TargetSelectButton.Size = UDim2.new(0, 45, 1, -10)
	GUIObject.TargetSelectButton.Font = Enum.Font.Code
	GUIObject.TargetSelectButton.Text = "Select"
	GUIObject.TargetSelectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	GUIObject.TargetSelectButton.TextScaled = true
	
	local selectCorner = Instance.new("UICorner")
	selectCorner.CornerRadius = UDim.new(0, 5)
	selectCorner.Parent = GUIObject.TargetSelectButton
	
	-- Target Mode Button
	GUIObject.TargetModeButton.Name = "TargetModeButton"
	GUIObject.TargetModeButton.Parent = GUIObject.TargetFrame
	GUIObject.TargetModeButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
	GUIObject.TargetModeButton.BorderSizePixel = 0
	GUIObject.TargetModeButton.Position = UDim2.new(1, -50, 0, 5)
	GUIObject.TargetModeButton.Size = UDim2.new(0, 45, 1, -10)
	GUIObject.TargetModeButton.Font = Enum.Font.Code
	GUIObject.TargetModeButton.Text = "Mode"
	GUIObject.TargetModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	GUIObject.TargetModeButton.TextScaled = true
	
	local modeCorner = Instance.new("UICorner")
	modeCorner.CornerRadius = UDim.new(0, 5)
	modeCorner.Parent = GUIObject.TargetModeButton
	
	-- Target List
	GUIObject.TargetList.Name = "TargetList"
	GUIObject.TargetList.Parent = GUIObject.Screen
	GUIObject.TargetList.AnchorPoint = Vector2.new(0.5, 0)
	GUIObject.TargetList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	GUIObject.TargetList.BorderSizePixel = 0
	GUIObject.TargetList.Position = UDim2.new(0.5, 0, 0, 70)
	GUIObject.TargetList.Size = UDim2.new(0, 400, 0, 200)
	GUIObject.TargetList.Visible = false
	GUIObject.TargetList.ScrollBarThickness = 5
	GUIObject.TargetList.CanvasSize = UDim2.new(0, 0, 0, 0)
	GUIObject.TargetList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	
	local listCorner = Instance.new("UICorner")
	listCorner.CornerRadius = UDim.new(0, 10)
	listCorner.Parent = GUIObject.TargetList
	
	GUIObject.TargetUIListLayout.Parent = GUIObject.TargetList
	GUIObject.TargetUIListLayout.SortOrder = Enum.SortOrder.Name
	GUIObject.TargetUIListLayout.Padding = UDim.new(0, 5)
	
	-- Mobile Support Elements
	if MobileMode then
		-- Mobile Target Button
		GUIObject.MobileTargetButton.Name = "MobileTargetButton"
		GUIObject.MobileTargetButton.Parent = GUIObject.Screen
		GUIObject.MobileTargetButton.AnchorPoint = Vector2.new(1, 0)
		GUIObject.MobileTargetButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
		GUIObject.MobileTargetButton.BorderSizePixel = 0
		GUIObject.MobileTargetButton.Position = UDim2.new(1, -10, 0, 10)
		GUIObject.MobileTargetButton.Size = UDim2.new(0, 60, 0, 60)
		GUIObject.MobileTargetButton.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		
		local mobileCorner = Instance.new("UICorner")
		mobileCorner.CornerRadius = UDim.new(0.5, 0)
		mobileCorner.Parent = GUIObject.MobileTargetButton
		
		-- Touch Indicator
		GUIObject.TouchIndicator.Name = "TouchIndicator"
		GUIObject.TouchIndicator.Parent = GUIObject.Screen
		GUIObject.TouchIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
		GUIObject.TouchIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
		GUIObject.TouchIndicator.BackgroundTransparency = 0.5
		GUIObject.TouchIndicator.BorderSizePixel = 0
		GUIObject.TouchIndicator.Size = UDim2.new(0, 50, 0, 50)
		GUIObject.TouchIndicator.Visible = false
		
		local touchCorner = Instance.new("UICorner")
		touchCorner.CornerRadius = UDim.new(0.5, 0)
		touchCorner.Parent = GUIObject.TouchIndicator
	end
	
	warn("Enhanced UI initialized successfully!")
end

-- Setup enhanced input handling
function Function.SetupEnhancedInput()
	-- Button connections
	local TargetSelectConnect = GUIObject.TargetSelectButton.MouseButton1Click:Connect(function()
		Function.UpdateTargetList()
		GUIObject.TargetList.Visible = not GUIObject.TargetList.Visible
	end)
	
	local TargetModeConnect = GUIObject.TargetModeButton.MouseButton1Click:Connect(function()
		TargetSelectionMode = not TargetSelectionMode
		GUIObject.TargetModeButton.BackgroundColor3 = TargetSelectionMode and 
			Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 100, 0)
		GUIObject.TargetModeButton.Text = TargetSelectionMode and "ON" or "Mode"
		warn("Target Selection Mode: " .. (TargetSelectionMode and "ON" or "OFF"))
	end)
	
	-- Mobile touch input
	if MobileMode then
		local TouchConnection = UIS.InputBegan:Connect(Function.HandleTouch)
		table.insert(TouchConnections, TouchConnection)
		
		if GUIObject.MobileTargetButton then
			local MobileBtnConnect = GUIObject.MobileTargetButton.MouseButton1Click:Connect(function()
				Function.UpdateTargetList()
				GUIObject.TargetList.Visible = not GUIObject.TargetList.Visible
			end)
			table.insert(AllConnect, MobileBtnConnect)
		end
	end
	
	table.insert(AllConnect, TargetSelectConnect)
	table.insert(AllConnect, TargetModeConnect)
	for _, connection in pairs(TouchConnections) do
		table.insert(AllConnect, connection)
	end
	
	warn("Enhanced input handling setup complete!")
	warn("Mobile mode: " .. (MobileMode and "ENABLED" or "DISABLED"))
end

-- Enhanced Mouse Down Event (REPLACE the original MouseDown in the script)
function Function.SetupEnhancedMouseDown()
	local cooldown = false
	local EnhancedMouseDown = Mouse.Button1Down:Connect(function()
		IsMouseDown = true
		MouseDownStart = UIS:GetMouseLocation()
		GuiPositionStart = GUIObject.MainFrame.Position

		if ClickExecute == true and cooldown == false then
			cooldown = true
			local Part = Mouse.Target

			if Part and Part:FindFirstAncestorOfClass("Model") ~= nil then
				Function.ExecuteOnTarget(Part:FindFirstAncestorOfClass("Model"))
			end
			cooldown = false
		elseif TargetSelectionMode and cooldown == false then
			cooldown = true
			local Part = Mouse.Target
			if Part and Part:FindFirstAncestorOfClass("Model") ~= nil then
				local targetModel = Part:FindFirstAncestorOfClass("Model")
				if targetModel:FindFirstChild("Humanoid") then
					Function.SetCurrentTarget(targetModel)
				end
			end
			cooldown = false
		end
	end)
	
	table.insert(AllConnect, EnhancedMouseDown)
end

-- ==================== INITIALIZATION FUNCTION ====================
function Function.InitializeEnhancedRoClothes()
	-- Initialize the enhanced system
	Function.InitializeEnhancedUI()
	Function.SetupEnhancedInput()
	Function.SetupEnhancedMouseDown()
	Function.SetCurrentTarget(Player.Character, Player.Name)
	
	warn("==========================================")
	warn("RoClothes Enhanced v0.7.5 - LOADED!")
	warn("==========================================")
	warn("New Features Added:")
	warn("✓ Click to select any model/player")
	warn("✓ Mobile touch support")
	warn("✓ Target selection UI")
	warn("✓ Enhanced click execute")
	warn("✓ Visual target highlighting")
	warn("")
	warn("Controls:")
	warn("PC - Click 'Mode' button to enable selection mode")
	warn("PC - Click 'Select' button to open target list")
	warn("Mobile - Use mobile target button (top right)")
	warn("Mobile - Short tap = select, Long press = execute")
	warn("==========================================")
end

--[[
INTEGRATION INSTRUCTIONS:

1. Paste this entire code at the END of the RoClothes function (before the final 'end')

2. Add this line at the very end of the RoClothes function (before the final 'end'):
   Function.InitializeEnhancedRoClothes()

3. If you want to replace the original mouse handling, find the original MouseDown event
   and comment it out, then the enhanced version will take over automatically.

4. Make sure the GUIObject.Screen is properly parented to Players.LocalPlayer:WaitForChild("PlayerGui")

That's it! The enhanced features will be automatically added to your RoClothes script.
]]