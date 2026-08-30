<div align="center">

# Kairo

### Arch, composed.

A safe, interactive installer for an Arch Linux, Hyprland, and CLI-first workstation.

[![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?logo=archlinux&logoColor=white)](https://archlinux.org/)
[![Website](https://img.shields.io/badge/Website-get--kairo.vercel.app-cba6f7)](https://get-kairo.vercel.app)
[![Shell](https://img.shields.io/badge/Installer-Bash-a6e3a1?logo=gnubash&logoColor=11111b)](install.sh)
[![License](https://img.shields.io/github/license/nihitdev/kairo)](LICENSE)

[Website](https://get-kairo.vercel.app) · [Quick start](#quick-start) · [Modules](#included-configurations) · [Safety](#safety-first)

</div>

Kairo turns a fresh Arch installation into a focused development environment without treating your home directory like a blank canvas. It combines curated dotfiles, optional package installation, developer toolchains, GPU detection, and a dependency-free terminal UI with transactional replacement and rollback.

## Highlights

- Full-screen interactive installer built with Bash and standard terminal sequences
- Arch-first package management with `pacman`, plus optional Paru or Yay support
- Selectable dotfile modules and independent developer toolchain profiles
- Intel, AMD, and NVIDIA GPU detection with reviewed driver proposals
- Private backups, staged replacements, path validation, and transaction rollback
- Deterministic plain output for CI, pipes, remote bootstrap, and automation
- Separate Starship configuration for Bash, Fish, Nushell, and Zsh
- Fish login-shell setup after a successful interactive installation

## Quick start

Clone the repository for the complete interactive experience:

```sh
git clone https://github.com/nihitdev/kairo.git
cd kairo
./install.sh
```

Start with a zero-write preview if you want to inspect every action first:

```sh
./install.sh --dry-run
```

For a plain remote bootstrap:

```sh
curl -fsSL https://raw.githubusercontent.com/nihitdev/kairo/main/install.sh | bash
```

The remote entry point downloads an immutable repository archive and verifies its SHA-256 checksum before use. Because piped input is not a terminal, it automatically uses deterministic non-interactive output.

## Installer experience

Running `./install.sh` in a terminal opens a guided flow:

```text
Welcome → Detect → Dependencies → Modules → Review
        → Backup → Packages → Dotfiles → Configure → Validate → Complete
```

Kairo shows the detected distribution, architecture, shell, display session, package tools, service manager, and configuration root. Before changing anything, the review screen lists selected modules, missing packages, replacement targets, and backup behavior.

### Controls

| Key | Action |
| --- | --- |
| `↑` / `↓` or `J` / `K` | Move through choices |
| `Space` | Toggle the focused item |
| `A` | Select all |
| `N` | Select none |
| `Enter` | Continue |
| `Q` or `Esc` | Cancel safely |

Mouse escape sequences are consumed safely and scrolling does not terminate the installer. Small terminals use a compact layout. The cursor, alternate screen, input mode, and terminal state are restored after success, failure, cancellation, `SIGINT`, or `SIGTERM`.

Animations are automatically disabled when output is redirected, stdout is not a TTY, or `CI=true`.

## Useful commands

```sh
# Preview one module
./install.sh --dry-run --only starship

# Install several modules
./install.sh --only yazi --only broot --only starship

# Install every supported dotfile module
./install.sh --only all

# Install missing packages for the selected modules
./install.sh --install-packages --only nvim --only yazi

# Add developer toolchains
./install.sh --install-packages --profile core-build --profile rust --profile web

# Select Yay instead of the default Paru helper
./install.sh --install-packages --aur-helper yay

# Review and install detected GPU drivers
./install.sh --install-packages --install-gpu-drivers

# Disable backup creation explicitly
./install.sh --no-backup --only starship
```

Run `./install.sh --help` for the authoritative option and component list.

## Included configurations

| Area | Modules |
| --- | --- |
| Shells | [Bash](.config/bash/), [Fish](.config/fish/), [Nushell](.config/nushell/), [Zsh + Oh My Zsh](.config/oh-my-zsh/) |
| Prompt and history | [Starship](.config/starship/), [Atuin](.config/atuin/), [Oh My Posh](.config/oh-my-posh/) |
| CLI workflow | [Bat](.config/bat/), [Broot](.config/broot/), [Yazi](.config/yazi/), [LazyGit](.config/lazygit/), [Fastfetch](.config/fastfetch/), [Cava](.config/cava/) |
| Development | [Git](.config/git/), [Neovim](.config/nvim/), [SSH](.config/ssh/) |
| Desktop | [Kitty](.config/kitty/), [Hyprland](.config/hypr/) |

Hyprland is opt-in because replacing a compositor configuration can disrupt an active session. Preview it before installation:

```sh
./install.sh --dry-run --only hypr
```

Third-party snapshots and intentionally duplicated assets are documented in [VENDORED.md](VENDORED.md).

## Developer toolchains

Profiles install workstation packages independently from dotfile modules. Repeat `--profile` to combine them or use `--profile all`.

| Profile | Included tools |
| --- | --- |
| `core-build` | Base development tools, Git, curl, rsync, archives, jq, ShellCheck |
| `cpp` | GCC, Clang, CMake, Ninja, Meson, GDB, LLDB |
| `rust` | Rustup |
| `python` | Python, pip, uv |
| `web` | Node.js, npm, pnpm, Bun |
| `containers` | Docker, Docker Compose, Podman, Buildah |
| `wayland` | Portal, clipboard, screenshots, brightness, media, and DDC tools |
| `media` | PipeWire, WirePlumber, FFmpeg, ImageMagick, yt-dlp |

## Package management

Package installation is always opt-in through `--install-packages` or the interactive review. Kairo checks what is already present and installs only packages needed by the selected modules and profiles.

- Official packages are grouped into `sudo pacman -S --needed ...`.
- AUR packages use Paru by default or Yay with `--aur-helper yay`.
- AUR helpers are never run through `sudo` or as root.
- A missing helper is bootstrapped from its official AUR PKGBUILD as the current user.
- Kairo never performs a surprise full-system upgrade.

When privileged work is selected, interactive mode requests and validates sudo access after review and before filesystem changes begin.

### Chaotic-AUR

[Chaotic-AUR](https://github.com/chaotic-aur) is an optional third-party repository and a separate trust decision:

```sh
./install.sh --dry-run --enable-chaotic-aur --profile web
./install.sh --enable-chaotic-aur --profile web
```

Kairo imports and locally signs the published key, installs the signed keyring and mirror list, backs up `/etc/pacman.conf`, and adds the repository idempotently. If the later transaction fails, the original Pacman configuration is restored.

## GPU drivers

With `--install-gpu-drivers`, Kairo inspects graphics controllers and proposes an Arch package set for review:

| Detected hardware | Proposed stack |
| --- | --- |
| AMD | Mesa and RADV Vulkan |
| Intel | Mesa, Intel Vulkan, and Intel media drivers |
| Modern NVIDIA | Open kernel modules, utilities, VA-API bridge, and matching installed-kernel headers |

Mixed Intel/AMD systems receive both applicable userspace stacks. Unclassified or legacy NVIDIA hardware produces a warning instead of guessing. Kairo does not generate an Xorg configuration or require Hyprland to be running.

## Per-shell Starship

One Starship binary is shared across all shells, while `STARSHIP_CONFIG` selects a shell-specific configuration:

```text
~/.config/starship/
├── bash.toml       # Bash
├── fish.toml       # Fish
├── nushell.toml    # Nushell
└── zsh.toml        # Zsh
```

The installer manages the complete directory; Kairo does not use a single prompt file at the configuration root.

## Safety first

Kairo preserves the existing installer’s transactional design:

- Existing destinations are backed up under private, unique `~/.dotfiles-backup/YYYYMMDD-HHMMSS.xxxxxx/` directories.
- Replacement payloads are staged before activation.
- A failed operation restores replaced destinations and removes newly created partial targets.
- Destinations outside the home directory, traversal paths, symlink escapes, `/`, `$HOME`, and the configuration root itself are rejected.
- `--dry-run` performs no writes, package changes, plugin installation, shell changes, or cache mutation.
- Repeated installation is safe: unchanged payloads are retained and Git/SSH includes are not duplicated.
- Git identity, signing, credentials, personal SSH material, `known_hosts`, and `authorized_keys` are not overwritten.

`--no-backup` disables backup creation but does not disable staging, destination safety, or rollback handling.

## Repository map

```text
dotfiles/
├── .config/
│   ├── bash/                 # Managed Bash configuration
│   ├── fish/                 # Fish configuration and integrations
│   ├── nushell/              # Nushell configuration and startup files
│   ├── oh-my-zsh/            # Zsh + Oh My Zsh configuration
│   ├── starship/             # Four shell-specific prompt configs
│   ├── scripts/
│   │   ├── install-ui.sh     # Dependency-free terminal UI
│   │   └── validate_repo.py  # Repository validation
│   └── tests/                # Linux installer tests
├── site/                     # Vite + Tailwind CSS website
├── install.sh                # Main installer and remote entry point
├── VENDORED.md
└── LICENSE
```

## Website development

The website at [get-kairo.vercel.app](https://get-kairo.vercel.app) lives in [`site/`](site/) and uses Vite with Tailwind CSS v4.

```sh
cd site
bun install
bun run dev
bun run build
```

pnpm is also supported:

```sh
pnpm install
pnpm dev
pnpm build
```

## Validation

```sh
bash -n install.sh
bash -n .config/scripts/install-ui.sh
./install.sh --dry-run
./install.sh --dry-run --only starship
./install.sh --dry-run --only yazi --only broot --only starship
python3 .config/scripts/validate_repo.py
./.config/tests/test-install.sh
```

The Linux test suite covers normal and repeated installation, dry-run immutability, component selection, backup and no-backup modes, Git and SSH include deduplication, shell-specific Starship paths, rollback, remote bootstrap, non-interactive execution, and terminal input handling.

## License

Released under the terms in [LICENSE](LICENSE).
