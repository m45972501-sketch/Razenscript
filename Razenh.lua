
-- Razen Hub | Advanced Multi-Game Script
-- Protection: Anti-Cheat Bypass v4.0 Enabled
-- UI: Dark Aesthetic / Professional

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Window = Library:CreateWindow({ Title = "Razen Hub", Center = true, AutoShow = true })

local Tabs = {
    Main = Window:AddTab("Steal an Egg"),
    MM2 = Window:AddTab("MM2"),
    Keyboard = Window:AddTab("Keyboard Escape"),
    Misc = Window:AddTab("System")
}

-- Steal an Egg
Tabs.Main:AddToggle("AutoFarm", {Text = "Auto Farm Secret Eggs"})
Tabs.Main:AddSlider("Speed", {Text = "Speed", Default = 16, Min = 16, Max = 1000})
Tabs.Main:AddToggle("ESPEgg", {Text = "Egg ESP"})
Tabs.Main:AddToggle("AntiTrap", {Text = "Anti Trap/Fall"})
Tabs.Main:AddButton({Text = "Join Private Server", Callback = function()
    -- Logic for Teleporting to low-pop server
    local HttpService = game:GetService("HttpService")
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"))
    for _, v in pairs(servers.data) do
        if v.playing == 1 then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id)
        end
    end
end})

-- MM2
Tabs.MM2:AddToggle("SheriffESP", {Text = "Sheriff ESP"})
Tabs.MM2:AddToggle("MurderESP", {Text = "Murderer ESP"})
Tabs.MM2:AddToggle("InnocentESP", {Text = "Innocent ESP"})
Tabs.MM2:AddToggle("AimBot", {Text = "Auto Aim"})
Tabs.MM2:AddToggle("Crosshair", {Text = "Custom Crosshair"})

-- Keyboard Escape
Tabs.Keyboard:AddToggle("AutoWin", {Text = "Auto Win Farm"})
Tabs.Keyboard:AddToggle("AllTread", {Text = "Unlock All Treadmills"})
Tabs.Keyboard:AddSlider("KSpeed", {Text = "Speed", Default = 16, Min = 16, Max = 300})

-- Anti-Cheat Protection Logic
local function AntiCheatBypass()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and self.Name == "AntiCheatEvent" then
            return nil
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end

AntiCheatBypass()
Library:Notify("Razen Hub Loaded Successfully.")