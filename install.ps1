[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$NoBackup,

    [Parameter(DontShow)]
    [string]$SourceRoot
)

$ErrorActionPreference = 'Stop'
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

$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupRoot = Join-Path $HOME ".dotfiles-backup\$Timestamp"

function Install-Dotfile {
    param(
        [Parameter(Mandatory)]
        [string]$Source,

        [Parameter(Mandatory)]
        [string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Warning "Skipped missing source: $Source"
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
        if (Test-Path -LiteralPath $Source -PathType Container) {
            New-Item -ItemType Directory -Path $Destination -Force | Out-Null
            Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
                Copy-Item -LiteralPath $_.FullName -Destination $Destination -Recurse -Force
            }
        }
        else {
            New-Item -ItemType Directory -Path (Split-Path $Destination -Parent) -Force | Out-Null
            Copy-Item -LiteralPath $Source -Destination $Destination -Force
        }
    }
}

$ConfigRoot = Join-Path $HOME '.config'
$Installations = @(
    @{ Source = 'powershell\profile.ps1'; Destination = $PROFILE.CurrentUserAllHosts }
    @{ Source = 'nushell\config.nu'; Destination = Join-Path $env:APPDATA 'nushell\config.nu' }
    @{ Source = 'nvim'; Destination = Join-Path $env:LOCALAPPDATA 'nvim' }
    @{ Source = 'fastfetch'; Destination = Join-Path $ConfigRoot 'fastfetch' }
    @{ Source = 'oh-my-posh\amro.omp.json'; Destination = Join-Path $ConfigRoot 'oh-my-posh\amro.omp.json' }
    @{ Source = 'starship\starship.toml'; Destination = Join-Path $ConfigRoot 'starship.toml' }
    @{ Source = 'bat\config'; Destination = Join-Path $env:APPDATA 'bat\config' }
    @{ Source = 'bat\themes'; Destination = Join-Path $env:APPDATA 'bat\themes' }
    @{ Source = 'cava\config'; Destination = Join-Path $ConfigRoot 'cava\config' }
    @{
        Source = 'one-commander\Catppuccin-Mocha.xaml'
        Destination = Join-Path $env:LOCALAPPDATA 'OneCommander\Themes\Dark\Catppuccin-Mocha.xaml'
    }
    @{ Source = 'yasb'; Destination = Join-Path $ConfigRoot 'yasb' }
)

foreach ($Item in $Installations) {
    Install-Dotfile `
        -Source (Join-Path $RepositoryRoot $Item.Source) `
        -Destination $Item.Destination
}

$TerminalPackages = @(
    'Microsoft.WindowsTerminal_8wekyb3d8bbwe',
    'Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe'
)

foreach ($Package in $TerminalPackages) {
    $TerminalState = Join-Path $env:LOCALAPPDATA "Packages\$Package\LocalState"
    if (Test-Path -LiteralPath $TerminalState) {
        Install-Dotfile `
            -Source (Join-Path $RepositoryRoot 'windows-terminal\settings.json') `
            -Destination (Join-Path $TerminalState 'settings.json')
        break
    }
}

$VencordThemes = Join-Path $env:APPDATA 'Vencord\themes'
if (Test-Path -LiteralPath (Split-Path $VencordThemes -Parent)) {
    Install-Dotfile `
        -Source (Join-Path $RepositoryRoot 'discord\themes') `
        -Destination $VencordThemes
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    if ($PSCmdlet.ShouldProcess('Bat theme cache', 'Rebuild')) {
        bat cache --build
    }
}

Write-Host 'Dotfiles installation complete.' -ForegroundColor Green
if (-not $NoBackup -and (Test-Path -LiteralPath $BackupRoot)) {
    Write-Host "Previous files were backed up to $BackupRoot"
}
Write-Host 'Restart your shells and configured applications to apply the changes.'
