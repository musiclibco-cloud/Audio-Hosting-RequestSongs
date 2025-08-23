-- Kasane+ Module (Full Version)
local Kasane = {}
Kasane.__index = Kasane

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- =========================
-- Notification System
-- =========================
local Notifications = {}
Notifications.__index = Notifications
Notifications.Container = nil

function Notifications:Init()
    if not self.Container then
        self.Container = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
        self.Container.Name = "KasaneNotifications"
    end
end

function Notifications:Send(text, duration)
    self:Init()
    duration = duration or 3

    local notif = Instance.new("Frame", self.Container)
    notif.Size = UDim2.new(0, 250, 0, 50)
    notif.Position = UDim2.new(0.5, -125, -0.2, 0)
    notif.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notif.BorderSizePixel = 0
    notif.AnchorPoint = Vector2.new(0.5, 0)

    local label = Instance.new("TextLabel", notif)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.Text = text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16

    -- Tween in
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -125, 0, 10)}):Play()

    -- Auto destroy
    delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, -125, -0.2, 0), BackgroundTransparency = 1}):Play()
        delay(0.5, function() notif:Destroy() end)
    end)
end

-- =========================
-- Drag helper
-- =========================
local function makeDraggable(frame, topbar)
    local dragging = false
    local dragStart, startPos

    local function startDrag(input)
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- =========================
-- Window Creation
-- =========================
function Kasane:CreateWindow(titleText, options)
    options = options or {}
    local window = {}
    window.tabs = {}
    window.errors = options.printErrors or false
    window.visible = true

    -- Main Frame
    local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    screenGui.Name = "KasaneUI"

    window.frame = Instance.new("Frame", screenGui)
    window.frame.Size = UDim2.new(0, 500, 0, 350)
    window.frame.Position = UDim2.new(0.5, -250, 0.5, -175)
    window.frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    window.frame.BorderSizePixel = 0

    -- Topbar
    local topbar = Instance.new("Frame", window.frame)
    topbar.Size = UDim2.new(1,0,0,30)
    topbar.BackgroundColor3 = Color3.fromRGB(34,34,34)
    topbar.BorderSizePixel = 0

    local title = Instance.new("TextLabel", topbar)
    title.Text = titleText or "Kasane+"
    title.Size = UDim2.new(1, -60,1,0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(240,240,240)
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextSize = 16

    -- Close / Minimize
    local closeButton = Instance.new("TextButton", topbar)
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0,30,1,0)
    closeButton.Position = UDim2.new(1,-30,0,0)
    closeButton.BackgroundTransparency = 1
    closeButton.TextColor3 = Color3.fromRGB(240,100,100)
    closeButton.MouseButton1Click:Connect(function()
        TweenService:Create(window.frame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -250,1,0), BackgroundTransparency=1}):Play()
        delay(0.3,function() window.frame:Destroy() end)
    end)

    local minimizeButton = Instance.new("TextButton", topbar)
    minimizeButton.Text = "_"
    minimizeButton.Size = UDim2.new(0,30,1,0)
    minimizeButton.Position = UDim2.new(1,-60,0,0)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.TextColor3 = Color3.fromRGB(200,200,100)

    local minimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            window.content.Visible = false
            window.navbar.Visible = false
            window.frame.Size = UDim2.new(window.frame.Size.X.Scale, window.frame.Size.X.Offset,0,30)
        else
            window.content.Visible = true
            window.navbar.Visible = true
            window.frame.Size = UDim2.new(0,500,0,350)
        end
    end)

    makeDraggable(window.frame, topbar)

    -- Content
    local content = Instance.new("ScrollingFrame", window.frame)
    content.Size = UDim2.new(1,0,1, -60)
    content.Position = UDim2.new(0,0,0,30)
    content.BackgroundColor3 = Color3.fromRGB(30,30,30)
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 6
    window.content = content

    -- Navbar
    local navbar = Instance.new("Frame", window.frame)
    navbar.Size = UDim2.new(1,0,0,30)
    navbar.Position = UDim2.new(0,0,1,-30)
    navbar.BackgroundColor3 = Color3.fromRGB(34,34,34)
    navbar.BorderSizePixel = 0
    window.navbar = navbar

    -- =========================
    -- Multi-Tab Support
    -- =========================
    function window:addTab(tabName)
        local tab = {}
        tab.buttons = {}

        -- Helper to update buttons
        local function updateTabButtons()
            local buttons = {}
            for _, child in ipairs(navbar:GetChildren()) do
                if child:IsA("TextButton") then
                    table.insert(buttons, child)
                end
            end
            local count = #buttons
            for i, btn in ipairs(buttons) do
                btn.Size = UDim2.new(1/count,0,1,0)
                btn.Position = UDim2.new((i-1)/count,0,0,0)
            end
        end

        -- Navbar button
        local tabBtn = Instance.new("TextButton", navbar)
        tabBtn.Text = tabName
        tabBtn.BackgroundTransparency = 1
        tabBtn.TextColor3 = Color3.fromRGB(200,200,200)
        tabBtn.Font = Enum.Font.SourceSans
        tabBtn.TextSize = 14

        updateTabButtons()

        -- Tab content
        local tabFrame = Instance.new("ScrollingFrame", content)
        tabFrame.Size = UDim2.new(1,0,1,0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.CanvasSize = UDim2.new(0,0,0,0)
        tabFrame.ScrollBarThickness = 6
        tabFrame.Visible = false

        local grid = Instance.new("UIGridLayout", tabFrame)
        grid.CellSize = UDim2.new(0,120,0,40)
        grid.CellPadding = UDim2.new(0,6,0,6)
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabFrame.CanvasSize = UDim2.new(0,0,0,grid.AbsoluteContentSize.Y+10)
        end)

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in ipairs(window.tabs) do
                t.frame.Visible = false
            end
            tabFrame.Visible = true
        end)

        -- Add elements
        function tab:addButton(text, callback)
            local btn = Instance.new("TextButton", tabFrame)
            btn.Size = UDim2.new(0,120,0,40)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            btn.TextColor3 = Color3.fromRGB(240,240,240)
            btn.Text = text
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 16
            btn.AutoButtonColor = true
            btn.MouseButton1Click:Connect(callback)
            table.insert(self.buttons, btn)
        end

        function tab:addToggle(text, default, callback)
            local frame = Instance.new("Frame", tabFrame)
            frame.Size = UDim2.new(0,120,0,40)
            frame.BackgroundColor3 = Color3.fromRGB(40,40,40)

            local label = Instance.new("TextLabel", frame)
            label.Text = text
            label.Size = UDim2.new(0.7,0,1,0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(240,240,240)
            label.Font = Enum.Font.SourceSans
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left

            local toggleBtn = Instance.new("TextButton", frame)
            toggleBtn.Size = UDim2.new(0.25,0,0.6,0)
            toggleBtn.Position = UDim2.new(0.72,0,0.2,0)
            toggleBtn.Text = ""
            toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)

            local toggled = default
            toggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                toggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
                if callback then callback(toggled) end
            end)
        end

        function tab:addTextBox(text, placeholder, callback)
            local frame = Instance.new("Frame", tabFrame)
            frame.Size = UDim2.new(0,120,0,40)
            frame.BackgroundColor3 = Color3.fromRGB(40,40,40)

            local label = Instance.new("TextLabel", frame)
            label.Text = text
            label.Size = UDim2.new(1,0,0.4,0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(240,240,240)
            label.Font = Enum.Font.SourceSans
            label.TextSize = 14

            local box = Instance.new("TextBox", frame)
            box.Size = UDim2.new(1,0,0.6,0)
            box.Position = UDim2.new(0,0,0.4,0)
            box.BackgroundColor3 = Color3.fromRGB(30,30,30)
            box.TextColor3 = Color3.fromRGB(240,240,240)
            box.PlaceholderText = placeholder or ""
            box.Font = Enum.Font.SourceSans
            box.TextSize = 14

            box.FocusLost:Connect(function(enterPressed)
                if enterPressed and callback then
                    callback(box.Text)
                end
            end)
        end

        tab.frame = tabFrame
        table.insert(window.tabs, tab)

        if #window.tabs == 1 then
            tabFrame.Visible = true
        end
        return tab
    end

    -- =========================
    -- Toggle UI function
    -- =========================
    function window:toggleUI()
        self.visible = not self.visible
        window.frame.Visible = self.visible
    end

    -- =========================
    -- Notification helper
    -- =========================
    function window:notify(text, duration)
        Notifications:Send(text, duration)
    end

    setmetatable(window, {__index = Kasane})
    return window
end

return Kasane
