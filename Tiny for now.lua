local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService") -- optional for sound feedback

local UI_API = {}
UI_API.__index = UI_API

-- Utility to create instances with props
local function createInstance(className, parent, properties)
    local inst = Instance.new(className)
    if properties then
        for k, v in pairs(properties) do
            inst[k] = v
        end
    end
    inst.Parent = parent
    return inst
end

-- Optionally play a sound on click/touch/hover (add your own sounds to SoundService)
local function playClickSound()
    -- SoundService:PlayLocalSound(SoundService:FindFirstChild("UIButton"))
end

-- Draggable + curvature
local function makeDraggable(dragFrame, handleBar)
    local UIS = game:GetService("UserInputService")
    local dragging, dragInput, startPos, startInputPos

    local function update(input)
        local delta = input.Position - startInputPos
        dragFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    handleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInputPos = input.Position
            startPos = dragFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Create responsive curved window with fade-in effect
function UI_API:CreateWindow(title, size, position)
    local screenGui = createInstance("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"), {
        Name = "UI_API_ScreenGui",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ScreenInsets = Enum.ScreenInsets.DeviceSafe
    })

    local canvas = createInstance("CanvasGroup", screenGui, {
        Name = "WindowCanvas", -- for fade animations
        BackgroundTransparency = 1
    })

    local window = createInstance("Frame", canvas, {
        Name = "Window",
        Size = size or UDim2.new(0.7, 0, 0.55, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = position or UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(34, 34, 40),
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 1
    })
    createInstance("UICorner", window, {CornerRadius = UDim.new(0, 22)})

    -- Fade in
    window.GroupTransparency = 1
    TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {GroupTransparency = 0}):Play()

    local titleBar = createInstance("Frame", window, {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        BorderSizePixel = 0,
        LayoutOrder = 0,
        ZIndex = 3
    })
    createInstance("UICorner", titleBar, {CornerRadius = UDim.new(0, 18)})

    createInstance("TextLabel", titleBar, {
        Name = "Title",
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "Window",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamSemibold,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4
    })

    local closeButton = createInstance("TextButton", titleBar, {
        Name = "CloseButton",
        Size = UDim2.new(0, 40, 1, 0),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundColor3 = Color3.fromRGB(233, 26, 78),
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        AutoButtonColor = true,
        ZIndex = 4
    })
    createInstance("UICorner", closeButton, {CornerRadius = UDim.new(0.5, 0)})

    closeButton.MouseButton1Click:Connect(function()
        TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {GroupTransparency = 1}):Play()
        wait(0.32)
        screenGui:Destroy()
    end)

    local contentFrame = createInstance("Frame", window, {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        ZIndex = 2
    })
    local contentLayout = createInstance("UIListLayout", contentFrame, {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })

    -- Make draggable
    makeDraggable(window, titleBar)

    local windowObj = {
        Content = contentFrame,
        Parent = window,
        AddElement = function(self, element)
            element.Parent = self.Content
            element.LayoutOrder = #self.Content:GetChildren()
        end
    }
    return windowObj
end

-- Sidebar tab system with animated transitions
function UI_API:AddSidebarTabs(window, tabInfoList)
    local sidebar = createInstance("Frame", window.Parent, {
        Name = "Sidebar",
        Size = UDim2.new(0, 94, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(44,44,54),
        BorderSizePixel = 0,
        ZIndex = 4
    })
    createInstance("UICorner", sidebar, {CornerRadius = UDim.new(0, 18)})

    local tabBtns, tabFrames = {}, {}

    local tabLayout = createInstance("UIListLayout", sidebar, {
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    for i, tabInfo in ipairs(tabInfoList) do
        local btn = createInstance("TextButton", sidebar, {
            Name = tabInfo.Name .. "_Btn",
            Size = UDim2.new(1, -10, 0, 48),
            BackgroundColor3 = Color3.fromRGB(68, 68, 78),
            Text = tabInfo.Name,
            TextColor3 = Color3.fromRGB(222,222,233),
            Font = Enum.Font.GothamSemibold,
            TextSize = 16,
            AutoButtonColor = true,
            ZIndex = 4
        })
        createInstance("UICorner", btn, {CornerRadius = UDim.new(0, 14)})
        tabBtns[i] = btn

        -- Tab main content frame
        local tabFrame = createInstance("Frame", window.Parent, {
            Name = tabInfo.Name .. "_Frame",
            Size = UDim2.new(1, -94, 1, 0),
            Position = UDim2.new(0, 94, 0, 0),
            BackgroundTransparency = 1,
            Visible = i == 1,
            ZIndex = 3
        })
        tabFrames[i] = tabFrame

        btn.MouseButton1Click:Connect(function()
            playClickSound()
            for j = 1, #tabBtns do
                tabBtns[j].BackgroundColor3 = Color3.fromRGB(68, 68, 78)
                tabFrames[j].Visible = false
            end
            btn.BackgroundColor3 = Color3.fromRGB(0,160,255)
            tabFrame.Visible = true

            -- Tab transition animation (pulse frame quickly)
            tabFrame.Size = UDim2.new(1, -94, 1, 0)
            TweenService:Create(tabFrame, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {Size = UDim2.new(1, -80, 1, 0)}):Play()
            wait(0.07)
            TweenService:Create(tabFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.new(1, -94, 1, 0)}):Play()
        end)
    end
    return {Sidebar = sidebar, Buttons = tabBtns, Frames = tabFrames}
end

-- Improved, visually responsive button
function UI_API:AddButton(window, text, callback)
    local button = createInstance("TextButton", nil, {
        Name = "Button",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Color3.fromRGB(80, 80, 120),
        Text = text or "Button",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Gotham,
        TextSize = 18
    })
    createInstance("UICorner", button, {CornerRadius = UDim.new(0, 12)})
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.18), {Size = UDim2.new(1, 0, 0, 54)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.18), {Size = UDim2.new(1, 0, 0, 48)}):Play()
    end)
    button.MouseButton1Click:Connect(function()
        playClickSound()
        if callback then callback() end
    end)
    window:AddElement(button)
    return button
end

-- Improved label, textbox, toggle methods (similar to previous, with better colors/font/sizing and curvature)

-- ... (AddLabel, AddTextbox, AddToggle, etc. similarly improved as above)

return UI_API
