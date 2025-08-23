-- Load Kasane library
local Kasane = loadstring(game:HttpGet("https://raw.githubusercontent.com/musiclibco-cloud/Audio-Hosting-RequestSongs/refs/heads/main/Kasane.lua"))()

-- Create window
local Window = Kasane:CreateWindow("Player Settings")

-- Add "Movement" tab
local MovementTab = Window:addTab("Movement") -- Make sure the library supports addTab like this

-- Walkspeed button
MovementTab:addButton("Set Walkspeed 96", function()
    local plr = game.Players.LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.WalkSpeed = 96
    end
end)

-- Jump Power textbox
MovementTab:addTextbox("Jump Power", function(value)
    local num = tonumber(value)
    local plr = game.Players.LocalPlayer
    if num and plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.JumpPower = num
    end
end)

-- No Gravity toggle
MovementTab:addToggle("No Gravity", function(state)
    workspace.Gravity = state and 0 or 196.2
end)

-- Jump Power presets dropdown
MovementTab:addDropdown("Jump Power Presets", {"50", "75", "100", "150"}, function(selection)
    local num = tonumber(selection)
    local plr = game.Players.LocalPlayer
    if num and plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.JumpPower = num
    end
end)

-- Kick button (for fun Unused)
MovementTab:addButton("Kick Me", function()
    game.Players.LocalPlayer:Kick("You clicked the button!")
end)
