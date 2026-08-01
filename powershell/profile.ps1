# ============================================================
# PowerShell Profile
# UTF-8 • Oh My Posh • Fastfetch • Zoxide • Modern CLI aliases
# ============================================================


# ------------------------------------------------------------
# PATHS
# ------------------------------------------------------------

$FastfetchConfig = "$HOME\.config\fastfetch\config.jsonc"
$OhMyPoshConfig  = "$HOME\.config\oh-my-posh\pure.omp.json"
$ProfileCache    = Join-Path $PSScriptRoot ".profile-cache"


# ------------------------------------------------------------
# UTF-8 ENCODING
# ------------------------------------------------------------

try {
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding           = [System.Text.UTF8Encoding]::new($false)

}
catch {
    # Ignore encoding errors during terminal startup.
}


# ------------------------------------------------------------
# HELPER FUNCTIONS
# ------------------------------------------------------------

function Test-Command {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}


function Show-MissingCommand {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    Write-Host "$Name is not installed or is not available in PATH." `
        -ForegroundColor Yellow
}


# ------------------------------------------------------------
# STARTUP COMMANDS
# ------------------------------------------------------------

# Only resolve programs that are needed during startup. Everything else is
# checked lazily when its wrapper function is called.
$HasOhMyPosh = Test-Command "oh-my-posh"
$HasZoxide   = Test-Command "zoxide"
$HasFastfetch = Test-Command "fastfetch"


# ------------------------------------------------------------
# PSREADLINE
# ------------------------------------------------------------

if ($Host.Name -eq 'ConsoleHost') {
    # PowerShell loads PSReadLine automatically for interactive consoles. Do
    # not force its relatively expensive import for scripts or redirected runs.
    if ((Get-Module PSReadLine) -and -not [Console]::IsOutputRedirected) {
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle InlineView
        Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardChar
    }
}


# ------------------------------------------------------------
# TERMINAL STARTUP
# ------------------------------------------------------------

if ($HasFastfetch -and -not [Console]::IsOutputRedirected) {
    if (Test-Path $FastfetchConfig) {
        fastfetch --config $FastfetchConfig
    }
    else {
        fastfetch
    }
}


# ------------------------------------------------------------
# PROMPT
# ------------------------------------------------------------

function Enable-PoshPrompt {
    if (-not $HasOhMyPosh) {
        Show-MissingCommand "oh-my-posh"
        return
    }

    $OhMyPoshInit = Join-Path $ProfileCache "oh-my-posh.ps1"
    $PromptConfig = Get-Item $OhMyPoshConfig -ErrorAction SilentlyContinue
    $PromptCache  = Get-Item $OhMyPoshInit -ErrorAction SilentlyContinue

    if (
        -not $PromptCache -or
        ($PromptConfig -and $PromptConfig.LastWriteTimeUtc -gt $PromptCache.LastWriteTimeUtc)
    ) {
        New-Item $ProfileCache -ItemType Directory -Force | Out-Null

        if ($PromptConfig) {
            oh-my-posh init pwsh --config $OhMyPoshConfig |
                Set-Content $OhMyPoshInit -Encoding utf8
        }
        else {
            oh-my-posh init pwsh |
                Set-Content $OhMyPoshInit -Encoding utf8
        }
    }

    if (Test-Path $OhMyPoshInit) {
        . $OhMyPoshInit
    }
}

Enable-PoshPrompt


# ------------------------------------------------------------
# NAVIGATION
# ------------------------------------------------------------

if ($HasZoxide) {
    $ZoxideInit = Join-Path $ProfileCache "zoxide.ps1"

    if (-not (Test-Path $ZoxideInit)) {
        New-Item $ProfileCache -ItemType Directory -Force | Out-Null
        zoxide init powershell | Set-Content $ZoxideInit -Encoding utf8
    }

    . $ZoxideInit
}

function .. {
    Set-Location ..
}

function ... {
    Set-Location ../..
}

function .... {
    Set-Location ../../..
}


# ------------------------------------------------------------
# TERMINAL UTILITIES
# ------------------------------------------------------------

function c {
    Clear-Host
}

function reload {
    . $PROFILE
}

function profile {
    if (Test-Command "code") {
        code $PROFILE
    }
    else {
        notepad.exe $PROFILE
    }
}


# ------------------------------------------------------------
# MODERN COMMAND REPLACEMENTS
# ------------------------------------------------------------

function cat {
    if (Test-Command "bat") {
        bat --paging=never @args
    }
    else {
        Microsoft.PowerShell.Management\Get-Content @args
    }
}

function grep {
    if (Test-Command "rg") {
        rg @args
    }
    else {
        Show-MissingCommand "ripgrep"
    }
}

function find {
    if (Test-Command "fd") {
        fd @args
    }
    else {
        Show-MissingCommand "fd"
    }
}

function du {
    if (Test-Command "dust") {
        dust @args
    }
    else {
        Show-MissingCommand "dust"
    }
}

function top {
    if (Test-Command "btm") {
        btm @args
    }
    else {
        Show-MissingCommand "bottom"
    }
}

function sudo {
    if (Test-Command "gsudo") {
        gsudo @args
    }
    else {
        Show-MissingCommand "gsudo"
    }
}

function http {
    if (Test-Command "xh") {
        xh @args
    }
    else {
        Show-MissingCommand "xh"
    }
}

function dns {
    if (Test-Command "doggo") {
        doggo @args
    }
    else {
        Show-MissingCommand "doggo"
    }
}

function ps {
    if (Test-Command "procs") {
        procs @args
    }
    else {
        Microsoft.PowerShell.Management\Get-Process @args
    }
}

function sed {
    if (Test-Command "sd") {
        sd @args
    }
    else {
        Show-MissingCommand "sd"
    }
}


# ------------------------------------------------------------
# FILE LISTING
# ------------------------------------------------------------

function l {
    if (Test-Command "eza") {
        eza --icons @args
    }
    else {
        Get-ChildItem @args
    }
}

function la {
    if (Test-Command "eza") {
        eza --all --icons @args
    }
    else {
        Get-ChildItem -Force @args
    }
}

function ll {
    if (Test-Command "eza") {
        eza --long --all --header --git --icons @args
    }
    else {
        Get-ChildItem -Force @args |
            Format-Table
    }
}

function lt {
    if (Test-Command "eza") {
        eza --tree --level=2 --icons @args
    }
    else {
        tree @args
    }
}


# ------------------------------------------------------------
# APPLICATION SHORTCUTS
# ------------------------------------------------------------

function preview-md {
    if (Test-Command "glow") {
        glow @args
    }
    else {
        Show-MissingCommand "glow"
    }
}

function npp {
    if (Test-Command "notepad++.exe") {
        notepad++.exe @args
    }
    else {
        Show-MissingCommand "Notepad++"
    }
}

function ff {
    if (Test-Command "fastfetch") {
        if ($args.Count -gt 0) {
            fastfetch @args
        }
        elseif (Test-Path $FastfetchConfig) {
            fastfetch --config $FastfetchConfig
        }
        else {
            fastfetch
        }
    }
    else {
        Show-MissingCommand "fastfetch"
    }
}


# ------------------------------------------------------------
# YAZI FILE MANAGER
# ------------------------------------------------------------

function y {
    if (-not (Test-Command "yazi.exe")) {
        Show-MissingCommand "yazi"
        return
    }

    $TempFile = New-TemporaryFile

    try {
        yazi.exe @args --cwd-file="$($TempFile.FullName)"

        if (Test-Path $TempFile.FullName) {
            $NewDirectory = Get-Content $TempFile.FullName -Raw

            if (
                $NewDirectory -and
                (Test-Path $NewDirectory -PathType Container)
            ) {
                Set-Location $NewDirectory
            }
        }
    }
    finally {
        Remove-Item $TempFile.FullName `
            -Force `
            -ErrorAction SilentlyContinue
    }
}
