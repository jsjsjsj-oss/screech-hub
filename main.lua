--[[Screech Hub - Main Script]]
local Config = require(script.Parent.config)

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Player Info
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- UI Creation (Screech Hub Title)
local UI = Instance.new("ScreenGui")
UI.Name = "ScreechHubUI"
UI.Parent = CoreGui

-- Top Left Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 150, 0, 30)
TitleLabel.Position = UDim2.new(0.01, 0, 0.01, 0)
TitleLabel.Text = Config.UIName
TitleLabel.TextColor3 = Config.UIColor
TitleLabel.TextSize = 22
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = UI

-- ESP UI
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "ScreechESP"
ESPGui.Parent = CoreGui

-- Tool: Create ESP Label
local function createESPLabel(target, color, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, Config.ESP.Door.TextSize)
    label.Text = text or target.Name
    label.TextColor3 = color
    label.TextSize = Config.ESP.Door.TextSize
    label.Font = Enum.Font.SourceSansBold
    label.BackgroundTransparency = 1
    label.Parent = ESPGui

    RunService.RenderStepped:Connect(function()
        if not target or not target.Parent then label:Destroy() return end
        local pos, onScreen = Camera:WorldToScreenPoint(target.Position)
        if onScreen then
            label.Position = UDim2.new(0, pos.X - 100, 0, pos.Y - 30)
        else
            label.Visible = false
        end
    end)
    return label
end

-- Tool: Create Tracer
local function createTracer(target, color)
    local line = Instance.new("LineHandleAdornment")
    line.Adornee = RootPart
    line.ZIndex = 10
    line.Color3 = color
    line.Thickness = 2
    line.Parent = ESPGui

    RunService.RenderStepped:Connect(function()
        if not target or not target.Parent then line:Destroy() return end
        local pos = Camera:WorldToViewportPoint(target.Position)
        line.From = Vector3.new(0, 0, 0)
        line.To = Camera:ViewportPointToWorldPoint(Vector3.new(pos.X, pos.Y, Camera.NearPlaneDistance)) - RootPart.Position
    end)
    return line
end

-- 1. Godmode
if Config.Survival.Godmode then
    Humanoid.HealthChanged:Connect(function()
        Humanoid.Health = Humanoid.MaxHealth
    end)
    Humanoid.Died:Connect(function()
        Character = LocalPlayer.CharacterAdded:Wait()
        Humanoid = Character:WaitForChild("Humanoid")
        RootPart = Character:WaitForChild("HumanoidRootPart")
    end)
end

-- 2. Fly
local isFlying = Config.Movement.Fly
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[Config.Keybinds.Fly] then
        isFlying = not isFlying
        Humanoid.PlatformStand = isFlying
    end
end)

RunService.RenderStepped:Connect(function()
    if isFlying then
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Vector3.new(0, 0, -1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir += Vector3.new(0, 0, 1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir += Vector3.new(-1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Vector3.new(1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir += Vector3.new(0, -1, 0) end
        RootPart.Velocity = moveDir.Unit * Config.Movement.FlySpeed
    end
end)

-- 3. Speed Boost
if Config.Movement.SpeedBoost > 0 then
    Humanoid.WalkSpeed = Humanoid.WalkSpeed + Config.Movement.SpeedBoost
    Humanoid.JumpPower = Humanoid.JumpPower + Config.Movement.JumpBoost
end

-- 4. Fullbright
if Config.Visual.Fullbright then
    Lighting.Brightness = 2
    Lighting.Contrast = 1
    Lighting.ColorShift_Top = Color3.new(1, 1, 1)
end

-- 5. No Fog
if Config.Visual.NoFog then
    Lighting.FogEnd = 10000
end

-- 6. ESP System
RunService.RenderStepped:Connect(function()
    -- Door ESP
    if Config.ESP.Door.Enabled then
        for _, door in ipairs(Workspace:GetDescendants()) do
            if door.Name:lower():find("door") and (door:FindFirstChild("ClickDetector") or door:FindFirstChild("TouchTransmitter")) then
                local dist = (RootPart.Position - door.Position).Magnitude
                if dist <= Config.ESP.Distance then
                    createESPLabel(door, Config.ESP.Door.Color)
                    if Config.ESP.Door.Tracers then createTracer(door, Config.ESP.Door.Color) end
                end
            end
        end
    end

    -- Item ESP
    if Config.ESP.Item.Enabled then
        for _, item in ipairs(Workspace:GetDescendants()) do
            if item:IsA("Tool") or item.Name:lower():find("key") or item.Name:lower():find("item") then
                local dist = (RootPart.Position - item.Position).Magnitude
                if dist <= Config.ESP.Distance then
                    createESPLabel(item, Config.ESP.Item.Color)
                    if Config.ESP.Item.Tracers then createTracer(item, Config.ESP.Item.Color) end
                end
            end
        end
    end

    -- Entity ESP
    if Config.ESP.Entity.Enabled then
        for _, entity in ipairs(Workspace:GetDescendants()) do
            if entity.Name:lower():find("screech") or entity.Name:lower():find("eyes") or entity.Name:lower():find("figure") or entity.Name:lower():find("a90") then
                local dist = (RootPart.Position - entity.Position).Magnitude
                if dist <= Config.ESP.Distance then
                    createESPLabel(entity, Config.ESP.Entity.Color)
                    if Config.ESP.Entity.Tracers then createTracer(entity, Config.ESP.Entity.Color) end
                end
            end
        end
    end

    -- Gold ESP
    if Config.ESP.Gold.Enabled then
        for _, gold in ipairs(Workspace:GetDescendants()) do
            if gold.Name:lower():find("gold") or gold.Name:lower():find("coin") or gold.BrickColor == BrickColor.new("Gold") then
                local dist = (RootPart.Position - gold.Position).Magnitude
                if dist <= Config.ESP.Distance then
                    createESPLabel(gold, Config.ESP.Gold.Color)
                    if Config.ESP.Gold.Tracers then createTracer(gold, Config.ESP.Gold.Color) end
                end
            end
        end
    end

    -- Player ESP
    if Config.ESP.Player.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if playerRoot then
                    local dist = (RootPart.Position - playerRoot.Position).Magnitude
                    if dist <= Config.ESP.Distance then
                        createESPLabel(playerRoot, Config.ESP.Player.Color, player.Name)
                        if Config.ESP.Player.Tracers then createTracer(playerRoot, Config.ESP.Player.Color) end
                    end
                end
            end
        end
    end
end)

-- 7. Auto Interact
local isAutoInteract = Config.Auto.Interact
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[Config.Keybinds.AutoInteract] then
        isAutoInteract = not isAutoInteract
    end
end)

spawn(function()
    while wait(0.1) do
        if isAutoInteract then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:FindFirstChild("ClickDetector") then
                    local dist = (RootPart.Position - obj.Position).Magnitude
                    if dist <= 10 then
                        fireclickdetector(obj.ClickDetector)
                    end
                end
            end
        end
    end
end)

-- 8. Anti Jumpscares
if Config.Survival.AntiJumpscares then
    SoundService.Volume = 0.2
    RunService.RenderStepped:Connect(function()
        for _, entity in ipairs(Workspace:GetDescendants()) do
            if entity.Name:lower():find("screech") or entity.Name:lower():find("jump") then
                entity.Transparency = 1
            end
        end
    end)
end

-- 9. Third Person
local isThirdPerson = Config.Visual.ThirdPerson
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[Config.Keybinds.ThirdPerson] then
        isThirdPerson = not isThirdPerson
        Camera.CameraType = isThirdPerson and Enum.CameraType.Attach or Enum.CameraType.Custom
        if isThirdPerson then
            Camera.CFrame = RootPart.CFrame * CFrame.new(0, 2, 5)
        end
    end
end)

-- 10. No Cam Shake
if Config.Visual.NoCamShake then
    Camera.ShakeEnabled = false
end

print("[Screech Hub] 加载成功！左上角可看到标题，按对应按键使用功能～")
