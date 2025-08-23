-- Roblox UI Library
-- A comprehensive UI API for creating modern interfaces

local UILib = {}
UILib.__index = UILib

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Constants
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local FAST_TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Color Themes
UILib.Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Surface = Color3.fromRGB(35, 35, 35),
        Primary = Color3.fromRGB(0, 162, 255),
        Secondary = Color3.fromRGB(60, 60, 60),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 200, 200),
        Border = Color3.fromRGB(50, 50, 50),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 152, 0),
        Error = Color3.fromRGB(244, 67, 54)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Surface = Color3.fromRGB(255, 255, 255),
        Primary = Color3.fromRGB(33, 150, 243),
        Secondary = Color3.fromRGB(158, 158, 158),
        Text = Color3.fromRGB(33, 33, 33),
        SubText = Color3.fromRGB(117, 117, 117),
        Border = Color3.fromRGB(224, 224, 224),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 152, 0),
        Error = Color3.fromRGB(244, 67, 54)
    }
}

-- Utility Functions
local function createCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    return corner
end

local function createStroke(color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(50, 50, 50)
    stroke.Thickness = thickness or 1
    return stroke
end

local function createPadding(padding)
    local pad = Instance.new("UIPadding")
    if typeof(padding) == "number" then
        pad.PaddingTop = UDim.new(0, padding)
        pad.PaddingBottom = UDim.new(0, padding)
        pad.PaddingLeft = UDim.new(0, padding)
        pad.PaddingRight = UDim.new(0, padding)
    else
        pad.PaddingTop = UDim.new(0, padding.Top or 0)
        pad.PaddingBottom = UDim.new(0, padding.Bottom or 0)
        pad.PaddingLeft = UDim.new(0, padding.Left or 0)
        pad.PaddingRight = UDim.new(0, padding.Right or 0)
    end
    return pad
end

-- Main Library Constructor
function UILib.new(config)
    local self = setmetatable({}, UILib)
    
    config = config or {}
    self.Theme = UILib.Themes[config.Theme] or UILib.Themes.Dark
    self.Name = config.Name or "UILibrary"
    
    -- Create main ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = self.Name
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = PlayerGui
    
    self.Components = {}
    
    return self
end

-- Window Creation
function UILib:CreateWindow(config)
    config = config or {}
    
    local window = {}
    window.Tabs = {}
    window.ActiveTab = nil
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.Size = config.Size or UDim2.new(0, 600, 0, 450)
    main.Position = config.Position or UDim2.new(0.5, -300, 0.5, -225)
    main.BackgroundColor3 = self.Theme.Surface
    main.BorderSizePixel = 0
    main.Parent = self.ScreenGui
    
    createCorner(12).Parent = main
    createStroke(self.Theme.Border, 1).Parent = main
    
    window.Frame = main
    
    -- Title Bar (now with tabs)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 80) -- Increased height for tabs
    titleBar.BackgroundColor3 = self.Theme.Primary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    
    createCorner(12).Parent = titleBar
    
    -- Title bar mask for rounded corners
    local titleMask = Instance.new("Frame")
    titleMask.Size = UDim2.new(1, 0, 0, 12)
    titleMask.Position = UDim2.new(0, 0, 1, -12)
    titleMask.BackgroundColor3 = self.Theme.Primary
    titleMask.BorderSizePixel = 0
    titleMask.Parent = titleBar
    
    -- Top section of title bar (window title + controls)
    local topSection = Instance.new("Frame")
    topSection.Size = UDim2.new(1, 0, 0, 40)
    topSection.BackgroundTransparency = 1
    topSection.Parent = titleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = config.Title or "Window"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 16
    titleText.Font = Enum.Font.GothamMedium
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = topSection
    
    -- Window Controls Container
    local controlsContainer = Instance.new("Frame")
    controlsContainer.Size = UDim2.new(0, 90, 1, 0)
    controlsContainer.Position = UDim2.new(1, -95, 0, 0)
    controlsContainer.BackgroundTransparency = 1
    controlsContainer.Parent = topSection
    
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.Position = UDim2.new(0, 5, 0, 7.5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 189, 46)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 14
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = controlsContainer
    
    createCorner(12).Parent = minimizeBtn
    
    -- Maximize Button (placeholder for future functionality)
    local maximizeBtn = Instance.new("TextButton")
    maximizeBtn.Size = UDim2.new(0, 25, 0, 25)
    maximizeBtn.Position = UDim2.new(0, 35, 0, 7.5)
    maximizeBtn.BackgroundColor3 = Color3.fromRGB(40, 201, 64)
    maximizeBtn.BorderSizePixel = 0
    maximizeBtn.Text = "□"
    maximizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    maximizeBtn.TextSize = 12
    maximizeBtn.Font = Enum.Font.GothamBold
    maximizeBtn.Parent = controlsContainer
    
    createCorner(12).Parent = maximizeBtn
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(0, 65, 0, 7.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = controlsContainer
    
    createCorner(12).Parent = closeBtn
    
    -- Tab Container
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -20, 0, 35)
    tabContainer.Position = UDim2.new(0, 10, 0, 45)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.ScrollBarThickness = 0
    tabContainer.ScrollingDirection = Enum.ScrollingDirection.X
    tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContainer.Parent = titleBar
    
    -- Tab layout
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer
    
    -- Update tab container canvas size
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + 10, 0, 0)
    end)
    
    window.TabContainer = tabContainer
    window.TabLayout = tabLayout
    
    -- Content Area (will hold different tab contents)
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -20, 1, -100)
    contentArea.Position = UDim2.new(0, 10, 0, 90)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.Parent = main
    
    window.ContentArea = contentArea
    
    -- Mobile and Desktop Dragging Support
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragConnection = nil
    
    local function startDrag(inputPos)
        dragging = true
        dragStart = inputPos
        startPos = main.Position
    end
    
    local function updateDrag(inputPos)
        if dragging and dragStart then
            local delta = inputPos - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
    
    local function endDrag()
        dragging = false
        dragStart = nil
        startPos = nil
        if dragConnection then
            dragConnection:Disconnect()
            dragConnection = nil
        end
    end
    
    -- Desktop dragging
    topSection.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            startDrag(input.Position)
        elseif input.UserInputType == Enum.UserInputType.Touch then
            -- Mobile touch dragging
            startDrag(input.Position)
        end
    end)
    
    -- Global input handling for dragging
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateDrag(input.Position)
        elseif input.UserInputType == Enum.UserInputType.Touch and input.UserInputState == Enum.UserInputState.Change then
            updateDrag(input.Position)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)
    
    -- Touch support for mobile
    UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
        if dragging then
            endDrag()
        end
    end)
    
    -- Window control functionality
    local isMinimized = false
    local originalSize = main.Size
    
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(main, TWEEN_INFO, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 80)}):Play()
        else
            TweenService:Create(main, TWEEN_INFO, {Size = originalSize}):Play()
        end
    end)
    
    maximizeBtn.MouseButton1Click:Connect(function()
        -- Toggle between original size and maximized
        local currentSize = main.Size
        local viewport = workspace.CurrentCamera.ViewportSize
        
        if currentSize.X.Offset >= viewport.X - 20 then
            -- Restore to original size
            TweenService:Create(main, TWEEN_INFO, {
                Size = originalSize,
                Position = UDim2.new(0.5, -originalSize.X.Offset/2, 0.5, -originalSize.Y.Offset/2)
            }):Play()
        else
            -- Maximize
            originalSize = currentSize
            TweenService:Create(main, TWEEN_INFO, {
                Size = UDim2.new(0, viewport.X - 20, 0, viewport.Y - 40),
                Position = UDim2.new(0, 10, 0, 20)
            }):Play()
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(main, TWEEN_INFO, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        wait(0.3)
        self.ScreenGui:Destroy()
    end)
    
    -- Tab Management Methods
    function window:CreateTab(config)
        config = config or {}
        local tabName = config.Name or "Tab " .. (#self.Tabs + 1)
        local tabIcon = config.Icon or ""
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(0, 120, 1, 0)
        tabButton.BackgroundColor3 = self.ActiveTab and Color3.fromRGB(255, 255, 255):lerp(self.Theme.Primary, 0.9) or Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundTransparency = self.ActiveTab and 0.7 or 0.3
        tabButton.BorderSizePixel = 0
        tabButton.Text = (tabIcon ~= "" and tabIcon .. " " or "") .. tabName
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = 12
        tabButton.Font = Enum.Font.GothamMedium
        tabButton.Parent = window.TabContainer
        
        createCorner(4).Parent = tabButton
        
        -- Create tab content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "_Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = UILib.Theme.Primary
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = false
        tabContent.Parent = window.ContentArea
        
        -- Tab content layout
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.Parent = tabContent
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 16)
        end)
        
        local tab = {
            Name = tabName,
            Button = tabButton,
            Content = tabContent,
            Layout = contentLayout,
            IsActive = false
        }
        
        -- Tab switching functionality
        tabButton.MouseButton1Click:Connect(function()
            window:SwitchToTab(tabName)
        end)
        
        -- Add tab methods
        function tab:AddButton(config)
            return UILib:CreateButton(config, self.Content)
        end
        
        function tab:AddLabel(config)
            return UILib:CreateLabel(config, self.Content)
        end
        
        function tab:AddTextBox(config)
            return UILib:CreateTextBox(config, self.Content)
        end
        
        function tab:AddToggle(config)
            return UILib:CreateToggle(config, self.Content)
        end
        
        function tab:AddSlider(config)
            return UILib:CreateSlider(config, self.Content)
        end
        
        function tab:AddDropdown(config)
            return UILib:CreateDropdown(config, self.Content)
        end
        
        function tab:AddSection(config)
            return UILib:CreateSection(config, self.Content)
        end
        
        table.insert(window.Tabs, tab)
        
        -- Auto-select first tab
        if #window.Tabs == 1 then
            window:SwitchToTab(tabName)
        end
        
        return tab
    end
    
    function window:SwitchToTab(tabName)
        -- Hide current tab
        if self.ActiveTab then
            self.ActiveTab.Content.Visible = false
            self.ActiveTab.IsActive = false
            TweenService:Create(self.ActiveTab.Button, FAST_TWEEN, {
                BackgroundTransparency = 0.7,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255):lerp(UILib.Theme.Primary, 0.9)
            }):Play()
        end
        
        -- Find and show new tab
        for _, tab in pairs(self.Tabs) do
            if tab.Name == tabName then
                tab.Content.Visible = true
                tab.IsActive = true
                self.ActiveTab = tab
                TweenService:Create(tab.Button, FAST_TWEEN, {
                    BackgroundTransparency = 0.3,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                }):Play()
                break
            end
        end
    end
    
    function window:RemoveTab(tabName)
        for i, tab in pairs(self.Tabs) do
            if tab.Name == tabName then
                tab.Button:Destroy()
                tab.Content:Destroy()
                table.remove(self.Tabs, i)
                
                -- Switch to another tab if this was active
                if tab.IsActive and #self.Tabs > 0 then
                    self:SwitchToTab(self.Tabs[1].Name)
                end
                break
            end
        end
    end
    
    -- Add reference to main library
    for name, func in pairs(self) do
        if typeof(func) == "function" and name:sub(1, 6) == "Create" then
            window[name] = function(_, ...)
                return func(self, ...)
            end
        end
    end
    
    return window
end

-- Button Component
function UILib:CreateButton(config, parent)
    config = config or {}
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, config.Height or 35)
    button.BackgroundColor3 = config.Color or self.Theme.Primary
    button.BorderSizePixel = 0
    button.Text = config.Text or "Button"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = config.TextSize or 14
    button.Font = Enum.Font.Gotham
    button.Parent = parent or self.ScreenGui
    
    createCorner(6).Parent = button
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, FAST_TWEEN, {BackgroundColor3 = button.BackgroundColor3:lerp(Color3.fromRGB(255, 255, 255), 0.1)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, FAST_TWEEN, {BackgroundColor3 = config.Color or self.Theme.Primary}):Play()
    end)
    
    -- Click callback
    if config.Callback then
        button.MouseButton1Click:Connect(config.Callback)
    end
    
    return button
end

-- Label Component
function UILib:CreateLabel(config, parent)
    config = config or {}
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, config.Height or 25)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Label"
    label.TextColor3 = config.Color or self.Theme.Text
    label.TextSize = config.TextSize or 14
    label.Font = config.Font or Enum.Font.Gotham
    label.TextXAlignment = config.TextXAlignment or Enum.TextXAlignment.Left
    label.Parent = parent or self.ScreenGui
    
    return label
end

-- TextBox Component
function UILib:CreateTextBox(config, parent)
    config = config or {}
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, 0, 0, config.Height or 35)
    textBox.BackgroundColor3 = self.Theme.Secondary
    textBox.BorderSizePixel = 0
    textBox.Text = config.PlaceholderText or ""
    textBox.PlaceholderText = config.PlaceholderText or "Enter text..."
    textBox.TextColor3 = self.Theme.Text
    textBox.PlaceholderColor3 = self.Theme.SubText
    textBox.TextSize = config.TextSize or 14
    textBox.Font = Enum.Font.Gotham
    textBox.Parent = parent or self.ScreenGui
    
    createCorner(6).Parent = textBox
    createPadding(8).Parent = textBox
    
    if config.Callback then
        textBox.FocusLost:Connect(function(enterPressed)
            config.Callback(textBox.Text, enterPressed)
        end)
    end
    
    return textBox
end

-- Toggle Component
function UILib:CreateToggle(config, parent)
    config = config or {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = parent or self.ScreenGui
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.or "Toggle"
    label.TextColor3 = self.Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 40, 0, 20)
    toggleFrame.Position = UDim2.new(1, -40, 0.5, -10)
    toggleFrame.BackgroundColor3 = self.Theme.Secondary
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = frame
    
    createCorner(10).Parent = toggleFrame
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Size = UDim2.new(0, 16, 0, 16)
    toggleButton.Position = UDim2.new(0, 2, 0.5, -8)
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame
    
    createCorner(8).Parent = toggleButton
    
    local isToggled = config.Default or false
    
    local function updateToggle()
        local targetColor = isToggled and self.Theme.Primary or self.Theme.Secondary
        local targetPos = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        
        TweenService:Create(toggleFrame, FAST_TWEEN, {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(toggleButton, FAST_TWEEN, {Position = targetPos}):Play()
    end
    
    updateToggle()
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        updateToggle()
        if config.Callback then
            config.Callback(isToggled)
        end
    end)
    
    return frame
end

-- Slider Component
function UILib:CreateSlider(config, parent)
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local callback = config.Callback
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent or self.ScreenGui
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Slider"
    label.TextColor3 = self.Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = self.Theme.Primary
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 4)
    sliderFrame.Position = UDim2.new(0, 0, 1, -15)
    sliderFrame.BackgroundColor3 = self.Theme.Secondary
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = frame
    
    createCorner(2).Parent = sliderFrame
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = self.Theme.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderFrame
    
    createCorner(2).Parent = sliderFill
    
    local sliderButton = Instance.new("Frame")
    sliderButton.Size = UDim2.new(0, 12, 0, 12)
    sliderButton.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    sliderButton.BackgroundColor3 = self.Theme.Primary
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = sliderFrame
    
    createCorner(6).Parent = sliderButton
    
    local dragging = false
    local currentValue = default
    
    local function updateSlider(value)
        currentValue = math.clamp(value, min, max)
        local percentage = (currentValue - min) / (max - min)
        
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        sliderButton.Position = UDim2.new(percentage, -6, 0.5, -6)
        valueLabel.Text = tostring(math.floor(currentValue + 0.5))
        
        if callback then
            callback(currentValue)
        end
    end
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = sliderFrame
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percentage = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            updateSlider(min + percentage * (max - min))
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percentage = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            updateSlider(min + percentage * (max - min))
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return frame
end

-- Section Component
function UILib:CreateSection(config, parent)
    config = config or {}
    
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 25)
    section.BackgroundTransparency = 1
    section.Parent = parent or self.ScreenGui
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = self.Theme.Border
    line.BorderSizePixel = 0
    line.Parent = section
    
    if config.Text then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 0, 1, 0)
        label.BackgroundColor3 = parent and parent.BackgroundColor3 or self.Theme.Background
        label.Text = " " .. config.Text .. " "
        label.TextColor3 = self.Theme.SubText
        label.TextSize = 12
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = section
        
        -- Auto-size the label
        local textService = game:GetService("TextService")
        local textSize = textService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(math.huge, label.AbsoluteSize.Y))
        label.Size = UDim2.new(0, textSize.X, 1, 0)
    end
    
    return section
end

-- Dropdown Component (Basic implementation)
function UILib:CreateDropdown(config, parent)
    config = config or {}
    local options = config.Options or {"Option 1", "Option 2"}
    local selected = config.Default or options[1]
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = parent or self.ScreenGui
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(1, 0, 1, 0)
    dropdown.BackgroundColor3 = self.Theme.Secondary
    dropdown.BorderSizePixel = 0
    dropdown.Text = selected
    dropdown.TextColor3 = self.Theme.Text
    dropdown.TextSize = 14
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextXAlignment = Enum.TextXAlignment.Left
    dropdown.Parent = frame
    
    createCorner(6).Parent = dropdown
    createPadding(8).Parent = dropdown
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = self.Theme.SubText
    arrow.TextSize = 12
    arrow.Font = Enum.Font.Gotham
    arrow.Parent = dropdown
    
    -- Simple dropdown functionality (you might want to expand this)
    local currentIndex = 1
    for i, option in ipairs(options) do
        if option == selected then
            currentIndex = i
            break
        end
    end
    
    dropdown.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        selected = options[currentIndex]
        dropdown.Text = selected
        
        if config.Callback then
            config.Callback(selected)
        end
    end)
    
    return frame
end

-- Utility method to change theme
function UILib:SetTheme(themeName)
    self.Theme = UILib.Themes[themeName] or UILib.Themes.Dark
    -- You could add logic here to update existing components
end

return UILib
