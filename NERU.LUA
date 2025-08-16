local NeruLib = {}
NeruLib.__index = NeruLib

-- Theme based on character's colors
local theme = {
    background = Color3.fromRGB(30, 30, 30),
    primaryAccent = Color3.fromRGB(255, 204, 51),
    secondaryAccent = Color3.fromRGB(100, 100, 100),
    text = Color3.fromRGB(245, 235, 210),
    buttonBG = Color3.fromRGB(50, 50, 50),
    buttonHighlight = Color3.fromRGB(255, 204, 51),
    textboxBG = Color3.fromRGB(60, 60, 60),
}

local CORNER_RADIUS = 10

local UserInputService = game:GetService("UserInputService")

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

-- Draggable function without clamps for free movement
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
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function NeruLib:CreateWindow(titleText)
    local self = setmetatable({}, NeruLib)

    self.ScreenGui = createInstance("ScreenGui", {Name = "NeruLib"})
    self.ScreenGui.Parent = game:GetService("CoreGui")

    self.MainFrame = createInstance("Frame", {
        Size = UDim2.new(0, 500, 0, 320),
        Position = UDim2.new(0.5, -250, 0.5, -160),
        BackgroundColor3 = theme.background,
        BorderSizePixel = 0,
        Parent = self.ScreenGui,
        CornerRadius = CORNER_RADIUS,
    })

    -- Sidebar
    self.Sidebar = createInstance("Frame", {
        Size = UDim2.new(0, 110, 1, 0),
        BackgroundColor3 = theme.secondaryAccent,
        BorderSizePixel = 0,
        Parent = self.MainFrame,
        CornerRadius = CORNER_RADIUS,
    })

    -- Header: drag zone and controls
    self.Header = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        Parent = self.MainFrame,
    })

    self.TitleLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, -90, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = theme.primaryAccent,
        Font = Enum.Font.SourceSansBold,
        TextSize = 22,
        Text = titleText,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = self.Header,
    })

    self.CloseButton = createInstance("TextButton", {
        Size = UDim2.new(0, 35, 0, 25),
        Position = UDim2.new(1, -40, 0, 5),
        BackgroundColor3 = theme.buttonBG,
        Text = "X",
        TextColor3 = theme.primaryAccent,
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        AutoButtonColor = false,
        Parent = self.Header,
        CornerRadius = CORNER_RADIUS,
    })

    self.MinimizeButton = createInstance("TextButton", {
        Size = UDim2.new(0, 35, 0, 25),
        Position = UDim2.new(1, -80, 0, 5),
        BackgroundColor3 = theme.buttonBG,
        Text = "_",
        TextColor3 = theme.primaryAccent,
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        AutoButtonColor = false,
        Parent = self.Header,
        CornerRadius = CORNER_RADIUS,
    })

    makeDraggable(self.MainFrame, self.Header)

    self.CloseButton.MouseEnter:Connect(function()
        self.CloseButton.BackgroundColor3 = theme.primaryAccent
        self.CloseButton.TextColor3 = theme.background
    end)
    self.CloseButton.MouseLeave:Connect(function()
        self.CloseButton.BackgroundColor3 = theme.buttonBG
        self.CloseButton.TextColor3 = theme.primaryAccent
    end)
    self.CloseButton.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)

    local minimized = false
    self.MinimizeButton.MouseEnter:Connect(function()
        self.MinimizeButton.BackgroundColor3 = theme.primaryAccent
        self.MinimizeButton.TextColor3 = theme.background
    end)
    self.MinimizeButton.MouseLeave:Connect(function()
        self.MinimizeButton.BackgroundColor3 = theme.buttonBG
        self.MinimizeButton.TextColor3 = theme.primaryAccent
    end)
    self.MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        self.TabContentHolder.Visible = not minimized
        self.Sidebar.Visible = not minimized
        if minimized then
            self.MainFrame.Size = UDim2.new(0, 200, 0, 50)
        else
            self.MainFrame.Size = UDim2.new(0, 500, 0, 320)
        end
    end)

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

    self.TabContentHolder = createInstance("Frame", {
        Size = UDim2.new(1, -110, 1, -35), -- fixed height to align with sidebar
        Position = UDim2.new(0, 110, 0, 35),
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

function NeruLib:CreateTab(name)
    local btn = createInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = theme.secondaryAccent,
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

function NeruLib:SelectTab(name)
    for tabName, tabData in pairs(self.Tabs) do
        local selected = tabName == name
        tabData.Frame.Visible = selected
        tabData.Button.BackgroundColor3 = selected and theme.primaryAccent or theme.secondaryAccent
        tabData.Button.TextColor3 = selected and theme.background or theme.text
    end
    self.CurrentTab = name
end

function NeruLib:AddButton(parent, text, callback)
    local btn = createInstance("TextButton", {
        Size = UDim2.new(0, 180, 0, 32),
        BackgroundColor3 = theme.primaryAccent,
        TextColor3 = theme.background,
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

function NeruLib:AddLabel(parent, text)
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

function NeruLib:AddTextbox(parent, placeholder)
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

function NeruLib:AddToggle(parent, text, default, callback)
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
        BackgroundColor3 = default and theme.primaryAccent or Color3.fromRGB(70,70,70),
        Text = default and "ON" or "OFF",
        TextColor3 = theme.background,
        Font = Enum.Font.SourceSansBold,
        TextSize = 18,
        Parent = container,
        AutoButtonColor = false,
        CornerRadius = CORNER_RADIUS,
    })

    local state = default or false

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and theme.primaryAccent or Color3.fromRGB(70,70,70)
        toggleBtn.Text = state and "ON" or "OFF"
        if callback then
            callback(state)
        end
    end)

    return container, function(newState)
        if newState ~= nil then
            state = newState
            toggleBtn.BackgroundColor3 = state and theme.primaryAccent or Color3.fromRGB(70,70,70)
            toggleBtn.Text = state and "ON" or "OFF"
        end
        return state
    end
end

function NeruLib:ToggleUI()
    if self.ScreenGui then
        self.ScreenGui.Enabled = not self.ScreenGui.Enabled
    end
end

return NeruLib
