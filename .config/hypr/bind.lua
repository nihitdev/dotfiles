


local mainMod = "SUPER"


hl.bind(mainMod .. " + " .. "RETURN", hl.dsp.exec_cmd("kitty"))

hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd("kitty --class floating"))

hl.bind(mainMod .. " + " .. "Q", hl.dsp.window.close())

hl.bind("ALT + F4", hl.dsp.window.close())

hl.bind(mainMod .. " + " .. "F11", hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + " .. "E", hl.dsp.exec_cmd("nemo"))

hl.bind(mainMod .. " + " .. "F", hl.dsp.exec_cmd("firefox"))

hl.bind(mainMod .. " + SHIFT" .. " + " .. "F", hl.dsp.exec_cmd("firefox --private-window"))

hl.bind(mainMod .. " + " .. "T", hl.dsp.exec_cmd("telegram-desktop"))

hl.bind(mainMod .. " + " .. "C", hl.dsp.exec_cmd("code"))

hl.bind(mainMod .. " + " .. "O", hl.dsp.exec_cmd("obs"))


hl.bind(mainMod .. " + " .. "L", hl.dsp.exec_cmd("hyprlock"))

hl.bind(mainMod .. " + " .. "S", hl.dsp.window.float())

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "R", hl.dsp.exec_cmd("/home/nihitdev/.config/hypr/scripts/reload.sh"))


hl.bind(mainMod .. " + " .. "P", hl.dsp.window.pseudo())


hl.bind("J", hl.dsp.layout("togglesplit"))





hl.bind(mainMod .. " + " .. "SPACE", hl.dsp.exec_cmd("~/.config/rofi/launchers/launcher.sh"))

hl.bind(mainMod .. " + " .. "X", hl.dsp.exec_cmd("~/.config/rofi/powermenu/type-2/powermenu.sh"))


hl.bind(mainMod .. " + " .. "R", hl.dsp.exec_cmd("~/.config/rofi/run/run.sh"))

hl.bind(mainMod .. " + " .. "Z", hl.dsp.exec_cmd("~/.config/rofi/filebrowser/filebrowser.sh"))

hl.bind(mainMod .. " + " .. "V", hl.dsp.exec_cmd("~/.config/rofi/clipboard/clipboard.sh"))

hl.bind(mainMod .. " + SHIFT" .. " + " .. "V", hl.dsp.exec_cmd("~/.config/rofi/snippet/snippet.sh"))

hl.bind(mainMod .. " + SHIFT" .. " + " .. "SPACE", hl.dsp.exec_cmd("~/.config/rofi/emoji/emoji.sh"))

hl.bind(mainMod .. " + " .. "W", hl.dsp.exec_cmd("~/.config/rofi/wifi/wifi.sh"))

hl.bind(mainMod .. " + SHIFT" .. " + " .. "W", hl.dsp.exec_cmd("~/.config/rofi/wifi/wifinew.sh"))



hl.bind("SHIFT + Print", hl.dsp.exec_cmd("FILE=~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png; grim -g \"$(slurp)\" - | tee >(wl-copy) | { cat > $FILE && [ -s $FILE ] && dunstify -i $FILE Screenshot of the region taken -t 1000 || rm -f $FILE ; }"))

hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy && wl-paste > ~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png | dunstify -i ~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png \"Screenshot of whole screen taken\" -t 1000"))



hl.bind(mainMod .. " + SHIFT + ALT + P", hl.dsp.exec_cmd("shutdown -h now"))

hl.bind(mainMod .. " + SHIFT + ALT + R", hl.dsp.exec_cmd("reboot"))

hl.bind(mainMod .. " + SHIFT + ALT + L", hl.dsp.exit())

hl.bind(mainMod .. " + SHIFT + ALT + S", hl.dsp.exec_cmd("sleep 1 && hyprctl dispatch dpms off"))


hl.bind(mainMod .. " + SHIFT" .. " + " .. "S", hl.dsp.exec_cmd("sleep 1 && hyprctl dispatch dpms on"))



hl.bind(mainMod .. " + " .. "left", hl.dsp.focus({ direction = "left" }))

hl.bind(mainMod .. " + " .. "right", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + " .. "up", hl.dsp.focus({ direction = "up" }))

hl.bind(mainMod .. " + " .. "down", hl.dsp.focus({ direction = "down" }))

hl.bind("ALT + Tab", hl.dsp.window.cycle_next())



hl.bind(mainMod .. " + " .. 1, hl.dsp.focus({ workspace = 1 }))

hl.bind(mainMod .. " + " .. 2, hl.dsp.focus({ workspace = 2 }))

hl.bind(mainMod .. " + " .. 3, hl.dsp.focus({ workspace = 3 }))

hl.bind(mainMod .. " + " .. 4, hl.dsp.focus({ workspace = 4 }))

hl.bind(mainMod .. " + " .. 5, hl.dsp.focus({ workspace = 5 }))

hl.bind(mainMod .. " + " .. 6, hl.dsp.focus({ workspace = 6 }))

hl.bind(mainMod .. " + " .. 7, hl.dsp.focus({ workspace = 7 }))

hl.bind(mainMod .. " + " .. 8, hl.dsp.focus({ workspace = 8 }))

hl.bind(mainMod .. " + " .. 9, hl.dsp.focus({ workspace = 9 }))


hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 1, hl.dsp.window.move({ workspace = 1 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 2, hl.dsp.window.move({ workspace = 2 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 3, hl.dsp.window.move({ workspace = 3 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 4, hl.dsp.window.move({ workspace = 4 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 5, hl.dsp.window.move({ workspace = 5 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 6, hl.dsp.window.move({ workspace = 6 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 7, hl.dsp.window.move({ workspace = 7 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 8, hl.dsp.window.move({ workspace = 8 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 9, hl.dsp.window.move({ workspace = 9 }))


hl.bind(mainMod .. " + " .. "mouse_down", hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mainMod .. " + " .. "mouse_up", hl.dsp.focus({ workspace = "e-1" }))


hl.bind(mainMod .. " + " .. "mouse:272", hl.dsp.window.drag(), { mouse = true })

hl.bind(mainMod .. " + " .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }))


hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brillo -q -U 5 && dunstify -h int:value:\"$(( ($(cat /sys/class/backlight/*/brightness) * 100) / $(cat /sys/class/backlight/*/max_brightness) ))\" -i ~/.config/dunst/assets/brightness.svg -t 500 -r 2593 \"Brightness: $(( ($(cat /sys/class/backlight/*/brightness) * 100) / $(cat /sys/class/backlight/*/max_brightness) ))%\""))

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brillo -q -A 5 && dunstify -h int:value:\"$(( ($(cat /sys/class/backlight/*/brightness) * 100) / $(cat /sys/class/backlight/*/max_brightness) ))\" -i ~/.config/dunst/assets/brightness.svg -t 500 -r 2593 \"Brightness: $(( ($(cat /sys/class/backlight/*/brightness) * 100) / $(cat /sys/class/backlight/*/max_brightness) ))%\""))


hl.bind("xf86audioraisevolume", hl.dsp.exec_cmd("pamixer -i 5 && dunstify -h int:value:\"$(pamixer --get-volume)\" -i ~/.config/dunst/assets/volume.svg -t 500 -r 2593 \"Volume: $(pamixer --get-volume) %\""))

hl.bind("xf86audiolowervolume", hl.dsp.exec_cmd("pamixer -d 5 && dunstify -h int:value:\"$(pamixer --get-volume)\" -i ~/.config/dunst/assets/volume.svg -t 500 -r 2593 \"Volume: $(pamixer --get-volume) %\""))

hl.bind("xf86AudioMute", hl.dsp.exec_cmd("pamixer -t && dunstify -i ~/.config/dunst/assets/$(pamixer --get-mute | grep -q \"true\" && echo \"volume-mute.svg\" || echo \"volume.svg\" ) -t 500 -r 2593 \"Toggle Mute\""))

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))

hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

hl.bind("XF86audiostop", hl.dsp.exec_cmd("playerctl stop"))


hl.bind(mainMod .. " + " .. "H", hl.dsp.window.move({ workspace = "special:hidden" , follow = false}))

hl.bind(mainMod .. " + " .. "grave", hl.dsp.workspace.toggle_special("hidden"))
-- Kairo Hyprland keybindings
-- Bindings are grouped by workflow and intentionally contain no disabled legacy entries.
