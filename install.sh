#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────────────────────
# Linux Dotfiles Installer
# ─────────────────────────────────────────────────────────────────────────────

set -Eeuo pipefail

if [[ $(uname -s) != Linux ]]; then
    printf 'This installer supports Linux only.\n' >&2
    exit 1
fi

dry_run=false
no_backup=false
declare -a only=()
declare -a installed=()
declare -a skipped=()

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --dry-run          Show what would change without writing files
  --no-backup        Replace existing files without backing them up
  --only NAME        Install only a component; may be repeated
  -h, --help         Show this help

Components:
  zsh nushell git lazygit broot nvim yazi fastfetch oh-my-posh
  starship atuin bat cava ssh
EOF
}

while (($#)); do
    case "$1" in
        --dry-run)
            dry_run=true
            ;;
        --no-backup)
            no_backup=true
            ;;
        --only)
            [[ $# -ge 2 ]] || { printf 'Missing value for --only\n' >&2; exit 2; }
            only+=("$2")
            shift
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

valid_components=' zsh nushell git lazygit broot nvim yazi fastfetch oh-my-posh starship atuin bat cava ssh '
for component in "${only[@]}"; do
    if [[ $valid_components != *" $component "* ]]; then
        printf 'Unsupported component: %s\n' "$component" >&2
        exit 2
    fi
done

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_root=$script_dir
temporary_root=''

cleanup() {
    if [[ -n $temporary_root && -d $temporary_root ]]; then
        rm -rf -- "$temporary_root"
    fi
}
trap cleanup EXIT

# Support: curl -fsSL <raw-install.sh-url> | bash
if [[ ! -f $repo_root/nvim/init.lua ]]; then
    command -v curl >/dev/null 2>&1 || {
        printf 'curl is required for remote installation.\n' >&2
        exit 1
    }
    command -v tar >/dev/null 2>&1 || {
        printf 'tar is required for remote installation.\n' >&2
        exit 1
    }

    temporary_root=$(mktemp -d)
    archive="$temporary_root/dotfiles.tar.gz"
    printf 'Downloading dotfiles...\n'
    curl -fsSL 'https://github.com/nihitdev/dotfiles/archive/refs/heads/main.tar.gz' -o "$archive"
    tar -xzf "$archive" -C "$temporary_root"
    repo_root="$temporary_root/dotfiles-main"
fi

timestamp=$(date '+%Y%m%d-%H%M%S')
backup_root="$HOME/.dotfiles-backup/$timestamp"
config_root=${XDG_CONFIG_HOME:-"$HOME/.config"}

is_selected() {
    local component=$1
    local selected

    ((${#only[@]} == 0)) && return 0
    for selected in "${only[@]}"; do
        [[ $selected == "$component" ]] && return 0
    done
    return 1
}

describe() {
    if $dry_run; then
        printf '[dry-run] %s\n' "$*"
    else
        printf '%s\n' "$*"
    fi
}

record_installed() {
    local component=$1
    local existing
    for existing in "${installed[@]}"; do
        [[ $existing == "$component" ]] && return
    done
    installed+=("$component")
}

assert_safe_destination() {
    local destination=$1
    case "$destination" in
        '' | / | "$HOME" | "$config_root")
            printf 'Refusing unsafe destination: %s\n' "$destination" >&2
            exit 1
            ;;
        "$HOME"/*) ;;
        *)
            printf 'Destination must be inside HOME: %s\n' "$destination" >&2
            exit 1
            ;;
    esac
}

install_item() {
    local component=$1
    local source=$2
    local destination=$3

    if ! is_selected "$component"; then
        return
    fi
    if [[ ! -e $source ]]; then
        printf 'Warning: missing source for %s: %s\n' "$component" "$source" >&2
        skipped+=("$component")
        return
    fi

    assert_safe_destination "$destination"

    if [[ -e $destination || -L $destination ]]; then
        if ! $no_backup; then
            local relative=${destination#"$HOME"/}
            local backup="$backup_root/$relative"
            describe "Back up $destination -> $backup"
            if ! $dry_run; then
                mkdir -p -- "$(dirname -- "$backup")"
                cp -a -- "$destination" "$backup"
            fi
        fi

        describe "Remove old $destination"
        if ! $dry_run; then
            rm -rf -- "$destination"
        fi
    fi

    describe "Install $component -> $destination"
    if ! $dry_run; then
        mkdir -p -- "$(dirname -- "$destination")"
        cp -a -- "$source" "$destination"
    fi
    record_installed "$component"
}

old_git_name=''
old_git_email=''
if command -v git >/dev/null 2>&1; then
    old_git_name=$(git config --global --get user.name || true)
    old_git_email=$(git config --global --get user.email || true)
fi

install_item zsh "$repo_root/oh-my-zsh/.zshrc" "$HOME/.zshrc"
install_item zsh "$repo_root/powerlevel10k/.p10k.zsh" "$HOME/.p10k.zsh"
install_item nushell "$repo_root/nushell/config.nu" "$config_root/nushell/config.nu"
install_item git "$repo_root/git/.gitconfig" "$HOME/.gitconfig"
install_item lazygit "$repo_root/lazygit/config.yml" "$config_root/lazygit/config.yml"
install_item broot "$repo_root/broot" "$config_root/broot"
install_item nvim "$repo_root/nvim" "$config_root/nvim"
install_item yazi "$repo_root/yazi" "$config_root/yazi"
install_item fastfetch "$repo_root/fastfetch" "$config_root/fastfetch"
install_item oh-my-posh "$repo_root/oh-my-posh/amro.omp.json" "$config_root/oh-my-posh/amro.omp.json"
install_item starship "$repo_root/starship/starship.toml" "$config_root/starship.toml"
install_item atuin "$repo_root/atuin/config.toml" "$config_root/atuin/config.toml"
install_item bat "$repo_root/bat/config" "$config_root/bat/config"
install_item bat "$repo_root/bat/themes" "$config_root/bat/themes"
install_item cava "$repo_root/cava/config" "$config_root/cava/config"
install_item ssh "$repo_root/ssh/config" "$HOME/.ssh/config"

if is_selected git && ! $dry_run && command -v git >/dev/null 2>&1; then
    # Adapt the tracked Windows defaults to Linux line-ending behavior.
    git config --global core.autocrlf input
    git config --global core.eol lf

    if [[ -n $old_git_name ]]; then
        git config --global user.name "$old_git_name"
    else
        git config --global --unset-all user.name 2>/dev/null || true
    fi
    if [[ -n $old_git_email ]]; then
        git config --global user.email "$old_git_email"
    else
        git config --global --unset-all user.email 2>/dev/null || true
    fi
fi

if is_selected ssh && ! $dry_run && [[ -f $HOME/.ssh/config ]]; then
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh/config"
fi

if is_selected bat && ! $dry_run && command -v bat >/dev/null 2>&1; then
    bat cache --build
fi

summary_label=Installed
$dry_run && summary_label=Planned
printf '\n%s: %s\n' "$summary_label" "${installed[*]:-nothing}"
if ((${#skipped[@]})); then
    printf 'Skipped: %s\n' "${skipped[*]}"
fi
if ! $no_backup && [[ -d $backup_root ]]; then
    printf 'Backups: %s\n' "$backup_root"
fi
printf 'Done. Restart your shell and configured applications.\n'
