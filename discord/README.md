<div align="center">

# Shellcord

**A terminal-inspired Discord theme built for developers.**
[![License](https://img.shields.io/github/license/nihitdev/shellcord?style=flat-square&color=a6e3a1)](LICENSE)
[![Stars](https://img.shields.io/github/stars/nihitdev/shellcord?style=flat-square&color=f9e2af)](https://github.com/nihitdev/shellcord/stargazers)
[![CSS](https://img.shields.io/badge/built%20with-CSS-89b4fa?style=flat-square&logo=css&logoColor=white)](https://developer.mozilla.org/docs/Web/CSS)
[![Vencord](https://img.shields.io/badge/Vencord-compatible-cba6f7?style=flat-square)](https://vencord.dev/)
[![BetterDiscord](https://img.shields.io/badge/BetterDiscord-compatible-7289da?style=flat-square)](https://betterdiscord.app/)
[![CI](https://github.com/nihitdev/shellcord/actions/workflows/ci.yml/badge.svg)](https://github.com/nihitdev/shellcord/actions/workflows/ci.yml)

Modular customization · Catppuccin colors · Clean terminal aesthetic

![Shellcord preview](assets/preview.png)

</div>

## Features

- Terminal-inspired interface with TUI-style panel labels
- Catppuccin Mocha palette and DM Mono typography
- Rounded TUI-style panels with focused hover accents; transparency, blur, and rounding are configurable
- Optional ASCII titles, loaders, Spotify progress bar, and panel labels
- Modular CSS source files for straightforward customization
- Compatible with Vencord and BetterDiscord

## Installation

### Vencord

Open **Settings → Themes → Online Themes** and add:

```text
https://raw.githubusercontent.com/nihitdev/shellcord/main/theme/shellcord.theme.css
```

### BetterDiscord

1. Download [`shellcord.theme.css`](https://raw.githubusercontent.com/nihitdev/shellcord/main/theme/shellcord.theme.css).
2. Move it into your BetterDiscord themes folder.
3. Enable **Shellcord** from the Themes page.

## Customization

Open `theme/shellcord.theme.css` and adjust the variables near the top of the file. You can change typography, spacing, animations, window controls, blur, panel labels, ASCII styling, and the complete color palette without editing generated CSS.

Curated starting points are available in [`docs/PRESETS.md`](docs/PRESETS.md).

The inherited ASCII loader value remains `system24` for compatibility:

```css
body {
    --ascii-titles: on;
    --ascii-loader: system24;
    --panel-labels: on;
    --custom-spotify-bar: on;
}
```

## Development

```sh
git clone https://github.com/nihitdev/shellcord.git
cd shellcord
npm ci
npm run build
npm run check
```

Make changes in `src/` and run `npm run build` to regenerate `build/shellcord.css`. Do not edit the generated build directly.

For live desktop development, set `DEV_OUTPUT_PATH` in `.env` and run `npm run dev`. The browser injection workflow is documented in [`docs/BROWSER_DEV.md`](docs/BROWSER_DEV.md).

`theme/shellcord.theme.css` tracks the latest `main` build and is the edge
channel. For a rollback-friendly stable installation, download the
`shellcord.theme.css` asset from a tagged
[release](https://github.com/nihitdev/shellcord/releases).

## Quality and compatibility

- [`docs/VISUAL_QA.md`](docs/VISUAL_QA.md) — critical Discord surface matrix
- [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md) — supported clients and response policy
- [`docs/PROJECT_CHARTER.md`](docs/PROJECT_CHARTER.md) — product direction and ownership
- [`docs/METRICS.md`](docs/METRICS.md) — measurable success criteria
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — prioritized growth plan

## Project structure

```text
src/                       Shellcord source modules
theme/shellcord.theme.css  Installable theme and public variables
build/shellcord.css        Generated, committed CSS build
main.css                   Retained legacy compatibility snapshot; do not edit
scripts/theme.config.js    Build paths and source ordering
```

## Credits

Shellcord is based on [System24](https://github.com/refact0r/system24) by refact0r and inherits [midnight](https://github.com/refact0r/midnight-discord). It is not affiliated with or endorsed by either project. The color palette and related assets are credited to [Catppuccin](https://github.com/catppuccin/catppuccin).

## License

Distributed under the [MIT License](LICENSE). Preserve the upstream System24 license and attribution when redistributing this fork.
