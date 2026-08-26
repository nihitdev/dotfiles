# Theme distribution files

- `shellcord.theme.css` is the preferred Shellcord entrypoint.
- `system24.theme.css` and `flavors/system24-*.theme.css` are vendored upstream
  System24 compatibility entrypoints.

Remote GitHub CSS and assets are pinned to full commit SHAs. DM Mono is not
downloaded at runtime; install it locally or use the monospace fallback.

Update these files deliberately alongside [the vendoring notes](../../../VENDORED.md)
and run `python3 .config/scripts/validate_repo.py` before committing.
