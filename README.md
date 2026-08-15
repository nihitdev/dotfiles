# Nihit's Windows dotfiles

[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-7-5391FE?logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/github/license/nihitdev/dotfiles)](LICENSE)

My Catppuccin-inspired Windows setup for PowerShell, Nushell, Windows Terminal, Neovim, Git, terminal file managers, and modern command-line tools, plus a manual Linux setup for Zsh.

## Quick install

Open PowerShell and run:

```powershell
irm https://nihit.is-a.dev/ricingsetup | iex
```

The installer backs up existing files to `~/.dotfiles-backup/<timestamp>` before applying the configurations. Applications and command-line tools are not installed automatically.

## What's included

| Configuration | Purpose |
| --- | --- |
| [Atuin](atuin/) | Searchable and synchronized shell history with a Catppuccin theme |
| [Bat](bat/) | Syntax-highlighted file viewer and Catppuccin themes |
| [Broot](broot/) | Tree-based file navigation with custom verbs and a Catppuccin Mocha skin |
| [Cava](cava/) | Terminal audio visualizer |
| [Discord](discord/) | Shellcord/System24 Vencord themes and color flavors |
| [ExplorerBlurMica](explorerblurmica/) | Explorer backdrop customization |
| [Fastfetch](fastfetch/) | System information layout and custom ASCII art |
| [Git](git/) | Global Git behavior, concise aliases, and Catppuccin-styled Delta diffs |
| [LazyGit](lazygit/) | Catppuccin Mocha terminal Git UI theme |
| [Neovim](nvim/) | LazyVim setup, pinned plugins, and a custom dashboard |
| [Nushell](nushell/) | Interactive shell settings, helpers, and aliases |
| [Oh My Zsh](oh-my-zsh/) | Manual Linux Zsh configuration and plugins |
| [OneCommander](one-commander/) | Catppuccin Mocha file manager theme |
| [Oh My Posh](oh-my-posh/) | Custom prompt theme and shell integration |
| [Powerlevel10k](powerlevel10k/) | Powerlevel10k prompt configuration for Zsh |
| [PowerShell](powershell/) | Profile, prompt startup, navigation, and CLI helpers |
| [SSH](ssh/) | Host aliases and isolated authentication-key paths for GitHub and the AUR |
| [Starship](starship/) | Optional minimal cross-shell prompt |
| [Windows Terminal](windows-terminal/) | Terminal profiles and appearance |
| [YASB](yasb/) | Status bar configuration and styles |
| [Yazi](yazi/) | Fast terminal file manager with previews, search, Git status, and Catppuccin Mocha |

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
| `git/.gitconfig` | `~/.gitconfig` |
| `lazygit/config.yml` | `%LOCALAPPDATA%\lazygit\config.yml` |
| `broot/` | `%APPDATA%\dystroy\broot\config\` |
| `nvim/` | `%LOCALAPPDATA%\nvim\` |
| `yazi/` | `%APPDATA%\yazi\config\` |
| `one-commander/Catppuccin-Mocha.xaml` | `%LOCALAPPDATA%\OneCommander\Themes\Dark\Catppuccin-Mocha.xaml` |
| `fastfetch/` | `~/.config/fastfetch/` |
| `oh-my-posh/amro.omp.json` | `~/.config/oh-my-posh/amro.omp.json` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `atuin/config.toml` | `~/.config/atuin/config.toml` |
| `bat/config` | Run `bat --config-file` to find it |
| `bat/themes/` | Run `bat --config-dir` to find the theme directory |
| `cava/config` | `~/.config/cava/config` |
| `ssh/config` | `~/.ssh/config` (manual installation) |
| `windows-terminal/settings.json` | Windows Terminal's LocalState directory |
| `yasb/` | `~/.config/yasb/` |

The installer backs up every existing destination, copies all Windows configurations above, corrects the Vencord theme destination, and rebuilds the Bat theme cache when Bat is available. Restart your shells and configured applications after installation.

### Developer tools

- **Git and Delta:** the tracked global config uses histogram diffs, `zdiff3` conflicts, safe pruning, reusable conflict resolutions, eight focused aliases, and a subtle Catppuccin Mocha Delta presentation. It keeps Windows `autocrlf = true` and uses placeholder identity values that you should replace after installation.
- **LazyGit:** the theme is installed into LazyGit's standard Windows configuration directory.
- **Neovim:** the complete LazyVim configuration and lockfile are installed to Neovim's standard Windows config directory. Start `nvim` after installation to let `lazy.nvim` restore pinned plugins.
- **Yazi:** the full configuration and vendored packages are installed. Run `ya pkg install` after installation whenever you want to verify or restore the package payload from `package.toml`.
- **Broot:** `conf.hjson`, `verbs.hjson`, and the Catppuccin skin are installed together so custom verbs and theming remain in sync.

ExplorerBlurMica remains a manual copy because its `config.ini` must live beside the particular ExplorerBlurMica installation, whose directory varies by package manager. Copy `explorerblurmica/config.ini` over the application's existing `config.ini` after backing it up.

### Atuin

After installing Atuin, set it up manually in PowerShell with these exact steps:

1. Initialize Atuin in your shell by adding this line to your PowerShell profile (`$PROFILE`):

   ```powershell
   atuin init powershell | Out-String | Invoke-Expression
   ```

2. Create Atuin's configuration directory and copy the tracked configuration into it:

   ```powershell
   New-Item -ItemType Directory -Force -Path "$HOME\.config\atuin" | Out-Null
   Copy-Item '.\atuin\config.toml' -Destination "$HOME\.config\atuin\config.toml" -Force
   ```

The tracked PowerShell profile already performs step 1 when Atuin is available, and `install.ps1` performs step 2 automatically.

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

The PowerShell and Nushell profiles integrate with optional tools such as Fastfetch, Oh My Posh, Zoxide, Atuin, Bat, Ripgrep, fd, eza, dust, bottom, gsudo, xh, doggo, procs, sd, Glow, Yazi, Broot, LazyGit, GitHub CLI, and Neovim. Missing optional commands are handled gracefully.

## Look and feel

- Palette: Catppuccin Mocha
- Fonts: Nerd Font-compatible terminal fonts
- Terminal: Windows Terminal
- Prompts: Oh My Posh, Starship, and Powerlevel10k
- System information: Fastfetch
- Pagers: Delta for Git, Bat for files

## License

Licensed under the [GNU General Public License v3.0](LICENSE).

Copyright (C) 2026 nihit_dev.
