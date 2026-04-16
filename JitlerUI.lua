-- JitlerUI.lua v8.0 — Ambient Gradient UI Library
-- Wide sidebar with text labels, teal→pink gradient accents, clean design

local Library = {}
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpSvc = game:GetService("HttpService")

-- ==================== GRADIENT ACCENT ====================
local GradStart = Color3.fromRGB(0, 200, 180)
local GradEnd   = Color3.fromRGB(200, 60, 180)

local Themes = {
    ["Ambient"]     = { GradStart = Color3.fromRGB(0, 200, 180),   GradEnd = Color3.fromRGB(200, 60, 180) },
    ["Ocean"]       = { GradStart = Color3.fromRGB(40, 100, 255),  GradEnd = Color3.fromRGB(0, 220, 200) },
    ["Sunset"]      = { GradStart = Color3.fromRGB(255, 140, 50),  GradEnd = Color3.fromRGB(255, 50, 120) },
    ["Neon"]        = { GradStart = Color3.fromRGB(0, 255, 200),   GradEnd = Color3.fromRGB(180, 0, 255) },
    ["Monochrome"]  = { GradStart = Color3.fromRGB(160, 160, 170), GradEnd = Color3.fromRGB(100, 100, 110) },
    ["Custom"]      = nil,
}
local ThemeNames = {"Ambient","Ocean","Sunset","Neon","Monochrome","Custom"}

local C = {
    Bg        = Color3.fromRGB(12, 12, 18),
    BgOuter   = Color3.fromRGB(0, 0, 0),
    Sidebar   = Color3.fromRGB(8, 8, 14),
    Header    = Color3.fromRGB(10, 10, 16),
    Surface   = Color3.fromRGB(20, 20, 28),
    SurfaceAlt= Color3.fromRGB(24, 24, 32),
    Hover     = Color3.fromRGB(30, 30, 40),
    Accent    = Color3.fromRGB(0, 200, 180),
    AccentH   = Color3.fromRGB(40, 230, 210),
    AccentDk  = Color3.fromRGB(0, 140, 130),
    Text      = Color3.fromRGB(230, 230, 240),
    Label     = Color3.fromRGB(185, 190, 205),
    Dim       = Color3.fromRGB(100, 105, 125),
    ValText   = Color3.fromRGB(240, 243, 255),
    TogOff    = Color3.fromRGB(30, 30, 40),
    TogOn     = Color3.fromRGB(0, 200, 180),
    TogOnH    = Color3.fromRGB(40, 230, 210),
    TogOffH   = Color3.fromRGB(40, 40, 50),
    Border    = Color3.fromRGB(28, 28, 40),
    SliderBg  = Color3.fromRGB(10, 10, 16),
    Green     = Color3.fromRGB(56, 198, 116),
    Red       = Color3.fromRGB(238, 56, 56),
    Yellow    = Color3.fromRGB(248, 198, 48),
    WidgetBorder = Color3.fromRGB(24, 24, 34),
    TabBg     = Color3.fromRGB(8, 8, 14),
    TabActive = Color3.fromRGB(18, 26, 26),
    Shadow    = Color3.fromRGB(0, 0, 0),
    Knob      = Color3.fromRGB(220, 220, 235),
    Card      = Color3.fromRGB(14, 14, 20),
    CardBorder= Color3.fromRGB(30, 30, 42),
    SectionDim= Color3.fromRGB(70, 75, 95),
}
local F = {
    Bold = Enum.Font.GothamBold,
    Semi = Enum.Font.GothamSemibold,
    Med  = Enum.Font.GothamMedium,
    Reg  = Enum.Font.Gotham,
}
local CORNER = {
    Widget = 8,
    Main   = 10,
    Tab    = 6,
    Small  = 5,
    Pill   = 10,
    Card   = 8,
}

local UISettings = {
    Theme = "Ambient",
    CustomGradStart = Color3.fromRGB(0, 200, 180),
    CustomGradEnd = Color3.fromRGB(200, 60, 180),
    BgTransparency = 0,
    SidebarTransparency = 0,
    CardTransparency = 0,
    GlobalScale = 1,
    TextScale = 1,
    IconScale = 1,
    EnableShadow = true,
    CompactMode = false,
}
local _uiSettingsCallbacks = {}

-- ==================== HELPERS ====================
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
local function rc(parent, r) return mk("UICorner", {CornerRadius = UDim.new(0, r or CORNER.Widget), Parent = parent}) end
local function st(parent, col, th) return mk("UIStroke", {Color = col or C.Border, Thickness = th or 1, Parent = parent}) end
local function pad(parent, t, r, b, l)
    return mk("UIPadding", {PaddingTop=UDim.new(0,t or 0), PaddingRight=UDim.new(0,r or 0), PaddingBottom=UDim.new(0,b or 0), PaddingLeft=UDim.new(0,l or 0), Parent=parent})
end

-- ==================== FILE SYSTEM ====================
local function _writefile(p, c) if typeof(writefile)=="function" then pcall(writefile,p,c) end end
local function _readfile(p) if typeof(readfile)=="function" then local ok,d=pcall(readfile,p); if ok then return d end end; return nil end
local function _isfile(p) if typeof(isfile)=="function" then local ok,r=pcall(isfile,p); if ok then return r end end; return false end
local function _makefolder(p) if typeof(makefolder)=="function" then pcall(makefolder,p) end end
local function _listfiles(p) if typeof(listfiles)=="function" then local ok,r=pcall(listfiles,p); if ok then return r end end; return {} end
local function _delfile(p) if typeof(delfile)=="function" then pcall(delfile,p) end end

local _notifContainer = nil
local _screenGui = nil
local NotifColors = { info=C.Accent, success=C.Green, warning=C.Yellow, error=C.Red }

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
    rc(nf, CORNER.Widget); local nfSt = st(nf, barColor, 1); nfSt.Transparency = 0.4
    local bar = mk("Frame", {BackgroundColor3=Color3.new(1,1,1), Size=UDim2.new(0,3,1,-10), Position=UDim2.fromOffset(4,5), BorderSizePixel=0, Parent=nf}); rc(bar,2)
    mk("UIGradient", {Color=ColorSequence.new(GradStart, GradEnd), Rotation=90, Parent=bar})
    mk("TextLabel", {Text=title, TextColor3=C.Accent, Font=F.Bold, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-20,0,18), Position=UDim2.fromOffset(14,5), Parent=nf})
    mk("TextLabel", {Text=content, TextColor3=C.Text, Font=F.Reg, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, BackgroundTransparency=1, Size=UDim2.new(1,-20,0,28), Position=UDim2.fromOffset(14,24), Parent=nf})
    tw(nf, {Size=UDim2.new(1,0,0,58)}, 0.2)
    task.delay(dur, function()
        if not nf or not nf.Parent then return end
        tw(nf, {Size=UDim2.new(1,0,0,0)}, 0.25)
        task.wait(0.3); if nf and nf.Parent then nf:Destroy() end
    end)
end

-- ==================== WINDOW ====================
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local name = cfg.Name or "Jitler Hub"

    local guiName = "JitlerHubUI"
    for _, p in ipairs({game:GetService("CoreGui"), Players.LocalPlayer:FindFirstChild("PlayerGui")}) do
        if p then local old = p:FindFirstChild(guiName); if old then old:Destroy() end end
    end
    if typeof(gethui)=="function" then local old = gethui():FindFirstChild(guiName); if old then old:Destroy() end end

    local sg = mk("ScreenGui", {Name=guiName, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, ResetOnSpawn=false})
    if typeof(syn)=="table" and syn.protect_gui then syn.protect_gui(sg); sg.Parent = game:GetService("CoreGui")
    elseif typeof(gethui)=="function" then sg.Parent = gethui()
    else sg.Parent = game:GetService("CoreGui") end
    _screenGui = sg

    -- ==================== LOADING SCREEN ====================
    local hasLoading = cfg.LoadingTitle ~= nil
    local loadScreen, loadFill, loadPct

    if hasLoading then
        loadScreen = mk("Frame", {Name="Loading", BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0, Size=UDim2.new(1,0,1,0), ZIndex=100, BorderSizePixel=0, Parent=sg})
        local center = mk("Frame", {BackgroundTransparency=1, Size=UDim2.fromOffset(200,160), Position=UDim2.new(0.5,-100,0.5,-80), ZIndex=101, Parent=loadScreen})
        local loadIcon = cfg.Icon
        if loadIcon and loadIcon ~= "" then
            mk("ImageLabel", {Image=loadIcon, BackgroundTransparency=1, Size=UDim2.fromOffset(80,80), Position=UDim2.new(0.5,-40,0,0), ScaleType=Enum.ScaleType.Fit, ZIndex=102, Parent=center})
        end
        local titleY = (loadIcon and loadIcon ~= "") and 88 or 8
        mk("TextLabel", {Text=cfg.LoadingTitle or "Loading", TextColor3=C.Text, Font=F.Bold, TextSize=22, BackgroundTransparency=1, Size=UDim2.new(1,0,0,24), Position=UDim2.fromOffset(0,titleY), TextXAlignment=Enum.TextXAlignment.Center, ZIndex=102, Parent=center})
        mk("TextLabel", {Text=cfg.LoadingSubtitle or "", TextColor3=C.Dim, Font=F.Reg, TextSize=12, BackgroundTransparency=1, Size=UDim2.new(1,0,0,16), Position=UDim2.fromOffset(0,titleY+24), TextXAlignment=Enum.TextXAlignment.Center, ZIndex=102, Parent=center})
        local loadBar = mk("Frame", {BackgroundColor3=C.SliderBg, Size=UDim2.new(0.8,0,0,3), Position=UDim2.new(0.1,0,0,titleY+44), BorderSizePixel=0, ZIndex=102, Parent=center}); rc(loadBar,2)
        loadFill = mk("Frame", {BackgroundColor3=Color3.new(1,1,1), Size=UDim2.new(0,0,1,0), BorderSizePixel=0, ZIndex=103, Parent=loadBar}); rc(loadFill,2)
        mk("UIGradient", {Color=ColorSequence.new(GradStart, GradEnd), Parent=loadFill})
        loadPct = mk("TextLabel", {Text="0%", TextColor3=C.Dim, Font=F.Reg, TextSize=12, BackgroundTransparency=1, Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,0,titleY+50), TextXAlignment=Enum.TextXAlignment.Center, ZIndex=102, Parent=center})
    end

    -- ==================== MAIN FRAME ====================
    local WIN_W, WIN_H = 860, 560
    local SIDEBAR_W = 155
    local HEADER_H = 40

    local mainWrapper = mk("Frame", {Name="MainWrapper", BackgroundTransparency=1, Size=UDim2.fromOffset(WIN_W+16, WIN_H+16), Position=UDim2.new(0.5,-math.floor((WIN_W+16)/2),0.5,-math.floor((WIN_H+16)/2)), ClipsDescendants=false, Visible=not hasLoading, Parent=sg})

    local shadowOuter = mk("Frame", {BackgroundColor3=C.Shadow, BackgroundTransparency=0.60, Size=UDim2.new(1,10,1,10), Position=UDim2.fromOffset(-5,-3), BorderSizePixel=0, ZIndex=0, Parent=mainWrapper}); rc(shadowOuter, CORNER.Main+6)
    local shadowMid = mk("Frame", {BackgroundColor3=C.Shadow, BackgroundTransparency=0.40, Size=UDim2.new(1,4,1,4), Position=UDim2.fromOffset(-2,0), BorderSizePixel=0, ZIndex=0, Parent=mainWrapper}); rc(shadowMid, CORNER.Main+3)

    local main = mk("Frame", {Name="Main", BackgroundColor3=C.Bg, Size=UDim2.fromOffset(WIN_W, WIN_H), Position=UDim2.fromOffset(8, 8), BorderSizePixel=0, ClipsDescendants=true, Parent=mainWrapper})
    rc(main, CORNER.Main)
    local mainSt = st(main, C.Border, 1); mainSt.Transparency = 0.3

    -- ==================== SIDEBAR ====================
    local sidebar = mk("Frame", {Name="Sidebar", BackgroundColor3=C.Sidebar, BackgroundTransparency=UISettings.SidebarTransparency, Size=UDim2.new(0,SIDEBAR_W,1,0), BorderSizePixel=0, ClipsDescendants=true, Parent=main})
    mk("Frame", {BackgroundColor3=C.Border, BackgroundTransparency=0.4, Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,0,0,0), BorderSizePixel=0, Parent=sidebar})

    -- Sidebar header
    local sidebarHdr = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,48), Parent=sidebar})
    local headerIcon = cfg.Icon
    if headerIcon and headerIcon ~= "" then
        mk("ImageLabel", {Image=headerIcon, BackgroundTransparency=1, Size=UDim2.fromOffset(24,24), Position=UDim2.fromOffset(14,12), ScaleType=Enum.ScaleType.Fit, Parent=sidebarHdr})
    end
    local shortName = name:match("^(.-)%s+v") or name:match("^(.-)%s+%-") or name
    if #shortName > 20 then shortName = shortName:sub(1,20) end
    mk("TextLabel", {Text=shortName, TextColor3=C.Text, Font=F.Bold, TextSize=16, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-52,0,24), Position=UDim2.fromOffset(headerIcon and 44 or 14, 12), Parent=sidebarHdr})
    mk("Frame", {BackgroundColor3=C.Border, BackgroundTransparency=0.5, Size=UDim2.new(1,-20,0,1), Position=UDim2.new(0,10,1,-1), BorderSizePixel=0, Parent=sidebarHdr})

    -- Sidebar scroll
    local sidebarScroll = mk("ScrollingFrame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,-52), Position=UDim2.fromOffset(0,52), ScrollBarThickness=2, ScrollBarImageColor3=C.Dim, CanvasSize=UDim2.new(0,0,0,0), BorderSizePixel=0, Parent=sidebar})
    local sidebarLayout = mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,1), Parent=sidebarScroll})
    pad(sidebarScroll, 4, 6, 4, 6)
    sidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sidebarScroll.CanvasSize = UDim2.new(0,0,0,sidebarLayout.AbsoluteContentSize.Y+12)
    end)

    -- ==================== RIGHT AREA ====================
    local rightArea = mk("Frame", {Name="RightArea", BackgroundTransparency=1, Size=UDim2.new(1,-(SIDEBAR_W+1),1,0), Position=UDim2.fromOffset(SIDEBAR_W+1,0), ClipsDescendants=true, Parent=main})

    -- Header bar
    local header = mk("Frame", {Name="Header", BackgroundColor3=C.Header, Size=UDim2.new(1,0,0,HEADER_H), BorderSizePixel=0, Parent=rightArea})
    mk("UIGradient", {Transparency=NumberSequence.new(0.15,0.02), Rotation=90, Parent=header})

    local subTitle = name:match("v.+$") or ""
    mk("TextLabel", {Text=subTitle, TextColor3=C.Dim, Font=F.Med, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-100,1,0), Position=UDim2.fromOffset(12,0), Parent=header})
    mk("Frame", {BackgroundColor3=C.Shadow, BackgroundTransparency=0.5, Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,0), BorderSizePixel=0, Parent=header})

    local closeBtn = mk("TextButton", {Text="\226\156\149", TextColor3=C.Dim, Font=F.Bold, TextSize=14, BackgroundTransparency=1, Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-32,0,6), AutoButtonColor=false, Parent=header})
    local minBtn = mk("TextButton", {Text="\226\148\128", TextColor3=C.Dim, Font=F.Bold, TextSize=12, BackgroundTransparency=1, Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-58,0,6), AutoButtonColor=false, Parent=header})
    for _, b in ipairs({closeBtn, minBtn}) do
        b.MouseEnter:Connect(function() tw(b, {TextColor3=C.Text}, 0.1) end)
        b.MouseLeave:Connect(function() tw(b, {TextColor3=C.Dim}, 0.1) end)
    end

    local contentArea = mk("Frame", {Name="Content", BackgroundTransparency=1, Size=UDim2.new(1,0,1,-HEADER_H), Position=UDim2.fromOffset(0,HEADER_H), ClipsDescendants=true, Parent=rightArea})

    local dialogOverlay = mk("Frame", {Name="DialogOverlay", BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.5, Size=UDim2.new(1,0,1,0), Visible=false, ZIndex=50, Parent=main})

    local notifC = mk("Frame", {Name="Notifs", BackgroundTransparency=1, Size=UDim2.new(0,280,1,0), Position=UDim2.new(1,-290,0,8), Parent=sg})
    mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5), VerticalAlignment=Enum.VerticalAlignment.Top, Parent=notifC})
    _notifContainer = notifC

    -- ==================== STATE ====================
    local Window = {}
    local tabs = {}
    local settingsTabData = nil
    local activeTab = nil
    local minimized = false
    local Flags = {}
    local _sidebarOrder = 0
    local _seenSections = {}

    -- ==================== CONFIG ====================
    local cfgSave = cfg.ConfigurationSaving or {}
    local cfgEnabled = cfgSave.Enabled == true
    local cfgFolder = cfgSave.FolderName or "JitlerHub"
    local cfgDefaultName = cfgSave.FileName or "Default"
    local cfgAutoSave = false
    local _saveThread = nil
    local cfgAutoLoad = false
    local function GetAutoLoadPath() return cfgFolder.."/autoload.txt" end
    local function SaveAutoLoadPref()
        if typeof(writefile)~="function" then return end
        _makefolder(cfgFolder)
        if cfgAutoLoad then _writefile(GetAutoLoadPath(), cfgDefaultName) else pcall(function() if _isfile(GetAutoLoadPath()) then _delfile(GetAutoLoadPath()) end end) end
    end
    pcall(function() if _isfile(GetAutoLoadPath()) then cfgAutoLoad = true end end)

    local function GetConfigPath(pn) return cfgFolder.."/"..(pn or cfgDefaultName)..".json" end
    local function SaveConfig(pn)
        if not cfgEnabled or typeof(writefile)~="function" then return end
        pcall(function()
            local d={}; for f,i in pairs(Flags) do d[f]=i.get() end
            _makefolder(cfgFolder); _writefile(GetConfigPath(pn), HttpSvc:JSONEncode(d))
        end)
    end
    local function DebouncedSave()
        if not cfgEnabled or not cfgAutoSave then return end
        if _saveThread then pcall(task.cancel, _saveThread) end
        _saveThread = task.delay(0.5, function() _saveThread=nil; SaveConfig() end)
    end
    local function LoadConfig(pn)
        if not cfgEnabled then return end
        local c = _readfile(GetConfigPath(pn)); if not c then return end
        local ok,d = pcall(HttpSvc.JSONDecode, HttpSvc, c); if not ok or type(d)~="table" then return end
        for f,v in pairs(d) do if Flags[f] then pcall(Flags[f].set, v) end end
    end
    local function DeleteConfig(pn) if cfgEnabled and _isfile(GetConfigPath(pn)) then _delfile(GetConfigPath(pn)) end end
    local function ListConfigs()
        if not cfgEnabled then return {} end
        local files = _listfiles(cfgFolder); local p = {}
        for _,f in ipairs(files) do local n=f:match("([^/\\]+)%.json$"); if n then table.insert(p,n) end end; return p
    end

    function Window:SaveConfig(pn) SaveConfig(pn) end
    function Window:LoadConfig(pn) LoadConfig(pn) end
    function Window:DeleteConfig(pn) DeleteConfig(pn) end
    function Window:ListConfigs() return ListConfigs() end

    -- UI Theme persistence
    local function GetUISettingsPath() return cfgFolder.."/UITheme.json" end
    local function SaveUISettings()
        if typeof(writefile)~="function" then return end
        pcall(function()
            local d = {
                Theme = UISettings.Theme,
                CustomGradStart = {R=math.floor(UISettings.CustomGradStart.R*255), G=math.floor(UISettings.CustomGradStart.G*255), B=math.floor(UISettings.CustomGradStart.B*255)},
                CustomGradEnd = {R=math.floor(UISettings.CustomGradEnd.R*255), G=math.floor(UISettings.CustomGradEnd.G*255), B=math.floor(UISettings.CustomGradEnd.B*255)},
                BgTransparency = UISettings.BgTransparency,
                SidebarTransparency = UISettings.SidebarTransparency,
                CardTransparency = UISettings.CardTransparency,
                GlobalScale = UISettings.GlobalScale,
                TextScale = UISettings.TextScale,
                IconScale = UISettings.IconScale,
                EnableShadow = UISettings.EnableShadow,
                CompactMode = UISettings.CompactMode,
            }
            _makefolder(cfgFolder); _writefile(GetUISettingsPath(), HttpSvc:JSONEncode(d))
        end)
    end
    local function LoadUISettings()
        local c = _readfile(GetUISettingsPath()); if not c then return end
        local ok,d = pcall(HttpSvc.JSONDecode, HttpSvc, c); if not ok or type(d)~="table" then return end
        for k,v in pairs(d) do
            if (k == "CustomGradStart" or k == "CustomGradEnd") and type(v) == "table" and v.R then
                UISettings[k] = Color3.fromRGB(v.R, v.G, v.B)
            elseif UISettings[k] ~= nil and k ~= "CustomGradStart" and k ~= "CustomGradEnd" then
                UISettings[k] = v
            end
        end
        -- Apply loaded theme
        local preset = Themes[UISettings.Theme]
        if preset then GradStart = preset.GradStart; GradEnd = preset.GradEnd
        elseif UISettings.Theme == "Custom" then GradStart = UISettings.CustomGradStart; GradEnd = UISettings.CustomGradEnd end
        C.Accent = GradStart; C.AccentH = GradStart; C.AccentDk = GradEnd; C.TogOn = GradStart; C.TogOnH = GradStart
    end

    -- ==================== DIALOG ====================
    function Window:Dialog(dc)
        dc = dc or {}
        for _,c2 in ipairs(dialogOverlay:GetChildren()) do c2:Destroy() end
        dialogOverlay.Visible = true
        local panel = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.fromOffset(300,0), Position=UDim2.new(0.5,-150,0.5,-65), BorderSizePixel=0, ClipsDescendants=true, ZIndex=51, Parent=dialogOverlay}); rc(panel,CORNER.Main); st(panel,C.Border)
        mk("TextLabel", {Text=dc.Title or "Confirm", TextColor3=C.Text, Font=F.Bold, TextSize=17, BackgroundTransparency=1, Size=UDim2.new(1,-16,0,26), Position=UDim2.fromOffset(8,8), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=52, Parent=panel})
        mk("TextLabel", {Text=dc.Content or "", TextColor3=C.Dim, Font=F.Reg, TextSize=12, TextWrapped=true, BackgroundTransparency=1, Size=UDim2.new(1,-16,0,36), Position=UDim2.fromOffset(8,34), TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, ZIndex=52, Parent=panel})
        local btnRow = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-12,0,28), Position=UDim2.fromOffset(6,78), ZIndex=52, Parent=panel})
        mk("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5), HorizontalAlignment=Enum.HorizontalAlignment.Right, Parent=btnRow})

        local function closeDialog() tw(panel, {Size=UDim2.fromOffset(300,0)}, 0.15); task.delay(0.15, function() dialogOverlay.Visible=false end) end
        for i, bc in ipairs(dc.Buttons or {}) do
            local ia = i==1
            local db = mk("TextButton", {Text=bc.Name or "OK", TextColor3=ia and C.Text or C.Dim, Font=F.Semi, TextSize=13, BackgroundColor3=ia and C.Accent or C.Bg, Size=UDim2.fromOffset(76,26), BorderSizePixel=0, AutoButtonColor=false, LayoutOrder=i, ZIndex=53, Parent=btnRow}); rc(db,CORNER.Small)
            db.MouseButton1Click:Connect(function() closeDialog(); if bc.Callback then pcall(bc.Callback) end end)
            db.MouseEnter:Connect(function() tw(db, {BackgroundColor3=ia and C.AccentH or C.Hover}, 0.08) end)
            db.MouseLeave:Connect(function() tw(db, {BackgroundColor3=ia and C.Accent or C.Bg}, 0.08) end)
        end
        tw(panel, {Size=UDim2.fromOffset(300,116)}, 0.2)
    end

    -- ==================== DESTROY ====================
    function Window:Destroy() if sg then sg:Destroy() end; _notifContainer=nil; _screenGui=nil end
    Library.Destroy = function() if sg then sg:Destroy() end end

    -- ==================== DRAGGING ====================
    local dragging, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=input.Position; startPos=mainWrapper.Position end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local d=input.Position-dragStart; mainWrapper.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tw(main, {Size=UDim2.fromOffset(WIN_W, HEADER_H)}, 0.2)
            task.delay(0.1, function() sidebar.Visible=false; rightArea.Size=UDim2.new(1,0,1,0); rightArea.Position=UDim2.fromOffset(0,0) end)
        else
            sidebar.Visible=true; rightArea.Size=UDim2.new(1,-(SIDEBAR_W+1),1,0); rightArea.Position=UDim2.fromOffset(SIDEBAR_W+1,0)
            tw(main, {Size=UDim2.fromOffset(WIN_W, WIN_H)}, 0.2)
        end
    end)
    closeBtn.MouseButton1Click:Connect(function() mainWrapper.Visible=false end)
    UIS.InputBegan:Connect(function(input,gp) if gp then return end; if input.KeyCode==Enum.KeyCode.RightControl then mainWrapper.Visible=not mainWrapper.Visible end end)

    -- ==================== TAB SELECTION ====================
    local function selectTab(tabName)
        for _, t in ipairs(tabs) do
            if t.name == tabName then
                t.content.Visible = true
                tw(t.button, {BackgroundColor3=C.TabActive}, 0.15)
                t.indicator.Visible = true
                if t.nameLabel then tw(t.nameLabel, {TextColor3=C.Text}, 0.15) end
                if t.iconLabel then tw(t.iconLabel, {ImageColor3=C.Text}, 0.15) end
                activeTab = tabName
            else
                t.content.Visible = false
                tw(t.button, {BackgroundColor3=C.Sidebar}, 0.15)
                t.indicator.Visible = false
                if t.nameLabel then tw(t.nameLabel, {TextColor3=C.Dim}, 0.15) end
                if t.iconLabel then tw(t.iconLabel, {ImageColor3=C.Dim}, 0.15) end
            end
        end
        if settingsTabData then
            if tabName == settingsTabData.name then
                settingsTabData.content.Visible = true
                tw(settingsTabData.button, {BackgroundColor3=C.TabActive}, 0.15)
                settingsTabData.indicator.Visible = true
                if settingsTabData.nameLabel then tw(settingsTabData.nameLabel, {TextColor3=C.Text}, 0.15) end
                if settingsTabData.iconLabel then tw(settingsTabData.iconLabel, {ImageColor3=C.Text}, 0.15) end
            else
                settingsTabData.content.Visible = false
                tw(settingsTabData.button, {BackgroundColor3=C.Sidebar}, 0.15)
                settingsTabData.indicator.Visible = false
                if settingsTabData.nameLabel then tw(settingsTabData.nameLabel, {TextColor3=C.Dim}, 0.15) end
                if settingsTabData.iconLabel then tw(settingsTabData.iconLabel, {ImageColor3=C.Dim}, 0.15) end
            end
        end
    end

    -- ==================== WIDGET FACTORY ====================
    local function attachWidgets(target, wContent)
        local wOrder = 0
        local function wNextOrder() wOrder = wOrder + 1; return wOrder end
        local _currentCard = nil

        -- ========== SECTION ==========
        function target:CreateSection(sectionName)
            local card = mk("Frame", {
                Name = "SectionCard",
                BackgroundColor3 = C.Card,
                BackgroundTransparency = UISettings.CardTransparency,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
                LayoutOrder = wNextOrder(),
                Parent = wContent,
            })
            rc(card, CORNER.Card)
            st(card, C.CardBorder, 1)
            pad(card, 4, 6, 6, 6)

            mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = card})

            local hdr = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,26), LayoutOrder=0, Parent=card})
            mk("TextLabel", {Text=sectionName, TextColor3=C.Label, Font=F.Semi, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-4,0,18), Position=UDim2.fromOffset(4,2), Parent=hdr})
            local divider = mk("Frame", {BackgroundColor3=Color3.new(1,1,1), Size=UDim2.new(1,-4,0,1), Position=UDim2.fromOffset(2,22), BorderSizePixel=0, Parent=hdr})
            divider.BackgroundTransparency = 0.7
            mk("UIGradient", {Color=ColorSequence.new(GradStart, GradEnd), Parent=divider})

            _currentCard = card
        end

        local function getWidgetParent()
            if _currentCard then return _currentCard end
            return wContent
        end

        -- ========== TOGGLE ==========
        function target:CreateToggle(tcfg)
            local value = tcfg.CurrentValue or false
            local toggle = {Value = value}
            local hasDesc = tcfg.Description and tcfg.Description ~= ""
            local frameH = hasDesc and 46 or 36

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,frameH), BorderSizePixel=0, LayoutOrder=wNextOrder(), Parent=getWidgetParent()})
            rc(frame, CORNER.Widget)

            mk("TextLabel", {Text=tcfg.Name or "Toggle", TextColor3=C.Label, Font=F.Med, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-56,0,18), Position=UDim2.fromOffset(8, hasDesc and 5 or 9), Parent=frame})
            if hasDesc then mk("TextLabel", {Text=tcfg.Description, TextColor3=C.Dim, Font=F.Reg, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-56,0,14), Position=UDim2.fromOffset(8,24), Parent=frame}) end

            local swBg = mk("Frame", {BackgroundColor3=C.TogOff, Size=UDim2.fromOffset(38,20), Position=UDim2.new(1,-46,0.5,-10), BorderSizePixel=0, Parent=frame}); rc(swBg,CORNER.Pill)
            local swGrad = mk("Frame", {BackgroundColor3=Color3.new(1,1,1), Size=UDim2.new(1,0,1,0), BorderSizePixel=0, Visible=value, Parent=swBg}); rc(swGrad,CORNER.Pill)
            mk("UIGradient", {Color=ColorSequence.new(GradStart, GradEnd), Parent=swGrad})
            local circle = mk("Frame", {BackgroundColor3=C.Knob, Size=UDim2.fromOffset(16,16), Position=value and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2), BorderSizePixel=0, ZIndex=2, Parent=swBg}); rc(circle,8)

            local function updateVis(v)
                swGrad.Visible = v
                tw(circle, {Position=v and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2)}, 0.15)
            end
            function toggle:Set(v)
                if v==value then return end; value=v; toggle.Value=v; updateVis(v)
                if tcfg.Callback then pcall(tcfg.Callback, v) end
            end

            local overlay = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=3, AutoButtonColor=false, Parent=frame})
            overlay.MouseButton1Click:Connect(function()
                value=not value; toggle.Value=value; updateVis(value)
                if tcfg.Callback then pcall(tcfg.Callback, value) end; DebouncedSave()
            end)
            overlay.MouseEnter:Connect(function() tw(frame, {BackgroundColor3=C.Hover}, 0.08) end)
            overlay.MouseLeave:Connect(function() tw(frame, {BackgroundColor3=C.Surface}, 0.08) end)

            if tcfg.Flag then Flags[tcfg.Flag]={get=function() return value end, set=function(v) toggle:Set(v==true) end} end
            return toggle
        end

        -- ========== TOGGLE WITH KEYBIND ==========
        function target:CreateToggleWithKeybind(tcfg, kcfg)
            local value = tcfg.CurrentValue or false
            local toggle = {Value = value}
            local currentKey = (kcfg and kcfg.CurrentKeybind) or "F"
            local listening = false
            local hasDesc = tcfg.Description and tcfg.Description ~= ""
            local frameH = hasDesc and 46 or 36

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,frameH), BorderSizePixel=0, LayoutOrder=wNextOrder(), Parent=getWidgetParent()})
            rc(frame, CORNER.Widget)

            mk("TextLabel", {Text=tcfg.Name or "Toggle", TextColor3=C.Label, Font=F.Med, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-100,0,18), Position=UDim2.fromOffset(8, hasDesc and 5 or 9), Parent=frame})
            if hasDesc then mk("TextLabel", {Text=tcfg.Description, TextColor3=C.Dim, Font=F.Reg, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-100,0,14), Position=UDim2.fromOffset(8,24), Parent=frame}) end

            local swBg = mk("Frame", {BackgroundColor3=C.TogOff, Size=UDim2.fromOffset(38,20), Position=UDim2.new(1,-46,0.5,-10), BorderSizePixel=0, ZIndex=2, Parent=frame}); rc(swBg,CORNER.Pill)
            local swGrad = mk("Frame", {BackgroundColor3=Color3.new(1,1,1), Size=UDim2.new(1,0,1,0), BorderSizePixel=0, Visible=value, Parent=swBg}); rc(swGrad,CORNER.Pill)
            mk("UIGradient", {Color=ColorSequence.new(GradStart, GradEnd), Parent=swGrad})
            local circle = mk("Frame", {BackgroundColor3=C.Knob, Size=UDim2.fromOffset(16,16), Position=value and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2), BorderSizePixel=0, ZIndex=3, Parent=swBg}); rc(circle,8)

            local keyBtn = mk("TextButton", {Text="["..currentKey.."]", TextColor3=C.ValText, Font=F.Semi, TextSize=11, BackgroundColor3=C.Bg, Size=UDim2.fromOffset(42,22), Position=UDim2.new(1,-94,0.5,-11), BorderSizePixel=0, AutoButtonColor=false, ZIndex=2, Parent=frame}); rc(keyBtn,CORNER.Small)

            local function updateVis(v)
                swGrad.Visible = v
                tw(circle, {Position=v and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2)}, 0.15)
            end
            function toggle:Set(v)
                if v==value then return end; value=v; toggle.Value=v; updateVis(v)
                if tcfg.Callback then pcall(tcfg.Callback, v) end
            end

            local swOverlay = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.fromOffset(38,20), Position=UDim2.new(1,-46,0.5,-10), ZIndex=4, AutoButtonColor=false, Parent=frame})
            swOverlay.MouseButton1Click:Connect(function()
                value=not value; toggle.Value=value; updateVis(value)
                if tcfg.Callback then pcall(tcfg.Callback, value) end; DebouncedSave()
            end)

            keyBtn.MouseButton1Click:Connect(function()
                if listening then return end; listening=true; keyBtn.Text="[...]"; tw(keyBtn,{BackgroundColor3=C.AccentDk},0.1)
            end)
            UIS.InputBegan:Connect(function(input,gp)
                if listening then
                    if input.UserInputType==Enum.UserInputType.Keyboard then
                        if input.KeyCode==Enum.KeyCode.Delete or input.KeyCode==Enum.KeyCode.Backspace then
                            currentKey="None"; keyBtn.Text="[None]"
                        else
                            currentKey=input.KeyCode.Name; keyBtn.Text="["..currentKey.."]"
                        end
                        listening=false; tw(keyBtn,{BackgroundColor3=C.Bg},0.1); DebouncedSave()
                    end
                    return
                end
                if not gp and currentKey~="None" and input.KeyCode~=Enum.KeyCode.Unknown and input.KeyCode.Name==currentKey then
                    value=not value; toggle.Value=value; updateVis(value)
                    if tcfg.Callback then pcall(tcfg.Callback, value) end; DebouncedSave()
                end
            end)

            frame.MouseEnter:Connect(function() tw(frame, {BackgroundColor3=C.Hover}, 0.08) end)
            frame.MouseLeave:Connect(function() tw(frame, {BackgroundColor3=C.Surface}, 0.08) end)

            if tcfg.Flag then Flags[tcfg.Flag]={get=function() return value end, set=function(v) toggle:Set(v==true) end} end
            if kcfg and kcfg.Flag then Flags[kcfg.Flag]={get=function() return currentKey end, set=function(v) if type(v)=="string" then currentKey=v; keyBtn.Text="["..v.."]" end end} end
            return toggle
        end

        -- ========== SLIDER ==========
        function target:CreateSlider(scfg)
            local range = scfg.Range or {0,100}
            local mn, mx = range[1], range[2]
            local inc = scfg.Increment or 1
            local suffix = scfg.Suffix or ""
            local value = math.clamp(scfg.CurrentValue or mn, mn, mx)
            local slider = {Value = value}

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,50), BorderSizePixel=0, LayoutOrder=wNextOrder(), Parent=getWidgetParent()})
            rc(frame, CORNER.Widget)

            mk("TextLabel", {Text=scfg.Name or "Slider", TextColor3=C.Label, Font=F.Med, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(0.6,0,0,18), Position=UDim2.fromOffset(8,5), Parent=frame})

            local function fmtVal(v)
                local vs = inc >= 1 and tostring(math.floor(v+0.5)) or string.format("%.2f", v):gsub("0+$",""):gsub("%.$","")
                local ms = inc >= 1 and tostring(math.floor(mx+0.5)) or string.format("%.2f", mx):gsub("0+$",""):gsub("%.$","")
                return vs.."/"..ms
            end
            local valLbl = mk("TextLabel", {Text=fmtVal(value), TextColor3=C.ValText, Font=F.Semi, TextSize=14, TextXAlignment=Enum.TextXAlignment.Right, BackgroundTransparency=1, Size=UDim2.new(0.4,-12,0,18), Position=UDim2.new(0.6,0,0,5), Parent=frame})

            local track = mk("Frame", {BackgroundColor3=C.SliderBg, Size=UDim2.new(1,-16,0,5), Position=UDim2.new(0,8,0,32), BorderSizePixel=0, Parent=frame}); rc(track,3)
            local pct = (value-mn)/math.max(mx-mn,0.001)
            local fill = mk("Frame", {BackgroundColor3=Color3.new(1,1,1), Size=UDim2.new(pct,0,1,0), BorderSizePixel=0, Parent=track}); rc(fill,3)
            mk("UIGradient", {Color=ColorSequence.new(GradStart, GradEnd), Parent=fill})

            local knob = mk("Frame", {BackgroundColor3=C.Knob, Size=UDim2.fromOffset(12,12), Position=UDim2.new(pct,-6,0.5,-6), BorderSizePixel=0, ZIndex=3, Parent=track}); rc(knob,6)

            local function updateSlider(v)
                v = math.clamp(v, mn, mx)
                v = math.floor(v/inc+0.5)*inc
                v = math.clamp(v, mn, mx)
                if inc >= 1 then v = math.floor(v+0.5) end
                value = v; slider.Value = v
                local p = (v-mn)/math.max(mx-mn,0.001)
                fill.Size = UDim2.new(p,0,1,0)
                knob.Position = UDim2.new(p,-6,0.5,-6)
                valLbl.Text = fmtVal(v)
                if scfg.Callback then pcall(scfg.Callback, v) end; DebouncedSave()
            end
            function slider:Set(v) updateSlider(v) end

            local sliding = false
            local hitArea = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,0,28), AutoButtonColor=false, Parent=frame})
            hitArea.InputBegan:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 then
                    sliding=true; local rel=math.clamp((input.Position.X-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
                    updateSlider(mn+rel*(mx-mn))
                end
            end)
            UIS.InputChanged:Connect(function(input)
                if sliding and input.UserInputType==Enum.UserInputType.MouseMovement then
                    local rel=math.clamp((input.Position.X-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
                    updateSlider(mn+rel*(mx-mn))
                end
            end)
            UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
            frame.MouseEnter:Connect(function() tw(frame, {BackgroundColor3=C.Hover}, 0.08) end)
            frame.MouseLeave:Connect(function() tw(frame, {BackgroundColor3=C.Surface}, 0.08) end)

            if scfg.Flag then Flags[scfg.Flag]={get=function() return value end, set=function(v) slider:Set(tonumber(v) or value) end} end
            return slider
        end

        -- ========== BUTTON ==========
        function target:CreateButton(bcfg)
            local btn2 = mk("TextButton", {Text=bcfg.Name or "Button", TextColor3=C.Label, Font=F.Med, TextSize=14, BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,34), BorderSizePixel=0, AutoButtonColor=false, LayoutOrder=wNextOrder(), Parent=getWidgetParent()})
            rc(btn2, CORNER.Widget)
            btn2.MouseButton1Click:Connect(function()
                tw(btn2, {BackgroundColor3=C.Accent}, 0.06)
                task.delay(0.1, function() tw(btn2, {BackgroundColor3=C.Surface}, 0.12) end)
                if bcfg.Callback then pcall(bcfg.Callback) end
            end)
            btn2.MouseEnter:Connect(function() tw(btn2, {BackgroundColor3=C.Hover}, 0.08) end)
            btn2.MouseLeave:Connect(function() tw(btn2, {BackgroundColor3=C.Surface}, 0.08) end)
        end

        -- ========== DROPDOWN ==========
        function target:CreateDropdown(dcfg)
            local options = dcfg.Options or {}
            local isMulti = dcfg.MultiSelection == true
            local current = dcfg.CurrentOption or (isMulti and {} or (options[1] or ""))
            local dropdown = {Value=current}
            local isOpen = false
            local closedH, optH = 36, 28

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,closedH), BorderSizePixel=0, ClipsDescendants=true, LayoutOrder=wNextOrder(), Parent=getWidgetParent()})
            rc(frame, CORNER.Widget); st(frame, C.WidgetBorder)

            mk("TextLabel", {Text=dcfg.Name or "Dropdown", TextColor3=C.Label, Font=F.Med, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, ClipsDescendants=true, BackgroundTransparency=1, Size=UDim2.new(0.4,-4,0,closedH), Position=UDim2.fromOffset(8,0), Parent=frame})

            local selected = {}

            local function formatOption(opt)
                if type(opt) == "table" then return opt.Name and tostring(opt.Name) or tostring(opt) end
                return tostring(opt)
            end

            local function buildSelectedList()
                local list = {}
                for _, opt in ipairs(options) do
                    local sel = selected[tostring(opt)]
                    if sel ~= nil then table.insert(list, sel) end
                end
                return list
            end

            local selLbl = mk("TextLabel", {Text="", TextColor3=C.ValText, Font=F.Semi, TextSize=13, TextXAlignment=Enum.TextXAlignment.Right, TextTruncate=Enum.TextTruncate.AtEnd, ClipsDescendants=true, BackgroundTransparency=1, Size=UDim2.new(0.6,-18,0,closedH), Position=UDim2.new(0.4,4,0,0), Parent=frame})

            local function updateSelLabel()
                local txt
                if isMulti then
                    local list = buildSelectedList()
                    if #list > 0 then
                        local textList = {}
                        for _, v in ipairs(list) do table.insert(textList, formatOption(v)) end
                        txt = table.concat(textList, ", ")
                    else txt = "None" end
                else txt = formatOption(buildSelectedList()[1] or "") end
                selLbl.Text = txt .. (isOpen and " \226\150\178" or " \226\150\190")
            end

            local function applySelection()
                if isMulti then dropdown.Value = buildSelectedList()
                else dropdown.Value = buildSelectedList()[1] or "" end
                if dcfg.Callback then pcall(dcfg.Callback, dropdown.Value) end
                DebouncedSave()
            end

            local optionButtons = {}
            local function updateAllOptionVisuals()
                for key, btn in pairs(optionButtons) do
                    btn.BackgroundColor3 = selected[key] and C.AccentDk or C.Bg
                end
            end

            local function setSelected(val)
                selected = {}
                if isMulti then
                    if type(val) == "table" then for _, v in ipairs(val) do selected[tostring(v)] = v end
                    elseif val ~= nil then selected[tostring(val)] = val end
                else if val ~= nil then selected[tostring(val)] = val end end
                updateSelLabel(); updateAllOptionVisuals()
            end

            local toggleBtn2 = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,0,closedH), ZIndex=2, AutoButtonColor=false, Parent=frame})
            local optC = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-6,0,#options*optH), Position=UDim2.new(0,3,0,closedH+2), Parent=frame})
            mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,1), Parent=optC})

            local function rebuildOptions()
                for _, child in ipairs(optC:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                optionButtons = {}
                for i, opt in ipairs(options) do
                    local ob = mk("TextButton", {Text="  "..formatOption(opt), TextColor3=C.Text, Font=F.Reg, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, BackgroundColor3=C.Bg, Size=UDim2.new(1,0,0,optH), BorderSizePixel=0, AutoButtonColor=false, LayoutOrder=i, Parent=optC})
                    optionButtons[tostring(opt)] = ob; rc(ob, CORNER.Small)
                    ob.MouseButton1Click:Connect(function()
                        if isMulti then
                            local key = tostring(opt)
                            if selected[key] then selected[key] = nil else selected[key] = opt end
                            ob.BackgroundColor3 = selected[key] and C.AccentDk or C.Bg
                            applySelection()
                        else
                            setSelected(opt); applySelection()
                            isOpen = false; tw(frame, {Size = UDim2.new(1,0,0,closedH)}, 0.15)
                        end
                    end)
                    ob.MouseEnter:Connect(function() tw(ob,{BackgroundColor3=C.Hover},0.06) end)
                    ob.MouseLeave:Connect(function() tw(ob,{BackgroundColor3=selected[tostring(opt)] and C.AccentDk or C.Bg},0.06) end)
                end
                optC.Size = UDim2.new(1,-6,0,#options*(optH+1))
            end

            function dropdown:Set(val) setSelected(val); applySelection() end
            function dropdown:SetValue(val) dropdown:Set(val) end
            function dropdown:SetOptions(newOptions)
                options = newOptions or {}; rebuildOptions()
                if isMulti then
                    local keep = {}
                    for _, v in ipairs(buildSelectedList()) do for _, o in ipairs(options) do if o == v then table.insert(keep, v); break end end end
                    setSelected(keep)
                else setSelected(options[1] or "") end
                applySelection()
            end

            rebuildOptions(); setSelected(current); applySelection()
            toggleBtn2.MouseButton1Click:Connect(function()
                isOpen = not isOpen; local openH = closedH + 4 + #options * (optH + 1)
                tw(frame, {Size = UDim2.new(1,0,0, isOpen and openH or closedH)}, 0.18)
                updateSelLabel()
            end)

            if dcfg.Flag then Flags[dcfg.Flag] = {get = function() return dropdown.Value end, set = function(v) dropdown:Set(v) end} end
            return dropdown
        end

        -- ========== INPUT ==========
        function target:CreateInput(icfg)
            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,34), BorderSizePixel=0, LayoutOrder=wNextOrder(), Parent=getWidgetParent()}); rc(frame,CORNER.Widget)
            mk("TextLabel", {Text=icfg.Name or "Input", TextColor3=C.Label, Font=F.Med, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(0.4,0,1,0), Position=UDim2.fromOffset(8,0), Parent=frame})
            local box = mk("TextBox", {Text="", PlaceholderText=icfg.PlaceholderText or "...", PlaceholderColor3=C.Dim, TextColor3=C.Text, Font=F.Reg, TextSize=12, BackgroundColor3=C.Bg, Size=UDim2.new(0.55,-8,0,22), Position=UDim2.new(0.45,0,0.5,-11), BorderSizePixel=0, ClearTextOnFocus=false, Parent=frame}); rc(box,CORNER.Small); pad(box,0,5,0,5)
            if icfg.Callback then box.FocusLost:Connect(function() pcall(icfg.Callback, box.Text); if icfg.RemoveTextAfterFocusLost then box.Text="" end end) end
        end

        -- ========== KEYBIND ==========
        function target:CreateKeybind(kcfg)
            local currentKey = kcfg.CurrentKeybind or "F"
            local listening = false
            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,34), BorderSizePixel=0, LayoutOrder=wNextOrder(), Parent=getWidgetParent()}); rc(frame,CORNER.Widget)
            mk("TextLabel", {Text=kcfg.Name or "Keybind", TextColor3=C.Label, Font=F.Med, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-52,1,0), Position=UDim2.fromOffset(8,0), Parent=frame})
            local keyBtn = mk("TextButton", {Text="["..currentKey.."]", TextColor3=C.ValText, Font=F.Semi, TextSize=11, BackgroundColor3=C.Bg, Size=UDim2.fromOffset(44,22), Position=UDim2.new(1,-50,0.5,-11), BorderSizePixel=0, AutoButtonColor=false, Parent=frame}); rc(keyBtn,CORNER.Small)
            keyBtn.MouseButton1Click:Connect(function()
                if listening then return end; listening=true; keyBtn.Text="[...]"; tw(keyBtn,{BackgroundColor3=C.AccentDk},0.1)
            end)
            UIS.InputBegan:Connect(function(input,gp)
                if listening then
                    if input.UserInputType==Enum.UserInputType.Keyboard then
                        if input.KeyCode==Enum.KeyCode.Delete or input.KeyCode==Enum.KeyCode.Backspace then currentKey="None"; keyBtn.Text="[None]"
                        else currentKey=input.KeyCode.Name; keyBtn.Text="["..currentKey.."]" end
                        listening=false; tw(keyBtn,{BackgroundColor3=C.Bg},0.1); DebouncedSave()
                    end
                    return
                end
                if not gp and currentKey~="None" and input.KeyCode~=Enum.KeyCode.Unknown and input.KeyCode.Name==currentKey then if kcfg.Callback then pcall(kcfg.Callback) end end
            end)
            frame.MouseEnter:Connect(function() tw(frame,{BackgroundColor3=C.Hover},0.08) end)
            frame.MouseLeave:Connect(function() tw(frame,{BackgroundColor3=C.Surface},0.08) end)
            if kcfg.Flag then Flags[kcfg.Flag]={get=function() return currentKey end, set=function(v) if type(v)=="string" then currentKey=v; keyBtn.Text="["..v.."]" end end} end
        end

        -- ========== LABEL ==========
        function target:CreateLabel(text)
            local label = {}
            local lbl = mk("TextLabel", {Text=text or "", TextColor3=C.Dim, Font=F.Reg, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, BackgroundTransparency=1, Size=UDim2.new(1,-8,0,20), LayoutOrder=wNextOrder(), Parent=getWidgetParent()}); pad(lbl,0,0,0,8)
            function label:Set(t) lbl.Text=t end; return label
        end

        -- ========== PARAGRAPH ==========
        function target:CreateParagraph(pcfg2)
            pcfg2 = pcfg2 or {}; local para = {}
            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,56), BorderSizePixel=0, LayoutOrder=wNextOrder(), Parent=getWidgetParent()}); rc(frame,CORNER.Widget)
            local accentBar = mk("Frame", {BackgroundColor3=Color3.new(1,1,1), Size=UDim2.new(0,3,1,-8), Position=UDim2.fromOffset(4,4), BorderSizePixel=0, Parent=frame}); rc(accentBar,2)
            mk("UIGradient", {Color=ColorSequence.new(GradStart, GradEnd), Rotation=90, Parent=accentBar})
            local tLbl = mk("TextLabel", {Text=pcfg2.Title or "", TextColor3=C.Text, Font=F.Semi, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-18,0,18), Position=UDim2.fromOffset(14,5), Parent=frame})
            local cLbl = mk("TextLabel", {Text=pcfg2.Content or "", TextColor3=C.Dim, Font=F.Reg, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, TextYAlignment=Enum.TextYAlignment.Top, BackgroundTransparency=1, Size=UDim2.new(1,-18,0,28), Position=UDim2.fromOffset(14,24), Parent=frame})
            local function resize()
                local ts=game:GetService("TextService")
                local b=ts:GetTextSize(cLbl.Text,11,F.Reg,Vector2.new(math.max(frame.AbsoluteSize.X-18,80),1000))
                local h=math.max(56,28+b.Y+8); frame.Size=UDim2.new(1,0,0,h); cLbl.Size=UDim2.new(1,-18,0,b.Y+2)
            end; task.defer(resize)
            function para:Set(c2) if c2.Title then tLbl.Text=c2.Title end; if c2.Content then cLbl.Text=c2.Content; task.defer(resize) end end; return para
        end

        -- ========== COLOR PICKER ==========
        function target:CreateColorPicker(ccfg)
            ccfg = ccfg or {}
            local value = ccfg.Default or Color3.fromRGB(130,87,230)
            local picker = {Value=value}; local pickerOpen=false; local closedH,openH=34,128

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,closedH), BorderSizePixel=0, ClipsDescendants=true, LayoutOrder=wNextOrder(), Parent=getWidgetParent()}); rc(frame,CORNER.Widget)
            mk("TextLabel", {Text=ccfg.Name or "Color", TextColor3=C.Label, Font=F.Med, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-44,0,closedH), Position=UDim2.fromOffset(8,0), Parent=frame})
            local preview = mk("Frame", {BackgroundColor3=value, Size=UDim2.fromOffset(20,20), Position=UDim2.new(1,-28,0,7), BorderSizePixel=0, Parent=frame}); rc(preview,10); st(preview,C.Border)
            local previewBtn = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,0,closedH), ZIndex=2, AutoButtonColor=false, Parent=frame})

            local cR,cG,cB = value.R, value.G, value.B
            local channelSliders = {}
            local function updateColor()
                value=Color3.new(math.clamp(cR,0,1),math.clamp(cG,0,1),math.clamp(cB,0,1))
                picker.Value=value; preview.BackgroundColor3=value
                if ccfg.Callback then pcall(ccfg.Callback, value) end; DebouncedSave()
            end

            for ci, ch in ipairs({{"R",function() return cR end,function(v) cR=v end},{"G",function() return cG end,function(v) cG=v end},{"B",function() return cB end,function(v) cB=v end}}) do
                local chName,getV,setV = ch[1],ch[2],ch[3]
                local yOff = closedH+2+(ci-1)*26
                mk("TextLabel", {Text=chName, TextColor3=C.Dim, Font=F.Semi, TextSize=11, BackgroundTransparency=1, Size=UDim2.fromOffset(14,18), Position=UDim2.fromOffset(8,yOff+1), Parent=frame})
                local chTrack = mk("Frame", {BackgroundColor3=C.SliderBg, Size=UDim2.new(1,-52,0,5), Position=UDim2.new(0,26,0,yOff+7), BorderSizePixel=0, Parent=frame}); rc(chTrack,3)
                local chFill = mk("Frame", {BackgroundColor3=Color3.new(1,1,1), Size=UDim2.new(getV(),0,1,0), BorderSizePixel=0, Parent=chTrack}); rc(chFill,3)
                mk("UIGradient", {Color=ColorSequence.new(GradStart, GradEnd), Parent=chFill})
                local chVal = mk("TextLabel", {Text=tostring(math.floor(getV()*255)), TextColor3=C.ValText, Font=F.Semi, TextSize=11, BackgroundTransparency=1, Size=UDim2.fromOffset(22,18), Position=UDim2.new(1,-24,0,yOff), TextXAlignment=Enum.TextXAlignment.Right, Parent=frame})
                local chSliding=false
                local chHit = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,-52,0,18), Position=UDim2.new(0,26,0,yOff), AutoButtonColor=false, Parent=frame})
                chHit.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then chSliding=true; local p=math.clamp((input.Position.X-chTrack.AbsolutePosition.X)/math.max(chTrack.AbsoluteSize.X,1),0,1); setV(p); chFill.Size=UDim2.new(p,0,1,0); chVal.Text=tostring(math.floor(p*255)); updateColor() end end)
                UIS.InputChanged:Connect(function(input) if chSliding and input.UserInputType==Enum.UserInputType.MouseMovement then local p=math.clamp((input.Position.X-chTrack.AbsolutePosition.X)/math.max(chTrack.AbsoluteSize.X,1),0,1); setV(p); chFill.Size=UDim2.new(p,0,1,0); chVal.Text=tostring(math.floor(p*255)); updateColor() end end)
                UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then chSliding=false end end)
                table.insert(channelSliders, {fill=chFill, valLbl=chVal, getV=getV})
            end
            previewBtn.MouseButton1Click:Connect(function() pickerOpen=not pickerOpen; tw(frame,{Size=UDim2.new(1,0,0,pickerOpen and openH or closedH)},0.18) end)
            function picker:Set(col) if typeof(col)~="Color3" then return end; cR,cG,cB=col.R,col.G,col.B; value=col; picker.Value=col; preview.BackgroundColor3=col; for _,s in ipairs(channelSliders) do s.fill.Size=UDim2.new(s.getV(),0,1,0); s.valLbl.Text=tostring(math.floor(s.getV()*255)) end end
            if ccfg.Flag then Flags[ccfg.Flag]={get=function() return {R=math.floor(cR*255),G=math.floor(cG*255),B=math.floor(cB*255)} end, set=function(v) if type(v)=="table" and v.R then picker:Set(Color3.fromRGB(v.R,v.G,v.B)) end end} end
            frame.MouseEnter:Connect(function() tw(frame,{BackgroundColor3=C.Hover},0.08) end)
            frame.MouseLeave:Connect(function() tw(frame,{BackgroundColor3=C.Surface},0.08) end)
            return picker
        end

        -- ========== DUAL PANE ==========
        function target:CreateDualPane()
            local pane = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,100), LayoutOrder=wNextOrder(), Parent=wContent})

            local leftCol = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(0.5,-3,0,0), Position=UDim2.fromOffset(0,0), Parent=pane})
            local leftLayout = mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,3), Parent=leftCol})

            local rightCol = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(0.5,-3,0,0), Position=UDim2.new(0.5,3,0,0), Parent=pane})
            local rightLayout = mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,3), Parent=rightCol})

            local function updateHeight()
                local lh = leftLayout.AbsoluteContentSize.Y
                local rh = rightLayout.AbsoluteContentSize.Y
                local h = math.max(lh, rh) + 4
                pane.Size = UDim2.new(1,0,0,h)
                leftCol.Size = UDim2.new(0.5,-3,0,lh)
                rightCol.Size = UDim2.new(0.5,-3,0,rh)
            end
            leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)
            rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)

            local Left, Right = {}, {}
            attachWidgets(Left, leftCol)
            attachWidgets(Right, rightCol)
            return Left, Right
        end
    end -- end attachWidgets

    -- ==================== TAB BUTTON HELPER ====================
    local function createTabButton(tabName, tabIcon, isFirst, parent, layoutOrder)
        local btn = mk("TextButton", {
            Name = tabName, Text = "",
            BackgroundColor3 = isFirst and C.TabActive or C.Sidebar,
            Size = UDim2.new(1, 0, 0, 32),
            BorderSizePixel = 0, AutoButtonColor = false,
            LayoutOrder = layoutOrder,
            Parent = parent,
        })
        rc(btn, CORNER.Tab)

        local indicator = mk("Frame", {
            BackgroundColor3 = Color3.new(1,1,1),
            Size = UDim2.new(0, 3, 0, 18),
            Position = UDim2.new(0, 2, 0.5, -9),
            BorderSizePixel = 0,
            Visible = isFirst,
            Parent = btn,
        })
        rc(indicator, 2)
        mk("UIGradient", {Color=ColorSequence.new(GradStart, GradEnd), Rotation=90, Parent=indicator})

        local iconLabel = nil
        if tabIcon and tabIcon ~= "" then
            iconLabel = mk("ImageLabel", {
                Image = tabIcon, ImageColor3 = isFirst and C.Text or C.Dim,
                BackgroundTransparency = 1, Size = UDim2.fromOffset(18, 18),
                Position = UDim2.fromOffset(14, 7), ScaleType = Enum.ScaleType.Fit, Parent = btn,
            })
        end

        local nameLabel = mk("TextLabel", {
            Text = tabName, TextColor3 = isFirst and C.Text or C.Dim,
            Font = F.Med, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -((tabIcon and tabIcon ~= "") and 40 or 16), 1, 0),
            Position = UDim2.fromOffset((tabIcon and tabIcon ~= "") and 38 or 14, 0),
            Parent = btn,
        })

        return btn, indicator, iconLabel, nameLabel
    end

    -- ==================== CREATE TAB ====================
    function Window:CreateTab(tabArg)
        local tabName, tabIcon, tabSection
        if type(tabArg)=="table" then tabName=tabArg.Name or "Tab"; tabIcon=tabArg.Icon; tabSection=tabArg.Section
        else tabName=tostring(tabArg or "Tab") end

        local Tab = {}
        local isFirst = #tabs==0

        -- Add section header if new section encountered
        if tabSection and not _seenSections[tabSection] then
            _seenSections[tabSection] = true
            _sidebarOrder = _sidebarOrder + 1
            local sLbl = mk("TextLabel", {
                Text = string.upper(tabSection), TextColor3 = C.SectionDim,
                Font = F.Semi, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 22),
                LayoutOrder = _sidebarOrder, Parent = sidebarScroll,
            })
            pad(sLbl, 6, 0, 0, 8)
        end

        _sidebarOrder = _sidebarOrder + 1
        local tabBtn, indicator, iconLabel, nameLabel = createTabButton(tabName, tabIcon, isFirst, sidebarScroll, _sidebarOrder)

        local content = mk("ScrollingFrame", {Name=tabName, BackgroundTransparency=1, Size=UDim2.new(1,-12,1,-6), Position=UDim2.fromOffset(6,3), ScrollBarThickness=3, ScrollBarImageColor3=C.AccentDk, CanvasSize=UDim2.new(0,0,0,0), BorderSizePixel=0, Visible=isFirst, Parent=contentArea})
        local cLayout = mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,3), Parent=content})
        cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() content.CanvasSize=UDim2.new(0,0,0,cLayout.AbsoluteContentSize.Y+10) end)

        local tabData = {name=tabName, button=tabBtn, indicator=indicator, content=content, iconLabel=iconLabel, nameLabel=nameLabel}
        table.insert(tabs, tabData)
        if isFirst then activeTab=tabName end

        tabBtn.MouseButton1Click:Connect(function() selectTab(tabName) end)
        tabBtn.MouseEnter:Connect(function() if activeTab~=tabName then tw(tabBtn, {BackgroundColor3=C.Hover}, 0.1) end end)
        tabBtn.MouseLeave:Connect(function() if activeTab~=tabName then tw(tabBtn, {BackgroundColor3=C.Sidebar}, 0.1) end end)

        attachWidgets(Tab, content)

        -- ==================== SUB-TABS ====================
        local subTabs = {}
        local activeSubTab = nil
        local subTabBar = nil

        function Tab:CreateSubTab(subTabName)
            local SubTab = {}
            local isFirstSub = #subTabs==0

            if isFirstSub then
                content.Visible = false
                local subContainer = mk("Frame", {Name=tabName.."_Sub", BackgroundTransparency=1, Size=UDim2.new(1,-12,1,-6), Position=UDim2.fromOffset(6,3), ClipsDescendants=true, Visible=(activeTab==tabName), Parent=contentArea})
                tabData.content = subContainer

                subTabBar = mk("Frame", {BackgroundColor3=C.Header, BackgroundTransparency=0.15, Size=UDim2.new(1,0,0,36), BorderSizePixel=0, Parent=subContainer}); rc(subTabBar,CORNER.Widget)
                mk("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,1), Parent=subTabBar})
            end

            local subBtn = mk("TextButton", {Text=subTabName, TextColor3=isFirstSub and C.Text or C.Dim, Font=F.Semi, TextSize=14, BackgroundTransparency=1, Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X, AutoButtonColor=false, LayoutOrder=#subTabs, Parent=subTabBar})
            pad(subBtn, 0,14,0,14)

            local glowLine = mk("Frame", {BackgroundColor3=Color3.new(1,1,1), BackgroundTransparency=isFirstSub and 0 or 1, Size=UDim2.new(1,4,0,2), Position=UDim2.new(0,-2,1,-2), BorderSizePixel=0, Parent=subBtn}); rc(glowLine,1)
            mk("UIGradient", {Color=ColorSequence.new(GradStart, GradEnd), Parent=glowLine})

            local subContent = mk("ScrollingFrame", {Name=subTabName, BackgroundTransparency=1, Size=UDim2.new(1,0,1,-40), Position=UDim2.fromOffset(0,39), ScrollBarThickness=3, ScrollBarImageColor3=C.AccentDk, CanvasSize=UDim2.new(0,0,0,0), BorderSizePixel=0, Visible=isFirstSub, Parent=tabData.content})
            local subLayout = mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,3), Parent=subContent})
            subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() subContent.CanvasSize=UDim2.new(0,0,0,subLayout.AbsoluteContentSize.Y+10) end)

            table.insert(subTabs, {name=subTabName, button=subBtn, content=subContent, glow=glowLine})
            if isFirstSub then activeSubTab=subTabName end

            local function selectSubTab(stName)
                for _, s in ipairs(subTabs) do
                    if s.name==stName then
                        s.content.Visible=true; s.content.Position=UDim2.fromOffset(14,39)
                        tw(s.content, {Position=UDim2.fromOffset(0,39)}, 0.2)
                        s.button.TextColor3=C.Text
                        tw(s.glow, {BackgroundTransparency=0}, 0.15)
                        activeSubTab=stName
                    else
                        s.content.Visible=false; s.button.TextColor3=C.Dim
                        tw(s.glow, {BackgroundTransparency=1}, 0.15)
                    end
                end
            end
            subBtn.MouseButton1Click:Connect(function() selectSubTab(subTabName) end)
            subBtn.MouseEnter:Connect(function() if activeSubTab~=subTabName then tw(subBtn,{TextColor3=C.AccentH},0.08) end end)
            subBtn.MouseLeave:Connect(function() if activeSubTab~=subTabName then tw(subBtn,{TextColor3=C.Dim},0.08) end end)

            attachWidgets(SubTab, subContent)
            return SubTab
        end

        return Tab
    end

    -- ==================== SETTINGS TAB ====================
    if cfgEnabled then
        -- Add settings section header (high LayoutOrder so it's always last)
        local settingsSectionLbl = mk("TextLabel", {
            Text = "SETTINGS", TextColor3 = C.SectionDim,
            Font = F.Semi, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 22),
            LayoutOrder = 9998, Parent = sidebarScroll,
        })
        pad(settingsSectionLbl, 6, 0, 0, 8)

        local settingsIcon = cfg.SettingsIcon or ""
        local sBtn, sIndicator, sIconLabel, sNameLabel = createTabButton("Settings", settingsIcon, false, sidebarScroll, 9999)

        local settingsContent = mk("ScrollingFrame", {Name="Settings", BackgroundTransparency=1, Size=UDim2.new(1,-12,1,-6), Position=UDim2.fromOffset(6,3), ScrollBarThickness=3, ScrollBarImageColor3=C.AccentDk, CanvasSize=UDim2.new(0,0,0,0), BorderSizePixel=0, Visible=false, Parent=contentArea})
        local sLayout = mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,3), Parent=settingsContent})
        sLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() settingsContent.CanvasSize=UDim2.new(0,0,0,sLayout.AbsoluteContentSize.Y+10) end)

        settingsTabData = {name="Settings", button=sBtn, indicator=sIndicator, content=settingsContent, iconLabel=sIconLabel, nameLabel=sNameLabel}

        sBtn.MouseButton1Click:Connect(function() selectTab("Settings") end)
        sBtn.MouseEnter:Connect(function() if activeTab~="Settings" then tw(sBtn, {BackgroundColor3=C.Hover}, 0.1) end end)
        sBtn.MouseLeave:Connect(function() if activeTab~="Settings" then tw(sBtn, {BackgroundColor3=C.Sidebar}, 0.1) end end)

        local SettingsTab = {}
        attachWidgets(SettingsTab, settingsContent)

        SettingsTab:CreateSection("Configuration")
        local profileList=ListConfigs(); if #profileList==0 then profileList={cfgDefaultName} end
        local currentProfile=cfgDefaultName
        SettingsTab:CreateDropdown({Name="Config Profile", Options=profileList, CurrentOption=cfgDefaultName, Callback=function(v) currentProfile=type(v)=="table" and v[1] or v end})
        SettingsTab:CreateButton({Name="Load Config", Callback=function() LoadConfig(currentProfile); Library:Notify({Title="Config",Content="Loaded: "..currentProfile,Duration=2,Type="success"}) end})
        SettingsTab:CreateButton({Name="Save Config", Callback=function() SaveConfig(currentProfile); Library:Notify({Title="Config",Content="Saved: "..currentProfile,Duration=2,Type="success"}) end})
        SettingsTab:CreateButton({Name="Delete Config", Callback=function() Window:Dialog({Title="Delete Profile",Content="Delete '"..currentProfile.."'?",Buttons={{Name="Delete",Callback=function() DeleteConfig(currentProfile); Library:Notify({Title="Config",Content="Deleted: "..currentProfile,Duration=2,Type="warning"}) end},{Name="Cancel",Callback=function() end}}}) end})
        SettingsTab:CreateInput({Name="New Profile", PlaceholderText="Profile name...", RemoveTextAfterFocusLost=true, Callback=function(text) if text and #text>0 then text=text:gsub("[^%w%-%_ ]",""); if #text>0 then SaveConfig(text); Library:Notify({Title="Config",Content="Created: "..text,Duration=2,Type="success"}) end end end})

        SettingsTab:CreateSection("General")
        SettingsTab:CreateToggle({Name="Auto-Save", Description="Save config on change", CurrentValue=cfgAutoSave, Callback=function(v) cfgAutoSave=v end})
        SettingsTab:CreateToggle({Name="Auto-Load Config", Description="Load default config on startup", CurrentValue=cfgAutoLoad, Callback=function(v) cfgAutoLoad=v; SaveAutoLoadPref() end})
        SettingsTab:CreateParagraph({Title="Jitler Hub", Content=name.."\nRightControl to toggle UI.\nConfig: "..cfgFolder})

        SettingsTab:CreateSection("Theme")
        SettingsTab:CreateDropdown({Name="Theme Preset", Options=ThemeNames, CurrentOption=UISettings.Theme, Flag="UITheme", Callback=function(v)
            UISettings.Theme = v
            local preset = Themes[v]
            if preset then GradStart = preset.GradStart; GradEnd = preset.GradEnd
            elseif v == "Custom" then GradStart = UISettings.CustomGradStart; GradEnd = UISettings.CustomGradEnd end
            C.Accent = GradStart; C.AccentH = GradStart; C.AccentDk = GradEnd; C.TogOn = GradStart; C.TogOnH = GradStart
            SaveUISettings()
        end})

        SettingsTab:CreateColorPicker({Name="Custom Gradient Start", Default=UISettings.CustomGradStart, Flag="UIGradStart", Callback=function(col)
            UISettings.CustomGradStart = col
            if UISettings.Theme == "Custom" then GradStart = col; C.Accent = col; C.AccentH = col; C.TogOn = col; C.TogOnH = col end
            SaveUISettings()
        end})
        SettingsTab:CreateColorPicker({Name="Custom Gradient End", Default=UISettings.CustomGradEnd, Flag="UIGradEnd", Callback=function(col)
            UISettings.CustomGradEnd = col
            if UISettings.Theme == "Custom" then GradEnd = col; C.AccentDk = col end
            SaveUISettings()
        end})

        SettingsTab:CreateSection("Background")
        SettingsTab:CreateSlider({Name="Main Background Transparency", Range={0,0.9}, Increment=0.05, Suffix="", CurrentValue=UISettings.BgTransparency, Flag="UIBgTrans", Callback=function(v)
            UISettings.BgTransparency = v; main.BackgroundTransparency = v; SaveUISettings()
        end})
        SettingsTab:CreateSlider({Name="Sidebar Transparency", Range={0,0.95}, Increment=0.05, Suffix="", CurrentValue=UISettings.SidebarTransparency, Flag="UISidebarTrans", Callback=function(v)
            UISettings.SidebarTransparency = v; sidebar.BackgroundTransparency = v; SaveUISettings()
        end})
        SettingsTab:CreateSlider({Name="Card Transparency", Range={0,0.8}, Increment=0.05, Suffix="", CurrentValue=UISettings.CardTransparency, Flag="UICardTrans", Callback=function(v)
            UISettings.CardTransparency = v; SaveUISettings()
        end})

        SettingsTab:CreateSection("Visual")
        SettingsTab:CreateToggle({Name="Enable Shadow", Description="Outer shadow layers", CurrentValue=UISettings.EnableShadow, Flag="UIShadow", Callback=function(v)
            UISettings.EnableShadow = v; shadowOuter.Visible = v; shadowMid.Visible = v; SaveUISettings()
        end})

        SettingsTab:CreateSection("Theme Persistence")
        SettingsTab:CreateButton({Name="Save UI Theme", Callback=function() SaveUISettings(); Library:Notify({Title="UI Theme",Content="Theme saved!",Duration=2,Type="success"}) end})
        SettingsTab:CreateButton({Name="Load UI Theme", Callback=function() LoadUISettings(); Library:Notify({Title="UI Theme",Content="Theme loaded! Rejoin for full effect.",Duration=3,Type="info"}) end})
    end

    -- ==================== LOADING ====================
    if hasLoading then
        task.spawn(function()
            for i=1,20 do local p=i/20; tw(loadFill,{Size=UDim2.new(p,0,1,0)},0.07); loadPct.Text=tostring(math.floor(p*100)).."%"; task.wait(0.05) end
            task.wait(0.15)
            tw(loadScreen,{BackgroundTransparency=1},0.35)
            for _,d in ipairs(loadScreen:GetDescendants()) do
                if d:IsA("TextLabel") then tw(d,{TextTransparency=1},0.25) end
                if d:IsA("ImageLabel") then tw(d,{ImageTransparency=1},0.25) end
                if d:IsA("Frame") then tw(d,{BackgroundTransparency=1},0.25) end
            end
            task.wait(0.4); loadScreen.Visible=false
            mainWrapper.Visible=true; main.BackgroundTransparency=1; mainSt.Transparency=1
            tw(main,{BackgroundTransparency=UISettings.BgTransparency},0.2); tw(mainSt,{Transparency=0.3},0.2)
        end)
    end

    pcall(LoadUISettings)
    if cfgEnabled and cfgAutoLoad then task.delay(0.8, function() LoadConfig() end) end
    return Window
end

return Library
