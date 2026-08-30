# ─────────────────────────────────────────────────────────────────────────────
# Zsh
# ─────────────────────────────────────────────────────────────────────────────

export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export VISUAL="nvim"

# ─────────────────────────────────────────────────────────────────────────────
# THEME
# ─────────────────────────────────────────────────────────────────────────────

ZSH_THEME=""

# ─────────────────────────────────────────────────────────────────────────────
# PLUGINS
# ─────────────────────────────────────────────────────────────────────────────

plugins=(
  git
  sudo
  command-not-found
  colored-man-pages
)

# ─────────────────────────────────────────────────────────────────────────────
# OH MY ZSH
# ─────────────────────────────────────────────────────────────────────────────

[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Arch packages provide these integrations under /usr/share/zsh/plugins.
[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ─────────────────────────────────────────────────────────────────────────────
# STARSHIP
# ─────────────────────────────────────────────────────────────────────────────

if command -v starship >/dev/null 2>&1; then
  export STARSHIP_CONFIG="$HOME/.config/starship/zsh.toml"
  eval "$(starship init zsh)"
fi
