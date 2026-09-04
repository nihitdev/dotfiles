dofile(os.getenv("HOME") .. "/.config/hypr/bind.lua")









hl.monitor({
    output   = "LVDS-1",
    mode     = "1366x768",
    position = "0x0",
    scale    = 1,
})














hl.env("XCURSOR_SIZE", 2)

hl.env("XDG_SESSION_TYPE", "wayland")

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")

hl.env("XDG_SESSION_DESKTOP", "Hyprland")


hl.config({
    input = {
        kb_layout = "us",
        numlock_by_default = true,
        follow_mouse = 1,
        touchpad = {
            disable_while_typing = true,
            natural_scroll = true,
            disable_while_typing = true,
        },
        sensitivity = 0,
    },
})

hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        layout = "dwindle",
        col = {
            active_border = "0xffcba6f7",
            inactive_border = "0xff313244",
        },
    },
})

hl.config({
    decoration = {
        rounding = 5,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        blur = {
            enabled = true,
            size = 10,
            passes = 1,
            new_optimizations = true,
        },
        shadow = {
            enabled = true,
            range = 4,
            offset = "2 2",
            render_power = 2,
            color = "0x66000000",
        },
    },
})

hl.config({
    animations = {
        enabled = true,
    },
})
hl.curve("myBezier", {
    type = "bezier",
    points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
})
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
        new_on_top = true,
    },
})

hl.config({
    gestures = {
    },
})












hl.config({
    general = {
        col = {
            active_border = "rgb(268bd2)",
            inactive_border = "rgb(1a1a1a)",
        },
    },
})


















































hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("dunst -conf ~/.config/dunst/dunstrc")
    hl.exec_cmd("easyeffects --gapplication-service")
    hl.exec_cmd("hypridle")
end)
-- Kairo Hyprland profile
-- Keep this file focused on active settings; machine-specific overrides belong in user.lua.
