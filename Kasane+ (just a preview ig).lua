-- Kasane+ Full Module
local Kasane = {}
Kasane.__index = Kasane

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Config
local DefaultWindowSize = UDim2.new(0, 500, 0, 350)

-- Helper: draggable frame
local function makeDraggable(frame, topbar)
    local dragging, dragStart, startPos = false, nil, nil
    local function updatePos(input)
        if dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end

    topbar.InputBegan:Connect(function(input)
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

    UserInputService.InputChanged:Connect(updatePos)
end

-- Notification system
function Kasane:Notify(text, duration)
    duration = duration or 3
    local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    screenGui.ResetOnSpawn = false

    local notif = Instance.new("Frame", screenGui)
    notif.Size = UDim2.new(0, 300, 0, 50)
    notif.Position = UDim2.new(0.5, -150, 0, -50)
    notif.BackgroundColor3 = Color3.fromRGB(30,30,30)
    notif.BorderSizePixel = 0
    notif.BackgroundTransparency = 0.1
    notif.ClipsDescendants = true

    local label = Instance.new("TextLabel", notif)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16

    -- Tween in
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -150, 0, 20)}):Play()
    delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -150, 0, -50)}):Play()
        wait(0.4)
        notif:Destroy()
        screenGui:Destroy()
    end)
end

-- Create Window
function Kasane:CreateWindow(title)
    local window = {}
    window.tabs = {}
    window.visible = true

    local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    screenGui.ResetOnSpawn = false
    window.screenGui = screenGui

    -- Main frame
    local frame = Instance.new("Frame", screenGui)
    frame.Size = DefaultWindowSize
    frame.Position = UDim2.new(0.5, -250, 0.5, -175)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.BorderSizePixel = 0
    window.frame = frame

    -- Topbar
    local topbar = Instance.new("Frame", frame)
    topbar.Size = UDim2.new(1,0,0,30)
    topbar.BackgroundColor3 = Color3.fromRGB(34,34,34)
    topbar.BorderSizePixel = 0

    local titleLabel = Instance.new("TextLabel", topbar)
    titleLabel.Text = title or "Kasane+"
    titleLabel.Size = UDim2.new(1, -60,1,0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(240,240,240)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextSize = 16

    -- Close Button
    local closeBtn = Instance.new("TextButton", topbar)
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0,30,1,0)
    closeBtn.Position = UDim2.new(1,-30,0,0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(240,100,100)
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}):Play()
        wait(0.3)
        screenGui:Destroy()
    end)

    -- Minimize Button
    local minBtn = Instance.new("TextButton", topbar)
    minBtn.Text = "_"
    minBtn.Size = UDim2.new(0,30,1,0)
    minBtn.Position = UDim2.new(1,-60,0,0)
    minBtn.BackgroundTransparency = 1
    minBtn.TextColor3 = Color3.fromRGB(200,200,100)
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            for _, v in pairs(frame:GetChildren()) do
                if v ~= topbar then
                    v.Visible = false
                end
            end
            TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset,0,30)}):Play()
        else
            for _, v in pairs(frame:GetChildren()) do
                v.Visible = true
            end
            TweenService:Create(frame, TweenInfo.new(0.3), {Size = DefaultWindowSize}):Play()
        end
    end)

    makeDraggable(frame, topbar)

    -- Content Frame
    local content = Instance.new("Frame", frame)
    content.Size = UDim2.new(1,0,1,-60)
    content.Position = UDim2.new(0,0,0,30)
    content.BackgroundTransparency = 1
    window.content = content

    -- Navbar
    local navbar = Instance.new("Frame", frame)
    navbar.Size = UDim2.new(1,0,0,30)
    navbar.Position = UDim2.new(0,0,1,-30)
    navbar.BackgroundColor3 = Color3.fromRGB(34,34,34)
    navbar.BorderSizePixel = 0
    window.navbar = navbar

    -- Add tab
    function window:addTab(name)
        local tab = {}
        tab.elements = {}
        tab.frame = Instance.new("ScrollingFrame", content)
        tab.frame.Size = UDim2.new(1,0,1,0)
        tab.frame.BackgroundTransparency = 1
        tab.frame.ScrollBarThickness = 6
        tab.frame.Visible = false

        local layout = Instance.new("UIListLayout", tab.frame)
        layout.Padding = UDim.new(0,6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        -- Navbar button
        local btn = Instance.new("TextButton", navbar)
        local count = #navbar:GetChildren()
        btn.Size = UDim2.new(1/(count+1),0,1,0)
        btn.Position = UDim2.new(count/(count+1),0,0,0)
        btn.Text = name
        btn.BackgroundTransparency = 1
        btn.TextColor3 = Color3.fromRGB(200,200,200)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14

        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(window.tabs) do
                t.frame.Visible = false
            end
            tab.frame.Visible = true
        end)

        -- Add Button
        function tab:addButton(text, callback)
            local b = Instance.new("TextButton", tab.frame)
            b.Size = UDim2.new(1,0,0,40)
            b.BackgroundColor3 = Color3.fromRGB(40,40,40)
            b.Text = text
            b.TextColor3 = Color3.fromRGB(240,240,240)
            b.Font = Enum.Font.SourceSans
            b.TextSize = 16
            b.AutoButtonColor = true
            b.MouseButton1Click:Connect(function()
                if callback then
                    pcall(callback)
                end
            end)
            table.insert(self.elements,b)
        end

        -- Add Toggle
        function tab:addToggle(text, default, callback)
            default = default or false
            local frame = Instance.new("Frame", tab.frame)
            frame.Size = UDim2.new(1,0,0,40)
            frame.BackgroundColor3 = Color3.fromRGB(40,40,40)

            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(0.7,0,1,0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Color3.fromRGB(240,240,240)
            label.Font = Enum.Font.SourceSans
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left

            local toggleBtn = Instance.new("TextButton", frame)
            toggleBtn.Size = UDim2.new(0.25,0,0.6,0)
            toggleBtn.Position = UDim2.new(0.72,0,0.2,0)
            toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
            local toggled = default
            toggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                toggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
                if callback then pcall(callback,toggled) end
            end)
            table.insert(self.elements,frame)
        end

        -- Add TextBox
        function tab:addTextBox(labelText, placeholder, callback)
            local frame = Instance.new("Frame", tab.frame)
            frame.Size = UDim2.new(1,0,0,40)
            frame.BackgroundColor3 = Color3.fromRGB(40,40,40)

            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(0.4,0,1,0)
            label.BackgroundTransparency = 1
            label.Text = labelText
            label.TextColor3 = Color3.fromRGB(240,240,240)
            label.Font = Enum.Font.SourceSans
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local box = Instance.new("TextBox", frame)
            box.Size = UDim2.new(0.55,0,0.8,0)
            box.Position = UDim2.new(0.42,0,0.1,0)
            box.BackgroundColor3 = Color3.fromRGB(30,30,30)
            box.TextColor3 = Color3.fromRGB(240,240,240)
            box.PlaceholderText = placeholder or ""
            box.Font = Enum.Font.SourceSans
            box.TextSize = 14
            box.FocusLost:Connect(function(enter)
                if enter and callback then
                    pcall(callback,box.Text)
                end
            end)
            table.insert(self.elements,frame)
        end

        table.insert(window.tabs,tab)
        return tab
    end

    -- Toggle UI visibility
    function window:toggleUI()
        self.visible = not self.visible
        self.frame.Visible = self.visible
    end

    return window
end

return Kasane
