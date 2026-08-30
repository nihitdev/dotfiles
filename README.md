# Kairo

[![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?logo=archlinux&logoColor=white)](https://archlinux.org/)
[![Website](https://img.shields.io/badge/Website-get--kairo.vercel.app-cba6f7)](https://get-kairo.vercel.app)
[![License](https://img.shields.io/github/license/nihitdev/dotfiles)](LICENSE)

An Arch-first, Catppuccin-inspired environment for Bash, Fish, Nushell, Zsh, Kitty, Hyprland, Neovim, Git, Yazi, and modern command-line tools.

**[Explore Kairo →](https://get-kairo.vercel.app)**

## Installation

Quick install directly from GitHub:

```sh
curl -fsSL https://raw.githubusercontent.com/nihitdev/dotfiles/main/install.sh | bash
```

The piped installer automatically uses plain non-interactive output and downloads the pinned, SHA-256-verified repository archive.

Clone the repository and run the transactional installer:

```sh
git clone https://github.com/nihitdev/dotfiles.git
cd dotfiles
./install.sh
```

On a terminal, `./install.sh` opens Kairo's dependency-free full-screen installer. It detects the system, lets you select modules with the keyboard, reviews packages and replacement targets, then shows real installation stages and results. Small terminals use a compact layout. Pipes, redirected output, explicit `--only` selections, and `CI=true` automatically use deterministic plain output.

Preview changes or select individual components:

```sh
./install.sh --dry-run
./install.sh --only bash --only starship
./install.sh --only nvim --only yazi
./install.sh --only all
./install.sh --install-packages
./install.sh --profile core-build --profile rust --profile python
```

The installer supports `bash`, `fish`, `nushell`, `zsh`, `starship`, `atuin`, `bat`, `broot`, `yazi`, `lazygit`, `fastfetch`, `git`, `nvim`, `kitty`, `cava`, `ssh`, `oh-my-posh`, and opt-in `hypr`. It backs up existing destinations under private, uniquely named `~/.dotfiles-backup/YYYYMMDD-HHMMSS.xxxxxx/` directories, stages replacements before activation, rolls back failed transactions, and rejects unsafe or escaping paths. Unchanged payloads are reported as already current.

`--install-packages` installs only missing packages needed by selected modules. Official packages are grouped into one `sudo pacman -S --needed` call. AUR packages use Paru by default, or Yay with `--aur-helper yay`, without `sudo`; Kairo refuses to invoke an AUR helper as root and never performs a surprise full-system upgrade. If the selected helper is missing, Kairo installs `base-devel` and Git, clones its official AUR PKGBUILD, and builds it as the current user. Without the flag, missing tools are reported but dotfile installation continues.

Optional package profiles turn Kairo into a broader workstation bootstrapper without forcing unrelated packages:

| Profile | Includes |
| --- | --- |
| `core-build` | `base-devel`, Git, curl, rsync, archives, jq, ShellCheck |
| `cpp` | GCC, Clang, CMake, Ninja, Meson, GDB, LLDB |
| `rust` | Rustup |
| `python` | Python, pip, uv |
| `web` | Node.js, npm, pnpm, Bun |
| `containers` | Docker, Docker Compose, Podman, Buildah |
| `wayland` | Portal, clipboard, screenshots, brightness, media controls, DDC |
| `media` | PipeWire, WirePlumber, FFmpeg, ImageMagick, yt-dlp |

Repeat `--profile` to combine profiles. The interactive installer exposes the same choices on a separate package-profile screen.
Use `--profile all` to select every package profile.

Chaotic-AUR is an optional third-party binary repository. Enable it only after reviewing the trust change:

```sh
./install.sh --dry-run --enable-chaotic-aur --profile web
./install.sh --enable-chaotic-aur --profile web
```

Kairo follows [Chaotic-AUR's published setup](https://github.com/chaotic-aur): imports and locally signs its primary key, installs its signed keyring and mirrorlist packages, backs up `/etc/pacman.conf`, appends the repository idempotently, and synchronizes package databases. It restores `pacman.conf` if the installation subsequently fails.

The interactive flow offers package installation when selected tools are missing. When Fish is selected, it also makes Fish the login shell after verifying its path is listed in `/etc/shells`. Automated and explicit `--only` runs do not change the login shell.

## Repository layout

```text
dotfiles/
├── .config/
│   ├── bash/
│   ├── fish/
│   ├── hypr/
│   ├── kitty/
│   ├── nushell/
│   ├── nvim/
│   ├── starship/
│   │   ├── bash.toml
│   │   ├── fish.toml
│   │   ├── nushell.toml
│   │   └── zsh.toml
│   └── yazi/
├── install.sh
├── LICENSE
└── VENDORED.md
```

| Configuration | Purpose |
| --- | --- |
| [Atuin](.config/atuin/) | Searchable shell history with Catppuccin colors |
| [Bash](.config/bash/) | Interactive Bash setup with Starship, Zoxide, and Atuin |
| [Bat](.config/bat/) | Syntax-highlighted file viewer and Catppuccin themes |
| [Broot](.config/broot/) | Tree navigation, custom verbs, and Catppuccin skin |
| [Cava](.config/cava/) | Terminal audio visualizer |
| [Fastfetch](.config/fastfetch/) | System information layout and custom Arch artwork |
| [Fish](.config/fish/) | Fish shell environment and integrations |
| [Git](.config/git/) | Linux Git defaults, aliases, and Delta styling |
| [Hyprland](.config/hypr/) | Arch/Hyprland configuration available as an opt-in module |
| [Kitty](.config/kitty/) | Kitty terminal configuration |
| [LazyGit](.config/lazygit/) | Catppuccin LazyGit theme |
| [Neovim](.config/nvim/) | LazyVim setup with pinned plugins |
| [Nushell](.config/nushell/) | Nushell settings, helpers, and cached integrations |
| [Oh My Posh](.config/oh-my-posh/) | Optional prompt theme |
| [Oh My Zsh](.config/oh-my-zsh/) | Zsh configuration and plugins |
| [SSH](.config/ssh/) | Managed SSH include with GitHub and AUR hosts |
| [Starship](.config/starship/) | Per-shell prompt configurations |
| [Yazi](.config/yazi/) | Terminal file manager configuration and plugins |

Third-party snapshots and intentionally duplicated assets are documented in [VENDORED.md](VENDORED.md).

## Starship

One Starship binary is shared by all shells, while each shell selects its own configuration through `STARSHIP_CONFIG`:

```text
~/.config/starship/
├── bash.toml
├── fish.toml
├── nushell.toml
└── zsh.toml
```

The tracked Bash, Fish, Nushell, and Zsh configurations already point to their matching file. Install Starship on Arch with:

```sh
sudo pacman -S starship
```

## Arch setup notes

Package installation is optional. Preview both package and dotfile actions safely with:

```sh
./install.sh --dry-run --install-packages --only fish --only starship
```

The Zsh configuration expects Oh My Zsh plus `zsh-autosuggestions` and `zsh-syntax-highlighting`. All prompt configurations work best with a Nerd Font.

Hyprland is not selected by default because replacing compositor configuration can disrupt an active graphical session. Review it first, then install it explicitly:

```sh
./install.sh --dry-run --only hypr
./install.sh --only hypr
```

Kairo backs up an existing `~/.config/hypr` directory before replacing it.

## Remote bootstrap

The quick-install command above uses plain output. Its downloaded repository archive is pinned to an immutable commit and verified with SHA-256 before extraction; checksum verification is never bypassed.

## Validation

```sh
bash -n install.sh
./install.sh --dry-run
./install.sh --dry-run --only starship
python3 .config/scripts/validate_repo.py
./.config/tests/test-install.sh
```

## License

See [LICENSE](LICENSE).
