local IMG_LOGO_TITLE = "rbxassetid://93349170559446"
local IMG_LOGO_NIEELS = "rbxassetid://93349170559446"

local LUCIDE_ICONS = {
    Close = "rbxassetid://10747384394",
    Minus = "rbxassetid://10734896206",
    Lock = "rbxassetid://10723434711",
    Unlock = "rbxassetid://10723434711",
}

local Library = {}
Library.Scheme = {}
Library.Scheme.AccentColor     = Color3.fromRGB(0, 255, 255)
Library.Scheme.BackgroundColor = Color3.fromRGB(8, 12, 20)
Library.Scheme.MainColor       = Color3.fromRGB(14, 20, 35)
Library.Scheme.OutlineColor    = Color3.fromRGB(0, 179, 255)
Library.Scheme.FontColor       = Color3.fromRGB(180, 239, 255)

local function applyGlowStroke(parent, color1, color2)
    pcall(function()
        if parent:IsA("UIStroke") then
            parent.Color = Color3.fromRGB(255, 255, 255)
        elseif parent:IsA("GuiObject") then
            parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, color1 or Library.Scheme.AccentColor),
        ColorSequenceKeypoint.new(1.00, color2 or Library.Scheme.MainColor)
    }
    gradient.Parent = parent
    local rotationSpeed = 120
    local runService = game:GetService("RunService")
    local connection
    connection = runService.Heartbeat:Connect(function(deltaTime)
        if gradient.Parent then
            gradient.Rotation = (gradient.Rotation + rotationSpeed * deltaTime) % 360
        else
            connection:Disconnect()
        end
    end)
    return gradient
end

local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local CoreGui=game:GetService("CoreGui")
local RS=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local WS=game:GetService("Workspace")
local VIM=game:GetService("VirtualInputManager")
local GuiService=game:GetService("GuiService")
local CollectionService=game:GetService("CollectionService")
local TweenService=game:GetService("TweenService")

while not Players.LocalPlayer do task.wait() end
local player = Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui")
local CAMERA = workspace.CurrentCamera
local KILLER_MARKER = "Lookscriptkiller"

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local LocalPlayer = player
local UserInputService = UIS
local PlayerGui = GUI
local LP = player
local LOCAL_PLAYER = player

local DEVELOPER_NAME = "rizky"

_G.NIEELS = _G.NIEELS or {}
_G.NIEELS.ScriptAlive = true
_G.NIEELS.SkipEndscreen = false

local StretchRes = { Enabled = false, Amount = 0.67, Conn = nil }

local function StartStretch()
    if StretchRes.Conn then return end
    StretchRes.Conn = RS.RenderStepped:Connect(function()
        if not StretchRes.Enabled then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        cam.CFrame = cam.CFrame * CFrame.new(0,0,0, 1,0,0, 0,StretchRes.Amount,0, 0,0,1)
    end)
end
local function StopStretch()
    if StretchRes.Conn then StretchRes.Conn:Disconnect(); StretchRes.Conn = nil end
end
local function SetStretchRes(enabled)
    StretchRes.Enabled = enabled
    if enabled then StartStretch() else StopStretch() end
end
local function SetStretchAmount(v) StretchRes.Amount = v end

local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera

local SkillCheckConfig = { Enabled = false, Mode = "Legit" }
local SkillCheckState = { busy = false, RandomMode_IsNormal = false }
local SkillCheckConn = nil

local function FindSkillCheckButton()
    local pg = LP:FindFirstChild("PlayerGui") or PlayerGui
    if not pg then return nil end
    local survivorMob = pg:FindFirstChild("Survivor-mob")
    if not survivorMob then return nil end
    local controls = survivorMob:FindFirstChild("Controls")
    if not controls then return nil end
    local action = controls:FindFirstChild("action")
    return action or controls:FindFirstChild("check")
end

local function PressSkillCheck()
    local btn = FindSkillCheckButton()
    if btn and btn:IsA("GuiObject") and btn.Visible and type(firesignal) == "function" then
        pcall(function()
            firesignal(btn.MouseButton1Down)
            task.wait(0.005)
            firesignal(btn.MouseButton1Up)
        end)
        return true
    end
    if btn and btn:IsA("GuiObject") and btn.Visible then
        pcall(function()
            local absPos = btn.AbsolutePosition
            local absSize = btn.AbsoluteSize
            local inset = GuiService:GetGuiInset()
            local touchId = 8822 + math.random(1, 9999)
            VirtualInputManager:SendTouchEvent(touchId, 0, absPos.X + absSize.X/2 + inset.X, absPos.Y + absSize.Y/2 + inset.Y)
            task.wait(0.005)
            VirtualInputManager:SendTouchEvent(touchId, 2, absPos.X + absSize.X/2 + inset.X, absPos.Y + absSize.Y/2 + inset.Y)
        end)
        return true
    end
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.005)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    return true
end

local function StopSkillCheckLoop()
    if SkillCheckConn then SkillCheckConn:Disconnect(); SkillCheckConn = nil end
end

local function StartSkillCheckLoop()
    StopSkillCheckLoop()
    SkillCheckConn = RS.Heartbeat:Connect(function()
        if not SkillCheckConfig.Enabled or SkillCheckState.busy then return end
        local pg = LP:FindFirstChild("PlayerGui") or PlayerGui
        if not pg then return end
        local prompt = pg:FindFirstChild("SkillCheckPromptGui")
        if not prompt then return end
        local check = prompt:FindFirstChild("Check")
        if not check or not check.Visible then SkillCheckState.RandomMode_IsNormal = false; return end
        local line = check:FindFirstChild("Line")
        local goal = check:FindFirstChild("Goal")
        if not line or not goal then return end
        local useInstant = SkillCheckConfig.Mode == "Instant"
        if not useInstant then
            useInstant = SkillCheckConfig.Mode == "Random"
            if useInstant then useInstant = not SkillCheckState.RandomMode_IsNormal end
        end
        if useInstant then
            line.Rotation = goal.Rotation + 109
            SkillCheckState.busy = true
            task.spawn(function() PressSkillCheck(); task.wait(0.05); SkillCheckState.busy = false end)
            return
        end
        local isNormal = SkillCheckConfig.Mode == "Normal"
            or (SkillCheckConfig.Mode == "Random" and SkillCheckState.RandomMode_IsNormal)
        local lineRot = line.Rotation % 360
        local goalRot = goal.Rotation % 360
        local minAngle, maxAngle
        if isNormal then
            minAngle = (goalRot + 116) % 360; maxAngle = (goalRot + 140) % 360
        else
            minAngle = (goalRot + 102) % 360; maxAngle = (goalRot + 116) % 360
        end
        local inZone
        if maxAngle < minAngle then inZone = (lineRot >= minAngle) or (lineRot <= maxAngle)
        else inZone = (lineRot >= minAngle) and (lineRot <= maxAngle) end
        if inZone then
            SkillCheckState.busy = true
            task.spawn(function() PressSkillCheck(); task.wait(0.05); SkillCheckState.busy = false end)
        end
    end)
end

local SkillCheck = {}
function SkillCheck.SetEnabled(state)
    SkillCheckConfig.Enabled = state and true or false
    if SkillCheckConfig.Enabled then StartSkillCheckLoop() else StopSkillCheckLoop() end
end
function SkillCheck.SetMode(mode)
    if mode == "Legit" or mode == "Instant" or mode == "Normal" or mode == "Random" then
        SkillCheckConfig.Mode = mode; SkillCheckState.RandomMode_IsNormal = false
    end
end
function SkillCheck.GetMode() return SkillCheckConfig.Mode end
function SkillCheck.IsEnabled() return SkillCheckConfig.Enabled end

LP.CharacterAdded:Connect(function()
    SkillCheckState.busy = false; SkillCheckState.RandomMode_IsNormal = false
    if SkillCheckConfig.Enabled then task.wait(1); StartSkillCheckLoop() end
end)

task.spawn(function()
    local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
    local killerPerks = remotes and remotes:WaitForChild("KillerPerks", 5)
    local kingscourge = killerPerks and killerPerks:WaitForChild("kingscourge", 5)
    local kingScourgeStart = kingscourge and kingscourge:WaitForChild("KingScourgeStart", 5)
    if kingScourgeStart then
        kingScourgeStart.OnClientEvent:Connect(function()
            if SkillCheckConfig.Mode == "Random" then SkillCheckState.RandomMode_IsNormal = true end
        end)
    end
end)

local ENUM_MOUSE = Enum.UserInputType.MouseButton1
local ENUM_TOUCH = Enum.UserInputType.Touch
local ENUM_MOVE = Enum.UserInputType.MouseMovement

local function create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    return obj
end

local AutoSelfHeal = { Enabled = false, Conn = nil, LoopThread = nil }

local function SetupHealAnimationBlocker()
    if AutoSelfHeal.Conn then
        pcall(function() AutoSelfHeal.Conn:Disconnect() end)
        AutoSelfHeal.Conn = nil
    end
    local character = LP.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end
    AutoSelfHeal.Conn = animator.AnimationPlayed:Connect(function(anim)
        if anim.Animation and tostring(anim.Animation.AnimationId):find("95836365038528") then
            anim:Stop(0)
        end
    end)
end

local function StartAutoSelfHealLoop()
    if AutoSelfHeal.LoopThread then return end
    AutoSelfHeal.LoopThread = task.spawn(function()
        while AutoSelfHeal.Enabled do
            task.wait(3)
            if not AutoSelfHeal.Enabled then break end
            if LP.Team and LP.Team.Name == "Killer" then continue end
            local character = LP.Character
            if character then
                local checkInterractable = character:FindFirstChild("CheckInterractable")
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local isBusy = false
                if checkInterractable and (checkInterractable:GetAttribute("isVaulting") or checkInterractable:GetAttribute("isRepairing") or checkInterractable:GetAttribute("isUnhooking") or checkInterractable:GetAttribute("isHealing") or checkInterractable:GetAttribute("isSliding")) then
                    isBusy = true
                end
                if not isBusy and humanoidRootPart and humanoid and humanoid.Health < humanoid.MaxHealth then
                    pcall(function()
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        if remotes and remotes:FindFirstChild("Healing") then
                            remotes.Healing.HealEvent:FireServer(humanoidRootPart, true)
                        end
                    end)
                end
            end
        end
        AutoSelfHeal.LoopThread = nil
    end)
end

local function StopAutoSelfHealLoop()
    if AutoSelfHeal.LoopThread then
        pcall(function() task.cancel(AutoSelfHeal.LoopThread) end)
        AutoSelfHeal.LoopThread = nil
    end
end

local function SetAutoSelfHeal(state)
    AutoSelfHeal.Enabled = state and true or false
    if AutoSelfHeal.Enabled then
        SetupHealAnimationBlocker()
        StartAutoSelfHealLoop()
    else
        StopAutoSelfHealLoop()
        if AutoSelfHeal.Conn then
            pcall(function() AutoSelfHeal.Conn:Disconnect() end)
            AutoSelfHeal.Conn = nil
        end
    end
end

LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    if AutoSelfHeal.Enabled then SetupHealAnimationBlocker(); StartAutoSelfHealLoop() end
end)

local InfiniteLunge = { Enabled = false }

local function EnableInfiniteLunge()
    InfiniteLunge.Enabled = true
    local c = LP.Character
    if c then c:SetAttribute("lungeboost", 999) end
end

local function DisableInfiniteLunge()
    InfiniteLunge.Enabled = false
    local c = LP.Character
    if c then c:SetAttribute("lungeboost", 1) end
end

local function SetInfiniteLunge(state)
    if state then EnableInfiniteLunge() else DisableInfiniteLunge() end
end

LP.CharacterAdded:Connect(function(nc)
    task.wait(0.8)
    if InfiniteLunge.Enabled and nc then nc:SetAttribute("lungeboost", 999) end
end)

local AttackAimbot = {
    Enabled = false,
    MaxDist = 12,
    Smoothness = 0.5,
    Holding = false,
    Target = nil,
}

local function AA_GetRole()
    if not LP.Team then return "Unknown" end
    local n = LP.Team.Name
    if n == "Killer" then return "Killer"
    elseif n == "Survivors" then return "Survivor"
    else return "Spectator" end
end

local function AA_IsDowned(char)
    if not char then return false end
    return char:GetAttribute("Knocked") == true or char:GetAttribute("IsHooked") == true
end

local function AA_GetDistance(pos)
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return math.huge end
    return (pos - root.Position).Magnitude
end

local function AA_GetBestTarget()
    local best = nil
    local myRole = AA_GetRole()
    local shortest3D = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local valid = false
            if myRole == "Killer" and AttackAimbot.Enabled and not (p.Team and p.Team.Name == "Killer") then
                local hum = p.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 and not AA_IsDowned(p.Character) then valid = true end
            end
            if valid then
                local hrp = p.Character.HumanoidRootPart
                local d3 = AA_GetDistance(hrp.Position)
                if myRole == "Killer" and d3 <= AttackAimbot.MaxDist then
                    if d3 < shortest3D then shortest3D = d3; best = hrp end
                end
            end
        end
    end
    return best
end

local AttackAimbotInputBeganConn = UIS.InputBegan:Connect(function(input, gp)
    local myRole = AA_GetRole()
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if gp then return end
        if myRole == "Killer" and AttackAimbot.Enabled then
            AttackAimbot.Target = AA_GetBestTarget()
            if AttackAimbot.Target then AttackAimbot.Holding = true end
        end
    end
end)

local AttackAimbotInputEndedConn = UIS.InputEnded:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        AttackAimbot.Holding = false
        AttackAimbot.Target = nil
    end
end)

local AttackAimbotRenderConn = RS.RenderStepped:Connect(function()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if AttackAimbot.Enabled and AttackAimbot.Holding then
        local myRole = AA_GetRole()
        if myRole == "Killer" and AttackAimbot.Target then
            local tc = AttackAimbot.Target.Parent
            local th = tc and tc:FindFirstChild("Humanoid")
            if not th or th.Health <= 0 or AA_IsDowned(tc) then
                AttackAimbot.Target = AA_GetBestTarget()
            end
            if AttackAimbot.Target then
                local tp = AttackAimbot.Target.Position
                if AA_GetDistance(tp) > AttackAimbot.MaxDist then
                    AttackAimbot.Target = AA_GetBestTarget()
                else
                    local cam = workspace.CurrentCamera
                    if not cam then return end
                    local g = CFrame.new(cam.CFrame.Position, tp)
                    cam.CFrame = cam.CFrame:Lerp(g, AttackAimbot.Smoothness)
                    local gh = CFrame.new(hrp.Position, Vector3.new(tp.X, hrp.Position.Y, tp.Z))
                    hrp.CFrame = hrp.CFrame:Lerp(gh, AttackAimbot.Smoothness)
                end
            end
        end
    end
end)

local SilentAimFlask = { Enabled = false, ShowLaser = true, LaserPart = nil, Thread = nil }

local _flaskPlayerCache = {}
local _flaskPlayerCacheTime = 0

local function _RefreshFlaskPlayerCache()
    _flaskPlayerCache = Players:GetPlayers()
    _flaskPlayerCacheTime = tick()
end
_RefreshFlaskPlayerCache()
Players.PlayerAdded:Connect(_RefreshFlaskPlayerCache)
Players.PlayerRemoving:Connect(_RefreshFlaskPlayerCache)

local function _GetFlaskPlayers()
    if tick() - _flaskPlayerCacheTime > 1 then _RefreshFlaskPlayerCache() end
    return _flaskPlayerCache
end

local function UpdateCureFlaskLaser()
    local char = LP.Character
    if not char then return end
    local targetPos, originPos, closest, minDst = nil, nil, nil, math.huge
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local hand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
        originPos = hand and hand.Position or hrp.Position
        for _, v in pairs(_GetFlaskPlayers()) do
            if v ~= LP
            and v.Character and v.Character:FindFirstChild("HumanoidRootPart")
            and not v.Character:GetAttribute("IsKiller") then
                local dst = (v.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dst < minDst then minDst = dst; closest = v end
            end
        end
    end
    if closest then
        targetPos = closest.Character.HumanoidRootPart.Position
    end
    local actionActive = false
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("LocalScript") and child:GetAttribute("action") == true then
            actionActive = true
            break
        end
    end
    if originPos and targetPos and actionActive then
        if not SilentAimFlask.LaserPart then
            local l = Instance.new("Part")
            l.Name = "FlaskSilentAimLaser"
            l.Anchored = true
            l.CanCollide = false
            l.CanTouch = false
            l.CastShadow = false
            l.Material = Enum.Material.Neon
            l.Color = Color3.fromRGB(255, 50, 50)
            l.Transparency = 0
            l.Parent = workspace
            SilentAimFlask.LaserPart = l
        end
        local dist = (targetPos - originPos).Magnitude
        if dist > 0.1 then
            local l = SilentAimFlask.LaserPart
            l.Size = Vector3.new(0.16, 0.16, dist)
            l.CFrame = CFrame.new((originPos + targetPos) / 2, targetPos)
            l.Transparency = 0
        end
    else
        if SilentAimFlask.LaserPart then
            SilentAimFlask.LaserPart.Transparency = 1
        end
    end
end

local function ClearFlaskLaser()
    if SilentAimFlask.LaserPart then
        pcall(function() SilentAimFlask.LaserPart:Destroy() end)
        SilentAimFlask.LaserPart = nil
    end
end

local function StartCureFlaskLaser()
    if SilentAimFlask.Thread then return end
    local counter = 0
    SilentAimFlask.Thread = RS.RenderStepped:Connect(function()
        counter = counter + 1
        if counter % 2 ~= 0 then return end
        if not SilentAimFlask.Enabled or not SilentAimFlask.ShowLaser then
            ClearFlaskLaser()
            return
        end
        pcall(UpdateCureFlaskLaser)
    end)
end

local function StopCureFlaskLaser()
    if SilentAimFlask.Thread then
        pcall(function() SilentAimFlask.Thread:Disconnect() end)
        SilentAimFlask.Thread = nil
    end
    ClearFlaskLaser()
end

local function SetSilentAimFlask(state)
    SilentAimFlask.Enabled = state and true or false
    if SilentAimFlask.Enabled then
        StartCureFlaskLaser()
    else
        StopCureFlaskLaser()
    end
end

local function SetFlaskLaserVisible(state)
    SilentAimFlask.ShowLaser = state and true or false
    if not SilentAimFlask.ShowLaser then ClearFlaskLaser() end
end

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if SilentAimFlask.Enabled then StartCureFlaskLaser() end
end)

local InfoPlayer = {
    HitSoundEnabled = false,
    HitSoundVolume = 1.0,
    HitSoundId = "rbxassetid://119974879573475",
    HitSoundCooldown = 0.3,
    HitSoundLastTime = 0,
    WatermarkEnabled = true,
    WatermarkConn = nil,
    WatermarkGui = nil,
    WatermarkLabel = nil,
    NextKillerEnabled = false,
    NextKillerGui = nil,
    MapPredictEnabled = false,
    MapPredictGui = nil,
    SpectatorEnabled = false,
    SpectatorGui = nil,
    SpectatorLabel = nil,
    KillerPerksEnabled = false,
    KillerPerksGui = nil,
    KillerPerksMinimized = false,
    StunEnabled = false,
    _hitSoundCache = nil,
    _playerCache = {},
    _playerCacheTime = 0,
}

local WorldEffect = {
    FullBrightEnabled = false,
    CleanSkyEnabled = false,
    NoShadowEnabled = false,
    NoScreenEffectsEnabled = false,
    LowGraphicsEnabled = false,
    NoFogEnabled = false,
    TimeOfDayValue = 14,
    OriginalVisual = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        GlobalShadows = Lighting.GlobalShadows,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        FogColor = Lighting.FogColor,
    },
    DisabledEffects = {},
    LoopThread = nil,
    ChildAddedConn = nil,
    DescendantAddedConn = nil,
    DestroyedSkies = {},
}

local WATERMARK_WIDTH = 200

local function _RefreshInfoPlayerCache()
    InfoPlayer._playerCache = Players:GetPlayers()
    InfoPlayer._playerCacheTime = tick()
end
_RefreshInfoPlayerCache()
Players.PlayerAdded:Connect(_RefreshInfoPlayerCache)
Players.PlayerRemoving:Connect(_RefreshInfoPlayerCache)

local function _GetInfoPlayers()
    if tick() - InfoPlayer._playerCacheTime > 1 then _RefreshInfoPlayerCache() end
    return InfoPlayer._playerCache
end

local function Info_IsKiller(p)
    return p and p.Team and p.Team.Name == "Killer"
end

local function PlayHitSound()
    if not InfoPlayer.HitSoundEnabled then return end
    local now = tick()
    if now - InfoPlayer.HitSoundLastTime < InfoPlayer.HitSoundCooldown then return end
    InfoPlayer.HitSoundLastTime = now
    pcall(function()
        if not InfoPlayer._hitSoundCache or not InfoPlayer._hitSoundCache.Parent then
            InfoPlayer._hitSoundCache = Instance.new("Sound")
            InfoPlayer._hitSoundCache.SoundId = InfoPlayer.HitSoundId
            InfoPlayer._hitSoundCache.Parent = workspace.CurrentCamera or workspace
        end
        InfoPlayer._hitSoundCache.Volume = InfoPlayer.HitSoundVolume
        InfoPlayer._hitSoundCache:Play()
    end)
end

local function SetHitSoundEnabled(state)
    InfoPlayer.HitSoundEnabled = state and true or false
end

local function CreateWatermark()
    if InfoPlayer.WatermarkGui then InfoPlayer.WatermarkGui:Destroy() end
    local sg = Instance.new("ScreenGui")
    sg.Name = "NIEELS_Watermark"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
    local ok = pcall(function() sg.Parent = CoreGui end)
    if not ok then sg.Parent = LP:WaitForChild("PlayerGui") end
    InfoPlayer.WatermarkGui = sg

    local frame = Instance.new("Frame", sg)
    frame.Name = "Frame"
    frame.Size = UDim2.new(0, WATERMARK_WIDTH, 0, 26)
    frame.Position = UDim2.new(0.5, -WATERMARK_WIDTH/2, 0, 8)
    frame.BackgroundColor3 = Library.Scheme.MainColor
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Library.Scheme.OutlineColor
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    applyGlowStroke(stroke, Library.Scheme.AccentColor, Library.Scheme.MainColor)

    local logo = Instance.new("ImageLabel", frame)
    logo.Size = UDim2.new(0, 20, 0, 20)
    logo.Position = UDim2.new(0, 4, 0.5, -10)
    logo.BackgroundTransparency = 1
    logo.Image = IMG_LOGO_NIEELS
    logo.ImageColor3 = Library.Scheme.FontColor
    logo.ScaleType = Enum.ScaleType.Fit

    InfoPlayer.WatermarkLabel = Instance.new("TextLabel", frame)
    InfoPlayer.WatermarkLabel.Size = UDim2.new(1, -30, 1, 0)
    InfoPlayer.WatermarkLabel.Position = UDim2.new(0, 26, 0, 0)
    InfoPlayer.WatermarkLabel.BackgroundTransparency = 1
    InfoPlayer.WatermarkLabel.Font = Enum.Font.Code
    InfoPlayer.WatermarkLabel.TextSize = 11
    InfoPlayer.WatermarkLabel.TextColor3 = Library.Scheme.FontColor
    InfoPlayer.WatermarkLabel.Text = "NIEELS"
    InfoPlayer.WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left

    local dragging, dragStart, startPos = false, nil, nil
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function StartWatermark()
    if InfoPlayer.WatermarkConn then InfoPlayer.WatermarkConn:Disconnect(); InfoPlayer.WatermarkConn = nil end
    CreateWatermark()
    if not InfoPlayer.WatermarkGui then return end
    local frame = InfoPlayer.WatermarkGui:FindFirstChild("Frame")
    if frame then frame.Visible = true end

    local FrameTimer = tick()
    local FrameCounter = 0
    local FPS = 60
    InfoPlayer.WatermarkConn = RS.Heartbeat:Connect(function()
        if not InfoPlayer.WatermarkEnabled then
            if InfoPlayer.WatermarkConn then InfoPlayer.WatermarkConn:Disconnect(); InfoPlayer.WatermarkConn = nil end
            if InfoPlayer.WatermarkGui then local f = InfoPlayer.WatermarkGui:FindFirstChild("Frame") if f then f.Visible = false end end
            return
        end
        FrameCounter = FrameCounter + 1
        if (tick() - FrameTimer) >= 1 then
            FPS = FrameCounter
            FrameTimer = tick()
            FrameCounter = 0
        end
        local ping = 0
        pcall(function()
            ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() or 0)
        end)
        if InfoPlayer.WatermarkLabel then
            InfoPlayer.WatermarkLabel.Text = ("NIEELS | %s fps | %s ms"):format(math.floor(FPS), ping)
        end
    end)
end

local function SetWatermarkEnabled(state)
    InfoPlayer.WatermarkEnabled = state and true or false
    if state then StartWatermark()
    else
        if InfoPlayer.WatermarkConn then InfoPlayer.WatermarkConn:Disconnect(); InfoPlayer.WatermarkConn = nil end
        if InfoPlayer.WatermarkGui then InfoPlayer.WatermarkGui:Destroy(); InfoPlayer.WatermarkGui = nil end
    end
end

local function CreateNextKiller()
    if InfoPlayer.NextKillerGui then InfoPlayer.NextKillerGui:Destroy() end
    local sg = Instance.new("ScreenGui")
    sg.Name = "NIEELS_NextKiller"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
    local ok = pcall(function() sg.Parent = CoreGui end)
    if not ok then sg.Parent = LP:WaitForChild("PlayerGui") end
    InfoPlayer.NextKillerGui = sg

    local frame = Instance.new("Frame", sg)
    frame.Name = "Frame"
    frame.Size = UDim2.new(0, WATERMARK_WIDTH, 0, 26)
    frame.Position = UDim2.new(0.5, -WATERMARK_WIDTH/2, 0, 40)
    frame.BackgroundColor3 = Library.Scheme.MainColor
    frame.BorderSizePixel = 0
    frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Library.Scheme.OutlineColor
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    applyGlowStroke(stroke, Library.Scheme.AccentColor, Library.Scheme.MainColor)

    local logo = Instance.new("ImageLabel", frame)
    logo.Size = UDim2.new(0, 20, 0, 20)
    logo.Position = UDim2.new(0, 4, 0.5, -10)
    logo.BackgroundTransparency = 1
    logo.Image = IMG_LOGO_NIEELS
    logo.ImageColor3 = Library.Scheme.AccentColor
    logo.ScaleType = Enum.ScaleType.Fit

    local label = Instance.new("TextLabel", frame)
    label.Name = "NextKillerDisplay"
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 26, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = 11
    label.TextColor3 = Library.Scheme.FontColor
    label.Text = "Next: ..."
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.RichText = true

    local dragging, dragStart, startPos = false, nil, nil
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    task.spawn(function()
        while InfoPlayer.NextKillerEnabled and InfoPlayer.NextKillerGui do
            local f = InfoPlayer.NextKillerGui:FindFirstChild("Frame")
            if f then
                local lbl = f:FindFirstChild("NextKillerDisplay")
                if lbl then
                    local pl = Players:GetPlayers()
                    table.sort(pl, function(a, b)
                        local aA = a:GetAttribute("AllowKiller") or false
                        local bA = b:GetAttribute("AllowKiller") or false
                        if aA ~= bA then return aA end
                        return (a:GetAttribute("KillerChance") or 0) > (b:GetAttribute("KillerChance") or 0)
                    end)
                    local nk = pl[1]
                    if nk then
                        local name = (nk == LocalPlayer) and "<font color='#ff5555'>YOU</font>" or nk.Name
                        lbl.Text = "Next: " .. name
                    else
                        lbl.Text = "Next: <font color='#888888'>Waiting...</font>"
                    end
                end
            end
            task.wait(1.5)
        end
    end)
end

local function SetNextKillerEnabled(state)
    InfoPlayer.NextKillerEnabled = state and true or false
    if state then CreateNextKiller()
    else
        if InfoPlayer.NextKillerGui then InfoPlayer.NextKillerGui:Destroy(); InfoPlayer.NextKillerGui = nil end
    end
end

local function detectMap()
    local m = workspace:FindFirstChild("Map")
    if not m then return nil end
    if m:FindFirstChild("random shakes") or m:FindFirstChild("SCP-173 Room") or m:FindFirstChild("SCP-205 Room") then return "Site 68"
    elseif m:FindFirstChild("HooksMeat") then return "BLOODBATH! Club"
    elseif m:FindFirstChild("Gate") and m.Gate:FindFirstChild("vfx") then return "Firelink Shrine"
    elseif m:FindFirstChild("Bldg_Addon_RooftopUnit_A") or m:FindFirstChild("Rooftop") then return "Mercy Hospital Rooftop"
    elseif m:FindFirstChild("White Armored Car") then return "Mount Massive Asylum"
    elseif m:FindFirstChild("Dumbster") then return "The Bay Harbor"
    elseif m:FindFirstChild("water pump") then return "Valdelobos Village"
    elseif m:FindFirstChild("LargeBoulder01") then return "Woodview Cabin" end
    return nil
end

local function CreateMapPredict()
    if InfoPlayer.MapPredictGui then InfoPlayer.MapPredictGui:Destroy() end
    local sg = Instance.new("ScreenGui")
    sg.Name = "NIEELS_MapPredict"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
    local ok = pcall(function() sg.Parent = CoreGui end)
    if not ok then sg.Parent = LP:WaitForChild("PlayerGui") end
    InfoPlayer.MapPredictGui = sg

    local frame = Instance.new("Frame", sg)
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, WATERMARK_WIDTH, 0, 26)
    frame.Position = UDim2.new(0.5, -WATERMARK_WIDTH/2, 0, 72)
    frame.BackgroundColor3 = Library.Scheme.MainColor
    frame.BorderSizePixel = 0
    frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Library.Scheme.OutlineColor
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    applyGlowStroke(stroke, Library.Scheme.AccentColor, Library.Scheme.MainColor)

    local logo = Instance.new("ImageLabel", frame)
    logo.Size = UDim2.new(0, 20, 0, 20)
    logo.Position = UDim2.new(0, 4, 0.5, -10)
    logo.BackgroundTransparency = 1
    logo.Image = IMG_LOGO_NIEELS
    logo.ImageColor3 = Library.Scheme.AccentColor
    logo.ScaleType = Enum.ScaleType.Fit

    local label = Instance.new("TextLabel", frame)
    label.Name = "MapLabel"
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 26, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = 11
    label.TextColor3 = Library.Scheme.FontColor
    label.Text = "Map: ..."
    label.TextXAlignment = Enum.TextXAlignment.Left

    local dragging, dragStart, startPos = false, nil, nil
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    task.spawn(function()
        local lastMap = nil
        while InfoPlayer.MapPredictEnabled and InfoPlayer.MapPredictGui do
            local g = InfoPlayer.MapPredictGui
            if g then
                local mf = g:FindFirstChild("MainFrame")
                if mf then
                    local lbl = mf:FindFirstChild("MapLabel")
                    if lbl then
                        local det = detectMap()
                        if det then
                            lastMap = det
                            lbl.Text = "Map: " .. det
                            lbl.TextColor3 = Color3.fromRGB(100, 255, 100)
                        else
                            if lastMap then
                                lbl.Text = "Map: " .. lastMap
                                lbl.TextColor3 = Color3.fromRGB(255, 200, 50)
                            else
                                lbl.Text = "Map: Unknown"
                                lbl.TextColor3 = Library.Scheme.FontColor
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

local function SetMapPredictEnabled(state)
    InfoPlayer.MapPredictEnabled = state and true or false
    if state then CreateMapPredict()
    else
        if InfoPlayer.MapPredictGui then InfoPlayer.MapPredictGui:Destroy(); InfoPlayer.MapPredictGui = nil end
    end
end

local function CreateSpectator()
    if InfoPlayer.SpectatorGui then InfoPlayer.SpectatorGui:Destroy() end
    InfoPlayer.SpectatorGui = nil
    InfoPlayer.SpectatorLabel = nil
end

local function SetSpectatorEnabled(state)
    InfoPlayer.SpectatorEnabled = state and true or false
    if state then
        CreateSpectator()
        task.spawn(function()
            while InfoPlayer.SpectatorEnabled do
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local existing = hrp:FindFirstChild("NIEELS_SpectatorBillboard")
                    if existing then existing:Destroy() end

                    local bill = Instance.new("BillboardGui")
                    bill.Name = "NIEELS_SpectatorBillboard"
                    bill.Adornee = hrp
                    bill.AlwaysOnTop = true
                    bill.Size = UDim2.new(0, 80, 0, 22)
                    bill.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
                    bill.ResetOnSpawn = false
                    bill.Parent = hrp

                    local frame = Instance.new("Frame", bill)
                    frame.Name = "MainBox"
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundColor3 = Library.Scheme.MainColor
                    frame.BorderSizePixel = 0
                    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

                    local stroke = Instance.new("UIStroke", frame)
                    stroke.Color = Library.Scheme.OutlineColor
                    stroke.Thickness = 1
                    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    applyGlowStroke(stroke, Library.Scheme.AccentColor, Library.Scheme.MainColor)

                    local layout = Instance.new("UIListLayout", frame)
                    layout.FillDirection = Enum.FillDirection.Horizontal
                    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    layout.VerticalAlignment = Enum.VerticalAlignment.Center
                    layout.Padding = UDim.new(0, 4)

                    local padding = Instance.new("UIPadding", frame)
                    padding.PaddingLeft = UDim.new(0, 6)
                    padding.PaddingRight = UDim.new(0, 6)

                    local icon = Instance.new("ImageLabel", frame)
                    icon.Name = "Icon"
                    icon.Size = UDim2.new(0, 12, 0, 12)
                    icon.BackgroundTransparency = 1
                    icon.Image = "rbxassetid://13321848320"
                    icon.ImageColor3 = Library.Scheme.AccentColor
                    icon.ScaleType = Enum.ScaleType.Fit

                    local label = Instance.new("TextLabel", frame)
                    label.Name = "CountLabel"
                    label.BackgroundTransparency = 1
                    label.Font = Enum.Font.Code
                    label.Text = "0"
                    label.TextColor3 = Library.Scheme.FontColor
                    label.TextSize = 11
                    label.AutomaticSize = Enum.AutomaticSize.X

                    local function UpdateCount()
                        local count = 0
                        for _, p in ipairs(Players:GetPlayers()) do
                            local teamName = nil
                            pcall(function() teamName = p.Team and p.Team.Name end)
                            if teamName and (teamName == "Spectator" or teamName == "Spectators") then
                                count = count + 1
                            elseif p.Team == nil then
                                if p:GetAttribute("IsSpectator") == true then count = count + 1 end
                            end
                        end
                        if label then label.Text = tostring(count) end
                    end
                    UpdateCount()
                    InfoPlayer.SpectatorGui = bill
                    InfoPlayer.SpectatorLabel = label

                    local updateConn
                    updateConn = task.spawn(function()
                        while InfoPlayer.SpectatorEnabled and bill and bill.Parent do
                            UpdateCount()
                            task.wait(1)
                        end
                    end)

                    while InfoPlayer.SpectatorEnabled do
                        local c = LP.Character
                        local newHrp = c and c:FindFirstChild("HumanoidRootPart")
                        if not newHrp or newHrp ~= hrp then break end
                        task.wait(0.5)
                    end
                    if bill and bill.Parent then bill:Destroy() end
                    InfoPlayer.SpectatorGui = nil
                    InfoPlayer.SpectatorLabel = nil
                else
                    task.wait(0.5)
                end
            end
        end)
    else
        if InfoPlayer.SpectatorGui then
            pcall(function() InfoPlayer.SpectatorGui:Destroy() end)
            InfoPlayer.SpectatorGui = nil
        end
        InfoPlayer.SpectatorLabel = nil
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local existing = hrp:FindFirstChild("NIEELS_SpectatorBillboard")
            if existing then existing:Destroy() end
        end
    end
end

local function CreateKillerPerks()
    if InfoPlayer.KillerPerksGui then pcall(function() InfoPlayer.KillerPerksGui:Destroy() end); InfoPlayer.KillerPerksGui = nil end
    InfoPlayer.KillerPerksMinimized = false

    local function esc(t)
        t = tostring(t or "")
        t = t:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
        return t
    end
    local function parsePerk(name)
        name = tostring(name or "")
        local pn, lvl = name:match("^(.+)%s+(%d+)$")
        if not pn then return nil end
        pn = pn:gsub("^%s+", ""):gsub("%s+$", "")
        if pn == "" then return nil end
        local ex = { head=true, torso=true, humanoid=true, humanoidrootpart=true, ["left arm"]=true, ["right arm"]=true, ["left leg"]=true, ["right leg"]=true }
        if ex[pn:lower()] then return nil end
        return pn, lvl
    end
    local function getKiller()
        for _, plr in ipairs(_GetInfoPlayers()) do
            local tn = plr.Team and plr.Team.Name
            if tn and tn:lower():find("killer") then return plr end
        end
        return nil
    end
    local function readPerks(k)
        if not k then return {} end
        local c = k.Character or workspace:FindFirstChild(k.Name) or workspace:FindFirstChild(k.DisplayName)
        if not c then return {} end
        local r, seen = {}, {}
        for _, ch in ipairs(c:GetChildren()) do
            local pn, lvl = parsePerk(ch.Name)
            if pn and not seen[pn] then seen[pn] = true; table.insert(r, {Name=pn, Level=lvl}) end
        end
        table.sort(r, function(a,b) return tostring(a.Name) < tostring(b.Name) end)
        return r
    end
    local function buildText()
        local k = getKiller()
        local kn = k and (k.DisplayName or k.Name) or "Unknown"
        local perks = readPerks(k)
        if #perks == 0 then
            for _, plr in ipairs(_GetInfoPlayers()) do
                local cand = readPerks(plr)
                if #cand > 0 then k = plr; kn = plr.DisplayName or plr.Name; perks = cand; break end
            end
        end
        local lines = { 'Killer [<font color="rgb(0,255,255)">' .. esc(kn) .. '</font>]' }
        if #perks == 0 then
            table.insert(lines, '<font color="rgb(180,239,255)">- Waiting...</font>')
        else
            for i = 1, math.min(#perks, 3) do
                local p = perks[i]
                local lv = p.Level and (" lvl " .. tostring(p.Level)) or ""
                table.insert(lines, '<font color="rgb(180,239,255)">- ' .. esc(p.Name .. lv) .. '</font>')
            end
        end
        return table.concat(lines, "\n"), #perks
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "NIEELS_KillerPerks"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
    local ok = pcall(function() sg.Parent = CoreGui end)
    if not ok then sg.Parent = LP:WaitForChild("PlayerGui") end

    local holder = Instance.new("Frame", sg)
    holder.Name = "Holder"
    holder.Size = UDim2.new(0, WATERMARK_WIDTH, 0, 75)
    holder.Position = UDim2.new(0, 8, 0, 150)
    holder.BackgroundColor3 = Library.Scheme.MainColor
    holder.BorderSizePixel = 0
    holder.Active = true
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", holder)
    stroke.Color = Library.Scheme.OutlineColor
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    applyGlowStroke(stroke, Library.Scheme.AccentColor, Library.Scheme.MainColor)

    local header = Instance.new("Frame", holder)
    header.Size = UDim2.new(1, 0, 0, 22)
    header.BackgroundColor3 = Library.Scheme.BackgroundColor
    header.BorderSizePixel = 0
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 6, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Code
    title.Text = "Perks Info"
    title.TextColor3 = Library.Scheme.AccentColor
    title.TextSize = 10
    title.TextXAlignment = Enum.TextXAlignment.Left

    local function makeButton(text, x)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 24, 0, 14)
        btn.Position = UDim2.new(1, x, 0, 4)
        btn.BackgroundColor3 = Library.Scheme.BackgroundColor
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Code
        btn.Text = text
        btn.TextColor3 = Library.Scheme.FontColor
        btn.TextSize = 8
        btn.Parent = header
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
        local s = Instance.new("UIStroke", btn)
        s.Color = Library.Scheme.OutlineColor
        s.Thickness = 1
        return btn
    end

    local minBtn = makeButton("Min", -52)
    local closeBtn = makeButton("X", -26)

    local label = Instance.new("TextLabel", holder)
    label.Name = "KillerPerksText"
    label.Size = UDim2.new(1, -12, 1, -26)
    label.Position = UDim2.new(0, 6, 0, 24)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.RichText = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextColor3 = Library.Scheme.FontColor
    label.TextSize = 10
    label.TextWrapped = true

    minBtn.MouseButton1Click:Connect(function()
        InfoPlayer.KillerPerksMinimized = not InfoPlayer.KillerPerksMinimized
        label.Visible = not InfoPlayer.KillerPerksMinimized
        minBtn.Text = InfoPlayer.KillerPerksMinimized and "Sh" or "Min"
        holder.Size = InfoPlayer.KillerPerksMinimized and UDim2.new(0, WATERMARK_WIDTH, 0, 22) or UDim2.new(0, WATERMARK_WIDTH, 0, 75)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        InfoPlayer.KillerPerksEnabled = false
        if InfoPlayer.KillerPerksGui then pcall(function() InfoPlayer.KillerPerksGui:Destroy() end); InfoPlayer.KillerPerksGui = nil end
    end)

    local dragging, dragStart, startPos = false, nil, nil
    holder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = holder.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    holder.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    InfoPlayer.KillerPerksGui = sg
    task.spawn(function()
        while InfoPlayer.KillerPerksEnabled and InfoPlayer.KillerPerksGui do
            if not InfoPlayer.KillerPerksMinimized then
                local text, count = buildText()
                label.Text = text
                local rows = math.max(2, math.min(count + 1, 4))
                holder.Size = UDim2.new(0, WATERMARK_WIDTH, 0, math.max(60, 26 + rows * 14))
            end
            task.wait(2)
        end
    end)
end

local function SetKillerPerksEnabled(state)
    InfoPlayer.KillerPerksEnabled = state and true or false
    if state then CreateKillerPerks()
    else
        if InfoPlayer.KillerPerksGui then InfoPlayer.KillerPerksGui:Destroy(); InfoPlayer.KillerPerksGui = nil end
    end
end

local StunData = {}

local function SetupStun(char)
    if not char or StunData[char] then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local old = hrp:FindFirstChild("StunUI"); if old then old:Destroy() end

    local bill = Instance.new("BillboardGui")
    bill.Name = "StunUI"
    bill.Adornee = hrp
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 90, 0, 14)
    bill.StudsOffsetWorldSpace = Vector3.new(0, 4.5, 0)
    bill.ResetOnSpawn = false
    bill.Parent = hrp
    bill.Enabled = false

    local frame = Instance.new("Frame", bill)
    frame.Name = "Frame"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Library.Scheme.MainColor
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)

    local uiStroke = Instance.new("UIStroke", frame)
    uiStroke.Name = "UIStroke"
    uiStroke.Color = Library.Scheme.OutlineColor
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.LineJoinMode = Enum.LineJoinMode.Round
    applyGlowStroke(uiStroke, Library.Scheme.AccentColor, Library.Scheme.MainColor)

    local icon = Instance.new("ImageLabel", frame)
    icon.Size = UDim2.new(0, 10, 0, 10)
    icon.Position = UDim2.new(0, 3, 0.5, -5)
    icon.BackgroundTransparency = 1
    icon.Image = IMG_LOGO_NIEELS
    icon.ImageColor3 = Library.Scheme.FontColor
    icon.ScaleType = Enum.ScaleType.Fit

    local label = Instance.new("TextLabel", frame)
    label.Name = "Label"
    label.Size = UDim2.new(1, -18, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = 9
    label.TextColor3 = Library.Scheme.FontColor
    label.Text = "STUN"
    label.TextXAlignment = Enum.TextXAlignment.Left

    local fillBg = Instance.new("Frame", frame)
    fillBg.Size = UDim2.new(1, -6, 0, 2)
    fillBg.Position = UDim2.new(0, 3, 1, -3)
    fillBg.BackgroundColor3 = Library.Scheme.BackgroundColor
    fillBg.BorderSizePixel = 0
    Instance.new("UICorner", fillBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", fillBg)
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = Library.Scheme.AccentColor
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    StunData[char] = { bill = bill, fill = fill, timer = nil, duration = 2.2, startTime = 0 }

    local function OnStun()
        PlayHitSound()
        local data = StunData[char]
        if not data then return end
        data.bill.Enabled = true
        data.duration = 2.2
        data.startTime = tick()
        if data.timer then task.cancel(data.timer) end
        data.timer = task.spawn(function()
            while data.bill and data.bill.Enabled do
                local elapsed = tick() - data.startTime
                local progress = 1 - (elapsed / data.duration)
                if progress <= 0 then data.bill.Enabled = false; break end
                data.fill.Size = UDim2.new(progress, 0, 1, 0)
                if progress > 0.5 then data.fill.BackgroundColor3 = Library.Scheme.AccentColor
                elseif progress > 0.2 then data.fill.BackgroundColor3 = Color3.fromRGB(0, 179, 255)
                else data.fill.BackgroundColor3 = Color3.fromRGB(139, 0, 0) end
                task.wait(0.05)
            end
        end)
    end

    char:GetAttributeChangedSignal("IsStunned"):Connect(function()
        if char:GetAttribute("IsStunned") == true then OnStun() end
    end)
    char:GetAttributeChangedSignal("Immobile"):Connect(function()
        if char:GetAttribute("Immobile") == true then OnStun() end
    end)
end

local function SetupAllStun()
    if not InfoPlayer.StunEnabled then return end
    for _, p in ipairs(_GetInfoPlayers()) do
        if Info_IsKiller(p) and p.Character then SetupStun(p.Character) end
    end
end

local function SetStunEnabled(state)
    InfoPlayer.StunEnabled = state and true or false
    if state then
        SetupAllStun()
    else
        for char, data in pairs(StunData) do
            if data.bill then data.bill:Destroy() end
            if data.timer then task.cancel(data.timer) end
        end
        StunData = {}
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(c)
        if InfoPlayer.StunEnabled and Info_IsKiller(plr) then
            task.wait(0.5); SetupStun(c)
        end
    end)
    if plr.Character and InfoPlayer.StunEnabled and Info_IsKiller(plr) then SetupStun(plr.Character) end
end)

local function World_ApplyFullBright()
    if WorldEffect.FullBrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = WorldEffect.TimeOfDayValue
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
    else
        Lighting.Brightness = WorldEffect.OriginalVisual.Brightness
        Lighting.ClockTime = WorldEffect.OriginalVisual.ClockTime
        Lighting.Ambient = WorldEffect.OriginalVisual.Ambient
        Lighting.OutdoorAmbient = WorldEffect.OriginalVisual.OutdoorAmbient
    end
end

local function World_ApplyNoFog()
    if not WorldEffect.NoFogEnabled then return end
    pcall(function()
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
        Lighting.FogColor = Color3.fromRGB(255,255,255)
        local at = Lighting:FindFirstChildOfClass("Atmosphere")
        if at then
            at.Density = 0
            at.Offset = 0
            at.Glare = 0
            at.Haze = 0
        end
    end)
end

local function World_ApplyNoShadow()
    if WorldEffect.NoShadowEnabled then
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = WorldEffect.OriginalVisual.GlobalShadows
    end
end

local function World_ApplyLowGraphics()
    if not WorldEffect.LowGraphicsEnabled then return end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

local function World_ApplyNoScreenEffects()
    if not WorldEffect.NoScreenEffectsEnabled then return end
    local ScreenEffectTypes = {
        "ColorCorrectionEffect", "DepthOfFieldEffect",
        "BlurEffect", "SunRaysEffect", "BloomEffect"
    }
    for _, v in pairs(Lighting:GetChildren()) do
        for _, t in pairs(ScreenEffectTypes) do
            if v:IsA(t) then
                WorldEffect.DisabledEffects[v] = v.Enabled
                v.Enabled = false
            end
        end
    end
end

local function World_ApplyCleanSky()
    if not WorldEffect.CleanSkyEnabled then return end
    pcall(function()
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Sky") then
                WorldEffect.DestroyedSkies[obj] = true
                obj:Destroy()
            end
        end
    end)
end

local function World_ApplyAll()
    pcall(function() World_ApplyFullBright() end)
    pcall(function() World_ApplyNoFog() end)
    pcall(function() World_ApplyNoShadow() end)
    pcall(function() World_ApplyLowGraphics() end)
    pcall(function() World_ApplyNoScreenEffects() end)
    pcall(function() World_ApplyCleanSky() end)
end

local function World_RestoreAll()
    pcall(function()
        Lighting.Brightness = WorldEffect.OriginalVisual.Brightness
        Lighting.ClockTime = WorldEffect.OriginalVisual.ClockTime
        Lighting.Ambient = WorldEffect.OriginalVisual.Ambient
        Lighting.OutdoorAmbient = WorldEffect.OriginalVisual.OutdoorAmbient
        Lighting.GlobalShadows = WorldEffect.OriginalVisual.GlobalShadows
        Lighting.FogStart = WorldEffect.OriginalVisual.FogStart
        Lighting.FogEnd = WorldEffect.OriginalVisual.FogEnd
        Lighting.FogColor = WorldEffect.OriginalVisual.FogColor
    end)
    pcall(function()
        for effect, origEnabled in pairs(WorldEffect.DisabledEffects) do
            if effect and effect.Parent then
                effect.Enabled = origEnabled
            end
        end
        WorldEffect.DisabledEffects = {}
    end)
end

local function World_StartLoop()
    if WorldEffect.LoopThread then return end
    WorldEffect.LoopThread = task.spawn(function()
        while true do
            task.wait(0.25)
            local anyEnabled = WorldEffect.FullBrightEnabled or WorldEffect.NoFogEnabled
                or WorldEffect.NoShadowEnabled or WorldEffect.LowGraphicsEnabled
                or WorldEffect.NoScreenEffectsEnabled or WorldEffect.CleanSkyEnabled
            if not anyEnabled then
                WorldEffect.LoopThread = nil
                return
            end
            pcall(function() World_ApplyAll() end)
        end
    end)
end

local function World_StopLoop()
    if WorldEffect.LoopThread then
        pcall(function() task.cancel(WorldEffect.LoopThread) end)
        WorldEffect.LoopThread = nil
    end
end

local function World_SetupListeners()
    if WorldEffect.ChildAddedConn then
        pcall(function() WorldEffect.ChildAddedConn:Disconnect() end)
        WorldEffect.ChildAddedConn = nil
    end
    if WorldEffect.DescendantAddedConn then
        pcall(function() WorldEffect.DescendantAddedConn:Disconnect() end)
        WorldEffect.DescendantAddedConn = nil
    end

    WorldEffect.ChildAddedConn = Lighting.ChildAdded:Connect(function(child)
        if child:IsA("Sky") or child:IsA("Atmosphere") then
            task.wait(0.1)
            if WorldEffect.FullBrightEnabled then pcall(World_ApplyFullBright) end
            if WorldEffect.NoFogEnabled then pcall(World_ApplyNoFog) end
            if WorldEffect.CleanSkyEnabled then pcall(World_ApplyCleanSky) end
        end
        if WorldEffect.NoScreenEffectsEnabled then
            task.wait(0.1)
            pcall(World_ApplyNoScreenEffects)
        end
    end)

    WorldEffect.DescendantAddedConn = Lighting.DescendantAdded:Connect(function(child)
        if child:IsA("Sky") or child:IsA("Atmosphere") then
            task.wait(0.1)
            if WorldEffect.FullBrightEnabled then pcall(World_ApplyFullBright) end
            if WorldEffect.NoFogEnabled then pcall(World_ApplyNoFog) end
            if WorldEffect.CleanSkyEnabled then pcall(World_ApplyCleanSky) end
        end
        if WorldEffect.NoScreenEffectsEnabled then
            task.wait(0.1)
            pcall(World_ApplyNoScreenEffects)
        end
    end)
end

local function SetWorldFullBright(state)
    WorldEffect.FullBrightEnabled = state and true or false
    if state then World_ApplyFullBright() else World_ApplyFullBright() end
    World_StartLoop()
end

local function SetWorldCleanSky(state)
    WorldEffect.CleanSkyEnabled = state and true or false
    if state then World_ApplyCleanSky() end
    World_StartLoop()
end

local function SetWorldNoShadow(state)
    WorldEffect.NoShadowEnabled = state and true or false
    World_ApplyNoShadow()
    World_StartLoop()
end

local function SetWorldNoScreenEffects(state)
    WorldEffect.NoScreenEffectsEnabled = state and true or false
    if state then
        World_ApplyNoScreenEffects()
        World_SetupListeners()
    else
        for effect, origEnabled in pairs(WorldEffect.DisabledEffects) do
            if effect and effect.Parent then effect.Enabled = origEnabled end
        end
        WorldEffect.DisabledEffects = {}
    end
    World_StartLoop()
end

local function SetWorldLowGraphics(state)
    WorldEffect.LowGraphicsEnabled = state and true or false
    if state then World_ApplyLowGraphics() end
    World_StartLoop()
end

local function SetWorldNoFog(state)
    WorldEffect.NoFogEnabled = state and true or false
    if state then World_ApplyNoFog() else
        pcall(function()
            Lighting.FogStart = WorldEffect.OriginalVisual.FogStart
            Lighting.FogEnd = WorldEffect.OriginalVisual.FogEnd
            Lighting.FogColor = WorldEffect.OriginalVisual.FogColor
        end)
    end
    World_StartLoop()
end

World_SetupListeners()

local Moonwalk = {
    Enabled = false, GuiVisible = false, Gui = nil,
    IsActive = false, InputConn = nil,
}

local function StartMoonwalk()
    local character = LP.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoidRootPart or not humanoid then return end
    humanoid.AutoRotate = false
    Moonwalk.Enabled = true
end

local function StopMoonwalk()
    Moonwalk.Enabled = false
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.AutoRotate = true end
end

local function UpdateMoonwalkGUI(isOn)
    if not Moonwalk.Gui then return end
    local frame = Moonwalk.Gui:FindFirstChild("Frame")
    if not frame then return end
    local actionButton = frame:FindFirstChild("ActionButton")
    if not actionButton then return end
    if isOn then
        actionButton.Text = "MOON [ON]"
        actionButton.TextColor3 = Library.Scheme.AccentColor
    else
        actionButton.Text = "MOON [OFF]"
        actionButton.TextColor3 = Library.Scheme.FontColor
    end
end

local function ToggleMoonwalkStatus()
    if Moonwalk.Enabled then StopMoonwalk() else StartMoonwalk() end
    Moonwalk.IsActive = Moonwalk.Enabled
    UpdateMoonwalkGUI(Moonwalk.Enabled)
end

local function CreateMoonwalkGUI()
    if Moonwalk.InputConn then Moonwalk.InputConn:Disconnect(); Moonwalk.InputConn = nil end
    if Moonwalk.Gui then Moonwalk.Gui:Destroy(); Moonwalk.Gui = nil end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MoonwalkCustomGui"; screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui; screenGui.Enabled = false
    Moonwalk.Gui = screenGui; Moonwalk.GuiVisible = false
    local frame = Instance.new("Frame", screenGui)
    frame.Name = "Frame"
    frame.Size = UDim2.fromOffset(110, 36)
    frame.Position = UDim2.fromScale(0.85, 0.45)
    frame.BackgroundColor3 = Library.Scheme.MainColor
    frame.BackgroundTransparency = 0
    frame.Active = true; frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)
    local uiStroke = Instance.new("UIStroke", frame)
    uiStroke.Name = "UIStroke"
    uiStroke.Color = Library.Scheme.OutlineColor
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.LineJoinMode = Enum.LineJoinMode.Round
    applyGlowStroke(uiStroke, Library.Scheme.AccentColor, Library.Scheme.MainColor)
    local textButton = Instance.new("TextButton", frame)
    textButton.Name = "ActionButton"
    textButton.Size = UDim2.new(1, 0, 1, 0)
    textButton.Text = "MOON [OFF]"
    textButton.BackgroundTransparency = 1
    textButton.Font = Enum.Font.Code
    textButton.TextSize = 12
    textButton.TextColor3 = Library.Scheme.FontColor
    textButton.BorderSizePixel = 0
    textButton.AutoButtonColor = true
    Instance.new("UICorner", textButton).CornerRadius = UDim.new(1, 0)
    local isDown = false
    local isDragging = false
    local dragHoldDelay = false
    local startPos = nil
    local frameStartPos = nil
    local holdThread = nil
    local function onDrag(input)
        if not isDown or not dragHoldDelay or not startPos or not frameStartPos then return end
        local delta = input.Position - startPos
        if not isDragging and (math.abs(delta.X) > 18 or math.abs(delta.Y) > 18) then isDragging = true end
        if isDragging then
            frame.Position = UDim2.new(
                frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y
            )
        end
    end
    textButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            isDown = true; isDragging = false; dragHoldDelay = false
            startPos = input.Position; frameStartPos = frame.Position
            if holdThread then task.cancel(holdThread) end
            holdThread = task.delay(0.18, function() if isDown then dragHoldDelay = true end end)
        end
    end)
    textButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if holdThread then task.cancel(holdThread) end
            if isDown and not isDragging then ToggleMoonwalkStatus() end
            isDown = false; isDragging = false; dragHoldDelay = false
            startPos = nil; frameStartPos = nil
        end
    end)
    Moonwalk.InputConn = UserInputService.InputChanged:Connect(function(input)
        if isDown and dragHoldDelay
            and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            onDrag(input)
        end
    end)
end

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if Moonwalk.Enabled then StartMoonwalk() end
    if Moonwalk.GuiVisible and Moonwalk.Gui then
        Moonwalk.Gui.Enabled = true
        UpdateMoonwalkGUI(Moonwalk.Enabled)
    end
end)

local MoonwalkRenderConn = RS.RenderStepped:Connect(function(deltaTime)
    if not Moonwalk.Enabled then return end
    local character = LP.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local camera = workspace.CurrentCamera
    if not humanoidRootPart or not humanoid or not camera then return end
    if humanoid.AutoRotate ~= false then humanoid.AutoRotate = false end
    local lookRaw = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
    local rightRaw = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
    local look = lookRaw.Magnitude > 0.001 and lookRaw.Unit or Vector3.zero
    local right = rightRaw.Magnitude > 0.001 and rightRaw.Unit or Vector3.zero
    local sway = math.sin(tick() * 35)
    local faceDir = CFrame.Angles(0, math.rad(30 * sway), 0) * look
    humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + faceDir)
    humanoid:Move(-look * 1.2 + right * (sway * 1.05), false)
end)

task.spawn(function() task.wait(1.5); CreateMoonwalkGUI() end)

getgenv().MoonwalkAPI = {
    ShowGUI = function()
        if not Moonwalk.Gui then CreateMoonwalkGUI() end
        Moonwalk.Gui.Enabled = true; Moonwalk.GuiVisible = true
        UpdateMoonwalkGUI(Moonwalk.Enabled)
    end,
    HideGUI = function()
        if Moonwalk.Gui then Moonwalk.Gui.Enabled = false; Moonwalk.GuiVisible = false end
    end,
    Toggle = function() ToggleMoonwalkStatus() end,
    Enable = function() StartMoonwalk(); UpdateMoonwalkGUI(true) end,
    Disable = function() StopMoonwalk(); UpdateMoonwalkGUI(false) end,
}

local AutoDodgeCrouch = false
local DodgeThread = nil
local currentAbyssalAnimationTrack = nil

local function isAbyssalwalkerSkillActive()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return false end
    for _, playerObj in ipairs(Players:GetPlayers()) do
        if playerObj.Team and playerObj.Team.Name == "Killer" and playerObj.Character then
            local killerHRP = playerObj.Character:FindFirstChild("HumanoidRootPart")
            if not killerHRP then continue end
            local distance = (myHRP.Position - killerHRP.Position).Magnitude
            if distance > 25 then continue end
            local humanoid = playerObj.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        if track.Animation and track.Animation.AnimationId == "rbxassetid://80411309607666" then
                            local timeLeft = track.Length - track.TimePosition
                            if timeLeft <= 1.5 then currentAbyssalAnimationTrack = nil; return false end
                            currentAbyssalAnimationTrack = track; return true
                        end
                    end
                end
            end
        end
    end
    currentAbyssalAnimationTrack = nil
    return false
end

local function getCrouchBtn()
    local b = LP:FindFirstChild("PlayerGui")
    for segment in string.gmatch("Survivor-mob.Controls.crouch.icon", "[^%.]+") do
        if b then b = b:FindFirstChild(segment) end
    end
    if b and b:IsA("GuiObject") and b.Visible and b.Parent and b.Parent:IsA("GuiButton") then return b.Parent end
    return nil
end

local function fireCrouch(state)
    if isMobile then
        local btn = getCrouchBtn()
        if btn then pcall(function() firesignal(btn.MouseButton1Click) end) end
    else
        if state then VIM:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        else VIM:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game) end
    end
end

local function StartAutoDodgeCrouch()
    if DodgeThread then return end
    DodgeThread = task.spawn(function()
        local isCrouching = false
        while AutoDodgeCrouch do
            local skillActive = isAbyssalwalkerSkillActive()
            if skillActive and not isCrouching then isCrouching = true; fireCrouch(true)
            elseif not skillActive and isCrouching then isCrouching = false; fireCrouch(false) end
            task.wait(0.05)
        end
        if isCrouching then fireCrouch(false) end
    end)
end

local function StopAutoDodgeCrouch()
    if DodgeThread then task.cancel(DodgeThread); DodgeThread = nil end
end

local NotifGui = nil
local NotifStack = {}
local NOTIF_WIDTH = 207
local NOTIF_HEIGHT = 47
local NOTIF_GAP = 6
local NOTIF_TOP_OFFSET = 60
local NOTIF_RIGHT_OFFSET = 15
local NOTIF_LOGO_SIZE = 31

local function GetNotifGui()
    if NotifGui and NotifGui.Parent then return NotifGui end
    local sg = CoreGui:FindFirstChild("NIEELS_NotifyGui")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "NIEELS_NotifyGui"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local ok = pcall(function() sg.Parent = CoreGui end)
        if not ok then sg.Parent = LP:WaitForChild("PlayerGui") end
    end
    NotifGui = sg
    return sg
end

local function RepositionNotifs()
    local y = NOTIF_TOP_OFFSET
    for i, frame in ipairs(NotifStack) do
        if frame and frame.Parent then
            frame.Position = UDim2.new(1, -(NOTIF_WIDTH + NOTIF_RIGHT_OFFSET), 0, y)
            y = y + NOTIF_HEIGHT + NOTIF_GAP
        end
    end
end

local function NIEELS_Notify(title, text, duration)
    duration = duration or 2
    pcall(function()
        local sg = GetNotifGui()
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, NOTIF_WIDTH, 0, NOTIF_HEIGHT)
        frame.Position = UDim2.new(1, -(NOTIF_WIDTH + NOTIF_RIGHT_OFFSET), 0, NOTIF_TOP_OFFSET)
        frame.BackgroundColor3 = Color3.fromRGB(25, 20, 35); frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0; frame.Parent = sg
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Library.Scheme.AccentColor; stroke.Thickness = 1.0; stroke.Transparency = 1
        applyGlowStroke(stroke, Library.Scheme.AccentColor, Library.Scheme.BackgroundColor)
        local logo = Instance.new("ImageLabel", frame)
        logo.Size = UDim2.new(0, NOTIF_LOGO_SIZE, 0, NOTIF_LOGO_SIZE)
        logo.Position = UDim2.new(0, 9, 0.5, -(NOTIF_LOGO_SIZE / 2))
        logo.BackgroundTransparency = 1; logo.Image = IMG_LOGO_NIEELS
        logo.ImageColor3 = Library.Scheme.FontColor; logo.ScaleType = Enum.ScaleType.Fit
        logo.ZIndex = 2; logo.ImageTransparency = 1
        local t = Instance.new("TextLabel", frame)
        t.Size = UDim2.new(1, -(NOTIF_LOGO_SIZE + 18), 0, 18)
        t.Position = UDim2.new(0, NOTIF_LOGO_SIZE + 13, 0, 4)
        t.BackgroundTransparency = 1; t.Text = title
        t.TextColor3 = Library.Scheme.AccentColor; t.Font = Enum.Font.Code; t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left; t.TextTransparency = 1; t.ZIndex = 2
        local b = Instance.new("TextLabel", frame)
        b.Size = UDim2.new(1, -(NOTIF_LOGO_SIZE + 18), 0, 18)
        b.Position = UDim2.new(0, NOTIF_LOGO_SIZE + 13, 0, 22)
        b.BackgroundTransparency = 1; b.Text = text
        b.TextColor3 = Library.Scheme.FontColor; b.Font = Enum.Font.Code; b.TextSize = 11
        b.TextXAlignment = Enum.TextXAlignment.Left; b.TextTransparency = 1; b.ZIndex = 2
        table.insert(NotifStack, 1, frame)
        RepositionNotifs()
        local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(frame, info, { BackgroundTransparency = 0 }):Play()
        TweenService:Create(stroke, info, { Transparency = 0 }):Play()
        TweenService:Create(logo, info, { ImageTransparency = 0 }):Play()
        TweenService:Create(t, info, { TextTransparency = 0 }):Play()
        TweenService:Create(b, info, { TextTransparency = 0 }):Play()
        task.delay(duration, function()
            if frame and frame.Parent then
                local out = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                TweenService:Create(frame, out, { BackgroundTransparency = 1 }):Play()
                TweenService:Create(stroke, out, { Transparency = 1 }):Play()
                TweenService:Create(logo, out, { ImageTransparency = 1 }):Play()
                TweenService:Create(t, out, { TextTransparency = 1 }):Play()
                TweenService:Create(b, out, { TextTransparency = 1 }):Play()
                task.wait(0.28)
                for i, f in ipairs(NotifStack) do
                    if f == frame then table.remove(NotifStack, i); break end
                end
                if frame and frame.Parent then frame:Destroy() end
                RepositionNotifs()
            end
        end)
    end)
end

local LowGraphicConfig = { Enabled = false, Loop = nil, Conns = {} }

local function killEffects(container)
    for _, fx in ipairs(container:GetChildren()) do
        pcall(function()
            if fx:IsA("BloomEffect") or fx:IsA("BlurEffect") or fx:IsA("SunRaysEffect")
            or fx:IsA("DepthOfFieldEffect") or fx:IsA("ColorCorrectionEffect") or fx:IsA("Clouds") then
                fx.Enabled = false
            elseif fx:IsA("Atmosphere") then fx.Density = 0; fx.Haze = 0; fx.Glare = 0 end
        end)
    end
end

local function applyPotato()
    if not LowGraphicConfig.Enabled then return end
    pcall(function() if setfpscap then setfpscap(999) end end)
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function() settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01 end)
    pcall(function() UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1 end)
    Lighting.GlobalShadows = false
    pcall(function() Lighting.ShadowSoftness = 0 end)
    Lighting.FogEnd = 1e6; Lighting.FogStart = 1e6
    killEffects(Lighting)
    pcall(function()
        local t = Workspace:FindFirstChildOfClass("Terrain")
        if t then
            t.Decoration = false; t.WaterWaveSize = 0; t.WaterWaveSpeed = 0
            t.WaterReflectance = 0; t.WaterTransparency = 1
        end
    end)
    pcall(function() LP:SetAttribute("lowGraphics", true) end)
end

local function EnableLowGraphic()
    if LowGraphicConfig.Enabled then return end
    LowGraphicConfig.Enabled = true
    applyPotato()
    table.insert(LowGraphicConfig.Conns, Lighting.ChildAdded:Connect(function(child)
        if not LowGraphicConfig.Enabled then return end
        task.defer(function()
            if child:IsA("BloomEffect") or child:IsA("BlurEffect") or child:IsA("SunRaysEffect")
            or child:IsA("DepthOfFieldEffect") or child:IsA("ColorCorrectionEffect") or child:IsA("Clouds") then
                child.Enabled = false
            elseif child:IsA("Atmosphere") then child.Density = 0; child.Haze = 0; child.Glare = 0 end
        end)
    end))
    table.insert(LowGraphicConfig.Conns, Workspace.DescendantAdded:Connect(function(obj)
        if not LowGraphicConfig.Enabled then return end
        if obj:IsA("BasePart") and obj.CastShadow then
            local map = Workspace:FindFirstChild("Map")
            if map and obj:IsDescendantOf(map) then obj.CastShadow = false end
        end
    end))
    table.insert(LowGraphicConfig.Conns, LP.CharacterAdded:Connect(function()
        task.wait(1); if LowGraphicConfig.Enabled then applyPotato() end
    end))
end

local function DisableLowGraphic()
    LowGraphicConfig.Enabled = false
    if LowGraphicConfig.Loop then pcall(function() task.cancel(LowGraphicConfig.Loop) end); LowGraphicConfig.Loop = nil end
    for _, conn in ipairs(LowGraphicConfig.Conns) do pcall(function() conn:Disconnect() end) end
    LowGraphicConfig.Conns = {}
end

local tbl6 = { [25]=true,[17]=true,[30]=true,[67.8]=true,[2]=true,[4]=true,[0.25]=true,[70]=true,[0.65]=true }
local tbl7 = {[1]=true,[10]=true}
local var53
local killerNoCDFlag = false
local var54, _activeKillerT = nil, 0

local function fn6()
    local now = tick()
    if now - _activeKillerT < 2 and var54 ~= nil then return var54 end
    local var55 = nil
    pcall(function()
        local var56 = LP:GetAttribute("SelectedKiller")
        local name = tostring(var56 or ""):lower()
        if name:find("hidden") then var55 = "hidden"
        elseif name:find("mayers") or name:find("stalker") or name:find("michael") then var55 = "mayers" end
        if not var55 then
            local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
            local var57 = ReplicatedStorage2:FindFirstChild("Remotes") and ReplicatedStorage2.Remotes:FindFirstChild("Killers")
            if var57 then
                if var57:FindFirstChild("Stalker") then var55 = "mayers"
                elseif var57:FindFirstChild("Hidden") then var55 = "hidden" end
            end
        end
    end)
    var54, _activeKillerT = var55, now
    return var55
end

local function fn7()
    if var53 then return end
    if not hookfunction then NIEELS_Notify("No Cooldown", "Executor tidak support hookfunction", 2.0); return end
    local var59, err = pcall(function()
        local var58 = newcclosure or function(arg4) return arg4 end
        var53 = hookfunction(task.delay, var58(function(delayTime, callback)
            if not var53 then return task.delay and task.delay(0, callback) or task.spawn(callback) end
            if not killerNoCDFlag then return var53(delayTime, callback) end
            if tbl6[delayTime] then return var53(0, callback) end
            if tbl7[delayTime] and fn6() == "mayers" then return var53(0, callback) end
            return var53(delayTime, callback)
        end))
    end)
    if not var59 then NIEELS_Notify("No Cooldown", "Gagal hook task.delay: " .. tostring(err), 2.0); var53 = nil end
end

local function fn8()
    if var53 then
        if restorefunction then pcall(restorefunction, task.delay) end
        var53 = nil
    end
end

local GetNearestSurvivorForMayers, StartMayersMobileHook, StopMayersMobileHook
do
    local tbl2_list19 = {}
    local tbl2_list20 = {}
    local tbl2_connection27, tbl2_connection28
    local tbl2_flag160 = false
    local tbl2_flag162 = false

    function GetNearestSurvivorForMayers(maxDist)
        maxDist = maxDist or 5
        local char = LP.Character
        local var65 = char and char:FindFirstChild("HumanoidRootPart")
        if not var65 then return nil, math.huge end
        local var66, var67 = nil, maxDist + 0.01
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LP and v.Character then
                local humanoidRootPart = v.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = v.Character:FindFirstChildOfClass("Humanoid")
                if humanoidRootPart and humanoid and humanoid.Health > 0 then
                    local magnitude = (humanoidRootPart.Position - var65.Position).Magnitude
                    if magnitude < var67 then var66, var67 = v.Character, magnitude end
                end
            end
        end
        return var66, var67
    end

    local function var64()
        if not (tbl2_flag160 or killerNoCDFlag) then return end
        if fn6() ~= "mayers" then return end
        if tbl2_flag162 then return end
        local char = LP.Character
        if not char then return end
        local humanoidRootPart2 = char:FindFirstChild("HumanoidRootPart")
        local humanoid2 = char:FindFirstChildOfClass("Humanoid")
        if not (humanoidRootPart2 and humanoid2 and humanoid2.Health > 0) then return end
        tbl2_flag162 = true
        task.delay(0.35, function() tbl2_flag162 = false end)
        local var68 = nil
        pcall(function()
            local animation = Instance.new("Animation")
            animation.AnimationId = "rbxassetid://77477445889320"
            local var69 = humanoid2:FindFirstChildOfClass("Animator") or humanoid2
            var68 = var69:LoadAnimation(animation)
            var68.Priority = Enum.AnimationPriority.Action
            var68:Play()
        end)
        local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
        pcall(function() ReplicatedStorage3.Remotes.SoundPlayer:FireServer("132736711620405", humanoidRootPart2, 0.3, 70) end)
        pcall(function() ReplicatedStorage3.Remotes.Attacks.BasicAttack:FireServer(true) end)
        pcall(function()
            local var70 = ReplicatedStorage3:FindFirstChild("Remotes") and ReplicatedStorage3.Remotes:FindFirstChild("Killers") and ReplicatedStorage3.Remotes.Killers:FindFirstChild("Stalker") and ReplicatedStorage3.Remotes.Killers.Stalker:FindFirstChild("ConsumeReady")
            if var70 then var70:FireServer() end
        end)
        task.spawn(function()
            local now2 = tick()
            local flag2 = false
            while tick() - now2 < 2 and not flag2 do
                RunService.Heartbeat:Wait()
                local target, dist = GetNearestSurvivorForMayers(5)
                if target and dist <= 5 then
                    pcall(function()
                        local grab = ReplicatedStorage3.Remotes.Killers.Stalker:FindFirstChild("grab")
                        if grab then grab:FireServer(target) end
                    end)
                    if var68 then pcall(function() var68:Stop(0.1) end) end
                    flag2 = true; break
                end
            end
            if var68 then pcall(function() var68:Stop(0.1) end) end
        end)
    end

    local function fn11(arg6)
        if not (arg6 and arg6:IsA("GuiButton")) then return false end
        if arg6.Name ~= "move2" then return false end
        local parent = arg6.Parent
        if not (parent and parent.Name == "Controls") then return false end
        local parent2 = parent.Parent
        if not (parent2 and parent2.Name == "Slasher-mob") then return false end
        return true
    end

    local function fn12(arg7)
        if not tbl2_flag160 then return end
        if fn6() ~= "mayers" then return end
        if not fn11(arg7) then return end
        if tbl2_list20[arg7] then return end
        tbl2_list20[arg7] = true
        pcall(function() arg7.Active = true end)
        local connection = arg7.Activated:Connect(function()
            if not tbl2_flag160 then return end
            pcall(var64)
        end)
        table.insert(tbl2_list19, connection)
    end

    local function fn13()
        if not tbl2_flag160 then return end
        if fn6() ~= "mayers" then return end
        local var74 = LP:FindFirstChildOfClass("PlayerGui") or playerGui
        if not var74 then return end
        pcall(function()
            local slasherMob = var74:FindFirstChild("Slasher-mob")
            if slasherMob then
                local controls = slasherMob:FindFirstChild("Controls")
                if controls then
                    local move2 = controls:FindFirstChild("move2")
                    if move2 then fn12(move2) end
                    for _, v3 in ipairs(controls:GetDescendants()) do
                        if v3.Name == "move2" then fn12(v3) end
                    end
                end
            end
        end)
        if tbl2_connection28 then pcall(function() tbl2_connection28:Disconnect() end) end
        tbl2_connection28 = var74.ChildAdded:Connect(function(arg8)
            if arg8.Name == "Slasher-mob" then
                task.wait(0.5); fn13()
                if tbl2_connection27 then pcall(function() tbl2_connection27:Disconnect() end) end
                tbl2_connection27 = arg8.DescendantAdded:Connect(function(arg9)
                    if arg9.Name == "move2" then fn12(arg9) end
                end)
                table.insert(tbl2_list19, tbl2_connection27)
            end
        end)
        table.insert(tbl2_list19, tbl2_connection28)
    end

    function StartMayersMobileHook() tbl2_flag160 = true; fn13() end
    function StopMayersMobileHook()
        tbl2_flag160 = false
        for _, v4 in ipairs(tbl2_list19) do pcall(function() v4:Disconnect() end) end
        tbl2_list19 = {}; tbl2_list20 = {}
        if tbl2_connection28 then pcall(function() tbl2_connection28:Disconnect() end) tbl2_connection28 = nil end
        if tbl2_connection27 then pcall(function() tbl2_connection27:Disconnect() end) tbl2_connection27 = nil end
    end
end

local ESP={_enabled=false,_loop=nil,_survivorColor=Color3.fromRGB(255,255,255),_killerColor=Color3.fromRGB(255,0,0),_tag="PlayerESP",_txtTag="PlayerESP_Txt",_cache={}}
local function IsKiller(p)
    if not p.Character then return false end
    return p.Character:FindFirstChild(KILLER_MARKER,true)~=nil
end
local function ShouldESP(p) return p~=LP and p.Character~=nil end
local function MakeESP(o,p)
    if not o then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = o:FindFirstChild("HumanoidRootPart")
    local dist = (root and targetRoot) and (root.Position - targetRoot.Position).Magnitude or 9999
    if dist > 250 then
        local ex=o:FindFirstChild(ESP._tag); local ext=o:FindFirstChild(ESP._txtTag)
        if ex then ex:Destroy() end; if ext then ext:Destroy() end
        return
    end
    local isDown = false
    local hum = o:FindFirstChildOfClass("Humanoid")
    if hum then
        isDown = hum.Health <= 0 or hum.Health < 2 or o:GetAttribute("Downed") == true
            or o:GetAttribute("IsDown") == true or o:GetAttribute("Knocked") == true
    end
    local col = IsKiller(p) and ESP._killerColor or ESP._survivorColor
    if isDown then col = Color3.fromRGB(255, 0, 0) end
    local displayText = p.Name
    if isDown then displayText = "🔻 DOWN\n" .. p.Name end
    displayText = displayText .. string.format("\n[%.0fm]", dist)
    local ex=o:FindFirstChild(ESP._tag); local ext=o:FindFirstChild(ESP._txtTag)
    if ex then
        ex.OutlineColor=col
        if ext then
            local txt=ext:FindFirstChildOfClass("TextLabel")
            if txt then txt.TextColor3=col; txt.Text=displayText end
        end
        return
    end
    local hl=Instance.new("Highlight",o)
    hl.Name=ESP._tag; hl.FillTransparency=1; hl.OutlineColor=col; hl.OutlineTransparency=0
    local bb=Instance.new("BillboardGui",o)
    bb.Name=ESP._txtTag; bb.Size=UDim2.new(0,140,0,60); bb.AlwaysOnTop=true; bb.StudsOffset=Vector3.new(0,4.2,0)
    local t=Instance.new("TextLabel",bb)
    t.Name="NameLabel"; t.Size=UDim2.new(1,0,1,0); t.BackgroundTransparency=1; t.Text=displayText; t.TextColor3=col
    t.Font=Enum.Font.Code; t.TextSize=10; t.TextStrokeTransparency=0.3
    table.insert(ESP._cache, hl); table.insert(ESP._cache, bb)
end

local function ClearESP()
    for _, v in ipairs(ESP._cache) do if v and v.Parent then v:Destroy() end end
    table.clear(ESP._cache)
end

function ESP:Start()
    if self._loop then self._loop:Disconnect(); self._loop=nil end
    local lastUpdate = 0
    self._loop=RS.Heartbeat:Connect(function()
        if not self._enabled then return end
        local now = tick()
        if now - lastUpdate < 0.2 then return end
        lastUpdate = now
        for _,p in pairs(Players:GetPlayers()) do if ShouldESP(p) then MakeESP(p.Character,p) end end
    end)
    self._enabled=true
end
function ESP:Stop()
    if self._loop then self._loop:Disconnect(); self._loop=nil end
    ClearESP(); self._enabled=false
end
function ESP:Toggle(s)
    if s==nil then s=not self._enabled end
    if s then self:Start() else self:Stop() end
    return self._enabled
end

local GeneratorESPConfig = { Enabled = false, BaseColor = Color3.fromRGB(255, 170, 0), DoneColor = Color3.fromRGB(0, 255, 120) }
local CachedGenerators = {}

local function GetGameValue(obj, name)
    if not obj then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    local child = obj:FindFirstChild(name)
    if child then
        local success, val = pcall(function() return child.Value end)
        if success then return val end
    end
    return nil
end

local function ApplyGenHighlight(object, color)
    local h = object:FindFirstChild("GenHighlight") or Instance.new("Highlight")
    h.Name = "GenHighlight"; h.Adornee = object; h.FillColor = color; h.OutlineColor = color
    h.FillTransparency = 0.9; h.OutlineTransparency = 0; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
end

local function CreateBillboard(text, color)
    local bb = Instance.new("BillboardGui")
    bb.Name = "GenESP"; bb.Size = UDim2.new(0, 100, 0, 30); bb.AlwaysOnTop = true
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = color
    l.TextStrokeTransparency = 0; l.Font = Enum.Font.Code; l.TextSize = 13; l.Parent = bb
    return bb
end

local function UpdateGenerator(generator)
    if not generator or not generator.Parent then return end
    if not GeneratorESPConfig.Enabled then
        local ob = generator:FindFirstChild("GenESP"); if ob then ob:Destroy() end
        local oh = generator:FindFirstChild("GenHighlight"); if oh then oh:Destroy() end
        return
    end
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local dist = 9999
    if myRoot then
        if generator:IsA("Model") then
            local cf, _ = generator:GetBoundingBox()
            dist = (myRoot.Position - cf.Position).Magnitude
        elseif generator:IsA("BasePart") then
            dist = (myRoot.Position - generator.Position).Magnitude
        end
    end
    if dist > 250 then
        local ob = generator:FindFirstChild("GenESP"); if ob then ob:Destroy() end
        local oh = generator:FindFirstChild("GenHighlight"); if oh then oh:Destroy() end
        return
    end
    local percent = GetGameValue(generator, "RepairProgress") or GetGameValue(generator, "Progress") or 0
    local billboard = generator:FindFirstChild("GenESP")
    local highlight = generator:FindFirstChild("GenHighlight")
    if percent >= 100 then
        if billboard then billboard:Destroy() end
        if highlight then highlight:Destroy() end
        return
    end
    local cp = math.clamp(percent, 0, 100)
    local cc = GeneratorESPConfig.BaseColor:Lerp(GeneratorESPConfig.DoneColor, cp / 100)
    local text = string.format("Gen %.0f%%", percent)
    if not billboard then
        billboard = CreateBillboard(text, cc); billboard.Adornee = generator; billboard.Parent = generator
    else
        local lbl = billboard:FindFirstChildOfClass("TextLabel")
        if lbl then lbl.Text = text; lbl.TextColor3 = cc end
    end
    ApplyGenHighlight(generator, cc)
end

local function cacheObject(obj) if obj.Name == "Generator" then CachedGenerators[obj] = true end end
local function removeCache(obj) if CachedGenerators[obj] then CachedGenerators[obj] = nil end end
for _, obj in ipairs(WS:GetDescendants()) do cacheObject(obj) end
WS.DescendantAdded:Connect(cacheObject)
WS.DescendantRemoving:Connect(removeCache)

local genEspLastUpdate = 0
local GEN_ESP_INTERVAL = 0.5
RS.Heartbeat:Connect(function()
    local now = tick()
    if now - genEspLastUpdate < GEN_ESP_INTERVAL then return end
    genEspLastUpdate = now
    if GeneratorESPConfig.Enabled then
        for gen in pairs(CachedGenerators) do UpdateGenerator(gen) end
    end
end)

local AutoStalk = { Enabled = false, StalkRange = 150 }
local StalkerConnection = nil

local function getRoot() return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") end

local function getClosestSurvivorForStalk()
    local root = getRoot(); if not root then return nil end
    local closest, shortest = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 30 then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist <= AutoStalk.StalkRange and dist < shortest then shortest = dist; closest = plr end
            end
        end
    end
    return closest
end

local function startAutoStalk()
    if StalkerConnection then return end
    StalkerConnection = RS.Heartbeat:Connect(function()
        if not AutoStalk.Enabled then return end
        local target = getClosestSurvivorForStalk()
        if not target or not target.Character then return end
        local se = ReplicatedStorage:FindFirstChild("Remotes", true)
            and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
            and ReplicatedStorage.Remotes.Killers:FindFirstChild("Stalker", true)
            and ReplicatedStorage.Remotes.Killers.Stalker:FindFirstChild("StartStalking")
        if se then pcall(function() se:FireServer(target) end) end
    end)
end

local function stopAutoStalk()
    AutoStalk.Enabled = false
    if StalkerConnection then StalkerConnection:Disconnect(); StalkerConnection = nil end
end

local StalkerGUI = nil
local StalkerButton = nil

local function GetNearest()
    local c = LP.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local h = c.HumanoidRootPart
    local n, nd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (h.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < nd then nd = d; n = p end
        end
    end
    return n
end

local function CreateStalker()
    if StalkerGUI then StalkerGUI:Destroy() end
    StalkerGUI = Instance.new("ScreenGui"); StalkerGUI.Name = "rizssky_StalkerGUI"
    StalkerGUI.ResetOnSpawn = false; StalkerGUI.IgnoreGuiInset = true
    local ok = pcall(function() StalkerGUI.Parent = CoreGui end)
    if not ok then StalkerGUI.Parent = LP:WaitForChild("PlayerGui") end
    StalkerButton = Instance.new("ImageButton"); StalkerButton.Name = "StalkerGrabButton"
    StalkerButton.Size = UDim2.new(0, 45, 0, 45); StalkerButton.Position = UDim2.new(0.68, 0, 0.88, 0)
    StalkerButton.AnchorPoint = Vector2.new(0.5, 0.5); StalkerButton.BackgroundColor3 = Library.Scheme.MainColor
    StalkerButton.BackgroundTransparency = 0; StalkerButton.AutoButtonColor = true
    StalkerButton.ZIndex = 10; StalkerButton.Parent = StalkerGUI
    Instance.new("UICorner", StalkerButton).CornerRadius = UDim.new(1, 0)
    local s = Instance.new("UIStroke", StalkerButton)
    s.Color = Library.Scheme.OutlineColor; s.Thickness = 1; s.Transparency = 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.LineJoinMode = Enum.LineJoinMode.Round
    applyGlowStroke(s, Color3.fromRGB(180, 45, 45), Library.Scheme.MainColor)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1; l.Text = "GRAB"
    l.TextColor3 = Library.Scheme.FontColor; l.TextScaled = true
    l.Font = Enum.Font.Code; l.ZIndex = 11; l.Parent = StalkerButton
    local GR = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Killers")
        and ReplicatedStorage.Remotes.Killers:FindFirstChild("Stalker") and ReplicatedStorage.Remotes.Killers.Stalker:FindFirstChild("grab")
    StalkerButton.MouseButton1Click:Connect(function()
        local p = GetNearest()
        if not p then NIEELS_Notify("Stalker Grab", "No player nearby!", 2.0); return end
        if not GR then NIEELS_Notify("Stalker Grab", "Error: Remote not found", 2.0); return end
        pcall(function() GR:FireServer(p.Character) end)
        NIEELS_Notify("Stalker Grab", "Grabbed: " .. p.Name, 2.0)
    end)
end

local function ToggleStalker()
    if StalkerGUI and StalkerGUI.Parent then StalkerGUI:Destroy(); StalkerGUI = nil
    else CreateStalker() end
end

local var973, StopHiddenM2Hook
do
    local num96 = 50
    local num97 = 1.5
    local tbl2 = { flag159 = false, num161 = 0, num160 = 1.0, connection26 = nil }

    local function fn9_local(player)
        local ok, team = pcall(function() return player.Team end)
        if not ok or not team then return "survivor" end
        return team.Name:lower():find("killer") and "killer" or "survivor"
    end

    local function fn267(character)
        if not character then return false end
        local humanoid21 = character:FindFirstChildOfClass("Humanoid")
        if not humanoid21 or humanoid21.Health <= 0 then return false end
        if character:GetAttribute("Knocked") then return false end
        if character:GetAttribute("IsHooked") then return false end
        if character:GetAttribute("IsCarried") then return false end
        return true
    end

    local function fn268()
        local character45 = LP.Character
        local var974 = character45 and character45:FindFirstChild("HumanoidRootPart")
        if not var974 then return nil end
        local var975, huge9 = nil, math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and player.Character and fn267(player.Character) then
                if fn9_local(player) ~= "killer" then
                    local part = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Head")
                    if part and part:IsA("BasePart") then
                        local dist = (var974.Position - part.Position).Magnitude
                        if dist <= num96 and dist < huge9 then huge9 = dist; var975 = part end
                    end
                end
            end
        end
        return var975
    end

    local function onEvent()
        if not tbl2.flag159 then return end
        local var976, isKiller = pcall(function() return fn9_local(LP) == "killer" end)
        if not var976 or not isKiller then return end
        tbl2.num161 = tick() + num97
    end

    function var973()
        if tbl2.connection26 then return end
        pcall(function()
            local remotes12 = ReplicatedStorage:FindFirstChild("Remotes")
            local killers = remotes12 and remotes12:FindFirstChild("Killers")
            local var977 = killers and killers:FindFirstChild("Hidden")
            local var978 = var977 and var977:FindFirstChild("preparem2")
            if var978 and var978:IsA("BindableEvent") then tbl2.connection26 = var978.Event:Connect(onEvent)
            elseif var978 and var978:IsA("RemoteEvent") then tbl2.connection26 = var978.OnClientEvent:Connect(onEvent)
            else NIEELS_Notify("AIMLOCK M2", "preparem2 tidak ditemukan", 2) end
        end)
    end

    function StopHiddenM2Hook()
        if tbl2.connection26 then pcall(function() tbl2.connection26:Disconnect() end); tbl2.connection26 = nil end
        tbl2.num161 = 0
    end

    RS.RenderStepped:Connect(function()
        if not tbl2.flag159 then return end
        if tick() > tbl2.num161 then return end
        local var979, isKiller = pcall(function() return fn9_local(LP) == "killer" end)
        if not var979 or not isKiller then return end
        local currentCamera20 = workspace.CurrentCamera
        if not currentCamera20 then return end
        local var980 = fn268()
        if not var980 then return end
        local position21 = var980.Position
        local smooth = math.clamp(tonumber(tbl2.num160) or 1, 0.05, 1)
        pcall(function()
            currentCamera20.CFrame = currentCamera20.CFrame:Lerp(CFrame.new(currentCamera20.CFrame.Position, position21), smooth)
        end)
        pcall(function()
            local char = LP.Character
            local var981 = char and char:FindFirstChild("HumanoidRootPart")
            if var981 then var981.CFrame = CFrame.new(var981.Position, Vector3.new(position21.X, var981.Position.Y, position21.Z)) end
        end)
    end)

    _G.NIEELSAimlockHiddenSet = function(enabled) tbl2.flag159 = enabled and true or false end
    _G.NIEELSAimlockHiddenSetSmooth = function(val) tbl2.num160 = math.clamp(tonumber(val) or 1, 0.05, 1) end
end

task.spawn(function()
    while _G.NIEELS.ScriptAlive do
        if _G.NIEELS.SkipEndscreen then
            pcall(function()
                local map = workspace:FindFirstChild("Map")
                if map then
                    local es = map:FindFirstChild("endscreen", true)
                    if es then
                        for _, d in ipairs(es:GetDescendants()) do
                            if d:IsA("LocalScript") then d.Disabled = true end
                        end
                        es:Destroy()
                    end
                end
                local res = PlayerGui:FindFirstChild("Results")
                if res then
                    local fr = res:FindFirstChild("Frame")
                    if fr then
                        local cl = fr:FindFirstChild("Close")
                        if cl and fr.Visible and cl.Visible then
                            pcall(function()
                                if typeof(firesignal) == "function" then firesignal(cl.MouseButton1Click) end
                            end)
                        end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

local guiName="NIEELSFreemium_V2_Tabbed"
if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy()
elseif LP.PlayerGui:FindFirstChild(guiName) then LP.PlayerGui[guiName]:Destroy() end
local SG2=Instance.new("ScreenGui")
SG2.Name=guiName; SG2.ResetOnSpawn=false
local ok=pcall(function() SG2.Parent=CoreGui end)
if not ok then SG2.Parent=LP:WaitForChild("PlayerGui") end

local MF=Instance.new("Frame")
MF.Size=UDim2.new(0,365,0,265); MF.Position=UDim2.new(0.5,-174,0.5,-129)
MF.BackgroundColor3=Library.Scheme.BackgroundColor; MF.BorderSizePixel=0; MF.Active=true; MF.Parent=SG2

local BGImage = Instance.new("ImageLabel")
BGImage.Name = "BackgroundLogo"
BGImage.Size = UDim2.new(1, -16, 1, -84)
BGImage.Position = UDim2.new(0, 8, 0, 76)
BGImage.BackgroundTransparency = 1
BGImage.Image = IMG_LOGO_NIEELS
BGImage.ImageColor3 = Color3.fromRGB(55, 110, 170)
BGImage.ImageTransparency = 0.55
BGImage.ScaleType = Enum.ScaleType.Fit
BGImage.ZIndex = 1
BGImage.Parent = MF
Instance.new("UICorner", BGImage).CornerRadius = UDim.new(0, 6)

local MFC=Instance.new("UICorner",MF); MFC.CornerRadius=UDim.new(0,8)
local MS=Instance.new("UIStroke",MF); MS.Thickness=1; MS.Color=Library.Scheme.OutlineColor
MS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; MS.LineJoinMode=Enum.LineJoinMode.Round; MS.Parent=MF
applyGlowStroke(MS, Library.Scheme.AccentColor, Library.Scheme.MainColor)

local TB=Instance.new("Frame",MF)
TB.Size=UDim2.new(1,0,0,32); TB.BackgroundColor3=Library.Scheme.MainColor; TB.BorderSizePixel=0; TB.ZIndex=2
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,8)

local TBB=Instance.new("Frame",TB)
TBB.Size=UDim2.new(1,0,0,8); TBB.Position=UDim2.new(0,0,1,-8); TBB.BackgroundColor3=Library.Scheme.MainColor; TBB.BorderSizePixel=0
local TitleDivider=Instance.new("Frame",TB)
TitleDivider.Size=UDim2.new(1,0,0,1); TitleDivider.Position=UDim2.new(0,0,1,0)
TitleDivider.BackgroundColor3=Library.Scheme.OutlineColor; TitleDivider.BorderSizePixel=0; TitleDivider.ZIndex=5

local TitleLogo=Instance.new("ImageLabel")
TitleLogo.Name="TitleLogo"; TitleLogo.Size=UDim2.new(0,28,0,28); TitleLogo.Position=UDim2.new(0,8,0,2)
TitleLogo.BackgroundTransparency=1; TitleLogo.Image=IMG_LOGO_TITLE; TitleLogo.ImageColor3=Library.Scheme.FontColor
TitleLogo.ScaleType=Enum.ScaleType.Fit; TitleLogo.ZIndex=5; TitleLogo.Parent=TB

local TTL=Instance.new("TextLabel",TB)
TTL.AutomaticSize=Enum.AutomaticSize.X; TTL.Size=UDim2.new(0,0,0,19); TTL.Position=UDim2.new(0,40,0,6)
TTL.BackgroundTransparency=1; TTL.Text="NIEELS HUB"; TTL.TextColor3=Library.Scheme.FontColor; TTL.TextSize=25
TTL.Font=Enum.Font.GothamBlack; TTL.TextStrokeColor3=Color3.fromRGB(0,0,0); TTL.TextStrokeTransparency=0.4; TTL.ZIndex=3

local CB=Instance.new("ImageButton",TB)
CB.Size=UDim2.new(0,22,0,22); CB.Position=UDim2.new(1,-28,0.5,-11)
CB.BackgroundTransparency=1; CB.Image=LUCIDE_ICONS.Close; CB.ImageColor3=Library.Scheme.FontColor
CB.ScaleType=Enum.ScaleType.Fit; CB.ZIndex=3
local CBP=Instance.new("UIPadding",CB); CBP.PaddingTop=UDim.new(0,4); CBP.PaddingBottom=UDim.new(0,4); CBP.PaddingLeft=UDim.new(0,4); CBP.PaddingRight=UDim.new(0,4)
Instance.new("UICorner",CB).CornerRadius=UDim.new(0,5)
local CBS=Instance.new("UIStroke",CB); CBS.Color=Color3.fromRGB(100,100,110); CBS.Thickness=1; CBS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

local MB=Instance.new("ImageButton",TB)
MB.Size=UDim2.new(0,22,0,22); MB.Position=UDim2.new(1,-54,0.5,-11)
MB.BackgroundTransparency=1; MB.Image=LUCIDE_ICONS.Minus; MB.ImageColor3=Library.Scheme.FontColor
MB.ScaleType=Enum.ScaleType.Fit; MB.ZIndex=3
local MBP=Instance.new("UIPadding",MB); MBP.PaddingTop=UDim.new(0,4); MBP.PaddingBottom=UDim.new(0,4); MBP.PaddingLeft=UDim.new(0,4); MBP.PaddingRight=UDim.new(0,4)
Instance.new("UICorner",MB).CornerRadius=UDim.new(0,5)
local MBS=Instance.new("UIStroke",MB); MBS.Color=Color3.fromRGB(100,100,110); MBS.Thickness=1; MBS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

local NIEELSLogo=Instance.new("ImageLabel")
NIEELSLogo.Name="NIEELSLogo"; NIEELSLogo.Size=UDim2.new(0.7,0,0.7,0); NIEELSLogo.Position=UDim2.new(0.15,0,0.15,0)
NIEELSLogo.BackgroundTransparency=1; NIEELSLogo.Image=IMG_LOGO_NIEELS; NIEELSLogo.ImageColor3=Color3.fromRGB(255,255,255)
NIEELSLogo.ScaleType=Enum.ScaleType.Fit; NIEELSLogo.Visible=false; NIEELSLogo.ZIndex=5; NIEELSLogo.Parent=MB

local isLocked=true
local LB=Instance.new("ImageButton",TB)
LB.Size=UDim2.new(0,22,0,22); LB.Position=UDim2.new(1,-80,0.5,-11)
LB.BackgroundTransparency=1; LB.Image=LUCIDE_ICONS.Lock; LB.ImageColor3=Library.Scheme.AccentColor
LB.ScaleType=Enum.ScaleType.Fit; LB.ZIndex=3
local LBP=Instance.new("UIPadding",LB); LBP.PaddingTop=UDim.new(0,4); LBP.PaddingBottom=UDim.new(0,4); LBP.PaddingLeft=UDim.new(0,4); LBP.PaddingRight=UDim.new(0,4)
Instance.new("UICorner",LB).CornerRadius=UDim.new(0,5)
local LBS=Instance.new("UIStroke",LB); LBS.Color=Library.Scheme.AccentColor; LBS.Thickness=1; LBS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

local CP=Instance.new("Frame",MF)
CP.Size=UDim2.new(1,-40,0,110); CP.Position=UDim2.new(0,20,0.5,-55); CP.BackgroundColor3=Library.Scheme.MainColor
CP.BorderSizePixel=0; CP.Visible=false; CP.ZIndex=50
Instance.new("UICorner",CP).CornerRadius=UDim.new(0,8)

local PS=Instance.new("UIStroke",CP); PS.Color=Color3.fromRGB(139,0,0); PS.Thickness=1
PS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; PS.LineJoinMode=Enum.LineJoinMode.Round
applyGlowStroke(PS, Color3.fromRGB(255, 50, 50), Library.Scheme.MainColor)

local PT=Instance.new("TextLabel",CP)
PT.Size=UDim2.new(1,-20,0,40); PT.Position=UDim2.new(0,10,0,10); PT.BackgroundTransparency=1
PT.Text="Are you sure you want to exit the script?"; PT.TextColor3=Library.Scheme.FontColor; PT.TextSize=12
PT.Font=Enum.Font.Code; PT.TextWrapped=true; PT.ZIndex=51
local YB=Instance.new("TextButton",CP)
YB.Size=UDim2.new(0.5,-15,0,30); YB.Position=UDim2.new(0,10,0,70); YB.BackgroundColor3=Color3.fromRGB(139,0,0)
YB.Text="Yes"; YB.TextColor3=Library.Scheme.FontColor; YB.Font=Enum.Font.Code; YB.TextSize=12; YB.ZIndex=51
Instance.new("UICorner",YB).CornerRadius=UDim.new(0,5)
local NB=Instance.new("TextButton",CP)
NB.Size=UDim2.new(0.5,-15,0,30); NB.Position=UDim2.new(0.5,5,0,70); NB.BackgroundColor3=Color3.fromRGB(80,80,90)
NB.Text="Close"; NB.TextColor3=Library.Scheme.FontColor; NB.Font=Enum.Font.Code; NB.TextSize=12; NB.ZIndex=51
Instance.new("UICorner",NB).CornerRadius=UDim.new(0,5)

local TabBar=Instance.new("Frame",MF)
TabBar.Size=UDim2.new(1,-16,0,34); TabBar.Position=UDim2.new(0,8,0,36)
TabBar.BackgroundColor3=Library.Scheme.BackgroundColor; TabBar.BorderSizePixel=0; TabBar.ZIndex=2
Instance.new("UICorner",TabBar).CornerRadius=UDim.new(0,6)
local TL=Instance.new("UIListLayout",TabBar)
TL.FillDirection=Enum.FillDirection.Horizontal; TL.HorizontalAlignment=Enum.HorizontalAlignment.Center
TL.VerticalAlignment=Enum.VerticalAlignment.Center; TL.Padding=UDim.new(0,3)
local TP=Instance.new("UIPadding",TabBar)
TP.PaddingLeft=UDim.new(0,3); TP.PaddingRight=UDim.new(0,3); TP.PaddingTop=UDim.new(0,4); TP.PaddingBottom=UDim.new(0,4)

local TabDivider=Instance.new("Frame",MF)
TabDivider.Size=UDim2.new(1,-16,0,1); TabDivider.Position=UDim2.new(0,8,0,72)
TabDivider.BackgroundColor3=Library.Scheme.OutlineColor; TabDivider.BorderSizePixel=0; TabDivider.ZIndex=5

local CC=Instance.new("Frame",MF)
CC.Size=UDim2.new(1,-16,1,-84); CC.Position=UDim2.new(0,8,0,76); CC.BackgroundTransparency=1; CC.ZIndex=2

local TBN={}; local TFN={}; local ActiveTab=nil
local TAC=Library.Scheme.AccentColor; local TIC=Library.Scheme.BackgroundColor
local ACC=Library.Scheme.AccentColor; local ONC=Color3.fromRGB(60,200,120); local OFC=Library.Scheme.MainColor
local LC=Library.Scheme.MainColor; local TRC=Library.Scheme.BackgroundColor
local SECT=Library.Scheme.OutlineColor; local TXC=Library.Scheme.FontColor; local DGC=Color3.fromRGB(139,0,0)

local function CreateTF(n)
    local f=Instance.new("ScrollingFrame")
    f.Name=n.."Tab"; f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1; f.BorderSizePixel=0
    f.ScrollBarThickness=4; f.ScrollBarImageColor3=ACC; f.CanvasSize=UDim2.new(0,0,0,0)
    f.AutomaticCanvasSize=Enum.AutomaticSize.Y; f.ScrollingDirection=Enum.ScrollingDirection.Y; f.Visible=false; f.Parent=CC
    f.ZIndex=3
    local l=Instance.new("UIListLayout",f); l.SortOrder=Enum.SortOrder.LayoutOrder; l.Padding=UDim.new(0,6)
    local p=Instance.new("UIPadding",f)
    p.PaddingLeft=UDim.new(0,6); p.PaddingRight=UDim.new(0,6); p.PaddingTop=UDim.new(0,6); p.PaddingBottom=UDim.new(0,6)
    return f
end

local function SwitchTab(n)
    if ActiveTab==n then return end
    for nm,f in pairs(TFN) do f.Visible=(nm==n) end
    for nm,b in pairs(TBN) do
        local stroke = b:FindFirstChildOfClass("UIStroke")
        if nm==n then
            b.TextColor3=TAC
            if stroke then stroke.Transparency=0 end
        else
            b.TextColor3=Color3.fromRGB(120,120,130)
            if stroke then stroke.Transparency=1 end
        end
    end
    ActiveTab=n
end

local TBC=4
local function CreateTab(n,dn,o)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1/TBC,-4,1,-4); b.LayoutOrder=o; b.BackgroundColor3=TIC; b.BackgroundTransparency=1
    b.Text=dn; b.TextColor3=Color3.fromRGB(120,120,130); b.Font=Enum.Font.Code; b.TextSize=10; b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4); b.Parent=TabBar; b.ZIndex=3
    local stroke = Instance.new("UIStroke", b)
    stroke.Color=TAC; stroke.Thickness=1; stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; stroke.Transparency=1
    b.MouseButton1Click:Connect(function() SwitchTab(n) end)
    TBN[n]=b; TFN[n]=CreateTF(n)
    return TFN[n]
end

local function CreateSec(p,t,o)
    local s=Instance.new("Frame",p)
    s.Size=UDim2.new(1,0,0,22); s.LayoutOrder=o; s.BackgroundTransparency=1; s.ZIndex=3
    local l=Instance.new("TextLabel",s)
    l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.Text=t
    l.TextColor3=SECT; l.Font=Enum.Font.Code; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=3
    local lp=Instance.new("UIPadding",l); lp.PaddingLeft=UDim.new(0,4)
end

local function CreateDivider(p,o)
    local d=Instance.new("Frame",p)
    d.Size=UDim2.new(1,0,0,8); d.LayoutOrder=o; d.BackgroundTransparency=1; d.ZIndex=3
    local line=Instance.new("Frame",d)
    line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,0.5,0)
    line.BackgroundColor3=Library.Scheme.OutlineColor; line.BorderSizePixel=0
end

local function CreateToggle(p,o,lt,init,cb)
    local C=Instance.new("TextButton"); C.Size=UDim2.new(1,0,0,24)
    C.BackgroundTransparency=1; C.Text=""; C.LayoutOrder=o; C.Parent=p; C.ZIndex=3
    local L=Instance.new("TextLabel"); L.Size=UDim2.new(0.7,0,1,0)
    L.BackgroundTransparency=1; L.Text=lt; L.TextColor3=Color3.fromRGB(200,200,200)
    L.Font=Enum.Font.Code; L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=C; L.ZIndex=3
    local IB=Instance.new("Frame")
    IB.Size=UDim2.new(0,34,0,18); IB.Position=UDim2.new(1,-34,0.5,-9)
    IB.BackgroundColor3=init and Color3.fromRGB(90,120,210) or Color3.fromRGB(40,40,45); IB.Parent=C; IB.ZIndex=3
    Instance.new("UICorner",IB).CornerRadius=UDim.new(1,0)
    local Ci=Instance.new("Frame")
    Ci.Size=UDim2.new(0,14,0,14); Ci.Position=init and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    Ci.BackgroundColor3=Color3.fromRGB(255,255,255); Ci.Parent=IB; Ci.ZIndex=4
    Instance.new("UICorner",Ci).CornerRadius=UDim.new(1,0)
    local state=init
    C.MouseButton1Click:Connect(function()
        state=not state; cb(state)
        NIEELS_Notify(lt, state and "Enabled" or "Disabled", 2.0)
        TweenService:Create(IB, TweenInfo.new(0.2), { BackgroundColor3 = state and Color3.fromRGB(90,120,210) or Color3.fromRGB(40,40,45) }):Play()
        TweenService:Create(Ci, TweenInfo.new(0.2), { Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7) }):Play()
    end)
    return C
end

local function CreateAction(p,o,lt,bt,cb,cc)
    local C=Instance.new("Frame"); C.Size=UDim2.new(1,0,0,24)
    C.BackgroundTransparency=1; C.LayoutOrder=o; C.Parent=p; C.ZIndex=3
    local L=Instance.new("TextLabel"); L.Size=UDim2.new(0.6,0,1,0)
    L.BackgroundTransparency=1; L.Text=lt; L.TextColor3=Color3.fromRGB(200,200,200)
    L.Font=Enum.Font.Code; L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=C; L.ZIndex=3
    local ac = cc or Color3.fromRGB(90,120,210)
    local B=Instance.new("TextButton"); B.Size=UDim2.new(0.4,0,0,18)
    B.Position=UDim2.new(0.6,0,0.5,-9); B.BackgroundTransparency=1
    B.Text=bt; B.TextColor3=ac; B.Font=Enum.Font.Code; B.TextSize=10; B.AutoButtonColor=false; B.Parent=C; B.ZIndex=4
    Instance.new("UICorner",B).CornerRadius=UDim.new(1,0)
    local S=Instance.new("UIStroke",B); S.Color=ac; S.Thickness=1; S.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    B.MouseButton1Click:Connect(function() cb(B); NIEELS_Notify(lt, "Triggered", 2.0) end)
    return B, L
end

local function CreateSliderRow(p,o,lt,mn,mx,df,isf,cb)
    local C=Instance.new("Frame"); C.Size=UDim2.new(1,0,0,34)
    C.BackgroundTransparency=1; C.LayoutOrder=o; C.Parent=p; C.ZIndex=3
    local L=Instance.new("TextLabel"); L.Size=UDim2.new(1,0,0,14)
    L.Position=UDim2.new(0,0,0,0); L.BackgroundTransparency=1
    L.Text=lt..": "..df; L.TextColor3=Color3.fromRGB(200,200,200)
    L.Font=Enum.Font.Code; L.TextSize=11; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=C; L.ZIndex=3
    local SB=Instance.new("Frame"); SB.Size=UDim2.new(1,0,0,8)
    SB.Position=UDim2.new(0,0,0,20); SB.BackgroundColor3=Color3.fromRGB(40,40,45); SB.Parent=C; SB.ZIndex=3
    Instance.new("UICorner",SB).CornerRadius=UDim.new(1,0)
    local ip=math.clamp((df-mn)/(mx-mn),0,1)
    local SF=Instance.new("Frame"); SF.Size=UDim2.new(ip,0,1,0)
    SF.BackgroundColor3=Color3.fromRGB(90,120,210); SF.Parent=SB; SF.ZIndex=4
    Instance.new("UICorner",SF).CornerRadius=UDim.new(1,0)
    local Ci=Instance.new("Frame"); Ci.Size=UDim2.new(0,14,0,14)
    Ci.AnchorPoint=Vector2.new(0.5,0.5); Ci.Position=UDim2.new(ip,0,0.5,0)
    Ci.BackgroundColor3=Color3.fromRGB(255,255,255); Ci.ZIndex=5; Ci.Parent=SB
    Instance.new("UICorner",Ci).CornerRadius=UDim.new(1,0)
    local drag=false
    local function Upd(input)
        if not SB or not SB.Parent or SB.AbsoluteSize.X<=0 then return end
        local pc=math.clamp((input.Position.X-SB.AbsolutePosition.X)/SB.AbsoluteSize.X,0,1)
        local v=mn+pc*(mx-mn); v=math.clamp(v,mn,mx)
        v=isf and (math.floor(v*100+0.5)/100) or math.floor(v+0.5)
        local cp=math.clamp((v-mn)/(mx-mn),0,1)
        TweenService:Create(SF,TweenInfo.new(0.08),{Size=UDim2.new(cp,0,1,0)}):Play()
        TweenService:Create(Ci,TweenInfo.new(0.08),{Position=UDim2.new(cp,0,0.5,0)}):Play()
        L.Text=lt..": "..v; cb(v)
    end
    SB.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; Upd(i)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then Upd(i) end
    end)
    return L, SF
end

local function CreateCycle(p,o,lt,bt,cb)
    local C=Instance.new("TextButton"); C.Size=UDim2.new(1,0,0,24)
    C.BackgroundTransparency=1; C.Text=""; C.LayoutOrder=o; C.Parent=p; C.ZIndex=3
    local L=Instance.new("TextLabel"); L.Size=UDim2.new(0.6,0,1,0)
    L.BackgroundTransparency=1; L.Text=lt; L.TextColor3=Color3.fromRGB(200,200,200)
    L.Font=Enum.Font.Code; L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=C; L.ZIndex=3
    local cc=Color3.fromRGB(90,120,210)
    local VB=Instance.new("TextButton"); VB.Size=UDim2.new(0.4,0,0,18)
    VB.Position=UDim2.new(0.6,0,0.5,-9); VB.BackgroundTransparency=1
    VB.Text=bt; VB.TextColor3=cc; VB.Font=Enum.Font.Code; VB.TextSize=10; VB.AutoButtonColor=false; VB.Parent=C; VB.ZIndex=4
    Instance.new("UICorner",VB).CornerRadius=UDim.new(1,0)
    local S=Instance.new("UIStroke",VB); S.Color=cc; S.Thickness=1; S.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    VB.MouseButton1Click:Connect(function() cb(VB,L); NIEELS_Notify(lt,"Mode: "..VB.Text,2.0) end)
    return VB, L
end

local MainTab=CreateTab("Main","MAIN",1)
local SurvTab=CreateTab("Survivor","SURVIVOR",2)
local KillerTab=CreateTab("Killer","KILLER",3)
local InfoTab=CreateTab("Info","INFO",4)

local o=1
CreateSec(MainTab,"VISUAL",o); o=o+1
CreateToggle(MainTab,o,"Low graphic",false,function(v)
    if v then EnableLowGraphic() else DisableLowGraphic() end
end); o=o+1
CreateDivider(MainTab,o); o=o+1
CreateSec(MainTab,"STRETCH RES",o); o=o+1
CreateToggle(MainTab,o,"Stretch Res",false,function(v) SetStretchRes(v) end); o=o+1
CreateSliderRow(MainTab,o,"Stretch Amount",0.1,2.0,0.67,true,function(v) SetStretchAmount(v) end); o=o+1
CreateDivider(MainTab,o); o=o+1
CreateSec(MainTab,"MOONWALK",o); o=o+1
CreateToggle(MainTab,o,"Moonwalk",false,function(v)
    if v then StartMoonwalk(); Moonwalk.IsActive = Moonwalk.Enabled; UpdateMoonwalkGUI(Moonwalk.Enabled)
    else StopMoonwalk(); Moonwalk.IsActive = Moonwalk.Enabled; UpdateMoonwalkGUI(Moonwalk.Enabled) end
end); o=o+1
CreateToggle(MainTab,o,"Show Moonwalk GUI",false,function(v)
    if v then
        if not Moonwalk.Gui then CreateMoonwalkGUI() end
        Moonwalk.Gui.Enabled = true; Moonwalk.GuiVisible = true
        UpdateMoonwalkGUI(Moonwalk.Enabled)
    else
        if Moonwalk.Gui then Moonwalk.Gui.Enabled = false; Moonwalk.GuiVisible = false end
    end
end); o=o+1
CreateDivider(MainTab,o); o=o+1
CreateSec(MainTab,"MISC",o); o=o+1
CreateToggle(MainTab,o,"Skip Endscreen",false,function(v) _G.NIEELS.SkipEndscreen=v end); o=o+1

o=1
CreateSec(SurvTab,"AUTO SKILL CHECK",o); o=o+1
CreateToggle(SurvTab,o,"Auto Skill Check",false,function(s) SkillCheck.SetEnabled(s) end); o=o+1
CreateCycle(SurvTab,o,"Skill Mode","Legit",function(b)
    local mode = SkillCheck.GetMode()
    if mode == "Legit" then SkillCheck.SetMode("Instant")
    elseif mode == "Instant" then SkillCheck.SetMode("Normal")
    elseif mode == "Normal" then SkillCheck.SetMode("Random")
    else SkillCheck.SetMode("Legit") end
    b.Text = SkillCheck.GetMode()
    SkillCheckState.busy = false
end); o=o+1
CreateDivider(SurvTab,o); o=o+1
CreateSec(SurvTab,"HEALING",o); o=o+1
CreateToggle(SurvTab,o,"Auto Self Heal",false,function(v)
    SetAutoSelfHeal(v)
end); o=o+1
CreateDivider(SurvTab,o); o=o+1
CreateSec(SurvTab,"MOVEMENT",o); o=o+1
CreateToggle(SurvTab,o,"Auto Dodge Crouch",false,function(v)
    AutoDodgeCrouch = v
    if v then StartAutoDodgeCrouch() else StopAutoDodgeCrouch() end
end); o=o+1
CreateDivider(SurvTab,o); o=o+1
CreateSec(SurvTab,"ESCAPE",o); o=o+1
CreateAction(SurvTab,o,"Instant Escape","ESCAPE",function(b)
    local root = getRoot(); if not root then return end
    local found = nil
    for _, obj in ipairs(WS:GetDescendants()) do
        if string.lower(obj.Name) == "fininshline" and obj:IsA("BasePart") then found = obj; break end
    end
    if found then root.CFrame = found.CFrame + Vector3.new(0, 5, 0) end
    b.Text="Triggered"; b.TextColor3=ONC
    local stroke=b:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Color=ONC end
    task.wait(0.8)
    b.Text="ESCAPE"; b.TextColor3=ACC
    if stroke then stroke.Color=ACC end
end, ACC); o=o+1
CreateDivider(SurvTab,o); o=o+1
CreateSec(SurvTab,"ESP",o); o=o+1
CreateToggle(SurvTab,o,"ESP Player",false,function(s) ESP:Toggle(s) end); o=o+1
CreateToggle(SurvTab,o,"ESP Generator",false,function(s)
    GeneratorESPConfig.Enabled=s
    if not s then
        for gen in pairs(CachedGenerators) do
            if gen then
                local b=gen:FindFirstChild("GenESP"); if b then b:Destroy() end
                local h=gen:FindFirstChild("GenHighlight"); if h then h:Destroy() end
            end
        end
    end
end); o=o+1

o=1
CreateSec(KillerTab,"MYERS",o); o=o+1
CreateToggle(KillerTab,o,"GRAB GUI",false,function(s)
    if s then
        if not (StalkerGUI and StalkerGUI.Parent) then ToggleStalker() end
    else
        if StalkerGUI and StalkerGUI.Parent then ToggleStalker() end
    end
end); o=o+1
CreateToggle(KillerTab,o,"Auto Stalk",false,function(s)
    AutoStalk.Enabled=s
    if s then startAutoStalk() else stopAutoStalk() end
end); o=o+1
CreateDivider(KillerTab,o); o=o+1
CreateSec(KillerTab,"ATTACK AIMBOT",o); o=o+1
CreateToggle(KillerTab,o,"Attack Aimbot",false,function(v) AttackAimbot.Enabled = v end); o=o+1
CreateSliderRow(KillerTab,o,"Aimbot Max Dist",5,30,12,false,function(v) AttackAimbot.MaxDist = v end); o=o+1
CreateSliderRow(KillerTab,o,"Aimbot Smoothness",0.05,1.0,0.5,true,function(v) AttackAimbot.Smoothness = v end); o=o+1
CreateDivider(KillerTab,o); o=o+1
CreateSec(KillerTab,"INFINITE LUNGE",o); o=o+1
CreateToggle(KillerTab,o,"Infinite Lunge",false,function(v) SetInfiniteLunge(v) end); o=o+1
CreateDivider(KillerTab,o); o=o+1
CreateSec(KillerTab,"SILENT AIM FLASK",o); o=o+1
CreateToggle(KillerTab,o,"Silent Aim Flask",false,function(v) SetSilentAimFlask(v) end); o=o+1
CreateToggle(KillerTab,o,"Show Flask Laser",true,function(v) SetFlaskLaserVisible(v) end); o=o+1
CreateDivider(KillerTab,o); o=o+1
CreateSec(KillerTab,"AIMLOCK HIDDEN M2",o); o=o+1
CreateToggle(KillerTab,o,"Aimlock Hidden M2",false,function(s)
    if _G.NIEELSAimlockHiddenSet then _G.NIEELSAimlockHiddenSet(s) end
    if s then
        if var973 then var973() end
        NIEELS_Notify("Aimlock M2", "Enabled", 2.0)
    else
        if StopHiddenM2Hook then StopHiddenM2Hook() end
        NIEELS_Notify("Aimlock M2", "Disabled", 2.0)
    end
end); o=o+1
CreateSliderRow(KillerTab,o,"M2 Smoothness",0.05,1.0,1.0,true,function(v)
    if _G.NIEELSAimlockHiddenSetSmooth then _G.NIEELSAimlockHiddenSetSmooth(v) end
end); o=o+1
CreateDivider(KillerTab,o); o=o+1
CreateSec(KillerTab,"BYPASS COOLDOWN",o); o=o+1
CreateToggle(KillerTab,o,"Bypass Cooldown Killer",false,function(s)
    killerNoCDFlag = s
    if s then
        fn7()
        local killerType = fn6()
        if killerType == "mayers" then StartMayersMobileHook(); NIEELS_Notify("NO COOLDOWN", "Mayers NO CD Enable", 2.0)
        elseif killerType == "hidden" then NIEELS_Notify("No COOLDOWN", "Hidden NO CD Enable", 2.0)
        else NIEELS_Notify("NO COOLDOWN", "NO Cooldown Enable", 2.0) end
    else
        fn8(); StopMayersMobileHook(); NIEELS_Notify("NO COOLDOWN", "NO Cooldown Disable", 2.0)
    end
end); o=o+1

o=1
CreateSec(InfoTab,"INFO DISPLAY",o); o=o+1
CreateToggle(InfoTab,o,"FPS & Ping Watermark",true,function(v) SetWatermarkEnabled(v) end); o=o+1
CreateToggle(InfoTab,o,"Next Killer Predict",false,function(v) SetNextKillerEnabled(v) end); o=o+1
CreateToggle(InfoTab,o,"Next Map Predict",false,function(v) SetMapPredictEnabled(v) end); o=o+1
CreateToggle(InfoTab,o,"Spectator Counter",false,function(v) SetSpectatorEnabled(v) end); o=o+1
CreateToggle(InfoTab,o,"Killer Perks Display",false,function(v) SetKillerPerksEnabled(v) end); o=o+1
CreateDivider(InfoTab,o); o=o+1
CreateSec(InfoTab,"KILLER INDICATORS",o); o=o+1
CreateToggle(InfoTab,o,"Stun Indicator",false,function(v) SetStunEnabled(v) end); o=o+1
CreateToggle(InfoTab,o,"Hit Sound Effect",false,function(v) SetHitSoundEnabled(v) end); o=o+1
CreateDivider(InfoTab,o); o=o+1
CreateSec(InfoTab,"WORLD EFFECT",o); o=o+1
CreateToggle(InfoTab,o,"Full Bright",false,function(v) SetWorldFullBright(v) end); o=o+1
CreateToggle(InfoTab,o,"Clean Sky",false,function(v) SetWorldCleanSky(v) end); o=o+1
CreateToggle(InfoTab,o,"No Shadow",false,function(v) SetWorldNoShadow(v) end); o=o+1
CreateToggle(InfoTab,o,"No Screen Effects",false,function(v) SetWorldNoScreenEffects(v) end); o=o+1
CreateToggle(InfoTab,o,"Low Graphics",false,function(v) SetWorldLowGraphics(v) end); o=o+1
CreateToggle(InfoTab,o,"No Fog",false,function(v) SetWorldNoFog(v) end); o=o+1

local SavedSize = MF.Size
local SavedPosition = MF.Position
local isMin=false
local MiniFrame=Instance.new("Frame")
MiniFrame.Name="MiniFrame"; MiniFrame.Size=UDim2.new(0,37,0,37); MiniFrame.Position=UDim2.new(0,100,0,100)
MiniFrame.BackgroundColor3=Library.Scheme.MainColor; MiniFrame.BorderSizePixel=0; MiniFrame.Active=true
MiniFrame.Visible=false; MiniFrame.ZIndex=100; MiniFrame.ClipsDescendants=true; MiniFrame.Parent=SG2
Instance.new("UICorner",MiniFrame).CornerRadius=UDim.new(1,0)

local MiniStroke=Instance.new("UIStroke",MiniFrame); MiniStroke.Color=Library.Scheme.AccentColor; MiniStroke.Thickness=1
MiniStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; MiniStroke.LineJoinMode=Enum.LineJoinMode.Round
applyGlowStroke(MiniStroke, Library.Scheme.AccentColor, Library.Scheme.MainColor)

local MiniGlow=Instance.new("ImageLabel",MiniFrame); MiniGlow.Name="Glow"; MiniGlow.Size=UDim2.new(1,10,1,10)
MiniGlow.Position=UDim2.new(0,-5,0,-5); MiniGlow.BackgroundTransparency=1; MiniGlow.Image="rbxassetid://5028857084"
MiniGlow.ImageColor3=Library.Scheme.AccentColor; MiniGlow.ImageTransparency=0.5; MiniGlow.ZIndex=99
local MiniLogo=Instance.new("ImageLabel"); MiniLogo.Size=UDim2.new(0.7,0,0.7,0); MiniLogo.Position=UDim2.new(0.15,0,0.15,0)
MiniLogo.BackgroundTransparency=1; MiniLogo.Image=IMG_LOGO_NIEELS; MiniLogo.ImageColor3=Library.Scheme.FontColor
MiniLogo.ScaleType=Enum.ScaleType.Fit; MiniLogo.ZIndex=101; MiniLogo.Parent=MiniFrame
local MiniBtn=Instance.new("TextButton"); MiniBtn.Size=UDim2.new(1,0,1,0); MiniBtn.BackgroundTransparency=1
MiniBtn.Text=""; MiniBtn.ZIndex=102; MiniBtn.Parent=MiniFrame

local miniDrag, miniStart, miniPos = false, nil, nil
local miniMoved=false
MiniBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        miniDrag=not isLocked; miniMoved=false; miniStart=i.Position; miniPos=MiniFrame.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if isLocked then return end
    if not miniDrag or not miniStart then return end
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        local d=i.Position-miniStart
        if math.abs(d.X)>3 or math.abs(d.Y)>3 then miniMoved=true end
        MiniFrame.Position=UDim2.new(miniPos.X.Scale,miniPos.X.Offset+d.X,miniPos.Y.Scale,miniPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        miniDrag=false; miniStart=nil
    end
end)

local function RestoreFromMini()
    isMin=false; MF.Visible=true
    if SavedSize then MF.Size=SavedSize else MF.Size=UDim2.new(0,347,0,257) end
    TB.Size=UDim2.new(1,0,0,32); TTL.Visible=true; CB.Visible=true; LB.Visible=true; TBB.Visible=true
    TitleLogo.Visible=true; TabBar.Visible=true; CC.Visible=true
    if TabDivider then TabDivider.Visible=true end
    MB.Size=UDim2.new(0,22,0,22); MB.Position=UDim2.new(1,-54,0.5,-11)
    MB.BackgroundTransparency=1; NIEELSLogo.Visible=false
end
MiniBtn.MouseButton1Click:Connect(function()
    if miniMoved then return end
    if isMin then RestoreFromMini() else MF.Visible=false; isMin=true end
end)
MB.MouseButton1Click:Connect(function()
    if CP.Visible then return end
    isMin=not isMin
    if isMin then SavedSize=MF.Size; SavedPosition=MF.Position; MiniFrame.Visible=true; MF.Visible=false
    else RestoreFromMini() end
end)
LB.MouseButton1Click:Connect(function()
    if CP.Visible then return end
    isLocked=not isLocked
    local stroke=LB:FindFirstChildOfClass("UIStroke")
    if isLocked then
        LB.Image=LUCIDE_ICONS.Lock; LB.ImageColor3=Library.Scheme.AccentColor
        if stroke then stroke.Color=Library.Scheme.AccentColor end
    else
        LB.Image=LUCIDE_ICONS.Unlock; LB.ImageColor3=Color3.fromRGB(120,120,130)
        if stroke then stroke.Color=Color3.fromRGB(100,100,110) end
    end
end)

CB.MouseButton1Click:Connect(function() if not CP.Visible then CP.Visible=true end end)
NB.MouseButton1Click:Connect(function() CP.Visible=false end)

local dg=false
local ds,sp=nil,nil
local function IBH(i)
    if isLocked or CP.Visible then return end
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dg=true; ds=i.Position; sp=MF.Position
    end
end
MF.InputBegan:Connect(function(i) IBH(i) end)
TB.InputBegan:Connect(function(i) if not isMin then IBH(i) end end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false; ds=nil end
end)
UIS.InputChanged:Connect(function(i)
    if not dg or isLocked or CP.Visible or not ds then return end
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        local d=i.Position-ds
        MF.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
end)

SwitchTab("Main")
NIEELS_Notify("NIEELS HUB", "Script loaded by "..DEVELOPER_NAME.."!", 3)
StartWatermark()

YB.MouseButton1Click:Connect(function()
    _G.NIEELS.ScriptAlive=false
    ESP:Stop()
    stopAutoStalk()
    DisableLowGraphic()
    SetStretchRes(false)
    SetAutoSelfHeal(false)
    SetInfiniteLunge(false)
    SetSilentAimFlask(false)
    AttackAimbot.Enabled = false
    AttackAimbot.Holding = false
    AttackAimbot.Target = nil
    if AttackAimbotInputBeganConn then AttackAimbotInputBeganConn:Disconnect() end
    if AttackAimbotInputEndedConn then AttackAimbotInputEndedConn:Disconnect() end
    if AttackAimbotRenderConn then AttackAimbotRenderConn:Disconnect() end
    if _G.NIEELSAimlockHiddenSet then _G.NIEELSAimlockHiddenSet(false) end
    if StopHiddenM2Hook then StopHiddenM2Hook() end
    fn8(); StopMayersMobileHook()
    GeneratorESPConfig.Enabled=false
    for gen in pairs(CachedGenerators) do
        if gen then
            local b=gen:FindFirstChild("GenESP"); if b then b:Destroy() end
            local h=gen:FindFirstChild("GenHighlight"); if h then h:Destroy() end
        end
    end
    StopAutoDodgeCrouch(); SkillCheck.SetEnabled(false)
    if StalkerGUI then StalkerGUI:Destroy() end
    if MiniFrame then MiniFrame:Destroy() end
    SetWatermarkEnabled(false)
    SetNextKillerEnabled(false)
    SetMapPredictEnabled(false)
    SetSpectatorEnabled(false)
    SetKillerPerksEnabled(false)
    SetStunEnabled(false)
    SetWorldFullBright(false)
    SetWorldCleanSky(false)
    SetWorldNoShadow(false)
    SetWorldNoScreenEffects(false)
    SetWorldLowGraphics(false)
    SetWorldNoFog(false)
    World_StopLoop()
    World_RestoreAll()
    if WorldEffect.ChildAddedConn then WorldEffect.ChildAddedConn:Disconnect(); WorldEffect.ChildAddedConn = nil end
    if WorldEffect.DescendantAddedConn then WorldEffect.DescendantAddedConn:Disconnect(); WorldEffect.DescendantAddedConn = nil end
    StopMoonwalk()
    if MoonwalkRenderConn then MoonwalkRenderConn:Disconnect() end
    if Moonwalk.InputConn then Moonwalk.InputConn:Disconnect(); Moonwalk.InputConn = nil end
    if Moonwalk.Gui then Moonwalk.Gui:Destroy(); Moonwalk.Gui = nil end
    if getgenv then getgenv().MoonwalkAPI = nil end
    SG2:Destroy()
end)
