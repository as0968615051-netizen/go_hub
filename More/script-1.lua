task.wait(2)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local SoundService = game:GetService("SoundService")

local Config = {
    FlySpeed = 50,
    WalkSpeed = 22,
    JumpPower = 60,
    Noclip = false,
    Fly = false,
    Recording = false,
    Replaying = false,
}

local MusicList = {
    {Name = "🌮 Taco Tuesday", Id = "rbxassetid://1837849482"},
    {Name = "🎵 Roblox主題曲", Id = "rbxassetid://160791378"},
    {Name = "👻 經典恐怖音樂", Id = "rbxassetid://537347340"},
    {Name = "⚔️ 史詩戰鬥音樂", Id = "rbxassetid://590474268"},
    {Name = "🎉 派對音樂", Id = "rbxassetid://655354831"},
    {Name = "🎹 鋼琴演奏", Id = "rbxassetid://904171977"},
    {Name = "🎸 搖滾音樂", Id = "rbxassetid://470092958"},
    {Name = "🎮 經典遊戲音樂", Id = "rbxassetid://180551658"},
    {Name = "🎵 電子舞曲", Id = "rbxassetid://130833415"},
    {Name = "🎼 交響樂", Id = "rbxassetid://489779885"},
}

local Sound = Instance.new("Sound")
Sound.Parent = SoundService
Sound.Volume = 0.5
Sound.Looped = true
local currentMusicIndex = 1

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 550)
Main.Position = UDim2.new(0.5, -160, 0.5, -275)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ 萬能腳本 v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local TabButtons = {}
local Tabs = {}
local TabNames = {"功能", "音樂", "小遊戲", "錄製"}

for i, name in ipairs(TabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 0, 35)
    btn.Position = UDim2.new((i-1) * 0.25, 0, 0, 40)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(70, 70, 100) or Color3.fromRGB(50, 50, 70)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = Main
    TabButtons[i] = btn
    
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, -80)
    page.Position = UDim2.new(0, 0, 0, 80)
    page.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    page.Visible = i == 1
    page.Parent = Main
    Tabs[i] = page
    
    btn.MouseButton1Click:Connect(function()
        for j, tab in ipairs(Tabs) do
            tab.Visible = (j == i)
        end
        for j, tabBtn in ipairs(TabButtons) do
            tabBtn.BackgroundColor3 = (j == i) and Color3.fromRGB(70, 70, 100) or Color3.fromRGB(50, 50, 70)
        end
    end)
end

local function CreateToggle(parent, text, yPos, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 30)
    btn.Position = UDim2.new(0.75, 0, 0.1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    btn.Text = "開"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Parent = frame
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "開" or "關"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
        callback(state)
    end)
end

CreateToggle(Tabs[1], "✈️ 飛行", 10, function(state)
    Config.Fly = state
end)

CreateToggle(Tabs[1], "👻 穿牆", 60, function(state)
    Config.Noclip = state
end)

CreateToggle(Tabs[1], "🚀 加速", 110, function(state)
    if state then
        Config.WalkSpeed = 50
    else
        Config.WalkSpeed = 22
    end
end)

CreateToggle(Tabs[1], "💀 無敵", 160, function(state)
    if state then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = 999999
            humanoid.Health = 999999
        end
    end
end)

CreateToggle(Tabs[1], "🦘 高跳躍", 210, function(state)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = state and 100 or Config.JumpPower
    end
end)

local musicLabel = Instance.new("TextLabel")
musicLabel.Size = UDim2.new(1, -20, 0, 30)
musicLabel.Position = UDim2.new(0, 10, 0, 10)
musicLabel.BackgroundTransparency = 1
musicLabel.Text = "🎵 經典Roblox音樂"
musicLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
musicLabel.TextSize = 16
musicLabel.Font = Enum.Font.SourceSansBold
musicLabel.Parent = Tabs[2]

local currentSongLabel = Instance.new("TextLabel")
currentSongLabel.Size = UDim2.new(1, -20, 0, 25)
currentSongLabel.Position = UDim2.new(0, 10, 0, 45)
currentSongLabel.BackgroundTransparency = 1
currentSongLabel.Text = "當前: " .. MusicList[1].Name
currentSongLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
currentSongLabel.TextSize = 13
currentSongLabel.Parent = Tabs[2]

for i, music in ipairs(MusicList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, 80 + (i-1) * 35)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.Text = music.Name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Parent = Tabs[2]
    
    btn.MouseButton1Click:Connect(function()
        currentMusicIndex = i
        Sound.SoundId = music.Id
        Sound:Play()
        currentSongLabel.Text = "當前: " .. music.Name
    end)
end

local idBox = Instance.new("TextBox")
idBox.Size = UDim2.new(1, -20, 0, 30)
idBox.Position = UDim2.new(0, 10, 0, 430)
idBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
idBox.PlaceholderText = "輸入音樂ID (rbxassetid)"
idBox.Text = ""
idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
idBox.TextSize = 12
idBox.Parent = Tabs[2]

local playBtn = Instance.new("TextButton")
playBtn.Size = UDim2.new(1, -20, 0, 30)
playBtn.Position = UDim2.new(0, 10, 0, 465)
playBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
playBtn.Text = "▶️ 播放自訂音樂"
playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playBtn.TextSize = 12
playBtn.Parent = Tabs[2]

playBtn.MouseButton1Click:Connect(function()
    local id = tonumber(idBox.Text)
    if id then
        Sound.SoundId = "rbxassetid://" .. id
        Sound:Play()
        currentSongLabel.Text = "當前: 自訂音樂"
    end
end)

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(1, -20, 0, 30)
stopBtn.Position = UDim2.new(0, 10, 0, 500)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopBtn.Text = "⏹️ 停止音樂"
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.TextSize = 12
stopBtn.Parent = Tabs[2]

stopBtn.MouseButton1Click:Connect(function()
    Sound:Stop()
end)

local grid = {}
local score = 0
local gameOver = false

local function Init2048()
    grid = {}
    score = 0
    gameOver = false
    for i = 1, 4 do
        grid[i] = {}
        for j = 1, 4 do
            grid[i][j] = 0
        end
    end
    AddRandomTile()
    AddRandomTile()
end

local function AddRandomTile()
    local empty = {}
    for i = 1, 4 do
        for j = 1, 4 do
            if grid[i][j] == 0 then
                table.insert(empty, {i, j})
            end
        end
    end
    if #empty > 0 then
        local pos = empty[math.random(#empty)]
        grid[pos[1]][pos[2]] = math.random() < 0.9 and 2 or 4
    end
end

local gameLabel = Instance.new("TextLabel")
gameLabel.Size = UDim2.new(1, -20, 0, 30)
gameLabel.Position = UDim2.new(0, 10, 0, 10)
gameLabel.BackgroundTransparency = 1
gameLabel.Text = "🎮 2048 小遊戲"
gameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
gameLabel.TextSize = 16
gameLabel.Font = Enum.Font.SourceSansBold
gameLabel.Parent = Tabs[3]

local scoreLabel = Instance.new("TextLabel")
scoreLabel.Size = UDim2.new(1, -20, 0, 25)
scoreLabel.Position = UDim2.new(0, 10, 0, 45)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Text = "分數: 0"
scoreLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
scoreLabel.TextSize = 14
scoreLabel.Parent = Tabs[3]

local boardFrame = Instance.new("Frame")
boardFrame.Size = UDim2.new(0, 260, 0, 260)
boardFrame.Position = UDim2.new(0.5, -130, 0, 80)
boardFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
boardFrame.Parent = Tabs[3]

local tileLabels = {}
for i = 1, 4 do
    tileLabels[i] = {}
    for j = 1, 4 do
        local tile = Instance.new("Frame")
        tile.Size = UDim2.new(0, 55, 0, 55)
        tile.Position = UDim2.new(0, 10 + (j-1) * 62, 0, 10 + (i-1) * 62)
        tile.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
        tile.Parent = boardFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = ""
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 18
        label.Font = Enum.Font.SourceSansBold
        label.Parent = tile
        
        tileLabels[i][j] = label
    end
end

local function Update2048()
    for i = 1, 4 do
        for j = 1, 4 do
            local value = grid[i][j]
            tileLabels[i][j].Text = value == 0 and "" or tostring(value)
            if value == 0 then
                tileLabels[i][j].Parent.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
            elseif value == 2 then
                tileLabels[i][j].Parent.BackgroundColor3 = Color3.fromRGB(238, 228, 218)
                tileLabels[i][j].TextColor3 = Color3.fromRGB(119, 110, 101)
            elseif value == 4 then
                tileLabels[i][j].Parent.BackgroundColor3 = Color3.fromRGB(237, 224, 200)
                tileLabels[i][j].TextColor3 = Color3.fromRGB(119, 110, 101)
            elseif value == 8 then
                tileLabels[i][j].Parent.BackgroundColor3 = Color3.fromRGB(242, 177, 121)
                tileLabels[i][j].TextColor3 = Color3.fromRGB(255, 255, 255)
            elseif value == 16 then
                tileLabels[i][j].Parent.BackgroundColor3 = Color3.fromRGB(245, 149, 99)
                tileLabels[i][j].TextColor3 = Color3.fromRGB(255, 255, 255)
            elseif value == 32 then
                tileLabels[i][j].Parent.BackgroundColor3 = Color3.fromRGB(246, 124, 95)
                tileLabels[i][j].TextColor3 = Color3.fromRGB(255, 255, 255)
            elseif value == 64 then
                tileLabels[i][j].Parent.BackgroundColor3 = Color3.fromRGB(246, 94, 59)
                tileLabels[i][j].TextColor3 = Color3.fromRGB(255, 255, 255)
            elseif value == 128 then
                tileLabels[i][j].Parent.BackgroundColor3 = Color3.fromRGB(237, 207, 114)
                tileLabels[i][j].TextColor3 = Color3.fromRGB(255, 255, 255)
            elseif value == 256 then
                tileLabels[i][j].Parent.BackgroundColor3 = Color3.fromRGB(237, 204, 97)
                tileLabels[i][j].TextColor3 = Color3.fromRGB(255, 255, 255)
            elseif value == 512 then
                tileLabels[i][j].Parent.BackgroundColor3 = Color3.fromRGB(237, 200, 80)
                tileLabels[i][j].TextColor3 = Color3.fromRGB(255, 255, 255)
            elseif value == 1024 then
                tileLabels[i][j].Parent.BackgroundColor3 = Color3.fromRGB(237, 197, 63)
                tileLabels[i][j].TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                tileLabels[i][j].Parent.BackgroundColor3 = Color3.fromRGB(237, 194, 46)
                tileLabels[i][j].TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
    end
    scoreLabel.Text = "分數: " .. score
end

local function MoveLine(line)
    local newLine = {}
    for i = 1, 4 do
        if line[i] ~= 0 then
            table.insert(newLine, line[i])
        end
    end
    while #newLine < 4 do
        table.insert(newLine, 0)
    end
    
    for i = 1, 3 do
        if newLine[i] ~= 0 and newLine[i] == newLine[i+1] then
            newLine[i] = newLine[i] * 2
            score = score + newLine[i]
            for j = i+1, 3 do
                newLine[j] = newLine[j+1]
            end
            newLine[4] = 0
        end
    end
    return newLine
end

local function Move2048(direction)
    if gameOver then return end
    
    local oldGrid = {}
    for i = 1, 4 do
        oldGrid[i] = {}
        for j = 1, 4 do
            oldGrid[i][j] = grid[i][j]
        end
    end
    
    if direction == "left" then
        for i = 1, 4 do
            grid[i] = MoveLine(grid[i])
        end
    elseif direction == "right" then
        for i = 1, 4 do
            local line = {grid[i][4], grid[i][3], grid[i][2], grid[i][1]}
            line = MoveLine(line)
            grid[i] = {line[4], line[3], line[2], line[1]}
        end
    elseif direction == "up" then
        for j = 1, 4 do
            local line = {grid[1][j], grid[2][j], grid[3][j], grid[4][j]}
            line = MoveLine(line)
            for i = 1, 4 do
                grid[i][j] = line[i]
            end
        end
    elseif direction == "down" then
        for j = 1, 4 do
            local line = {grid[4][j], grid[3][j], grid[2][j], grid[1][j]}
            line = MoveLine(line)
            for i = 1, 4 do
                grid[i][j] = line[5-i]
            end
        end
    end
    
    local changed = false
    for i = 1, 4 do
        for j = 1, 4 do
            if grid[i][j] ~= oldGrid[i][j] then
                changed = true
            end
        end
    end
    
    if changed then
        AddRandomTile()
    end
    
    gameOver = true
    for i = 1, 4 do
        for j = 1, 4 do
            if grid[i][j] == 0 then
                gameOver = false
            end
        end
    end
    if gameOver then
        for i = 1, 3 do
            for j = 1, 3 do
                if grid[i][j] == grid[i+1][j] or grid[i][j] == grid[i][j+1] then
                    gameOver = false
                end
            end
        end
    end
    
    Update2048()
end

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 50, 0, 40)
upBtn.Position = UDim2.new(0.5, -25, 0, 350)
upBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
upBtn.Text = "↑"
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.TextSize = 20
upBtn.Parent = Tabs[3]
upBtn.MouseButton1Click:Connect(function() Move2048("up") end)

local leftBtn = Instance.new("TextButton")
leftBtn.Size = UDim2.new(0, 50, 0, 40)
leftBtn.Position = UDim2.new(0.5, -80, 0, 395)
leftBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
leftBtn.Text = "←"
leftBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
leftBtn.TextSize = 20
leftBtn.Parent = Tabs[3]
leftBtn.MouseButton1Click:Connect(function() Move2048("left") end)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 50, 0, 40)
downBtn.Position = UDim2.new(0.5, -25, 0, 395)
downBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
downBtn.Text = "↓"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.TextSize = 20
downBtn.Parent = Tabs[3]
downBtn.MouseButton1Click:Connect(function() Move2048("down") end)

local rightBtn = Instance.new("TextButton")
rightBtn.Size = UDim2.new(0, 50, 0, 40)
rightBtn.Position = UDim2.new(0.5, 30, 0, 395)
rightBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
rightBtn.Text = "→"
rightBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rightBtn.TextSize = 20
rightBtn.Parent = Tabs[3]
rightBtn.MouseButton1Click:Connect(function() Move2048("right") end)

local restartBtn = Instance.new("TextButton")
restartBtn.Size = UDim2.new(1, -20, 0, 35)
restartBtn.Position = UDim2.new(0, 10, 0, 440)
restartBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
restartBtn.Text = "🔄 重新開始"
restartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
restartBtn.TextSize = 13
restartBtn.Parent = Tabs[3]
restartBtn.MouseButton1Click:Connect(function()
    Init2048()
    Update2048()
end)

Init2048()
Update2048()

local recordedActions = {}
local isRecording = false
local isReplaying = false

local recordLabel = Instance.new("TextLabel")
recordLabel.Size = UDim2.new(1, -20, 0, 30)
recordLabel.Position = UDim2.new(0, 10, 0, 10)
recordLabel.BackgroundTransparency = 1
recordLabel.Text = "🎬 動作錄製"
recordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
recordLabel.TextSize = 16
recordLabel.Font = Enum.Font.SourceSansBold
recordLabel.Parent = Tabs[4]

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 45)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "狀態: 未錄製"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 14
statusLabel.Parent = Tabs[4]

local recordBtn = Instance.new("TextButton")
recordBtn.Size = UDim2.new(1, -20, 0, 40)
recordBtn.Position = UDim2.new(0, 10, 0, 80)
recordBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
recordBtn.Text = "🔴 開始錄製"
recordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
recordBtn.TextSize = 14
recordBtn.Parent = Tabs[4]

recordBtn.MouseButton1Click:Connect(function()
    if not isRecording then
        isRecording = true
        recordedActions = {}
        recordBtn.Text = "⏹️ 停止錄製"
        recordBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "狀態: 錄製中..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        isRecording = false
        recordBtn.Text = "🔴 開始錄製"
        recordBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "狀態: 已錄製 " .. #recordedActions .. " 個動作"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

local replayBtn = Instance.new("TextButton")
replayBtn.Size = UDim2.new(1, -20, 0, 40)
replayBtn.Position = UDim2.new(0, 10, 0, 130)
replayBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
replayBtn.Text = "▶️ 重播動作"
replayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
replayBtn.TextSize = 14
replayBtn.Parent = Tabs[4]

replayBtn.MouseButton1Click:Connect(function()
    if #recordedActions == 0 then return end
    if isReplaying then return end
    
    isReplaying = true
    statusLabel.Text = "狀態: 重播中..."
    statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    
    spawn(function()
        for i, action in ipairs(recordedActions) do
            if not isReplaying then break end
            pcall(function()
                LocalPlayer.Character:SetPrimaryPartCFrame(action.CFrame)
            end)
            task.wait(action.Delay)
        end
        isReplaying = false
        statusLabel.Text = "狀態: 重播完成"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    end)
end)

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(1, -20, 0, 40)
clearBtn.Position = UDim2.new(0, 10, 0, 180)
clearBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
clearBtn.Text = "🗑️ 清除錄製"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.TextSize = 14
clearBtn.Parent = Tabs[4]

clearBtn.MouseButton1Click:Connect(function()
    recordedActions = {}
    isReplaying = false
    statusLabel.Text = "狀態: 已清除"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not root or not humanoid then return end
    
    if Config.Fly then
        humanoid:ChangeState(Enum.HumanoidStateType.Flying)
        humanoid.WalkSpeed = Config.FlySpeed
        
        local moveDirection = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Up) then
            moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.Down) then
            moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.Left) then
            moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.Right) then
            moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + moveDirection.Normalize * Config.FlySpeed * 0.1
        end
    else
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
        humanoid.WalkSpeed = Config.WalkSpeed
    end
    
    if Config.Noclip then
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    if isRecording then
        table.insert(recordedActions, {
            CFrame = root.CFrame,
            Delay = 0.1
        })
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "萬能腳本 v2",
    Text = "✅ 加載成功！UI在屏幕中央",
    Duration = 5
})
