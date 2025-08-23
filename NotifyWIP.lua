-- KasaneNotify Module
local KasaneNotify = {}
KasaneNotify.__index = KasaneNotify

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

function KasaneNotify:Notify(text, duration)
    duration = duration or 3
    local screenGui = player:FindFirstChild("PlayerGui")
    if not screenGui then return end

    -- Notification frame
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 240, 0, 50)
    frame.Position = UDim2.new(0.5, -120, -0.1, 0) -- start offscreen top
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.ZIndex = 999

    -- Text
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16

    -- Tween in (swipe from top)
    TweenService:Create(
        frame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -120, 0, 10)}
    ):Play()

    -- Wait duration, then swipe out and destroy
    delay(duration, function()
        local outTween = TweenService:Create(
            frame,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, -120, -0.1, 0)}
        )
        outTween:Play()
        outTween.Completed:Wait()
        frame:Destroy()
    end)
end

setmetatable(KasaneNotify, KasaneNotify)
return KasaneNotify
