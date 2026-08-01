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
| [Scoop](scoop/) | Exported package inventory |
| [Windows Terminal](windows-terminal/) | Terminal profiles and appearance |
| [YASB](yasb/) | Status bar configuration and styles |

## Installation

These are personal configuration files, so review them before copying or linking them. Several files assume that the corresponding applications are already installed.

```powershell
git clone https://github.com/nihitdev/dotfiles.git
cd dotfiles
```

Copy the configurations you want to the locations used by each application:

| Repository path | Typical destination |
| --- | --- |
| `powershell/profile.ps1` | `$PROFILE` |
| `nushell/config.nu` | Run `$nu.config-path` in Nushell to find it |
| `fastfetch/` | `~/.config/fastfetch/` |
| `oh-my-posh/pure.omp.json` | `~/.config/oh-my-posh/pure.omp.json` |
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

The complete Scoop export is available in [`scoop/packages.json`](scoop/packages.json). Restore only the packages you need rather than treating the export as a required dependency list.

## Look and feel

- Palette: Catppuccin Mocha
- Fonts: Nerd Font-compatible terminal fonts
- Terminal: Windows Terminal
- Prompt: Oh My Posh
- System information: Fastfetch
- Pager: Bat

## License

Licensed under the [MIT License](LICENSE).
