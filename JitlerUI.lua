-- JitlerUI.lua — Custom UI Library for Jitler Hub
-- Dark theme with purple accents, modern design

local Library = {}
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

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
    TogOff   = Color3.fromRGB(44, 42, 62),
    Border   = Color3.fromRGB(38, 36, 58),
    SliderBg = Color3.fromRGB(32, 30, 48),
    Green    = Color3.fromRGB(80, 200, 120),
    Red      = Color3.fromRGB(220, 70, 70),
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

-- Module-level references (set by CreateWindow)
local _notifContainer = nil

-- ==================== NOTIFICATIONS ====================
function Library:Notify(cfg)
    if not _notifContainer then return end
    cfg = cfg or {}
    local title = cfg.Title or "Notification"
    local content = tostring(cfg.Content or "")
    local dur = cfg.Duration or 3

    local nf = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,56), BorderSizePixel=0, Parent=_notifContainer})
    rc(nf, 6)
    local nfSt = st(nf, C.AccentDk)
    local bar = mk("Frame", {BackgroundColor3=C.Accent, Size=UDim2.new(0,3,1,-10), Position=UDim2.fromOffset(5,5), BorderSizePixel=0, Parent=nf})
    rc(bar, 2)
    local tLbl = mk("TextLabel", {Text=title, TextColor3=C.Accent, Font=F.Bold, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-22,0,18), Position=UDim2.fromOffset(16,5), Parent=nf})
    local cLbl = mk("TextLabel", {Text=content, TextColor3=C.Text, Font=F.Reg, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, BackgroundTransparency=1, Size=UDim2.new(1,-22,0,26), Position=UDim2.fromOffset(16,24), Parent=nf})

    task.delay(dur, function()
        if not nf or not nf.Parent then return end
        tw(nf, {BackgroundTransparency=1}, 0.3)
        tw(tLbl, {TextTransparency=1}, 0.3)
        tw(cLbl, {TextTransparency=1}, 0.3)
        tw(bar, {BackgroundTransparency=1}, 0.3)
        tw(nfSt, {Transparency=1}, 0.3)
        task.wait(0.35)
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

    -- Main frame
    local main = mk("Frame", {Name="Main", BackgroundColor3=C.Bg, Size=UDim2.fromOffset(580,400), Position=UDim2.new(0.5,-290,0.5,-200), BorderSizePixel=0, ClipsDescendants=true, Parent=sg})
    rc(main, 10)
    local mainSt = st(main, C.AccentDk); mainSt.Transparency = 0.4

    -- Header
    local icon = cfg.Icon or nil
    local header = mk("Frame", {Name="Header", BackgroundColor3=C.Header, Size=UDim2.new(1,0,0,40), BorderSizePixel=0, Parent=main})

    if icon and icon ~= "" then
        -- Logo + title layout
        local logoImg = mk("ImageLabel", {
            Image = icon,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(28, 28),
            Position = UDim2.new(0, 8, 0.5, -14),
            ScaleType = Enum.ScaleType.Fit,
            Parent = header,
        })
        mk("TextLabel", {
            Text = name,
            TextColor3 = C.Text, Font = F.Bold, TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -100, 1, 0),
            Position = UDim2.fromOffset(42, 0),
            Parent = header,
        })
    else
        mk("TextLabel", {Text="  ⬡ "..name, TextColor3=C.Text, Font=F.Bold, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, Size=UDim2.new(1,-90,1,0), Position=UDim2.fromOffset(6,0), Parent=header})
    end

    mk("Frame", {BackgroundColor3=C.Border, Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BorderSizePixel=0, Parent=header})

    local closeBtn = mk("TextButton", {Text="✕", TextColor3=C.Dim, Font=F.Bold, TextSize=15, BackgroundTransparency=1, Size=UDim2.fromOffset(30,30), Position=UDim2.new(1,-36,0,5), AutoButtonColor=false, Parent=header})
    local minBtn = mk("TextButton", {Text="─", TextColor3=C.Dim, Font=F.Bold, TextSize=15, BackgroundTransparency=1, Size=UDim2.fromOffset(30,30), Position=UDim2.new(1,-64,0,5), AutoButtonColor=false, Parent=header})

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

    -- Notification container (outside main frame, top-right)
    local notifC = mk("Frame", {Name="Notifs", BackgroundTransparency=1, Size=UDim2.new(0,300,1,0), Position=UDim2.new(1,-310,0,10), Parent=sg})
    mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6), VerticalAlignment=Enum.VerticalAlignment.Top, Parent=notifC})
    _notifContainer = notifC

    -- Window state
    local Window = {}
    local tabs = {}
    local activeTab = nil
    local minimized = false

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
                t.button.TextColor3 = C.Text
                activeTab = tabName
            else
                t.content.Visible = false
                tw(t.button, {BackgroundColor3 = C.Sidebar, BackgroundTransparency = 1}, 0.15)
                tw(t.indicator, {BackgroundTransparency = 1}, 0.15)
                t.button.TextColor3 = C.Dim
            end
        end
    end

    -- ==================== CREATE TAB ====================
    function Window:CreateTab(tabName)
        local Tab = {}
        local order = 0
        local isFirst = #tabs == 0

        -- Tab button
        local btn = mk("TextButton", {
            Text = "   " .. tabName,
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

        local tabData = {name=tabName, button=btn, content=content, indicator=indicator}
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
                Text="── "..sectionName.." ──", TextColor3=C.Dim, Font=F.Semi, TextSize=12,
                BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=sec,
            })
        end

        -- ==================== TOGGLE ====================
        function Tab:CreateToggle(cfg)
            local value = cfg.CurrentValue or false
            local toggle = {Value = value}

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,34), BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=content})
            rc(frame, 6)
            mk("TextLabel", {
                Text=cfg.Name or "Toggle", TextColor3=C.Text, Font=F.Reg, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1,
                Size=UDim2.new(1,-60,1,0), Position=UDim2.fromOffset(10,0), Parent=frame,
            })

            local swBg = mk("Frame", {
                BackgroundColor3 = value and C.Accent or C.TogOff,
                Size=UDim2.fromOffset(38,20), Position=UDim2.new(1,-48,0.5,-10),
                BorderSizePixel=0, Parent=frame,
            })
            rc(swBg, 10)
            local circle = mk("Frame", {
                BackgroundColor3=C.Text, Size=UDim2.fromOffset(16,16),
                Position = value and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2),
                BorderSizePixel=0, Parent=swBg,
            })
            rc(circle, 8)

            local function updateVis(v)
                tw(swBg, {BackgroundColor3 = v and C.Accent or C.TogOff}, 0.15)
                tw(circle, {Position = v and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2)}, 0.15)
            end

            function toggle:Set(v)
                if v == value then return end
                value = v; toggle.Value = v; updateVis(v)
                if cfg.Callback then pcall(cfg.Callback, v) end
            end

            local overlay = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=2, AutoButtonColor=false, Parent=frame})
            overlay.MouseButton1Click:Connect(function()
                value = not value; toggle.Value = value; updateVis(value)
                if cfg.Callback then pcall(cfg.Callback, value) end
            end)
            overlay.MouseEnter:Connect(function() tw(frame, {BackgroundColor3=C.Hover}, 0.1) end)
            overlay.MouseLeave:Connect(function() tw(frame, {BackgroundColor3=C.Surface}, 0.1) end)

            return toggle
        end

        -- ==================== SLIDER ====================
        function Tab:CreateSlider(cfg)
            local range = cfg.Range or {0, 100}
            local mn, mx = range[1], range[2]
            local inc = cfg.Increment or 1
            local suffix = cfg.Suffix or ""
            local value = math.clamp(cfg.CurrentValue or mn, mn, mx)
            local slider = {Value = value}

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,50), BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=content})
            rc(frame, 6)

            mk("TextLabel", {
                Text=cfg.Name or "Slider", TextColor3=C.Text, Font=F.Reg, TextSize=13,
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
            local fill = mk("Frame", {BackgroundColor3=C.Accent, Size=UDim2.new(pct,0,1,0), BorderSizePixel=0, Parent=track})
            rc(fill, 3)

            local function updateSlider(v)
                v = math.clamp(v, mn, mx)
                v = math.floor(v / inc + 0.5) * inc
                v = math.clamp(v, mn, mx)
                if inc >= 1 then v = math.floor(v + 0.5) end
                value = v; slider.Value = v
                fill.Size = UDim2.new((v - mn) / math.max(mx - mn, 0.001), 0, 1, 0)
                valLbl.Text = tostring(v) .. suffix
                if cfg.Callback then pcall(cfg.Callback, v) end
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

            return slider
        end

        -- ==================== BUTTON ====================
        function Tab:CreateButton(cfg)
            local btn = mk("TextButton", {
                Text=cfg.Name or "Button", TextColor3=C.Text, Font=F.Semi, TextSize=13,
                BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,34), BorderSizePixel=0,
                AutoButtonColor=false, LayoutOrder=nextOrder(), Parent=content,
            })
            rc(btn, 6)
            btn.MouseButton1Click:Connect(function()
                tw(btn, {BackgroundColor3=C.Accent}, 0.08)
                task.delay(0.12, function() tw(btn, {BackgroundColor3=C.Surface}, 0.15) end)
                if cfg.Callback then pcall(cfg.Callback) end
            end)
            btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3=C.Hover}, 0.1) end)
            btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3=C.Surface}, 0.1) end)
        end

        -- ==================== DROPDOWN ====================
        function Tab:CreateDropdown(cfg)
            local options = cfg.Options or {}
            local current = cfg.CurrentOption or (options[1] or "")
            local dropdown = {Value = current}
            local isOpen = false
            local closedH, optH = 34, 28

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,closedH), BorderSizePixel=0, ClipsDescendants=true, LayoutOrder=nextOrder(), Parent=content})
            rc(frame, 6)

            mk("TextLabel", {
                Text=cfg.Name or "Dropdown", TextColor3=C.Text, Font=F.Reg, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1,
                Size=UDim2.new(0.5,0,0,closedH), Position=UDim2.fromOffset(10,0), Parent=frame,
            })
            local selLbl = mk("TextLabel", {
                Text=current.." ▼", TextColor3=C.AccentH, Font=F.Semi, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Right, BackgroundTransparency=1,
                Size=UDim2.new(0.5,-14,0,closedH), Position=UDim2.new(0.5,0,0,0), Parent=frame,
            })

            local toggleBtn = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,0,closedH), ZIndex=2, AutoButtonColor=false, Parent=frame})

            local optContainer = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-8,0,#options*optH), Position=UDim2.new(0,4,0,closedH+2), Parent=frame})
            mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,1), Parent=optContainer})

            local function setCurrent(val)
                current = val; dropdown.Value = val; selLbl.Text = val .. " ▼"
                if cfg.Callback then pcall(cfg.Callback, val) end
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

            toggleBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local openH = closedH + 6 + #options * (optH + 1)
                tw(frame, {Size=UDim2.new(1,0,0,isOpen and openH or closedH)}, 0.2)
                selLbl.Text = current .. (isOpen and " ▲" or " ▼")
            end)

            return dropdown
        end

        -- ==================== INPUT ====================
        function Tab:CreateInput(cfg)
            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,34), BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=content})
            rc(frame, 6)
            mk("TextLabel", {
                Text=cfg.Name or "Input", TextColor3=C.Text, Font=F.Reg, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1,
                Size=UDim2.new(0.4,0,1,0), Position=UDim2.fromOffset(10,0), Parent=frame,
            })
            local box = mk("TextBox", {
                Text="", PlaceholderText=cfg.PlaceholderText or "...", PlaceholderColor3=C.Dim,
                TextColor3=C.Text, Font=F.Reg, TextSize=12, BackgroundColor3=C.Bg,
                Size=UDim2.new(0.55,-10,0,24), Position=UDim2.new(0.45,0,0.5,-12),
                BorderSizePixel=0, ClearTextOnFocus=false, Parent=frame,
            })
            rc(box, 4); pad(box, 0, 6, 0, 6)

            if cfg.Callback then
                box.FocusLost:Connect(function()
                    pcall(cfg.Callback, box.Text)
                    if cfg.RemoveTextAfterFocusLost then box.Text = "" end
                end)
            end
        end

        -- ==================== KEYBIND ====================
        function Tab:CreateKeybind(cfg)
            local currentKey = cfg.CurrentKeybind or "F"
            local listening = false

            local frame = mk("Frame", {BackgroundColor3=C.Surface, Size=UDim2.new(1,0,0,34), BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=content})
            rc(frame, 6)
            mk("TextLabel", {
                Text=cfg.Name or "Keybind", TextColor3=C.Text, Font=F.Reg, TextSize=13,
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
                    end
                    return
                end
                if not gp and input.KeyCode ~= Enum.KeyCode.Unknown then
                    if input.KeyCode.Name == currentKey then
                        if cfg.Callback then pcall(cfg.Callback) end
                    end
                end
            end)

            frame.MouseEnter:Connect(function() tw(frame, {BackgroundColor3=C.Hover}, 0.1) end)
            frame.MouseLeave:Connect(function() tw(frame, {BackgroundColor3=C.Surface}, 0.1) end)
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

        return Tab
    end

    return Window
end

return Library
