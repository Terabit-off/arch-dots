---@diagnostic disable: trailing-space

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    --mode = "highres",
    position = "auto",
    scale    = "auto",
})


local mainMod = "SUPER"
---------------------
---- MY PROGRAMS ----
---------------------



local terminal    = "kitty"
local fileManager = "nemo"
local menu        = "qs ipc call launcher toggle"--"wofi"



-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function () 
  hl.exec_cmd("hyprpaper & qs")
  hl.exec_cmd("firefox")
  hl.exec_cmd("wl-paste --watch cliphist store")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("HYPRCURSOR_SIZE", "20")
hl.env("XCURSOR_SIZE", "20")
hl.env("XCURSOR_THEME", "BreezeX-Black")



hl.env("GDK_SCALE", "1")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },

    general = {
        gaps_in  = 2,
        gaps_out = 0,

        border_size = 1,

        col = {
            active_border   = { colors = {"rgba(858585ff)"}, angle = 45 },
            inactive_border = "rgba(3d3d3dff)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 5,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 0.9,

        shadow = {
            enabled      = false,
            range        = 3,
            render_power = 1,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = true,
            size      = 3,
            passes    = 2,
            vibrancy  = 0.3696,

            ignore_opacity = true,

            popups = true,
            popups_ignorealpha = 0,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("smooth", {type = "bezier",points = {{0.16, 1}, {0.3, 1}}})
hl.curve("smoothOut", {type = "bezier",points = {{0.22, 1}, {0.36, 1}}})
hl.curve("smoothInOut", {type = "bezier",points = {{0.65, 0}, {0.35, 1}}})
hl.curve("quickOut", {type = "bezier",points = {{0.15, 0}, {0.15, 1}}})
hl.curve("soft", {type = "bezier",points = {{0.25, 0.8}, {0.25, 1}}})
hl.curve("linear", {type = "bezier",points = {{0, 0}, {1, 1}}})

hl.animation({leaf = "global",enabled = true,speed = 10,bezier = "default"})
hl.animation({leaf = "border",enabled = true,speed = 5.8,bezier = "smoothOut"})
hl.animation({leaf = "windows",enabled = true,speed = 5.4,bezier = "smoothOut"})
hl.animation({leaf = "windowsIn",enabled = true,speed = 4.2,bezier = "smoothOut",style = "slide"})
hl.animation({leaf = "windowsOut",enabled = true,speed = 5.5,bezier = "smooth",style = "slide"})
hl.animation({leaf = "fade",enabled = true,speed = 6,bezier = "smoothOut"})
hl.animation({leaf = "fadeIn",enabled = true,speed = 5.8,bezier = "smoothOut"})
hl.animation({leaf = "fadeOut",enabled = true,speed = 6.2,bezier = "quickOut"})
hl.animation({leaf = "layers",enabled = true,speed = 5.5,bezier = "smoothOut"})
hl.animation({leaf = "layersIn",enabled = true,speed = 5.2,bezier = "smoothOut",style = "fade"})
hl.animation({leaf = "layersOut",enabled = true,speed = 6,bezier = "quickOut",style = "fade"})
hl.animation({leaf = "fadeLayersIn",enabled = true,speed = 6,bezier = "smoothOut"})
hl.animation({leaf = "fadeLayersOut",enabled = true,speed = 6.5,bezier = "quickOut"})
hl.animation({leaf = "workspaces",enabled = true,speed = 4.2,bezier = "smoothInOut",style = "slide"})
hl.animation({leaf = "workspacesIn",enabled = true,speed = 4.5,bezier = "smoothOut",style = "slide"})
hl.animation({leaf = "workspacesOut",enabled = true,speed = 4.8,bezier = "smooth",style = "slide"})
hl.animation({leaf = "zoomFactor",enabled = true,speed = 7,bezier = "quickOut"})


-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
hl.window_rule({
    name  = "no-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 5,
})

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
        smart_split = false,
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us, ru",
        kb_variant = "",
        kb_model   = "",
        kb_options = "grp:alt_shift_toggle",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -1.0,
})


---------------------
---- KEYBINDINGS ----
---------------------


hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('~/.config/hypr/screenshot.sh'))

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + CTRL + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", function ()
                                hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
                                hl.dispatch(hl.dsp.window.resize({x = 1000, y = 600, exact = true}))
                                hl.dispatch(hl.dsp.window.center())
                            end)
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Swap master window 
-- hl.bind(mainMod .. " + D", hl.dsp.layout("swapwithmaster", "master"))
-- Swap windows
-- hl.bind(mainMod .. " + SHIFT + up", hl.dsp.layout("swapprev"))
-- hl.bind(mainMod .. " + SHIFT + down", hl.dsp.layout("swapnext"))

-- Switch workspaces with mainMod + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Move/resize windows with mainMod + LMB/RMB/swipe and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.gesture({ fingers = 3, direction = "swipe", mods = "SUPER", action = "resize" }) -- super + swipe 3 fingers



-- OVERVIEW CONTROLS

-- hl.bind(mainMod .. " + TAB", function ()
--    Toggle_qs_overview() 
-- end)
-- hl.gesture({ fingers = 3, direction = "up", action = function ()
--     Toggle_qs_overview()
-- end })

-- hl.gesture({ fingers = 3, direction = "down", action = function ()
--     hl.exec_cmd("qs ipc call overview close");
-- end })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
suppressMaximizeRule:set_enabled(false)

hl.layer_rule({
    match = {
        namespace = "^qs-blur$",
    },

    blur = true,
    blur_popups = true,
    ignore_alpha = 0.05,
})


hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- bluetooth UI app
hl.window_rule({
    name = "floatWindowOverskride",
    match = { class = "io.github.kaii_lb.Overskride" },

    float = true,
    size = {800,600}
})

-- swayimg - image view app 
hl.window_rule({
    name = "floatImageView",
    match = { class = "swayimg" },

    float = true,
    size = {1000, 800}
})
hl.window_rule({
    name = "floatKitty",
    match = { class = "kitty" },

    float = true,
    size = {1000, 600}
})


-- TEMP DISABLED 
function Toggle_qs_overview()
    hl.exec_cmd([[
        sh -lc 'qs ipc call overview toggle "$(hyprctl activewindow -j | jq -r ".address")"'
    ]])
end
