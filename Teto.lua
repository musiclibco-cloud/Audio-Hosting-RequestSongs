-- UILib Module
local UILib = {}
UILib.__index = UILib

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- 🔹 Helper: drag a frame
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

-- 🔹 Create a new window
function UILib:CreateWindow(titleText)
    local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

    local window = {}
    window.tabs = {}
    window.frame = Instance.new("Frame", screenGui)
    window.frame.Size = UDim2.new(0, 500, 0, 350)
    window.frame.Position = UDim2.new(0.5, -250, 0.5, -175)
    window.frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    window.frame.BorderSizePixel = 0

    -- Topbar
    local topbar = Instance.new("Frame", window.frame)
    topbar.Size = UDim2.new(1, 0, 0, 30)
    topbar.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    topbar.BorderSizePixel = 0

    local title = Instance.new("TextLabel", topbar)
    title.Text = titleText or "Window"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(240, 240, 240)
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextSize = 16

    -- Close / Minimize
    local closeButton = Instance.new("TextButton", topbar)
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.TextColor3 = Color3.fromRGB(240, 100, 100)
    closeButton.MouseButton1Click:Connect(function()
        window.frame:Destroy()
    end)

    local minimizeButton = Instance.new("TextButton", topbar)
    minimizeButton.Text = "_"
    minimizeButton.Size = UDim2.new(0, 30, 1, 0)
    minimizeButton.Position = UDim2.new(1, -60, 0, 0)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.TextColor3 = Color3.fromRGB(200, 200, 100)
    
    local minimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            window.content.Visible = false
            window.navbar.Visible = false
            window.frame.Size = UDim2.new(window.frame.Size.X.Scale, window.frame.Size.X.Offset, 0, 30)
        else
            window.content.Visible = true
            window.navbar.Visible = true
            window.frame.Size = UDim2.new(0, 500, 0, 350)
        end
    end)

    makeDraggable(window.frame, topbar)

    -- Content ScrollingFrame
    local content = Instance.new("ScrollingFrame", window.frame)
    content.Size = UDim2.new(1, 0, 1, -60)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 6
    window.content = content

    local navbar = Instance.new("Frame", window.frame)
    navbar.Size = UDim2.new(1, 0, 0, 30)
    navbar.Position = UDim2.new(0, 0, 1, -30)
    navbar.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    navbar.BorderSizePixel = 0
    window.navbar = navbar

    -- Add tab
    function window:addTab(tabName)
        local tab = {}
        tab.buttons = {}

        -- Create navbar button
        local tabBtn = Instance.new("TextButton", navbar)
        tabBtn.Size = UDim2.new(1 / (#navbar:GetChildren()), 0, 1, 0) -- approximate
        tabBtn.Position = UDim2.new((#navbar:GetChildren()-1)/ (#navbar:GetChildren()),0,0,0)
        tabBtn.Text = tabName
        tabBtn.BackgroundTransparency = 1
        tabBtn.TextColor3 = Color3.fromRGB(200,200,200)
        tabBtn.Font = Enum.Font.SourceSans
        tabBtn.TextSize = 14

        -- Container for tab content
        local tabFrame = Instance.new("Frame")
        tabFrame.Size = UDim2.new(1,0,1,0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Parent = content
        tabFrame.Visible = false

        local grid = Instance.new("UIGridLayout", tabFrame)
        grid.CellSize = UDim2.new(0, 120, 0, 40)
        grid.CellPadding = UDim2.new(0, 6, 0, 6)
        grid.SortOrder = Enum.SortOrder.LayoutOrder

        grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabFrame.CanvasSize = UDim2.new(0,0,0,grid.AbsoluteContentSize.Y + 10)
        end)

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(window.tabs) do
                t.frame.Visible = false
            end
            tabFrame.Visible = true
        end)

        -- Add button function
        function tab:addButton(text, callback)
            local btn = Instance.new("TextButton", tabFrame)
            btn.Size = UDim2.new(0, 120, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            btn.TextColor3 = Color3.fromRGB(240,240,240)
            btn.Text = text
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 16
            btn.AutoButtonColor = true
            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            table.insert(self.buttons, btn)
        end

        tab.frame = tabFrame
        table.insert(window.tabs, tab)
        return tab
    end

    setmetatable(window, {__index = UILib})
    return window
end

return UILib
