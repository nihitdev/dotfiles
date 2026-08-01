# ============================================================
# Nushell Config
# UTF-8 • Oh My Posh • Fastfetch • Zoxide • Modern CLI tools
# ============================================================


# ------------------------------------------------------------
# PATHS
# ------------------------------------------------------------

const FASTFETCH_CONFIG = $"($nu.home-dir)/.config/fastfetch/config.jsonc"
const OH_MY_POSH_CONFIG = $"($nu.home-dir)/.config/oh-my-posh/pure.omp.json"


# ------------------------------------------------------------
# HELPERS
# ------------------------------------------------------------

def has-command [name: string] {
    which --all $name
    | where type == "external"
    | is-not-empty
}

def missing-command [name: string] {
    print $"(ansi yellow)($name) is not installed or unavailable in PATH.(ansi reset)"
}


# ------------------------------------------------------------
# NUSHELL SETTINGS
# ------------------------------------------------------------

$env.config.show_banner = false

$env.config.history = {
    max_size: 100_000
    sync_on_enter: true
    file_format: "plaintext"
    isolation: false
}

$env.config.completions = {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "fuzzy"
    external: {
        enable: true
        max_results: 100
        completer: null
    }
}


# ------------------------------------------------------------
# TERMINAL STARTUP
# ------------------------------------------------------------

if (has-command fastfetch) {
    if ($FASTFETCH_CONFIG | path exists) {
        ^fastfetch --config $FASTFETCH_CONFIG
    } else {
        ^fastfetch
    }
}


# ------------------------------------------------------------
# ZOXIDE
# ------------------------------------------------------------

# Run this once manually:
#
# zoxide init nushell | save -f ~/.zoxide.nu
#
# Then uncomment:
#
# source ~/.zoxide.nu


# ------------------------------------------------------------
# NAVIGATION
# ------------------------------------------------------------

def --env ".." [] {
    cd ..
}

def --env "..." [] {
    cd ../..
}

def --env "...." [] {
    cd ../../..
}

def --env home [] {
    cd $nu.home-dir
}


# ------------------------------------------------------------
# TERMINAL UTILITIES
# ------------------------------------------------------------

def c [] {
    clear
}

def reload [] {
    exec nu
}

# Type `profile` to open config.nu in Notepad.
def profile [] {
    ^notepad.exe $nu.config-path
}

# Open env.nu in Notepad.
def env-profile [] {
    ^notepad.exe $nu.env-path
}

def paths [] {
    $env.PATH
}


# ------------------------------------------------------------
# MODERN CLI COMMANDS
#
# Native Nushell commands such as cat, find, du and ps are not
# replaced because they return structured data.
# ------------------------------------------------------------

def --wrapped bat [...args] {
    if (has-command bat) {
        ^bat --paging=never ...$args
    } else {
        missing-command bat
    }
}

def --wrapped grep [...args] {
    if (has-command rg) {
        ^rg ...$args
    } else {
        missing-command ripgrep
    }
}

def --wrapped rg [...args] {
    if (has-command rg) {
        ^rg ...$args
    } else {
        missing-command ripgrep
    }
}

def --wrapped fd [...args] {
    if (has-command fd) {
        ^fd ...$args
    } else {
        missing-command fd
    }
}

def --wrapped dust [...args] {
    if (has-command dust) {
        ^dust ...$args
    } else {
        missing-command dust
    }
}

def --wrapped btm [...args] {
    if (has-command btm) {
        ^btm ...$args
    } else {
        missing-command bottom
    }
}

def --wrapped sudo [...args] {
    if (has-command gsudo) {
        ^gsudo ...$args
    } else {
        missing-command gsudo
    }
}

def --wrapped http [...args] {
    if (has-command xh) {
        ^xh ...$args
    } else {
        missing-command xh
    }
}

def --wrapped dns [...args] {
    if (has-command doggo) {
        ^doggo ...$args
    } else {
        missing-command doggo
    }
}

def --wrapped procs [...args] {
    if (has-command procs) {
        ^procs ...$args
    } else {
        missing-command procs
    }
}

def --wrapped sd [...args] {
    if (has-command sd) {
        ^sd ...$args
    } else {
        missing-command sd
    }
}


# ------------------------------------------------------------
# FILE LISTING
# ------------------------------------------------------------

def --wrapped l [...args] {
    if (has-command eza) {
        ^eza --icons ...$args
    } else {
        ls ...$args
    }
}

def --wrapped la [...args] {
    if (has-command eza) {
        ^eza --all --icons ...$args
    } else {
        ls --all ...$args
    }
}

def --wrapped ll [...args] {
    if (has-command eza) {
        ^eza --long --all --header --git --icons ...$args
    } else {
        ls --long --all ...$args
    }
}

def --wrapped lt [...args] {
    if (has-command eza) {
        ^eza --tree --level=2 --icons ...$args
    } else {
        missing-command eza
    }
}


# ------------------------------------------------------------
# GIT SHORTCUTS
# ------------------------------------------------------------

def --wrapped g [...args] {
    if (has-command git) {
        ^git ...$args
    } else {
        missing-command git
    }
}

def gs [] {
    ^git status --short --branch
}

def ga [...files] {
    ^git add ...$files
}

def gc [message: string] {
    ^git commit -m $message
}

def gp [] {
    ^git push
}

def gl [] {
    ^git log --oneline --graph --decorate --all
}


# ------------------------------------------------------------
# APPLICATION SHORTCUTS
# ------------------------------------------------------------

def --wrapped preview-md [...args] {
    if (has-command glow) {
        ^glow ...$args
    } else {
        missing-command glow
    }
}

def --wrapped npp [...args] {
    if (has-command notepad++.exe) {
        ^notepad++.exe ...$args
    } else {
        missing-command "Notepad++"
    }
}

def --wrapped code [...args] {
    if (has-command code) {
        ^code ...$args
    } else {
        missing-command "Visual Studio Code"
    }
}

def --wrapped ff [...args] {
    if not (has-command fastfetch) {
        missing-command fastfetch
        return
    }

    if ($args | is-not-empty) {
        ^fastfetch ...$args
    } else if ($FASTFETCH_CONFIG | path exists) {
        ^fastfetch --config $FASTFETCH_CONFIG
    } else {
        ^fastfetch
    }
}


# ------------------------------------------------------------
# OH MY POSH PROMPT
# ------------------------------------------------------------

# Oh My Posh requires Nushell 0.104.0 or newer.
if (has-command oh-my-posh) {
    if ($OH_MY_POSH_CONFIG | path exists) {
        oh-my-posh init nu --config $OH_MY_POSH_CONFIG
    } else {
        print $"(ansi yellow)Oh My Posh theme not found: ($OH_MY_POSH_CONFIG)(ansi reset)"
        oh-my-posh init nu
    }
}
