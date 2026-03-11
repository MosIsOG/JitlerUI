This is a Jitler UI.
JitlerUI features:

Dark purple theme — deep navy/black backgrounds with purple (#8264D2) accents
API-compatible with Rayfield — same CreateWindow, CreateTab, CreateToggle, CreateSlider, CreateButton, CreateDropdown, CreateInput, CreateKeybind, CreateLabel, and Notify methods, so the main script needed zero callback changes
Modern design — rounded corners, smooth tween animations on hover/click, sliding toggle switches with pill design, active tab indicator bars
Sidebar tabs with accent bar indicator on the active tab
Draggable window via header
Minimize (shrinks to header) and Close (hides, press RightControl to toggle)
Toast notifications at top-right with accent sidebar, auto-dismiss with fade-out
Exploit-safe — uses syn.protect_gui/gethui() for GUI protection, cleans up previous instances on re-execute
