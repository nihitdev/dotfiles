"""Kitty's required entrypoint for the tab implementation in tab.py."""

from runpy import run_path

from kitty.constants import config_dir


_tab = run_path(f"{config_dir}/tab.py")
draw_tab = _tab["draw_tab"]
