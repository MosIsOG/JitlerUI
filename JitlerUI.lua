-- JitlerUI.lua — Custom UI Library for Jitler Hub
-- WindUI-inspired features: loading screen, tab icons, color picker,
-- paragraph, dialog, multi-profile config, typed notifications, settings tab

local Library = {}
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpSvc = game:GetService("HttpService")

-- Theme
local C = {
    Bg       = Color3.fromRGB(14, 14, 24),
    Sidebar  = Color3.fromRGB(11, 11, 18),
    Header   = Color3.fromRGB(18, 16, 28),
    Surface  = Color3.fromRGB(24, 22, 38),
    Hover    = Color3.fromRGB(34, 30, 52),
    Accent   = Color3.fromRGB(130, 100, 210),
    AccentH  = Color3.fromRGB(155, 125, 235),
    AccentDk = Color3.fromRGB(80, 60, 150),
    Text     = Color3.fromRGB(225, 225, 240),
    Dim      = Color3.fromRGB(120, 120, 150),
    TogOff   = Color3.fromRGB(160, 45, 45),
    TogOn    = Color3.fromRGB(100, 70, 190),
    TogOnH   = Color3.fromRGB(155, 120, 240),
    TogOffH  = Color3.fromRGB(210, 75, 75),
    Border   = Color3.fromRGB(38, 36, 58),
    SliderBg = Color3.fromRGB(32, 30, 48),
    Green    = Color3.fromRGB(80, 200, 120),
    Red      = Color3.fromRGB(220, 70, 70),
    Yellow   = Color3.fromRGB(230, 190, 60),
    Blue     = Color3.fromRGB(70, 140, 220),
}
local F = {
    Bold = Enum.Font.GothamBold,
    Semi = Enum.Font.GothamSemibold,
    Reg  = Enum.Font.Gotham,
}

-- Helpers
local function mk(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
    if props.Parent then o.Parent = props.Parent end
    return o
end

local function tw(obj, goal, dur)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    t:Play(); return t
end

local function rc(parent, r) return mk("UICorner", {CornerRadius = UDim.new(0, r or 6), Parent = parent}) end
local function st(parent, col, th) return mk("UIStroke", {Color = col or C.Border, Thickness = th or 1, Parent = parent}) end
local function pad(parent, t, r, b, l)
    return mk("UIPadding", {PaddingTop=UDim.new(0,t or 0), PaddingRight=UDim.new(0,r or 0), PaddingBottom=UDim.new(0,b or 0), PaddingLeft=UDim.new(0,l or 0), Parent=parent})
end

-- File system helpers (exploit API wrappers)
local function _writefile(path, content)
    if typeof(writefile) == "function" then pcall(writefile, path, content) end
end
local function _readfile(path)
    if typeof(readfile) == "function" then local ok, d = pcall(readfile, path); if ok then return d end end
    return nil
end
local function _isfile(path)
    if typeof(isfile) == "function" then local ok, r = pcall(isfile, path); if ok then return r end end
    return false
end
local function _makefolder(path)
    if typeof(makefolder) == "function" then pcall(makefolder, path) end
end
local function _listfiles(path)
    if typeof(listfiles) == "function" then local ok, r = pcall(listfiles, path); if ok then return r end end
    return {}
end
local function _delfile(path)
    if typeof(delfile) == "function" then pcall(delfile, path) end
end

-- Module-level references
local _notifContainer = nil
local _screenGui = nil

-- Notification type colors
local NotifColors = {
    info    = C.Accent,
    success = C.Green,
    warning = C.Yellow,
    error   = C.Red,
}

-- ==================== NOTIFICATIONS ====================
function Library:Notify(cfg)
    if not _notifContainer then return end
    cfg = cfg or {}
    local title = cfg.Title or "Notification"
    local content = tostring(cfg.Content or "")
    local dur = cfg.Duration or 3
    local nType = cfg.Type or "info"
    local barColor = NotifColors[nType] or C.Accent

    local nf = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,0), BorderSizePixel=0, ClipsDescendants=true, Parent=_notifContainer})
    rc(nf, 6)
    local nfSt = st(nf, barColor, 1)
    nfSt.Transparency = 0.5
    local bar = mk("Frame", {BackgroundColor3=barColor, Size=UDim2.new(0,3,1,-10), Position=UDim2.fromOffset(5,5), BorderSizePixel=0, Parent=nf})
    rc(bar, 2)
    local tLbl = mk("TextLabel", {Text=title, TextColor3=barColor, Font=F.Bold, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-22,0,18), Position=UDim2.fromOffset(16,5), Parent=nf})
    local cLbl = mk("TextLabel", {Text=content, TextColor3=C.Text, Font=F.Reg, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, BackgroundTransparency=1, Size=UDim2.new(1,-22,0,26), Position=UDim2.fromOffset(16,24), Parent=nf})

    -- Slide in
    tw(nf, {Size=UDim2.new(1,0,0,56)}, 0.2)

    task.delay(dur, function()
        if not nf or not nf.Parent then return end
        tw(nf, {Size=UDim2.new(1,0,0,0)}, 0.25)
        tw(tLbl, {TextTransparency=1}, 0.2)
        tw(cLbl, {TextTransparency=1}, 0.2)
        tw(bar, {BackgroundTransparency=1}, 0.2)
        tw(nfSt, {Transparency=1}, 0.2)
        task.wait(0.3)
        if nf and nf.Parent then nf:Destroy() end
    end)
end

-- ==================== WINDOW ====================
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local name = cfg.Name or "Jitler Hub"

    -- Cleanup previous
    local guiName = "JitlerHubUI"
    for _, p in ipairs({game:GetService("CoreGui"), Players.LocalPlayer:FindFirstChild("PlayerGui")}) do
        if p then local old = p:FindFirstChild(guiName); if old then old:Destroy() end end
    end
    if typeof(gethui) == "function" then
        local old = gethui():FindFirstChild(guiName); if old then old:Destroy() end
    end

    local sg = mk("ScreenGui", {Name=guiName, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, ResetOnSpawn=false})
    if typeof(syn) == "table" and syn.protect_gui then
        syn.protect_gui(sg); sg.Parent = game:GetService("CoreGui")
    elseif typeof(gethui) == "function" then
        sg.Parent = gethui()
    else
        sg.Parent = game:GetService("CoreGui")
    end
    _screenGui = sg

    -- ==================== LOADING SCREEN ====================
    local loadingTitle = cfg.LoadingTitle
    local loadingSubtitle = cfg.LoadingSubtitle
    local hasLoading = loadingTitle ~= nil

    local loadScreen, loadFill, loadPct
    if hasLoading then
        loadScreen = mk("Frame", {Name="Loading", BackgroundColor3=C.Bg, Size=UDim2.new(1,0,1,0), ZIndex=100, BorderSizePixel=0, Parent=sg})

        local center = mk("Frame", {BackgroundTransparency=1, Size=UDim2.fromOffset(300,140), Position=UDim2.new(0.5,-150,0.5,-70), ZIndex=101, Parent=loadScreen})

        local loadIcon = cfg.Icon
        if loadIcon and loadIcon ~= "" then
            mk("ImageLabel", {
                Image=loadIcon, BackgroundTransparency=1, Size=UDim2.fromOffset(48,48),
                Position=UDim2.new(0.5,-24,0,0), ScaleType=Enum.ScaleType.Fit, ZIndex=102,
                Parent=center,
            })
        end

        local titleY = (loadIcon and loadIcon ~= "") and 54 or 10
        mk("TextLabel", {
            Text=loadingTitle or "Loading", TextColor3=C.Text, Font=F.Bold, TextSize=20,
            BackgroundTransparency=1, Size=UDim2.new(1,0,0,28), Position=UDim2.fromOffset(0,titleY),
            ZIndex=102, Parent=center,
        })
        mk("TextLabel", {
            Text=loadingSubtitle or "", TextColor3=C.Dim, Font=F.Reg, TextSize=13,
            BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), Position=UDim2.fromOffset(0,titleY+28),
            ZIndex=102, Parent=center,
        })

        local loadBar = mk("Frame", {BackgroundColor3=C.SliderBg, Size=UDim2.new(0.8,0,0,4), Position=UDim2.new(0.1,0,0,titleY+60), BorderSizePixel=0, ZIndex=102, Parent=center})
        rc(loadBar, 2)
        loadFill = mk("Frame", {BackgroundColor3=C.Accent, Size=UDim2.new(0,0,1,0), BorderSizePixel=0, ZIndex=103, Parent=loadBar})
        rc(loadFill, 2)
        loadPct = mk("TextLabel", {
            Text="0%", TextColor3=C.Dim, Font=F.Reg, TextSize=11,
            BackgroundTransparency=1, Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,0,titleY+68),
            ZIndex=102, Parent=center,
        })
    end

    -- Main frame (hidden during loading)
    local main = mk("Frame", {Name="Main", BackgroundColor3=C.Bg, Size=UDim2.fromOffset(580,400), Position=UDim2.new(0.5,-290,0.5,-200), BorderSizePixel=0, ClipsDescendants=true, Visible=not hasLoading, Parent=sg})
    rc(main, 10)
    local mainSt = st(main, C.AccentDk); mainSt.Transparency = 0.4

    -- Header
    local headerIcon = cfg.Icon or nil
    local header = mk("Frame", {Name="Header", BackgroundColor3=C.Header, Size=UDim2.new(1,0,0,40), BorderSizePixel=0, Parent=main})

    if headerIcon and headerIcon ~= "" then
        mk("ImageLabel", {
            Image=headerIcon, BackgroundTransparency=1, Size=UDim2.fromOffset(28,28),
            Position=UDim2.new(0,8,0.5,-14), ScaleType=Enum.ScaleType.Fit, Parent=header,
        })
        mk("TextLabel", {
            Text=name, TextColor3=C.Text, Font=F.Bold, TextSize=15,
            TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1,
            Size=UDim2.new(1,-100,1,0), Position=UDim2.fromOffset(42,0), Parent=header,
        })
    else
        mk("TextLabel", {Text="  \226\172\161 "..name, TextColor3=C.Text, Font=F.Bold, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-90,1,0), Position=UDim2.fromOffset(6,0), Parent=header})
    end

    mk("Frame", {BackgroundColor3=C.Border, Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BorderSizePixel=0, Parent=header})

    local closeBtn = mk("TextButton", {Text="\226\156\149", TextColor3=C.Dim, Font=F.Bold, TextSize=15, BackgroundTransparency=1, Size=UDim2.fromOffset(30,30), Position=UDim2.new(1,-36,0,5), AutoButtonColor=false, Parent=header})
    local minBtn = mk("TextButton", {Text="\226\148\128", TextColor3=C.Dim, Font=F.Bold, TextSize=15, BackgroundTransparency=1, Size=UDim2.fromOffset(30,30), Position=UDim2.new(1,-64,0,5), AutoButtonColor=false, Parent=header})

    for _, b in ipairs({closeBtn, minBtn}) do
        b.MouseEnter:Connect(function() tw(b, {TextColor3=C.Text}, 0.1) end)
        b.MouseLeave:Connect(function() tw(b, {TextColor3=C.Dim}, 0.1) end)
    end

    -- Body (sidebar + content)
    local body = mk("Frame", {Name="Body", BackgroundTransparency=1, Size=UDim2.new(1,0,1,-40), Position=UDim2.fromOffset(0,40), Parent=main})

    -- Sidebar
    local sidebar = mk("Frame", {Name="Sidebar", BackgroundColor3=C.Sidebar, Size=UDim2.new(0,140,1,0), BorderSizePixel=0, Parent=body})
    mk("Frame", {BackgroundColor3=C.Border, Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0), BorderSizePixel=0, Parent=sidebar})

    local tabScroll = mk("ScrollingFrame", {BackgroundTransparency=1, Size=UDim2.new(1,-8,1,-8), Position=UDim2.fromOffset(4,4), ScrollBarThickness=0, CanvasSize=UDim2.new(0,0,0,0), BorderSizePixel=0, Parent=sidebar})
    local tabLayout = mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,2), Parent=tabScroll})
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabScroll.CanvasSize = UDim2.new(0,0,0,tabLayout.AbsoluteContentSize.Y)
    end)

    -- Content area
    local contentArea = mk("Frame", {Name="Content", BackgroundTransparency=1, Size=UDim2.new(1,-140,1,0), Position=UDim2.fromOffset(140,0), Parent=body})

    -- Dialog overlay
    local dialogOverlay = mk("Frame", {Name="DialogOverlay", BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.5, Size=UDim2.new(1,0,1,0), Visible=false, ZIndex=50, Parent=main})

    -- Notification container
    local notifC = mk("Frame", {Name="Notifs", BackgroundTransparency=1, Size=UDim2.new(0,300,1,0), Position=UDim2.new(1,-310,0,10), Parent=sg})
    mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6), VerticalAlignment=Enum.VerticalAlignment.Top, Parent=notifC})
    _notifContainer = notifC

    -- Window state
    local Window = {}
    local tabs = {}
    local activeTab = nil
    local minimized = false

    -- ==================== CONFIG SYSTEM (MULTI-PROFILE) ====================
    local Flags = {}
    local cfgSave = cfg.ConfigurationSaving or {}
    local cfgEnabled = cfgSave.Enabled == true
    local cfgFolder = cfgSave.FolderName or "JitlerHub"
    local cfgDefaultName = cfgSave.FileName or "Default"
    local cfgAutoSave = true
    local _saveThread = nil

    local function GetConfigPath(profileName)
        return cfgFolder .. "/" .. (profileName or cfgDefaultName) .. ".json"
    end

    local function SaveConfig(profileName)
        if not cfgEnabled then return end
        if typeof(writefile) ~= "function" then return end
        pcall(function()
            local data = {}
            for flag, info in pairs(Flags) do data[flag] = info.get() end
            _makefolder(cfgFolder)
            _writefile(GetConfigPath(profileName), HttpSvc:JSONEncode(data))
        end)
    end

    local function DebouncedSave()
        if not cfgEnabled or not cfgAutoSave then return end
        if _saveThread then pcall(task.cancel, _saveThread) end
        _saveThread = task.delay(0.5, function()
            _saveThread = nil
            SaveConfig()
        end)
    end

    local function LoadConfig(profileName)
        if not cfgEnabled then return end
        local content = _readfile(GetConfigPath(profileName))
        if not content then return end
        local ok, data = pcall(HttpSvc.JSONDecode, HttpSvc, content)
        if not ok or type(data) ~= "table" then return end
        for flag, val in pairs(data) do
            if Flags[flag] then pcall(Flags[flag].set, val) end
        end
    end

    local function DeleteConfig(profileName)
        if not cfgEnabled then return end
        local path = GetConfigPath(profileName)
        if _isfile(path) then _delfile(path) end
    end

    local function ListConfigs()
        if not cfgEnabled then return {} end
        local files = _listfiles(cfgFolder)
        local profiles = {}
        for _, f in ipairs(files) do
            local n = f:match("([^/\\]+)%.json$")
            if n then table.insert(profiles, n) end
        end
        return profiles
    end

    function Window:SaveConfig(pname) SaveConfig(pname) end
    function Window:LoadConfig(pname) LoadConfig(pname) end
    function Window:DeleteConfig(pname) DeleteConfig(pname) end
    function Window:ListConfigs() return ListConfigs() end

    -- ==================== DIALOG SYSTEM ====================
    function Window:Dialog(dialogCfg)
        dialogCfg = dialogCfg or {}
        local title = dialogCfg.Title or "Confirm"
        local dcontent = dialogCfg.Content or ""
        local buttons = dialogCfg.Buttons or {}

        for _, c in ipairs(dialogOverlay:GetChildren()) do c:Destroy() end
        dialogOverlay.Visible = true

        local panel = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.fromOffset(300,0), Position=UDim2.new(0.5,-150,0.5,-65), BorderSizePixel=0, ClipsDescendants=true, ZIndex=51, Parent=dialogOverlay})
        rc(panel, 8)
        st(panel, C.AccentDk)

        mk("TextLabel", {Text=title, TextColor3=C.Text, Font=F.Bold, TextSize=15, BackgroundTransparency=1, Size=UDim2.new(1,-20,0,30), Position=UDim2.fromOffset(10,8), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=52, Parent=panel})
        mk("TextLabel", {Text=dcontent, TextColor3=C.Dim, Font=F.Reg, TextSize=12, TextWrapped=true, BackgroundTransparency=1, Size=UDim2.new(1,-20,0,40), Position=UDim2.fromOffset(10,38), TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, ZIndex=52, Parent=panel})

        local btnRow = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-16,0,32), Position=UDim2.fromOffset(8,88), ZIndex=52, Parent=panel})
        mk("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6), HorizontalAlignment=Enum.HorizontalAlignment.Right, Parent=btnRow})

        local function closeDialog()
            tw(panel, {Size=UDim2.fromOffset(300,0)}, 0.15)
            task.delay(0.15, function() dialogOverlay.Visible = false end)
        end

        for i, bCfg in ipairs(buttons) do
            local isAccent = i == 1
            local db = mk("TextButton", {
                Text=bCfg.Name or "OK", TextColor3=isAccent and C.Text or C.Dim,
                Font=F.Semi, TextSize=12, BackgroundColor3=isAccent and C.Accent or C.Bg,
                Size=UDim2.fromOffset(80,28), BorderSizePixel=0, AutoButtonColor=false,
                LayoutOrder=i, ZIndex=53, Parent=btnRow,
            })
            rc(db, 4)
            db.MouseButton1Click:Connect(function()
                closeDialog()
                if bCfg.Callback then pcall(bCfg.Callback) end
            end)
            db.MouseEnter:Connect(function() tw(db, {BackgroundColor3=isAccent and C.AccentH or C.Hover}, 0.08) end)
            db.MouseLeave:Connect(function() tw(db, {BackgroundColor3=isAccent and C.Accent or C.Bg}, 0.08) end)
        end

        tw(panel, {Size=UDim2.fromOffset(300,130)}, 0.2)
    end

    -- ==================== DESTROY ====================
    function Window:Destroy()
        if sg then sg:Destroy() end
        _notifContainer = nil
        _screenGui = nil
    end
    Library.Destroy = function() if sg then sg:Destroy() end end

    -- Dragging
    local dragging, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Minimize
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tw(main, {Size = UDim2.fromOffset(580, 40)}, 0.2); body.Visible = false
        else
            body.Visible = true; tw(main, {Size = UDim2.fromOffset(580, 400)}, 0.2)
        end
    end)

    -- Close (hide)
    closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)

    -- Toggle visibility: RightControl
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightControl then main.Visible = not main.Visible end
    end)

    -- Tab selection
    local function selectTab(tabName)
        for _, t in ipairs(tabs) do
            if t.name == tabName then
                t.content.Visible = true
                tw(t.button, {BackgroundColor3 = C.Accent, BackgroundTransparency = 0.75}, 0.15)
                tw(t.indicator, {BackgroundTransparency = 0}, 0.15)
                if t.label then t.label.TextColor3 = C.Text end
                activeTab = tabName
            else
                t.content.Visible = false
                tw(t.button, {BackgroundColor3 = C.Sidebar, BackgroundTransparency = 1}, 0.15)
                tw(t.indicator, {BackgroundTransparency = 1}, 0.15)
                if t.label then t.label.TextColor3 = C.Dim end
            end
        end
    end

    -- ==================== CREATE TAB ====================
    -- Supports: Window:CreateTab("Name") or Window:CreateTab({Name="Name", Icon="rbxassetid://..."})
    function Window:CreateTab(tabArg)
        local tabName, tabIcon
        if type(tabArg) == "table" then
            tabName = tabArg.Name or "Tab"
            tabIcon = tabArg.Icon
        else
            tabName = tostring(tabArg or "Tab")
            tabIcon = nil
        end

        local Tab = {}
        local order = 0
        local isFirst = #tabs == 0

        -- Tab button
        local btn = mk("TextButton", {
            Text = "",
            TextColor3 = isFirst and C.Text or C.Dim,
            Font = F.Semi, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = isFirst and C.Accent or C.Sidebar,
            BackgroundTransparency = isFirst and 0.75 or 1,
            Size = UDim2.new(1, 0, 0, 32),
            BorderSizePixel = 0, AutoButtonColor = false,
            LayoutOrder = #tabs,
            Parent = tabScroll,
        })
        rc(btn, 6)

        -- Tab icon + label inside button
        local textOffset = 12
        if tabIcon and tabIcon ~= "" then
            mk("ImageLabel", {
                Image = tabIcon, BackgroundTransparency = 1,
                Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 8, 0.5, -8),
                ScaleType = Enum.ScaleType.Fit, Parent = btn,
            })
            textOffset = 28
        end
        local tabLabel = mk("TextLabel", {
            Text = tabName, TextColor3 = isFirst and C.Text or C.Dim,
            Font = F.Semi, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1, Size = UDim2.new(1, -textOffset-4, 1, 0),
            Position = UDim2.fromOffset(textOffset, 0), Parent = btn,
        })

        -- Active indicator bar
        local indicator = mk("Frame", {
            BackgroundColor3 = C.Accent,
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = isFirst and 0 or 1,
            Parent = btn,
        })
        rc(indicator, 2)

        -- Content scroll frame
        local content = mk("ScrollingFrame", {
            Name = tabName,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -16, 1, -8),
            Position = UDim2.fromOffset(8, 4),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = C.AccentDk,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BorderSizePixel = 0,
            Visible = isFirst,
            Parent = contentArea,
        })
        local cLayout = mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,4), Parent=content})
        cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, cLayout.AbsoluteContentSize.Y + 12)
        end)

        local tabData = {name=tabName, button=btn, content=content, indicator=indicator, label=tabLabel}
        table.insert(tabs, tabData)
        if isFirst then activeTab = tabName end

        btn.MouseButton1Click:Connect(function() selectTab(tabName) end)
        btn.MouseEnter:Connect(function()
            if activeTab ~= tabName then tw(btn, {BackgroundTransparency=0.85, BackgroundColor3=C.Hover}, 0.1) end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab ~= tabName then tw(btn, {BackgroundTransparency=1, BackgroundColor3=C.Sidebar}, 0.1) end
        end)

        local function nextOrder() order = order + 1; return order end

        -- ==================== SECTION ====================
        function Tab:CreateSection(sectionName)
            local sec = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,26), LayoutOrder=nextOrder(), Parent=content})
            mk("TextLabel", {
                Text="\226\148\128\226\148\128 "..sectionName.." \226\148\128\226\148\128", TextColor3=C.Dim, Font=F.Semi, TextSize=12,
                BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=sec,
            })
        end

        -- ==================== TOGGLE ====================
        function Tab:CreateToggle(tcfg)
            local value = tcfg.CurrentValue or false
            local toggle = {Value = value}

            local hasDesc = tcfg.Description and tcfg.Description ~= ""
            local frameH = hasDesc and 48 or 34

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,frameH), BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=content})
            rc(frame, 6)

            mk("TextLabel", {
                Text=tcfg.Name or "Toggle", TextColor3=C.Text, Font=F.Reg, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1,
                Size=UDim2.new(1,-60,0,20), Position=UDim2.fromOffset(10, hasDesc and 4 or 7), Parent=frame,
            })

            if hasDesc then
                mk("TextLabel", {
                    Text=tcfg.Description, TextColor3=C.Dim, Font=F.Reg, TextSize=10,
                    TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1,
                    Size=UDim2.new(1,-60,0,14), Position=UDim2.fromOffset(10,24), Parent=frame,
                })
            end

            local swBg = mk("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                Size=UDim2.fromOffset(38,20), Position=UDim2.new(1,-48,0.5,-10),
                BorderSizePixel=0, Parent=frame,
            })
            rc(swBg, 10)
            local swGrad = mk("UIGradient", {
                Color = ColorSequence.new(
                    value and C.TogOn or C.TogOff,
                    value and C.TogOnH or C.TogOffH
                ),
                Parent = swBg,
            })
            local circle = mk("Frame", {
                BackgroundColor3=C.Text, Size=UDim2.fromOffset(16,16),
                Position = value and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2),
                BorderSizePixel=0, Parent=swBg,
            })
            rc(circle, 8)

            local function updateVis(v)
                swGrad.Color = ColorSequence.new(
                    v and C.TogOn or C.TogOff,
                    v and C.TogOnH or C.TogOffH
                )
                tw(circle, {Position = v and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2)}, 0.15)
            end

            function toggle:Set(v)
                if v == value then return end
                value = v; toggle.Value = v; updateVis(v)
                if tcfg.Callback then pcall(tcfg.Callback, v) end
            end

            local overlay = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=2, AutoButtonColor=false, Parent=frame})
            overlay.MouseButton1Click:Connect(function()
                value = not value; toggle.Value = value; updateVis(value)
                if tcfg.Callback then pcall(tcfg.Callback, value) end
                DebouncedSave()
            end)
            overlay.MouseEnter:Connect(function() tw(frame, {BackgroundColor3=C.Hover}, 0.1) end)
            overlay.MouseLeave:Connect(function() tw(frame, {BackgroundColor3=C.Surface}, 0.1) end)

            if tcfg.Flag then
                Flags[tcfg.Flag] = {
                    get = function() return value end,
                    set = function(v) toggle:Set(v == true) end,
                }
            end

            return toggle
        end

        -- ==================== SLIDER ====================
        function Tab:CreateSlider(scfg)
            local range = scfg.Range or {0, 100}
            local mn, mx = range[1], range[2]
            local inc = scfg.Increment or 1
            local suffix = scfg.Suffix or ""
            local value = math.clamp(scfg.CurrentValue or mn, mn, mx)
            local slider = {Value = value}

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,50), BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=content})
            rc(frame, 6)

            mk("TextLabel", {
                Text=scfg.Name or "Slider", TextColor3=C.Text, Font=F.Reg, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1,
                Size=UDim2.new(0.6,0,0,20), Position=UDim2.fromOffset(10,4), Parent=frame,
            })
            local valLbl = mk("TextLabel", {
                Text=tostring(value)..suffix, TextColor3=C.AccentH, Font=F.Semi, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Right, BackgroundTransparency=1,
                Size=UDim2.new(0.4,-14,0,20), Position=UDim2.new(0.6,0,0,4), Parent=frame,
            })

            local track = mk("Frame", {BackgroundColor3=C.SliderBg, Size=UDim2.new(1,-20,0,6), Position=UDim2.new(0,10,0,34), BorderSizePixel=0, Parent=frame})
            rc(track, 3)
            local pct = (value - mn) / math.max(mx - mn, 0.001)
            local fill = mk("Frame", {BackgroundColor3=Color3.new(1,1,1), Size=UDim2.new(pct,0,1,0), BorderSizePixel=0, Parent=track})
            rc(fill, 3)
            mk("UIGradient", {Color=ColorSequence.new(C.TogOn, C.TogOnH), Parent=fill})

            local function updateSlider(v)
                v = math.clamp(v, mn, mx)
                v = math.floor(v / inc + 0.5) * inc
                v = math.clamp(v, mn, mx)
                if inc >= 1 then v = math.floor(v + 0.5) end
                value = v; slider.Value = v
                fill.Size = UDim2.new((v - mn) / math.max(mx - mn, 0.001), 0, 1, 0)
                valLbl.Text = tostring(v) .. suffix
                if scfg.Callback then pcall(scfg.Callback, v) end
                DebouncedSave()
            end

            function slider:Set(v) updateSlider(v) end

            local sliding = false
            local hitArea = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,0,26), Position=UDim2.new(0,0,0,24), AutoButtonColor=false, Parent=frame})

            hitArea.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                    updateSlider(mn + rel * (mx - mn))
                end
            end)
            UIS.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                    updateSlider(mn + rel * (mx - mn))
                end
            end)
            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)

            frame.MouseEnter:Connect(function() tw(frame, {BackgroundColor3=C.Hover}, 0.1) end)
            frame.MouseLeave:Connect(function() tw(frame, {BackgroundColor3=C.Surface}, 0.1) end)

            if scfg.Flag then
                Flags[scfg.Flag] = {
                    get = function() return value end,
                    set = function(v) slider:Set(tonumber(v) or value) end,
                }
            end

            return slider
        end

        -- ==================== BUTTON ====================
        function Tab:CreateButton(bcfg)
            local btn2 = mk("TextButton", {
                Text=bcfg.Name or "Button", TextColor3=C.Text, Font=F.Semi, TextSize=13,
                BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,34), BorderSizePixel=0,
                AutoButtonColor=false, LayoutOrder=nextOrder(), Parent=content,
            })
            rc(btn2, 6)
            btn2.MouseButton1Click:Connect(function()
                tw(btn2, {BackgroundColor3=C.Accent}, 0.08)
                task.delay(0.12, function() tw(btn2, {BackgroundColor3=C.Surface}, 0.15) end)
                if bcfg.Callback then pcall(bcfg.Callback) end
            end)
            btn2.MouseEnter:Connect(function() tw(btn2, {BackgroundColor3=C.Hover}, 0.1) end)
            btn2.MouseLeave:Connect(function() tw(btn2, {BackgroundColor3=C.Surface}, 0.1) end)
        end

        -- ==================== DROPDOWN ====================
        function Tab:CreateDropdown(dcfg)
            local options = dcfg.Options or {}
            local current = dcfg.CurrentOption or (options[1] or "")
            local dropdown = {Value = current}
            local isOpen = false
            local closedH, optH = 34, 28

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,closedH), BorderSizePixel=0, ClipsDescendants=true, LayoutOrder=nextOrder(), Parent=content})
            rc(frame, 6)

            mk("TextLabel", {
                Text=dcfg.Name or "Dropdown", TextColor3=C.Text, Font=F.Reg, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1,
                Size=UDim2.new(0.5,0,0,closedH), Position=UDim2.fromOffset(10,0), Parent=frame,
            })
            local selLbl = mk("TextLabel", {
                Text=current.." \226\150\188", TextColor3=C.AccentH, Font=F.Semi, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Right, BackgroundTransparency=1,
                Size=UDim2.new(0.5,-14,0,closedH), Position=UDim2.new(0.5,0,0,0), Parent=frame,
            })

            local toggleBtn2 = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,0,closedH), ZIndex=2, AutoButtonColor=false, Parent=frame})

            local optContainer = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-8,0,#options*optH), Position=UDim2.new(0,4,0,closedH+2), Parent=frame})
            mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,1), Parent=optContainer})

            local function setCurrent(val)
                current = val; dropdown.Value = val; selLbl.Text = val .. " \226\150\188"
                if dcfg.Callback then pcall(dcfg.Callback, val) end
                DebouncedSave()
            end
            function dropdown:Set(val) setCurrent(val) end

            for i, opt in ipairs(options) do
                local ob = mk("TextButton", {
                    Text="  "..opt, TextColor3=C.Text, Font=F.Reg, TextSize=12,
                    TextXAlignment=Enum.TextXAlignment.Left, BackgroundColor3=C.Bg,
                    Size=UDim2.new(1,0,0,optH), BorderSizePixel=0, AutoButtonColor=false,
                    LayoutOrder=i, Parent=optContainer,
                })
                rc(ob, 4)
                ob.MouseButton1Click:Connect(function()
                    setCurrent(opt); isOpen = false
                    tw(frame, {Size=UDim2.new(1,0,0,closedH)}, 0.15)
                end)
                ob.MouseEnter:Connect(function() tw(ob, {BackgroundColor3=C.Hover}, 0.08) end)
                ob.MouseLeave:Connect(function() tw(ob, {BackgroundColor3=C.Bg}, 0.08) end)
            end

            toggleBtn2.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local openH = closedH + 6 + #options * (optH + 1)
                tw(frame, {Size=UDim2.new(1,0,0,isOpen and openH or closedH)}, 0.2)
                selLbl.Text = current .. (isOpen and " \226\150\178" or " \226\150\188")
            end)

            if dcfg.Flag then
                Flags[dcfg.Flag] = {
                    get = function() return current end,
                    set = function(v) dropdown:Set(tostring(v)) end,
                }
            end

            return dropdown
        end

        -- ==================== INPUT ====================
        function Tab:CreateInput(icfg)
            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,34), BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=content})
            rc(frame, 6)
            mk("TextLabel", {
                Text=icfg.Name or "Input", TextColor3=C.Text, Font=F.Reg, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1,
                Size=UDim2.new(0.4,0,1,0), Position=UDim2.fromOffset(10,0), Parent=frame,
            })
            local box = mk("TextBox", {
                Text="", PlaceholderText=icfg.PlaceholderText or "...", PlaceholderColor3=C.Dim,
                TextColor3=C.Text, Font=F.Reg, TextSize=12, BackgroundColor3=C.Bg,
                Size=UDim2.new(0.55,-10,0,24), Position=UDim2.new(0.45,0,0.5,-12),
                BorderSizePixel=0, ClearTextOnFocus=false, Parent=frame,
            })
            rc(box, 4); pad(box, 0, 6, 0, 6)

            if icfg.Callback then
                box.FocusLost:Connect(function()
                    pcall(icfg.Callback, box.Text)
                    if icfg.RemoveTextAfterFocusLost then box.Text = "" end
                end)
            end
        end

        -- ==================== KEYBIND ====================
        function Tab:CreateKeybind(kcfg)
            local currentKey = kcfg.CurrentKeybind or "F"
            local listening = false

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,34), BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=content})
            rc(frame, 6)
            mk("TextLabel", {
                Text=kcfg.Name or "Keybind", TextColor3=C.Text, Font=F.Reg, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1,
                Size=UDim2.new(1,-60,1,0), Position=UDim2.fromOffset(10,0), Parent=frame,
            })
            local keyBtn = mk("TextButton", {
                Text="["..currentKey.."]", TextColor3=C.AccentH, Font=F.Semi, TextSize=12,
                BackgroundColor3=C.Bg, Size=UDim2.fromOffset(44,24),
                Position=UDim2.new(1,-52,0.5,-12), BorderSizePixel=0, AutoButtonColor=false, Parent=frame,
            })
            rc(keyBtn, 4)

            keyBtn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true; keyBtn.Text = "[...]"
                tw(keyBtn, {BackgroundColor3=C.AccentDk}, 0.1)
            end)

            UIS.InputBegan:Connect(function(input, gp)
                if listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode.Name
                        keyBtn.Text = "["..currentKey.."]"
                        listening = false
                        tw(keyBtn, {BackgroundColor3=C.Bg}, 0.1)
                        DebouncedSave()
                    end
                    return
                end
                if not gp and input.KeyCode ~= Enum.KeyCode.Unknown then
                    if input.KeyCode.Name == currentKey then
                        if kcfg.Callback then pcall(kcfg.Callback) end
                    end
                end
            end)

            frame.MouseEnter:Connect(function() tw(frame, {BackgroundColor3=C.Hover}, 0.1) end)
            frame.MouseLeave:Connect(function() tw(frame, {BackgroundColor3=C.Surface}, 0.1) end)

            if kcfg.Flag then
                Flags[kcfg.Flag] = {
                    get = function() return currentKey end,
                    set = function(v)
                        if type(v) == "string" and #v > 0 then
                            currentKey = v; keyBtn.Text = "[" .. v .. "]"
                        end
                    end,
                }
            end
        end

        -- ==================== LABEL ====================
        function Tab:CreateLabel(text)
            local label = {}
            local lbl = mk("TextLabel", {
                Text=text or "", TextColor3=C.Dim, Font=F.Reg, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true,
                BackgroundTransparency=1, Size=UDim2.new(1,-10,0,20),
                LayoutOrder=nextOrder(), Parent=content,
            })
            pad(lbl, 0, 0, 0, 10)
            function label:Set(newText) lbl.Text = newText end
            return label
        end

        -- ==================== PARAGRAPH ====================
        function Tab:CreateParagraph(pcfg2)
            pcfg2 = pcfg2 or {}
            local para = {}
            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,60), BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=content})
            rc(frame, 6)
            local accent = mk("Frame", {BackgroundColor3=C.Accent, Size=UDim2.new(0,3,1,-10), Position=UDim2.fromOffset(5,5), BorderSizePixel=0, Parent=frame})
            rc(accent, 2)
            local titleLbl = mk("TextLabel", {
                Text=pcfg2.Title or "", TextColor3=C.Text, Font=F.Bold, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1,
                Size=UDim2.new(1,-22,0,18), Position=UDim2.fromOffset(16,6), Parent=frame,
            })
            local contentLbl = mk("TextLabel", {
                Text=pcfg2.Content or "", TextColor3=C.Dim, Font=F.Reg, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, TextYAlignment=Enum.TextYAlignment.Top,
                BackgroundTransparency=1, Size=UDim2.new(1,-22,0,30), Position=UDim2.fromOffset(16,26), Parent=frame,
            })

            local function resize()
                local ts = game:GetService("TextService")
                local bounds = ts:GetTextSize(contentLbl.Text, 12, F.Reg, Vector2.new(math.max(frame.AbsoluteSize.X - 22, 100), 1000))
                local h = math.max(60, 30 + bounds.Y + 10)
                frame.Size = UDim2.new(1, 0, 0, h)
                contentLbl.Size = UDim2.new(1, -22, 0, bounds.Y + 4)
            end
            task.defer(resize)

            function para:Set(cfg2)
                if cfg2.Title then titleLbl.Text = cfg2.Title end
                if cfg2.Content then contentLbl.Text = cfg2.Content; task.defer(resize) end
            end
            return para
        end

        -- ==================== COLOR PICKER ====================
        function Tab:CreateColorPicker(ccfg)
            ccfg = ccfg or {}
            local value = ccfg.Default or Color3.fromRGB(130, 100, 210)
            local picker = {Value = value}
            local pickerOpen = false

            local closedH = 34
            local openH = 130

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,closedH), BorderSizePixel=0, ClipsDescendants=true, LayoutOrder=nextOrder(), Parent=content})
            rc(frame, 6)

            mk("TextLabel", {
                Text=ccfg.Name or "Color", TextColor3=C.Text, Font=F.Reg, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1,
                Size=UDim2.new(1,-50,0,closedH), Position=UDim2.fromOffset(10,0), Parent=frame,
            })

            local preview = mk("Frame", {
                BackgroundColor3=value, Size=UDim2.fromOffset(24,18),
                Position=UDim2.new(1,-36,0,8), BorderSizePixel=0, Parent=frame,
            })
            rc(preview, 4)
            st(preview, C.Border)

            local previewBtn = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,0,closedH), ZIndex=2, AutoButtonColor=false, Parent=frame})

            -- RGB sliders
            local cR, cG, cB = value.R, value.G, value.B
            local channelSliders = {}

            local function updateColor()
                value = Color3.new(math.clamp(cR,0,1), math.clamp(cG,0,1), math.clamp(cB,0,1))
                picker.Value = value
                preview.BackgroundColor3 = value
                if ccfg.Callback then pcall(ccfg.Callback, value) end
                DebouncedSave()
            end

            local channels = {
                {"R", function() return cR end, function(v) cR = v end},
                {"G", function() return cG end, function(v) cG = v end},
                {"B", function() return cB end, function(v) cB = v end},
            }

            for ci, ch in ipairs(channels) do
                local chName, getV, setV = ch[1], ch[2], ch[3]
                local yOff = closedH + 4 + (ci - 1) * 28

                mk("TextLabel", {
                    Text=chName, TextColor3=C.Dim, Font=F.Semi, TextSize=11,
                    BackgroundTransparency=1, Size=UDim2.fromOffset(16, 20),
                    Position=UDim2.fromOffset(10, yOff + 2), Parent=frame,
                })

                local chTrack = mk("Frame", {BackgroundColor3=C.SliderBg, Size=UDim2.new(1,-60,0,6), Position=UDim2.new(0,30,0,yOff+8), BorderSizePixel=0, Parent=frame})
                rc(chTrack, 3)
                local chFill = mk("Frame", {BackgroundColor3=C.Accent, Size=UDim2.new(getV(),0,1,0), BorderSizePixel=0, Parent=chTrack})
                rc(chFill, 3)

                local chVal = mk("TextLabel", {
                    Text=tostring(math.floor(getV()*255)), TextColor3=C.AccentH, Font=F.Semi, TextSize=10,
                    BackgroundTransparency=1, Size=UDim2.fromOffset(24,20),
                    Position=UDim2.new(1,-28,0,yOff+1), TextXAlignment=Enum.TextXAlignment.Right, Parent=frame,
                })

                local chSliding = false
                local chHit = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,-60,0,20), Position=UDim2.new(0,30,0,yOff), AutoButtonColor=false, Parent=frame})

                chHit.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        chSliding = true
                        local pctV = math.clamp((input.Position.X - chTrack.AbsolutePosition.X) / math.max(chTrack.AbsoluteSize.X, 1), 0, 1)
                        setV(pctV); chFill.Size = UDim2.new(pctV,0,1,0); chVal.Text = tostring(math.floor(pctV*255))
                        updateColor()
                    end
                end)
                UIS.InputChanged:Connect(function(input)
                    if chSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pctV = math.clamp((input.Position.X - chTrack.AbsolutePosition.X) / math.max(chTrack.AbsoluteSize.X, 1), 0, 1)
                        setV(pctV); chFill.Size = UDim2.new(pctV,0,1,0); chVal.Text = tostring(math.floor(pctV*255))
                        updateColor()
                    end
                end)
                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then chSliding = false end
                end)

                table.insert(channelSliders, {fill=chFill, valLbl=chVal, getV=getV})
            end

            previewBtn.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                tw(frame, {Size=UDim2.new(1,0,0,pickerOpen and openH or closedH)}, 0.2)
            end)

            function picker:Set(col)
                if typeof(col) ~= "Color3" then return end
                cR, cG, cB = col.R, col.G, col.B
                value = col; picker.Value = col; preview.BackgroundColor3 = col
                for _, s in ipairs(channelSliders) do
                    s.fill.Size = UDim2.new(s.getV(), 0, 1, 0)
                    s.valLbl.Text = tostring(math.floor(s.getV() * 255))
                end
            end

            if ccfg.Flag then
                Flags[ccfg.Flag] = {
                    get = function() return {R=math.floor(cR*255), G=math.floor(cG*255), B=math.floor(cB*255)} end,
                    set = function(v)
                        if type(v) == "table" and v.R then
                            picker:Set(Color3.fromRGB(v.R, v.G, v.B))
                        end
                    end,
                }
            end

            frame.MouseEnter:Connect(function() tw(frame, {BackgroundColor3=C.Hover}, 0.1) end)
            frame.MouseLeave:Connect(function() tw(frame, {BackgroundColor3=C.Surface}, 0.1) end)

            return picker
        end

        return Tab
    end

    -- ==================== BUILT-IN SETTINGS TAB ====================
    if cfgEnabled then
        local SettingsTab = Window:CreateTab({Name="Settings", Icon=""})

        SettingsTab:CreateSection("Configuration")

        local profileList = ListConfigs()
        if #profileList == 0 then profileList = {cfgDefaultName} end

        local currentProfile = cfgDefaultName
        SettingsTab:CreateDropdown({
            Name = "Config Profile",
            Options = profileList,
            CurrentOption = cfgDefaultName,
            Callback = function(v)
                currentProfile = type(v) == "table" and v[1] or v
            end,
        })

        SettingsTab:CreateButton({Name="Load Config", Callback=function()
            LoadConfig(currentProfile)
            Library:Notify({Title="Config", Content="Loaded profile: "..currentProfile, Duration=2, Type="success"})
        end})

        SettingsTab:CreateButton({Name="Save Config", Callback=function()
            SaveConfig(currentProfile)
            Library:Notify({Title="Config", Content="Saved profile: "..currentProfile, Duration=2, Type="success"})
        end})

        SettingsTab:CreateButton({Name="Delete Config", Callback=function()
            Window:Dialog({
                Title = "Delete Profile",
                Content = "Are you sure you want to delete '"..currentProfile.."'?",
                Buttons = {
                    {Name = "Delete", Callback = function()
                        DeleteConfig(currentProfile)
                        Library:Notify({Title="Config", Content="Deleted: "..currentProfile, Duration=2, Type="warning"})
                    end},
                    {Name = "Cancel", Callback = function() end},
                }
            })
        end})

        SettingsTab:CreateInput({
            Name = "New Profile",
            PlaceholderText = "Profile name...",
            RemoveTextAfterFocusLost = true,
            Callback = function(text)
                if text and #text > 0 then
                    text = text:gsub("[^%w%-%_ ]", "")
                    if #text > 0 then
                        SaveConfig(text)
                        Library:Notify({Title="Config", Content="Created profile: "..text, Duration=2, Type="success"})
                    end
                end
            end,
        })

        SettingsTab:CreateSection("Settings")

        SettingsTab:CreateToggle({
            Name = "Auto-Save",
            Description = "Automatically save config when settings change",
            CurrentValue = true,
            Callback = function(v) cfgAutoSave = v end,
        })

        SettingsTab:CreateParagraph({
            Title = "Jitler Hub",
            Content = name .. "\nPress Right Control to toggle UI visibility.\nConfig folder: " .. cfgFolder,
        })
    end

    -- ==================== LOADING SCREEN ANIMATION ====================
    if hasLoading then
        task.spawn(function()
            for i = 1, 20 do
                local pctVal = i / 20
                tw(loadFill, {Size = UDim2.new(pctVal, 0, 1, 0)}, 0.08)
                loadPct.Text = tostring(math.floor(pctVal * 100)) .. "%"
                task.wait(0.06)
            end
            task.wait(0.2)

            tw(loadScreen, {BackgroundTransparency = 1}, 0.4)
            for _, desc in ipairs(loadScreen:GetDescendants()) do
                if desc:IsA("TextLabel") then tw(desc, {TextTransparency=1}, 0.3) end
                if desc:IsA("ImageLabel") then tw(desc, {ImageTransparency=1}, 0.3) end
                if desc:IsA("Frame") then tw(desc, {BackgroundTransparency=1}, 0.3) end
            end
            task.wait(0.45)

            loadScreen.Visible = false
            main.Visible = true
            main.BackgroundTransparency = 1
            mainSt.Transparency = 1
            tw(main, {BackgroundTransparency=0}, 0.25)
            tw(mainSt, {Transparency=0.4}, 0.25)
        end)
    end

    -- Auto-load default config once all elements have been registered
    if cfgEnabled then task.delay(0.8, function() LoadConfig() end) end

    return Window
end

return Library
