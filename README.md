# Windows dotfiles

[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-7-5391FE?logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/github/license/nihitdev/dotfiles)](LICENSE)

My personal Windows terminal and desktop setup: a Catppuccin-inspired environment built around PowerShell, Nushell, Windows Terminal, and modern command-line tools.

## What's included

| Configuration | Purpose |
| --- | --- |
| [Bat](bat/) | Syntax-highlighted file viewer and Catppuccin themes |
| [Cava](cava/) | Terminal audio visualizer |
| [Discord](discord/) | Shellcord/System24 Vencord themes and color flavors |
| [ExplorerBlurMica](explorerblurmica/) | Explorer backdrop customization |
| [Fastfetch](fastfetch/) | System information layout and custom ASCII art |
| [Nushell](nushell/) | Interactive shell settings, helpers, and aliases |
| [Oh My Posh](oh-my-posh/) | Prompt theme |
| [PowerShell](powershell/) | Profile, prompt startup, navigation, and CLI helpers |
| [Starship](starship/) | Cross-shell prompt configuration |
| [Windows Terminal](windows-terminal/) | Terminal profiles and appearance |
| [YASB](yasb/) | Status bar configuration and styles |

## Installation

These are personal configuration files, so review them before installing. Several files assume that the corresponding applications are already installed.

Install directly from PowerShell:

```powershell
irm https://raw.githubusercontent.com/nihitdev/dotfiles/main/install.ps1 | iex
```

Alternatively, clone the repository and run the installer locally:

```powershell
git clone https://github.com/nihitdev/dotfiles.git
cd dotfiles
Set-ExecutionPolicy -Scope Process Bypass
.\install.ps1
```

The installer copies the user-level configurations to their standard locations. Existing files are preserved in a timestamped backup directory unless you pass `-NoBackup`. Use `-WhatIf` to preview the changes.

```powershell
.\install.ps1 -WhatIf
.\install.ps1 -NoBackup
```

The main destinations are:

| Repository path | Typical destination |
| --- | --- |
| `powershell/profile.ps1` | `$PROFILE` |
| `nushell/config.nu` | Run `$nu.config-path` in Nushell to find it |
| `fastfetch/` | `~/.config/fastfetch/` |
| `oh-my-posh/amro.omp.json` | `~/.config/oh-my-posh/amro.omp.json` |
| `bat/config` | Run `bat --config-file` to find it |
| `bat/themes/` | Run `bat --config-dir` to find the theme directory |
| `cava/config` | `~/.config/cava/config` |
| `windows-terminal/settings.json` | Windows Terminal's LocalState directory |
| `yasb/` | `~/.config/yasb/` |

After adding Bat themes, run `bat cache --build`. Restart the relevant shell or application after installing a configuration.

> [!NOTE]
> The Windows Terminal settings can contain machine-specific profile identifiers. Merge the tracked settings with your existing file instead of replacing it blindly.

## Shell tooling

The PowerShell and Nushell profiles integrate with optional tools such as Fastfetch, Oh My Posh, Zoxide, Bat, Ripgrep, fd, eza, dust, bottom, gsudo, xh, doggo, procs, sd, Glow, and Yazi. Missing optional commands are handled gracefully.

## Look and feel

- Palette: Catppuccin Mocha
- Fonts: Nerd Font-compatible terminal fonts
- Terminal: Windows Terminal
- Prompt: Oh My Posh
- System information: Fastfetch
- Pager: Bat

## License

Licensed under the [MIT License](LICENSE).
