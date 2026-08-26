# Yazi configuration for Windows

A fast Windows-focused Yazi setup using Catppuccin Mocha, natural sorting,
Git status indicators, fuzzy navigation, content search, rendered Markdown,
and native image/PDF/video/archive previews.

This configuration targets Yazi `26.5.6` or newer in the same release line.

## Included packages

- `yazi-rs/flavors:catppuccin-mocha`
- `yazi-rs/plugins:git`
- `yazi-rs/plugins:smart-enter`
- `yazi-rs/plugins:piper`
- `yazi-rs/plugins:mime-ext`

The checked-in `plugins/` and `flavors/` directories make the configuration
usable immediately. `package.toml` remains the canonical package manifest.

## Requirements

Install Yazi and the tools used by its preview/search integrations:

```powershell
scoop install yazi fzf fd ripgrep jq 7zip file ffmpeg poppler imagemagick resvg chafa zoxide glow git lazygit
```

PowerShell 7, Windows Terminal, VS Code, and a Nerd Font are recommended.
Git for Windows supplies `sh.exe`, which the Markdown preview plugin uses.

Check the important commands:

```powershell
yazi --version
yazi --debug
Get-Command file, sh, glow, ffmpeg, pdftoppm, magick, resvg, 7z, fzf, fd, rg
```

## Installation

Yazi's Windows configuration directory is normally:

```text
%APPDATA%\yazi\config
```

Back up an existing configuration, copy this directory's contents, and install
the pinned packages:

```powershell
$destination = Join-Path $env:APPDATA 'yazi\config'
$backup = "$destination.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"

if (Test-Path -LiteralPath $destination) {
    Copy-Item -LiteralPath $destination -Destination $backup -Recurse
}

New-Item -ItemType Directory -Path $destination -Force | Out-Null
Copy-Item -Path .\yazi\* -Destination $destination -Recurse -Force
ya pkg install
```

If the repository itself is already open at `yazi\`, use `Copy-Item -Path .\*`
instead of `Copy-Item -Path .\yazi\*`.

Verify the detected paths and flavor:

```powershell
yazi --debug
ya pkg list
```

`yazi --debug` should list the five configuration files and show
`catppuccin-mocha` as the dark flavor.

## Important keys

| Key | Action |
| --- | --- |
| `f` | Fuzzy-jump with fzf |
| `F` | Filter the current directory |
| `/`, `?` | Find forward/backward |
| `s`, `g s` | Search filenames with fd |
| `S`, `g r` | Search file contents with ripgrep |
| `.` | Toggle hidden files |
| `l`, `Enter` | Enter a directory or open a file |
| `c p`, `c c` | Copy path |
| `g t` | Open PowerShell here in Windows Terminal |
| `g l` | Open lazygit here |
| `z` | Fuzzy jump |
| `Z` | Zoxide jump |

## If previews are blank

### 1. Reinstall the configured plugins

Run this first after copying the configuration:

```powershell
ya pkg install
ya pkg list
```

The list must include `mime-ext`, `piper`, `git`, `smart-enter`, and the
Catppuccin Mocha flavor.

### 2. Check MIME detection on Windows

Some Windows builds of `file.exe` do not support the `-L` option Yazi uses.
This was the cause of completely blank previews on the original machine.

Test it with:

```powershell
file -bL --mime-type .\yazi.toml
```

A working build prints something such as `text/plain`. A broken build prints
the `file.exe` usage screen or nothing. This configuration avoids that problem
with the official `mime-ext` plugin. Confirm that `yazi.toml` contains both
`mime-ext.local` and `mime-ext.remote` fetchers and that `init.lua` contains:

```lua
require("mime-ext.local"):setup {
	fallback_file1 = false,
}
```

Then reinstall packages and restart Yazi:

```powershell
Set-Location (Join-Path $env:APPDATA 'yazi\config')
ya pkg install
yazi --clear-cache --debug
```

The `Routine: file -bL --mime-type` line may remain blank with the incompatible
Scoop `file.exe`; previews should still work because `mime-ext` now performs
preview routing.

### 3. Check preview dependencies

```powershell
ffmpeg -version
pdftoppm -v
magick -version
resvg --version
7z
glow --version
sh --version
```

- Text and source files use Yazi's built-in syntax previewer.
- Markdown uses `piper` + `sh` + `glow`.
- PDF preview requires Poppler (`pdftoppm`).
- Video thumbnails require FFmpeg.
- SVG and uncommon image formats use `resvg` or ImageMagick.
- Archives use the non-standalone 7-Zip package.

### 4. Check the terminal

Image previews require a compatible terminal graphics protocol. Use a current
Windows Terminal release and start Yazi directly inside it:

```powershell
wt pwsh
yazi
```

`yazi --debug` should report Windows Terminal and a Sixel adapter. Text previews
do not require Sixel, so if text is also blank, return to the MIME/plugin checks.

### 5. Capture a Yazi debug log

```powershell
$env:YAZI_LOG = 'debug'
yazi
Get-Content (Join-Path $env:APPDATA 'yazi\state\yazi.log') -Tail 200
Remove-Item Env:YAZI_LOG
```

Inside Yazi, press `w` to open the task manager and inspect failed preview jobs.

## Updating

Update every plugin and flavor, then review the manifest changes:

```powershell
Set-Location (Join-Path $env:APPDATA 'yazi\config')
ya pkg upgrade
ya pkg list
```

After verifying the update, copy the updated `package.toml`, `plugins/`, and
`flavors/` back into this repository if vendored package files should remain
in sync.
