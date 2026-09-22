-- Razen Hub | Professional Script
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Razen Hub - Professional", "DarkTheme")

-- نظام كشف الماب
local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local Player = game.Players.LocalPlayer

-- التبويب العام
local Main = Window:NewTab("Global")
local MainSection = Main:NewSection("Universal Features")

MainSection:NewSlider("Speed", "Adjust WalkSpeed", 500, 16, function(s) Player.Character.Humanoid.WalkSpeed = s end)
MainSection:NewToggle("Fly", "Enable Flight", function(state) -- Add fly logic here end)
MainSection:NewToggle("Infinite Jump", "Jump forever", function(state) 
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if state then game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
    end)
end)

-- كشف المابات وتفعيل ميزاتها
if game.PlaceId == 142823291 then -- MM2 ID
    local MM2 = Window:NewTab("MM2")
    local MM2Section = MM2:NewSection("Role ESP & Aim")
    MM2Section:NewToggle("Murderer ESP", "Show Murderer", function(s) end)
    MM2Section:NewToggle("Sheriff ESP", "Show Sheriff", function(s) end)
    MM2Section:NewToggle("Aimbot", "Lock on targets", function(s) end)

elseif game.PlaceId == 123456789 then -- Steel an Egg ID
    local Egg = Window:NewTab("Steel an Egg")
    local EggSection = Egg:NewSection("Auto Farm")
    EggSection:NewToggle("Auto Farm", "Collect eggs", function(s) end)
    EggSection:NewSlider("Speed", "Set Speed", 800, 16, function(s) Player.Character.Humanoid.WalkSpeed = s end)

elseif game.PlaceId == 987654321 then -- Keyboard Escape ID
    local Key = Window:NewTab("Keyboard Escape")
    Key:NewSection("Automation")
    Key:NewToggle("Auto Wins", "Auto Farm Wins", function(s) end)
    Key:NewSlider("Speed", "WalkSpeed", 300, 16, function(s) Player.Character.Humanoid.WalkSpeed = s end)
end
