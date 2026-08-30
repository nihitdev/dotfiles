# =============================================================================
# Fish Configuration
# ~/.config/fish/config.fish
# =============================================================================


# -----------------------------------------------------------------------------
# PATH
# -----------------------------------------------------------------------------

# User binaries
if test -d $HOME/.local/bin
    fish_add_path $HOME/.local/bin
end

# Bun
set -gx BUN_INSTALL $HOME/.bun
if test -d $BUN_INSTALL/bin
    fish_add_path $BUN_INSTALL/bin
end


# -----------------------------------------------------------------------------
# Development Environment
# -----------------------------------------------------------------------------

# Go installs
set -gx GOBIN $HOME/.local/bin

# Cargo installs
set -gx CARGO_INSTALL_ROOT $HOME/.local


# -----------------------------------------------------------------------------
# Interactive Shell
# -----------------------------------------------------------------------------

if status is-interactive

    # -------------------------------------------------------------------------
    # General
    # -------------------------------------------------------------------------

    # Disable Fish greeting
    set -g fish_greeting

    # Default editor
    set -gx EDITOR nvim
    set -gx VISUAL nvim


    # -------------------------------------------------------------------------
    # Fish Colors
    # -------------------------------------------------------------------------

    set -g fish_color_normal         F1F3E4
    set -g fish_color_command        e2342a
    set -g fish_color_keyword        e83b30
    set -g fish_color_param          F1F3E4
    set -g fish_color_option         CCD0CF
    set -g fish_color_quote          A3C293
    set -g fish_color_redirection    8AA9CC
    set -g fish_color_end            e83b30
    set -g fish_color_error          FF6B6B
    set -g fish_color_comment        949699
    set -g fish_color_operator       93D4E0
    set -g fish_color_escape         93D4E0
    set -g fish_color_autosuggestion 949699


    # -------------------------------------------------------------------------
    # Fastfetch
    # -------------------------------------------------------------------------

    if command -v ryoku-fastfetch >/dev/null 2>&1
        ryoku-fastfetch
    end


    # -------------------------------------------------------------------------
    # Starship Prompt
    # -------------------------------------------------------------------------

    if command -v starship >/dev/null 2>&1
        set -gx STARSHIP_CONFIG "$HOME/.config/starship/fish.toml"
        starship init fish | source
    end


    # -------------------------------------------------------------------------
    # Zoxide
    # -------------------------------------------------------------------------

    # Smart directory jumping
    #
    # z <name>  -> jump to a remembered directory
    # zi        -> interactive directory picker
    #
    # Normal `cd` remains normal Fish cd.

    if command -v zoxide >/dev/null 2>&1
        zoxide init fish | source
    end


    # -------------------------------------------------------------------------
    # Mise
    # -------------------------------------------------------------------------

    # Runtime / development tool version manager

    if command -v mise >/dev/null 2>&1
        mise activate fish | source
    end


    # -------------------------------------------------------------------------
    # FZF
    # -------------------------------------------------------------------------

    # Use fd as the default filesystem walker when available

    if command -v fd >/dev/null 2>&1
        set -gx FZF_DEFAULT_COMMAND \
            'fd --hidden --follow --exclude .git'

        set -gx FZF_CTRL_T_COMMAND \
            $FZF_DEFAULT_COMMAND

        set -gx FZF_ALT_C_COMMAND \
            'fd --type d --hidden --follow --exclude .git'
    end

    # Fish key bindings:
    # Ctrl-R -> history
    # Ctrl-T -> files
    # Alt-C  -> directories

    if command -v fzf >/dev/null 2>&1
        fzf --fish | source
    end


    # -------------------------------------------------------------------------
    # Eza
    # -------------------------------------------------------------------------

    if command -v eza >/dev/null 2>&1
        alias ls  'eza -lh --group-directories-first --icons=auto'
        alias lsa 'ls -a'
        alias lt  'eza --tree --level=2 --long --icons --git'
        alias lta 'lt -a'
    end

end


# -----------------------------------------------------------------------------
# User Overrides
# -----------------------------------------------------------------------------

# Personal overrides belong here so the main config can stay clean.
# ~/.config/fish/user.fish loads last and therefore wins over settings above.

if test -f $__fish_config_dir/user.fish
    source $__fish_config_dir/user.fish
end
