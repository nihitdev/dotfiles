# ─────────────────────────────────────────────────────────────────────────────
# Dotfiles Installer
# ─────────────────────────────────────────────────────────────────────────────

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$NoBackup,

    [ValidateSet(
        'powershell', 'nushell', 'git', 'lazygit', 'broot', 'nvim', 'yazi',
        'fastfetch', 'oh-my-posh', 'starship', 'atuin', 'bat', 'cava',
        'one-commander', 'yasb', 'windows-terminal', 'discord', 'ssh'
    )]
    [string[]]$Only,

    [Parameter(DontShow)]
    [string]$SourceRoot
)

$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSEdition -eq 'Core' -and -not $IsWindows) {
    throw 'This installer supports Windows only. Use ./install.sh on Linux.'
}

$RepositoryRoot = if ($SourceRoot) { $SourceRoot } else { $PSScriptRoot }

# When invoked with `irm <raw-url> | iex`, the script has no repository beside
# it. Download a temporary copy and hand execution to that local copy.
if (
    [string]::IsNullOrWhiteSpace($RepositoryRoot) -or
    -not (Test-Path -LiteralPath (Join-Path $RepositoryRoot 'powershell\profile.ps1'))
) {
    $TemporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) "dotfiles-$([guid]::NewGuid())"
    $ArchivePath = Join-Path $TemporaryRoot 'dotfiles.zip'

    try {
        New-Item -ItemType Directory -Path $TemporaryRoot -Force | Out-Null
        Write-Host 'Downloading dotfiles...'
        $ArchiveUri = 'https://github.com/nihitdev/dotfiles/archive/refs/heads/main.zip' +
            "?cache=$([guid]::NewGuid())"
        Invoke-WebRequest `
            -Uri $ArchiveUri `
            -OutFile $ArchivePath
        Expand-Archive -LiteralPath $ArchivePath -DestinationPath $TemporaryRoot

        $DownloadedRoot = Join-Path $TemporaryRoot 'dotfiles-main'
        $DownloadedInstaller = Join-Path $DownloadedRoot 'install.ps1'
        $DownloadedScript = [scriptblock]::Create(
            (Get-Content -LiteralPath $DownloadedInstaller -Raw)
        )
        $ForwardedParameters = @{} + $PSBoundParameters
        $ForwardedParameters.Remove('SourceRoot')
        & $DownloadedScript -SourceRoot $DownloadedRoot @ForwardedParameters
    }
    finally {
        if (Test-Path -LiteralPath $TemporaryRoot) {
            [System.IO.Directory]::Delete($TemporaryRoot, $true)
        }
    }

    return
}

Write-Host @'
██████╗ ██╗ ██████╗██╗███╗   ██╗ ██████╗
██╔══██╗██║██╔════╝██║████╗  ██║██╔════╝
██████╔╝██║██║     ██║██╔██╗ ██║██║  ███╗
██╔══██╗██║██║     ██║██║╚██╗██║██║   ██║
██║  ██║██║╚██████╗██║██║ ╚████║╚██████╔╝
╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝╚═╝  ╚═══╝ ╚═════╝
'@ -ForegroundColor Magenta
Write-Host "`nInstalling Nihit's Dotfiles..."

$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupRoot = Join-Path $HOME ".dotfiles-backup\$Timestamp"
$Installed = [System.Collections.Generic.List[string]]::new()
$Skipped = [System.Collections.Generic.List[string]]::new()

function Test-Selected {
    param([Parameter(Mandatory)][string]$Name)

    return $Only.Count -eq 0 -or $Name -in $Only
}

function Install-Dotfile {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Source,

        [Parameter(Mandatory)]
        [string]$Destination
    )

    if (-not (Test-Selected -Name $Name)) {
        return
    }

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Warning "Skipped missing source: $Source"
        $Skipped.Add($Name)
        return
    }

    if (-not $NoBackup -and (Test-Path -LiteralPath $Destination)) {
        $RelativePath = $Destination.Replace(':', '').TrimStart('\', '/')
        $BackupPath = Join-Path $BackupRoot $RelativePath

        if ($PSCmdlet.ShouldProcess($Destination, "Back up to $BackupPath")) {
            New-Item -ItemType Directory -Path (Split-Path $BackupPath -Parent) -Force | Out-Null
            Copy-Item -LiteralPath $Destination -Destination $BackupPath -Recurse -Force
        }
    }

    if ($PSCmdlet.ShouldProcess($Destination, "Install $Source")) {
        if (Test-Path -LiteralPath $Destination) {
            Remove-Item -LiteralPath $Destination -Recurse -Force
        }

        New-Item -ItemType Directory -Path (Split-Path $Destination -Parent) -Force | Out-Null
        if (Test-Path -LiteralPath $Source -PathType Container) {
            Copy-Item -LiteralPath $Source -Destination $Destination -Recurse -Force
        }
        else {
            Copy-Item -LiteralPath $Source -Destination $Destination -Force
        }
    }

    $Installed.Add($Name)
}

$ConfigRoot = Join-Path $HOME '.config'
$ExistingGitName = if (Get-Command git -ErrorAction SilentlyContinue) {
    git config --global --get user.name
}
$ExistingGitEmail = if (Get-Command git -ErrorAction SilentlyContinue) {
    git config --global --get user.email
}
$Installations = @(
    @{ Name = 'powershell'; Source = 'powershell\profile.ps1'; Destination = $PROFILE.CurrentUserAllHosts }
    @{ Name = 'nushell'; Source = 'nushell\config.nu'; Destination = Join-Path $env:APPDATA 'nushell\config.nu' }
    @{ Name = 'git'; Source = 'git\.gitconfig'; Destination = Join-Path $HOME '.gitconfig' }
    @{ Name = 'lazygit'; Source = 'lazygit\config.yml'; Destination = Join-Path $env:LOCALAPPDATA 'lazygit\config.yml' }
    @{ Name = 'broot'; Source = 'broot'; Destination = Join-Path $env:APPDATA 'dystroy\broot\config' }
    @{ Name = 'nvim'; Source = 'nvim'; Destination = Join-Path $env:LOCALAPPDATA 'nvim' }
    @{ Name = 'yazi'; Source = 'yazi'; Destination = Join-Path $env:APPDATA 'yazi\config' }
    @{ Name = 'fastfetch'; Source = 'fastfetch'; Destination = Join-Path $ConfigRoot 'fastfetch' }
    @{ Name = 'oh-my-posh'; Source = 'oh-my-posh\amro.omp.json'; Destination = Join-Path $ConfigRoot 'oh-my-posh\amro.omp.json' }
    @{ Name = 'starship'; Source = 'starship\starship.toml'; Destination = Join-Path $ConfigRoot 'starship.toml' }
    @{ Name = 'atuin'; Source = 'atuin\config.toml'; Destination = Join-Path $ConfigRoot 'atuin\config.toml' }
    @{ Name = 'bat'; Source = 'bat\config'; Destination = Join-Path $env:APPDATA 'bat\config' }
    @{ Name = 'bat'; Source = 'bat\themes'; Destination = Join-Path $env:APPDATA 'bat\themes' }
    @{ Name = 'cava'; Source = 'cava\config'; Destination = Join-Path $ConfigRoot 'cava\config' }
    @{
        Name = 'one-commander'
        Source = 'one-commander\Catppuccin-Mocha.xaml'
        Destination = Join-Path $env:LOCALAPPDATA 'OneCommander\Themes\Dark\Catppuccin-Mocha.xaml'
    }
    @{ Name = 'yasb'; Source = 'yasb'; Destination = Join-Path $ConfigRoot 'yasb' }
    @{ Name = 'ssh'; Source = 'ssh\config'; Destination = Join-Path $HOME '.ssh\config' }
)

foreach ($Item in $Installations) {
    Install-Dotfile `
        -Name $Item.Name `
        -Source (Join-Path $RepositoryRoot $Item.Source) `
        -Destination $Item.Destination
}

if ((Test-Selected -Name 'git') -and -not $WhatIfPreference -and (Get-Command git -ErrorAction SilentlyContinue)) {
    if ($ExistingGitName) {
        git config --global user.name $ExistingGitName
    }
    else {
        git config --global --unset-all user.name 2>$null
    }

    if ($ExistingGitEmail) {
        git config --global user.email $ExistingGitEmail
    }
    else {
        git config --global --unset-all user.email 2>$null
    }
}

if ((Test-Selected -Name 'ssh') -and -not $WhatIfPreference) {
    $SshConfig = Join-Path $HOME '.ssh\config'
    if (Test-Path -LiteralPath $SshConfig) {
        icacls $SshConfig /inheritance:r /grant:r "$env:USERNAME`:F" | Out-Null
    }
}

$TerminalPackages = @(
    'Microsoft.WindowsTerminal_8wekyb3d8bbwe',
    'Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe'
)

foreach ($Package in $TerminalPackages) {
    if (-not (Test-Selected -Name 'windows-terminal')) {
        break
    }

    $TerminalState = Join-Path $env:LOCALAPPDATA "Packages\$Package\LocalState"
    if (Test-Path -LiteralPath $TerminalState) {
        Install-Dotfile `
            -Name 'windows-terminal' `
            -Source (Join-Path $RepositoryRoot 'windows-terminal\settings.json') `
            -Destination (Join-Path $TerminalState 'settings.json')
        break
    }
}

$VencordThemes = Join-Path $env:APPDATA 'Vencord\themes'
if ((Test-Selected -Name 'discord') -and (Test-Path -LiteralPath (Split-Path $VencordThemes -Parent))) {
    Install-Dotfile `
        -Name 'discord' `
        -Source (Join-Path $RepositoryRoot 'discord\theme') `
        -Destination $VencordThemes
}

if ((Test-Selected -Name 'bat') -and (Get-Command bat -ErrorAction SilentlyContinue)) {
    if ($PSCmdlet.ShouldProcess('Bat theme cache', 'Rebuild')) {
        bat cache --build
    }
}

if (-not $NoBackup -and (Test-Path -LiteralPath $BackupRoot)) {
    Write-Host "Previous files were backed up to $BackupRoot"
}

$SummaryLabel = if ($WhatIfPreference) { 'Planned' } else { 'Installed' }
$UniqueInstalled = $Installed | Select-Object -Unique
Write-Host "`n$SummaryLabel`: $($UniqueInstalled -join ', ')" -ForegroundColor Green
if ($Skipped.Count -gt 0) {
    Write-Warning "Skipped: $(($Skipped | Select-Object -Unique) -join ', ')"
}
Write-Host 'Done! Restart your terminal and configured applications.' -ForegroundColor Green
