# system24 servers

An unofficial custom fork of refact0r/System24 for Discord. This fork keeps the original System24 structure and behavior where present, changes the server-list panel label from `nav` to `servers`, and includes a ready-to-use Catppuccin Mocha theme file.

## Description

Short description:

```text
A polished Catppuccin Mocha fork of System24 for Discord, with TUI-style panels and the server list labelled "servers".
```

Long description:

```text
system24 servers is an unofficial fork of refact0r/System24 using Catppuccin Mocha colors, DM Mono typography, rounded blurred panels, and a server-list panel label changed from "nav" to "servers". Built for Vencord and BetterDiscord.
```

## Screenshots

Screenshots coming soon.

## Installation

### Vencord

1. Open Vencord settings.
2. Go to Themes.
3. Add the raw theme URL:

```text
https://raw.githubusercontent.com/nihitdev/theme-fetch/main/theme/system24-servers.theme.css
```

### BetterDiscord

1. Download or copy `theme/system24-servers.theme.css`.
2. Place it in your BetterDiscord themes folder.
3. Enable `system24 servers (catppuccin mocha)` in BetterDiscord themes.

## Theme File

The ready-to-use theme file is:

```text
theme/system24-servers.theme.css
```

Before publishing, replace the hosted build import placeholder:

```css
@import url('https://raw.githubusercontent.com/nihitdev/theme-fetch/main/build/system24.css');
```

Use the raw.githubusercontent.com URL for this repository's built CSS. Do not use GitHub Pages for this fork unless you intentionally change the theme import yourself.

## Build

Install dependencies and build the generated CSS:

```sh
npm install
npm run build
```

The source label rule lives in:

```text
src/panel-labels.css
```

The generated build output is:

```text
build/system24.css
```

## Credits

Based on System24 by refact0r. This is an unofficial fork and is not affiliated with or endorsed by the original System24 project.

Catppuccin Mocha colors and Catppuccin assets are credited to the Catppuccin project.

## License

MIT. Preserve the upstream System24 license and attribution when distributing this fork. See `LICENSE`.
