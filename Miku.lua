local NeruLib = {}
NeruLib.__index = NeruLib

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
        Size = UDim2.new(0, 510, 0, 350),
        Position = UDim2.new(0.5, -255, 0.5, -175),
        BackgroundColor3 = theme.background,
        BorderSizePixel = 0,
        Parent = self.ScreenGui,
        CornerRadius = CORNER_RADIUS,
    })

    self.Sidebar = createInstance("Frame", {
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundColor3 = theme.secondaryAccent,
        BorderSizePixel = 0,
        Parent = self.MainFrame,
        CornerRadius = CORNER_RADIUS,
    })

    -- Sidebar title label
    self.TitleLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        TextColor3 = theme.primaryAccent,
        Font = Enum.Font.SourceSansBold,
        TextSize = 22,
        Text = titleText,
        Parent = self.Sidebar,
    })

    makeDraggable(self.MainFrame, self.TitleLabel)

    -- Scrollable Sidebar buttons holder
    self.TabButtonsHolder = createInstance("ScrollingFrame", {
        Size = UDim2.new(1, -8, 1, -35),
        Position = UDim2.new(0, 4, 0, 35),
        BackgroundTransparency = 1,
        ScrollBarThickness = 8,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        VerticalScrollBarInset = Enum.ScrollBarInset.Always,
        Parent = self.Sidebar,
    })
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.Parent = self.TabButtonsHolder
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 6)

    -- Scrollable Tab content holder
    self.TabContentHolder = createInstance("ScrollingFrame", {
        Size = UDim2.new(1, -120, 1, -35),
        Position = UDim2.new(0, 120, 0, 35),
        BackgroundTransparency = 1,
        ScrollBarThickness = 8,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        VerticalScrollBarInset = Enum.ScrollBarInset.Always,
        Parent = self.MainFrame,
        CornerRadius = CORNER_RADIUS,
    })

    self.Tabs = {}
    self.CurrentTab = nil

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

    -- Each tab content container inside scroll frame, auto height
    local frame = createInstance("Frame", {
        Size = UDim2.new(1, -12, 0, 0),
        BackgroundColor3 = theme.background,
        BorderSizePixel = 0,
        Visible = false,
        Parent = self.TabContentHolder,
        AutomaticSize = Enum.AutomaticSize.Y,
        CornerRadius = CORNER_RADIUS,
    })

    -- Vertical list layout for contents inside tab
    local layout = Instance.new("UIListLayout")
    layout.Parent = frame
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

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
        BackgroundColor3 = default and theme.primaryAccent or Color3.fromRGB(70, 70, 70),
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
        toggleBtn.BackgroundColor3 = state and theme.primaryAccent or Color3.fromRGB(70, 70, 70)
        toggleBtn.Text = state and "ON" or "OFF"
        if callback then
            callback(state)
        end
    end)

    return container, function(newState)
        if newState ~= nil then
            state = newState
            toggleBtn.BackgroundColor3 = state and theme.primaryAccent or Color3.fromRGB(70, 70, 70)
            toggleBtn.Text = state and "ON" or "OFF"
        end
        return state
    end
end

function NeruLib:CreateContainer(parent, layoutType, gridOptions)
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = parent

    if layoutType == "Grid" then
        local gridLayout = Instance.new("UIGridLayout")
        gridLayout.FillDirection = Enum.FillDirection.Horizontal
        gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
        gridLayout.CellPadding = gridOptions and gridOptions.CellPadding or UDim2.new(0, 8, 0, 8)
        gridLayout.CellSize = gridOptions and gridOptions.CellSize or UDim2.new(0, 100, 0, 100)
        gridLayout.Parent = container
    else
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = gridOptions and gridOptions.Padding or UDim.new(0, 6)
        listLayout.Parent = container
    end

    return container
end

function NeruLib:ToggleUI()
    if self.ScreenGui then
        self.ScreenGui.Enabled = not self.ScreenGui.Enabled
    end
end

return NeruLib
  
