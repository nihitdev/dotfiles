[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$RepositoryRoot = Split-Path -Parent $PSScriptRoot
$TestRoot = Join-Path ([System.IO.Path]::GetTempPath()) "dotfiles-tests-$([guid]::NewGuid())"

function Assert-True {
    param([Parameter(Mandatory)][bool]$Condition, [Parameter(Mandatory)][string]$Message)
    if (-not $Condition) { throw $Message }
}

function Invoke-IsolatedInstaller {
    param(
        [Parameter(Mandatory)][string]$Home,
        [Parameter(Mandatory)][string[]]$Only,
        [string]$SourceRoot = $RepositoryRoot
    )
    $env:APPDATA = Join-Path $Home 'AppData\Roaming'
    $env:LOCALAPPDATA = Join-Path $Home 'AppData\Local'
    & (Join-Path $RepositoryRoot 'install.ps1') `
        -SourceRoot $SourceRoot -HomeRoot $Home -Only $Only
}

try {
    New-Item -ItemType Directory -Path $TestRoot | Out-Null

    $PreserveHome = Join-Path $TestRoot 'preserve'
    New-Item -ItemType Directory -Path (Join-Path $PreserveHome '.ssh') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $PreserveHome '.gitconfig') -Value @'
[user]
    name = Existing User
[custom]
    value = retained
'@
    Set-Content -LiteralPath (Join-Path $PreserveHome '.ssh\config') -Value @'
Host existing.example
    User existing
'@
    Invoke-IsolatedInstaller -Home $PreserveHome -Only git, ssh
    Invoke-IsolatedInstaller -Home $PreserveHome -Only git, ssh
    $GitText = Get-Content -LiteralPath (Join-Path $PreserveHome '.gitconfig') -Raw
    $SshText = Get-Content -LiteralPath (Join-Path $PreserveHome '.ssh\config') -Raw
    Assert-True ($GitText.Contains('name = Existing User')) 'Existing Git identity was lost.'
    Assert-True ($GitText.Contains('value = retained')) 'Existing Git setting was lost.'
    Assert-True (([regex]::Matches($GitText, '(?m)^\s*path = ')).Count -eq 1) 'Git include is not idempotent.'
    Assert-True ($SshText.Contains('Host existing.example')) 'Existing SSH host was lost.'
    Assert-True (([regex]::Matches($SshText, '(?m)^Include ~/.ssh/config.d/\*\.conf$')).Count -eq 1) 'SSH include is not idempotent.'
    $BackupRuns = Get-ChildItem -LiteralPath (Join-Path $PreserveHome '.dotfiles-backup') -Directory
    Assert-True ($BackupRuns.Count -eq 2) 'Backup runs did not use unique directories.'
    Assert-True ((Get-Acl -LiteralPath (Join-Path $PreserveHome '.dotfiles-backup')).AreAccessRulesProtected) 'Backup parent ACL inheritance was not removed.'
    foreach ($BackupRun in $BackupRuns) {
        Assert-True ((Get-Acl -LiteralPath $BackupRun.FullName).AreAccessRulesProtected) 'Backup ACL inheritance was not removed.'
    }

    $TraversalHome = Join-Path $TestRoot 'traversal\home'
    New-Item -ItemType Directory -Path $TraversalHome -Force | Out-Null
    $env:APPDATA = Join-Path $TraversalHome '..\escaped'
    $env:LOCALAPPDATA = Join-Path $TraversalHome 'AppData\Local'
    $TraversalRejected = $false
    try {
        & (Join-Path $RepositoryRoot 'install.ps1') -SourceRoot $RepositoryRoot -HomeRoot $TraversalHome -Only nushell
    }
    catch { $TraversalRejected = $true }
    Assert-True $TraversalRejected 'Parent traversal destination root was accepted.'

    $JunctionHome = Join-Path $TestRoot 'junction\home'
    $Outside = Join-Path $TestRoot 'junction\outside'
    New-Item -ItemType Directory -Path $JunctionHome, $Outside -Force | Out-Null
    $Roaming = Join-Path $JunctionHome 'AppData\Roaming'
    New-Item -ItemType Junction -Path $Roaming -Target $Outside | Out-Null
    $env:APPDATA = $Roaming
    $env:LOCALAPPDATA = Join-Path $JunctionHome 'AppData\Local'
    $JunctionRejected = $false
    try {
        & (Join-Path $RepositoryRoot 'install.ps1') -SourceRoot $RepositoryRoot -HomeRoot $JunctionHome -Only nushell
    }
    catch { $JunctionRejected = $true }
    Assert-True $JunctionRejected 'Junction destination escape was accepted.'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $Outside 'nushell'))) 'Junction escape wrote outside the isolated home.'

    $RollbackHome = Join-Path $TestRoot 'rollback\home'
    $PartialSource = Join-Path $TestRoot 'rollback\source'
    New-Item -ItemType Directory -Path (Join-Path $RollbackHome 'AppData\Roaming\nushell'), (Join-Path $PartialSource 'nushell') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $RollbackHome 'AppData\Roaming\nushell\config.nu') -Value 'old config'
    Set-Content -LiteralPath (Join-Path $PartialSource 'nushell\config.nu') -Value 'new config'
    $RollbackFailed = $false
    try { Invoke-IsolatedInstaller -Home $RollbackHome -Only nushell -SourceRoot $PartialSource }
    catch { $RollbackFailed = $true }
    Assert-True $RollbackFailed 'Missing second source did not fail closed.'
    Assert-True ((Get-Content -LiteralPath (Join-Path $RollbackHome 'AppData\Roaming\nushell\config.nu') -Raw).Trim() -eq 'old config') 'Rollback did not restore the original Nushell config.'

    $TerminalHome = Join-Path $TestRoot 'terminal-opt-in'
    $env:APPDATA = Join-Path $TerminalHome 'AppData\Roaming'
    $env:LOCALAPPDATA = Join-Path $TerminalHome 'AppData\Local'
    $TerminalState = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'
    New-Item -ItemType Directory -Path $TerminalState -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $TerminalState 'settings.json') -Value '{"sentinel":true}'
    $DefaultPlan = & (Join-Path $RepositoryRoot 'install.ps1') -SourceRoot $RepositoryRoot -WhatIf 6>&1 | Out-String
    Assert-True (-not $DefaultPlan.Contains('windows-terminal')) 'Windows Terminal was selected by the default install.'
    Invoke-IsolatedInstaller -Home $TerminalHome -Only windows-terminal
    $TerminalText = Get-Content -LiteralPath (Join-Path $TerminalState 'settings.json') -Raw
    Assert-True (-not $TerminalText.Contains('sentinel')) 'Explicit Windows Terminal install did not replace settings.'

    $RemoteHome = Join-Path $TestRoot 'remote-home'
    $RemoteScript = Join-Path $TestRoot 'remote-install.ps1'
    New-Item -ItemType Directory -Path $RemoteHome -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $RepositoryRoot 'install.ps1') -Destination $RemoteScript
    $env:APPDATA = Join-Path $RemoteHome 'AppData\Roaming'
    $env:LOCALAPPDATA = Join-Path $RemoteHome 'AppData\Local'
    & $RemoteScript -WhatIf -Only nvim

    $BadRemoteScript = Join-Path $TestRoot 'remote-install-bad-hash.ps1'
    $RemoteText = Get-Content -LiteralPath $RemoteScript -Raw
    $RemoteText = $RemoteText.Replace(
        'd7a016fb6a4f91577234d616200fb266e6d5761b584cc55f1d7c70ecee457cf8',
        ('0' * 64)
    )
    Set-Content -LiteralPath $BadRemoteScript -Value $RemoteText
    $BadHashRejected = $false
    try { & $BadRemoteScript -WhatIf -Only nvim }
    catch { $BadHashRejected = $true }
    Assert-True $BadHashRejected 'Remote ZIP with an invalid checksum was accepted.'

    Write-Host 'Windows installer safety tests passed.' -ForegroundColor Green
}
finally {
    if (Test-Path -LiteralPath $TestRoot) {
        Remove-Item -LiteralPath $TestRoot -Recurse -Force
    }
}
