#!/usr/bin/env bash

set -Eeuo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
test_root=$(mktemp -d)

cleanup() {
    rm -rf -- "$test_root"
}
trap cleanup EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

assert_file_contains() {
    local file=$1 text=$2
    grep -Fq -- "$text" "$file" || fail "$file does not contain: $text"
}

assert_count() {
    local expected=$1 file=$2 text=$3 actual
    actual=$(grep -Fc -- "$text" "$file" || true)
    [[ $actual == "$expected" ]] || fail "expected $expected occurrences of '$text' in $file, got $actual"
}

run_preservation_test() {
    local home="$test_root/preserve"
    mkdir -p "$home/.ssh"
    printf '[user]\n    name = Existing User\n[custom]\n    value = retained\n' >"$home/.gitconfig"
    printf 'Host existing.example\n    User existing\n' >"$home/.ssh/config"

    HOME="$home" XDG_CONFIG_HOME="$home/.config" \
        "$repo_root/install.sh" --only git --only ssh >/dev/null

    assert_file_contains "$home/.gitconfig" 'name = Existing User'
    assert_file_contains "$home/.gitconfig" 'value = retained'
    assert_file_contains "$home/.gitconfig" "path = $home/.config/dotfiles/gitconfig"
    assert_file_contains "$home/.ssh/config" 'Host existing.example'
    assert_file_contains "$home/.ssh/config" 'Include ~/.ssh/config.d/*.conf'
    [[ -f $home/.ssh/config.d/dotfiles.conf ]] || fail 'managed SSH fragment was not installed'
    [[ -f $home/.config/dotfiles/gitconfig ]] || fail 'managed Git config was not installed'

    HOME="$home" XDG_CONFIG_HOME="$home/.config" \
        "$repo_root/install.sh" --only git --only ssh >/dev/null
    assert_count 1 "$home/.gitconfig" "path = $home/.config/dotfiles/gitconfig"
    assert_count 1 "$home/.ssh/config" 'Include ~/.ssh/config.d/*.conf'

    mapfile -t backups < <(find "$home/.dotfiles-backup" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')
    [[ ${#backups[@]} -eq 2 ]] || fail 'backup runs did not use unique directories'
    [[ $(stat -c '%a' "$home/.dotfiles-backup") == 700 ]] || fail 'backup parent is not private'
    local backup
    for backup in "${backups[@]}"; do
        [[ $(stat -c '%a' "$home/.dotfiles-backup/$backup") == 700 ]] || fail 'backup run directory is not private'
    done
}

run_traversal_test() {
    local home="$test_root/traversal/home"
    local escaped="$test_root/traversal/escaped"
    mkdir -p "$home" "$escaped"
    printf 'sentinel\n' >"$escaped/sentinel"

    if HOME="$home" XDG_CONFIG_HOME="$home/../../escaped" \
        "$repo_root/install.sh" --only nvim >/dev/null 2>&1; then
        fail 'parent traversal destination was accepted'
    fi
    assert_file_contains "$escaped/sentinel" sentinel
    [[ ! -e $escaped/nvim ]] || fail 'traversal wrote outside HOME'
}

run_symlink_escape_test() {
    local home="$test_root/symlink/home"
    local escaped="$test_root/symlink/escaped"
    mkdir -p "$home" "$escaped"
    ln -s "$escaped" "$home/.config"
    printf 'sentinel\n' >"$escaped/sentinel"

    if HOME="$home" "$repo_root/install.sh" --only nvim >/dev/null 2>&1; then
        fail 'symlink parent escape was accepted'
    fi
    assert_file_contains "$escaped/sentinel" sentinel
    [[ ! -e $escaped/nvim ]] || fail 'symlink escape wrote outside HOME'
}

run_rollback_test() {
    local home="$test_root/rollback/home"
    local fake_bin="$test_root/rollback/bin"
    mkdir -p "$home/.config/bat/themes" "$fake_bin"
    printf 'old config\n' >"$home/.config/bat/config"
    printf 'old theme\n' >"$home/.config/bat/themes/original.theme"
    printf '#!/usr/bin/env bash\nexit 23\n' >"$fake_bin/bat"
    chmod +x "$fake_bin/bat"

    if HOME="$home" XDG_CONFIG_HOME="$home/.config" PATH="$fake_bin:$PATH" \
        "$repo_root/install.sh" --only bat >/dev/null 2>&1; then
        fail 'injected post-install failure unexpectedly succeeded'
    fi
    assert_file_contains "$home/.config/bat/config" 'old config'
    assert_file_contains "$home/.config/bat/themes/original.theme" 'old theme'
    if find "$home" -name '.dotfiles-stage.*' -o -name '.dotfiles-previous.*' | grep -q .; then
        fail 'transaction artifacts remained after rollback'
    fi
}

run_nushell_payload_test() {
    local home="$test_root/nushell"
    mkdir -p "$home"
    HOME="$home" XDG_CONFIG_HOME="$home/.config" \
        "$repo_root/install.sh" --only nushell >/dev/null
    [[ -f $home/.config/nushell/dotfiles-init/starship.nu ]] || fail 'Starship bootstrap cache missing'
    [[ -f $home/.config/nushell/dotfiles-init/zoxide.nu ]] || fail 'Zoxide bootstrap cache missing'
    assert_file_contains "$home/.config/nushell/config.nu" 'has-command sudo'
}

run_kitty_payload_test() {
    local home="$test_root/kitty"
    mkdir -p "$home"
    HOME="$home" XDG_CONFIG_HOME="$home/.config" \
        "$repo_root/install.sh" --only kitty >/dev/null
    [[ -f $home/.config/kitty/kitty.conf ]] || fail 'Kitty config missing'
    [[ -f $home/.config/kitty/current-theme.conf ]] || fail 'Kitty theme missing'
    [[ -f $home/.config/kitty/tab.py ]] || fail 'Kitty tab implementation missing'
    [[ -f $home/.config/kitty/tab_bar.py ]] || fail 'Kitty tab entrypoint missing'
    assert_file_contains "$home/.config/kitty/kitty.conf" 'shell /usr/bin/fish'
}

run_fish_payload_test() {
    local home="$test_root/fish"
    mkdir -p "$home"
    HOME="$home" XDG_CONFIG_HOME="$home/.config" \
        "$repo_root/install.sh" --only fish >/dev/null
    [[ -f $home/.config/fish/config.fish ]] || fail 'Fish config missing'
    [[ -f $home/.config/fish/conf.d/rashin.fish ]] || fail 'Fish conf.d payload missing'
    [[ ! -e $home/.config/fish/fish_variables ]] || fail 'Machine-specific Fish variables were installed'
}

run_remote_verification_test() {
    local home="$test_root/remote/home"
    local script_copy="$test_root/remote/install.sh"
    local bad_script="$test_root/remote/install-bad-hash.sh"
    mkdir -p "$home"
    cp "$repo_root/install.sh" "$script_copy"
    HOME="$home" XDG_CONFIG_HOME="$home/.config" \
        bash "$script_copy" --dry-run --only nvim >/dev/null

    sed "s/remote_archive_sha256='[0-9a-f]*'/remote_archive_sha256='0000000000000000000000000000000000000000000000000000000000000000'/" \
        "$script_copy" >"$bad_script"
    if HOME="$home" XDG_CONFIG_HOME="$home/.config" \
        bash "$bad_script" --dry-run --only nvim >/dev/null 2>&1; then
        fail 'remote archive with an invalid checksum was accepted'
    fi
}

run_static_security_defaults_test() {
    grep -Fq 'raw.githubusercontent.com/nihitdev/dotfiles/main/install.ps1' "$repo_root/README.md" ||
        fail 'Windows quick-install URL is not hosted on raw.githubusercontent.com'
    grep -Fqx -- '--color=auto' "$repo_root/.config/bat/config" || fail 'Bat does not use automatic color mode'
    if grep -Fq '~/.config/fastfetch/ascii.txt' "$repo_root/.config/fastfetch/config.jsonc"; then
        fail 'Fastfetch config still hard-codes ~/.config'
    fi
    local license
    for license in "$repo_root"/.config/yazi/plugins/*.yazi/LICENSE; do
        [[ $(sha256sum "$license" | cut -d' ' -f1) == 06a2b04a7ed4f030a87d10b884fc1a2215c5e91b371f69dfe173448e834f3752 ]] ||
            fail "unexpected vendored license content: $license"
    done
}

run_all_selector_test() {
    local home="$test_root/all-selector"
    mkdir -p "$home"
    local plan
    plan=$(HOME="$home" XDG_CONFIG_HOME="$home/.config" \
        "$repo_root/install.sh" --dry-run --only all)
    [[ $plan == *'Install kitty'* ]] || fail '--only all did not select Kitty'
    [[ $plan == *'Install fish'* ]] || fail '--only all did not select Fish'
    [[ $plan == *'Install nvim'* ]] || fail '--only all did not select Neovim'
}

run_specific_selector_test() {
    local home="$test_root/specific-selector"
    local component
    mkdir -p "$home"
    for component in zsh nushell git lazygit broot nvim yazi fastfetch \
        oh-my-posh starship atuin bat cava ssh kitty fish; do
        HOME="$home" XDG_CONFIG_HOME="$home/.config" \
            "$repo_root/install.sh" --dry-run --only "$component" >/dev/null ||
            fail "--only rejected supported component: $component"
    done
}

run_preservation_test
run_traversal_test
run_symlink_escape_test
run_rollback_test
run_nushell_payload_test
run_kitty_payload_test
run_fish_payload_test
run_remote_verification_test
run_static_security_defaults_test
run_all_selector_test
run_specific_selector_test
printf 'Linux installer safety tests passed.\n'
