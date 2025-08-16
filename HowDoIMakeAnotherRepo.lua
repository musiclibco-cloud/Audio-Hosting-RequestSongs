local UILib = {}

local UserInputService = game:GetService("UserInputService")

-- Helper to make Frame draggable on any device
function UILib.MakeDraggable(frame)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    frame.InputBegan:Connect(function(input)
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

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Create a draggable window with close button
function UILib.CreateWindow(title)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UILibScreenGui"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 400, 0, 350)
    frame.Position = UDim2.new(0.3, 0, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    -- Rounded corners 9px
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 9)
    frameCorner.Parent = frame

    -- Make draggable
    UILib.MakeDraggable(frame)

    -- Title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0, 350, 0, 40)
    titleLabel.Position = UDim2.new(0, 45, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Window"
    titleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 26
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(0, 350, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    closeButton.AutoButtonColor = false
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 200, 200)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 28
    closeButton.Parent = frame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 9)
    closeCorner.Parent = closeButton

    closeButton.MouseEnter:Connect(function()
        closeButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    closeButton.MouseLeave:Connect(function()
        closeButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        closeButton.TextColor3 = Color3.fromRGB(255, 200, 200)
    end)

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    return frame, screenGui
end

-- Create a button
function UILib.CreateButton(parent, buttonName, text, position, size)
    local button = Instance.new("TextButton")
    button.Name = buttonName or "Button"
    button.Text = text or "Button"
    button.Size = size or UDim2.new(0, 140, 0, 40)
    button.Position = position or UDim2.new(0, 10, 0, 90)
    button.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
    button.TextColor3 = Color3.fromRGB(255, 100, 100)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 22
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = button

    button.AutoButtonColor = false
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
        button.TextColor3 = Color3.fromRGB(255, 100, 100)
    end)

    return button
end

-- Create a textbox
function UILib.CreateTextbox(parent, placeholder, position)
    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(0, 320, 0, 40)
    textbox.Position = position or UDim2.new(0, 10, 0, 50)
    textbox.PlaceholderText = placeholder or "Enter text..."
    textbox.BackgroundColor3 = Color3.fromRGB(70, 0, 0)
    textbox.TextColor3 = Color3.fromRGB(255, 150, 150)
    textbox.Font = Enum.Font.SourceSans
    textbox.TextSize = 20
    textbox.ClearTextOnFocus = false
    textbox.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = textbox

    return textbox
end

-- Create a toggle (with optional callback)
function UILib.CreateToggle(parent, toggleName, defaultValue, position, callback)
    local toggle = Instance.new("TextButton")
    toggle.Name = toggleName or "Toggle"
    toggle.Size = UDim2.new(0, 140, 0, 40)
    toggle.Position = position or UDim2.new(0, 10, 0, 130)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(70, 0, 0)
    toggle.Text = defaultValue and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 150, 150)
    toggle.Font = Enum.Font.SourceSansBold
    toggle.TextSize = 22
    toggle.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = toggle

    local state = defaultValue or false

    local function update()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        toggle.BackgroundColor3 = state and Color3.fromRGB(220, 0, 0) or Color3.fromRGB(70, 0, 0)
        if callback then
            callback(state)
        end
    end

    toggle.MouseButton1Click:Connect(update)

    return toggle
end

-- Create a side selector (like SFII char select)
function UILib.CreateSideSelector(parent, name, options, position, callback)
    local frame = Instance.new("Frame")
    frame.Name = name or "SideSelector"
    frame.Size = UDim2.new(0, 240, 0, 50)
    frame.Position = position or UDim2.new(0, 10, 0, 180)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    -- Left button
    local left = Instance.new("TextButton")
    left.Size = UDim2.new(0, 50, 0, 50)
    left.Position = UDim2.new(0, 0, 0, 0)
    left.Text = "<"
    left.Font = Enum.Font.SourceSansBold
    left.TextSize = 30
    left.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
    left.TextColor3 = Color3.new(1,1,1)
    left.Parent = frame

    local leftCorner = Instance.new("UICorner", left)
    leftCorner.CornerRadius = UDim.new(0, 9)

    -- Right button
    local right = Instance.new("TextButton")
    right.Size = UDim2.new(0, 50, 0, 50)
    right.Position = UDim2.new(0, 190, 0, 0)
    right.Text = ">"
    right.Font = Enum.Font.SourceSansBold
    right.TextSize = 30
    right.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
    right.TextColor3 = Color3.new(1,1,1)
    right.Parent = frame

    local rightCorner = Instance.new("UICorner", right)
    rightCorner.CornerRadius = UDim.new(0, 9)

    -- Center label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 140, 0, 50)
    label.Position = UDim2.new(0, 50, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = options and options[1] or "Option"
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 28
    label.TextColor3 = Color3.new(1,1,1)
    label.Parent = frame

    -- State
    local index = 1
    local count = #options

    local function updateLabel()
        label.Text = options[index]
        if callback then callback(options[index], index) end
    end

    left.MouseButton1Click:Connect(function()
        index = (index - 2) % count + 1
        updateLabel()
    end)

    right.MouseButton1Click:Connect(function()
        index = (index % count) + 1
        updateLabel()
    end)

    return frame, function() return options[index], index end
end

-- Create side tabs on the left of the window
function UILib.CreateSideTabs(window, tabNames)
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(0, 110, 1, 0)
    tabsContainer.Position = UDim2.new(0, 0, 0, 0)
    tabsContainer.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    tabsContainer.Parent = window

    local tabFrames = {}
    local buttons = {}
    local selectedTab

    local buttonHeight = window.Size.Y.Offset / #tabNames

    for i, tabName in ipairs(tabNames) do
        -- Create tab button
        local button = Instance.new("TextButton")
        button.Name = tabName .. "TabButton"
        button.Size = UDim2.new(1, 0, 0, buttonHeight)
        button.Position = UDim2.new(0, 0, (i-1) * buttonHeight / window.Size.Y.Offset, 0)
        button.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
        button.Text = tabName
        button.TextColor3 = Color3.fromRGB(255, 150, 150)
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 20
        button.Parent = tabsContainer
        button.TextWrapped = true

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 9)
        corner.Parent = button

        -- Create tab content frame (initially hidden)
        local contentFrame = Instance.new("Frame")
        contentFrame.Name = tabName .. "Content"
        contentFrame.Size = UDim2.new(1, -110, 1, 0)
        contentFrame.Position = UDim2.new(0, 110, 0, 0)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Visible = false
        contentFrame.Parent = window
        tabFrames[tabName] = contentFrame
        buttons[tabName] = button

        -- Button click to switch tabs
        button.MouseButton1Click:Connect(function()
            if selectedTab ~= tabName then
                -- Hide previous
                if selectedTab then
                    tabFrames[selectedTab].Visible = false
                    buttons[selectedTab].BackgroundColor3 = Color3.fromRGB(140, 0, 0)
                end
                -- Show current
                contentFrame.Visible = true
                button.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
                selectedTab = tabName
            end
        end)
    end

    -- Activate first tab by default
    if #tabNames > 0 then
        buttons[tabNames[1]].BackgroundColor3 = Color3.fromRGB(220, 0, 0)
        tabFrames[tabNames[1]].Visible = true
        selectedTab = tabNames[1]
    end

    -- Return the tab frames so user can add content to each tab
    return tabFrames
end

return UILib
