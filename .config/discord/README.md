# Discord themes

Vencord and BetterDiscord theme entrypoints retained for manual installation.

## Files

- `theme/shellcord.theme.css` is the preferred Shellcord theme. Its generated
  CSS import is pinned to a reviewed Shellcord commit.
- `theme/system24.theme.css` and `theme/flavors/` are vendored System24
  compatibility entrypoints. Their generated CSS import and GitHub-hosted
  assets are pinned to reviewed upstream commits.

These are distribution files, not a buildable Shellcord source tree. Make and
test source changes in the separate
[Shellcord repository](https://github.com/nihitdev/shellcord), then update the
pinned commit here after review.

## Manual installation

Copy the desired `.theme.css` file to the Vencord or BetterDiscord themes
directory and enable it in the client. The themes expect DM Mono to be installed
locally and fall back to the system monospace font.

## Updating pinned dependencies

Review upstream changes before replacing a full commit SHA. Run
`python3 .config/scripts/validate_repo.py` afterward; it rejects mutable GitHub branch
URLs in CSS files.
