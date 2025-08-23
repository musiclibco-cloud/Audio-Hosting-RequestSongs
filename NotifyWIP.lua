-- KasaneNotify Module
local Notify = {}
Notify.__index = Notify

local Players = game:GetService("Players")
local player = Players.LocalPlayer

function Notify:Send(text, duration)
    duration = duration or 3
    local screenGui = player:FindFirstChild("PlayerGui")
    if not screenGui then return end

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(1, -210, 1, -60)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0, 1)
    frame.ClipsDescendants = true

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16

    -- Tween in
    frame.Position = UDim2.new(1, -210, 1, 10)
    game:GetService("TweenService"):Create(frame, TweenInfo.new(0.4), {Position=UDim2.new(1, -210, 1, -60)}):Play()

    -- Remove after duration
    delay(duration, function()
        game:GetService("TweenService"):Create(frame, TweenInfo.new(0.4), {Position=UDim2.new(1, -210, 1, 10), BackgroundTransparency=1}):Play()
        wait(0.4)
        frame:Destroy()
    end)
end

return Notify
