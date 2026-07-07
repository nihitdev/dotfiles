# ============================================
# NIHIT INDUSTRIES™ PowerShell
# All-in-One Profile v2.0
# ============================================

# --------------------------------------------
# CONFIG
# --------------------------------------------
$Global:DevName = "windows@nihitdev"

# --------------------------------------------
# PROMPT
# --------------------------------------------
function prompt {
    Write-Host (Get-Location) -ForegroundColor White
    Write-Host $Global:DevName -ForegroundColor Green -NoNewline
    return "> "
}

# --------------------------------------------
# NAVIGATION (Lazy load zoxide)
# --------------------------------------------
function z {
    if (-not (Get-Command __zoxide_z -ErrorAction SilentlyContinue)) {
        zoxide init powershell | Out-String | Invoke-Expression
    }
    __zoxide_z @args
}

function zi {
    if (-not (Get-Command __zoxide_zi -ErrorAction SilentlyContinue)) {
        zoxide init powershell | Out-String | Invoke-Expression
    }
    __zoxide_zi @args
}

function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

# --------------------------------------------
# ALIASES (Fast - load immediately)
# --------------------------------------------
Set-Alias c clear
Set-Alias cat bat
Set-Alias grep rg
Set-Alias find fd
Set-Alias du dust
Set-Alias top btm
Set-Alias sudo gsudo
Set-Alias http xh
Set-Alias dns doggo
Set-Alias ps procs

# --------------------------------------------
# FUNCTIONS
# --------------------------------------------
# File listing
function l { eza --icons @args }
function la { eza -a --icons @args }
function ll { eza -lah --git --icons }
function lt { eza --tree --level=2 --icons }

# Markdown viewer
function md { glow @args }

# Notepad++
function npp { notepad++.exe @args }

# Fastfetch (lazy load)
function ff {
    if (-not (Get-Command fastfetch -ErrorAction SilentlyContinue)) {
        Write-Host "fastfetch not installed. Run: scoop install fastfetch" -ForegroundColor Yellow
        return
    }
    fastfetch
}

# --------------------------------------------
# CMD PROTECTION SYSTEM™
# --------------------------------------------
function global:Type-Text {
    param(
        [AllowEmptyString()]
        [string]$Text = '',
        [ValidateRange(0, 1000)]
        [int]$Speed = 0,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )
    foreach ($Character in $Text.ToCharArray()) {
        Write-Host -NoNewline $Character -ForegroundColor $Color
        if ($Speed -gt 0) { Start-Sleep -Milliseconds $Speed }
    }
    Write-Host
}

function global:cmd {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )
    
    Clear-Host
    Type-Text 'Initializing Nihit Industries Security Framework...' 8 Cyan
    Start-Sleep -Milliseconds 250
    Type-Text '[##########] 100%' 2 Green
    Start-Sleep -Milliseconds 300
    Write-Host
    Type-Text 'Scanning executable...' 10 Yellow
    Start-Sleep -Milliseconds 400
    Type-Text 'Found: cmd.exe' 15 White
    Start-Sleep -Milliseconds 350
    Type-Text 'Reading executable metadata...' 10 Yellow
    Start-Sleep -Milliseconds 500
    Type-Text 'Checking compatibility...' 10 Yellow
    Start-Sleep -Milliseconds 700
    Write-Host
    Type-Text '❌ STATUS : LEGACY APPLICATION DETECTED' 18 Red
    Start-Sleep -Milliseconds 700
    Clear-Host
    
    # CMD ASCII ART
    Type-Text ' ██████╗███╗   ███╗██████╗ ' 1 Cyan
    Type-Text '██╔════╝████╗ ████║██╔══██╗' 1 Cyan
    Type-Text '██║     ██╔████╔██║██║  ██║' 1 Cyan
    Type-Text '██║     ██║╚██╔╝██║██║  ██║' 1 Cyan
    Type-Text '╚██████╗██║ ╚═╝ ██║██████╔╝' 1 Cyan
    Type-Text ' ╚═════╝╚═╝     ╚═╝╚═════╝ ' 1 Cyan
    Write-Host
    Type-Text '════════════════════════════════════════════════════════' 1 DarkGray
    Type-Text '        NIHIT INDUSTRIES™ TERMINAL' 4 Magenta
    Type-Text '          Legacy Shell Protection' 4 DarkGray
    Type-Text '════════════════════════════════════════════════════════' 1 DarkGray
    Write-Host
    Type-Text '🚨 ACCESS DENIED 🚨' 15 Red
    Write-Host
    Type-Text 'The application you attempted to launch:' 6 White
    Write-Host
    Type-Text '        cmd.exe' 25 Yellow
    Write-Host
    Type-Text 'has reached End-of-Life and is no longer' 6 White
    Type-Text 'supported on this workstation.' 6 White
    Write-Host
    Type-Text 'Reason(s):' 8 Cyan
    Type-Text '  ❌ Lacks modern scripting' 4 Red
    Type-Text '  ❌ No package management' 4 Red
    Type-Text '  ❌ Primitive tab completion' 4 Red
    Type-Text '  ❌ Skill issue detected' 8 Red
    Write-Host
    Type-Text 'Approved Shells' 8 Green
    Type-Text '  ✅ PowerShell 7' 3 Green
    Type-Text '  ✅ WSL' 3 Green
    Type-Text '  ✅ Nushell' 3 Green
    Write-Host
    Type-Text 'Rejected' 8 Red
    Type-Text '  ❌ cmd.exe' 10 Red
    Write-Host
    Type-Text 'Status:' 8 Cyan
    Type-Text '  Legacy software blocked by' 5 White
    Type-Text '  Nihit Industries Security Policy' 5 White
    Type-Text '  (NISP-2026)' 5 White
    Write-Host
    Type-Text 'Suggestion:' 8 Cyan
    Type-Text '  Upgrade your shell.' 8 White
    Type-Text '  Upgrade your workflow.' 8 White
    Type-Text '  Upgrade yourself.' 15 Yellow
    Write-Host
    Type-Text 'Press any key to embrace the future...' 15 DarkGray
    
    try {
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }
    catch {
        Read-Host 'Press Enter to embrace the future' | Out-Null
    }
    Clear-Host
}
# --------------------------------------------
# STARTUP MESSAGE
# --------------------------------------------
Write-Host "🚀 NIHIT INDUSTRIES™ Terminal Loaded" -ForegroundColor Green
Write-Host "⚡ Type 'cmd' at your own risk" -ForegroundColor Yellow