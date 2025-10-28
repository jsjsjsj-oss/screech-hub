--[[Screech Hub - Main Script (内置Config，无依赖)]]
local Config = {
    -- UI Settings
    UIName = "screech hub",
    UIColor = Color3.fromHex("7B2CBF"), -- 紫色主题
    ToggleStyle = "Switch",

    -- ESP Settings
    ESP = {
        Door = {Enabled = true, Color = Color3.fromHex("00FFFF"), TextSize = 18, Tracers = true},
        Item = {Enabled = true, Color = Color3.fromHex("FF00FF"), TextSize = 18, Tracers = true},
        Entity = {Enabled = true, Color = Color3.fromHex("FF0000"), TextSize = 18, Tracers = true},
        Gold = {Enabled = true, Color = Color3.fromHex("FFFF00"), TextSize = 18, Tracers = true},
        Player = {Enabled = true, Color = Color3.fromHex("FFFFFF"), TextSize = 18, Tracers = true},
        Distance = 350
    },

    -- Survival Settings
    Survival = {Godmode = true, AntiScreech = true, AntiEyes = true, AntiJumpscares = true, AntiA90 = true, AntiFigure = true},

    -- Auto Functions
    Auto = {Interact = true, BreakerSolver = true, LibraryCode = true, DoorReach = true},

    -- Movement Settings
    Movement = {Fly = true, FlySpeed = 75, SpeedBoost = 15, JumpBoost = 5, NoCrouchBarriers = true},

    -- Visual Settings
    Visual = {Fullbright = true, NoFog = true, NoCamShake = true, FOV = 70, ThirdPerson = false},

    -- Keybinds
    Keybinds = {Fly = "F", Godmode = "G", AutoInteract = "R", ThirdPerson = "C"}
}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

-- Player Info
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- UI (左上角标题)
local UI = Instance.new("ScreenGui")
UI.Name = "ScreechHubUI"
UI.Parent = CoreGui
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 150, 0, 30)
Title.Position = UDim2.new(0.01, 0, 0.01, 0)
Title.Text = Config.UIName
Title.TextColor3 = Config.UIColor
Title.TextSize = 22
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = UI

-- ESP工具
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "ScreechESP"
ESPGui.Parent = CoreGui

local function createESPLabel(target, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 18)
    label.Text = target.Name
    label.TextColor3 = color
    label.TextSize = 18
    label.Font = Enum.Font.SourceSansBold
    label.BackgroundTransparency = 1
    label.Parent = ESPGui
    RunService.RenderStepped:Connect(function()
        if not target or not target.Parent then label:Destroy() return end
        local pos, onScreen = Camera:WorldToScreenPoint(target.Position)
        label.Position = onScreen and UDim2.new(0, pos.X - 100, 0, pos.Y - 30) or UDim2.new(0, -1000, 0, 0)
    end)
    return label
end

local function createTracer(target, color)
    local line = Instance.new("LineHandleAdornment")
    line.Adornee = RootPart
    line.Color3 = color
    line.Thickness = 2
    line.Parent = ESPGui
    RunService.RenderStepped:Connect(function()
        if not target or not target.Parent then line:Destroy() return end
        local pos = Camera:WorldToViewportPoint(target.Position)
        line.To = Camera:ViewportPointToWorldPoint(Vector3.new(pos.X, pos.Y, Camera.NearPlaneDistance)) - RootPart.Position
    end)
    return line
end

-- 1. 上帝模式
if Config.Survival.Godmode then
    Humanoid.HealthChanged:Connect(function() Humanoid.Health = Humanoid.MaxHealth end)
    Humanoid.Died:Connect(function()
        Character = LocalPlayer.CharacterAdded:Wait()
        Humanoid = Character:WaitForChild("Humanoid")
        RootPart = Character:WaitForChild("HumanoidRootPart")
    end)
end

-- 2. 飞行
local isFlying = Config.Movement.Fly
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[Config.Keybinds.Fly] then
        isFlying = not isFlying
        Humanoid.PlatformStand = isFlying
    end
end)

RunService.RenderStepped:Connect(function()
    if isFlying then
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Vector3.new(0,0,-1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir += Vector3.new(0,0,1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir += Vector3.new(-1,0,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Vector3.new(1,0,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir += Vector3.new(0,-1,0) end
        RootPart.Velocity = dir.Unit * Config.Movement.FlySpeed
    end
end)

-- 3. 速度提升
Humanoid.WalkSpeed += Config.Movement.SpeedBoost
Humanoid.JumpPower += Config.Movement.JumpBoost

-- 4. 全亮度+无雾
if Config.Visual.Fullbright then Lighting.Brightness = 2 end
if Config.Visual.NoFog then Lighting.FogEnd = 10000 end

-- 5. ESP功能
RunService.RenderStepped:Connect(function()
    -- 门ESP
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

    -- 物品ESP
    if Config.ESP.Item.Enabled then
        for _, item in ipairs(Workspace:GetDescendants()) do
            if item:IsA("Tool") or item.Name:lower():find("key") then
                local dist = (RootPart.Position - item.Position).Magnitude
                if dist <= Config.ESP.Distance then
                    createESPLabel(item, Config.ESP.Item.Color)
                    if Config.ESP.Item.Tracers then createTracer(item, Config.ESP.Item.Color) end
                end
            end
        end
    end

    -- 实体ESP
    if Config.ESP.Entity.Enabled then
        for _, entity in ipairs(Workspace:GetDescendants()) do
            if entity.Name:lower():find("screech") or entity.Name:lower():find("eyes") or entity.Name:lower():find("figure") then
                local dist = (RootPart.Position - entity.Position).Magnitude
                if dist <= Config.ESP.Distance then
                    createESPLabel(entity, Config.ESP.Entity.Color)
                    if Config.ESP.Entity.Tracers then createTracer(entity, Config.ESP.Entity.Color) end
                end
            end
        end
    end

    -- 金色物品ESP
    if Config.ESP.Gold.Enabled then
        for _, gold in ipairs(Workspace:GetDescendants()) do
            if gold.Name:lower():find("gold") or gold.BrickColor == BrickColor.new("Gold") then
                local dist = (RootPart.Position - gold.Position).Magnitude
                if dist <= Config.ESP.Distance then
                    createESPLabel(gold, Config.ESP.Gold.Color)
                    if Config.ESP.Gold.Tracers then createTracer(gold, Config.ESP.Gold.Color) end
                end
            end
        end
    end

    -- 玩家ESP
    if Config.ESP.Player.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (RootPart.Position - root.Position).Magnitude
                    if dist <= Config.ESP.Distance then
                        createESPLabel(root, Config.ESP.Player.Color, player.Name)
                        if Config.ESP.Player.Tracers then createTracer(root, Config.ESP.Player.Color) end
                    end
                end
            end
        end
    end
end)

-- 6. 自动交互
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
                    if dist <= 10 then fireclickdetector(obj.ClickDetector) end
                end
            end
        end
    end
end)

-- 7. 防惊吓
if Config.Survival.AntiJumpscares then
    SoundService.Volume = 0.2
    RunService.RenderStepped:Connect(function()
        for _, entity in ipairs(Workspace:GetDescendants()) do
            if entity.Name:lower():find("screech") then entity.Transparency = 1 end
        end
    end)
end

-- 8. 第三人称
local isThirdPerson = Config.Visual.ThirdPerson
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[Config.Keybinds.ThirdPerson] then
        isThirdPerson = not isThirdPerson
        Camera.CameraType = isThirdPerson and Enum.CameraType.Attach or Enum.CameraType.Custom
        if isThirdPerson then Camera.CFrame = RootPart.CFrame * CFrame.new(0,2,5) end
    end
end)

-- 9. 无镜头抖动
if Config.Visual.NoCamShake then Camera.ShakeEnabled = false end

print("[Screech Hub] 加载成功！左上角标题可见，按键：F飞行/G上帝模式/R自动交互/C第三人称")
