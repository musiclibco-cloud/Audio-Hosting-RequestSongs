-- Kasane Module (Improved Mobile-Stable Version)
local Kasane = {}
Kasane.__index = Kasane

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

-- Constants
local MOBILE_DETECTION_TYPES = {
    Enum.UserInputType.Touch,
    Enum.Platform.IOS,
    Enum.Platform.Android
}

-- Utility Functions
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function safeGetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or nil
end

local function safeWaitForChild(parent, childName, timeout)
    timeout = timeout or 10
    local startTime = tick()
    
    while tick() - startTime < timeout do
        local child = parent:FindFirstChild(childName)
        if child then
            return child
        end
        wait(0.1)
    end
    
    warn("SafeWaitForChild: Timeout waiting for " .. childName)
    return nil
end

-- Get player safely
local player = Players.LocalPlayer
if not player then
    repeat
        player = Players.LocalPlayer
        wait()
    until player
end

-- 🔹 Enhanced draggable frame with mobile support and constraints
local function makeDraggable(frame, topbar)
    if not frame or not topbar then
        warn("MakeDraggable: Invalid frame or topbar")
        return
    end
    
    local dragging = false
    local dragStart, startPos
    local connection
    local screenSize = workspace.CurrentCamera.ViewportSize
    
    -- Update screen size on viewport change
    local viewportConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        screenSize = workspace.CurrentCamera.ViewportSize
    end)
    
    local function constrainPosition(position)
        local frameSize = frame.AbsoluteSize
        local minX = 0
        local minY = 0
        local maxX = screenSize.X - frameSize.X
        local maxY = screenSize.Y - frameSize.Y
        
        local constrainedX = math.max(minX, math.min(maxX, position.X.Offset))
        local constrainedY = math.max(minY, math.min(maxY, position.Y.Offset))
        
        return UDim2.new(0, constrainedX, 0, constrainedY)
    end
    
    local function startDrag(input)
        if dragging then return end
        
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        -- Create input end detection
        local inputEndConnection
        inputEndConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if inputEndConnection then
                    inputEndConnection:Disconnect()
                    inputEndConnection = nil
                end
            end
        end)
    end

    -- Enhanced input detection for mobile and desktop
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end)

    -- Movement handling with throttling for performance
    local lastUpdate = 0
    connection = UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        
        local currentTime = tick()
        if currentTime - lastUpdate < 0.016 then -- ~60 FPS throttling
            return
        end
        lastUpdate = currentTime
        
        if (input.UserInputType == Enum.UserInputType.MouseMovement or 
            input.UserInputType == Enum.UserInputType.Touch) then
            
            local delta = input.Position - dragStart
            local newPosition = UDim2.new(
                0, startPos.X.Offset + delta.X,
                0, startPos.Y.Offset + delta.Y
            )
            
            frame.Position = constrainPosition(newPosition)
        end
    end)
    
    -- Cleanup function
    frame.AncestryChanged:Connect(function()
        if not frame.Parent then
            if connection then connection:Disconnect() end
            if viewportConnection then viewportConnection:Disconnect() end
        end
    end)
end

-- 🔹 Create Window with enhanced mobile support
function Kasane:CreateWindow(titleText)
    if not titleText or type(titleText) ~= "string" then
        titleText = "Window"
    end
    
    local playerGui = safeWaitForChild(player, "PlayerGui")
    if not playerGui then
        error("Could not access PlayerGui")
        return
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KasaneUI_" .. titleText
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    local window = {}
    window.tabs = {}
    window.activeTab = nil
    window.destroyed = false
    
    -- Mobile-responsive sizing
    local isMobileDevice = isMobile()
    local windowWidth = isMobileDevice and math.min(400, workspace.CurrentCamera.ViewportSize.X * 0.9) or 500
    local windowHeight = isMobileDevice and math.min(300, workspace.CurrentCamera.ViewportSize.Y * 0.7) or 350
    
    window.frame = Instance.new("Frame")
    window.frame.Name = "MainFrame"
    window.frame.Size = UDim2.new(0, windowWidth, 0, windowHeight)
    window.frame.Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
    window.frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    window.frame.BorderSizePixel = 0
    window.frame.ClipsDescendants = true
    window.frame.Parent = screenGui

    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = window.frame

    -- Topbar with mobile-friendly height
    local topbarHeight = isMobileDevice and 40 or 30
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, topbarHeight)
    topbar.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    topbar.BorderSizePixel = 0
    topbar.Parent = window.frame

    local topbarCorner = Instance.new("UICorner")
    topbarCorner.CornerRadius = UDim.new(0, 8)
    topbarCorner.Parent = topbar

    local topbarBottom = Instance.new("Frame")
    topbarBottom.Size = UDim2.new(1, 0, 0, 8)
    topbarBottom.Position = UDim2.new(0, 0, 1, -8)
    topbarBottom.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    topbarBottom.BorderSizePixel = 0
    topbarBottom.Parent = topbar

    -- Title with better mobile scaling
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = titleText
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(240, 240, 240)
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextSize = isMobileDevice and 18 or 16
    title.TextScaled = true
    title.Parent = topbar

    -- Mobile-friendly button sizes
    local buttonSize = isMobileDevice and 35 or 30
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "✕"
    closeButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    closeButton.Position = UDim2.new(1, -buttonSize - 5, 0, (topbarHeight - buttonSize) / 2)
    closeButton.BackgroundTransparency = 1
    closeButton.TextColor3 = Color3.fromRGB(240, 100, 100)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = isMobileDevice and 20 or 16
    closeButton.Parent = topbar
    
    -- Close button functionality with cleanup
    closeButton.MouseButton1Click:Connect(function()
        if not window.destroyed then
            window:Destroy()
        end
    end)

    -- Minimize Button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Text = "─"
    minimizeButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    minimizeButton.Position = UDim2.new(1, -buttonSize * 2 - 10, 0, (topbarHeight - buttonSize) / 2)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.TextColor3 = Color3.fromRGB(200, 200, 100)
    minimizeButton.Font = Enum.Font.SourceSansBold
    minimizeButton.TextSize = isMobileDevice and 20 or 16
    minimizeButton.Parent = topbar
    
    -- Enhanced minimize functionality with animation
    local minimized = false
    local originalSize = window.frame.Size
    
    minimizeButton.MouseButton1Click:Connect(function()
        if window.destroyed then return end
        
        minimized = not minimized
        
        local targetSize = minimized and UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, topbarHeight) or originalSize
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(window.frame, tweenInfo, {Size = targetSize})
        
        if minimized then
            window.content.Visible = false
            window.navbar.Visible = false
        else
            tween.Completed:Connect(function()
                window.content.Visible = true
                window.navbar.Visible = true
            end)
        end
        
        tween:Play()
    end)

    makeDraggable(window.frame, topbar)

    -- Content ScrollingFrame with mobile optimizations
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -topbarHeight - 35)
    content.Position = UDim2.new(0, 0, 0, topbarHeight)
    content.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    content.BorderSizePixel = 0
    content.ScrollBarThickness = isMobileDevice and 12 or 6
    content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.ScrollingDirection = Enum.ScrollingDirection.Y
    content.Parent = window.frame
    window.content = content

    -- Bottom Navbar with mobile-friendly height
    local navbarHeight = isMobileDevice and 35 or 30
    local navbar = Instance.new("Frame")
    navbar.Name = "Navbar"
    navbar.Size = UDim2.new(1, 0, 0, navbarHeight)
    navbar.Position = UDim2.new(0, 0, 1, -navbarHeight)
    navbar.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    navbar.BorderSizePixel = 0
    navbar.Parent = window.frame
    window.navbar = navbar

    local navbarCorner = Instance.new("UICorner")
    navbarCorner.CornerRadius = UDim.new(0, 8)
    navbarCorner.Parent = navbar

    local navbarTop = Instance.new("Frame")
    navbarTop.Size = UDim2.new(1, 0, 0, 8)
    navbarTop.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    navbarTop.BorderSizePixel = 0
    navbarTop.Parent = navbar

    -- Add UIListLayout for navbar buttons
    local navbarLayout = Instance.new("UIListLayout")
    navbarLayout.FillDirection = Enum.FillDirection.Horizontal
    navbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    navbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    navbarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navbarLayout.Parent = navbar

    -- Enhanced tab creation with error handling
    function window:addTab(tabName)
        if window.destroyed then 
            warn("Cannot add tab to destroyed window")
            return nil 
        end
        
        if not tabName or type(tabName) ~= "string" or tabName == "" then
            warn("Invalid tab name provided")
            return nil
        end

        local tab = {}
        tab.elements = {}
        tab.destroyed = false
        tab.window = window

        -- Calculate button width dynamically
        local buttonCount = #window.tabs + 1
        local buttonWidth = math.floor((windowWidth - 20) / buttonCount)

        -- Navbar button with improved styling
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "Tab_" .. tabName
        tabBtn.Size = UDim2.new(0, buttonWidth, 1, -4)
        tabBtn.Text = tabName
        tabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabBtn.Font = Enum.Font.SourceSans
        tabBtn.TextSize = isMobileDevice and 16 or 14
        tabBtn.TextScaled = true
        tabBtn.LayoutOrder = buttonCount
        tabBtn.Parent = navbar

        local tabBtnCorner = Instance.new("UICorner")
        tabBtnCorner.CornerRadius = UDim.new(0, 4)
        tabBtnCorner.Parent = tabBtn

        -- Resize existing buttons
        for i, existingTab in ipairs(window.tabs) do
            if existingTab.button then
                existingTab.button.Size = UDim2.new(0, buttonWidth, 1, -4)
            end
        end

        -- Container for tab content with better scrolling
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Name = "TabFrame_" .. tabName
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabFrame.ScrollBarThickness = isMobileDevice and 12 or 6
        tabFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        tabFrame.Visible = false
        tabFrame.Parent = content

        -- Mobile-responsive grid layout
        local cellWidth = isMobileDevice and math.floor((windowWidth - 40) / 2) or 120
        local cellHeight = isMobileDevice and 50 : 40
        
        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.new(0, cellWidth, 0, cellHeight)
        grid.CellPadding = UDim2.new(0, isMobileDevice and 8 or 6, 0, isMobileDevice and 8 or 6)
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
        grid.Parent = tabFrame

        -- Auto-resize canvas
        local function updateCanvasSize()
            if not tab.destroyed and tabFrame.Parent then
                tabFrame.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + 20)
            end
        end
        
        grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

        -- Tab switching with visual feedback
        tabBtn.MouseButton1Click:Connect(function()
            if window.destroyed or tab.destroyed then return end
            
            -- Hide all tabs and reset button colors
            for _, t in pairs(window.tabs) do
                if t.frame and t.frame.Parent then
                    t.frame.Visible = false
                end
                if t.button and t.button.Parent then
                    t.button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                end
            end
            
            -- Show current tab and highlight button
            tabFrame.Visible = true
            tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            window.activeTab = tab
        end)

        -- Enhanced UI element creation methods
        function tab:addButton(text, callback)
            if tab.destroyed then return end
            
            text = text or "Button"
            callback = callback or function() end
            
            local btn = Instance.new("TextButton")
            btn.Name = "Button_" .. text
            btn.Size = UDim2.new(0, cellWidth, 0, cellHeight)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.fromRGB(240, 240, 240)
            btn.Text = text
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = isMobileDevice and 18 or 16
            btn.TextScaled = true
            btn.AutoButtonColor = true
            btn.Parent = tabFrame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = btn

            -- Enhanced click handling with debounce
            local lastClick = 0
            btn.MouseButton1Click:Connect(function()
                local currentTime = tick()
                if currentTime - lastClick > 0.1 then -- 100ms debounce
                    lastClick = currentTime
                    pcall(callback)
                end
            end)

            table.insert(tab.elements, btn)
            updateCanvasSize()
            return btn
        end

        -- Enhanced toggle with better visual feedback
        function tab:addToggle(text, default, callback)
            if tab.destroyed then return end
            
            text = text or "Toggle"
            default = default or false
            callback = callback or function() end

            local frame = Instance.new("Frame")
            frame.Name = "Toggle_" .. text
            frame.Size = UDim2.new(0, cellWidth, 0, cellHeight)
            frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            frame.Parent = tabFrame

            local frameCorner = Instance.new("UICorner")
            frameCorner.CornerRadius = UDim.new(0, 4)
            frameCorner.Parent = frame

            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Text = text
            label.Size = UDim2.new(0.65, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(240, 240, 240)
            label.Font = Enum.Font.SourceSans
            label.TextSize = isMobileDevice and 16 or 14
            label.TextScaled = true
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame

            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Name = "ToggleButton"
            toggleBtn.Size = UDim2.new(0.3, -5, 0.7, 0)
            toggleBtn.Position = UDim2.new(0.68, 0, 0.15, 0)
            toggleBtn.Text = ""
            toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
            toggleBtn.Parent = frame

            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0.5, 0)
            toggleCorner.Parent = toggleBtn

            local toggled = default
            
            -- Enhanced toggle with animation
            local function updateToggle()
                local targetColor = toggled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
                local tween = TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = targetColor})
                tween:Play()
            end

            toggleBtn.MouseButton1Click:Connect(function()
                if tab.destroyed then return end
                toggled = not toggled
                updateToggle()
                pcall(callback, toggled)
            end)

            table.insert(tab.elements, frame)
            updateCanvasSize()
            return frame
        end

        -- Enhanced dropdown with scrollable options for mobile
        function tab:addDropdown(text, options, callback)
            if tab.destroyed then return end
            
            text = text or "Dropdown"
            options = options or {"Option 1"}
            callback = callback or function() end

            local frame = Instance.new("TextButton")
            frame.Name = "Dropdown_" .. text
            frame.Size = UDim2.new(0, cellWidth, 0, cellHeight)
            frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            frame.Font = Enum.Font.SourceSans
            frame.TextSize = isMobileDevice and 16 : 14
            frame.TextScaled = true
            frame.TextColor3 = Color3.fromRGB(240, 240, 240)
            frame.Parent = tabFrame

            local frameCorner = Instance.new("UICorner")
            frameCorner.CornerRadius = UDim.new(0, 4)
             frameCorner.Parent = frame

            local currentIndex = 1
            frame.Text = text .. ": " .. tostring(options[currentIndex])

            -- Cycle through options with debounce
            local lastClick = 0
            frame.MouseButton1Click:Connect(function()
                local currentTime = tick()
                if currentTime - lastClick > 0.1 then
                    lastClick = currentTime
                    currentIndex = currentIndex % #options + 1
                    frame.Text = text .. ": " .. tostring(options[currentIndex])
                    pcall(callback, options[currentIndex])
                end
            end)

            table.insert(tab.elements, frame)
            updateCanvasSize()
            return frame
        end

        -- Enhanced TextBox with mobile keyboard support
        function tab:addTextBox(text, placeholder, callback)
            if tab.destroyed then return end
            
            text = text or "TextBox"
            placeholder = placeholder or ""
            callback = callback or function() end

            local frame = Instance.new("Frame")
            frame.Name = "TextBox_" .. text
            frame.Size = UDim2.new(0, cellWidth, 0, cellHeight)
            frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            frame.Parent = tabFrame

            local frameCorner = Instance.new("UICorner")
            frameCorner.CornerRadius = UDim.new(0, 4)
            frameCorner.Parent = frame

            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Text = text
            label.Size = UDim2.new(1, 0, 0.4, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(240, 240, 240)
            label.Font = Enum.Font.SourceSans
            label.TextSize = isMobileDevice and 14 or 12
            label.TextScaled = true
            label.Parent = frame

            local box = Instance.new("TextBox")
            box.Name = "TextBox"
            box.Size = UDim2.new(1, -6, 0.6, 0)
            box.Position = UDim2.new(0, 3, 0.4, 0)
            box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            box.TextColor3 = Color3.fromRGB(240, 240, 240)
            box.PlaceholderText = placeholder
            box.Font = Enum.Font.SourceSans
            box.TextSize = isMobileDevice and 16 or 14
            box.TextScaled = true
            box.ClearTextOnFocus = false
            box.Parent = frame

            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 2)
            boxCorner.Parent = box

            -- Enhanced focus handling
            box.FocusLost:Connect(function(enterPressed)
                if tab.destroyed then return end
                if enterPressed then
                    pcall(callback, box.Text)
                end
            end)

            table.insert(tab.elements, frame)
            updateCanvasSize()
            return frame
        end

        -- Add cleanup method for tab
        function tab:Destroy()
            if tab.destroyed then return end
            tab.destroyed = true
            
            for _, element in ipairs(tab.elements) do
                if element and element.Parent then
                    element:Destroy()
                end
            end
            
            if tab.frame and tab.frame.Parent then
                tab.frame:Destroy()
            end
            
            if tab.button and tab.button.Parent then
                tab.button:Destroy()
            end
        end

        tab.frame = tabFrame
        tab.button = tabBtn
        table.insert(window.tabs, tab)

        -- Make first tab active
        if #window.tabs == 1 then
            tabFrame.Visible = true
            tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            window.activeTab = tab
        end

        updateCanvasSize()
        return tab
    end

    -- Add cleanup method for window
    function window:Destroy()
        if window.destroyed then return end
        window.destroyed = true
        
        for _, tab in ipairs(window.tabs) do
            if tab and tab.Destroy then
                tab:Destroy()
            end
        end
        
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
    end

    setmetatable(window, {__index = Kasane})
    return window
end

return Kasane
