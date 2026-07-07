local wezterm = require("wezterm")

return {
  default_prog = { "pwsh.exe" },

  font = wezterm.font("JetBrainsMono Nerd Font"),
  font_size = 13,

  color_scheme = "Tokyo Night Storm",

  enable_tab_bar = false,

  window_background_opacity = 0.75,
  win32_system_backdrop = "Mica",

  window_decorations = "TITLE|RESIZE",

  window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
  },

  initial_cols = 120,
  initial_rows = 35,

  audible_bell = "Disabled",
  window_close_confirmation = "NeverPrompt",
}