--[[
    ╔═══════════════════════════════════════════════════════╗
    ║           AMNEZIA UI LIBRARY v1.0.0                   ║
    ║        Premium Script Hub Interface                   ║
    ║     Dark Glassmorphism • Neon Accents • Smooth        ║
    ╚═══════════════════════════════════════════════════════╝

    USAGE EXAMPLE:
    ─────────────
    local Amnezia = loadstring(game:HttpGet("..."))()

    local Window = Amnezia:CreateWindow({
        Title = "My Hub",
        SubTitle = "v1.0",
        Key = "amnezia2026",         -- optional key system
        ShowIntro = true,
    })

    local Tab = Window:AddTab({ Name = "Combat", Icon = "sword" })
    local Section = Tab:AddSection({ Name = "Aimbot" })

    Section:AddToggle({ Name = "Enable Aimbot", Default = false, Callback = function(v) end })
    Section:AddSlider({ Name = "FOV", Min = 10, Max = 500, Default = 120, Callback = function(v) end })
    Section:AddDropdown({ Name = "Part", Options = {"Head","Torso","HumanoidRootPart"}, Default = "Head", Callback = function(v) end })
    Section:AddButton({ Name = "Teleport", Callback = function() end })
    Section:AddInput({ Name = "Walk Speed", Default = "16", Callback = function(v) end })

    Amnezia:Notify({ Title = "Chargé!", Message = "Amnezia activé.", Type = "success", Duration = 4 })
]]

-- ┌─────────────────────────────────────────┐
-- │              CORE SETUP                 │
-- └─────────────────────────────────────────┘

local Amnezia = {}
Amnezia.__index = Amnezia

local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local HttpService    = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ┌─────────────────────────────────────────┐
-- │              THEME                      │
-- └─────────────────────────────────────────┘

local Theme = {
    -- Backgrounds
    BG_Primary    = Color3.fromRGB(8, 8, 12),
    BG_Secondary  = Color3.fromRGB(12, 12, 18),
    BG_Tertiary   = Color3.fromRGB(16, 16, 24),
    BG_Card       = Color3.fromRGB(14, 14, 22),
    BG_Hover      = Color3.fromRGB(22, 22, 34),
    BG_Active     = Color3.fromRGB(28, 28, 44),

    -- Accents
    Accent        = Color3.fromRGB(99, 102, 241),   -- Indigo neon
    AccentBright  = Color3.fromRGB(129, 140, 248),
    AccentGlow    = Color3.fromRGB(79, 70, 229),
    AccentAlt     = Color3.fromRGB(168, 85, 247),   -- Purple

    -- Text
    Text          = Color3.fromRGB(248, 248, 255),
    TextMuted     = Color3.fromRGB(148, 148, 180),
    TextDim       = Color3.fromRGB(88, 88, 120),
    TextAccent    = Color3.fromRGB(129, 140, 248),

    -- Borders
    Border        = Color3.fromRGB(30, 30, 48),
    BorderBright  = Color3.fromRGB(50, 50, 80),
    BorderAccent  = Color3.fromRGB(99, 102, 241),

    -- Status
    Success       = Color3.fromRGB(52, 211, 153),
    Warning       = Color3.fromRGB(251, 191, 36),
    Error         = Color3.fromRGB(248, 113, 113),
    Info          = Color3.fromRGB(99, 102, 241),

    -- Misc
    White         = Color3.fromRGB(255, 255, 255),
    Black         = Color3.fromRGB(0, 0, 0),
    Transparent   = Color3.fromRGB(0, 0, 0),

    -- Sizes
    CornerRadius  = UDim.new(0, 10),
    CornerRadiusSmall = UDim.new(0, 6),
    CornerRadiusLarge = UDim.new(0, 14),

    -- Fonts
    Font          = Enum.Font.GothamBold,
    FontMedium    = Enum.Font.Gotham,
    FontLight     = Enum.Font.GothamSemibold,
    FontMono      = Enum.Font.Code,
}

-- ┌─────────────────────────────────────────┐
-- │              UTILITIES                  │
-- └─────────────────────────────────────────┘

local Utils = {}

function Utils.Tween(obj, props, duration, style, direction)
    duration = duration or 0.25
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(obj, TweenInfo.new(duration, style, direction), props)
    tween:Play()
    return tween
end

function Utils.Ripple(button)
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.fromOffset(0, 0)
    ripple.Position = UDim2.fromScale(0.5, 0.5)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.85
    ripple.ZIndex = button.ZIndex + 5
    ripple.Parent = button

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple

    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    Utils.Tween(ripple, {
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1
    }, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    game:GetService("Debris"):AddItem(ripple, 0.6)
end

function Utils.Shadow(parent, size, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, size or 20, 1, size or 20)
    shadow.Position = UDim2.new(0, -(size or 20)/2, 0, (size or 10)/2)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = parent
    return shadow
end

function Utils.GradientFrame(parent, colorA, colorB, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorA),
        ColorSequenceKeypoint.new(1, colorB),
    })
    gradient.Rotation = rotation or 135
    gradient.Parent = parent
    return gradient
end

function Utils.Stroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

function Utils.Corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Theme.CornerRadius
    corner.Parent = parent
    return corner
end

function Utils.Padding(parent, top, bottom, left, right)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, top    or 8)
    pad.PaddingBottom = UDim.new(0, bottom or 8)
    pad.PaddingLeft   = UDim.new(0, left   or 8)
    pad.PaddingRight  = UDim.new(0, right  or 8)
    pad.Parent = parent
    return pad
end

function Utils.ListLayout(parent, dir, padding, halign, valign)
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = dir or Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, padding or 6)
    layout.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = valign or Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = parent
    return layout
end

function Utils.MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            frame.Position = newPos
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function Utils.SaveConfig(data, name)
    local success, err = pcall(function()
        if writefile then
            writefile("amnezia_" .. (name or "config") .. ".json", HttpService:JSONEncode(data))
        end
    end)
    return success
end

function Utils.LoadConfig(name)
    local success, data = pcall(function()
        if readfile and isfile then
            local path = "amnezia_" .. (name or "config") .. ".json"
            if isfile(path) then
                return HttpService:JSONDecode(readfile(path))
            end
        end
        return {}
    end)
    return success and data or {}
end

-- ┌─────────────────────────────────────────┐
-- │         ICON SYSTEM (SVG-like)          │
-- └─────────────────────────────────────────┘

local Icons = {
    -- Roblox asset IDs for icons (using standard Roblox icons)
    sword       = "rbxassetid://7072706620",
    shield      = "rbxassetid://7072718272",
    eye         = "rbxassetid://7072725342",
    gear        = "rbxassetid://7072717857",
    bolt        = "rbxassetid://7072706990",
    home        = "rbxassetid://7072718741",
    star        = "rbxassetid://7072721398",
    lock        = "rbxassetid://7072718890",
    user        = "rbxassetid://7072725915",
    map         = "rbxassetid://7072720287",
    trophy      = "rbxassetid://7072721553",
    info        = "rbxassetid://7072718521",
    check       = "rbxassetid://7072706796",
    close       = "rbxassetid://7072706748",
    warning     = "rbxassetid://7072722022",
    search      = "rbxassetid://7072721292",
    default     = "rbxassetid://7072718521",
}

local function GetIcon(name)
    return Icons[name] or Icons.default
end

-- ┌─────────────────────────────────────────┐
-- │           NOTIFICATION SYSTEM           │
-- └─────────────────────────────────────────┘

local NotificationHolder
local NotifCount = 0

local function InitNotifications(gui)
    NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "AmneziaNotifs"
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Size = UDim2.new(0, 320, 1, 0)
    NotificationHolder.Position = UDim2.new(1, -330, 0, 0)
    NotificationHolder.Parent = gui

    Utils.ListLayout(NotificationHolder, Enum.FillDirection.Vertical, 8,
        Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
end

function Amnezia:Notify(opts)
    opts = opts or {}
    local title    = opts.Title    or "Amnezia"
    local message  = opts.Message  or ""
    local ntype    = opts.Type     or "info"
    local duration = opts.Duration or 4

    local accentColor = ({
        success = Theme.Success,
        warning = Theme.Warning,
        error   = Theme.Error,
        info    = Theme.Accent,
    })[ntype] or Theme.Accent

    local iconId = ({
        success = Icons.check,
        warning = Icons.warning,
        error   = Icons.close,
        info    = Icons.info,
    })[ntype] or Icons.info

    -- Container
    local notif = Instance.new("Frame")
    notif.Name = "Notif_" .. tostring(NotifCount)
    notif.BackgroundColor3 = Theme.BG_Card
    notif.BackgroundTransparency = 0.1
    notif.Size = UDim2.new(1, 0, 0, 72)
    notif.ClipsDescendants = true
    notif.Parent = NotificationHolder
    Utils.Corner(notif, UDim.new(0, 12))
    Utils.Stroke(notif, Theme.Border, 1)
    Utils.Shadow(notif, 14, 0.6)

    -- Accent left bar
    local bar = Instance.new("Frame")
    bar.Name = "AccentBar"
    bar.BackgroundColor3 = accentColor
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.Position = UDim2.fromOffset(0, 0)
    bar.BorderSizePixel = 0
    bar.Parent = notif
    Utils.Corner(bar, UDim.new(0, 3))

    -- Glow
    local glow = Instance.new("Frame")
    glow.BackgroundColor3 = accentColor
    glow.BackgroundTransparency = 0.85
    glow.Size = UDim2.new(0.4, 0, 1, 0)
    glow.BorderSizePixel = 0
    glow.Parent = notif
    Utils.GradientFrame(glow, accentColor, Color3.fromRGB(0,0,0), 180)

    -- Icon
    local iconFrame = Instance.new("Frame")
    iconFrame.BackgroundColor3 = accentColor
    iconFrame.BackgroundTransparency = 0.8
    iconFrame.Size = UDim2.fromOffset(32, 32)
    iconFrame.Position = UDim2.new(0, 14, 0.5, -16)
    iconFrame.Parent = notif
    Utils.Corner(iconFrame, UDim.new(0, 8))

    local icon = Instance.new("ImageLabel")
    icon.Image = iconId
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(0.6, 0, 0.6, 0)
    icon.Position = UDim2.new(0.2, 0, 0.2, 0)
    icon.ImageColor3 = accentColor
    icon.Parent = iconFrame

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Font = Theme.Font
    titleLabel.TextSize = 13
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 56, 0, 12)
    titleLabel.Size = UDim2.new(1, -72, 0, 18)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif

    -- Message
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Text = message
    msgLabel.TextColor3 = Theme.TextMuted
    msgLabel.Font = Theme.FontMedium
    msgLabel.TextSize = 11
    msgLabel.BackgroundTransparency = 1
    msgLabel.Position = UDim2.new(0, 56, 0, 32)
    msgLabel.Size = UDim2.new(1, -72, 0, 30)
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.Parent = notif

    -- Progress bar
    local progress = Instance.new("Frame")
    progress.BackgroundColor3 = accentColor
    progress.Size = UDim2.new(1, 0, 0, 2)
    progress.Position = UDim2.new(0, 0, 1, -2)
    progress.BorderSizePixel = 0
    progress.Parent = notif

    -- Animate in
    notif.Position = UDim2.new(1, 20, 1, 0)
    Utils.Tween(notif, { Position = UDim2.new(0, 0, 1, 0) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Progress shrink
    Utils.Tween(progress, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

    -- Auto dismiss
    task.delay(duration, function()
        Utils.Tween(notif, { Position = UDim2.new(1, 20, 1, 0), BackgroundTransparency = 1 }, 0.35)
        task.wait(0.4)
        notif:Destroy()
    end)

    NotifCount = NotifCount + 1
end

-- ┌─────────────────────────────────────────┐
-- │           INTRO / LOADER                │
-- └─────────────────────────────────────────┘

local function ShowIntro(gui)
    local introFrame = Instance.new("Frame")
    introFrame.Name = "AmneziaIntro"
    introFrame.BackgroundColor3 = Theme.BG_Primary
    introFrame.Size = UDim2.fromScale(1, 1)
    introFrame.ZIndex = 100
    introFrame.Parent = gui

    -- Background gradient
    Utils.GradientFrame(introFrame, Theme.BG_Primary, Color3.fromRGB(15, 10, 30), 135)

    -- Grid lines (aesthetic)
    for i = 1, 8 do
        local line = Instance.new("Frame")
        line.BackgroundColor3 = Theme.Accent
        line.BackgroundTransparency = 0.93
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, i/9, 0)
        line.BorderSizePixel = 0
        line.ZIndex = 101
        line.Parent = introFrame
    end
    for i = 1, 12 do
        local line = Instance.new("Frame")
        line.BackgroundColor3 = Theme.Accent
        line.BackgroundTransparency = 0.93
        line.Size = UDim2.new(0, 1, 1, 0)
        line.Position = UDim2.new(i/13, 0, 0, 0)
        line.BorderSizePixel = 0
        line.ZIndex = 101
        line.Parent = introFrame
    end

    -- Glow orb center
    local orb = Instance.new("Frame")
    orb.BackgroundColor3 = Theme.Accent
    orb.BackgroundTransparency = 0.7
    orb.Size = UDim2.fromOffset(200, 200)
    orb.Position = UDim2.new(0.5, -100, 0.5, -140)
    orb.BorderSizePixel = 0
    orb.ZIndex = 101
    orb.Parent = introFrame
    Utils.Corner(orb, UDim.new(1, 0))

    -- Logo text
    local logoText = Instance.new("TextLabel")
    logoText.Text = "AMNEZIA"
    logoText.TextColor3 = Theme.Text
    logoText.Font = Theme.Font
    logoText.TextSize = 52
    logoText.BackgroundTransparency = 1
    logoText.Size = UDim2.new(1, 0, 0, 70)
    logoText.Position = UDim2.new(0, 0, 0.5, -35)
    logoText.TextXAlignment = Enum.TextXAlignment.Center
    logoText.ZIndex = 102
    logoText.TextTransparency = 1
    logoText.Parent = introFrame

    -- Logo stroke/gradient effect
    local logoStroke = Utils.Stroke(logoText, Theme.Accent, 0)

    local subText = Instance.new("TextLabel")
    subText.Text = "SCRIPT HUB  •  v1.0.0"
    subText.TextColor3 = Theme.TextMuted
    subText.Font = Theme.FontLight
    subText.TextSize = 13
    subText.BackgroundTransparency = 1
    subText.Size = UDim2.new(1, 0, 0, 20)
    subText.Position = UDim2.new(0, 0, 0.5, 44)
    subText.TextXAlignment = Enum.TextXAlignment.Center
    subText.ZIndex = 102
    subText.TextTransparency = 1
    subText.Parent = introFrame

    -- Loading bar
    local loadBg = Instance.new("Frame")
    loadBg.BackgroundColor3 = Theme.BG_Secondary
    loadBg.Size = UDim2.new(0, 260, 0, 3)
    loadBg.Position = UDim2.new(0.5, -130, 0.5, 80)
    loadBg.BorderSizePixel = 0
    loadBg.ZIndex = 102
    loadBg.BackgroundTransparency = 1
    loadBg.Parent = introFrame
    Utils.Corner(loadBg, UDim.new(1, 0))

    local loadFill = Instance.new("Frame")
    loadFill.BackgroundColor3 = Theme.Accent
    loadFill.Size = UDim2.new(0, 0, 1, 0)
    loadFill.BorderSizePixel = 0
    loadFill.ZIndex = 103
    loadFill.Parent = loadBg
    Utils.Corner(loadFill, UDim.new(1, 0))
    Utils.GradientFrame(loadFill, Theme.AccentAlt, Theme.AccentBright, 90)

    local loadText = Instance.new("TextLabel")
    loadText.Text = "Chargement..."
    loadText.TextColor3 = Theme.TextDim
    loadText.Font = Theme.FontMono
    loadText.TextSize = 11
    loadText.BackgroundTransparency = 1
    loadText.Size = UDim2.new(0, 260, 0, 18)
    loadText.Position = UDim2.new(0.5, -130, 0.5, 90)
    loadText.ZIndex = 102
    loadText.TextTransparency = 1
    loadText.Parent = introFrame

    -- Animate sequence
    task.spawn(function()
        task.wait(0.2)

        -- Orb pulse
        Utils.Tween(orb, { BackgroundTransparency = 0.85, Size = UDim2.fromOffset(260, 260), Position = UDim2.new(0.5, -130, 0.5, -150) }, 0.6)

        task.wait(0.3)

        -- Fade in text
        Utils.Tween(logoText, { TextTransparency = 0 }, 0.5)
        Utils.Tween(subText,  { TextTransparency = 0 }, 0.7)
        Utils.Tween(loadBg,   { BackgroundTransparency = 0.7 }, 0.4)
        Utils.Tween(loadText, { TextTransparency = 0.3 }, 0.4)

        task.wait(0.5)

        -- Load bar fill
        local steps = {"Initialisation...", "Chargement modules...", "Connexion...", "Prêt!"}
        for i, msg in ipairs(steps) do
            loadText.Text = msg
            Utils.Tween(loadFill, { Size = UDim2.new(i/4, 0, 1, 0) }, 0.35, Enum.EasingStyle.Quart)
            task.wait(0.38)
        end

        task.wait(0.3)

        -- Fade out
        Utils.Tween(introFrame, { BackgroundTransparency = 1 }, 0.5)
        Utils.Tween(logoText, { TextTransparency = 1 }, 0.4)
        Utils.Tween(subText,  { TextTransparency = 1 }, 0.4)
        Utils.Tween(orb, { BackgroundTransparency = 1 }, 0.4)

        task.wait(0.55)
        introFrame:Destroy()
    end)

    return 1.8 + 4*0.38 + 0.85
end

-- ┌─────────────────────────────────────────┐
-- │             KEY SYSTEM                  │
-- └─────────────────────────────────────────┘

local function ShowKeySystem(gui, requiredKey, callback)
    local overlay = Instance.new("Frame")
    overlay.BackgroundColor3 = Theme.BG_Primary
    overlay.BackgroundTransparency = 0.3
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.ZIndex = 90
    overlay.Parent = gui

    local panel = Instance.new("Frame")
    panel.BackgroundColor3 = Theme.BG_Card
    panel.Size = UDim2.fromOffset(380, 240)
    panel.Position = UDim2.new(0.5, -190, 0.5, -120)
    panel.ZIndex = 91
    panel.Parent = overlay
    Utils.Corner(panel, UDim.new(0, 16))
    Utils.Stroke(panel, Theme.BorderAccent, 1, 0.5)
    Utils.Shadow(panel, 24, 0.5)

    -- Top accent bar
    local topBar = Instance.new("Frame")
    topBar.BackgroundColor3 = Theme.Accent
    topBar.Size = UDim2.new(1, 0, 0, 3)
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 92
    topBar.Parent = panel
    Utils.GradientFrame(topBar, Theme.AccentAlt, Theme.AccentBright, 90)

    local lockImg = Instance.new("ImageLabel")
    lockImg.Image = Icons.lock
    lockImg.BackgroundTransparency = 1
    lockImg.Size = UDim2.fromOffset(28, 28)
    lockImg.Position = UDim2.new(0.5, -14, 0, 20)
    lockImg.ImageColor3 = Theme.Accent
    lockImg.ZIndex = 92
    lockImg.Parent = panel

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Text = "Accès Requis"
    titleLbl.TextColor3 = Theme.Text
    titleLbl.Font = Theme.Font
    titleLbl.TextSize = 18
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(1, 0, 0, 24)
    titleLbl.Position = UDim2.new(0, 0, 0, 58)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Center
    titleLbl.ZIndex = 92
    titleLbl.Parent = panel

    local subLbl = Instance.new("TextLabel")
    subLbl.Text = "Entrez votre clé Amnezia pour continuer"
    subLbl.TextColor3 = Theme.TextMuted
    subLbl.Font = Theme.FontMedium
    subLbl.TextSize = 11
    subLbl.BackgroundTransparency = 1
    subLbl.Size = UDim2.new(1, -40, 0, 18)
    subLbl.Position = UDim2.new(0, 20, 0, 86)
    subLbl.TextXAlignment = Enum.TextXAlignment.Center
    subLbl.ZIndex = 92
    subLbl.Parent = panel

    -- Input box
    local inputBg = Instance.new("Frame")
    inputBg.BackgroundColor3 = Theme.BG_Secondary
    inputBg.Size = UDim2.new(1, -40, 0, 38)
    inputBg.Position = UDim2.new(0, 20, 0, 116)
    inputBg.ZIndex = 92
    inputBg.Parent = panel
    Utils.Corner(inputBg, UDim.new(0, 8))
    local inputStroke = Utils.Stroke(inputBg, Theme.Border, 1)

    local input = Instance.new("TextBox")
    input.BackgroundTransparency = 1
    input.Size = UDim2.new(1, -16, 1, 0)
    input.Position = UDim2.new(0, 8, 0, 0)
    input.Font = Theme.FontMono
    input.TextSize = 13
    input.TextColor3 = Theme.Text
    input.PlaceholderText = "Clé d'accès..."
    input.PlaceholderColor3 = Theme.TextDim
    input.Text = ""
    input.ClearTextOnFocus = false
    input.ZIndex = 93
    input.Parent = inputBg

    input.Focused:Connect(function()
        Utils.Tween(inputStroke, { Color = Theme.Accent }, 0.2)
    end)
    input.FocusLost:Connect(function()
        Utils.Tween(inputStroke, { Color = Theme.Border }, 0.2)
    end)

    -- Error label
    local errLbl = Instance.new("TextLabel")
    errLbl.Text = ""
    errLbl.TextColor3 = Theme.Error
    errLbl.Font = Theme.FontMedium
    errLbl.TextSize = 10
    errLbl.BackgroundTransparency = 1
    errLbl.Size = UDim2.new(1, -40, 0, 14)
    errLbl.Position = UDim2.new(0, 20, 0, 158)
    errLbl.TextXAlignment = Enum.TextXAlignment.Left
    errLbl.ZIndex = 92
    errLbl.Parent = panel

    -- Submit button
    local btn = Instance.new("TextButton")
    btn.Text = "Valider"
    btn.TextColor3 = Theme.White
    btn.Font = Theme.Font
    btn.TextSize = 13
    btn.BackgroundColor3 = Theme.Accent
    btn.Size = UDim2.new(1, -40, 0, 38)
    btn.Position = UDim2.new(0, 20, 0, 178)
    btn.ZIndex = 92
    btn.BorderSizePixel = 0
    btn.Parent = panel
    Utils.Corner(btn, UDim.new(0, 8))
    Utils.GradientFrame(btn, Theme.AccentAlt, Theme.AccentBright, 90)

    btn.MouseButton1Click:Connect(function()
        Utils.Ripple(btn)
        if input.Text == requiredKey then
            Utils.Tween(overlay, { BackgroundTransparency = 1 }, 0.4)
            Utils.Tween(panel, { Size = UDim2.fromOffset(380, 0), Position = UDim2.new(0.5, -190, 0.5, 0) }, 0.4, Enum.EasingStyle.Back)
            task.wait(0.45)
            overlay:Destroy()
            callback(true)
        else
            errLbl.Text = "✕  Clé invalide. Réessayez."
            Utils.Tween(inputBg, { BackgroundColor3 = Color3.fromRGB(40, 16, 16) }, 0.15)
            Utils.Tween(inputStroke, { Color = Theme.Error }, 0.15)
            task.wait(1.5)
            Utils.Tween(inputBg, { BackgroundColor3 = Theme.BG_Secondary }, 0.3)
            Utils.Tween(inputStroke, { Color = Theme.Border }, 0.3)
            errLbl.Text = ""
        end
    end)

    -- Animate in
    panel.Position = UDim2.new(0.5, -190, 0.5, -80)
    panel.BackgroundTransparency = 1
    Utils.Tween(panel, { Position = UDim2.new(0.5, -190, 0.5, -120), BackgroundTransparency = 0 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- ┌─────────────────────────────────────────┐
-- │           MAIN WINDOW                   │
-- └─────────────────────────────────────────┘

function Amnezia:CreateWindow(opts)
    opts = opts or {}
    local title     = opts.Title     or "Amnezia"
    local subtitle  = opts.SubTitle  or "Script Hub"
    local key       = opts.Key       -- nil = no key system
    local showIntro = opts.ShowIntro ~= false
    local size      = opts.Size      or Vector2.new(720, 480)
    local configName = opts.ConfigName or "default"

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "AmneziaHub"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999

    -- Try to parent to CoreGui (executor), fallback to PlayerGui
    local ok = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    if not ok then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    InitNotifications(gui)

    -- Main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "AmneziaMain"
    mainFrame.BackgroundColor3 = Theme.BG_Primary
    mainFrame.Size = UDim2.fromOffset(size.X, size.Y)
    mainFrame.Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2)
    mainFrame.ClipsDescendants = true
    mainFrame.ZIndex = 10
    mainFrame.Visible = false
    mainFrame.Parent = gui
    Utils.Corner(mainFrame, UDim.new(0, 16))
    Utils.Shadow(mainFrame, 30, 0.4)

    -- Background gradient
    Utils.GradientFrame(mainFrame, Theme.BG_Primary, Color3.fromRGB(10, 8, 20), 135)

    -- Outer border glow
    Utils.Stroke(mainFrame, Theme.BorderAccent, 1, 0.6)

    -- ── SIDEBAR ───────────────────────────────────────────
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundColor3 = Theme.BG_Secondary
    sidebar.Size = UDim2.new(0, 200, 1, 0)
    sidebar.BackgroundTransparency = 0.2
    sidebar.ZIndex = 11
    sidebar.Parent = mainFrame
    Utils.Stroke(sidebar, Theme.Border, 1)

    -- Sidebar gradient overlay
    local sideGrad = Instance.new("Frame")
    sideGrad.BackgroundColor3 = Theme.Accent
    sideGrad.BackgroundTransparency = 0.95
    sideGrad.Size = UDim2.fromScale(1, 1)
    sideGrad.BorderSizePixel = 0
    sideGrad.ZIndex = 11
    sideGrad.Parent = sidebar

    -- Logo area
    local logoArea = Instance.new("Frame")
    logoArea.BackgroundTransparency = 1
    logoArea.Size = UDim2.new(1, 0, 0, 70)
    logoArea.ZIndex = 12
    logoArea.Parent = sidebar

    -- Accent top line
    local accentLine = Instance.new("Frame")
    accentLine.BackgroundColor3 = Theme.Accent
    accentLine.Size = UDim2.new(0, 40, 0, 3)
    accentLine.Position = UDim2.new(0, 16, 1, -10)
    accentLine.BorderSizePixel = 0
    accentLine.ZIndex = 12
    accentLine.Parent = logoArea
    Utils.Corner(accentLine, UDim.new(1, 0))
    Utils.GradientFrame(accentLine, Theme.AccentAlt, Theme.AccentBright, 90)

    local logoLabel = Instance.new("TextLabel")
    logoLabel.Text = "AMNEZIA"
    logoLabel.TextColor3 = Theme.Text
    logoLabel.Font = Theme.Font
    logoLabel.TextSize = 20
    logoLabel.BackgroundTransparency = 1
    logoLabel.Size = UDim2.new(1, -16, 0, 28)
    logoLabel.Position = UDim2.new(0, 16, 0, 14)
    logoLabel.TextXAlignment = Enum.TextXAlignment.Left
    logoLabel.ZIndex = 12
    logoLabel.Parent = logoArea

    local subLabel = Instance.new("TextLabel")
    subLabel.Text = subtitle
    subLabel.TextColor3 = Theme.TextMuted
    subLabel.Font = Theme.FontLight
    subLabel.TextSize = 10
    subLabel.BackgroundTransparency = 1
    subLabel.Size = UDim2.new(1, -16, 0, 14)
    subLabel.Position = UDim2.new(0, 16, 0, 40)
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.ZIndex = 12
    subLabel.Parent = logoArea

    -- Tab scroll container in sidebar
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.BackgroundTransparency = 1
    tabScroll.Size = UDim2.new(1, 0, 1, -130)
    tabScroll.Position = UDim2.new(0, 0, 0, 72)
    tabScroll.ScrollBarThickness = 2
    tabScroll.ScrollBarImageColor3 = Theme.Accent
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroll.ZIndex = 12
    tabScroll.Parent = sidebar
    Utils.Padding(tabScroll, 6, 6, 10, 10)
    Utils.ListLayout(tabScroll, Enum.FillDirection.Vertical, 4)

    -- Bottom info
    local bottomInfo = Instance.new("Frame")
    bottomInfo.BackgroundTransparency = 1
    bottomInfo.Size = UDim2.new(1, 0, 0, 56)
    bottomInfo.Position = UDim2.new(0, 0, 1, -58)
    bottomInfo.ZIndex = 12
    bottomInfo.Parent = sidebar

    local divider = Instance.new("Frame")
    divider.BackgroundColor3 = Theme.Border
    divider.Size = UDim2.new(1, -20, 0, 1)
    divider.Position = UDim2.new(0, 10, 0, 0)
    divider.BorderSizePixel = 0
    divider.ZIndex = 12
    divider.Parent = bottomInfo

    local versionLbl = Instance.new("TextLabel")
    versionLbl.Text = "v1.0.0  •  Amnezia"
    versionLbl.TextColor3 = Theme.TextDim
    versionLbl.Font = Theme.FontMono
    versionLbl.TextSize = 9
    versionLbl.BackgroundTransparency = 1
    versionLbl.Size = UDim2.new(1, -16, 0, 30)
    versionLbl.Position = UDim2.new(0, 16, 0, 12)
    versionLbl.TextXAlignment = Enum.TextXAlignment.Left
    versionLbl.ZIndex = 12
    versionLbl.Parent = bottomInfo

    -- ── HEADER ────────────────────────────────────────────
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = Theme.BG_Secondary
    header.BackgroundTransparency = 0.3
    header.Size = UDim2.new(1, -200, 0, 46)
    header.Position = UDim2.new(0, 200, 0, 0)
    header.ZIndex = 12
    header.Parent = mainFrame
    Utils.Stroke(header, Theme.Border, 1)

    local headerTitle = Instance.new("TextLabel")
    headerTitle.Text = title
    headerTitle.TextColor3 = Theme.Text
    headerTitle.Font = Theme.Font
    headerTitle.TextSize = 14
    headerTitle.BackgroundTransparency = 1
    headerTitle.Size = UDim2.new(0.5, 0, 1, 0)
    headerTitle.Position = UDim2.new(0, 16, 0, 0)
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.ZIndex = 13
    headerTitle.Parent = header

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Theme.TextMuted
    closeBtn.Font = Theme.Font
    closeBtn.TextSize = 20
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.fromOffset(32, 32)
    closeBtn.Position = UDim2.new(1, -42, 0.5, -16)
    closeBtn.ZIndex = 13
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = header
    Utils.Corner(closeBtn, UDim.new(0, 6))

    closeBtn.MouseEnter:Connect(function()
        Utils.Tween(closeBtn, { BackgroundTransparency = 0.3, TextColor3 = Theme.Error }, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        Utils.Tween(closeBtn, { BackgroundTransparency = 1, TextColor3 = Theme.TextMuted }, 0.15)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Utils.Tween(mainFrame, { Size = UDim2.fromOffset(size.X, 0), Position = UDim2.new(0.5, -size.X/2, 0.5, 0), BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Back)
        task.wait(0.35)
        gui:Destroy()
    end)

    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Text = "−"
    minBtn.TextColor3 = Theme.TextMuted
    minBtn.Font = Theme.Font
    minBtn.TextSize = 18
    minBtn.BackgroundColor3 = Theme.BG_Hover
    minBtn.BackgroundTransparency = 1
    minBtn.Size = UDim2.fromOffset(32, 32)
    minBtn.Position = UDim2.new(1, -80, 0.5, -16)
    minBtn.ZIndex = 13
    minBtn.BorderSizePixel = 0
    minBtn.Parent = header
    Utils.Corner(minBtn, UDim.new(0, 6))

    local minimized = false
    minBtn.MouseEnter:Connect(function() Utils.Tween(minBtn, {BackgroundTransparency = 0.5}, 0.15) end)
    minBtn.MouseLeave:Connect(function() Utils.Tween(minBtn, {BackgroundTransparency = 1}, 0.15) end)
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Utils.Tween(mainFrame, { Size = UDim2.fromOffset(200, 46) }, 0.3, Enum.EasingStyle.Quart)
        else
            Utils.Tween(mainFrame, { Size = UDim2.fromOffset(size.X, size.Y) }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)

    -- Draggable
    Utils.MakeDraggable(mainFrame, header)

    -- ── CONTENT AREA ─────────────────────────────────────
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.BackgroundTransparency = 1
    contentArea.Size = UDim2.new(1, -200, 1, -46)
    contentArea.Position = UDim2.new(0, 200, 0, 46)
    contentArea.ZIndex = 11
    contentArea.Parent = mainFrame

    -- Tab management
    local tabs = {}
    local activeTab = nil

    local function ActivateTab(tabObj)
        if activeTab == tabObj then return end

        -- Deactivate previous
        if activeTab then
            Utils.Tween(activeTab.Button, {
                BackgroundColor3 = Color3.fromRGB(0,0,0),
                BackgroundTransparency = 1
            }, 0.2)
            Utils.Tween(activeTab.ButtonLabel, { TextColor3 = Theme.TextMuted }, 0.2)
            Utils.Tween(activeTab.ButtonIcon, { ImageColor3 = Theme.TextDim }, 0.2)
            activeTab.Content.Visible = false
        end

        activeTab = tabObj

        -- Activate new
        Utils.Tween(tabObj.Button, {
            BackgroundColor3 = Theme.BG_Active,
            BackgroundTransparency = 0,
        }, 0.2)
        Utils.Tween(tabObj.ButtonLabel, { TextColor3 = Theme.AccentBright }, 0.2)
        Utils.Tween(tabObj.ButtonIcon, { ImageColor3 = Theme.Accent }, 0.2)

        tabObj.Content.Visible = true
        -- Slide in
        tabObj.Content.Position = UDim2.new(0.04, 0, 0, 0)
        tabObj.Content.BackgroundTransparency = 1
        Utils.Tween(tabObj.Content, { Position = UDim2.fromScale(0,0), BackgroundTransparency = 1 }, 0.25, Enum.EasingStyle.Quart)
    end

    -- ── TAB OBJECT ────────────────────────────────────────
    local Window = {}
    Window._configData = Utils.LoadConfig(configName)
    Window._configName = configName

    function Window:AddTab(tabOpts)
        tabOpts = tabOpts or {}
        local tabName = tabOpts.Name or "Tab"
        local iconName = tabOpts.Icon or "default"

        -- Sidebar tab button
        local tabBtn = Instance.new("TextButton")
        tabBtn.BackgroundColor3 = Theme.BG_Active
        tabBtn.BackgroundTransparency = 1
        tabBtn.Size = UDim2.new(1, 0, 0, 38)
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = ""
        tabBtn.ZIndex = 13
        tabBtn.Parent = tabScroll
        Utils.Corner(tabBtn, UDim.new(0, 8))

        -- Active indicator
        local indicator = Instance.new("Frame")
        indicator.BackgroundColor3 = Theme.Accent
        indicator.Size = UDim2.new(0, 3, 0.6, 0)
        indicator.Position = UDim2.new(0, 0, 0.2, 0)
        indicator.BorderSizePixel = 0
        indicator.ZIndex = 14
        indicator.BackgroundTransparency = 1
        indicator.Parent = tabBtn
        Utils.Corner(indicator, UDim.new(1, 0))

        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Image = GetIcon(iconName)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Size = UDim2.fromOffset(16, 16)
        tabIcon.Position = UDim2.new(0, 10, 0.5, -8)
        tabIcon.ImageColor3 = Theme.TextDim
        tabIcon.ZIndex = 14
        tabIcon.Parent = tabBtn

        local tabLabel = Instance.new("TextLabel")
        tabLabel.Text = tabName
        tabLabel.TextColor3 = Theme.TextMuted
        tabLabel.Font = Theme.FontLight
        tabLabel.TextSize = 12
        tabLabel.BackgroundTransparency = 1
        tabLabel.Size = UDim2.new(1, -36, 1, 0)
        tabLabel.Position = UDim2.new(0, 32, 0, 0)
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.ZIndex = 14
        tabLabel.Parent = tabBtn

        -- Content scroll frame
        local content = Instance.new("ScrollingFrame")
        content.BackgroundTransparency = 1
        content.Size = UDim2.fromScale(1, 1)
        content.ScrollBarThickness = 3
        content.ScrollBarImageColor3 = Theme.Accent
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.Visible = false
        content.ZIndex = 12
        content.Parent = contentArea
        Utils.Padding(content, 12, 12, 14, 14)
        Utils.ListLayout(content, Enum.FillDirection.Vertical, 10)

        local tabObj = {
            Button = tabBtn,
            ButtonLabel = tabLabel,
            ButtonIcon = tabIcon,
            Indicator = indicator,
            Content = content,
        }

        table.insert(tabs, tabObj)

        -- Click
        tabBtn.MouseButton1Click:Connect(function()
            Utils.Ripple(tabBtn)
            ActivateTab(tabObj)
            Utils.Tween(indicator, { BackgroundTransparency = 0 }, 0.2)
            if activeTab and activeTab ~= tabObj then
                Utils.Tween(activeTab.Indicator, { BackgroundTransparency = 1 }, 0.2)
            end
            Utils.Tween(indicator, { BackgroundTransparency = 0 }, 0.2)
        end)

        tabBtn.MouseEnter:Connect(function()
            if activeTab ~= tabObj then
                Utils.Tween(tabBtn, { BackgroundTransparency = 0.7 }, 0.15)
                Utils.Tween(tabLabel, { TextColor3 = Theme.Text }, 0.15)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab ~= tabObj then
                Utils.Tween(tabBtn, { BackgroundTransparency = 1 }, 0.15)
                Utils.Tween(tabLabel, { TextColor3 = Theme.TextMuted }, 0.15)
            end
        end)

        if #tabs == 1 then
            ActivateTab(tabObj)
            indicator.BackgroundTransparency = 0
        end

        -- ── SECTION / COMPONENTS ─────────────────────────
        local Tab = {}

        function Tab:AddSection(secOpts)
            secOpts = secOpts or {}
            local secName = secOpts.Name or "Section"

            local section = Instance.new("Frame")
            section.BackgroundColor3 = Theme.BG_Card
            section.BackgroundTransparency = 0.1
            section.Size = UDim2.new(1, 0, 0, 0)
            section.AutomaticSize = Enum.AutomaticSize.Y
            section.BorderSizePixel = 0
            section.ZIndex = 13
            section.Parent = content
            Utils.Corner(section, UDim.new(0, 10))
            Utils.Stroke(section, Theme.Border, 1)

            -- Section header
            local secHeader = Instance.new("Frame")
            secHeader.BackgroundTransparency = 1
            secHeader.Size = UDim2.new(1, 0, 0, 32)
            secHeader.ZIndex = 14
            secHeader.LayoutOrder = 0
            secHeader.Parent = section

            local secAccent = Instance.new("Frame")
            secAccent.BackgroundColor3 = Theme.Accent
            secAccent.Size = UDim2.fromOffset(3, 14)
            secAccent.Position = UDim2.new(0, 14, 0.5, -7)
            secAccent.BorderSizePixel = 0
            secAccent.ZIndex = 14
            secAccent.Parent = secHeader
            Utils.Corner(secAccent, UDim.new(1, 0))

            local secLabel = Instance.new("TextLabel")
            secLabel.Text = string.upper(secName)
            secLabel.TextColor3 = Theme.TextAccent
            secLabel.Font = Theme.Font
            secLabel.TextSize = 10
            secLabel.BackgroundTransparency = 1
            secLabel.Size = UDim2.new(1, -34, 1, 0)
            secLabel.Position = UDim2.new(0, 24, 0, 0)
            secLabel.TextXAlignment = Enum.TextXAlignment.Left
            secLabel.ZIndex = 14
            secLabel.LetterSpacing = 2
            secLabel.Parent = secHeader

            local secDivider = Instance.new("Frame")
            secDivider.BackgroundColor3 = Theme.Border
            secDivider.Size = UDim2.new(1, -20, 0, 1)
            secDivider.Position = UDim2.new(0, 10, 1, -1)
            secDivider.BorderSizePixel = 0
            secDivider.ZIndex = 14
            secDivider.Parent = secHeader

            local itemsContainer = Instance.new("Frame")
            itemsContainer.BackgroundTransparency = 1
            itemsContainer.Size = UDim2.new(1, 0, 0, 0)
            itemsContainer.AutomaticSize = Enum.AutomaticSize.Y
            itemsContainer.ZIndex = 14
            itemsContainer.LayoutOrder = 1
            itemsContainer.Parent = section
            Utils.Padding(itemsContainer, 4, 10, 14, 14)
            Utils.ListLayout(itemsContainer, Enum.FillDirection.Vertical, 6)

            local secLayout = Instance.new("UIListLayout")
            secLayout.FillDirection = Enum.FillDirection.Vertical
            secLayout.SortOrder = Enum.SortOrder.LayoutOrder
            secLayout.Parent = section

            local Section = {}
            local _itemOrder = 0
            local function nextOrder()
                _itemOrder = _itemOrder + 1
                return _itemOrder
            end

            -- ── BUTTON ──────────────────────────────────
            function Section:AddButton(opts)
                opts = opts or {}
                local name = opts.Name or "Button"
                local desc = opts.Description
                local cb   = opts.Callback or function() end

                local row = Instance.new("TextButton")
                row.Text = ""
                row.BackgroundColor3 = Theme.BG_Hover
                row.BackgroundTransparency = 0.6
                row.Size = UDim2.new(1, 0, 0, desc and 50 or 36)
                row.LayoutOrder = nextOrder()
                row.ZIndex = 15
                row.BorderSizePixel = 0
                row.Parent = itemsContainer
                Utils.Corner(row, UDim.new(0, 7))
                Utils.Stroke(row, Theme.Border, 1)

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = name
                nameLabel.TextColor3 = Theme.Text
                nameLabel.Font = Theme.FontLight
                nameLabel.TextSize = 12
                nameLabel.BackgroundTransparency = 1
                nameLabel.Size = UDim2.new(1, -60, 0, 18)
                nameLabel.Position = UDim2.new(0, 12, 0, desc and 8 or 9)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.ZIndex = 15
                nameLabel.Parent = row

                if desc then
                    local descLabel = Instance.new("TextLabel")
                    descLabel.Text = desc
                    descLabel.TextColor3 = Theme.TextDim
                    descLabel.Font = Theme.FontMedium
                    descLabel.TextSize = 10
                    descLabel.BackgroundTransparency = 1
                    descLabel.Size = UDim2.new(1, -60, 0, 14)
                    descLabel.Position = UDim2.new(0, 12, 0, 28)
                    descLabel.TextXAlignment = Enum.TextXAlignment.Left
                    descLabel.ZIndex = 15
                    descLabel.Parent = row
                end

                -- Arrow icon
                local arrow = Instance.new("TextLabel")
                arrow.Text = "›"
                arrow.TextColor3 = Theme.Accent
                arrow.Font = Theme.Font
                arrow.TextSize = 18
                arrow.BackgroundTransparency = 1
                arrow.Size = UDim2.fromOffset(20, 20)
                arrow.Position = UDim2.new(1, -30, 0.5, -10)
                arrow.ZIndex = 15
                arrow.Parent = row

                row.MouseEnter:Connect(function()
                    Utils.Tween(row, { BackgroundTransparency = 0.2, BackgroundColor3 = Theme.BG_Active }, 0.15)
                    Utils.Tween(arrow, { TextColor3 = Theme.AccentBright }, 0.15)
                end)
                row.MouseLeave:Connect(function()
                    Utils.Tween(row, { BackgroundTransparency = 0.6, BackgroundColor3 = Theme.BG_Hover }, 0.15)
                    Utils.Tween(arrow, { TextColor3 = Theme.Accent }, 0.15)
                end)
                row.MouseButton1Click:Connect(function()
                    Utils.Ripple(row)
                    task.spawn(cb)
                end)

                return row
            end

            -- ── TOGGLE ──────────────────────────────────
            function Section:AddToggle(opts)
                opts = opts or {}
                local name    = opts.Name    or "Toggle"
                local desc    = opts.Description
                local default = opts.Default ~= nil and opts.Default or false
                local cb      = opts.Callback or function() end
                local flag    = opts.Flag

                local state = default

                -- Load from config if flag set
                if flag and Window._configData[flag] ~= nil then
                    state = Window._configData[flag]
                end

                local row = Instance.new("Frame")
                row.BackgroundColor3 = Theme.BG_Hover
                row.BackgroundTransparency = 0.6
                row.Size = UDim2.new(1, 0, 0, desc and 50 or 36)
                row.LayoutOrder = nextOrder()
                row.ZIndex = 15
                row.Parent = itemsContainer
                Utils.Corner(row, UDim.new(0, 7))
                Utils.Stroke(row, Theme.Border, 1)

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = name
                nameLabel.TextColor3 = Theme.Text
                nameLabel.Font = Theme.FontLight
                nameLabel.TextSize = 12
                nameLabel.BackgroundTransparency = 1
                nameLabel.Size = UDim2.new(1, -70, 0, 18)
                nameLabel.Position = UDim2.new(0, 12, 0, desc and 8 or 9)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.ZIndex = 15
                nameLabel.Parent = row

                if desc then
                    local descLabel = Instance.new("TextLabel")
                    descLabel.Text = desc
                    descLabel.TextColor3 = Theme.TextDim
                    descLabel.Font = Theme.FontMedium
                    descLabel.TextSize = 10
                    descLabel.BackgroundTransparency = 1
                    descLabel.Size = UDim2.new(1, -70, 0, 14)
                    descLabel.Position = UDim2.new(0, 12, 0, 28)
                    descLabel.TextXAlignment = Enum.TextXAlignment.Left
                    descLabel.ZIndex = 15
                    descLabel.Parent = row
                end

                -- Toggle pill
                local pillBg = Instance.new("Frame")
                pillBg.Size = UDim2.fromOffset(40, 22)
                pillBg.Position = UDim2.new(1, -52, 0.5, -11)
                pillBg.BackgroundColor3 = state and Theme.Accent or Theme.BG_Tertiary
                pillBg.ZIndex = 16
                pillBg.Parent = row
                Utils.Corner(pillBg, UDim.new(1, 0))
                Utils.Stroke(pillBg, state and Theme.Accent or Theme.Border, 1)

                local pill = Instance.new("Frame")
                pill.Size = UDim2.fromOffset(16, 16)
                pill.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                pill.BackgroundColor3 = Theme.White
                pill.ZIndex = 17
                pill.Parent = pillBg
                Utils.Corner(pill, UDim.new(1, 0))

                local function UpdateToggle(val)
                    state = val
                    if state then
                        Utils.Tween(pillBg, { BackgroundColor3 = Theme.Accent }, 0.2)
                        Utils.Tween(pill, { Position = UDim2.new(1, -19, 0.5, -8) }, 0.2, Enum.EasingStyle.Back)
                        local s = Instance.new("UIStroke")
                        s.Color = Theme.Accent
                        s.Thickness = 1
                        s.Parent = pillBg
                    else
                        Utils.Tween(pillBg, { BackgroundColor3 = Theme.BG_Tertiary }, 0.2)
                        Utils.Tween(pill, { Position = UDim2.new(0, 3, 0.5, -8) }, 0.2, Enum.EasingStyle.Back)
                        local s = pillBg:FindFirstChildOfClass("UIStroke")
                        if s then
                            Utils.Tween(s, { Color = Theme.Border }, 0.2)
                        end
                    end
                    if flag then
                        Window._configData[flag] = val
                        Utils.SaveConfig(Window._configData, Window._configName)
                    end
                    task.spawn(cb, val)
                end

                UpdateToggle(state)

                local clickArea = Instance.new("TextButton")
                clickArea.BackgroundTransparency = 1
                clickArea.Size = UDim2.fromScale(1, 1)
                clickArea.Text = ""
                clickArea.ZIndex = 18
                clickArea.Parent = row

                clickArea.MouseButton1Click:Connect(function()
                    UpdateToggle(not state)
                end)

                row.MouseEnter:Connect(function()
                    Utils.Tween(row, { BackgroundTransparency = 0.2 }, 0.15)
                end)
                row.MouseLeave:Connect(function()
                    Utils.Tween(row, { BackgroundTransparency = 0.6 }, 0.15)
                end)

                local obj = { Set = UpdateToggle, Get = function() return state end }
                return obj
            end

            -- ── SLIDER ──────────────────────────────────
            function Section:AddSlider(opts)
                opts = opts or {}
                local name    = opts.Name    or "Slider"
                local min     = opts.Min     or 0
                local max     = opts.Max     or 100
                local default = opts.Default ~= nil and opts.Default or min
                local suffix  = opts.Suffix  or ""
                local cb      = opts.Callback or function() end
                local flag    = opts.Flag

                local value = math.clamp(default, min, max)
                if flag and Window._configData[flag] ~= nil then
                    value = Window._configData[flag]
                end

                local row = Instance.new("Frame")
                row.BackgroundColor3 = Theme.BG_Hover
                row.BackgroundTransparency = 0.6
                row.Size = UDim2.new(1, 0, 0, 54)
                row.LayoutOrder = nextOrder()
                row.ZIndex = 15
                row.Parent = itemsContainer
                Utils.Corner(row, UDim.new(0, 7))
                Utils.Stroke(row, Theme.Border, 1)

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = name
                nameLabel.TextColor3 = Theme.Text
                nameLabel.Font = Theme.FontLight
                nameLabel.TextSize = 12
                nameLabel.BackgroundTransparency = 1
                nameLabel.Size = UDim2.new(0.7, 0, 0, 18)
                nameLabel.Position = UDim2.new(0, 12, 0, 8)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.ZIndex = 15
                nameLabel.Parent = row

                local valLabel = Instance.new("TextLabel")
                valLabel.Text = tostring(math.floor(value)) .. suffix
                valLabel.TextColor3 = Theme.AccentBright
                valLabel.Font = Theme.FontMono
                valLabel.TextSize = 12
                valLabel.BackgroundTransparency = 1
                valLabel.Size = UDim2.new(0.3, -12, 0, 18)
                valLabel.Position = UDim2.new(0.7, 0, 0, 8)
                valLabel.TextXAlignment = Enum.TextXAlignment.Right
                valLabel.ZIndex = 15
                valLabel.Parent = row

                -- Track
                local trackBg = Instance.new("Frame")
                trackBg.BackgroundColor3 = Theme.BG_Tertiary
                trackBg.Size = UDim2.new(1, -24, 0, 6)
                trackBg.Position = UDim2.new(0, 12, 0, 34)
                trackBg.ZIndex = 16
                trackBg.Parent = row
                Utils.Corner(trackBg, UDim.new(1, 0))

                local fill = Instance.new("Frame")
                fill.BackgroundColor3 = Theme.Accent
                fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
                fill.ZIndex = 17
                fill.Parent = trackBg
                Utils.Corner(fill, UDim.new(1, 0))
                Utils.GradientFrame(fill, Theme.AccentAlt, Theme.AccentBright, 90)

                -- Thumb
                local thumb = Instance.new("Frame")
                thumb.BackgroundColor3 = Theme.White
                thumb.Size = UDim2.fromOffset(14, 14)
                thumb.Position = UDim2.new((value - min)/(max - min), -7, 0.5, -7)
                thumb.ZIndex = 18
                thumb.Parent = trackBg
                Utils.Corner(thumb, UDim.new(1, 0))

                local function SetValue(v)
                    v = math.clamp(math.floor(v), min, max)
                    value = v
                    local pct = (v - min)/(max - min)
                    Utils.Tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.05)
                    Utils.Tween(thumb, { Position = UDim2.new(pct, -7, 0.5, -7) }, 0.05)
                    valLabel.Text = tostring(v) .. suffix
                    if flag then
                        Window._configData[flag] = v
                        Utils.SaveConfig(Window._configData, Window._configName)
                    end
                    task.spawn(cb, v)
                end

                local draggingSlider = false

                trackBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local rel = (input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X
                        SetValue(min + (max - min) * math.clamp(rel, 0, 1))
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)

                row.MouseEnter:Connect(function()
                    Utils.Tween(row, { BackgroundTransparency = 0.2 }, 0.15)
                end)
                row.MouseLeave:Connect(function()
                    Utils.Tween(row, { BackgroundTransparency = 0.6 }, 0.15)
                end)

                SetValue(value)
                return { Set = SetValue, Get = function() return value end }
            end

            -- ── DROPDOWN ────────────────────────────────
            function Section:AddDropdown(opts)
                opts = opts or {}
                local name    = opts.Name    or "Dropdown"
                local options = opts.Options or {}
                local default = opts.Default or (options[1] or "")
                local cb      = opts.Callback or function() end
                local flag    = opts.Flag

                local selected = default
                if flag and Window._configData[flag] ~= nil then
                    selected = Window._configData[flag]
                end

                local open = false

                local row = Instance.new("Frame")
                row.BackgroundColor3 = Theme.BG_Hover
                row.BackgroundTransparency = 0.6
                row.Size = UDim2.new(1, 0, 0, 36)
                row.LayoutOrder = nextOrder()
                row.ZIndex = 15
                row.ClipsDescendants = false
                row.Parent = itemsContainer
                Utils.Corner(row, UDim.new(0, 7))
                Utils.Stroke(row, Theme.Border, 1)

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = name
                nameLabel.TextColor3 = Theme.Text
                nameLabel.Font = Theme.FontLight
                nameLabel.TextSize = 12
                nameLabel.BackgroundTransparency = 1
                nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
                nameLabel.Position = UDim2.new(0, 12, 0, 0)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.ZIndex = 16
                nameLabel.Parent = row

                local selectedLabel = Instance.new("TextLabel")
                selectedLabel.Text = selected
                selectedLabel.TextColor3 = Theme.AccentBright
                selectedLabel.Font = Theme.FontMono
                selectedLabel.TextSize = 11
                selectedLabel.BackgroundTransparency = 1
                selectedLabel.Size = UDim2.new(0.45, -30, 1, 0)
                selectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
                selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
                selectedLabel.ZIndex = 16
                selectedLabel.Parent = row

                local chevron = Instance.new("TextLabel")
                chevron.Text = "⌄"
                chevron.TextColor3 = Theme.TextMuted
                chevron.Font = Theme.Font
                chevron.TextSize = 14
                chevron.BackgroundTransparency = 1
                chevron.Size = UDim2.fromOffset(20, 20)
                chevron.Position = UDim2.new(1, -26, 0.5, -10)
                chevron.ZIndex = 16
                chevron.Parent = row

                -- Dropdown panel
                local dropPanel = Instance.new("Frame")
                dropPanel.BackgroundColor3 = Theme.BG_Card
                dropPanel.Size = UDim2.new(1, 0, 0, 0)
                dropPanel.Position = UDim2.new(0, 0, 1, 4)
                dropPanel.ZIndex = 50
                dropPanel.ClipsDescendants = true
                dropPanel.Visible = false
                dropPanel.Parent = row
                Utils.Corner(dropPanel, UDim.new(0, 8))
                Utils.Stroke(dropPanel, Theme.BorderBright, 1)
                Utils.Shadow(dropPanel, 12, 0.5)

                local dropScroll = Instance.new("ScrollingFrame")
                dropScroll.BackgroundTransparency = 1
                dropScroll.Size = UDim2.fromScale(1, 1)
                dropScroll.ScrollBarThickness = 2
                dropScroll.ScrollBarImageColor3 = Theme.Accent
                dropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                dropScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                dropScroll.ZIndex = 51
                dropScroll.Parent = dropPanel
                Utils.Padding(dropScroll, 4, 4, 6, 6)
                Utils.ListLayout(dropScroll, Enum.FillDirection.Vertical, 2)

                local maxH = math.min(#options * 30 + 8, 160)

                for _, opt in ipairs(options) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Text = opt
                    optBtn.TextColor3 = opt == selected and Theme.AccentBright or Theme.TextMuted
                    optBtn.Font = opt == selected and Theme.FontLight or Theme.FontMedium
                    optBtn.TextSize = 12
                    optBtn.BackgroundColor3 = opt == selected and Theme.BG_Active or Color3.fromRGB(0,0,0)
                    optBtn.BackgroundTransparency = opt == selected and 0.3 or 1
                    optBtn.Size = UDim2.new(1, 0, 0, 28)
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    optBtn.ZIndex = 52
                    optBtn.Parent = dropScroll
                    Utils.Corner(optBtn, UDim.new(0, 5))
                    Utils.Padding(optBtn, 0, 0, 8, 0)

                    optBtn.MouseEnter:Connect(function()
                        if opt ~= selected then
                            Utils.Tween(optBtn, { BackgroundTransparency = 0.7, TextColor3 = Theme.Text }, 0.1)
                        end
                    end)
                    optBtn.MouseLeave:Connect(function()
                        if opt ~= selected then
                            Utils.Tween(optBtn, { BackgroundTransparency = 1, TextColor3 = Theme.TextMuted }, 0.1)
                        end
                    end)
                    optBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        selectedLabel.Text = opt
                        -- Reset all buttons
                        for _, child in ipairs(dropScroll:GetChildren()) do
                            if child:IsA("TextButton") then
                                Utils.Tween(child, {
                                    BackgroundTransparency = child.Text == opt and 0.3 or 1,
                                    TextColor3 = child.Text == opt and Theme.AccentBright or Theme.TextMuted,
                                }, 0.15)
                            end
                        end
                        -- Close
                        open = false
                        Utils.Tween(dropPanel, { Size = UDim2.new(1, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quart)
                        Utils.Tween(chevron, { Rotation = 0 }, 0.2)
                        task.wait(0.22)
                        dropPanel.Visible = false
                        if flag then
                            Window._configData[flag] = opt
                            Utils.SaveConfig(Window._configData, Window._configName)
                        end
                        task.spawn(cb, opt)
                    end)
                end

                local clickArea = Instance.new("TextButton")
                clickArea.BackgroundTransparency = 1
                clickArea.Size = UDim2.fromScale(1, 1)
                clickArea.Text = ""
                clickArea.ZIndex = 17
                clickArea.Parent = row

                clickArea.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        dropPanel.Visible = true
                        dropPanel.Size = UDim2.new(1, 0, 0, 0)
                        Utils.Tween(dropPanel, { Size = UDim2.new(1, 0, 0, maxH) }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        Utils.Tween(chevron, { Rotation = 180 }, 0.2)
                    else
                        Utils.Tween(dropPanel, { Size = UDim2.new(1, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quart)
                        Utils.Tween(chevron, { Rotation = 0 }, 0.2)
                        task.wait(0.22)
                        dropPanel.Visible = false
                    end
                end)

                row.MouseEnter:Connect(function()
                    Utils.Tween(row, { BackgroundTransparency = 0.2 }, 0.15)
                end)
                row.MouseLeave:Connect(function()
                    Utils.Tween(row, { BackgroundTransparency = 0.6 }, 0.15)
                end)

                return {
                    Set = function(v)
                        selected = v
                        selectedLabel.Text = v
                    end,
                    Get = function() return selected end,
                }
            end

            -- ── INPUT ───────────────────────────────────
            function Section:AddInput(opts)
                opts = opts or {}
                local name    = opts.Name    or "Input"
                local default = opts.Default or ""
                local placeholder = opts.Placeholder or "Valeur..."
                local cb      = opts.Callback or function() end
                local flag    = opts.Flag

                local row = Instance.new("Frame")
                row.BackgroundColor3 = Theme.BG_Hover
                row.BackgroundTransparency = 0.6
                row.Size = UDim2.new(1, 0, 0, 54)
                row.LayoutOrder = nextOrder()
                row.ZIndex = 15
                row.Parent = itemsContainer
                Utils.Corner(row, UDim.new(0, 7))
                Utils.Stroke(row, Theme.Border, 1)

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = name
                nameLabel.TextColor3 = Theme.Text
                nameLabel.Font = Theme.FontLight
                nameLabel.TextSize = 12
                nameLabel.BackgroundTransparency = 1
                nameLabel.Size = UDim2.new(1, -12, 0, 18)
                nameLabel.Position = UDim2.new(0, 12, 0, 7)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.ZIndex = 16
                nameLabel.Parent = row

                local inputBg = Instance.new("Frame")
                inputBg.BackgroundColor3 = Theme.BG_Tertiary
                inputBg.Size = UDim2.new(1, -24, 0, 22)
                inputBg.Position = UDim2.new(0, 12, 0, 26)
                inputBg.ZIndex = 16
                inputBg.Parent = row
                Utils.Corner(inputBg, UDim.new(0, 5))
                local iStroke = Utils.Stroke(inputBg, Theme.Border, 1)

                local input = Instance.new("TextBox")
                input.Text = default
                input.PlaceholderText = placeholder
                input.PlaceholderColor3 = Theme.TextDim
                input.TextColor3 = Theme.Text
                input.Font = Theme.FontMono
                input.TextSize = 11
                input.BackgroundTransparency = 1
                input.Size = UDim2.new(1, -12, 1, 0)
                input.Position = UDim2.new(0, 6, 0, 0)
                input.TextXAlignment = Enum.TextXAlignment.Left
                input.ClearTextOnFocus = false
                input.ZIndex = 17
                input.Parent = inputBg

                input.Focused:Connect(function()
                    Utils.Tween(iStroke, { Color = Theme.Accent }, 0.2)
                end)
                input.FocusLost:Connect(function(enter)
                    Utils.Tween(iStroke, { Color = Theme.Border }, 0.2)
                    if flag then
                        Window._configData[flag] = input.Text
                        Utils.SaveConfig(Window._configData, Window._configName)
                    end
                    task.spawn(cb, input.Text)
                end)

                return {
                    Set = function(v) input.Text = tostring(v) end,
                    Get = function() return input.Text end,
                }
            end

            -- ── LABEL ───────────────────────────────────
            function Section:AddLabel(opts)
                opts = opts or {}
                local text  = opts.Text  or ""
                local color = opts.Color or Theme.TextMuted

                local lbl = Instance.new("TextLabel")
                lbl.Text = text
                lbl.TextColor3 = color
                lbl.Font = Theme.FontMedium
                lbl.TextSize = 11
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(1, 0, 0, 20)
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextWrapped = true
                lbl.LayoutOrder = nextOrder()
                lbl.ZIndex = 15
                lbl.Parent = itemsContainer

                return { Set = function(v) lbl.Text = v end }
            end

            return Section
        end

        return Tab
    end

    -- Show main UI (after intro / key)
    local function ShowMain(delay)
        task.delay(delay or 0, function()
            mainFrame.Visible = true
            mainFrame.BackgroundTransparency = 1
            mainFrame.Size = UDim2.fromOffset(size.X * 0.95, size.Y * 0.95)
            mainFrame.Position = UDim2.new(0.5, -(size.X * 0.95)/2, 0.5, -(size.Y * 0.95)/2)
            Utils.Tween(mainFrame, {
                BackgroundTransparency = 0,
                Size = UDim2.fromOffset(size.X, size.Y),
                Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2),
            }, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)
    end

    -- Sequence: intro → key → main
    if showIntro then
        local introDur = ShowIntro(gui)
        if key then
            task.delay(introDur, function()
                ShowKeySystem(gui, key, function(success)
                    if success then ShowMain(0.1) end
                end)
            end)
        else
            ShowMain(introDur)
        end
    elseif key then
        ShowKeySystem(gui, key, function(success)
            if success then ShowMain(0.2) end
        end)
    else
        ShowMain(0)
    end

    return Window
end

-- ┌─────────────────────────────────────────┐
-- │              RETURN                     │
-- └─────────────────────────────────────────┘

return Amnezia
