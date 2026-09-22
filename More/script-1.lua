-- ============================================================
-- Bbslade Mobile (不管有沒有選都強制發送版)
-- ============================================================

local HttpService = game:GetService("HttpService")
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Bbslade Mobile",
    SubTitle = "Remote Control",
    TabWidth = 110,
    Size = UDim2.fromOffset(450, 420),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local MainTab = Window:AddTab({ Title = "⚡ 主控台", Icon = "zap" })
local AnimTab = Window:AddTab({ Title = "💃 動作", Icon = "play" })

getgenv().SpyEnabled = false
getgenv().BlockEnabled = false
getgenv().LoopRepeatActive = false

local MemoryFileName = "Bbslade_Remote_Memory.json"
local CapturedLogs = {}
local DropdownOptions = {}
local SelectedIndex = nil
local DropdownUI = nil

local currentTrack = nil
local loopAnimation = false
local selectedAnimId = "180436334"

local IgnoreKeywords = {
    "move", "movement", "walk", "jump", "step", "position", "cframe", 
    "health", "damage", "heal", "hp", "takedamage", "characterstate",
    "ping", "sync", "physics", "velocity"
}

local function isIgnored(remoteName)
    local lowerName = string.lower(remoteName)
    for _, kw in ipairs(IgnoreKeywords) do
        if string.find(lowerName, kw) then return true end
    end
    return false
end

local function buildDropdownOptions()
    DropdownOptions = {}
    for i, log in ipairs(CapturedLogs) do
        local label = string.format("#%d: [%s] %s", i, log.Method or "Remote", log.Name or "Unknown")
        table.insert(DropdownOptions, label)
    end
    if #DropdownOptions == 0 then
        table.insert(DropdownOptions, "無紀錄 (請先啟動偵測)")
    end
end

local function syncDropdownUI()
    buildDropdownOptions()
    if DropdownUI then
        pcall(function()
            DropdownUI:SetValues(DropdownOptions)
            if SelectedIndex and DropdownOptions[SelectedIndex] then
                DropdownUI:SetValue(DropdownOptions[SelectedIndex])
            end
        end)
    end
end

local function saveMemoryToFile()
    pcall(function()
        local saveData = {}
        for _, log in ipairs(CapturedLogs) do
            table.insert(saveData, {
                Path = log.Path,
                Name = log.Name,
                Method = log.Method,
                Args = log.Args
            })
        end
        writefile(MemoryFileName, HttpService:JSONEncode(saveData))
    end)
end

local function loadMemoryFromFile()
    if isfile and isfile(MemoryFileName) then
        pcall(function()
            local rawData = readfile(MemoryFileName)
            local decoded = HttpService:JSONDecode(rawData)
            if type(decoded) == "table" and #decoded > 0 then
                CapturedLogs = {}
                for _, item in ipairs(decoded) do
                    local inst = nil
                    pcall(function()
                        local pathParts = string.split(item.Path, ".")
                        current = game
                        for i = 2, #pathParts do
                            current = current:FindFirstChild(pathParts[i])
                        end
                        inst = current
                    end)

                    table.insert(CapturedLogs, {
                        Instance = inst,
                        Path = item.Path,
                        Name = item.Name,
                        Method = item.Method,
                        Args = item.Args or {}
                    })
                end
                SelectedIndex = #CapturedLogs -- 預設帶入最後一筆
                syncDropdownUI()
            end
        end)
    end
end

-- Hook
local rawMetatable = getrawmetatable(game)
local oldNamecall = rawMetatable.__namecall
setreadonly(rawMetatable, false)

rawMetatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if (method == "FireServer" or method == "InvokeServer" or method == "fireServer" or method == "invokeServer") then
        if getgenv().SpyEnabled and not checkcaller() then
            task.spawn(function()
                pcall(function()
                    local name = self.Name
                    if isIgnored(name) then return end

                    local path = self:GetFullName()

                    if #CapturedLogs >= 30 then
                        table.remove(CapturedLogs, 1)
                    end

                    table.insert(CapturedLogs, {
                        Instance = self,
                        Method = method,
                        Args = args,
                        Name = name,
                        Path = path
                    })

                    SelectedIndex = #CapturedLogs
                    saveMemoryToFile()
                    syncDropdownUI()
                end)
            end)

            if getgenv().BlockEnabled then return nil end
        end
    end

    return oldNamecall(self, ...)
end)

setreadonly(rawMetatable, true)

-- ============================================================
-- 暴力發送邏輯：只要列表有東西就拿去傳！
-- ============================================================
local function fireSelectedPacket()
    if #CapturedLogs == 0 then return false end
    
    -- 如果沒選到的話，強制自動抓最後一筆（最新發動的）
    local targetIndex = SelectedIndex or #CapturedLogs
    local data = CapturedLogs[targetIndex] or CapturedLogs[#CapturedLogs]
    
    if not data then return false end

    -- 防失效：實體消失則依照路徑重新補載
    if not data.Instance or not data.Instance.Parent then
        pcall(function()
            local pathParts = string.split(data.Path, ".")
            local current = game
            for i = 2, #pathParts do
                current = current:FindFirstChild(pathParts[i])
            end
            data.Instance = current
        end)
    end

    if data and data.Instance then
        pcall(function()
            if data.Method == "FireServer" or data.Method == "fireServer" then
                data.Instance:FireServer(unpack(data.Args))
            elseif data.Method == "InvokeServer" or data.Method == "invokeServer" then
                data.Instance:InvokeServer(unpack(data.Args))
            end
        end)
        return true
    end
    return false
end

-- UI 配置
MainTab:AddToggle("SpyToggle", {
    Title = "📡 啟動抓包",
    Default = false
}):OnChanged(function(Value)
    getgenv().SpyEnabled = Value
end)

DropdownUI = MainTab:AddDropdown("CapturedList", {
    Title = "🎯 選擇 Remote",
    Values = DropdownOptions,
    Multi = false,
    Callback = function(Value)
        if not Value or Value == "" then return end
        
        local indexNum = tonumber(Value:match("^#(%d+)"))
        if not indexNum then
            for idx, opt in ipairs(DropdownOptions) do
                if opt == Value then
                    indexNum = idx
                    break
                end
            end
        end

        if indexNum then
            SelectedIndex = indexNum
        end
    end
})

MainTab:AddButton({
    Title = "▶️ 發送一次 (沒選就傳最新)",
    Callback = function()
        fireSelectedPacket()
        Fluent:Notify({ Title = "🚀 已發送", Content = "不用管有沒有選，直接 Fire！", Duration = 1 })
    end
})

MainTab:AddToggle("LoopToggle", {
    Title = "🔄 無限重複連發",
    Default = false
}):OnChanged(function(Value)
    getgenv().LoopRepeatActive = Value
    if Value then
        task.spawn(function()
            while getgenv().LoopRepeatActive do
                fireSelectedPacket()
                task.wait(0.1)
            end
        end)
    end
end)

MainTab:AddToggle("BlockToggle", {
    Title = "🚫 攔截手動動作",
    Default = false
}):OnChanged(function(Value)
    getgenv().BlockEnabled = Value
end)

MainTab:AddSection("記憶與控制")

MainTab:AddButton({
    Title = "🔄 手動刷新 UI 列表",
    Callback = function()
        syncDropdownUI()
        Fluent:Notify({ Title = "刷新成功", Content = "目前列表共 " .. #CapturedLogs .. " 筆", Duration = 1 })
    end
})

MainTab:AddButton({
    Title = "📂 讀取本地記憶檔",
    Callback = function()
        if isfile and isfile(MemoryFileName) then
            loadMemoryFromFile()
            Fluent:Notify({ Title = "載入成功", Content = "已讀取歷史紀錄", Duration = 1 })
        end
    end
})

MainTab:AddButton({
    Title = "🗑️ 刪除本地記憶檔",
    Callback = function()
        if isfile and isfile(MemoryFileName) then
            delfile(MemoryFileName)
            CapturedLogs = {}
            SelectedIndex = nil
            syncDropdownUI()
            Fluent:Notify({ Title = "刪除成功", Content = "檔案已刪除並清空", Duration = 1 })
        end
    end
})

-- 動畫頁面
local function applyAnimation(id)
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end

    if currentTrack then pcall(function() currentTrack:Stop() end) end

    pcall(function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. tostring(id)
        currentTrack = hum:LoadAnimation(anim)
        currentTrack.Priority = Enum.AnimationPriority.Action4
        currentTrack.Looped = true
        currentTrack:Play()
    end)
end

AnimTab:AddInput("AnimIdInput", {
    Title = "動畫 ID",
    Default = "180436334",
    Numeric = true,
    Callback = function(Value)
        if tonumber(Value) then
            selectedAnimId = Value
            if loopAnimation then applyAnimation(selectedAnimId) end
        end
    end
})

AnimTab:AddToggle("AnimToggle", {
    Title = "動作鎖定",
    Default = false
}):OnChanged(function(Value)
    loopAnimation = Value
    if Value then
        applyAnimation(selectedAnimId)
    else
        if currentTrack then pcall(function() currentTrack:Stop() end) end
    end
end)

loadMemoryFromFile()
Window:SelectTab(1)
