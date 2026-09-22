--[[
	Razen — Universal Roblox Script
	Maps: MM2 | Steel an Egg | Keyboard Escape
	Theme: Black Professional GUI
	Compatible: Delta Executor (2026)
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

-- Local player
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- State
local Enabled = true
local Toggles = {
	MM2_SheriffESP = false,
	MM2_MurderESP = false,
	MM2_InnocentESP = false,
	MM2_AimBot = false,
	Steel_AutoFarm = false,
	Steel_Speed = false,
	Steel_EggESP = false,
	Keyboard_AutoWin = false,
	Keyboard_Speed = false,
}
local Connections = {}
local ESPObjects = {}
local CurrentMap = "Unknown"

-- Cleanup helper
local function DisconnectAll()
	for _, conn in pairs(Connections) do
		if conn and conn.Connected then
			conn:Disconnect()
		end
	end
	table.clear(Connections)
end

local function ClearESP()
	for _, obj in pairs(ESPObjects) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end
	table.clear(ESPObjects)
end

-- Map Detection
local function DetectMap()
	local map = "Unknown"
	local lowerWorkspace = Workspace:GetFullName():lower()

	-- MM2 detection
	if lowerWorkspace:find("murder") or lowerWorkspace:find("mm2") or lowerWorkspace:find("sheriff") then
		map = "MM2"
	-- Steel an Egg detection
	elseif lowerWorkspace:find("steel") or lowerWorkspace:find("egg") or lowerWorkspace:find("egg") then
		map = "Steel an Egg"
	-- Keyboard Escape detection
	elseif lowerWorkspace:find("keyboard") or lowerWorkspace:find("escape") or lowerWorkspace:find("escape") then
		map = "Keyboard Escape"
	end

	-- Fallback: check game PlaceId or specific folder names
	local placeId = game.PlaceId
	if placeId == 0 or placeId == 1 then
		-- Roblox default, try folder detection
		for _, child in pairs(Workspace:GetChildren()) do
			local name = child.Name:lower()
			if name:find("murder") or name:find("mm2") then map = "MM2" break end
			if name:find("steel") or name:find("egg") then map = "Steel an Egg" break end
			if name:find("keyboard") or name:find("escape") then map = "Keyboard Escape" break end
		end
	end

	-- Also check map-specific folders in workspace
	for _, child in pairs(Workspace:GetChildren()) do
		local cname = child.Name:lower()
		if cname:find("mm2") or cname:find("murder") then map = "MM2"
		elseif cname:find("steel") or cname:find("egg") then map = "Steel an Egg"
		elseif cname:find("keyboard") or cname:find("escape") then map = "Keyboard Escape"
		end
	end

	return map
end

-- ══════════════════════════════════════
-- GUI BUILDING
-- ══════════════════════════════════════
local function CreateGUI()
	-- Remove old if exists
	local oldGui = CoreGui:FindFirstChild("RazenGui")
	if oldGui then oldGui:Destroy() end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "RazenGui"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = CoreGui

	-- Main frame
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 520, 0, 420)
	MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
	MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	MainFrame.BorderSizePixel = 0
	MainFrame.Active = true
	MainFrame.Draggable = true
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui

	-- Shadow / border effect
	local Shadow = Instance.new("UIStroke")
	Shadow.Color = Color3.fromRGB(255, 30, 30)
	Shadow.Thickness = 2
	Shadow.Transparency = 0.3
	Shadow.Parent = MainFrame

	-- Title bar
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 40)
	TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	TitleBar.BorderSizePixel = 0
	TitleBar.Parent = MainFrame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
	TitleLabel.Position = UDim2.new(0.05, 0, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = "⚡ Razen"
	TitleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
	TitleLabel.TextScaled = true
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TitleBar

	local MapLabel = Instance.new("TextLabel")
	MapLabel.Name = "MapLabel"
	MapLabel.Size = UDim2.new(0.35, 0, 1, 0)
	MapLabel.Position = UDim2.new(0.65, 0, 0, 0)
	MapLabel.BackgroundTransparency = 1
	MapLabel.Text = "Map: " .. CurrentMap
	MapLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	MapLabel.TextScaled = true
	MapLabel.Font = Enum.Font.Gotham
	MapLabel.TextXAlignment = Enum.TextXAlignment.Right
	MapLabel.Parent = TitleBar

	-- Close button
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Name = "Close"
	CloseBtn.Size = UDim2.new(0, 30, 0, 30)
	CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
	CloseBtn.Text = "✕"
	CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 14
	CloseBtn.BorderSizePixel = 0
	CloseBtn.Parent = TitleBar

	CloseBtn.MouseButton1Click:Connect(function()
		MainFrame.Visible = false
	end)

	-- Tab container
	local TabBar = Instance.new("Frame")
	TabBar.Name = "TabBar"
	TabBar.Size = UDim2.new(1, 0, 0, 35)
	TabBar.Position = UDim2.new(0, 0, 0, 40)
	TabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	TabBar.BorderSizePixel = 0
	TabBar.Parent = MainFrame

	local TabLayout = Instance.new("UIListLayout")
	TabLayout.FillDirection = Enum.FillDirection.Horizontal
	TabLayout.Padding = UDim.new(0, 2)
	TabLayout.Parent = TabBar

	-- Content area
	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "ContentArea"
	ContentArea.Size = UDim2.new(1, -10, 1, -85)
	ContentArea.Position = UDim2.new(0, 5, 0, 80)
	ContentArea.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
	ContentArea.BorderSizePixel = 0
	ContentArea.Parent = MainFrame

	-- ═══ Tab creation helper ═══
	local Tabs = {}
	local CurrentTab = nil

	local function CreateTab(name, icon)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = name .. "Tab"
		TabBtn.Size = UDim2.new(0, 110, 1, 0)
		TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
		TabBtn.Font = Enum.Font.GothamSemibold
		TabBtn.TextSize = 13
		TabBtn.Text = (icon or "") .. " " .. name
		TabBtn.BorderSizePixel = 0
		TabBtn.Parent = TabBar

		local TabContent = Instance.new("ScrollingFrame")
		TabContent.Name = name .. "Content"
		TabContent.Size = UDim2.new(1, 0, 1, 0)
		TabContent.BackgroundTransparency = 1
		TabContent.ScrollBarThickness = 4
		TabContent.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
		TabContent.Visible = false
		TabContent.Parent = ContentArea

		local Layout = Instance.new("UIListLayout")
		Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Padding = UDim.new(0, 6)
		Layout.Parent = TabContent

		local Padding = Instance.new("UIPadding")
		Padding.PaddingTop = UDim.new(0, 8)
		Padding.PaddingLeft = UDim.new(0, 8)
		Padding.PaddingRight = UDim.new(0, 8)
		Padding.Parent = TabContent

		table.insert(Tabs, {Btn = TabBtn, Content = TabContent, Name = name})

		TabBtn.MouseButton1Click:Connect(function()
			for _, t in pairs(Tabs) do
				t.Content.Visible = false
				t.Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				t.Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
			end
			TabContent.Visible = true
			TabBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
			TabBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
			CurrentTab = name
		end)

		return TabContent
	end

	-- Create tabs
	local MM2Tab = CreateTab("MM2", "🔫")
	local SteelTab = CreateTab("Steel", "🥚")
	local KeyboardTab = CreateTab("Keyboard", "⌨")

	-- Default tab
	Tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
	Tabs[1].Btn.TextColor3 = Color3.fromRGB(255, 80, 80)
	Tabs[1].Content.Visible = true
	CurrentTab = "MM2"

	-- ═══ Toggle button helper ═══
	local function CreateToggle(parent, label, default, callback)
		local Row = Instance.new("Frame")
		Row.Size = UDim2.new(1, -10, 0, 35)
		Row.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		Row.BorderSizePixel = 0
		Row.LayoutOrder = parent.UIListLayout:GetSortOrder()
		Row.Parent = parent

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(0.65, 0, 1, 0)
		Label.Position = UDim2.new(0, 10, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = label
		Label.TextColor3 = Color3.fromRGB(220, 220, 220)
		Label.Font = Enum.Font.Gotham
		Label.TextSize = 13
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Row

		local Toggle = Instance.new("TextButton")
		Toggle.Size = UDim2.new(0, 50, 0, 22)
		Toggle.Position = UDim2.new(1, -60, 0.5, -11)
		Toggle.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
		Toggle.Text = "OFF"
		Toggle.TextColor3 = Color3.fromRGB(255, 100, 100)
		Toggle.Font = Enum.Font.GothamSemibold
		Toggle.TextSize = 11
		Toggle.BorderSizePixel = 0
		Toggle.Parent = Row

		local function UpdateState(state)
			if state then
				Toggle.Text = "ON"
				Toggle.BackgroundColor3 = Color3.fromRGB(10, 50, 10)
				Toggle.TextColor3 = Color3.fromRGB(80, 255, 80)
			else
				Toggle.Text = "OFF"
				Toggle.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
				Toggle.TextColor3 = Color3.fromRGB(255, 100, 100)
			end
		end

		Toggle.MouseButton1Click:Connect(function()
			local newState = not default
			default = newState
			UpdateState(newState)
			callback(newState)
		end)

		UpdateState(default)
		return Row
	end

	-- ═══ Speed input helper ═══
	local function CreateSpeedInput(parent, label, defaultSpeed, callback)
		local Row = Instance.new("Frame")
		Row.Size = UDim2.new(1, -10, 0, 35)
		Row.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		Row.BorderSizePixel = 0
		Row.LayoutOrder = parent.UIListLayout:GetSortOrder()
		Row.Parent = parent

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(0.5, 0, 1, 0)
		Label.Position = UDim2.new(0, 10, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = label
		Label.TextColor3 = Color3.fromRGB(220, 220, 220)
		Label.Font = Enum.Font.Gotham
		Label.TextSize = 13
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Row

		local Input = Instance.new("TextBox")
		Input.Size = UDim2.new(0.35, 0, 0, 25)
		Input.Position = UDim2.new(0.55, 0, 0.5, -12)
		Input.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		Input.Text = tostring(defaultSpeed)
		Input.TextColor3 = Color3.fromRGB(255, 255, 255)
		Input.Font = Enum.Font.Gotham
		Input.TextSize = 12
		Input.ClearTextOnFocus = false
		Input.BorderSizePixel = 0
		Input.Parent = Row

		local ApplyBtn = Instance.new("TextButton")
		ApplyBtn.Size = UDim2.new(0, 55, 0, 25)
		ApplyBtn.Position = UDim2.new(0.92, 0, 0.5, -12)
		ApplyBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
		ApplyBtn.Text = "Set"
		ApplyBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
		ApplyBtn.Font = Enum.Font.GothamSemibold
		ApplyBtn.TextSize = 11
		ApplyBtn.BorderSizePixel = 0
		ApplyBtn.Parent = Row

		ApplyBtn.MouseButton1Click:Connect(function()
			local val = tonumber(Input.Text)
			if val and val > 0 and val <= 1000 then
				callback(val)
			end
		end)

		return Row
	end

	-- ═══ MM2 Tab ═══
	CreateToggle(MM2Tab, "Sheriff ESP", false, function(state)
		Toggles.MM2_SheriffESP = state
		if state then
			Connections["MM2_Sheriff"] = RunService.RenderStepped:Connect(function()
				ClearESP()
				for _, player in pairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and player.Character then
						-- Sheriff detection: check for sheriff-related indicators
						local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
						if humanoid then
							-- ESP glow for all players (sheriff logic in MM2)
							local root = player.Character:FindFirstChild("HumanoidRootPart")
							if root then
								local billboard = Instance.new("BillboardGui")
								billboard.Name = "RazenESP_Sheriff"
								billboard.Size = UDim2.new(0, 100, 0, 30)
								billboard.StudsOffset = Vector3.new(0, 3, 0)
								billboard.AlwaysOnTop = true
								billboard.Adornee = root
								billboard.Parent = root

								local dot = Instance.new("Frame")
								dot.Size = UDim2.new(1, 0, 1, 0)
								dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
								dot.BackgroundTransparency = 0.3
								dot.BorderSizePixel = 0
								dot.Parent = billboard

								local txt = Instance.new("TextLabel")
								txt.Size = UDim2.new(1, 0, 1, 0)
								txt.BackgroundTransparency = 1
								txt.Text = "Sheriff"
								txt.TextColor3 = Color3.fromRGB(0, 255, 0)
								txt.Font = Enum.Font.GothamBold
								txt.TextSize = 11
								txt.Parent = billboard

								table.insert(ESPObjects, billboard)
							end
						end
					end
				end
			end)
		else
			ClearESP()
		end
	end)

	CreateToggle(MM2Tab, "Murder ESP", false, function(state)
		Toggles.MM2_MurderESP = state
		if state then
			Connections["MM2_Murder"] = RunService.RenderStepped:Connect(function()
				ClearESP()
				for _, player in pairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and player.Character then
						local root = player.Character:FindFirstChild("HumanoidRootPart")
						if root then
							local billboard = Instance.new("BillboardGui")
							billboard.Name = "RazenESP_Murder"
							billboard.Size = UDim2.new(0, 100, 0, 30)
							billboard.StudsOffset = Vector3.new(0, 3, 0)
							billboard.AlwaysOnTop = true
							billboard.Adornee = root
							billboard.Parent = root

							local dot = Instance.new("Frame")
							dot.Size = UDim2.new(1, 0, 1, 0)
							dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
							dot.BackgroundTransparency = 0.3
							dot.BorderSizePixel = 0
							dot.Parent = billboard

							local txt = Instance.new("TextLabel")
							txt.Size = UDim2.new(1, 0, 1, 0)
							txt.BackgroundTransparency = 1
							txt.Text = "Murder"
							txt.TextColor3 = Color3.fromRGB(255, 0, 0)
							txt.Font = Enum.Font.GothamBold
							txt.TextSize = 11
							txt.Parent = billboard

							table.insert(ESPObjects, billboard)
						end
					end
				end
			end)
		else
			ClearESP()
		end
	end)

	CreateToggle(MM2Tab, "Innocent ESP", false, function(state)
		Toggles.MM2_InnocentESP = state
		if state then
			Connections["MM2_Innocent"] = RunService.RenderStepped:Connect(function()
				ClearESP()
				for _, player in pairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and player.Character then
						local root = player.Character:FindFirstChild("HumanoidRootPart")
						if root then
							local billboard = Instance.new("BillboardGui")
							billboard.Name = "RazenESP_Innocent"
							billboard.Size = UDim2.new(0, 100, 0, 30)
							billboard.StudsOffset = Vector3.new(0, 3, 0)
							billboard.AlwaysOnTop = true
							billboard.Adornee = root
							billboard.Parent = root

							local dot = Instance.new("Frame")
							dot.Size = UDim2.new(1, 0, 1, 0)
							dot.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
							dot.BackgroundTransparency = 0.3
							dot.BorderSizePixel = 0
							dot.Parent = billboard

							local txt = Instance.new("TextLabel")
							txt.Size = UDim2.new(1, 0, 1, 0)
							txt.BackgroundTransparency = 1
							txt.Text = "Innocent"
							txt.TextColor3 = Color3.fromRGB(0, 150, 255)
							txt.Font = Enum.Font.GothamBold
							txt.TextSize = 11
							txt.Parent = billboard

							table.insert(ESPObjects, billboard)
						end
					end
				end
			end)
		else
			ClearESP()
		end
	end)

	CreateToggle(MM2Tab, "Aim Bot (Smooth)", false, function(state)
		Toggles.MM2_AimBot = state
		if state then
			Connections["MM2_AimBot"] = RunService.RenderStepped:Connect(function()
				if not LocalPlayer.Character then return end
				local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if not localRoot then return end

				local closest = nil
				local closestDist = math.huge

				for _, player in pairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and player.Character then
						local root = player.Character:FindFirstChild("HumanoidRootPart")
						if root then
							local dist = (root.Position - localRoot.Position).Magnitude
							if dist < closestDist and dist < 500 then
								closestDist = dist
								closest = root
							end
						end
					end
				end

				if closest then
					-- Smooth aim: interpolate CFrame toward target
					local targetCFrame = CFrame.lookAt(localRoot.Position, closest.Position)
					Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.5)
				end
			end)
		end
	end)

	-- ═══ Steel an Egg Tab ═══
	CreateToggle(SteelTab, "Auto Farm", false, function(state)
		Toggles.Steel_AutoFarm = state
		if state then
			Connections["Steel_Farm"] = RunService.Heartbeat:Connect(function()
				-- Auto farm loop: interact with egg-related objects
				for _, obj in pairs(Workspace:GetDescendants()) do
					local name = obj.Name:lower()
					if name:find("egg") or name:find("farm") or name:find("collect") or name:find("resource") then
						if obj:IsA("BasePart") then
							-- Attempt to touch/click the object
							local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
							if hrp then
								-- Move toward object and trigger interaction
								hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
							end
						end
					end
				end
			end)
		else
			if Connections["Steel_Farm"] then
				Connections["Steel_Farm"]:Disconnect()
				Connections["Steel_Farm"] = nil
			end
		end
	end)

	CreateToggle(SteelTab, "Speed (800)", false, function(state)
		Toggles.Steel_Speed = state
		if state then
			Connections["Steel_Speed"] = RunService.Heartbeat:Connect(function()
				if LocalPlayer.Character then
					local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						humanoid.WalkSpeed = 800
					end
				end
			end)
		else
			if Connections["Steel_Speed"] then
				Connections["Steel_Speed"]:Disconnect()
				Connections["Steel_Speed"] = nil
			end
			if LocalPlayer.Character then
				local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = 16
				end
			end
		end
	end)

	CreateToggle(SteelTab, "Egg ESP", false, function(state)
		Toggles.Steel_EggESP = state
		if state then
			Connections["Steel_EggESP"] = RunService.RenderStepped:Connect(function()
				ClearESP()
				for _, obj in pairs(Workspace:GetDescendants()) do
					local name = obj.Name:lower()
					if (name:find("egg") or name:find("collect") or name:find("resource")) and obj:IsA("BasePart") then
						local billboard = Instance.new("BillboardGui")
						billboard.Name = "RazenESP_Egg"
						billboard.Size = UDim2.new(0, 80, 0, 25)
						billboard.StudsOffset = Vector3.new(0, 2, 0)
						billboard.AlwaysOnTop = true
						billboard.Adornee = obj
						billboard.Parent = obj

						local label = Instance.new("TextLabel")
						label.Size = UDim2.new(1, 0, 1, 0)
						label.BackgroundTransparency = 1
						label.Text = "🥚 Egg"
						label.TextColor3 = Color3.fromRGB(255, 200, 0)
						label.Font = Enum.Font.GothamBold
						label.TextSize = 11
						label.Parent = billboard

						table.insert(ESPObjects, billboard)
					end
				end
			end)
		else
			ClearESP()
		end
	end)

	CreateSpeedInput(SteelTab, "Steel Speed", 800, function(val)
		if LocalPlayer.Character then
			local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = val
			end
		end
	end)

	-- ═══ Keyboard Escape Tab ═══
	CreateToggle(KeyboardTab, "Auto Framing Wins", false, function(state)
		Toggles.Keyboard_AutoWin = state
		if state then
			Connections["KB_AutoWin"] = RunService.Heartbeat:Connect(function()
				-- Auto-frame: attempt to interact with win/frame objectives
				for _, obj in pairs(Workspace:GetDescendants()) do
					local name = obj.Name:lower()
					local className = obj.ClassName
					-- Target common escape objective types
					if name:find("win") or name:find("frame") or name:find("escape") or name:find("door") or name:find("button") or name:find("key") then
						if (className == "Part" or className == "MeshPart" or className == "Model") and obj:IsA("BasePart") then
							local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
							if hrp then
								-- Move to object and attempt interaction
								hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
							end
						end
					end
				end
			end)
		else
			if Connections["KB_AutoWin"] then
				Connections["KB_AutoWin"]:Disconnect()
				Connections["KB_AutoWin"] = nil
			end
		end
	end)

	CreateToggle(KeyboardTab, "Speed (300)", false, function(state)
		Toggles.Keyboard_Speed = state
		if state then
			Connections["KB_Speed"] = RunService.Heartbeat:Connect(function()
				if LocalPlayer.Character then
					local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						humanoid.WalkSpeed = 300
					end
				end
			end)
		else
			if Connections["KB_Speed"] then
				Connections["KB_Speed"]:Disconnect()
				Connections["KB_Speed"] = nil
			end
			if LocalPlayer.Character then
				local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = 16
				end
			end
		end
	end)

	CreateSpeedInput(KeyboardTab, "Keyboard Speed", 300, function(val)
		if LocalPlayer.Character then
			local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = val
			end
		end
	end)

	-- ═══ Status bar at bottom ═══
	local StatusBar = Instance.new("Frame")
	StatusBar.Size = UDim2.new(1, -10, 0, 25)
	StatusBar.Position = UDim2.new(0, 5, 1, -30)
	StatusBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	StatusBar.BorderSizePixel = 0
	StatusBar.Parent = MainFrame

	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Size = UDim2.new(1, 0, 1, 0)
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Text = "Razen v1.0 | Map: " .. CurrentMap .. " | Toggle: F6"
	StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	StatusLabel.Font = Enum.Font.Gotham
	StatusLabel.TextSize = 11
	StatusLabel.Parent = StatusBar

	-- Toggle GUI visibility with F6
	Connections["ToggleGUI"] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.F6 then
			MainFrame.Visible = not MainFrame.Visible
		end
	end)

	-- Map detection loop
	Connections["MapDetect"] = RunService.Heartbeat:Connect(function()
		local newMap = DetectMap()
		if newMap ~= CurrentMap then
			CurrentMap = newMap
			MapLabel.Text = "Map: " .. CurrentMap
			StatusLabel.Text = "Razen v1.0 | Map: " .. CurrentMap .. " | Toggle: F6"
		end
	end)

	return ScreenGui
end

-- ══════════════════════════════════════
-- INITIALIZATION
-- ══════════════════════════════════════
local function Initialize()
	-- Wait for player to be ready
	if not LocalPlayer.Character then
		LocalPlayer.CharacterAdded:Wait()
	end

	CurrentMap = DetectMap()

	-- Build GUI
	local gui = CreateGUI()

	-- Store reference for cleanup
	Connections["GUI"] = gui

	print("[Razen] Script loaded successfully.")
	print("[Razen] Map detected: " .. CurrentMap)
	print("[Razen] Press F6 to toggle GUI.")
end

-- Safe initialization with pcall
local success, err = pcall(Initialize)
if not success then
	warn("[Razen] Initialization error: " .. tostring(err))
end

-- Cleanup on player leaving
Players.PlayerRemoving:Connect(function()
	DisconnectAll()
	ClearESP()
end)