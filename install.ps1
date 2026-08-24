# ─────────────────────────────────────────────────────────────────────────────
# Dotfiles Installer
# ─────────────────────────────────────────────────────────────────────────────

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$NoBackup,

    [Parameter(HelpMessage = 'Install specific components; pass multiple names or use all.')]
    [ValidateSet(
        'powershell', 'nushell', 'git', 'lazygit', 'broot', 'nvim', 'yazi',
        'fastfetch', 'oh-my-posh', 'starship', 'atuin', 'bat', 'cava',
        'one-commander', 'yasb', 'windows-terminal', 'discord', 'ssh', 'all'
    )]
    [string[]]$Only,

    [Parameter(DontShow)]
    [string]$SourceRoot,

    [Parameter(DontShow)]
    [string]$HomeRoot
)

$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSEdition -eq 'Core' -and -not $IsWindows) {
    throw 'This installer supports Windows only. Use ./install.sh on Linux.'
}

$ExplicitSourceRoot = -not [string]::IsNullOrWhiteSpace($SourceRoot)
$RepositoryRoot = if ($ExplicitSourceRoot) { $SourceRoot } else { $PSScriptRoot }
$UserHome = if ($HomeRoot) { $HomeRoot } else { $HOME }
$RemoteRef = '985ce90867e246e0b6626e435e53744fd10fbe3d'
$RemoteArchiveSha256 = 'd7a016fb6a4f91577234d616200fb266e6d5761b584cc55f1d7c70ecee457cf8'

# When invoked with `irm <raw-url> | iex`, the script has no repository beside
# it. Download a temporary copy and hand execution to that local copy.
if (
    -not $ExplicitSourceRoot -and (
        [string]::IsNullOrWhiteSpace($RepositoryRoot) -or
        -not (Test-Path -LiteralPath (Join-Path $RepositoryRoot 'powershell\profile.ps1'))
    )
) {
    $TemporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) "dotfiles-$([guid]::NewGuid())"
    $ArchivePath = Join-Path $TemporaryRoot 'dotfiles.zip'

    try {
        New-Item -ItemType Directory -Path $TemporaryRoot -Force -WhatIf:$false | Out-Null
        Write-Host 'Downloading dotfiles...'
        $ArchiveUri = "https://github.com/nihitdev/dotfiles/archive/$RemoteRef.zip"
        Invoke-WebRequest `
            -Uri $ArchiveUri `
            -OutFile $ArchivePath
        $ActualArchiveSha256 = (Get-FileHash -LiteralPath $ArchivePath -Algorithm SHA256).Hash
        if ($ActualArchiveSha256 -ne $RemoteArchiveSha256) {
            throw 'Downloaded archive failed SHA-256 verification.'
        }
        Expand-Archive `
            -LiteralPath $ArchivePath `
            -DestinationPath $TemporaryRoot `
            -WhatIf:$false

        $DownloadedRoot = Join-Path $TemporaryRoot "dotfiles-$RemoteRef"
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
$BackupRoot = Join-Path $UserHome ".dotfiles-backup\$Timestamp-$([guid]::NewGuid())"
$Installed = [System.Collections.Generic.List[string]]::new()
$Skipped = [System.Collections.Generic.List[string]]::new()
$Transaction = [System.Collections.Generic.List[object]]::new()
$RawDestinationRoots = @($UserHome, $env:APPDATA, $env:LOCALAPPDATA) |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
foreach ($Root in $RawDestinationRoots) {
    if (-not [System.IO.Path]::IsPathRooted($Root) -or ($Root -split '[\\/]') -contains '..') {
        throw "Unsafe user destination root: $Root"
    }
}
$ApprovedDestinationRoots = $RawDestinationRoots |
    ForEach-Object { [System.IO.Path]::GetFullPath($_).TrimEnd('\', '/') } |
    Select-Object -Unique

function Assert-SafeDestination {
    param([Parameter(Mandatory)][string]$Path)

    if (-not [System.IO.Path]::IsPathRooted($Path)) {
        throw "Destination must be absolute: $Path"
    }
    if (($Path -split '[\\/]') -contains '..') {
        throw "Destination contains parent traversal: $Path"
    }

    $FullPath = [System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
    $Allowed = $false
    foreach ($Root in $ApprovedDestinationRoots) {
        if (
            $FullPath.Length -gt $Root.Length -and
            $FullPath.StartsWith("$Root\", [System.StringComparison]::OrdinalIgnoreCase)
        ) {
            $Allowed = $true
            break
        }
    }
    if (-not $Allowed) {
        throw "Destination is outside approved user roots: $Path"
    }

    $Ancestor = Split-Path -Parent $FullPath
    while (-not (Test-Path -LiteralPath $Ancestor) -and (Split-Path -Parent $Ancestor)) {
        $Ancestor = Split-Path -Parent $Ancestor
    }
    while ($Ancestor) {
        $Item = Get-Item -LiteralPath $Ancestor -Force
        if ($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            throw "Destination parent is a reparse point: $Ancestor"
        }
        if ($Ancestor -in $ApprovedDestinationRoots) {
            break
        }
        $Parent = Split-Path -Parent $Ancestor
        if ($Parent -eq $Ancestor) { break }
        $Ancestor = $Parent
    }
}

function Undo-Transaction {
    Write-Warning 'Installation failed; rolling back completed changes.'
    for ($Index = $Transaction.Count - 1; $Index -ge 0; $Index--) {
        $Record = $Transaction[$Index]
        if ($Record.Activated -and (Test-Path -LiteralPath $Record.Destination)) {
            Remove-Item -LiteralPath $Record.Destination -Recurse -Force
        }
        if ($Record.Activated -and $Record.HadPrevious -and (Test-Path -LiteralPath $Record.Previous)) {
            Move-Item -LiteralPath $Record.Previous -Destination $Record.Destination
        }
        if (Test-Path -LiteralPath $Record.StageDirectory) {
            Remove-Item -LiteralPath $Record.StageDirectory -Recurse -Force
        }
    }
    $Transaction.Clear()
}

function Complete-Transaction {
    $CompletedRecords = @($Transaction)
    $Transaction.Clear()
    foreach ($Record in $CompletedRecords) {
        if ($Record.HadPrevious -and (Test-Path -LiteralPath $Record.Previous)) {
            Remove-Item -LiteralPath $Record.Previous -Recurse -Force -ErrorAction Continue
        }
        if (Test-Path -LiteralPath $Record.StageDirectory) {
            Remove-Item -LiteralPath $Record.StageDirectory -Recurse -Force -ErrorAction Continue
        }
    }
}

function Test-Selected {
    param([Parameter(Mandatory)][string]$Name)

    if ('all' -in $Only) {
        return $true
    }
    if ($Name -eq 'windows-terminal') {
        return $Only.Count -gt 0 -and $Name -in $Only
    }
    return $Only.Count -eq 0 -or $Name -in $Only
}

function Initialize-BackupRoot {
    if (Test-Path -LiteralPath $BackupRoot) { return }
    $BackupParent = Split-Path -Parent $BackupRoot
    New-Item -ItemType Directory -Path $BackupParent -Force | Out-Null
    icacls $BackupParent /inheritance:r /grant:r "$env:USERNAME`:F" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Failed to secure the backup parent ACL.' }
    New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
    icacls $BackupRoot /inheritance:r /grant:r "$env:USERNAME`:F" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Failed to secure the backup directory ACL.' }
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
        throw "Missing source for ${Name}: $Source"
    }

    Assert-SafeDestination -Path $Destination

    if ($WhatIfPreference) {
        if (-not $NoBackup -and (Test-Path -LiteralPath $Destination)) {
            $RelativePath = $Destination.Replace(':', '').TrimStart('\', '/')
            $BackupPath = Join-Path $BackupRoot $RelativePath
            $PSCmdlet.ShouldProcess($Destination, "Back up to $BackupPath") | Out-Null
        }
        $PSCmdlet.ShouldProcess($Destination, "Install $Source transactionally") | Out-Null
        $Installed.Add($Name)
        return
    }

    $DestinationParent = Split-Path $Destination -Parent
    New-Item -ItemType Directory -Path $DestinationParent -Force | Out-Null
    Assert-SafeDestination -Path $Destination

    $StageDirectory = Join-Path $DestinationParent ".dotfiles-stage-$([guid]::NewGuid())"
    $Staged = Join-Path $StageDirectory 'payload'
    $HadPrevious = Test-Path -LiteralPath $Destination
    $Previous = Join-Path $DestinationParent ".dotfiles-previous-$([guid]::NewGuid())"
    $Record = [pscustomobject]@{
        Destination = $Destination
        Previous = $Previous
        HadPrevious = $HadPrevious
        StageDirectory = $StageDirectory
        Activated = $false
    }
    $Transaction.Add($Record)
    New-Item -ItemType Directory -Path $StageDirectory | Out-Null
    if (Test-Path -LiteralPath $Source -PathType Container) {
        Copy-Item -LiteralPath $Source -Destination $Staged -Recurse
    }
    else {
        Copy-Item -LiteralPath $Source -Destination $Staged
    }

    if (-not $NoBackup -and $HadPrevious) {
        Initialize-BackupRoot
        $RelativePath = $Destination.Replace(':', '').TrimStart('\', '/')
        $BackupPath = Join-Path $BackupRoot $RelativePath

        New-Item -ItemType Directory -Path (Split-Path $BackupPath -Parent) -Force | Out-Null
        Copy-Item -LiteralPath $Destination -Destination $BackupPath -Recurse -Force
    }

    if ($HadPrevious) {
        Move-Item -LiteralPath $Destination -Destination $Previous
    }
    $Record.Activated = $true
    Move-Item -LiteralPath $Staged -Destination $Destination
    Remove-Item -LiteralPath $StageDirectory -Force

    $Installed.Add($Name)
}

function Install-IncludeLine {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Destination,
        [Parameter(Mandatory)][string]$Line
    )
    if (-not (Test-Selected -Name $Name)) { return }
    if ((Test-Path -LiteralPath $Destination) -and
        (Get-Content -LiteralPath $Destination) -contains $Line) { return }
    if ($WhatIfPreference) { return }

    $TemporarySource = Join-Path ([System.IO.Path]::GetTempPath()) "dotfiles-include-$([guid]::NewGuid())"
    try {
        if (Test-Path -LiteralPath $Destination) {
            Copy-Item -LiteralPath $Destination -Destination $TemporarySource
        }
        Add-Content -LiteralPath $TemporarySource -Value "`n$Line" -Encoding utf8
        Install-Dotfile -Name $Name -Source $TemporarySource -Destination $Destination
    }
    finally {
        Remove-Item -LiteralPath $TemporarySource -Force -ErrorAction SilentlyContinue
    }
}

function Install-GitInclude {
    param([Parameter(Mandatory)][string]$ManagedPath)
    if (-not (Test-Selected -Name 'git')) { return }

    $AlreadyIncluded = $false
    $NormalizedManagedPath = $ManagedPath.Replace('\', '/')
    if ((Test-Path -LiteralPath (Join-Path $UserHome '.gitconfig')) -and
        (Get-Command git -ErrorAction SilentlyContinue)) {
        $Includes = git config --file (Join-Path $UserHome '.gitconfig') --get-all include.path
        $AlreadyIncluded = $Includes | Where-Object {
            $_.Replace('\', '/') -eq $NormalizedManagedPath
        } | Select-Object -First 1
    }
    elseif (Test-Path -LiteralPath (Join-Path $UserHome '.gitconfig')) {
        $AlreadyIncluded = (Get-Content -LiteralPath (Join-Path $UserHome '.gitconfig')) |
            Where-Object { $_.Trim().Replace('\', '/') -eq "path = $NormalizedManagedPath" } |
            Select-Object -First 1
    }
    if ($AlreadyIncluded) { return }
    if ($WhatIfPreference) { return }

    $TemporarySource = Join-Path ([System.IO.Path]::GetTempPath()) "dotfiles-git-$([guid]::NewGuid())"
    try {
        $UserGitConfig = Join-Path $UserHome '.gitconfig'
        if (Test-Path -LiteralPath $UserGitConfig) {
            Copy-Item -LiteralPath $UserGitConfig -Destination $TemporarySource
        }
        Add-Content -LiteralPath $TemporarySource -Value "`n[include]`n    path = $NormalizedManagedPath" -Encoding utf8
        Install-Dotfile -Name 'git' -Source $TemporarySource -Destination $UserGitConfig
    }
    finally {
        Remove-Item -LiteralPath $TemporarySource -Force -ErrorAction SilentlyContinue
    }
}

$ConfigRoot = Join-Path $UserHome '.config'
$Installations = @(
    @{ Name = 'powershell'; Source = 'powershell\profile.ps1'; Destination = $PROFILE.CurrentUserAllHosts }
    @{ Name = 'nushell'; Source = 'nushell\config.nu'; Destination = Join-Path $env:APPDATA 'nushell\config.nu' }
    @{ Name = 'nushell'; Source = 'nushell\dotfiles-init\starship.nu'; Destination = Join-Path $env:APPDATA 'nushell\dotfiles-init\starship.nu' }
    @{ Name = 'nushell'; Source = 'nushell\dotfiles-init\zoxide.nu'; Destination = Join-Path $env:APPDATA 'nushell\dotfiles-init\zoxide.nu' }
    @{ Name = 'git'; Source = 'git\.gitconfig'; Destination = Join-Path $ConfigRoot 'dotfiles\gitconfig' }
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
    @{ Name = 'ssh'; Source = 'ssh\config'; Destination = Join-Path $UserHome '.ssh\config.d\dotfiles.conf' }
)

try {
    foreach ($Item in $Installations) {
        Install-Dotfile `
            -Name $Item.Name `
            -Source (Join-Path $RepositoryRoot $Item.Source) `
            -Destination $Item.Destination
    }

    Install-GitInclude -ManagedPath (Join-Path $ConfigRoot 'dotfiles\gitconfig')
    Install-IncludeLine `
        -Name 'ssh' `
        -Destination (Join-Path $UserHome '.ssh\config') `
        -Line 'Include ~/.ssh/config.d/*.conf'

if ((Test-Selected -Name 'ssh') -and -not $WhatIfPreference) {
    $SshConfig = Join-Path $UserHome '.ssh\config'
    if (Test-Path -LiteralPath $SshConfig) {
        icacls $SshConfig /inheritance:r /grant:r "$env:USERNAME`:F" | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Failed to secure the SSH config ACL.' }
        $SshFragment = Join-Path $UserHome '.ssh\config.d\dotfiles.conf'
        icacls $SshFragment /inheritance:r /grant:r "$env:USERNAME`:F" | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Failed to secure the SSH fragment ACL.' }
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

    if (-not $WhatIfPreference) {
        Complete-Transaction
    }
}
catch {
    if (-not $WhatIfPreference) {
        Undo-Transaction
    }
    throw
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
