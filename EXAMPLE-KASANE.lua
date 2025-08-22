local Kasane = loadstring(game:HttpGet("https://raw.githubusercontent.com/musiclibco-cloud/Audio-Hosting-RequestSongs/refs/heads/main/Kasane.lua"))()

local win = Kasane:CreateWindow("Player Hub")
local homeTab = win:addTab("Home")

homeTab:addButton("Set WalkSpeed 96", function()
    local player = game:GetService("Players").LocalPlayer
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 96
    end
end)

homeTab:addTextBox("Custom JumpPower", "Enter jump power...", function(value)
    local jumpPower = tonumber(value)
    if jumpPower then
        local player = game:GetService("Players").LocalPlayer
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = jumpPower
        end
    end
end)

homeTab:addToggle("No Gravity", false, function(state)
    local workspace = game:GetService("Workspace")
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored then
            part.Anchored = state
        end
    end
end)

homeTab:addDropdown("JumpPower Presets", {"50", "100", "200", "300"}, function(selected)
    local value = tonumber(selected)
    if value then
        local player = game:GetService("Players").LocalPlayer
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = value
        end
    end
end)
