# Ryoku palette for fish and fzf. Rendered by the theme daemon; do not edit.
#
# Dropped straight into conf.d, which fish sources on its own, so nothing in the
# shipped config has to include it. Your ~/.config/fish/user.fish loads last and
# still wins.

# Syntax highlighting.
set -g fish_color_normal E0DEF4
set -g fish_color_command C4A7E7
set -g fish_color_keyword EBBCBA
set -g fish_color_quote 9CCFD8
set -g fish_color_redirection 908CAA
set -g fish_color_end EBBCBA
set -g fish_color_error EB6F92
set -g fish_color_param E0DEF4
set -g fish_color_comment 908CAA
set -g fish_color_selection --background=26233A
set -g fish_color_operator EBBCBA
set -g fish_color_escape 9CCFD8
set -g fish_color_autosuggestion 908CAA
set -g fish_color_cancel EB6F92
set -g fish_color_search_match --background=26233A
set -g fish_color_valid_path --underline

# Completion pager.
set -g fish_pager_color_progress 908CAA
set -g fish_pager_color_prefix C4A7E7
set -g fish_pager_color_completion E0DEF4
set -g fish_pager_color_description 908CAA
set -g fish_pager_color_selected_background --background=26233A

# fzf takes the same palette, so Ctrl-R and Ctrl-T match the terminal they open
# in. Appended to whatever options are already set rather than replacing them.
set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS \
--color=fg:#E0DEF4,bg:-1,hl:#C4A7E7 \
--color=fg+:#E0DEF4,bg+:#26233A,hl+:#C4A7E7 \
--color=info:#9CCFD8,prompt:#C4A7E7,pointer:#EBBCBA \
--color=marker:#EBBCBA,spinner:#9CCFD8,header:#908CAA \
--color=border:#403D52"
