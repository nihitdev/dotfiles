# Nihit's Windows dotfiles

[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-7-5391FE?logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/github/license/nihitdev/dotfiles)](LICENSE)

My Catppuccin-inspired Windows setup for PowerShell, Nushell, Windows Terminal, Discord, OneCommander, and modern command-line tools, plus a manual Linux setup for Zsh.

## Quick install

Open PowerShell and run:

```powershell
irm https://nihit.is-a.dev/ricingsetup | iex
```

The installer backs up existing files to `~/.dotfiles-backup/<timestamp>` before applying the configurations. Applications and command-line tools are not installed automatically.

## What's included

| Configuration | Purpose |
| --- | --- |
| [Bat](bat/) | Syntax-highlighted file viewer and Catppuccin themes |
| [Cava](cava/) | Terminal audio visualizer |
| [Discord](discord/) | Shellcord/System24 Vencord themes and color flavors |
| [ExplorerBlurMica](explorerblurmica/) | Explorer backdrop customization |
| [Fastfetch](fastfetch/) | System information layout and custom ASCII art |
| [Nushell](nushell/) | Interactive shell settings, helpers, and aliases |
| [Neovim](nvim/) | LazyVim-based editor configuration with Catppuccin and Copilot |
| [Oh My Zsh](oh-my-zsh/) | Manual Linux Zsh configuration and plugins |
| [OneCommander](one-commander/) | Catppuccin Mocha file manager theme |
| [Oh My Posh](oh-my-posh/) | Custom prompt theme and shell integration |
| [Powerlevel10k](powerlevel10k/) | Powerlevel10k prompt configuration for Zsh |
| [PowerShell](powershell/) | Profile, prompt startup, navigation, and CLI helpers |
| [Starship](starship/) | Optional minimal cross-shell prompt |
| [Windows Terminal](windows-terminal/) | Terminal profiles and appearance |
| [YASB](yasb/) | Status bar configuration and styles |

## Prompt options

This repository includes three prompt configurations:

- **Oh My Posh** — the default PowerShell prompt, using the tracked `amro.omp.json` theme.
- **Starship** — an optional minimal two-line prompt with directory and Git information. Its configuration is available in `starship/starship.toml`.
- **Powerlevel10k (p10k)** — the Zsh prompt used by `oh-my-zsh/.zshrc`, with its prompt settings tracked separately in `powerlevel10k/.p10k.zsh`.

All three require a [Nerd Font](https://www.nerdfonts.com/) for their icons to render correctly.

## Manual installation

If you prefer to inspect everything before running it, clone the repository:

```powershell
git clone https://github.com/nihitdev/dotfiles.git
cd dotfiles
Set-ExecutionPolicy -Scope Process Bypass
.\install.ps1
```

Preview the changes without writing anything, or skip backups if you already have your own:

```powershell
.\install.ps1 -WhatIf
.\install.ps1 -NoBackup
```

The main destinations are:

| Repository path | Typical destination |
| --- | --- |
| `powershell/profile.ps1` | `$PROFILE` |
| `nushell/config.nu` | Run `$nu.config-path` in Nushell to find it |
| `nvim/` | `%LOCALAPPDATA%\nvim\` |
| `one-commander/Catppuccin-Mocha.xaml` | `%LOCALAPPDATA%\OneCommander\Themes\Dark\Catppuccin-Mocha.xaml` |
| `fastfetch/` | `~/.config/fastfetch/` |
| `oh-my-posh/amro.omp.json` | `~/.config/oh-my-posh/amro.omp.json` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `bat/config` | Run `bat --config-file` to find it |
| `bat/themes/` | Run `bat --config-dir` to find the theme directory |
| `cava/config` | `~/.config/cava/config` |
| `windows-terminal/settings.json` | Windows Terminal's LocalState directory |
| `yasb/` | `~/.config/yasb/` |

The installer rebuilds the Bat theme cache when Bat is available. Restart your shells and configured applications after installation.

### Oh My Zsh and Powerlevel10k (Linux)

> [!IMPORTANT]
> This configuration is for Linux and is not installed by the Windows `install.ps1` script or the quick-install command above.

After installing Zsh and [Oh My Zsh](https://ohmyz.sh/), clone [Powerlevel10k](https://github.com/romkatv/powerlevel10k) into the Oh My Zsh custom themes directory:

```sh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

The tracked Zsh configuration also enables [`zsh-autosuggestions`](https://github.com/zsh-users/zsh-autosuggestions) and [`zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting); install those plugins in the Oh My Zsh custom plugins directory before starting Zsh. Then copy the configuration files:

```sh
cp oh-my-zsh/.zshrc ~/.zshrc
cp powerlevel10k/.p10k.zsh ~/.p10k.zsh
exec zsh
```

Use a [Nerd Font](https://www.nerdfonts.com/) so the Powerlevel10k icons render correctly.

### OneCommander theme

The installer applies this theme automatically. For a manual installation, copy it to OneCommander's dark-theme directory:

```powershell
$themeDirectory = Join-Path $env:LOCALAPPDATA 'OneCommander\Themes\Dark'
New-Item -ItemType Directory -Force -Path $themeDirectory | Out-Null
Copy-Item '.\one-commander\Catppuccin-Mocha.xaml' -Destination $themeDirectory -Force
```

Restart OneCommander, open **Settings**, select **Theme**, and choose **Catppuccin Mocha** from the dark themes.

> [!NOTE]
> Windows Terminal settings can contain machine-specific profile identifiers. The installer backs up your existing settings before replacing them, so review the tracked file first if you have custom profiles.

## Shell tooling

The PowerShell and Nushell profiles integrate with optional tools such as Fastfetch, Oh My Posh, Zoxide, Bat, Ripgrep, fd, eza, dust, bottom, gsudo, xh, doggo, procs, sd, Glow, and Yazi. Missing optional commands are handled gracefully.

## Look and feel

- Palette: Catppuccin Mocha
- Fonts: Nerd Font-compatible terminal fonts
- Terminal: Windows Terminal
- Prompts: Oh My Posh, Starship, and Powerlevel10k
- System information: Fastfetch
- Pager: Bat

## License

Licensed under the [GNU General Public License v3.0](LICENSE).

Copyright (C) 2026 nihit_dev.
