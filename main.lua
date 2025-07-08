local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local farming = false
local airJumpEnabled = false
local espEnabled = false

local safeTPPosition = Vector3.new(0, 50, 0) -- Change to your safe spot coords

-- UI setup
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AutoFarmMenu"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 150)
Frame.Position = UDim2.new(0.5, -110, 0.5, -75) -- Centered
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local function createToggle(text, posY)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = text .. ": OFF"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.AutoButtonColor = true
    return btn
end

local farmToggle = createToggle("TP - TPS to closest player / attackable entinty", 10)
local airJumpToggle = createToggle("FLY", 55)
local espToggle = createToggle("ESP", 100)

farmToggle.MouseButton1Click:Connect(function()
    farming = not farming
    farmToggle.Text = farming and "AutoFarm: ON" or "AutoFarm: OFF"
end)

airJumpToggle.MouseButton1Click:Connect(function()
    airJumpEnabled = not airJumpEnabled
    airJumpToggle.Text = airJumpEnabled and "AirJump: ON" or "AirJump: OFF"
end)

espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggle.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    if not espEnabled then
        for _, box in pairs(Workspace:GetChildren()) do
            if box.Name == "ESP_Box" then
                box:Destroy()
            end
        end
    end
end)

-- Air jump fly logic
local flying = false
UserInputService.JumpRequest:Connect(function()
    if airJumpEnabled then
        flying = true
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        flying = false
    end
end)

RunService.Heartbeat:Connect(function()
    if flying and airJumpEnabled then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        humanoidRootPart.Velocity = Vector3.new(humanoidRootPart.Velocity.X, 50, humanoidRootPart.Velocity.Z)
    end
end)

-- ESP
local function createESPBox(target)
    if target:FindFirstChild("ESP_Box") then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box"
    box.Adornee = target
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Transparency = 0
    box.Size = target.Size + Vector3.new(0.2, 0.2, 0.2)
    box.Color3 = Color3.new(1, 0, 0)
    box.Parent = target
    return box
end

RunService.Heartbeat:Connect(function()
    if espEnabled then
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, enemy in pairs(enemies:GetChildren()) do
                if enemy:FindFirstChild("HumanoidRootPart") and not enemy:FindFirstChild("ESP_Box") then
                    createESPBox(enemy.HumanoidRootPart)
                end
            end
        end
    end
end)

-- Auto farm logic aggressive + random movement + safety teleport
spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if farming then
            local enemies = Workspace:FindFirstChild("Enemies")
            if enemies then
                for _, enemy in pairs(enemies:GetChildren()) do
                    if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        -- Teleport close to enemy, random offset for aggressiveness
                        local offset = Vector3.new(math.random(-3,3), 0, math.random(-3,3))
                        humanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(offset)

                        -- Attack simulation (replace with your actual attack logic)
                        -- Example: send tool activation or fire server event here

                        -- Wait random short delay for aggression
                        wait(math.random(5,15)/100)

                        -- Safety check: if player health low, teleport to safe spot
                        if humanoid.Health < humanoid.MaxHealth * 0.25 then
                            humanoidRootPart.CFrame = CFrame.new(safeTPPosition)
                            wait(2) -- Recover time
                        end
                    end
                end
            end
        else
            wait(0.5)
        end
    end
end)


--SPEED HAX

-- SpeedHack Popup GUI with Buttons

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "SpeedHackGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 240, 0, 140)
Frame.Position = UDim2.new(0.5, -120, 0.5, -70)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Speed Hack"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.BackgroundTransparency = 1

-- Speed label
local SpeedLabel = Instance.new("TextLabel", Frame)
SpeedLabel.Position = UDim2.new(0, 0, 0, 40)
SpeedLabel.Size = UDim2.new(1, 0, 0, 30)
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 20
SpeedLabel.Text = "Speed: 16"

-- Increase Button
local IncreaseButton = Instance.new("TextButton", Frame)
IncreaseButton.Position = UDim2.new(0.1, 0, 0, 80)
IncreaseButton.Size = UDim2.new(0.35, 0, 0, 30)
IncreaseButton.Text = "▲ +"
IncreaseButton.Font = Enum.Font.GothamBold
IncreaseButton.TextSize = 18
IncreaseButton.TextColor3 = Color3.new(1, 1, 1)
IncreaseButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)

-- Decrease Button
local DecreaseButton = Instance.new("TextButton", Frame)
DecreaseButton.Position = UDim2.new(0.55, 0, 0, 80)
DecreaseButton.Size = UDim2.new(0.35, 0, 0, 30)
DecreaseButton.Text = "▼ -"
DecreaseButton.Font = Enum.Font.GothamBold
DecreaseButton.TextSize = 18
DecreaseButton.TextColor3 = Color3.new(1, 1, 1)
DecreaseButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)

-- Logic
local currentSpeed = 16
local minSpeed = 16
local maxSpeed = 120

IncreaseButton.MouseButton1Click:Connect(function()
	currentSpeed = math.min(currentSpeed + 4, maxSpeed)
	SpeedLabel.Text = "Speed: " .. currentSpeed
end)

DecreaseButton.MouseButton1Click:Connect(function()
	currentSpeed = math.max(currentSpeed - 4, minSpeed)
	SpeedLabel.Text = "Speed: " .. currentSpeed
end)

-- Apply WalkSpeed
RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = currentSpeed
	end
end)


-- Freecam / SPINBOT

-- Haix Client

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "HaixClient"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 150)
Frame.Position = UDim2.new(0.5, -125, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Haix Client"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24

-- Helper function for buttons
local function createToggleButton(name, pos)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0, 110, 0, 30)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.Text = name .. ": OFF"
    local enabled = false
    
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = name .. (enabled and ": ON" or ": OFF")
    end)
    
    return btn, function() return enabled end
end

-- Create toggles and track their state
local autoFarmBtn, isAutoFarmOn = createToggleButton("Freecam - Moves camera to closest player", UDim2.new(0, 10, 0, 40))
local spinBotBtn, isSpinBotOn = createToggleButton("Spinbot", UDim2.new(0, 130, 0, 80))

-- ======= Auto Farm Logic =======
local attackRemote = nil
for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
    if v.Name:lower():find("attack") then
        attackRemote = v
        break
    end
end

local function getNearestEnemy()
    local nearest = nil
    local shortestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and myRoot then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    nearest = player
                end
            end
        end
    end
    return nearest
end

local function attackTarget(target)
    if not target or not target.Character then return end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    -- Teleport near enemy
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot then
        myRoot.CFrame = root.CFrame * CFrame.new(0, 0, 3)
    end
    -- Attack (simulate remote fire)
    if attackRemote and attackRemote:IsA("RemoteEvent") then
        attackRemote:FireServer()
    end
end

local safePosition = Vector3.new(0, 50, 0) -- somewhere safe high up

-- ======= ESP =======
local espBoxes = {}

local function createESPBox(player)
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    box.Size = Vector3.new(2, 5, 1)
    box.Transparency = 0.5
    box.Color3 = Color3.new(1, 0, 0)
    box.AlwaysOnTop = true
    box.Parent = game.CoreGui
    espBoxes[player] = box
end

local function removeESPBox(player)
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if isESPOn() and not espBoxes[player] then
                createESPBox(player)
            elseif not isESPOn() and espBoxes[player] then
                removeESPBox(player)
            end
        else
            removeESPBox(player)
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    removeESPBox(player)
end)

-- ======= Air Jump =======
local UserInputService = game:GetService("UserInputService")
local jumped = false
UserInputService.JumpRequest:Connect(function()
    if isAirJumpOn() then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Jump = true
        end
    end
end)

-- ======= Spinbot =======
local spinAngle = 0
RunService.Heartbeat:Connect(function()
    if isSpinBotOn() and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        spinAngle = (spinAngle + 20) % 360
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(20), 0)
    end
end)

-- ======= Main loop =======
RunService.Heartbeat:Connect(function()
    updateESP()
    if isAutoFarmOn() then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            if humanoid.Health < 50 then
                -- Go to safe position if low hp
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(safePosition)
                end
            else
                local target = getNearestEnemy()
                if target then
                    attackTarget(target)
                end
            end
        end
    end
end)


