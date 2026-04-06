task.spawn(function()
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local s = isMobile and 0.65 or 1 -- UI Scale factor

-- Safe character wait
local function waitForCharacter()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
        return char
    end
    return Player.CharacterAdded:Wait()
end

task.spawn(function()
    waitForCharacter()
end)

if not getgenv then
    getgenv = function() return _G end
end

-- NEW: Global Better PC Dragging Logic
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

local ConfigFileName = "Swag_Hub_Config_V3.json"

local Enabled = {
    SpeedBoost = false,
    AntiRagdoll = false,
    SpinBot = false,
    SpeedWhileStealing = false,
    AutoSteal = false,
    Unwalk = false,
    Optimizer = false,
    Galaxy = false,
    SpamBat = false,
    BatAimbot = false,
    GalaxySkyBright = false,
    AutoWalkEnabled = false,
    AutoRightEnabled = false,
    AutoPlayLeftEnabled = false,
    AutoPlayRightEnabled = false,
    InfJump = false,
    ESP = false,
    Hover = false,
    Stats = false,
    SpeedMeter = false
}

local Values = {
    BoostSpeed = 30,
    SpinSpeed = 30,
    StealingSpeedValue = 29,
    STEAL_RADIUS = 20,
    STEAL_DURATION = 1.3,
    AutoLeftSpeed = 59.5,
    AutoRightSpeed = 59.5,
    AutoWalkReturnSpeed = 30,
    AutoPlayReturnSpeed = 30,
    AutoWalkWaitTime = 1.0,
    AutoPlayWaitTime = 1.0,
    AutoPlayExitDist = 6.0,
    DEFAULT_GRAVITY = 196.2,
    GalaxyGravityPercent = 70,
    HOP_POWER = 35,
    HOP_COOLDOWN = 0.08,
    FOV = 105.8,
    HoverHeight = 15
}

local KEYBINDS = {
    SPEED = Enum.KeyCode.V,
    SPIN = Enum.KeyCode.N,
    GALAXY = Enum.KeyCode.M,
    BATAIMBOT = Enum.KeyCode.X,
    NUKE = Enum.KeyCode.Q,
    AUTOLEFT = Enum.KeyCode.Z,
    AUTORIGHT = Enum.KeyCode.C,
    AUTOPLAYLEFT = Enum.KeyCode.F10,
    AUTOPLAYRIGHT = Enum.KeyCode.F11,
    ANTIRAGDOLL = Enum.KeyCode.F1,
    SPEEDSTEAL = Enum.KeyCode.F2,
    AUTOSTEAL = Enum.KeyCode.F3,
    UNWALK = Enum.KeyCode.F4,
    OPTIMIZER = Enum.KeyCode.F5,
    SPAMBAT = Enum.KeyCode.F6,
    GALAXY_SKY = Enum.KeyCode.F7,
    INFJUMP = Enum.KeyCode.F8,
    ESP = Enum.KeyCode.P,
    HOVER = Enum.KeyCode.G,
    STATS = Enum.KeyCode.F9,
    SPEEDMETER = Enum.KeyCode.J
}

-- Theme and Background settings defined globally so they can save/load
local CurrentThemeIndex = 1
local isRainbow = false
local CurrentBgEffectIndex = 1

-- Load Config
local configLoaded = false
pcall(function()
    if readfile and isfile and isfile(ConfigFileName) then
        local data = HttpService:JSONDecode(readfile(ConfigFileName))
        if data then
            for k, v in pairs(data) do
                if Enabled[k] ~= nil then Enabled[k] = v end
            end
            for k, v in pairs(data) do
                if Values[k] ~= nil then Values[k] = v end
            end
            if data.KEY_SPEED then KEYBINDS.SPEED = Enum.KeyCode[data.KEY_SPEED] end
            if data.KEY_SPIN then KEYBINDS.SPIN = Enum.KeyCode[data.KEY_SPIN] end
            if data.KEY_GALAXY then KEYBINDS.GALAXY = Enum.KeyCode[data.KEY_GALAXY] end
            if data.KEY_BATAIMBOT then KEYBINDS.BATAIMBOT = Enum.KeyCode[data.KEY_BATAIMBOT] end
            if data.KEY_AUTOLEFT then KEYBINDS.AUTOLEFT = Enum.KeyCode[data.KEY_AUTOLEFT] end
            if data.KEY_AUTORIGHT then KEYBINDS.AUTORIGHT = Enum.KeyCode[data.KEY_AUTORIGHT] end
            if data.KEY_AUTOPLAYLEFT then KEYBINDS.AUTOPLAYLEFT = Enum.KeyCode[data.KEY_AUTOPLAYLEFT] end
            if data.KEY_AUTOPLAYRIGHT then KEYBINDS.AUTOPLAYRIGHT = Enum.KeyCode[data.KEY_AUTOPLAYRIGHT] end
            if data.KEY_ANTIRAGDOLL then KEYBINDS.ANTIRAGDOLL = Enum.KeyCode[data.KEY_ANTIRAGDOLL] end
            if data.KEY_SPEEDSTEAL then KEYBINDS.SPEEDSTEAL = Enum.KeyCode[data.KEY_SPEEDSTEAL] end
            if data.KEY_AUTOSTEAL then KEYBINDS.AUTOSTEAL = Enum.KeyCode[data.KEY_AUTOSTEAL] end
            if data.KEY_UNWALK then KEYBINDS.UNWALK = Enum.KeyCode[data.KEY_UNWALK] end
            if data.KEY_OPTIMIZER then KEYBINDS.OPTIMIZER = Enum.KeyCode[data.KEY_OPTIMIZER] end
            if data.KEY_SPAMBAT then KEYBINDS.SPAMBAT = Enum.KeyCode[data.KEY_SPAMBAT] end
            if data.KEY_GALAXY_SKY then KEYBINDS.GALAXY_SKY = Enum.KeyCode[data.KEY_GALAXY_SKY] end
            if data.KEY_INFJUMP then KEYBINDS.INFJUMP = Enum.KeyCode[data.KEY_INFJUMP] end
            if data.KEY_ESP then KEYBINDS.ESP = Enum.KeyCode[data.KEY_ESP] end
            if data.KEY_HOVER then KEYBINDS.HOVER = Enum.KeyCode[data.KEY_HOVER] end
            if data.KEY_STATS then KEYBINDS.STATS = Enum.KeyCode[data.KEY_STATS] end
            if data.KEY_SPEEDMETER then KEYBINDS.SPEEDMETER = Enum.KeyCode[data.KEY_SPEEDMETER] end
            
            if data.CurrentThemeIndex then CurrentThemeIndex = data.CurrentThemeIndex end
            if data.isRainbow ~= nil then isRainbow = data.isRainbow end
            if data.CurrentBgEffectIndex then CurrentBgEffectIndex = data.CurrentBgEffectIndex end
            
            configLoaded = true
        end
    end
end)

-- Save Config
local function SaveConfig()
    local data = {}
    for k, v in pairs(Enabled) do data[k] = v end
    for k, v in pairs(Values) do data[k] = v end
    data.KEY_SPEED = KEYBINDS.SPEED.Name
    data.KEY_SPIN = KEYBINDS.SPIN.Name
    data.KEY_GALAXY = KEYBINDS.GALAXY.Name
    data.KEY_BATAIMBOT = KEYBINDS.BATAIMBOT.Name
    data.KEY_AUTOLEFT = KEYBINDS.AUTOLEFT.Name
    data.KEY_AUTORIGHT = KEYBINDS.AUTORIGHT.Name
    data.KEY_AUTOPLAYLEFT = KEYBINDS.AUTOPLAYLEFT.Name
    data.KEY_AUTOPLAYRIGHT = KEYBINDS.AUTOPLAYRIGHT.Name
    data.KEY_ANTIRAGDOLL = KEYBINDS.ANTIRAGDOLL.Name
    data.KEY_SPEEDSTEAL = KEYBINDS.SPEEDSTEAL.Name
    data.KEY_AUTOSTEAL = KEYBINDS.AUTOSTEAL.Name
    data.KEY_UNWALK = KEYBINDS.UNWALK.Name
    data.KEY_OPTIMIZER = KEYBINDS.OPTIMIZER.Name
    data.KEY_SPAMBAT = KEYBINDS.SPAMBAT.Name
    data.KEY_GALAXY_SKY = KEYBINDS.GALAXY_SKY.Name
    data.KEY_INFJUMP = KEYBINDS.INFJUMP.Name
    data.KEY_ESP = KEYBINDS.ESP.Name
    data.KEY_HOVER = KEYBINDS.HOVER.Name
    data.KEY_STATS = KEYBINDS.STATS.Name
    data.KEY_SPEEDMETER = KEYBINDS.SPEEDMETER.Name
    
    data.CurrentThemeIndex = CurrentThemeIndex
    data.isRainbow = isRainbow
    data.CurrentBgEffectIndex = CurrentBgEffectIndex
    
    local success = false
    if writefile then
        pcall(function()
            writefile(ConfigFileName, HttpService:JSONEncode(data))
            success = true
        end)
    end
    return success
end

local Connections = {}
local isStealing = false
local lastBatSwing = 0
local BAT_SWING_COOLDOWN = 0.12

local SlapList = {
    {1, "Bat"}, {2, "Slap"}, {3, "Iron Slap"}, {4, "Gold Slap"},
    {5, "Diamond Slap"}, {6, "Emerald Slap"}, {7, "Ruby Slap"},
    {8, "Dark Matter Slap"}, {9, "Flame Slap"}, {10, "Nuclear Slap"},
    {11, "Galaxy Slap"}, {12, "Glitched Slap"}
}

local ADMIN_KEY = "78a772b6-9e1c-4827-ab8b-04a07838f298"
local REMOTE_EVENT_ID = "352aad58-c786-4998-886b-3e4fa390721e"
local BALLOON_REMOTE = ReplicatedStorage:FindFirstChild(REMOTE_EVENT_ID, true)

local function INSTANT_NUKE(target)
    if not BALLOON_REMOTE or not target then return end
    for _, p in ipairs({"balloon", "ragdoll", "jumpscare", "morph", "tiny", "rocket", "inverse", "jail"}) do
        BALLOON_REMOTE:FireServer(ADMIN_KEY, target, p)
    end
end

local function getNearestPlayer()
    local c = Player.Character
    if not c then return nil end
    local h = c:FindFirstChild("HumanoidRootPart")
    if not h then return nil end
    local pos = h.Position
    local nearest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local oh = p.Character:FindFirstChild("HumanoidRootPart")
            if oh then
                local d = (pos - oh.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = p
                end
            end
        end
    end
    return nearest
end

local function findBat()
    local c = Player.Character
    if not c then return nil end
    local bp = Player:FindFirstChildOfClass("Backpack")
    for _, ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
    end
    if bp then
        for _, ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
        end
    end
    for _, i in ipairs(SlapList) do
        local t = c:FindFirstChild(i[2]) or (bp and bp:FindFirstChild(i[2]))
        if t then return t end
    end
    return nil
end

local function startSpamBat()
    if Connections.spamBat then return end
    Connections.spamBat = RunService.Heartbeat:Connect(function()
        if not Enabled.SpamBat then return end
        local c = Player.Character
        if not c then return end
        local bat = findBat()
        if not bat then return end
        if bat.Parent ~= c then bat.Parent = c end
        local now = tick()
        if now - lastBatSwing < BAT_SWING_COOLDOWN then return end
        lastBatSwing = now
        pcall(function() bat:Activate() end)
    end)
end

local function stopSpamBat()
    if Connections.spamBat then Connections.spamBat:Disconnect() Connections.spamBat = nil end
end

local spinBAV = nil
local function startSpinBot()
    local c = Player.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if spinBAV then spinBAV:Destroy() spinBAV = nil end
    for _, v in pairs(hrp:GetChildren()) do if v.Name == "SpinBAV" then v:Destroy() end end
    spinBAV = Instance.new("BodyAngularVelocity")
    spinBAV.Name = "SpinBAV"
    spinBAV.MaxTorque = Vector3.new(0, math.huge, 0)
    spinBAV.AngularVelocity = Vector3.new(0, Values.SpinSpeed, 0)
    spinBAV.Parent = hrp
end

local function stopSpinBot()
    if spinBAV then spinBAV:Destroy() spinBAV = nil end
    local c = Player.Character
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do if v.Name == "SpinBAV" then v:Destroy() end end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if Enabled.SpinBot and spinBAV then
        if Player:GetAttribute("Stealing") then
            spinBAV.AngularVelocity = Vector3.new(0, 0, 0)
        else
            spinBAV.AngularVelocity = Vector3.new(0, Values.SpinSpeed, 0)
        end
    end
end)

-- ============================================
-- SPEED METER LOGIC
-- ============================================
local speedMeterConnection = nil
local speedMeterGui = nil

local function toggleSpeedMeter(state)
    if speedMeterConnection then
        speedMeterConnection:Disconnect()
        speedMeterConnection = nil
    end
    if speedMeterGui then
        speedMeterGui:Destroy()
        speedMeterGui = nil
    end

    if state then
        local char = Player.Character
        if not char then return end
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not head then return end
        
        speedMeterGui = Instance.new("BillboardGui")
        speedMeterGui.Name = "ZyphrotSpeedMeter"
        speedMeterGui.Adornee = head
        speedMeterGui.Size = UDim2.new(0, 150, 0, 40)
        speedMeterGui.StudsOffset = Vector3.new(0, 3.5, 0)
        speedMeterGui.AlwaysOnTop = true
        
        local textLabel = Instance.new("TextLabel", speedMeterGui)
        textLabel.Name = "SpeedText"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "Speed: 0"
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 16 * s
        
        local successHl, _ = pcall(function() speedMeterGui.Parent = game:GetService("CoreGui") end)
        if not successHl then speedMeterGui.Parent = Player:WaitForChild("PlayerGui") end
        
        speedMeterConnection = RunService.Heartbeat:Connect(function()
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = Player.Character.HumanoidRootPart
            if speedMeterGui and speedMeterGui:FindFirstChild("SpeedText") then
                -- Only use horizontal velocity for an accurate walkspeed reading
                local horizontalVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
                local speed = math.round(horizontalVelocity.Magnitude)
                speedMeterGui.SpeedText.Text = "Speed: " .. tostring(speed)
            end
        end)
    end
end

-- ============================================
-- NEW BAT AIMBOT LOGIC (EXACTLY AS PROVIDED)
-- ============================================
local aimbotConnection = nil
local lockedTarget = nil
local AIMBOT_SPEED = 60
local MELEE_OFFSET = 3
local MAX_DISTANCE = math.huge 

local aimbotHighlight = Instance.new("Highlight")
aimbotHighlight.Name = "AimbotTargetESP"
aimbotHighlight.FillColor = Color3.fromRGB(255, 0, 0)
aimbotHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
aimbotHighlight.FillTransparency = 0.5
aimbotHighlight.OutlineTransparency = 0
local successHl, _ = pcall(function() aimbotHighlight.Parent = game:GetService("CoreGui") end)
if not successHl then aimbotHighlight.Parent = Player:WaitForChild("PlayerGui") end

local function isTargetValid(targetChar)
    if not targetChar then return false end
    local hum = targetChar:FindFirstChildOfClass("Humanoid")
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    local ff = targetChar:FindFirstChildOfClass("ForceField")
    return hum and hrp and hum.Health > 0 and not ff
end

local function getBestTarget(myHRP)
    if lockedTarget and isTargetValid(lockedTarget) then
        return lockedTarget:FindFirstChild("HumanoidRootPart"), lockedTarget
    end

    local shortestDistance = MAX_DISTANCE
    local newTargetChar = nil
    local newTargetHRP = nil

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= Player and isTargetValid(targetPlayer.Character) then
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = (targetHRP.Position - myHRP.Position).Magnitude
            
            if distance < shortestDistance then
                shortestDistance = distance
                newTargetHRP = targetHRP
                newTargetChar = targetPlayer.Character
            end
        end
    end
    
    lockedTarget = newTargetChar
    return newTargetHRP, newTargetChar
end

local function startBatAimbot()
    if aimbotConnection then return end
    
    local c = Player.Character
    if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not h or not hum then return end
    
    hum.AutoRotate = false
    local attachment = h:FindFirstChild("AimbotAttachment") or Instance.new("Attachment", h)
    attachment.Name = "AimbotAttachment"
    
    local align = h:FindFirstChild("AimbotAlign") or Instance.new("AlignOrientation", h)
    align.Name = "AimbotAlign"
    align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    align.Attachment0 = attachment
    align.MaxTorque = math.huge
    align.Responsiveness = 200
    
    aimbotConnection = RunService.Heartbeat:Connect(function(dt)
        if not Enabled.BatAimbot then return end
        
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
        local currentHRP = Player.Character.HumanoidRootPart
        local currentHum = Player.Character:FindFirstChildOfClass("Humanoid")
        
        local bat = findBat()
        if bat and bat.Parent ~= Player.Character then currentHum:EquipTool(bat) end
        
        local targetHRP, targetChar = getBestTarget(currentHRP)
        
        if targetHRP and targetChar then
            aimbotHighlight.Adornee = targetChar
            
            -- Dynamic Prediction based on how fast they are moving
            local targetVelocity = targetHRP.AssemblyLinearVelocity
            local speed = targetVelocity.Magnitude
            local dynamicPredictTime = math.clamp(speed / 150, 0.05, 0.2)
            
            local predictedPos = targetHRP.Position + (targetVelocity * dynamicPredictTime)
            
            -- Calculate offset position (stay slightly behind them)
            local dirToTarget = (predictedPos - currentHRP.Position)
            local distance3D = dirToTarget.Magnitude
            
            local targetStandPos = predictedPos
            if distance3D > 0 then
                targetStandPos = predictedPos - (dirToTarget.Unit * MELEE_OFFSET)
            end

            -- Face the actual predicted position
            align.CFrame = CFrame.lookAt(currentHRP.Position, predictedPos)
            
            -- Move towards the offset position
            local moveDir = (targetStandPos - currentHRP.Position)
            local distToStandPos = moveDir.Magnitude
            
            if distToStandPos > 1 then
                currentHRP.AssemblyLinearVelocity = moveDir.Unit * AIMBOT_SPEED
            else
                currentHRP.AssemblyLinearVelocity = targetVelocity
            end
        else
            lockedTarget = nil
            currentHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            aimbotHighlight.Adornee = nil
        end
    end)
end

local function stopBatAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    
    local c = Player.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    
    if h then
        local att = h:FindFirstChild("AimbotAttachment")
        if att then att:Destroy() end
        
        local align = h:FindFirstChild("AimbotAlign")
        if
