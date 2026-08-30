# Nushell

Interactive Nushell settings, cached integrations, navigation helpers, and modern CLI wrappers.

Run `$nu.config-path` inside Nushell to find the active configuration directory, then copy `config.nu` and `dotfiles-init/` there. The bootstrap files make the first startup safe before Starship or Zoxide caches have been generated. Optional commands are detected at runtime, and elevation uses `sudo`.
