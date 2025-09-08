--// bot camlock (like da track etc)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local predictionEnabled = true
local camlockEnabled = false
local smoothness = 0.362
local predictionHorizontal = 0
local predictionVertical = 0.16
local shakeX = 0
local shakeY = 0
local shakeZ = 0
local buttonsVisible = true

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CamlockUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = gethui and gethui() or game:GetService("CoreGui")

-- Function to create a draggable element
local function makeDraggable(gui, handle)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Notify user about keybinds
local function notifyKeybinds()
    local notification = Instance.new("ScreenGui")
    notification.Name = "KeybindNotification"
    notification.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Text = "Keybinds"
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.Parent = frame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 0, 80)
    text.Position = UDim2.new(0, 10, 0, 40)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Text = "Y - Toggle Camlock\nHome - Toggle Prediction\nRight Alt - Hide/Show Buttons\nDelete - Terminate Script\nF1 - Show Keybinds"
    text.Font = Enum.Font.SourceSans
    text.TextSize = 16
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.Parent = frame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 100, 0, 30)
    closeBtn.Position = UDim2.new(0.5, -50, 0.8, 0)
    closeBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Text = "Close"
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 16
    closeBtn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        notification:Destroy()
    end)
    
    -- Auto-close after 10 seconds
    delay(10, function()
        if notification and notification.Parent then
            notification:Destroy()
        end
    end)
end

-- Show notification when script starts
notifyKeybinds()

local camlockBtn = Instance.new("TextButton")
camlockBtn.Size = UDim2.new(0, 140, 0, 40)
camlockBtn.Position = UDim2.new(0.05, 0, 0.8, 0)
camlockBtn.BackgroundColor3 = Color3.new(0, 0, 0)
camlockBtn.BackgroundTransparency = 0.3
camlockBtn.TextColor3 = Color3.new(1, 1, 1)
camlockBtn.Text = "Camlock: OFF"
camlockBtn.Font = Enum.Font.SourceSansBold
camlockBtn.TextSize = 18
camlockBtn.Active = true
camlockBtn.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = camlockBtn

local terminateBtn = Instance.new("TextButton")
terminateBtn.Size = UDim2.new(0, 140, 0, 40)
terminateBtn.Position = UDim2.new(0.05, 0, 0.87, 0)
terminateBtn.BackgroundColor3 = Color3.new(0.3, 0, 0)
terminateBtn.BackgroundTransparency = 0.3
terminateBtn.TextColor3 = Color3.new(1, 1, 1)
terminateBtn.Text = "Terminate Script"
terminateBtn.Font = Enum.Font.SourceSansBold
terminateBtn.TextSize = 18
terminateBtn.Active = true
terminateBtn.Parent = screenGui

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 12)
corner2.Parent = terminateBtn

local predictionBtn = Instance.new("TextButton")
predictionBtn.Size = UDim2.new(0, 140, 0, 40)
predictionBtn.Position = UDim2.new(0.05, 0, 0.94, 0)
predictionBtn.BackgroundColor3 = Color3.new(0, 0, 0.3)
predictionBtn.BackgroundTransparency = 0.3
predictionBtn.TextColor3 = Color3.new(1, 1, 1)
predictionBtn.Text = "Prediction: ON"
predictionBtn.Font = Enum.Font.SourceSansBold
predictionBtn.TextSize = 18
predictionBtn.Active = true
predictionBtn.Parent = screenGui

local corner3 = Instance.new("UICorner")
corner3.CornerRadius = UDim.new(0, 12)
corner3.Parent = predictionBtn

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 140, 0, 40)
hideBtn.Position = UDim2.new(0.05, 0, 0.73, 0)
hideBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0)
hideBtn.BackgroundTransparency = 0.3
hideBtn.TextColor3 = Color3.new(1, 1, 1)
hideBtn.Text = "Hide Buttons"
hideBtn.Font = Enum.Font.SourceSansBold
hideBtn.TextSize = 18
hideBtn.Active = true
hideBtn.Parent = screenGui

local corner4 = Instance.new("UICorner")
corner4.CornerRadius = UDim.new(0, 12)
corner4.Parent = hideBtn

-- Make buttons draggable
makeDraggable(camlockBtn, camlockBtn)
makeDraggable(terminateBtn, terminateBtn)
makeDraggable(predictionBtn, predictionBtn)
makeDraggable(hideBtn, hideBtn)

predictionBtn.MouseButton1Click:Connect(function()
    predictionEnabled = not predictionEnabled
    predictionBtn.Text = predictionEnabled and "Prediction: ON" or "Prediction: OFF"
end)

camlockBtn.MouseButton1Click:Connect(function()
    camlockEnabled = not camlockEnabled
    camlockBtn.Text = camlockEnabled and "Camlock: ON" or "Camlock: OFF"
end)

-- Function to toggle buttons visibility
local function toggleButtonsVisibility()
    buttonsVisible = not buttonsVisible
    camlockBtn.Visible = buttonsVisible
    terminateBtn.Visible = buttonsVisible
    predictionBtn.Visible = buttonsVisible
    hideBtn.Text = buttonsVisible and "Hide Buttons" or "Show Buttons"
end

local function getTargetHead()
    local bots = Workspace:FindFirstChild("Bots")
    if bots then
        for _, bot in pairs(bots:GetChildren()) do
            if bot:FindFirstChild("Head") then
                return bot.Head
            end
        end
    end
    return nil
end

local old_fire
old_fire = hookfunction(require(ReplicatedStorage.Modules.Weapons.GunClient).Fire, function(self, tool, origin, target, config, bullet_num, mouse)
    local bots = Workspace:FindFirstChild("Bots")
    local bot = bots and bots:GetChildren()[1]
    if bot and bot:FindFirstChild("Head") then
        target = bot.Head.Position
    end
    return old_fire(self, tool, origin, target, config, bullet_num, mouse)
end)

local renderConn

local function terminateScript()
    camlockEnabled = false
    if screenGui then screenGui:Destroy() end
    if renderConn then renderConn:Disconnect() end
    if old_fire then require(ReplicatedStorage.Modules.Weapons.GunClient).Fire = old_fire end
    print("Camlock script terminated.")
end

-- Function to create confirmation popup
local function createConfirmationPopup(action, message, confirmCallback)
    local popupFrame = Instance.new("Frame")
    popupFrame.Size = UDim2.new(0, 300, 0, 150)
    popupFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    popupFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    popupFrame.BackgroundTransparency = 0.3
    popupFrame.BorderSizePixel = 0
    popupFrame.ZIndex = 10
    popupFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = popupFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Text = message
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.ZIndex = 11
    title.Parent = popupFrame
    
    local yesBtn = Instance.new("TextButton")
    yesBtn.Size = UDim2.new(0, 100, 0, 40)
    yesBtn.Position = UDim2.new(0.5, -110, 0.7, 0)
    yesBtn.BackgroundColor3 = action == "terminate" and Color3.new(0.3, 0, 0) or Color3.new(0, 0.3, 0)
    yesBtn.BackgroundTransparency = 0.3
    yesBtn.TextColor3 = Color3.new(1, 1, 1)
    yesBtn.Text = "Yes"
    yesBtn.Font = Enum.Font.SourceSansBold
    yesBtn.TextSize = 18
    yesBtn.ZIndex = 11
    yesBtn.Parent = popupFrame
    
    local yesCorner = Instance.new("UICorner")
    yesCorner.CornerRadius = UDim.new(0, 12)
    yesCorner.Parent = yesBtn
    
    local noBtn = Instance.new("TextButton")
    noBtn.Size = UDim2.new(0, 100, 0, 40)
    noBtn.Position = UDim2.new(0.5, 10, 0.7, 0)
    noBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    noBtn.BackgroundTransparency = 0.3
    noBtn.TextColor3 = Color3.new(1, 1, 1)
    noBtn.Text = "No"
    noBtn.Font = Enum.Font.SourceSansBold
    noBtn.TextSize = 18
    noBtn.ZIndex = 11
    noBtn.Parent = popupFrame
    
    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = UDim.new(0, 12)
    noCorner.Parent = noBtn
    
    yesBtn.MouseButton1Click:Connect(function()
        confirmCallback()
        popupFrame:Destroy()
    end)
    
    noBtn.MouseButton1Click:Connect(function()
        popupFrame:Destroy()
    end)
    
    -- Make popup draggable
    makeDraggable(popupFrame, title)
end

terminateBtn.MouseButton1Click:Connect(function()
    createConfirmationPopup("terminate", "Are you sure to terminate the script?", terminateScript)
end)

hideBtn.MouseButton1Click:Connect(function()
    createConfirmationPopup("hide", "Are you sure to " .. (buttonsVisible and "hide" or "show") .. " the buttons?", toggleButtonsVisibility)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Home then
        predictionEnabled = not predictionEnabled
        predictionBtn.Text = predictionEnabled and "Prediction: ON" or "Prediction: OFF"
        print("Prediction " .. (predictionEnabled and "Enabled" or "Disabled"))
    end
    if input.KeyCode == Enum.KeyCode.Y then
        camlockEnabled = not camlockEnabled
        camlockBtn.Text = camlockEnabled and "Camlock: ON" or "Camlock: OFF"
    end
    if input.KeyCode == Enum.KeyCode.RightAlt or input.KeyCode == Enum.KeyCode.RightControl then
        toggleButtonsVisibility()
    end
    if input.KeyCode == Enum.KeyCode.Delete then
        createConfirmationPopup("terminate", "Are you sure to terminate the script?", terminateScript)
    end
    if input.KeyCode == Enum.KeyCode.F1 then
        notifyKeybinds()
    end
end)

renderConn = RunService.RenderStepped:Connect(function()
    if not camlockEnabled then return end

    local head = getTargetHead()
    if head and head.Parent and head.Parent:FindFirstChild("HumanoidRootPart") then
        local hrp = head.Parent.HumanoidRootPart
        local velocity = hrp.Velocity

        local predictionOffset = Vector3.new(
            velocity.X * predictionHorizontal,
            velocity.Y * predictionVertical,
            velocity.Z * predictionHorizontal
        )

        local predictedPosition = head.Position + (predictionEnabled and predictionOffset or Vector3.zero)

        local shakeOffset = Vector3.new(
            (math.random() - 0.5) * shakeX,
            (math.random() - 0.5) * shakeY,
            (math.random() - 0.5) * shakeZ
        )

        local targetCFrame = CFrame.new(Camera.CFrame.Position, predictedPosition + shakeOffset)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothness)
    else
        camlockEnabled = false
        camlockBtn.Text = "Camlock: OFF"
        print("Target Lost - Camlock Disabled")
    end
end)
