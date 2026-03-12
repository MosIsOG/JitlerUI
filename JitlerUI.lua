-- JitlerUI.lua v4 — Premium Exploit Hub UI Library
-- Purple accent, glass sidebar, hex icon tabs, slider knobs, two-column layout

local Library = {}
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpSvc = game:GetService("HttpService")

-- ==================== THEME ====================
local C = {
    Bg        = Color3.fromRGB(16, 16, 22),
    Sidebar   = Color3.fromRGB(22, 22, 30),
    Header    = Color3.fromRGB(18, 18, 26),
    Surface   = Color3.fromRGB(25, 27, 37),
    Hover     = Color3.fromRGB(33, 35, 49),
    Accent    = Color3.fromRGB(130, 87, 230),
    AccentH   = Color3.fromRGB(160, 120, 255),
    AccentDk  = Color3.fromRGB(80, 50, 170),
    Text      = Color3.fromRGB(228, 230, 240),
    Dim       = Color3.fromRGB(100, 104, 130),
    TogOff    = Color3.fromRGB(58, 60, 74),
    TogOn     = Color3.fromRGB(130, 87, 230),
    TogOnH    = Color3.fromRGB(155, 115, 250),
    TogOffH   = Color3.fromRGB(72, 74, 88),
    Border    = Color3.fromRGB(36, 38, 52),
    SliderBg  = Color3.fromRGB(26, 28, 40),
    Green     = Color3.fromRGB(56, 198, 116),
    Red       = Color3.fromRGB(238, 56, 56),
    Yellow    = Color3.fromRGB(248, 198, 48),
    WidgetBorder = Color3.fromRGB(32, 34, 48),
    TabBg     = Color3.fromRGB(26, 26, 36),
    TabActive = Color3.fromRGB(48, 30, 85),
}
local F = {
    Bold = Enum.Font.GothamBold,
    Semi = Enum.Font.GothamSemibold,
    Med  = Enum.Font.GothamMedium,
    Reg  = Enum.Font.Gotham,
}

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
local function rc(parent, r) return mk("UICorner", {CornerRadius = UDim.new(0, r or 6), Parent = parent}) end
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
    rc(nf, 6); local nfSt = st(nf, barColor, 1); nfSt.Transparency = 0.4
    local bar = mk("Frame", {BackgroundColor3=barColor, Size=UDim2.new(0,3,1,-10), Position=UDim2.fromOffset(4,5), BorderSizePixel=0, Parent=nf}); rc(bar,2)
    mk("TextLabel", {Text=title, TextColor3=barColor, Font=F.Bold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-20,0,16), Position=UDim2.fromOffset(14,5), Parent=nf})
    local cLbl = mk("TextLabel", {Text=content, TextColor3=C.Text, Font=F.Reg, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, BackgroundTransparency=1, Size=UDim2.new(1,-20,0,24), Position=UDim2.fromOffset(14,22), Parent=nf})
    tw(nf, {Size=UDim2.new(1,0,0,52)}, 0.2)
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
        loadScreen = mk("Frame", {Name="Loading", BackgroundColor3=C.Bg, Size=UDim2.new(1,0,1,0), ZIndex=100, BorderSizePixel=0, Parent=sg})
        local center = mk("Frame", {BackgroundTransparency=1, Size=UDim2.fromOffset(300,140), Position=UDim2.new(0.5,-150,0.5,-70), ZIndex=101, Parent=loadScreen})
        local loadIcon = cfg.Icon
        if loadIcon and loadIcon ~= "" then
            mk("ImageLabel", {Image=loadIcon, BackgroundTransparency=1, Size=UDim2.fromOffset(44,44), Position=UDim2.new(0.5,-22,0,0), ScaleType=Enum.ScaleType.Fit, ZIndex=102, Parent=center})
        end
        local titleY = (loadIcon and loadIcon ~= "") and 50 or 8
        mk("TextLabel", {Text=cfg.LoadingTitle or "Loading", TextColor3=C.Text, Font=F.Bold, TextSize=18, BackgroundTransparency=1, Size=UDim2.new(1,0,0,24), Position=UDim2.fromOffset(0,titleY), ZIndex=102, Parent=center})
        mk("TextLabel", {Text=cfg.LoadingSubtitle or "", TextColor3=C.Dim, Font=F.Reg, TextSize=12, BackgroundTransparency=1, Size=UDim2.new(1,0,0,18), Position=UDim2.fromOffset(0,titleY+24), ZIndex=102, Parent=center})
        local loadBar = mk("Frame", {BackgroundColor3=C.SliderBg, Size=UDim2.new(0.75,0,0,3), Position=UDim2.new(0.125,0,0,titleY+54), BorderSizePixel=0, ZIndex=102, Parent=center}); rc(loadBar,2)
        loadFill = mk("Frame", {BackgroundColor3=C.Accent, Size=UDim2.new(0,0,1,0), BorderSizePixel=0, ZIndex=103, Parent=loadBar}); rc(loadFill,2)
        loadPct = mk("TextLabel", {Text="0%", TextColor3=C.Dim, Font=F.Reg, TextSize=10, BackgroundTransparency=1, Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,0,titleY+60), ZIndex=102, Parent=center})
    end

    -- ==================== MAIN FRAME ====================
    local WIN_W, WIN_H = 820, 560
    local SIDEBAR_W = 54
    local HEADER_H = 40

    local main = mk("Frame", {Name="Main", BackgroundColor3=C.Bg, Size=UDim2.fromOffset(WIN_W, WIN_H), Position=UDim2.new(0.5,-math.floor(WIN_W/2),0.5,-math.floor(WIN_H/2)), BorderSizePixel=0, ClipsDescendants=false, Visible=not hasLoading, Parent=sg})
    rc(main, 8)
    local mainSt = st(main, C.Border, 1); mainSt.Transparency = 0.3

    -- ==================== GLASS SIDEBAR ====================
    local sidebar = mk("Frame", {Name="Sidebar", BackgroundColor3=C.Sidebar, BackgroundTransparency=0.30, Size=UDim2.new(0,SIDEBAR_W,1,0), BorderSizePixel=0, ClipsDescendants=false, Parent=main})
    -- Right edge line
    mk("Frame", {BackgroundColor3=C.Border, BackgroundTransparency=0.4, Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,0,0,0), BorderSizePixel=0, Parent=sidebar})

    -- Brand dot (top of sidebar)
    local brandGlow = mk("Frame", {BackgroundColor3=C.Accent, BackgroundTransparency=0.7, Size=UDim2.fromOffset(18,18), Position=UDim2.fromOffset(18,14), BorderSizePixel=0, Parent=sidebar}); rc(brandGlow,9)
    mk("Frame", {BackgroundColor3=C.Accent, Size=UDim2.fromOffset(6,6), Position=UDim2.fromOffset(24,20), BorderSizePixel=0, Parent=sidebar}); rc(brandGlow,3)

    -- ==================== RIGHT AREA ====================
    local rightArea = mk("Frame", {Name="RightArea", BackgroundTransparency=1, Size=UDim2.new(1,-(SIDEBAR_W+1),1,0), Position=UDim2.fromOffset(SIDEBAR_W+1,0), ClipsDescendants=true, Parent=main})

    -- Header
    local header = mk("Frame", {Name="Header", BackgroundColor3=C.Header, Size=UDim2.new(1,0,0,HEADER_H), BorderSizePixel=0, Parent=rightArea})
    mk("UIGradient", {Transparency=NumberSequence.new(0.2,0.05), Rotation=90, Parent=header})

    local headerIcon = cfg.Icon
    if headerIcon and headerIcon ~= "" then
        mk("ImageLabel", {Image=headerIcon, BackgroundTransparency=1, Size=UDim2.fromOffset(22,22), Position=UDim2.new(0,12,0.5,-11), ScaleType=Enum.ScaleType.Fit, Parent=header})
        mk("TextLabel", {Text=name, TextColor3=C.Text, Font=F.Bold, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-110,1,0), Position=UDim2.fromOffset(40,0), Parent=header})
    else
        mk("TextLabel", {Text=name, TextColor3=C.Text, Font=F.Bold, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-110,1,0), Position=UDim2.fromOffset(12,0), Parent=header})
    end
    mk("Frame", {BackgroundColor3=C.Border, BackgroundTransparency=0.5, Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BorderSizePixel=0, Parent=header})

    -- Close / Minimize
    local closeBtn = mk("TextButton", {Text="\226\156\149", TextColor3=C.Dim, Font=F.Bold, TextSize=14, BackgroundTransparency=1, Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-32,0,6), AutoButtonColor=false, Parent=header})
    local minBtn = mk("TextButton", {Text="\226\148\128", TextColor3=C.Dim, Font=F.Bold, TextSize=12, BackgroundTransparency=1, Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-58,0,6), AutoButtonColor=false, Parent=header})
    for _, b in ipairs({closeBtn, minBtn}) do
        b.MouseEnter:Connect(function() tw(b, {TextColor3=C.Text}, 0.1) end)
        b.MouseLeave:Connect(function() tw(b, {TextColor3=C.Dim}, 0.1) end)
    end

    -- Content area
    local contentArea = mk("Frame", {Name="Content", BackgroundTransparency=1, Size=UDim2.new(1,0,1,-HEADER_H), Position=UDim2.fromOffset(0,HEADER_H), ClipsDescendants=true, Parent=rightArea})

    -- Dialog overlay
    local dialogOverlay = mk("Frame", {Name="DialogOverlay", BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.5, Size=UDim2.new(1,0,1,0), Visible=false, ZIndex=50, Parent=main})

    -- Notifications
    local notifC = mk("Frame", {Name="Notifs", BackgroundTransparency=1, Size=UDim2.new(0,280,1,0), Position=UDim2.new(1,-290,0,8), Parent=sg})
    mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5), VerticalAlignment=Enum.VerticalAlignment.Top, Parent=notifC})
    _notifContainer = notifC

    -- ==================== STATE ====================
    local Window = {}
    local tabs = {}
    local activeTab = nil
    local minimized = false
    local Flags = {}

    -- ==================== CONFIG ====================
    local cfgSave = cfg.ConfigurationSaving or {}
    local cfgEnabled = cfgSave.Enabled == true
    local cfgFolder = cfgSave.FolderName or "JitlerHub"
    local cfgDefaultName = cfgSave.FileName or "Default"
    local cfgAutoSave = true
    local _saveThread = nil

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

    -- ==================== DIALOG ====================
    function Window:Dialog(dc)
        dc = dc or {}
        for _,c in ipairs(dialogOverlay:GetChildren()) do c:Destroy() end
        dialogOverlay.Visible = true
        local panel = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.fromOffset(300,0), Position=UDim2.new(0.5,-150,0.5,-65), BorderSizePixel=0, ClipsDescendants=true, ZIndex=51, Parent=dialogOverlay}); rc(panel,8); st(panel,C.AccentDk)
        mk("TextLabel", {Text=dc.Title or "Confirm", TextColor3=C.Text, Font=F.Bold, TextSize=14, BackgroundTransparency=1, Size=UDim2.new(1,-16,0,26), Position=UDim2.fromOffset(8,8), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=52, Parent=panel})
        mk("TextLabel", {Text=dc.Content or "", TextColor3=C.Dim, Font=F.Reg, TextSize=11, TextWrapped=true, BackgroundTransparency=1, Size=UDim2.new(1,-16,0,36), Position=UDim2.fromOffset(8,34), TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, ZIndex=52, Parent=panel})
        local btnRow = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-12,0,28), Position=UDim2.fromOffset(6,78), ZIndex=52, Parent=panel})
        mk("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5), HorizontalAlignment=Enum.HorizontalAlignment.Right, Parent=btnRow})

        local function closeDialog() tw(panel, {Size=UDim2.fromOffset(300,0)}, 0.15); task.delay(0.15, function() dialogOverlay.Visible=false end) end
        for i, bc in ipairs(dc.Buttons or {}) do
            local ia = i==1
            local db = mk("TextButton", {Text=bc.Name or "OK", TextColor3=ia and C.Text or C.Dim, Font=F.Semi, TextSize=11, BackgroundColor3=ia and C.Accent or C.Bg, Size=UDim2.fromOffset(76,26), BorderSizePixel=0, AutoButtonColor=false, LayoutOrder=i, ZIndex=53, Parent=btnRow}); rc(db,5)
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
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=input.Position; startPos=main.Position end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local d=input.Position-dragStart; main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
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
    closeBtn.MouseButton1Click:Connect(function() main.Visible=false end)
    UIS.InputBegan:Connect(function(input,gp) if gp then return end; if input.KeyCode==Enum.KeyCode.RightControl then main.Visible=not main.Visible end end)

    -- ==================== TAB SELECTION ====================
    local function selectTab(tabName)
        for _, t in ipairs(tabs) do
            if t.name == tabName then
                t.content.Visible = true
                tw(t.btn, {BackgroundColor3=C.TabActive}, 0.2)
                tw(t.stroke, {Transparency=0.3, Color=C.Accent}, 0.2)
                if t.iconImg then tw(t.iconImg, {ImageColor3=C.Text}, 0.2) end
                if t.iconTxt then t.iconTxt.TextColor3 = C.Text end
                activeTab = tabName
            else
                t.content.Visible = false
                tw(t.btn, {BackgroundColor3=C.TabBg}, 0.2)
                tw(t.stroke, {Transparency=1}, 0.2)
                if t.iconImg then tw(t.iconImg, {ImageColor3=C.Dim}, 0.2) end
                if t.iconTxt then t.iconTxt.TextColor3 = C.Dim end
            end
        end
    end

    -- Hex tab positioning (zig-zag)
    local TAB_SIZE = 38
    local TAB_START_Y = 52
    local TAB_SPACING = 50
    local function getTabPos(idx)
        local x = (idx % 2 == 0) and 4 or 12
        local y = TAB_START_Y + idx * TAB_SPACING
        return x, y
    end

    -- ==================== WIDGET FACTORY ====================
    local function attachWidgets(target, wContent)
        local wOrder = 0
        local function wNextOrder() wOrder = wOrder + 1; return wOrder end

        -- ========== SECTION ==========
        function target:CreateSection(sectionName)
            local sec = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,24), LayoutOrder=wNextOrder(), Parent=wContent})
            mk("Frame", {BackgroundColor3=C.Accent, Size=UDim2.new(0,3,0,14), Position=UDim2.fromOffset(0,5), BorderSizePixel=0, Parent=sec}); -- accent bar
            mk("TextLabel", {Text=sectionName, TextColor3=C.AccentH, Font=F.Semi, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-12,1,0), Position=UDim2.fromOffset(9,0), Parent=sec})
            mk("Frame", {BackgroundColor3=C.Border, BackgroundTransparency=0.5, Size=UDim2.new(0.5,0,0,1), Position=UDim2.new(0.5,0,0.5,0), BorderSizePixel=0, Parent=sec})
        end

        -- ========== TOGGLE ==========
        function target:CreateToggle(tcfg)
            local value = tcfg.CurrentValue or false
            local toggle = {Value = value}
            local hasDesc = tcfg.Description and tcfg.Description ~= ""
            local frameH = hasDesc and 40 or 30

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,frameH), BorderSizePixel=0, LayoutOrder=wNextOrder(), Parent=wContent})
            rc(frame, 6); st(frame, C.WidgetBorder)

            mk("TextLabel", {Text=tcfg.Name or "Toggle", TextColor3=C.Text, Font=F.Med, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-56,0,16), Position=UDim2.fromOffset(8, hasDesc and 4 or 7), Parent=frame})
            if hasDesc then mk("TextLabel", {Text=tcfg.Description, TextColor3=C.Dim, Font=F.Reg, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-56,0,12), Position=UDim2.fromOffset(8,20), Parent=frame}) end

            local swBg = mk("Frame", {BackgroundColor3=value and C.TogOn or C.TogOff, Size=UDim2.fromOffset(34,18), Position=UDim2.new(1,-42,0.5,-9), BorderSizePixel=0, Parent=frame}); rc(swBg,9)
            local circle = mk("Frame", {BackgroundColor3=C.Text, Size=UDim2.fromOffset(14,14), Position=value and UDim2.fromOffset(18,2) or UDim2.fromOffset(2,2), BorderSizePixel=0, Parent=swBg}); rc(circle,7)

            local function updateVis(v)
                tw(swBg, {BackgroundColor3=v and C.TogOn or C.TogOff}, 0.15)
                tw(circle, {Position=v and UDim2.fromOffset(18,2) or UDim2.fromOffset(2,2)}, 0.15)
            end
            function toggle:Set(v)
                if v==value then return end; value=v; toggle.Value=v; updateVis(v)
                if tcfg.Callback then pcall(tcfg.Callback, v) end
            end

            local overlay = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=2, AutoButtonColor=false, Parent=frame})
            overlay.MouseButton1Click:Connect(function()
                value=not value; toggle.Value=value; updateVis(value)
                if tcfg.Callback then pcall(tcfg.Callback, value) end; DebouncedSave()
            end)
            overlay.MouseEnter:Connect(function() tw(frame, {BackgroundColor3=C.Hover}, 0.08) end)
            overlay.MouseLeave:Connect(function() tw(frame, {BackgroundColor3=C.Surface}, 0.08) end)

            if tcfg.Flag then Flags[tcfg.Flag]={get=function() return value end, set=function(v) toggle:Set(v==true) end} end
            return toggle
        end

        -- ========== SLIDER (with knob) ==========
        function target:CreateSlider(scfg)
            local range = scfg.Range or {0,100}
            local mn, mx = range[1], range[2]
            local inc = scfg.Increment or 1
            local suffix = scfg.Suffix or ""
            local value = math.clamp(scfg.CurrentValue or mn, mn, mx)
            local slider = {Value = value}

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,44), BorderSizePixel=0, LayoutOrder=wNextOrder(), Parent=wContent})
            rc(frame, 6); st(frame, C.WidgetBorder)

            mk("TextLabel", {Text=scfg.Name or "Slider", TextColor3=C.Text, Font=F.Med, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(0.6,0,0,16), Position=UDim2.fromOffset(8,4), Parent=frame})
            local valLbl = mk("TextLabel", {Text=tostring(value)..suffix, TextColor3=C.AccentH, Font=F.Semi, TextSize=11, TextXAlignment=Enum.TextXAlignment.Right, BackgroundTransparency=1, Size=UDim2.new(0.4,-12,0,16), Position=UDim2.new(0.6,0,0,4), Parent=frame})

            local track = mk("Frame", {BackgroundColor3=C.SliderBg, Size=UDim2.new(1,-16,0,5), Position=UDim2.new(0,8,0,28), BorderSizePixel=0, Parent=frame}); rc(track,3)
            local pct = (value-mn)/math.max(mx-mn,0.001)
            local fill = mk("Frame", {BackgroundColor3=C.Accent, Size=UDim2.new(pct,0,1,0), BorderSizePixel=0, Parent=track}); rc(fill,3)
            mk("UIGradient", {Color=ColorSequence.new(C.AccentDk, C.Accent), Parent=fill})

            -- Circular knob
            local knob = mk("Frame", {BackgroundColor3=C.Text, Size=UDim2.fromOffset(12,12), Position=UDim2.new(pct,-6,0.5,-6), BorderSizePixel=0, ZIndex=3, Parent=track}); rc(knob,6)
            local knobGlow = mk("Frame", {BackgroundColor3=C.Accent, BackgroundTransparency=0.55, Size=UDim2.fromOffset(18,18), Position=UDim2.new(pct,-9,0.5,-9), BorderSizePixel=0, ZIndex=2, Parent=track}); rc(knobGlow,9)

            local function updateSlider(v)
                v = math.clamp(v, mn, mx)
                v = math.floor(v/inc+0.5)*inc
                v = math.clamp(v, mn, mx)
                if inc >= 1 then v = math.floor(v+0.5) end
                value = v; slider.Value = v
                local p = (v-mn)/math.max(mx-mn,0.001)
                fill.Size = UDim2.new(p,0,1,0)
                knob.Position = UDim2.new(p,-6,0.5,-6)
                knobGlow.Position = UDim2.new(p,-9,0.5,-9)
                valLbl.Text = tostring(v)..suffix
                if scfg.Callback then pcall(scfg.Callback, v) end; DebouncedSave()
            end
            function slider:Set(v) updateSlider(v) end

            local sliding = false
            local hitArea = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,0,22), AutoButtonColor=false, Parent=frame})
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
            local btn2 = mk("TextButton", {Text=bcfg.Name or "Button", TextColor3=C.Text, Font=F.Med, TextSize=12, BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,30), BorderSizePixel=0, AutoButtonColor=false, LayoutOrder=wNextOrder(), Parent=wContent})
            rc(btn2, 6); st(btn2, C.WidgetBorder)
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
            local current = dcfg.CurrentOption or (options[1] or "")
            local dropdown = {Value=current}
            local isOpen = false
            local closedH, optH = 30, 26

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,closedH), BorderSizePixel=0, ClipsDescendants=true, LayoutOrder=wNextOrder(), Parent=wContent})
            rc(frame, 6); st(frame, C.WidgetBorder)

            mk("TextLabel", {Text=dcfg.Name or "Dropdown", TextColor3=C.Text, Font=F.Med, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(0.5,0,0,closedH), Position=UDim2.fromOffset(8,0), Parent=frame})
            local selLbl = mk("TextLabel", {Text=current.." \226\150\190", TextColor3=C.AccentH, Font=F.Semi, TextSize=11, TextXAlignment=Enum.TextXAlignment.Right, BackgroundTransparency=1, Size=UDim2.new(0.5,-10,0,closedH), Position=UDim2.new(0.5,0,0,0), Parent=frame})

            local toggleBtn2 = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,0,closedH), ZIndex=2, AutoButtonColor=false, Parent=frame})
            local optC = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-6,0,#options*optH), Position=UDim2.new(0,3,0,closedH+2), Parent=frame})
            mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,1), Parent=optC})

            local function setCurrent(val) current=val; dropdown.Value=val; selLbl.Text=val.." \226\150\190"; if dcfg.Callback then pcall(dcfg.Callback, val) end; DebouncedSave() end
            function dropdown:Set(val) setCurrent(val) end

            for i, opt in ipairs(options) do
                local ob = mk("TextButton", {Text="  "..opt, TextColor3=C.Text, Font=F.Reg, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, BackgroundColor3=C.Bg, Size=UDim2.new(1,0,0,optH), BorderSizePixel=0, AutoButtonColor=false, LayoutOrder=i, Parent=optC})
                rc(ob, 4)
                ob.MouseButton1Click:Connect(function() setCurrent(opt); isOpen=false; tw(frame,{Size=UDim2.new(1,0,0,closedH)},0.15) end)
                ob.MouseEnter:Connect(function() tw(ob,{BackgroundColor3=C.Hover},0.06) end)
                ob.MouseLeave:Connect(function() tw(ob,{BackgroundColor3=C.Bg},0.06) end)
            end
            toggleBtn2.MouseButton1Click:Connect(function()
                isOpen=not isOpen; local openH=closedH+4+#options*(optH+1)
                tw(frame,{Size=UDim2.new(1,0,0,isOpen and openH or closedH)},0.18)
                selLbl.Text=current..(isOpen and " \226\150\178" or " \226\150\190")
            end)
            if dcfg.Flag then Flags[dcfg.Flag]={get=function() return current end, set=function(v) dropdown:Set(tostring(v)) end} end
            return dropdown
        end

        -- ========== INPUT ==========
        function target:CreateInput(icfg)
            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,30), BorderSizePixel=0, LayoutOrder=wNextOrder(), Parent=wContent}); rc(frame,6); st(frame,C.WidgetBorder)
            mk("TextLabel", {Text=icfg.Name or "Input", TextColor3=C.Text, Font=F.Med, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(0.4,0,1,0), Position=UDim2.fromOffset(8,0), Parent=frame})
            local box = mk("TextBox", {Text="", PlaceholderText=icfg.PlaceholderText or "...", PlaceholderColor3=C.Dim, TextColor3=C.Text, Font=F.Reg, TextSize=11, BackgroundColor3=C.Bg, Size=UDim2.new(0.55,-8,0,22), Position=UDim2.new(0.45,0,0.5,-11), BorderSizePixel=0, ClearTextOnFocus=false, Parent=frame}); rc(box,4); pad(box,0,5,0,5)
            if icfg.Callback then box.FocusLost:Connect(function() pcall(icfg.Callback, box.Text); if icfg.RemoveTextAfterFocusLost then box.Text="" end end) end
        end

        -- ========== KEYBIND ==========
        function target:CreateKeybind(kcfg)
            local currentKey = kcfg.CurrentKeybind or "F"
            local listening = false
            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,30), BorderSizePixel=0, LayoutOrder=wNextOrder(), Parent=wContent}); rc(frame,6); st(frame,C.WidgetBorder)
            mk("TextLabel", {Text=kcfg.Name or "Keybind", TextColor3=C.Text, Font=F.Med, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-52,1,0), Position=UDim2.fromOffset(8,0), Parent=frame})
            local keyBtn = mk("TextButton", {Text="["..currentKey.."]", TextColor3=C.AccentH, Font=F.Semi, TextSize=11, BackgroundColor3=C.Bg, Size=UDim2.fromOffset(40,22), Position=UDim2.new(1,-46,0.5,-11), BorderSizePixel=0, AutoButtonColor=false, Parent=frame}); rc(keyBtn,4)
            keyBtn.MouseButton1Click:Connect(function()
                if listening then return end; listening=true; keyBtn.Text="[...]"; tw(keyBtn,{BackgroundColor3=C.AccentDk},0.1)
            end)
            UIS.InputBegan:Connect(function(input,gp)
                if listening then
                    if input.UserInputType==Enum.UserInputType.Keyboard then currentKey=input.KeyCode.Name; keyBtn.Text="["..currentKey.."]"; listening=false; tw(keyBtn,{BackgroundColor3=C.Bg},0.1); DebouncedSave() end
                    return
                end
                if not gp and input.KeyCode~=Enum.KeyCode.Unknown and input.KeyCode.Name==currentKey then if kcfg.Callback then pcall(kcfg.Callback) end end
            end)
            frame.MouseEnter:Connect(function() tw(frame,{BackgroundColor3=C.Hover},0.08) end)
            frame.MouseLeave:Connect(function() tw(frame,{BackgroundColor3=C.Surface},0.08) end)
            if kcfg.Flag then Flags[kcfg.Flag]={get=function() return currentKey end, set=function(v) if type(v)=="string" and #v>0 then currentKey=v; keyBtn.Text="["..v.."]" end end} end
        end

        -- ========== LABEL ==========
        function target:CreateLabel(text)
            local label = {}
            local lbl = mk("TextLabel", {Text=text or "", TextColor3=C.Dim, Font=F.Reg, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, BackgroundTransparency=1, Size=UDim2.new(1,-8,0,18), LayoutOrder=wNextOrder(), Parent=wContent}); pad(lbl,0,0,0,8)
            function label:Set(t) lbl.Text=t end; return label
        end

        -- ========== PARAGRAPH ==========
        function target:CreateParagraph(pcfg2)
            pcfg2 = pcfg2 or {}; local para = {}
            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,52), BorderSizePixel=0, LayoutOrder=wNextOrder(), Parent=wContent}); rc(frame,6); st(frame,C.WidgetBorder)
            mk("Frame", {BackgroundColor3=C.Accent, Size=UDim2.new(0,3,1,-8), Position=UDim2.fromOffset(4,4), BorderSizePixel=0, Parent=frame})
            local tLbl = mk("TextLabel", {Text=pcfg2.Title or "", TextColor3=C.Text, Font=F.Bold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-18,0,16), Position=UDim2.fromOffset(14,5), Parent=frame})
            local cLbl = mk("TextLabel", {Text=pcfg2.Content or "", TextColor3=C.Dim, Font=F.Reg, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, TextYAlignment=Enum.TextYAlignment.Top, BackgroundTransparency=1, Size=UDim2.new(1,-18,0,26), Position=UDim2.fromOffset(14,22), Parent=frame})
            local function resize()
                local ts=game:GetService("TextService")
                local b=ts:GetTextSize(cLbl.Text,10,F.Reg,Vector2.new(math.max(frame.AbsoluteSize.X-18,80),1000))
                local h=math.max(52,26+b.Y+8); frame.Size=UDim2.new(1,0,0,h); cLbl.Size=UDim2.new(1,-18,0,b.Y+2)
            end; task.defer(resize)
            function para:Set(c2) if c2.Title then tLbl.Text=c2.Title end; if c2.Content then cLbl.Text=c2.Content; task.defer(resize) end end; return para
        end

        -- ========== COLOR PICKER ==========
        function target:CreateColorPicker(ccfg)
            ccfg = ccfg or {}
            local value = ccfg.Default or Color3.fromRGB(130,87,230)
            local picker = {Value=value}; local pickerOpen=false; local closedH,openH=30,118

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,closedH), BorderSizePixel=0, ClipsDescendants=true, LayoutOrder=wNextOrder(), Parent=wContent}); rc(frame,6); st(frame,C.WidgetBorder)
            mk("TextLabel", {Text=ccfg.Name or "Color", TextColor3=C.Text, Font=F.Med, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-44,0,closedH), Position=UDim2.fromOffset(8,0), Parent=frame})
            local preview = mk("Frame", {BackgroundColor3=value, Size=UDim2.fromOffset(22,16), Position=UDim2.new(1,-30,0,7), BorderSizePixel=0, Parent=frame}); rc(preview,4); st(preview,C.Border)
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
                mk("TextLabel", {Text=chName, TextColor3=C.Dim, Font=F.Semi, TextSize=10, BackgroundTransparency=1, Size=UDim2.fromOffset(14,18), Position=UDim2.fromOffset(8,yOff+1), Parent=frame})
                local chTrack = mk("Frame", {BackgroundColor3=C.SliderBg, Size=UDim2.new(1,-52,0,5), Position=UDim2.new(0,26,0,yOff+7), BorderSizePixel=0, Parent=frame}); rc(chTrack,3)
                local chFill = mk("Frame", {BackgroundColor3=C.Accent, Size=UDim2.new(getV(),0,1,0), BorderSizePixel=0, Parent=chTrack}); rc(chFill,3)
                local chVal = mk("TextLabel", {Text=tostring(math.floor(getV()*255)), TextColor3=C.AccentH, Font=F.Semi, TextSize=9, BackgroundTransparency=1, Size=UDim2.fromOffset(22,18), Position=UDim2.new(1,-24,0,yOff), TextXAlignment=Enum.TextXAlignment.Right, Parent=frame})
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

        -- ========== DUAL PANE (two-column layout) ==========
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

    -- ==================== CREATE TAB ====================
    function Window:CreateTab(tabArg)
        local tabName, tabIcon
        if type(tabArg)=="table" then tabName=tabArg.Name or "Tab"; tabIcon=tabArg.Icon
        else tabName=tostring(tabArg or "Tab"); tabIcon=nil end

        local Tab = {}
        local isFirst = #tabs==0
        local tabIndex = #tabs
        local tx, ty = getTabPos(tabIndex)

        -- Tab button in sidebar (zig-zag hex style)
        local tabBtn = mk("Frame", {BackgroundColor3=isFirst and C.TabActive or C.TabBg, Size=UDim2.fromOffset(TAB_SIZE,TAB_SIZE), Position=UDim2.fromOffset(tx,ty), BorderSizePixel=0, Parent=sidebar})
        rc(tabBtn, 8)
        local tabStroke = st(tabBtn, C.Accent, 1.2); tabStroke.Transparency = isFirst and 0.3 or 1

        local iconImg, iconTxt
        if tabIcon and tabIcon ~= "" then
            iconImg = mk("ImageLabel", {Image=tabIcon, ImageColor3=isFirst and C.Text or C.Dim, BackgroundTransparency=1, Size=UDim2.fromOffset(18,18), Position=UDim2.new(0.5,-9,0.5,-9), ScaleType=Enum.ScaleType.Fit, Parent=tabBtn})
        else
            iconTxt = mk("TextLabel", {Text="\226\154\153", TextColor3=isFirst and C.Text or C.Dim, Font=F.Bold, TextSize=16, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=tabBtn})
        end

        local clickBtn = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=2, AutoButtonColor=false, Parent=tabBtn})

        -- Content scroll
        local content = mk("ScrollingFrame", {Name=tabName, BackgroundTransparency=1, Size=UDim2.new(1,-12,1,-6), Position=UDim2.fromOffset(6,3), ScrollBarThickness=3, ScrollBarImageColor3=C.AccentDk, CanvasSize=UDim2.new(0,0,0,0), BorderSizePixel=0, Visible=isFirst, Parent=contentArea})
        local cLayout = mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,3), Parent=content})
        cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() content.CanvasSize=UDim2.new(0,0,0,cLayout.AbsoluteContentSize.Y+10) end)

        local tabData = {name=tabName, btn=tabBtn, stroke=tabStroke, content=content, iconImg=iconImg, iconTxt=iconTxt}
        table.insert(tabs, tabData)
        if isFirst then activeTab=tabName end

        clickBtn.MouseButton1Click:Connect(function() selectTab(tabName) end)
        clickBtn.MouseEnter:Connect(function() if activeTab~=tabName then tw(tabBtn,{BackgroundColor3=C.Hover},0.1) end end)
        clickBtn.MouseLeave:Connect(function() if activeTab~=tabName then tw(tabBtn,{BackgroundColor3=C.TabBg},0.1) end end)

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

                subTabBar = mk("Frame", {BackgroundColor3=C.Header, BackgroundTransparency=0.15, Size=UDim2.new(1,0,0,32), BorderSizePixel=0, Parent=subContainer}); rc(subTabBar,6)
                mk("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,1), Parent=subTabBar})
            end

            local subBtn = mk("TextButton", {Text=subTabName, TextColor3=isFirstSub and C.Text or C.Dim, Font=F.Semi, TextSize=12, BackgroundTransparency=1, Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X, AutoButtonColor=false, LayoutOrder=#subTabs, Parent=subTabBar})
            pad(subBtn, 0,14,0,14)

            -- Purple glow indicator
            local glowLine = mk("Frame", {BackgroundColor3=C.Accent, BackgroundTransparency=isFirstSub and 0.2 or 1, Size=UDim2.new(1,4,0,2), Position=UDim2.new(0,-2,1,-2), BorderSizePixel=0, Parent=subBtn}); rc(glowLine,1)
            local glowOuter = mk("Frame", {BackgroundColor3=C.Accent, BackgroundTransparency=isFirstSub and 0.75 or 1, Size=UDim2.new(1,12,0,6), Position=UDim2.new(0,-6,1,-4), BorderSizePixel=0, ZIndex=0, Parent=subBtn}); rc(glowOuter,3)

            local subContent = mk("ScrollingFrame", {Name=subTabName, BackgroundTransparency=1, Size=UDim2.new(1,0,1,-37), Position=UDim2.fromOffset(0,35), ScrollBarThickness=3, ScrollBarImageColor3=C.AccentDk, CanvasSize=UDim2.new(0,0,0,0), BorderSizePixel=0, Visible=isFirstSub, Parent=tabData.content})
            local subLayout = mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,3), Parent=subContent})
            subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() subContent.CanvasSize=UDim2.new(0,0,0,subLayout.AbsoluteContentSize.Y+10) end)

            table.insert(subTabs, {name=subTabName, button=subBtn, content=subContent, glow=glowLine, glowOuter=glowOuter})
            if isFirstSub then activeSubTab=subTabName end

            local function selectSubTab(stName)
                for _, s in ipairs(subTabs) do
                    if s.name==stName then
                        s.content.Visible=true; s.content.Position=UDim2.fromOffset(14,35)
                        tw(s.content, {Position=UDim2.fromOffset(0,35)}, 0.2)
                        s.button.TextColor3=C.Text
                        tw(s.glow, {BackgroundTransparency=0.2}, 0.15)
                        tw(s.glowOuter, {BackgroundTransparency=0.75}, 0.15)
                        activeSubTab=stName
                    else
                        s.content.Visible=false; s.button.TextColor3=C.Dim
                        tw(s.glow, {BackgroundTransparency=1}, 0.15)
                        tw(s.glowOuter, {BackgroundTransparency=1}, 0.15)
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
        local SettingsTab = Window:CreateTab({Name="Settings", Icon=cfg.SettingsIcon or ""})
        SettingsTab:CreateSection("Configuration")
        local profileList=ListConfigs(); if #profileList==0 then profileList={cfgDefaultName} end
        local currentProfile=cfgDefaultName
        SettingsTab:CreateDropdown({Name="Config Profile", Options=profileList, CurrentOption=cfgDefaultName, Callback=function(v) currentProfile=type(v)=="table" and v[1] or v end})
        SettingsTab:CreateButton({Name="Load Config", Callback=function() LoadConfig(currentProfile); Library:Notify({Title="Config",Content="Loaded: "..currentProfile,Duration=2,Type="success"}) end})
        SettingsTab:CreateButton({Name="Save Config", Callback=function() SaveConfig(currentProfile); Library:Notify({Title="Config",Content="Saved: "..currentProfile,Duration=2,Type="success"}) end})
        SettingsTab:CreateButton({Name="Delete Config", Callback=function() Window:Dialog({Title="Delete Profile",Content="Delete '"..currentProfile.."'?",Buttons={{Name="Delete",Callback=function() DeleteConfig(currentProfile); Library:Notify({Title="Config",Content="Deleted: "..currentProfile,Duration=2,Type="warning"}) end},{Name="Cancel",Callback=function() end}}}) end})
        SettingsTab:CreateInput({Name="New Profile", PlaceholderText="Profile name...", RemoveTextAfterFocusLost=true, Callback=function(text) if text and #text>0 then text=text:gsub("[^%w%-%_ ]",""); if #text>0 then SaveConfig(text); Library:Notify({Title="Config",Content="Created: "..text,Duration=2,Type="success"}) end end end})
        SettingsTab:CreateSection("Settings")
        SettingsTab:CreateToggle({Name="Auto-Save", Description="Save config on change", CurrentValue=true, Callback=function(v) cfgAutoSave=v end})
        SettingsTab:CreateParagraph({Title="Jitler Hub", Content=name.."\nRightControl to toggle UI.\nConfig: "..cfgFolder})
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
            main.Visible=true; main.BackgroundTransparency=1; mainSt.Transparency=1
            tw(main,{BackgroundTransparency=0},0.2); tw(mainSt,{Transparency=0.3},0.2)
        end)
    end

    if cfgEnabled then task.delay(0.8, function() LoadConfig() end) end
    return Window
end

return Library
