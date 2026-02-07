local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local viewport = workspace.CurrentCamera.ViewportSize
local Colors = {
    Glass = Color3.fromRGB(18, 18, 24),
    GlassLight = Color3.fromRGB(28, 28, 36),
    GlassDark = Color3.fromRGB(12, 12, 16),
    WindowTransparency = 0.12,
    TitleBarTransparency = 0.08,
    ButtonTransparency = 0.35,
    Border = Color3.fromRGB(55, 55, 70),
    BorderLight = Color3.fromRGB(70, 70, 90),
    Accent = Color3.fromRGB(255, 107, 157),
    Separator = Color3.fromRGB(60, 60, 75),
    Warning = Color3.fromRGB(255, 200, 80),
    Error = Color3.fromRGB(255, 90, 90),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 175),
    TextMuted = Color3.fromRGB(90, 90, 105),
    Overlay = Color3.fromRGB(0, 0, 0),
}
local Icons = {
    Minimize = "rbxassetid://71686683787518",
    Close = "rbxassetid://121948938505669",
    Logo = "rbxassetid://120200589320469",
}
local function isMobile()
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
        and not UserInputService.MouseEnabled
end
local function CreateRipple(button, x, y)
    spawn(function()
        button.ClipsDescendants = true
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y)
        ripple.ZIndex = button.ZIndex + 1
        ripple.Parent = button
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple
        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
        TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, size, 0, size),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        }):Play()
        wait(0.5)
        ripple:Destroy()
    end)
end
local function MakeDraggable(handle, target)
    local dragging = false
    local dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            TweenService:Create(target, TweenInfo.new(0.1), {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
end
local function MakeResizable(target, minW, minH)
    minW = minW or 400
    minH = minH or 280
    local handle = Instance.new("Frame")
    handle.Name = "ResizeHandle"
    handle.Size = UDim2.new(0, 20, 0, 20)
    handle.Position = UDim2.new(1, -20, 1, -20)
    handle.BackgroundTransparency = 1
    handle.Parent = target
    for i = 1, 2 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0, 8 + (i * 3), 0, 1)
        line.Position = UDim2.new(1, -(10 + (i * 4)), 1, -(4 + (i * 3)))
        line.BackgroundColor3 = Colors.TextMuted
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0
        line.Rotation = -45
        line.Parent = handle
    end
    local dragging = false
    local dragStart, startSize
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startSize = target.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newW = math.max(startSize.X.Offset + delta.X, minW)
            local newH = math.max(startSize.Y.Offset + delta.Y, minH)
            TweenService:Create(target, TweenInfo.new(0.08), {
                Size = UDim2.new(0, newW, 0, newH)
            }):Play()
        end
    end)
end
local CoralX = {}
CoralX.__index = CoralX
function CoralX:Window(config)
    config = config or {}
    config.Title = config.Title or "CoralX"
    config.Color = config.Color or Colors.Accent
    config.Size = config.Size or {Width = 620, Height = 400}
    local Window = {}
    local isMinimized = false
    local fullSize = UDim2.new(0, config.Size.Width, 0, config.Size.Height)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CoralX"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainWindow"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = fullSize
    MainFrame.BackgroundColor3 = Colors.Glass
    MainFrame.BackgroundTransparency = Colors.WindowTransparency
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    local MainBorder = Instance.new("UIStroke")
    MainBorder.Color = Colors.Border
    MainBorder.Thickness = 1
    MainBorder.Transparency = 0.4
    MainBorder.Parent = MainFrame
    local InnerGlass = Instance.new("Frame")
    InnerGlass.Name = "InnerGlass"
    InnerGlass.Size = UDim2.new(1, -2, 1, -2)
    InnerGlass.Position = UDim2.new(0, 1, 0, 1)
    InnerGlass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InnerGlass.BackgroundTransparency = 0.97
    InnerGlass.BorderSizePixel = 0
    InnerGlass.ZIndex = 0
    InnerGlass.Parent = MainFrame
    local InnerCorner = Instance.new("UICorner")
    InnerCorner.CornerRadius = UDim.new(0, 11)
    InnerCorner.Parent = InnerGlass
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 44)
    TitleBar.BackgroundColor3 = Colors.GlassLight
    TitleBar.BackgroundTransparency = Colors.TitleBarTransparency
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 5
    TitleBar.Parent = MainFrame
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    local TitleMask = Instance.new("Frame")
    TitleMask.Name = "Mask"
    TitleMask.Size = UDim2.new(1, 0, 0, 12)
    TitleMask.Position = UDim2.new(0, 0, 1, -12)
    TitleMask.BackgroundColor3 = Colors.GlassLight
    TitleMask.BackgroundTransparency = Colors.TitleBarTransparency
    TitleMask.BorderSizePixel = 0
    TitleMask.ZIndex = 5
    TitleMask.Parent = TitleBar
    local SeparatorLine = Instance.new("Frame")
    SeparatorLine.Name = "Separator"
    SeparatorLine.Size = UDim2.new(1, 0, 0, 1)
    SeparatorLine.Position = UDim2.new(0, 0, 1, 0)
    SeparatorLine.BackgroundColor3 = Colors.Separator
    SeparatorLine.BackgroundTransparency = 0.4
    SeparatorLine.BorderSizePixel = 0
    SeparatorLine.ZIndex = 6
    SeparatorLine.Parent = TitleBar
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 44, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = config.Title
    TitleLabel.TextColor3 = config.Color
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 6
    TitleLabel.Parent = TitleBar
    local HeaderLogo = Instance.new("ImageLabel")
    HeaderLogo.Name = "HeaderLogo"
    HeaderLogo.Size = UDim2.new(0, 24, 0, 24)
    HeaderLogo.Position = UDim2.new(0, 12, 0.5, -12)
    HeaderLogo.BackgroundTransparency = 1
    HeaderLogo.Image = "rbxassetid://119820737908622"
    HeaderLogo.ZIndex = 6
    HeaderLogo.Parent = TitleBar
    local ControlsFrame = Instance.new("Frame")
    ControlsFrame.Name = "Controls"
    ControlsFrame.Size = UDim2.new(0, 72, 0, 28)
    ControlsFrame.Position = UDim2.new(1, -84, 0.5, -14)
    ControlsFrame.BackgroundTransparency = 1
    ControlsFrame.ZIndex = 7
    ControlsFrame.Parent = TitleBar
    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsLayout.Padding = UDim.new(0, 5)
    ControlsLayout.Parent = ControlsFrame
    local function CreateButton(name, icon, hoverColor, order)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.LayoutOrder = order
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 8
        btn.Parent = ControlsFrame
        local iconLabel = Instance.new("ImageLabel")
        iconLabel.Name = "Icon"
        iconLabel.Size = UDim2.new(0, 24, 0, 24)
        iconLabel.Position = UDim2.new(0.5, -12, 0.5, -12)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Image = icon
        iconLabel.ImageColor3 = Colors.TextSecondary
        iconLabel.ZIndex = 9
        iconLabel.Parent = btn
        btn.MouseEnter:Connect(function()
            TweenService:Create(iconLabel, TweenInfo.new(0.15), {
                ImageColor3 = hoverColor
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(iconLabel, TweenInfo.new(0.15), {
                ImageColor3 = Colors.TextSecondary
            }):Play()
        end)
        return btn
    end
    local MinimizeBtn = CreateButton("Minimize", Icons.Minimize, Colors.Warning, 1)
    local CloseBtn = CreateButton("Close", Icons.Close, Colors.Error, 2)
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "Sidebar"
    TabContainer.Size = UDim2.new(0, 160, 1, -46)
    TabContainer.Position = UDim2.new(0, 0, 0, 46)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 2
    TabContainer.ScrollBarImageColor3 = config.Color
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ZIndex = 5
    TabContainer.Parent = MainFrame
    local TabPadding = Instance.new("UIListLayout")
    TabPadding.SortOrder = Enum.SortOrder.LayoutOrder
    TabPadding.Padding = UDim.new(0, 6)
    TabPadding.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabPadding.Parent = TabContainer
    local TabPad = Instance.new("UIPadding")
    TabPad.PaddingTop = UDim.new(0, 10)
    TabPad.Parent = TabContainer
    local SidebarLine = Instance.new("Frame")
    SidebarLine.Name = "SidebarLine"
    SidebarLine.Size = UDim2.new(0, 1, 1, -46)
    SidebarLine.Position = UDim2.new(0, 160, 0, 46)
    SidebarLine.BackgroundColor3 = Colors.Separator
    SidebarLine.BackgroundTransparency = 0.5
    SidebarLine.BorderSizePixel = 0
    SidebarLine.ZIndex = 5
    SidebarLine.Parent = MainFrame
    local Pages = Instance.new("Frame")
    Pages.Name = "Pages"
    Pages.Size = UDim2.new(1, -161, 1, -46)
    Pages.Position = UDim2.new(0, 161, 0, 46)
    Pages.BackgroundTransparency = 1
    Pages.ClipsDescendants = true
    Pages.ZIndex = 5
    Pages.Parent = MainFrame
    local ToggleUI = Instance.new("ImageButton")
    ToggleUI.Name = "ToggleUI"
    ToggleUI.Size = UDim2.new(0, 46, 0, 46)
    ToggleUI.Position = UDim2.new(0, 20, 0.5, -23)
    ToggleUI.BackgroundColor3 = Colors.Glass
    ToggleUI.BackgroundTransparency = 0.1
    ToggleUI.BorderSizePixel = 0
    ToggleUI.Image = ""
    ToggleUI.Visible = false
    ToggleUI.ZIndex = 10
    ToggleUI.Parent = ScreenGui
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleUI
    local ToggleBorder = Instance.new("UIStroke")
    ToggleBorder.Color = Colors.Border
    ToggleBorder.Thickness = 1
    ToggleBorder.Transparency = 0.4
    ToggleBorder.Parent = ToggleUI
    local ToggleLogo = Instance.new("ImageLabel")
    ToggleLogo.Name = "Logo"
    ToggleLogo.AnchorPoint = Vector2.new(0.5, 0.5)
    ToggleLogo.Size = UDim2.new(1, -6, 1, -6)
    ToggleLogo.Position = UDim2.new(0.5, 0, 0.5, 0)
    ToggleLogo.BackgroundTransparency = 1
    ToggleLogo.Image = Icons.Logo
    ToggleLogo.ImageColor3 = config.Color
    ToggleLogo.ZIndex = 11
    ToggleLogo.Parent = ToggleUI
    ToggleUI.MouseEnter:Connect(function()
        TweenService:Create(ToggleUI, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            Size = UDim2.new(0, 50, 0, 50),
            Position = UDim2.new(0, 18, 0.5, -25)
        }):Play()
        TweenService:Create(ToggleBorder, TweenInfo.new(0.2), {
            Color = config.Color,
            Transparency = 0.2
        }):Play()
    end)
    ToggleUI.MouseLeave:Connect(function()
        TweenService:Create(ToggleUI, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0, 46, 0, 46),
            Position = UDim2.new(0, 20, 0.5, -23)
        }):Play()
        TweenService:Create(ToggleBorder, TweenInfo.new(0.2), {
            Color = Colors.Border,
            Transparency = 0.4
        }):Play()
    end)
    local toggleDragging = false
    local dragStart = Vector2.new()
    local startPos = Vector2.new()
    local hasDragged = false
    ToggleUI.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggleDragging = true
            dragStart = input.Position
            startPos = ToggleUI.AbsolutePosition
            hasDragged = false
            TweenService:Create(ToggleUI, TweenInfo.new(0.1), {Size = UDim2.new(0, 42, 0, 42)}):Play()
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    toggleDragging = false
                    TweenService:Create(ToggleUI, TweenInfo.new(0.1), {Size = UDim2.new(0, 46, 0, 46)}):Play()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 3 then
                hasDragged = true
            end
            local newX = startPos.X + delta.X
            local newY = startPos.Y + delta.Y
            ToggleUI.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
    local function ShowWindow()
        isMinimized = false
        ToggleUI.Visible = false
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 1
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = fullSize,
            BackgroundTransparency = Colors.WindowTransparency
        }):Play()
    end
    local function HideWindow()
        isMinimized = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        wait(0.25)
        MainFrame.Visible = false
        ToggleUI.Visible = true
        ToggleUI.Size = UDim2.new(0, 0, 0, 0)
        ToggleUI.BackgroundTransparency = 1
        TweenService:Create(ToggleUI, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 46, 0, 46),
            BackgroundTransparency = 0.1
        }):Play()
    end
    MinimizeBtn.Activated:Connect(function()
        HideWindow()
    end)
    ToggleUI.MouseButton1Up:Connect(function()
        if not hasDragged then
            ShowWindow()
        end
    end)
    CloseBtn.Activated:Connect(function()
        CreateRipple(CloseBtn, Mouse.X, Mouse.Y)
        local Overlay = Instance.new("Frame")
        Overlay.Name = "Overlay"
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Colors.Overlay
        Overlay.BackgroundTransparency = 1
        Overlay.ZIndex = 50
        Overlay.Parent = MainFrame
        TweenService:Create(Overlay, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.5
        }):Play()
        local Dialog = Instance.new("Frame")
        Dialog.Name = "Dialog"
        Dialog.AnchorPoint = Vector2.new(0.5, 0.5)
        Dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
        Dialog.Size = UDim2.new(0, 0, 0, 0)
        Dialog.BackgroundColor3 = Colors.Glass
        Dialog.BackgroundTransparency = 0.05
        Dialog.BorderSizePixel = 0
        Dialog.ZIndex = 51
        Dialog.Parent = Overlay
        local dialogCorner = Instance.new("UICorner")
        dialogCorner.CornerRadius = UDim.new(0, 12)
        dialogCorner.Parent = Dialog
        local dialogStroke = Instance.new("UIStroke")
        dialogStroke.Color = Colors.Border
        dialogStroke.Thickness = 1
        dialogStroke.Transparency = 0.4
        dialogStroke.Parent = Dialog
        TweenService:Create(Dialog, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 280, 0, 130)
        }):Play()
        wait(0.1)
        local dialogHeader = Instance.new("Frame")
        dialogHeader.Size = UDim2.new(1, 0, 0, 40)
        dialogHeader.BackgroundColor3 = Colors.GlassLight
        dialogHeader.BackgroundTransparency = 0.3
        dialogHeader.BorderSizePixel = 0
        dialogHeader.ZIndex = 52
        dialogHeader.Parent = Dialog
        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 12)
        headerCorner.Parent = dialogHeader
        local headerMask = Instance.new("Frame")
        headerMask.Size = UDim2.new(1, 0, 0, 12)
        headerMask.Position = UDim2.new(0, 0, 1, -12)
        headerMask.BackgroundColor3 = Colors.GlassLight
        headerMask.BackgroundTransparency = 0.3
        headerMask.BorderSizePixel = 0
        headerMask.ZIndex = 52
        headerMask.Parent = dialogHeader
        local headerText = Instance.new("TextLabel")
        headerText.Size = UDim2.new(1, 0, 1, 0)
        headerText.BackgroundTransparency = 1
        headerText.Font = Enum.Font.GothamBold
        headerText.Text = "Close CoralX?"
        headerText.TextColor3 = Colors.TextPrimary
        headerText.TextSize = 14
        headerText.ZIndex = 53
        headerText.Parent = dialogHeader
        local msgText = Instance.new("TextLabel")
        msgText.Size = UDim2.new(1, -24, 0, 30)
        msgText.Position = UDim2.new(0, 12, 0, 45)
        msgText.BackgroundTransparency = 1
        msgText.Font = Enum.Font.Gotham
        msgText.Text = "Are you sure you want to close?"
        msgText.TextColor3 = Colors.TextSecondary
        msgText.TextSize = 12
        msgText.ZIndex = 52
        msgText.Parent = Dialog
        local btnContainer = Instance.new("Frame")
        btnContainer.Size = UDim2.new(1, -24, 0, 34)
        btnContainer.Position = UDim2.new(0, 12, 1, -46)
        btnContainer.BackgroundTransparency = 1
        btnContainer.ZIndex = 52
        btnContainer.Parent = Dialog
        local yesBtn = Instance.new("TextButton")
        yesBtn.Size = UDim2.new(0.48, 0, 1, 0)
        yesBtn.Position = UDim2.new(0, 0, 0, 0)
        yesBtn.BackgroundColor3 = Colors.Error
        yesBtn.BackgroundTransparency = 0.3
        yesBtn.BorderSizePixel = 0
        yesBtn.Font = Enum.Font.GothamBold
        yesBtn.Text = "Yes"
        yesBtn.TextColor3 = Colors.TextPrimary
        yesBtn.TextSize = 12
        yesBtn.AutoButtonColor = false
        yesBtn.ZIndex = 53
        yesBtn.Parent = btnContainer
        local yesCorner = Instance.new("UICorner")
        yesCorner.CornerRadius = UDim.new(0, 6)
        yesCorner.Parent = yesBtn
        yesBtn.MouseEnter:Connect(function()
            TweenService:Create(yesBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
        end)
        yesBtn.MouseLeave:Connect(function()
            TweenService:Create(yesBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
        end)
        yesBtn.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)
        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
        cancelBtn.Position = UDim2.new(0.52, 0, 0, 0)
        cancelBtn.BackgroundColor3 = Colors.GlassLight
        cancelBtn.BackgroundTransparency = 0.3
        cancelBtn.BorderSizePixel = 0
        cancelBtn.Font = Enum.Font.GothamBold
        cancelBtn.Text = "Cancel"
        cancelBtn.TextColor3 = Colors.TextPrimary
        cancelBtn.TextSize = 12
        cancelBtn.AutoButtonColor = false
        cancelBtn.ZIndex = 53
        cancelBtn.Parent = btnContainer
        local cancelCorner = Instance.new("UICorner")
        cancelCorner.CornerRadius = UDim.new(0, 6)
        cancelCorner.Parent = cancelBtn
        cancelBtn.MouseEnter:Connect(function()
            TweenService:Create(cancelBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
        end)
        cancelBtn.MouseLeave:Connect(function()
            TweenService:Create(cancelBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
        end)
        cancelBtn.MouseButton1Click:Connect(function()
            TweenService:Create(Dialog, TweenInfo.new(0.15), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            TweenService:Create(Overlay, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            wait(0.2)
            Overlay:Destroy()
        end)
    end)
    MakeDraggable(TitleBar, MainFrame)
    MakeResizable(MainFrame, 350, 200)
    local isBindingKey = false
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if isBindingKey then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            if isMinimized then
                ShowWindow()
            else
                HideWindow()
            end
        end
    end)
    local function FormatKeyName(keyCode)
        local name = keyCode.Name
        local nums = {Zero = "0", One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9"}
        return nums[name] or name
    end
    local ActiveIndicator = Instance.new("Frame")
    ActiveIndicator.Name = "ActiveIndicator"
    ActiveIndicator.Size = UDim2.new(0, 3, 0, 16)
    ActiveIndicator.BackgroundColor3 = config.Color
    ActiveIndicator.BorderSizePixel = 0
    ActiveIndicator.ZIndex = 8
    ActiveIndicator.Visible = false
    ActiveIndicator.Parent = MainFrame
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 2)
    IndicatorCorner.Parent = ActiveIndicator
    local function UpdateIndicatorPosition(btn)
        local relativeY = btn.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y + (btn.AbsoluteSize.Y/2) - (ActiveIndicator.Size.Y.Offset/2)
        local relativeX = 0
        local relX = btn.AbsolutePosition.X - MainFrame.AbsolutePosition.X
        TweenService:Create(ActiveIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, relX, 0, relativeY)
        }):Play()
    end
    function Window:Tab(name, icon)
        local Tab = {}
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name
        TabBtn.Size = UDim2.new(0, 140, 0, 36)
        TabBtn.BackgroundColor3 = Colors.GlassLight
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.ZIndex = 6
        TabBtn.Parent = TabContainer
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabBtn
        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Size = UDim2.new(0, 18, 0, 18)
        TabIcon.Position = UDim2.new(0, 12, 0.5, -9)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = icon or "rbxassetid://7072717958"
        TabIcon.ImageColor3 = Colors.TextSecondary
        TabIcon.ZIndex = 7
        TabIcon.Parent = TabBtn
        local TabText = Instance.new("TextLabel")
        TabText.Size = UDim2.new(0, 0, 1, 0)
        TabText.Position = UDim2.new(0, 40, 0, 0)
        TabText.BackgroundTransparency = 1
        TabText.Font = Enum.Font.GothamMedium
        TabText.Text = name
        TabText.TextColor3 = Colors.TextSecondary
        TabText.TextSize = 13
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.ZIndex = 7
        TabText.Parent = TabBtn
        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "_Page"
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = config.Color
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false
        Page.ZIndex = 6
        Page.Parent = Pages
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = Page
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Name = "SectionTitle"
        SectionTitle.Size = UDim2.new(1, 0, 0, 40)
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.Text = name
        SectionTitle.TextColor3 = Colors.TextPrimary
        SectionTitle.TextSize = 22
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.LayoutOrder = -1
        SectionTitle.Parent = Page
        local function Activate()
            for _, child in pairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    TweenService:Create(child.ImageLabel, TweenInfo.new(0.25), {ImageColor3 = Colors.TextSecondary}):Play()
                    TweenService:Create(child.TextLabel, TweenInfo.new(0.25), {TextColor3 = Colors.TextSecondary}):Play()
                    TweenService:Create(child, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(child.ImageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 12, 0.5, -9)}):Play()
                    TweenService:Create(child.TextLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 40, 0, 0)}):Play()
                end
            end
            for _, child in pairs(Pages:GetChildren()) do
                child.Visible = false
            end
            Page.Visible = true
            TweenService:Create(TabIcon, TweenInfo.new(0.25), {ImageColor3 = config.Color}):Play()
            TweenService:Create(TabText, TweenInfo.new(0.25), {TextColor3 = config.Color}):Play()
            TweenService:Create(TabBtn, TweenInfo.new(0.25), {BackgroundTransparency = 0.9}):Play()
            TweenService:Create(TabIcon, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 18, 0.5, -9)}):Play()
            TweenService:Create(TabText, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 46, 0, 0)}):Play()
            ActiveIndicator.Visible = true
            UpdateIndicatorPosition(TabBtn)
        end
        TabBtn.MouseButton1Click:Connect(Activate)
        if not FirstTab then
            FirstTab = Tab
            spawn(function() wait(0.05) Activate() end)
        end
        function Tab:Button(text, callback)
            callback = callback or function() end
            local Button = Instance.new("TextButton")
            Button.Name = "Button"
            Button.Size = UDim2.new(1, -4, 0, 36)
            Button.BackgroundColor3 = Colors.GlassDark
            Button.BackgroundTransparency = 0.4
            Button.BorderSizePixel = 0
            Button.Text = ""
            Button.AutoButtonColor = false
            Button.Parent = Page
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = Button
            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Colors.Border
            BtnStroke.Thickness = 1
            BtnStroke.Transparency = 0.6
            BtnStroke.Parent = Button
            local BtnText = Instance.new("TextLabel")
            BtnText.Size = UDim2.new(1, 0, 1, 0)
            BtnText.BackgroundTransparency = 1
            BtnText.Font = Enum.Font.GothamMedium
            BtnText.Text = text
            BtnText.TextColor3 = Colors.TextPrimary
            BtnText.TextSize = 13
            BtnText.Parent = Button
            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.3, BackgroundColor3 = Colors.GlassLight}):Play()
                TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Color = config.Color, Transparency = 0.4}):Play()
            end)
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.4, BackgroundColor3 = Colors.GlassDark}):Play()
                TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Color = Colors.Border, Transparency = 0.6}):Play()
            end)
            Button.MouseButton1Click:Connect(function()
                CreateRipple(Button, Mouse.X, Mouse.Y)
                pcall(callback)
            end)
        end
        function Tab:Toggle(text, default, callback)
            default = default or false
            callback = callback or function() end
            local toggled = default
            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Name = "Toggle"
            ToggleFrame.Size = UDim2.new(1, -4, 0, 38)
            ToggleFrame.BackgroundColor3 = Colors.GlassDark
            ToggleFrame.BackgroundTransparency = 0.5
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Parent = Page
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame
            local ToggleStroke = Instance.new("UIStroke")
            ToggleStroke.Color = Colors.Border
            ToggleStroke.Thickness = 1
            ToggleStroke.Transparency = 0.7
            ToggleStroke.Parent = ToggleFrame
            local ToggleText = Instance.new("TextLabel")
            ToggleText.Size = UDim2.new(1, -60, 1, 0)
            ToggleText.Position = UDim2.new(0, 12, 0, 0)
            ToggleText.BackgroundTransparency = 1
            ToggleText.Font = Enum.Font.GothamMedium
            ToggleText.Text = text
            ToggleText.TextColor3 = Colors.TextSecondary
            ToggleText.TextSize = 13
            ToggleText.TextXAlignment = Enum.TextXAlignment.Left
            ToggleText.Parent = ToggleFrame
            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 40, 0, 22)
            Switch.Position = UDim2.new(1, -52, 0.5, -11)
            Switch.BackgroundColor3 = toggled and config.Color or Colors.GlassLight
            Switch.BackgroundTransparency = toggled and 0.2 or 0.6
            Switch.Parent = ToggleFrame
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = Switch
            local SwitchKnob = Instance.new("Frame")
            SwitchKnob.Size = UDim2.new(0, 18, 0, 18)
            SwitchKnob.Position = UDim2.new(0, toggled and 20 or 2, 0.5, -9)
            SwitchKnob.BackgroundColor3 = Colors.TextPrimary
            SwitchKnob.Parent = Switch
            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = SwitchKnob
            local function UpdateToggle()
                if toggled then
                    TweenService:Create(Switch, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                        BackgroundColor3 = config.Color,
                        BackgroundTransparency = 0.2
                    }):Play()
                    TweenService:Create(SwitchKnob, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                        Position = UDim2.new(0, 20, 0.5, -9)
                    }):Play()
                    TweenService:Create(ToggleText, TweenInfo.new(0.2), {TextColor3 = Colors.TextPrimary}):Play()
                else
                    TweenService:Create(Switch, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                        BackgroundColor3 = Colors.GlassLight,
                        BackgroundTransparency = 0.6
                    }):Play()
                    TweenService:Create(SwitchKnob, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                        Position = UDim2.new(0, 2, 0.5, -9)
                    }):Play()
                    TweenService:Create(ToggleText, TweenInfo.new(0.2), {TextColor3 = Colors.TextSecondary}):Play()
                end
                pcall(callback, toggled)
            end
            ToggleFrame.MouseButton1Click:Connect(function()
                toggled = not toggled
                UpdateToggle()
            end)
            UpdateToggle()
        end
        function Tab:Slider(text, min, max, default, callback)
            min = min or 0
            max = max or 100
            default = default or min
            callback = callback or function() end
            local value = default
            local dragging = false
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = "Slider"
            SliderFrame.Size = UDim2.new(1, -4, 0, 60)
            SliderFrame.BackgroundColor3 = Colors.GlassDark
            SliderFrame.BackgroundTransparency = 0.5
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = Page
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame
            local SliderStroke = Instance.new("UIStroke")
            SliderStroke.Color = Colors.Border
            SliderStroke.Thickness = 1
            SliderStroke.Transparency = 0.7
            SliderStroke.Parent = SliderFrame
            local SliderText = Instance.new("TextLabel")
            SliderText.Size = UDim2.new(1, -20, 0, 20)
            SliderText.Position = UDim2.new(0, 12, 0, 8)
            SliderText.BackgroundTransparency = 1
            SliderText.Font = Enum.Font.GothamMedium
            SliderText.Text = text
            SliderText.TextColor3 = Colors.TextSecondary
            SliderText.TextSize = 13
            SliderText.TextXAlignment = Enum.TextXAlignment.Left
            SliderText.Parent = SliderFrame
            local ValueText = Instance.new("TextLabel")
            ValueText.Size = UDim2.new(0, 40, 0, 20)
            ValueText.Position = UDim2.new(1, -52, 0, 8)
            ValueText.BackgroundTransparency = 1
            ValueText.Font = Enum.Font.GothamBold
            ValueText.Text = tostring(value)
            ValueText.TextColor3 = Colors.TextPrimary
            ValueText.TextSize = 13
            ValueText.TextXAlignment = Enum.TextXAlignment.Right
            ValueText.Parent = SliderFrame
            local BarBG = Instance.new("Frame")
            BarBG.Name = "BarBG"
            BarBG.Size = UDim2.new(1, -24, 0, 4)
            BarBG.Position = UDim2.new(0, 12, 0, 38)
            BarBG.BackgroundColor3 = Colors.GlassLight
            BarBG.BorderSizePixel = 0
            BarBG.Parent = SliderFrame
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(1, 0)
            BarCorner.Parent = BarBG
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = config.Color
            Fill.BorderSizePixel = 0
            Fill.Parent = BarBG
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 12, 0, 12)
            Knob.Position = UDim2.new(1, -6, 0.5, -6)
            Knob.BackgroundColor3 = Color3.new(1, 1, 1)
            Knob.BorderSizePixel = 0
            Knob.Parent = Fill
            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = Knob
            local Hitbox = Instance.new("TextButton")
            Hitbox.Name = "Hitbox"
            Hitbox.Size = UDim2.new(1, 0, 0, 24)
            Hitbox.Position = UDim2.new(0, 0, 0.5, -12)
            Hitbox.BackgroundTransparency = 1
            Hitbox.Text = ""
            Hitbox.Parent = BarBG
            local function UpdateSlider(input)
                local pos = UDim2.new(math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1), 0, 1, 0)
                Fill.Size = pos
                local newVal = math.floor(min + ((max - min) * pos.X.Scale))
                ValueText.Text = tostring(newVal)
                pcall(callback, newVal)
            end
            Hitbox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(input)
                    TweenService:Create(Knob, TweenInfo.new(0.1), {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -8, 0.5, -8)}):Play()
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    TweenService:Create(Knob, TweenInfo.new(0.1), {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6)}):Play()
                end
            end)
        end
        function Tab:Textbox(text, placeholder, callback)
            callback = callback or function() end
            local BoxFrame = Instance.new("Frame")
            BoxFrame.Name = "Textbox"
            BoxFrame.Size = UDim2.new(1, -4, 0, 38)
            BoxFrame.BackgroundColor3 = Colors.GlassDark
            BoxFrame.BackgroundTransparency = 0.5
            BoxFrame.BorderSizePixel = 0
            BoxFrame.Parent = Page
            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 6)
            BoxCorner.Parent = BoxFrame
            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Color = Colors.Border
            BoxStroke.Thickness = 1
            BoxStroke.Transparency = 0.7
            BoxStroke.Parent = BoxFrame
            local BoxLabel = Instance.new("TextLabel")
            BoxLabel.Size = UDim2.new(0, 0, 1, 0)
            BoxLabel.Position = UDim2.new(0, 12, 0, 0)
            BoxLabel.BackgroundTransparency = 1
            BoxLabel.Font = Enum.Font.GothamMedium
            BoxLabel.Text = text
            BoxLabel.TextColor3 = Colors.TextSecondary
            BoxLabel.TextSize = 13
            BoxLabel.TextXAlignment = Enum.TextXAlignment.Left
            BoxLabel.Parent = BoxFrame
            local Input = Instance.new("TextBox")
            Input.Size = UDim2.new(0, 140, 0, 24)
            Input.Position = UDim2.new(1, -152, 0.5, -12)
            Input.BackgroundColor3 = Colors.GlassLight
            Input.BackgroundTransparency = 0.6
            Input.BorderSizePixel = 0
            Input.Font = Enum.Font.Gotham
            Input.PlaceholderText = placeholder or "Type here..."
            Input.Text = ""
            Input.TextColor3 = Colors.TextPrimary
            Input.PlaceholderColor3 = Colors.TextMuted
            Input.TextSize = 12
            Input.Parent = BoxFrame
            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 4)
            InputCorner.Parent = Input
            local InputStroke = Instance.new("UIStroke")
            InputStroke.Color = Colors.Border
            InputStroke.Thickness = 1
            InputStroke.Transparency = 0.8
            InputStroke.Parent = Input
            Input.Focused:Connect(function()
                TweenService:Create(Input, TweenInfo.new(0.2), {PlaceholderColor3 = Colors.TextPrimary}):Play()
                TweenService:Create(Input, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
            end)
            Input.FocusLost:Connect(function(enter)
                TweenService:Create(Input, TweenInfo.new(0.2), {PlaceholderColor3 = Colors.TextMuted}):Play()
                TweenService:Create(Input, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()
                pcall(callback, Input.Text)
            end)
        end
        function Tab:Keybind(text, default, callback)
            default = default or Enum.KeyCode.RightControl
            callback = callback or function() end
            local binding = false
            local key = default
            local KeyFrame = Instance.new("Frame")
            KeyFrame.Name = "Keybind"
            KeyFrame.Size = UDim2.new(1, -4, 0, 38)
            KeyFrame.BackgroundColor3 = Colors.GlassDark
            KeyFrame.BackgroundTransparency = 0.5
            KeyFrame.BorderSizePixel = 0
            KeyFrame.Parent = Page
            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 6)
            KeyCorner.Parent = KeyFrame
            local KeyStroke = Instance.new("UIStroke")
            KeyStroke.Color = Colors.Border
            KeyStroke.Thickness = 1
            KeyStroke.Transparency = 0.7
            KeyStroke.Parent = KeyFrame
            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Size = UDim2.new(0, 0, 1, 0)
            KeyLabel.Position = UDim2.new(0, 12, 0, 0)
            KeyLabel.BackgroundTransparency = 1
            KeyLabel.Font = Enum.Font.GothamMedium
            KeyLabel.Text = text
            KeyLabel.TextColor3 = Colors.TextSecondary
            KeyLabel.TextSize = 13
            KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeyLabel.Parent = KeyFrame
            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Size = UDim2.new(0, 80, 0, 24)
            KeyBtn.Position = UDim2.new(1, -92, 0.5, -12)
            KeyBtn.BackgroundColor3 = Colors.GlassLight
            KeyBtn.BackgroundTransparency = 0.6
            KeyBtn.BorderSizePixel = 0
            KeyBtn.Font = Enum.Font.GothamBold
            KeyBtn.Text = key.Name
            KeyBtn.TextColor3 = Colors.TextPrimary
            KeyBtn.TextSize = 12
            KeyBtn.AutoButtonColor = false
            KeyBtn.Parent = KeyFrame
            local KeyBtnCorner = Instance.new("UICorner")
            KeyBtnCorner.CornerRadius = UDim.new(0, 4)
            KeyBtnCorner.Parent = KeyBtn
            local KeyBtnStroke = Instance.new("UIStroke")
            KeyBtnStroke.Color = Colors.Border
            KeyBtnStroke.Thickness = 1
            KeyBtnStroke.Transparency = 0.8
            KeyBtnStroke.Parent = KeyBtn
            KeyBtn.MouseButton1Click:Connect(function()
                binding = true
                isBindingKey = true
                KeyBtn.Text = "..."
            end)
            UserInputService.InputBegan:Connect(function(input)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    binding = false
                    isBindingKey = false
                    key = input.KeyCode
                    KeyBtn.Text = FormatKeyName(key)
                    pcall(callback, key)
                end
            end)
        end
        function Tab:Paragraph(title, content)
            title = title or ""
            content = content or ""
            local ParagraphFrame = Instance.new("Frame")
            ParagraphFrame.Name = "Paragraph"
            ParagraphFrame.Size = UDim2.new(1, -4, 0, 50)
            ParagraphFrame.BackgroundColor3 = Colors.GlassDark
            ParagraphFrame.BackgroundTransparency = 0.5
            ParagraphFrame.BorderSizePixel = 0
            ParagraphFrame.Parent = Page
            local ParagraphCorner = Instance.new("UICorner")
            ParagraphCorner.CornerRadius = UDim.new(0, 6)
            ParagraphCorner.Parent = ParagraphFrame
            local ParagraphStroke = Instance.new("UIStroke")
            ParagraphStroke.Color = Colors.Border
            ParagraphStroke.Thickness = 1
            ParagraphStroke.Transparency = 0.7
            ParagraphStroke.Parent = ParagraphFrame
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(1, -24, 0, 16)
            TitleLabel.Position = UDim2.new(0, 12, 0, 8)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.Text = title
            TitleLabel.TextColor3 = config.Color
            TitleLabel.TextSize = 13
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = ParagraphFrame
            local ContentLabel = Instance.new("TextLabel")
            ContentLabel.Size = UDim2.new(1, -24, 0, 16)
            ContentLabel.Position = UDim2.new(0, 12, 0, 26)
            ContentLabel.BackgroundTransparency = 1
            ContentLabel.Font = Enum.Font.Gotham
            ContentLabel.Text = content
            ContentLabel.TextColor3 = Colors.TextSecondary
            ContentLabel.TextSize = 12
            ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
            ContentLabel.TextWrapped = true
            ContentLabel.RichText = true
            ContentLabel.Parent = ParagraphFrame
            local function UpdateSize()
                ContentLabel.TextWrapped = false
                local textBounds = ContentLabel.TextBounds
                local lines = math.ceil(textBounds.X / (ParagraphFrame.AbsoluteSize.X - 24))
                lines = math.max(lines, 1)
                ContentLabel.Size = UDim2.new(1, -24, 0, 12 * lines)
                ContentLabel.TextWrapped = true
                local totalHeight = 8 + 16 + 4 + (12 * lines) + 10
                ParagraphFrame.Size = UDim2.new(1, -4, 0, totalHeight)
            end
            ParagraphFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)
            spawn(function() wait() UpdateSize() end)
            local ParagraphAPI = {}
            function ParagraphAPI:SetTitle(newTitle)
                TitleLabel.Text = newTitle
            end
            function ParagraphAPI:SetContent(newContent)
                ContentLabel.Text = newContent
                UpdateSize()
            end
            return ParagraphAPI
        end
        
        local DropdownPanel = Instance.new("Frame")
        DropdownPanel.Name = "DropdownPanel"
        DropdownPanel.AnchorPoint = Vector2.new(0, 0)
        DropdownPanel.Position = UDim2.new(1, 0, 0, 50)
        DropdownPanel.Size = UDim2.new(0, 160, 1, -58)
        DropdownPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        DropdownPanel.BackgroundTransparency = 0
        DropdownPanel.BorderSizePixel = 0
        DropdownPanel.ClipsDescendants = true
        DropdownPanel.Visible = false
        DropdownPanel.ZIndex = 20
        DropdownPanel.Parent = MainFrame
        
        local PanelCorner = Instance.new("UICorner")
        PanelCorner.CornerRadius = UDim.new(0, 6)
        PanelCorner.Parent = DropdownPanel
        
        local PanelStroke = Instance.new("UIStroke")
        PanelStroke.Color = config.Color
        PanelStroke.Thickness = 1.5
        PanelStroke.Transparency = 0.3
        PanelStroke.Parent = DropdownPanel
        
        local PanelTitle = Instance.new("Frame")
        PanelTitle.Name = "TitleBar"
        PanelTitle.Size = UDim2.new(1, 0, 0, 32)
        PanelTitle.BackgroundColor3 = config.Color
        PanelTitle.BackgroundTransparency = 0.7
        PanelTitle.BorderSizePixel = 0
        PanelTitle.ZIndex = 21
        PanelTitle.Parent = DropdownPanel
        
        local TitleText = Instance.new("TextLabel")
        TitleText.Name = "TitleText"
        TitleText.Size = UDim2.new(1, -30, 1, 0)
        TitleText.Position = UDim2.new(0, 10, 0, 0)
        TitleText.BackgroundTransparency = 1
        TitleText.Font = Enum.Font.GothamBold
        TitleText.Text = "Select"
        TitleText.TextColor3 = Colors.TextPrimary
        TitleText.TextSize = 12
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.ZIndex = 22
        TitleText.Parent = PanelTitle
        
        local CloseDropBtn = Instance.new("TextButton")
        CloseDropBtn.Name = "CloseBtn"
        CloseDropBtn.Size = UDim2.new(0, 20, 0, 20)
        CloseDropBtn.Position = UDim2.new(1, -26, 0.5, -10)
        CloseDropBtn.BackgroundTransparency = 1
        CloseDropBtn.Font = Enum.Font.GothamBold
        CloseDropBtn.Text = "×"
        CloseDropBtn.TextColor3 = Colors.TextSecondary
        CloseDropBtn.TextSize = 18
        CloseDropBtn.ZIndex = 22
        CloseDropBtn.Parent = PanelTitle
        
        local PanelSearchBar = Instance.new("Frame")
        PanelSearchBar.Name = "SearchBar"
        PanelSearchBar.Size = UDim2.new(1, -16, 0, 26)
        PanelSearchBar.Position = UDim2.new(0, 8, 0, 38)
        PanelSearchBar.BackgroundColor3 = Colors.GlassLight
        PanelSearchBar.BackgroundTransparency = 0.7
        PanelSearchBar.Visible = false
        PanelSearchBar.ZIndex = 21
        PanelSearchBar.Parent = DropdownPanel
        
        local SearchBarCorner = Instance.new("UICorner")
        SearchBarCorner.CornerRadius = UDim.new(0, 4)
        SearchBarCorner.Parent = PanelSearchBar
        
        local PanelSearchInput = Instance.new("TextBox")
        PanelSearchInput.Size = UDim2.new(1, -10, 1, 0)
        PanelSearchInput.Position = UDim2.new(0, 5, 0, 0)
        PanelSearchInput.BackgroundTransparency = 1
        PanelSearchInput.Font = Enum.Font.Gotham
        PanelSearchInput.PlaceholderText = "Search..."
        PanelSearchInput.Text = ""
        PanelSearchInput.TextColor3 = Colors.TextPrimary
        PanelSearchInput.PlaceholderColor3 = Colors.TextMuted
        PanelSearchInput.TextSize = 11
        PanelSearchInput.ZIndex = 22
        PanelSearchInput.Parent = PanelSearchBar
        
        local PanelItems = Instance.new("ScrollingFrame")
        PanelItems.Name = "Items"
        PanelItems.Size = UDim2.new(1, -10, 1, -40)
        PanelItems.Position = UDim2.new(0, 5, 0, 36)
        PanelItems.BackgroundTransparency = 1
        PanelItems.BorderSizePixel = 0
        PanelItems.ScrollBarThickness = 2
        PanelItems.ScrollBarImageColor3 = config.Color
        PanelItems.CanvasSize = UDim2.new(0, 0, 0, 0)
        PanelItems.ZIndex = 21
        PanelItems.Parent = DropdownPanel
        
        local ItemsLayout = Instance.new("UIListLayout")
        ItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ItemsLayout.Padding = UDim.new(0, 2)
        ItemsLayout.Parent = PanelItems
        
        local ItemsPadding = Instance.new("UIPadding")
        ItemsPadding.PaddingTop = UDim.new(0, 2)
        ItemsPadding.Parent = PanelItems
        
        local currentDropdownCallback = nil
        local currentDropdownSelected = nil
        local currentDropdownMulti = false
        local currentDropdownLabel = nil
        local currentDropdownText = ""
        local currentDropdownOptions = {}
        local dropdownOpen = false
        
        local function CloseDropdownPanel()
            if not dropdownOpen then return end
            dropdownOpen = false
            TweenService:Create(DropdownPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
                Position = UDim2.new(1, 0, 0, 50)
            }):Play()
            task.delay(0.2, function()
                DropdownPanel.Visible = false
            end)
        end
        
        CloseDropBtn.MouseButton1Click:Connect(CloseDropdownPanel)
        
        local function RefreshDropdownItems(searchText)
            for _, child in pairs(PanelItems:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            local count = 0
            for _, option in ipairs(currentDropdownOptions) do
                if not searchText or searchText == "" or string.find(string.lower(option), string.lower(searchText)) then
                    local Item = Instance.new("TextButton")
                    Item.Size = UDim2.new(1, -4, 0, 26)
                    Item.BackgroundColor3 = Colors.GlassLight
                    Item.BackgroundTransparency = 0.9
                    Item.Text = ""
                    Item.AutoButtonColor = false
                    Item.ZIndex = 22
                    Item.Parent = PanelItems
                    
                    local ItemCorner = Instance.new("UICorner")
                    ItemCorner.CornerRadius = UDim.new(0, 4)
                    ItemCorner.Parent = Item
                    
                    local ItemText = Instance.new("TextLabel")
                    ItemText.Size = UDim2.new(1, -36, 1, 0)
                    ItemText.Position = UDim2.new(0, 10, 0, 0)
                    ItemText.BackgroundTransparency = 1
                    ItemText.Font = Enum.Font.GothamMedium
                    ItemText.Text = option
                    ItemText.TextColor3 = Colors.TextSecondary
                    ItemText.TextSize = 11
                    ItemText.TextXAlignment = Enum.TextXAlignment.Left
                    ItemText.ZIndex = 23
                    ItemText.Parent = Item
                    
                    local Checkmark = Instance.new("ImageLabel")
                    Checkmark.Size = UDim2.new(0, 14, 0, 14)
                    Checkmark.Position = UDim2.new(1, -20, 0.5, -7)
                    Checkmark.BackgroundTransparency = 1
                    Checkmark.Image = "rbxassetid://6031094678"
                    Checkmark.ImageColor3 = config.Color
                    Checkmark.ImageTransparency = 1
                    Checkmark.ZIndex = 23
                    Checkmark.Parent = Item
                    
                    local isSelected = false
                    if currentDropdownMulti then
                        if type(currentDropdownSelected) == "table" then
                            for _, s in pairs(currentDropdownSelected) do 
                                if s == option then isSelected = true break end 
                            end
                        end
                    else
                        isSelected = (currentDropdownSelected == option)
                    end
                    
                    if isSelected then
                        ItemText.TextColor3 = config.Color
                        Item.BackgroundTransparency = 0.7
                        Checkmark.ImageTransparency = 0
                    end
                    
                    Item.MouseEnter:Connect(function()
                        TweenService:Create(Item, TweenInfo.new(0.15), {BackgroundTransparency = 0.6}):Play()
                    end)
                    Item.MouseLeave:Connect(function()
                        local transp = isSelected and 0.7 or 0.9
                        TweenService:Create(Item, TweenInfo.new(0.15), {BackgroundTransparency = transp}):Play()
                    end)
                    
                    Item.MouseButton1Click:Connect(function()
                        if currentDropdownMulti then
                            local found = false
                            local index = 0
                            for i, s in pairs(currentDropdownSelected) do
                                if s == option then found = true index = i break end
                            end
                            if found then
                                table.remove(currentDropdownSelected, index)
                            else
                                table.insert(currentDropdownSelected, option)
                            end
                            if currentDropdownLabel then
                                currentDropdownLabel.Text = currentDropdownText .. ": [" .. #currentDropdownSelected .. "]"
                            end
                        else
                            currentDropdownSelected = option
                            if currentDropdownLabel then
                                currentDropdownLabel.Text = currentDropdownText .. ": " .. tostring(option)
                            end
                        end
                        
                        pcall(currentDropdownCallback, currentDropdownSelected)
                        RefreshDropdownItems(PanelSearchInput.Text)
                        
                        if not currentDropdownMulti then
                            CloseDropdownPanel()
                        end
                    end)
                    
                    count = count + 1
                end
            end
            
            PanelItems.CanvasSize = UDim2.new(0, 0, 0, (count * 31) + 8)
        end
        
        PanelSearchInput:GetPropertyChangedSignal("Text"):Connect(function()
            RefreshDropdownItems(PanelSearchInput.Text)
        end)
        
        local function CreateDropdown(text, options, default, callback, search, multi)
            options = options or {}
            default = default or (multi and {} or options[1])
            callback = callback or function() end
            local selected = default
            
            local DropdownFrame = Instance.new("TextButton")
            DropdownFrame.Name = "Dropdown"
            DropdownFrame.Size = UDim2.new(1, -4, 0, 38)
            DropdownFrame.BackgroundColor3 = Colors.GlassDark
            DropdownFrame.BackgroundTransparency = 0.5
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Text = ""
            DropdownFrame.AutoButtonColor = false
            DropdownFrame.Parent = Page
            
            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 6)
            DropCorner.Parent = DropdownFrame
            
            local DropStroke = Instance.new("UIStroke")
            DropStroke.Color = Colors.Border
            DropStroke.Thickness = 1
            DropStroke.Transparency = 0.7
            DropStroke.Parent = DropdownFrame
            
            local DropLabel = Instance.new("TextLabel")
            DropLabel.Size = UDim2.new(1, -40, 1, 0)
            DropLabel.Position = UDim2.new(0, 12, 0, 0)
            DropLabel.BackgroundTransparency = 1
            DropLabel.Font = Enum.Font.GothamMedium
            DropLabel.TextColor3 = Colors.TextSecondary
            DropLabel.TextSize = 13
            DropLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropLabel.Parent = DropdownFrame
            
            if multi then
                DropLabel.Text = text .. ": [" .. #selected .. "]"
            else
                DropLabel.Text = text .. ": " .. tostring(selected or "None")
            end
            
            local Arrow = Instance.new("ImageLabel")
            Arrow.Size = UDim2.new(0, 16, 0, 16)
            Arrow.Position = UDim2.new(1, -28, 0.5, -8)
            Arrow.BackgroundTransparency = 1
            Arrow.Image = "rbxassetid://6034818372"
            Arrow.ImageColor3 = Colors.TextSecondary
            Arrow.Parent = DropdownFrame
            
            DropdownFrame.MouseEnter:Connect(function()
                TweenService:Create(DropdownFrame, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
                TweenService:Create(DropStroke, TweenInfo.new(0.15), {Color = config.Color, Transparency = 0.4}):Play()
            end)
            DropdownFrame.MouseLeave:Connect(function()
                TweenService:Create(DropdownFrame, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
                TweenService:Create(DropStroke, TweenInfo.new(0.15), {Color = Colors.Border, Transparency = 0.7}):Play()
            end)
            
            DropdownFrame.MouseButton1Click:Connect(function()
                currentDropdownCallback = callback
                currentDropdownSelected = selected
                currentDropdownMulti = multi
                currentDropdownLabel = DropLabel
                currentDropdownText = text
                currentDropdownOptions = options
                
                TitleText.Text = text
                PanelSearchBar.Visible = search
                if search then
                    PanelItems.Size = UDim2.new(1, -10, 1, -70)
                    PanelItems.Position = UDim2.new(0, 5, 0, 68)
                else
                    PanelItems.Size = UDim2.new(1, -10, 1, -40)
                    PanelItems.Position = UDim2.new(0, 5, 0, 36)
                end
                PanelSearchInput.Text = ""
                
                RefreshDropdownItems("")
                
                dropdownOpen = true
                DropdownPanel.Visible = true
                DropdownPanel.Position = UDim2.new(1, 0, 0, 50)
                TweenService:Create(DropdownPanel, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Position = UDim2.new(1, -168, 0, 50)
                }):Play()
            end)
            
            local DropdownAPI = {}
            function DropdownAPI:Set(newValue)
                selected = newValue
                currentDropdownSelected = newValue
                if multi then
                    DropLabel.Text = text .. ": [" .. #selected .. "]"
                else
                    DropLabel.Text = text .. ": " .. tostring(selected)
                end
            end
            function DropdownAPI:SetOptions(newOptions)
                options = newOptions
                currentDropdownOptions = newOptions
            end
            return DropdownAPI
        end
        function Tab:Dropdown(text, options, default, callback)
            return CreateDropdown(text, options, default, callback, false, false)
        end
        function Tab:DropdownSearch(text, options, default, callback)
             return CreateDropdown(text, options, default, callback, true, false)
        end
        function Tab:MultiDropdown(text, options, default, callback)
             return CreateDropdown(text, options, default, callback, false, true)
        end
        function Tab:MultiDropdownSearch(text, options, default, callback)
             return CreateDropdown(text, options, default, callback, true, true)
        end
        return Tab
    end
    TabContainer.ChildAdded:Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabPadding.AbsoluteContentSize.Y + 20)
    end)
    function Window:IsMinimized()
        return isMinimized
    end
    return Window
end
