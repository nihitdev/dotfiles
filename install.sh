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
declare -a transaction_destinations=()
declare -a transaction_previous=()
declare -a transaction_had_previous=()
declare -a transaction_stages=()
transaction_active=false

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --dry-run          Show what would change without writing files
  --no-backup        Replace existing files without backing them up
  --only NAME        Install one specific component; repeat for multiple tools
                     Use --only all to install every supported component
  -h, --help         Show this help

Components:
  zsh nushell git lazygit broot nvim yazi fastfetch oh-my-posh
  starship atuin bat cava ssh kitty all
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

valid_components=' zsh nushell git lazygit broot nvim yazi fastfetch oh-my-posh starship atuin bat cava ssh kitty all '
for component in "${only[@]}"; do
    if [[ $valid_components != *" $component "* ]]; then
        printf 'Unsupported component: %s\n' "$component" >&2
        exit 2
    fi
done

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_root=$script_dir
temporary_root=''
stage_root=''
remote_ref='e73351e3e6745c15294075c711005f507b8664b1'
remote_archive_sha256='9ee478057f58ba0561bcc6ce96c38522b87efc8b0585c3aaf7a20c2799b51aa9'

cleanup() {
    local stage
    if [[ -n $temporary_root && -d $temporary_root ]]; then
        rm -rf -- "$temporary_root"
    fi
    if [[ -n $stage_root && -d $stage_root ]]; then
        rm -rf -- "$stage_root"
    fi
    for stage in "${transaction_stages[@]}"; do
        if [[ -n $stage && -d $stage ]]; then
            rm -rf -- "$stage"
        fi
    done
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
    command -v sha256sum >/dev/null 2>&1 || {
        printf 'sha256sum is required for remote archive verification.\n' >&2
        exit 1
    }

    temporary_root=$(mktemp -d)
    archive="$temporary_root/dotfiles.tar.gz"
    printf 'Downloading dotfiles...\n'
    curl -fsSL "https://github.com/nihitdev/dotfiles/archive/$remote_ref.tar.gz" -o "$archive"
    printf '%s  %s\n' "$remote_archive_sha256" "$archive" | sha256sum --check --status || {
        printf 'Downloaded archive failed SHA-256 verification.\n' >&2
        exit 1
    }
    tar -xzf "$archive" -C "$temporary_root"
    repo_root="$temporary_root/dotfiles-$remote_ref"
fi

timestamp=$(date '+%Y%m%d-%H%M%S')
backup_root=''
backup_display="$HOME/.dotfiles-backup/<unique-run>"
config_root=${XDG_CONFIG_HOME:-"$HOME/.config"}

command -v realpath >/dev/null 2>&1 || {
    printf 'realpath is required for safe destination validation.\n' >&2
    exit 1
}

ensure_backup_root() {
    if [[ -n $backup_root ]]; then
        return
    fi
    mkdir -p -- "$HOME/.dotfiles-backup"
    chmod 700 "$HOME/.dotfiles-backup"
    backup_root=$(mktemp -d -- "$HOME/.dotfiles-backup/$timestamp.XXXXXX")
    chmod 700 "$backup_root"
}

if [[ $HOME != /* || $HOME == / || $HOME == *'/../'* || $HOME == */.. ]]; then
    printf 'HOME must be an absolute, specific path without parent traversal: %s\n' "$HOME" >&2
    exit 1
fi
if [[ $config_root != /* || $config_root == *'/../'* || $config_root == */.. ]]; then
    printf 'XDG_CONFIG_HOME must be an absolute path without parent traversal: %s\n' "$config_root" >&2
    exit 1
fi

home_resolved=$(realpath -m -- "$HOME")
config_root_resolved=$(realpath -m -- "$config_root")
case "$config_root_resolved" in
    "$home_resolved"/*) ;;
    *)
        printf 'XDG_CONFIG_HOME must resolve inside HOME: %s\n' "$config_root" >&2
        exit 1
        ;;
esac

rollback_transaction() {
    local index destination previous had_previous

    $transaction_active || return 0
    trap - ERR INT TERM
    printf 'Installation failed; rolling back completed changes...\n' >&2
    for ((index=${#transaction_destinations[@]} - 1; index >= 0; index--)); do
        destination=${transaction_destinations[index]}
        previous=${transaction_previous[index]}
        had_previous=${transaction_had_previous[index]}
        if [[ -e $destination || -L $destination ]]; then
            rm -rf -- "$destination"
        fi
        if [[ $had_previous == true && ( -e $previous || -L $previous ) ]]; then
            mv -- "$previous" "$destination"
        fi
    done
    transaction_active=false
}

commit_transaction() {
    local previous
    transaction_active=false
    for previous in "${transaction_previous[@]}"; do
        if [[ -n $previous && ( -e $previous || -L $previous ) ]]; then
            if ! rm -rf -- "$previous"; then
                printf 'Warning: could not remove transaction artifact: %s\n' "$previous" >&2
            fi
        fi
    done
}

trap 'rollback_transaction' ERR
trap 'rollback_transaction; exit 130' INT TERM

is_selected() {
    local component=$1
    local selected

    ((${#only[@]} == 0)) && return 0
    for selected in "${only[@]}"; do
        [[ $selected == all || $selected == "$component" ]] && return 0
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
    local resolved parent ancestor

    case "$destination" in
        '' | / | "$HOME" | "$config_root" | *'/../'* | */..)
            printf 'Refusing unsafe destination: %s\n' "$destination" >&2
            return 1
            ;;
        /*) ;;
        *)
            printf 'Destination must be absolute: %s\n' "$destination" >&2
            return 1
            ;;
    esac

    resolved=$(realpath -m -- "$destination")
    case "$resolved" in
        "$home_resolved"/*) ;;
        *)
            printf 'Destination escapes HOME: %s -> %s\n' "$destination" "$resolved" >&2
            return 1
            ;;
    esac

    # Resolve every existing parent now. This rejects symlink escapes before a
    # staging directory or destructive operation can touch the target.
    parent=$(dirname -- "$destination")
    ancestor=$parent
    while [[ ! -e $ancestor && $ancestor != / ]]; do
        ancestor=$(dirname -- "$ancestor")
    done
    ancestor=$(realpath -- "$ancestor")
    case "$ancestor" in
        "$home_resolved" | "$home_resolved"/*) ;;
        *)
            printf 'Destination parent escapes HOME: %s -> %s\n' "$parent" "$ancestor" >&2
            return 1
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
        printf 'Missing source for %s: %s\n' "$component" "$source" >&2
        skipped+=("$component")
        return 1
    fi

    assert_safe_destination "$destination"

    local parent stage_dir staged previous='' had_previous=false relative backup
    parent=$(dirname -- "$destination")

    if $dry_run; then
        if [[ -e $destination || -L $destination ]]; then
            if ! $no_backup; then
                relative=${destination#"$HOME"/}
                backup="$backup_display/$relative"
                describe "Back up $destination -> $backup"
            fi
            describe "Replace $destination transactionally"
        else
            describe "Install $component -> $destination"
        fi
        record_installed "$component"
        return
    fi

    mkdir -p -- "$parent"
    assert_safe_destination "$destination"
    stage_dir=$(mktemp -d -- "$parent/.dotfiles-stage.XXXXXX")
    transaction_stages+=("$stage_dir")
    staged="$stage_dir/payload"
    cp -a -- "$source" "$staged"

    if [[ -e $destination || -L $destination ]]; then
        if ! $no_backup; then
            ensure_backup_root
            relative=${destination#"$HOME"/}
            backup="$backup_root/$relative"
            describe "Back up $destination -> $backup"
            mkdir -p -m 700 -- "$(dirname -- "$backup")"
            cp -a -- "$destination" "$backup"
        fi
        previous="$parent/.dotfiles-previous.$(basename -- "$destination").$$.${#transaction_destinations[@]}"
        had_previous=true
    fi

    describe "Install $component -> $destination"
    transaction_destinations+=("$destination")
    transaction_previous+=("$previous")
    transaction_had_previous+=("$had_previous")
    transaction_active=true
    if $had_previous; then
        mv -- "$destination" "$previous"
    fi
    mv -- "$staged" "$destination"
    rmdir -- "$stage_dir"
    record_installed "$component"
}

install_include_line() {
    local component=$1 destination=$2 line=$3 temp_source
    is_selected "$component" || return 0
    if [[ -f $destination ]] && grep -Fqx -- "$line" "$destination"; then
        return
    fi
    temp_source=$(mktemp)
    if [[ -f $destination ]]; then
        cp -- "$destination" "$temp_source"
    fi
    printf '\n%s\n' "$line" >>"$temp_source"
    install_item "$component" "$temp_source" "$destination"
    rm -f -- "$temp_source"
}

install_git_include() {
    local managed_path=$1 temp_source
    is_selected git || return 0
    if [[ -f $HOME/.gitconfig ]]; then
        if command -v git >/dev/null 2>&1 &&
            git config --file "$HOME/.gitconfig" --get-all include.path 2>/dev/null |
                grep -Fqx -- "$managed_path"; then
            return
        fi
        if grep -Fqx -- "    path = $managed_path" "$HOME/.gitconfig"; then
            return
        fi
    fi
    temp_source=$(mktemp)
    if [[ -f $HOME/.gitconfig ]]; then
        cp -- "$HOME/.gitconfig" "$temp_source"
    fi
    printf '\n[include]\n    path = %s\n' "$managed_path" >>"$temp_source"
    install_item git "$temp_source" "$HOME/.gitconfig"
    rm -f -- "$temp_source"
}

install_item zsh "$repo_root/oh-my-zsh/.zshrc" "$HOME/.zshrc"
install_item zsh "$repo_root/powerlevel10k/.p10k.zsh" "$HOME/.p10k.zsh"
install_item nushell "$repo_root/nushell/config.nu" "$config_root/nushell/config.nu"
install_item nushell "$repo_root/nushell/dotfiles-init/starship.nu" "$config_root/nushell/dotfiles-init/starship.nu"
install_item nushell "$repo_root/nushell/dotfiles-init/zoxide.nu" "$config_root/nushell/dotfiles-init/zoxide.nu"
install_item git "$repo_root/git/.gitconfig" "$config_root/dotfiles/gitconfig"
install_git_include "$config_root/dotfiles/gitconfig"
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
install_item ssh "$repo_root/ssh/config" "$HOME/.ssh/config.d/dotfiles.conf"
install_include_line ssh "$HOME/.ssh/config" 'Include ~/.ssh/config.d/*.conf'
install_item kitty "$repo_root/kitty" "$config_root/kitty"

if is_selected git && ! $dry_run && command -v git >/dev/null 2>&1; then
    # Adapt the tracked Windows defaults to Linux line-ending behavior.
    git config --file "$config_root/dotfiles/gitconfig" core.autocrlf input
    git config --file "$config_root/dotfiles/gitconfig" core.eol lf
fi

if is_selected ssh && ! $dry_run && [[ -f $HOME/.ssh/config ]]; then
    chmod 700 "$HOME/.ssh"
    chmod 700 "$HOME/.ssh/config.d"
    chmod 600 "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config.d/dotfiles.conf"
fi

if is_selected bat && ! $dry_run && command -v bat >/dev/null 2>&1; then
    bat cache --build
fi

if ! $dry_run; then
    commit_transaction
fi

summary_label=Installed
$dry_run && summary_label=Planned
printf '\n%s: %s\n' "$summary_label" "${installed[*]:-nothing}"
if ((${#skipped[@]})); then
    printf 'Skipped: %s\n' "${skipped[*]}"
fi
if ! $no_backup && [[ -n $backup_root && -d $backup_root ]]; then
    printf 'Backups: %s\n' "$backup_root"
fi
printf 'Done. Restart your shell and configured applications.\n'
