--// bot camlock (like da track etc)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local camlockEnabled = false
local smoothness = 0.362
local predictionHorizontal = 0
local predictionVertical = 0.16
local shakeX = 0
local shakeY = 0
local shakeZ = 0

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CamlockUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = gethui and gethui() or game:GetService("CoreGui")

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
camlockBtn.Draggable = true
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
terminateBtn.Draggable = true
terminateBtn.Parent = screenGui

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 12)
corner2.Parent = terminateBtn

camlockBtn.MouseButton1Click:Connect(function()
    camlockEnabled = not camlockEnabled
    camlockBtn.Text = camlockEnabled and "Camlock: ON" or "Camlock: OFF"
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Y then
        camlockEnabled = not camlockEnabled
        camlockBtn.Text = camlockEnabled and "Camlock: ON" or "Camlock: OFF"
    end
end)

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

terminateBtn.MouseButton1Click:Connect(terminateScript)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        terminateScript()
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

        local predictedPosition = head.Position + predictionOffset

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
