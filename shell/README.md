# Kairo Shell

Kairo Shell is the Quickshell layer for the Kairo desktop. It currently provides
the first working surface: a lightweight top bar with Kairo branding,
workspace indicators, and a clock.

Run it from a checkout with:

```sh
quickshell -p shell/shell.qml
```

The shell is intentionally separate from the dotfile installer. Future pieces
will add a launcher, control center, notifications, wallpaper controls, and
rice-aware theme loading without replacing users' existing configurations.
