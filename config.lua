-- Screech Hub Configuration
local Config = {
    -- UI Settings
    UIName = "screech hub",
    UIColor = Color3.fromHex("7B2CBF"), -- 紫色主题
    ToggleStyle = "Switch", -- "Switch" or "Checkbox"

    -- ESP Settings
    ESP = {
        Door = {
            Enabled = true,
            Color = Color3.fromHex("00FFFF"), -- 青色
            TextSize = 18,
            Tracers = true
        },
        Item = {
            Enabled = true,
            Color = Color3.fromHex("FF00FF"), -- 紫色
            TextSize = 18,
            Tracers = true
        },
        Entity = {
            Enabled = true,
            Color = Color3.fromHex("FF0000"), -- 红色
            TextSize = 18,
            Tracers = true
        },
        Gold = {
            Enabled = true,
            Color = Color3.fromHex("FFFF00"), -- 黄色
            TextSize = 18,
            Tracers = true
        },
        Player = {
            Enabled = true,
            Color = Color3.fromHex("FFFFFF"), -- 白色
            TextSize = 18,
            Tracers = true
        },
        Distance = 350, -- 最大显示距离
        ShowText = true,
        ShowDistance = true
    },

    -- Survival Settings
    Survival = {
        Godmode = true,
        AntiScreech = true,
        AntiEyes = true,
        AntiJumpscares = true,
        AntiA90 = true,
        AntiFigure = true
    },

    -- Auto Functions
    Auto = {
        Interact = true,
        BreakerSolver = true,
        LibraryCode = true,
        DoorReach = true,
        IgnoreJeffItems = false
    },

    -- Movement Settings
    Movement = {
        Fly = true,
        FlySpeed = 75,
        SpeedBoost = 15,
        JumpBoost = 5,
        NoCrouchBarriers = true,
        Noclip = false,
        NoclipKey = "N"
    },

    -- Visual Settings
    Visual = {
        Fullbright = true,
        NoFog = true,
        NoCamShake = true,
        FOV = 70,
        ThirdPerson = false,
        ThirdPersonKey = "C"
    },

    -- Keybinds
    Keybinds = {
        Fly = "F",
        Godmode = "G",
        AutoInteract = "R",
        ThirdPerson = "C",
        MenuToggle = "RightShift"
    }
}

return Config
