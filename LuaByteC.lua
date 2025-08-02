-- ExecutorUILib (Fixed Tabs, Functional Core Features, Consistent Theme)

local UILib = {}
UILib.__index = UILib

local theme = {
    background = Color3.fromRGB(20, 10, 30),
    accent = Color3.fromRGB(120, 50, 170),
    tab = Color3.fromRGB(50, 30, 80),
    text = Color3.fromRGB(240, 220, 255),
    textboxBG = Color3.fromRGB(30, 20, 50),
}

local CORNER_RADIUS = 10

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

local function makeDraggable(frame, dragZone)
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

    -- Layout for tab buttons
    self.TabButtonsHolder = createInstance("Frame", {
        Size = UDim2.new(1, -8, 1, -35),
        Position = UDim2.new(0, 4, 0, 35),
        BackgroundTransparency = 1,
        Parent = self.Sidebar,
    })
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.Parent = self.TabButtonsHolder
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 6)

    -- Content Holder for tab content frames
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
        Size = UDim2.new(1, 0, 0, 30),
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
        self:SelectTab(name)
    end

    return frame
end

function UILib:SelectTab(name)
    for tabName, tabData in pairs(self.Tabs) do
        local selected = tabName == name
        tabData.Frame.Visible = selected
        tabData.Button.BackgroundColor3 = selected and theme.accent or theme.tab
    end
    self.CurrentTab = name
end

function UILib:AddButton(parent, text, callback)
    local btn = createInstance("TextButton", {
        Size = UDim2.new(0, 180, 0, 32),
        BackgroundColor3 = theme.accent,
        TextColor3 = theme.text,
        Font = Enum.Font.SourceSansBold,
        TextSize = 18,
        Text = text,
        Parent = parent,
        AutoButtonColor = true,
        CornerRadius = CORNER_RADIUS,
    })

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

function UILib:AddLabel(parent, text)
    local lbl = createInstance("TextLabel", {
        Size = UDim2.new(0, 180, 0, 30),
        BackgroundTransparency = 1,
        TextColor3 = theme.text,
        Font = Enum.Font.SourceSans,
        TextSize = 18,
        Text = text,
        Parent = parent,
        TextWrapped = true,
    })
    return lbl
end

function UILib:AddTextbox(parent, placeholder)
    local tb = createInstance("TextBox", {
        Size = UDim2.new(0, 180, 0, 32),
        BackgroundColor3 = theme.textboxBG,
        TextColor3 = theme.text,
        Font = Enum.Font.SourceSans,
        TextSize = 18,
        PlaceholderText = placeholder or "",
        Parent = parent,
        ClearTextOnFocus = false,
        CornerRadius = CORNER_RADIUS,
    })
    return tb
end

function UILib:AddSideScroll(parent, options)
    local container = createInstance("Frame", {
        Size = UDim2.new(0, 200, 0, 36),
        BackgroundColor3 = theme.tab,
        Parent = parent,
        CornerRadius = CORNER_RADIUS,
    })

    local btnLeft = createInstance("TextButton", {
        Size = UDim2.new(0, 36, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Text = "<",
        BackgroundColor3 = theme.accent,
        TextColor3 = theme.text,
        Font = Enum.Font.SourceSansBold,
        TextSize = 24,
        Parent = container,
        CornerRadius = CORNER_RADIUS,
    })

    local btnRight = createInstance("TextButton", {
        Size = UDim2.new(0, 36, 1, 0),
        Position = UDim2.new(1, -36, 0, 0),
        Text = ">",
        BackgroundColor3 = theme.accent,
        TextColor3 = theme.text,
        Font = Enum.Font.SourceSansBold,
        TextSize = 24,
        Parent = container,
        CornerRadius = CORNER_RADIUS,
    })

    local label = createInstance("TextLabel", {
        Size = UDim2.new(1, -72, 1, 0),
        Position = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = theme.text,
        Font = Enum.Font.SourceSans,
        TextSize = 18,
        Text = options[1] or "",
        Parent = container,
    })

    local index = 1

    btnLeft.MouseButton1Click:Connect(function()
        index = index > 1 and (index - 1) or #options
        label.Text = options[index]
    end)

    btnRight.MouseButton1Click:Connect(function()
        index = index < #options and (index + 1) or 1
        label.Text = options[index]
    end)

    return container, function()
        return options[index]
    end
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
    notifType = notifType or "info"
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
