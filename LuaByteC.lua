-- ExecutorUILib with toggles, notifications, improved tabs, and consistent theme

local UILib = {}
UILib.__index = UILib

local theme = {
    background = Color3.fromRGB(20, 10, 30),
    accent = Color3.fromRGB(120, 50, 170),
    tab = Color3.fromRGB(50, 30, 80),
    text = Color3.fromRGB(240, 220, 255),
    textboxBG = Color3.fromRGB(30, 20, 50),
}

local CORNER_RADIUS = 10 -- less curved squirclcle

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local function addCorner(inst, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = inst
end

local function createInstance(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "CornerRadius" then
            inst[k] = v
        end
    end
    if props.CornerRadius then
        addCorner(inst, props.CornerRadius)
    end
    return inst
end

local function makeDraggable(frame, dragZone) -- window draggable by any click on dragZone (TitleLabel)
    local dragging, dragStart, startPos

    dragZone.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragZone.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local viewportSize = workspace.CurrentCamera.ViewportSize
            local newPos = UDim2.new(
                startPos.X.Scale,
                math.clamp(startPos.X.Offset + delta.X, 0, viewportSize.X - frame.AbsoluteSize.X),
                startPos.Y.Scale,
                math.clamp(startPos.Y.Offset + delta.Y, 0, viewportSize.Y - frame.AbsoluteSize.Y)
            )
            frame.Position = newPos
        end
    end)
end

function UILib:CreateWindow(titleText)
    local self = setmetatable({}, UILib)

    self.ScreenGui = createInstance("ScreenGui", {Name = "ExecutorUILib"})
    self.ScreenGui.Parent = game:GetService("CoreGui")

    self.MainFrame = createInstance("Frame", {
        Size = UDim2.new(0, 500, 0, 320),
        Position = UDim2.new(0.5, -250, 0.5, -160),
        BackgroundColor3 = theme.background,
        BorderSizePixel = 0,
        Parent = self.ScreenGui,
        CornerRadius = CORNER_RADIUS,
    })

    self.Sidebar = createInstance("Frame", {
        Size = UDim2.new(0, 110, 1, 0),
        BackgroundColor3 = theme.tab,
        BorderSizePixel = 0,
        Parent = self.MainFrame,
        CornerRadius = CORNER_RADIUS,
    })

    self.TitleLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        TextColor3 = theme.accent,
        Font = Enum.Font.SourceSansBold,
        TextSize = 22,
        Text = titleText,
        Parent = self.Sidebar,
    })

    makeDraggable(self.MainFrame, self.TitleLabel)

    self.TabButtonsHolder = createInstance("Frame", {
        Size = UDim2.new(1, -8, 1, -35),
        Position = UDim2.new(0, 4, 0, 35),
        BackgroundTransparency = 1,
        Parent = self.Sidebar,
    })

    self.TabContentHolder = createInstance("Frame", {
        Size = UDim2.new(1, -110, 1, 0),
        Position = UDim2.new(0, 110, 0, 0),
        BackgroundTransparency = 1,
        Parent = self.MainFrame,
        CornerRadius = CORNER_RADIUS,
    })

    self.Tabs = {}
    self.CurrentTab = nil

    self.Notifications = {}
    self.NotificationGui = nil

    return self
end

function UILib:CreateTab(name)
    local btn = createInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = theme.tab,
        TextColor3 = theme.text,
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
        Text = name,
        Parent = self.TabButtonsHolder,
        CornerRadius = CORNER_RADIUS,
        AutoButtonColor = false,
    })

    local frame = createInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.background,
        BorderSizePixel = 0,
        Visible = false,
        Parent = self.TabContentHolder,
        CornerRadius = CORNER_RADIUS,
    })

    self.Tabs[name] = {Button = btn, Frame = frame}

    btn.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)

    if not self.CurrentTab then
        self.CurrentTab = name
        frame.Visible = true
        btn.BackgroundColor3 = theme.accent
    end

    return frame
end

function UILib:SelectTab(name)
    if self.CurrentTab == name then
        return
    end

    for tabName, tabData in pairs(self.Tabs) do
        local selected = tabName == name
        tabData.Frame.Visible = selected
        tabData.Button.BackgroundColor3 = selected and theme.accent or theme.tab
    end
    self.CurrentTab = name
end

function UILib:AddToggle(parent, text, default, callback)
    local container = createInstance("Frame", {
        Size = UDim2.new(0, 200, 0, 36),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local textLabel = createInstance("TextLabel", {
        Text = text,
        Size = UDim2.new(0.7, 0, 1, 0),
        TextColor3 = theme.text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSans,
        TextSize = 18,
        Parent = container,
    })

    local toggleBtn = createInstance("TextButton", {
        Size = UDim2.new(0, 50, 0, 30),
        Position = UDim2.new(0.72, 0, 0.1, 0),
        BackgroundColor3 = default and theme.accent or Color3.fromRGB(70, 70, 70),
        Text = default and "ON" or "OFF",
        TextColor3 = theme.text,
        Font = Enum.Font.SourceSansBold,
        TextSize = 18,
        Parent = container,
        AutoButtonColor = false,
        CornerRadius = CORNER_RADIUS,
    })

    local state = default or false

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and theme.accent or Color3.fromRGB(70, 70, 70)
        toggleBtn.Text = state and "ON" or "OFF"
        if callback then
            callback(state)
        end
    end)

    return container, function(newState)
        if newState ~= nil then
            state = newState
            toggleBtn.BackgroundColor3 = state and theme.accent or Color3.fromRGB(70, 70, 70)
            toggleBtn.Text = state and "ON" or "OFF"
        end
        return state
    end
end

function UILib:Notify(title, message, duration, notifType)
    duration = duration or 3
    notifType = notifType or "info" -- "info","warning","error","success"

    if not self.NotificationGui then
        self.NotificationGui = createInstance("ScreenGui", {Name = "ExecutorNotifications"})
        self.NotificationGui.Parent = game:GetService("CoreGui")
    end

    local notifFrame = createInstance("Frame", {
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(0.5, -150, 1, -90 - (#self.Notifications * 90)),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Parent = self.NotificationGui,
        CornerRadius = CORNER_RADIUS,
    })

    local titleLabel = createInstance("TextLabel", {
        Text = title,
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 10, 0, 8),
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        TextColor3 = theme.text,
        BackgroundTransparency = 1,
        Parent = notifFrame,
    })

    local msgLabel = createInstance("TextLabel", {
        Text = message,
        Size = UDim2.new(1, -20, 0, 44),
        Position = UDim2.new(0, 10, 0, 32),
        Font = Enum.Font.SourceSans,
        TextSize = 16,
        TextColor3 = theme.text,
        BackgroundTransparency = 1,
        TextWrapped = true,
        Parent = notifFrame,
    })

    table.insert(self.Notifications, notifFrame)

    notifFrame.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    msgLabel.TextTransparency = 1

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(notifFrame, tweenInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(titleLabel, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(msgLabel, tweenInfo, {TextTransparency = 0}):Play()

    delay(duration, function()
        local fadeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(notifFrame, fadeTweenInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(titleLabel, fadeTweenInfo, {TextTransparency = 1}):Play()
        TweenService:Create(msgLabel, fadeTweenInfo, {TextTransparency = 1}):Play()
        wait(0.5)
        notifFrame:Destroy()
        for i, notif in ipairs(self.Notifications) do
            if notif == notifFrame then
                table.remove(self.Notifications, i)
                break
            end
        end
        for i, notif in ipairs(self.Notifications) do
            notif.Position = UDim2.new(0.5, -150, 1, -90 - ((i - 1) * 90))
        end
    end)
end

function UILib:recenterUI()
    self.MainFrame.Position = UDim2.new(0.5, -self.MainFrame.Size.X.Offset / 2, 0.5, -self.MainFrame.Size.Y.Offset / 2)
end

function UILib:SetTitle(text)
    if self.TitleLabel then
        self.TitleLabel.Text = text
    end
end

function UILib:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end
    if self.NotificationGui then
        self.NotificationGui:Destroy()
        self.NotificationGui = nil
    end
end

return UILib
