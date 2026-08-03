# Theme distribution files

- `shellcord.theme.css` is the supported Shellcord installer and public
  customization API.
- `system24.theme.css` and `flavors/system24-*.theme.css` are preserved upstream
  System24 compatibility copies. Their branding, import URLs, and defaults are
  intentionally not synchronized with Shellcord.

Shellcord source changes belong in `src/`. Run `npm run build` to regenerate the
committed build. Do not edit `build/shellcord.css` directly.

The normal online installer tracks `main` and is the edge channel. Tagged GitHub
releases provide a stable installer whose build import is pinned to the tag.
