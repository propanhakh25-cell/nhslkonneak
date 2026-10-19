-- NhaHub | Neon Edition | Smooth Fast Attack
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local old = player:WaitForChild("PlayerGui"):FindFirstChild("NhaHub")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "NhaHub"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- ==================== MAIN UI ====================
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(260, 520)
main.Position = UDim2.new(0, 18, 0.15, 0)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15) -- Deep Dark
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- Neon Border for the main frame
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Thickness = 2
mainStroke.Color = Color3.fromRGB(0, 255, 255) -- Cyan
local mainGradient = Instance.new("UIGradient", mainStroke)
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),   -- Cyan
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 0, 255))    -- Purple
})

local uiScale = Instance.new("UIScale")
uiScale.Parent = main
uiScale.Scale = 0 -- Start hidden for smooth fade-in

-- Fade in animation
TweenService:Create(uiScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

local function fitToScreen()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local view = camera.ViewportSize
    uiScale.Scale = math.clamp(math.min(view.X / 390, view.Y / 540), 0.72, 1)
    main.Position = UDim2.new(0, 12, 0.15, 0)
end
fitToScreen()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitToScreen)
end

-- Neon Logo
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -44, 0, 42)
title.Position = UDim2.fromOffset(12, 2)
title.BackgroundTransparency = 1
title.Text = "NhaHub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main
local titleStroke = Instance.new("UIStroke", title)
titleStroke.Color = Color3.fromRGB(0, 255, 255)
titleStroke.Thickness = 2.5
titleStroke.Transparency = 0.2

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -38, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255, 50, 50)
close.Font = Enum.Font.GothamBold
close.TextSize = 20
close.Parent = main
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
local closeStroke = Instance.new("UIStroke", close)
closeStroke.Color = Color3.fromRGB(255, 0, 0)
closeStroke.Thickness = 1.5

close.MouseEnter:Connect(function() TweenService:Create(closeStroke, TweenInfo.new(0.2), {Thickness = 3}):Play() end)
close.MouseLeave:Connect(function() TweenService:Create(closeStroke, TweenInfo.new(0.2), {Thickness = 1.5}):Play() end)
close.Activated:Connect(function() main.Visible = false end)

local sub = Instance.new("TextLabel")
sub.Position = UDim2.fromOffset(12, 40)
sub.Size = UDim2.new(1, -24, 0, 20)
sub.BackgroundTransparency = 1
sub.Text = "SURVIVE DEEP IN THE WOODS"
sub.TextColor3 = Color3.fromRGB(180, 180, 200)
sub.Font = Enum.Font.GothamMedium
sub.TextSize = 9
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.Parent = main

local panel = Instance.new("ScrollingFrame")
panel.Position = UDim2.fromOffset(10, 66)
panel.Size = UDim2.new(1, -20, 1, -76)
panel.BackgroundTransparency = 1
panel.BorderSizePixel = 0
panel.ScrollBarThickness = 3
panel.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
panel.CanvasSize = UDim2.new(0, 0, 0, 0)
panel.ScrollingDirection = Enum.ScrollingDirection.Y
panel.Parent = main

local layout = Instance.new("UIListLayout", panel)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- ==================== LOGIC ====================
local function character() return player.Character end
local function humanoid()
    local c = character()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local flags = {Speed = false, Jump = false, ESP = false, LowFX = false, FPSBoost = false, FastAttack = false}
local original = {WalkSpeed = 16, JumpPower = 50}
local highlights = {}
local espColors = {Color3.fromRGB(255, 50, 50), Color3.fromRGB(50, 150, 255), Color3.fromRGB(50, 255, 100), Color3.fromRGB(255, 200, 50)}
local espColorIndex = 1

local function setESP(enabled)
    for _, h in pairs(highlights) do if h then h:Destroy() end end
    table.clear(highlights)
    if not enabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local h = Instance.new("Highlight")
            h.Name = "NhaHubHighlight"
            h.FillColor = espColors[espColorIndex]
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.FillTransparency = 0.6
            h.Adornee = p.Character
            h.Parent = gui
            highlights[p] = h
        end
    end
end

Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(1) if flags.ESP then setESP(true) end end) end)
Players.PlayerRemoving:Connect(function(p) if highlights[p] then highlights[p]:Destroy() end highlights[p] = nil end)

local function refreshMovement()
    local h = humanoid()
    if not h then return end
    h.WalkSpeed = flags.Speed and 30 or original.WalkSpeed
    h.UseJumpPower = true
    h.JumpPower = flags.Jump and 90 or original.JumpPower
end

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    local h = humanoid()
    if h then
        original.WalkSpeed = h.WalkSpeed
        original.JumpPower = h.JumpPower
        refreshMovement()
    end
    if flags.ESP then setESP(true) end
end)

-- ==================== SMOOTH FAST ATTACK ====================
local fastAttackThread = nil
local attackDelay = 0.05 -- Default 20 hits/sec

local function setFastAttack(enabled)
    if fastAttackThread then
        task.cancel(fastAttackThread)
        fastAttackThread = nil
    end
    if not enabled then return end

    fastAttackThread = task.spawn(function()
        while flags.FastAttack do
            local char = character()
            if char and humanoid() and humanoid().Health > 0 then
                
                -- Method 1: getconnections (Direct UI Fire)
                local pg = player:FindFirstChild("PlayerGui")
                if pg then
                    for _, v in ipairs(pg:GetDescendants()) do
                        if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                            local txt = (v:IsA("TextButton") and string.lower(v.Text)) or ""
                            local nm = string.lower(v.Name)
                            if nm:find("swing") or nm:find("attack") or nm:find("hit") or txt:find("swing") then
                                if getconnections then
                                    pcall(function()
                                        for _, c in pairs(getconnections(v.MouseButton1Click)) do c:Fire() end
                                        for _, c in pairs(getconnections(v.MouseButton1Down)) do c:Fire() end
                                        for _, c in pairs(getconnections(v.Activated)) do c:Fire() end
                                    end)
                                end
                            end
                        end
                    end
                end

                -- Method 2: Force Fire Remotes
                pcall(function()
                    for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                        if v:IsA("RemoteEvent") then
                            local n = string.lower(v.Name)
                            if n == "swing" or n == "attack" or n == "hit" or n == "combat" or n == "damage" then
                                v:FireServer()
                            end
                        end
                    end
                end)

                -- Method 3: Tool Activate
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function()
                        tool.Enabled = true
                        tool:Activate()
                    end)
                end
            end
            task.wait(attackDelay) -- controlled by slider
        end
    end)
end

-- ==================== UI HELPERS (NEON STYLE) ====================
local function addToggle(label, key, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    b.TextColor3 = Color3.fromRGB(200, 200, 220)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.AutoButtonColor = false
    b.Parent = panel
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", b)
    stroke.Color = Color3.fromRGB(50, 50, 70)
    stroke.Thickness = 1.5

    local function draw()
        b.Text = label .. "     [" .. (flags[key] and "ON" or "OFF") .. "]"
        if flags[key] then
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 50, 40), TextColor3 = Color3.fromRGB(0, 255, 150)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 255, 150)}):Play()
        else
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 30), TextColor3 = Color3.fromRGB(200, 200, 220)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 70)}):Play()
        end
    end

    b.MouseEnter:Connect(function() if not flags[key] then TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 255, 255)}):Play() end end)
    b.MouseLeave:Connect(function() if not flags[key] then TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 70)}):Play() end end)

    b.Activated:Connect(function()
        flags[key] = not flags[key]
        -- Little tap animation
        TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0, 34)}):Play()
        task.delay(0.1, function() TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 36)}):Play() end)
        
        if callback then callback(flags[key]) end
        draw()
    end)
    draw()
end

local function addSlider(label, min, max, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 45)
    holder.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    holder.Parent = panel
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)
    local hStroke = Instance.new("UIStroke", holder)
    hStroke.Color = Color3.fromRGB(50, 50, 70)
    hStroke.Thickness = 1.5

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 18)
    lbl.Position = UDim2.fromOffset(8, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. tostring(default)
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -16, 0, 6)
    bar.Position = UDim2.fromOffset(8, 28)
    bar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    bar.Parent = holder
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale((default - min) / (max - min), 1)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, 0, 2, 0)
    track.Position = UDim2.new(0, 0, -0.5, 0)
    track.BackgroundTransparency = 1
    track.Text = ""
    track.Parent = bar

    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.fromScale(rel, 1)}):Play()
        lbl.Text = label .. ": " .. string.format("%.2f", val)
        if callback then pcall(callback, val) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
end

addToggle("Speed", "Speed", refreshMovement)
addToggle("Super Jump", "Jump", refreshMovement)
addToggle("Player ESP", "ESP", setESP)
addToggle("Fast Attack", "FastAttack", setFastAttack)

-- Hook up the slider to the attack delay
addSlider("Atk Delay", 0.01, 0.2, 0.05, function(val)
    attackDelay = val
end)

-- Visuals
local visualBackup = {}
local function applyFPSBoost(enabled)
    if enabled then
        visualBackup.GlobalShadows = Lighting.GlobalShadows
        visualBackup.Effects = {}
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("PostEffect") then
                visualBackup.Effects[obj] = obj.Enabled
                obj.Enabled = false
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                visualBackup.Effects[obj] = obj.Enabled
                obj.Enabled = false
            end
        end
        Lighting.GlobalShadows = false
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    else
        if visualBackup.GlobalShadows ~= nil then Lighting.GlobalShadows = visualBackup.GlobalShadows end
        for obj, wasEnabled in pairs(visualBackup.Effects or {}) do
            if obj and obj.Parent then pcall(function() obj.Enabled = wasEnabled end) end
        end
        table.clear(visualBackup)
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
    end
end

addToggle("Low Graphics", "LowFX", function(on)
    Lighting.GlobalShadows = not on
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then obj.Enabled = not on end
    end
end)
addToggle("FPS Boost", "FPSBoost", applyFPSBoost)

local espColorButton = Instance.new("TextButton")
espColorButton.Size = UDim2.new(1, 0, 0, 36)
espColorButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
espColorButton.TextColor3 = Color3.fromRGB(200, 200, 220)
espColorButton.Font = Enum.Font.GothamBold
espColorButton.TextSize = 12
espColorButton.Text = "ESP Color: Red"
espColorButton.Parent = panel
Instance.new("UICorner", espColorButton).CornerRadius = UDim.new(0, 8)
local esStroke = Instance.new("UIStroke", espColorButton)
esStroke.Color = Color3.fromRGB(50, 50, 70)
esStroke.Thickness = 1.5

local espColorNames = {"Red", "Blue", "Green", "Gold"}
espColorButton.Activated:Connect(function()
    espColorIndex = (espColorIndex % #espColors) + 1
    espColorButton.Text = "ESP Color: " .. espColorNames[espColorIndex]
    if flags.ESP then setESP(true) end
end)

-- ==================== SCRIPT EXECUTOR ====================
local execLabel = Instance.new("TextLabel")
execLabel.Size = UDim2.new(1, 0, 0, 24)
execLabel.BackgroundTransparency = 1
execLabel.Text = "SCRIPT EXECUTOR"
execLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
execLabel.Font = Enum.Font.GothamBold
execLabel.TextSize = 11
execLabel.TextXAlignment = Enum.TextXAlignment.Left
execLabel.Parent = panel

local execBox = Instance.new("TextBox")
execBox.Size = UDim2.new(1, 0, 0, 80)
execBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
execBox.TextColor3 = Color3.fromRGB(200, 200, 220)
execBox.PlaceholderText = "Paste URL or raw Lua code..."
execBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
execBox.Font = Enum.Font.Code
execBox.TextSize = 11
execBox.TextXAlignment = Enum.TextXAlignment.Left
execBox.TextYAlignment = Enum.TextYAlignment.Top
execBox.TextWrapped = true
execBox.ClearTextOnFocus = false
execBox.MultiLine = true
execBox.Text = ""
execBox.Parent = panel
Instance.new("UICorner", execBox).CornerRadius = UDim.new(0, 8)
local eStroke = Instance.new("UIStroke", execBox)
eStroke.Color = Color3.fromRGB(50, 50, 70)
eStroke.Thickness = 1.5

local execBtn = Instance.new("TextButton")
execBtn.Size = UDim2.new(1, 0, 0, 36)
execBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 80)
execBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
execBtn.Font = Enum.Font.GothamBold
execBtn.TextSize = 12
execBtn.Text = "EXECUTE"
execBtn.AutoButtonColor = false
execBtn.Parent = panel
Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 8)
local exStroke = Instance.new("UIStroke", execBtn)
exStroke.Color = Color3.fromRGB(0, 255, 255)
exStroke.Thickness = 1.5

execBtn.Activated:Connect(function()
    local input = execBox.Text
    if not input or input == "" then return end
    execBtn.Text = "RUNNING..."
    task.spawn(function()
        local success, err = pcall(function()
            if input:sub(1, 4):lower() == "http" then
                local code = game:HttpGet(input)
                local fn, loadErr = loadstring(code)
                if not fn then error(loadErr) end
                fn()
            else
                local fn, loadErr = loadstring(input)
                if not fn then error(loadErr) end
                fn()
            end
        end)
        if success then
            execBtn.Text = "SUCCESS!"
            TweenService:Create(execBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 150, 50)}):Play()
        else
            execBtn.Text = "ERROR"
            TweenService:Create(execBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(150, 0, 0)}):Play()
        end
        task.wait(2)
        execBtn.Text = "EXECUTE"
        TweenService:Create(execBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 80, 80)}):Play()
    end)
end)

-- ==================== DRAG + REOPEN ====================
local dragging, dragInput, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragInput = true, input
        dragStart, startPos = input.Position, main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local reopen = Instance.new("TextButton")
reopen.Size = UDim2.fromOffset(58, 58)
reopen.Position = UDim2.new(0, 12, 0.25, 0)
reopen.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
reopen.Text = "NH"
reopen.TextColor3 = Color3.fromRGB(0, 255, 255)
reopen.Font = Enum.Font.GothamBlack
reopen.TextSize = 18
reopen.Visible = false
reopen.Parent = gui
Instance.new("UICorner", reopen).CornerRadius = UDim.new(1, 0)
local reopenStroke = Instance.new("UIStroke", reopen)
reopenStroke.Color = Color3.fromRGB(0, 255, 255)
reopenStroke.Thickness = 2.5

close.Activated:Connect(function() reopen.Visible = true end)
reopen.Activated:Connect(function()
    main.Visible = true
    reopen.Visible = false
end)

print("NhaHub Neon Edition Loaded.")