"""Themed, clickable tabs for kitty.

Kitty remains the source of truth for tab state.  This module only renders the
tab controls and adds a close-button hit target to kitty's native tab bar.
"""

from __future__ import annotations

from typing import Any

from kitty.fast_data_types import (
    GLFW_MOUSE_BUTTON_LEFT,
    GLFW_PRESS,
    GLFW_RELEASE,
    get_boss,
    set_tab_being_dragged,
)
from kitty.tab_bar import ExtraData, TabBarData, draw_tab_with_powerline
from kitty.tabs import TabManager


# Nerd Font / Material Design icons. Kitty's symbol-map fallback renders these
# even when the main terminal font does not contain them.
NEW_TAB_ICON = "󰐕"
CLOSE_TAB_ICON = "󰅖"


def draw_tab(
    draw_data: Any,
    screen: Any,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    """Draw compact rounded tabs with kitty's native powerline renderer."""
    if tab.tab_id < 0:
        tab = tab._replace(title=NEW_TAB_ICON)
    return draw_tab_with_powerline(
        draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data
    )


def _is_close_button(manager: TabManager, x: float, y: float, tab_id: int) -> bool:
    """Return whether a pointer event lands on a real tab's close icon."""
    bar = manager.tab_bar
    if tab_id <= 0 or not bar.laid_out_once:
        return False
    geometry = bar.window_geometry
    if not (geometry.left <= x < geometry.right and geometry.top <= y < geometry.bottom):
        return False
    cell_x = (int(x) - geometry.left) // bar.cell_width
    cell_y = (int(y) - geometry.top) // bar.cell_height
    for extent in bar.tab_extents:
        if extent.tab_id == tab_id and extent.contains(cell_x, cell_y):
            # The padded title template puts the close icon five cells before
            # the round cap. Include its neighboring padding for easy clicking.
            return extent.x.end - 6 <= cell_x <= extent.x.end - 4
    return False


_native_mouse_handler = getattr(
    TabManager.handle_tab_bar_mouse,
    "_native_tab_bar_mouse_handler",
    TabManager.handle_tab_bar_mouse,
)


def _handle_tab_bar_mouse(
    manager: TabManager,
    x: float,
    y: float,
    button: int,
    modifiers: int,
    action: int,
) -> None:
    """Close the pointed tab without first activating or disturbing another."""
    tab_id = manager.tab_bar.tab_id_at(int(x), int(y))
    if button == GLFW_MOUSE_BUTTON_LEFT and _is_close_button(manager, x, y, tab_id):
        if action == GLFW_PRESS:
            # Do not let a close-button press begin kitty's tab drag gesture.
            manager.recent_tab_bar_mouse_events.clear()
            set_tab_being_dragged()
            return
        if action == GLFW_RELEASE:
            tab = manager.tab_for_id(tab_id)
            if tab is not None:
                get_boss().close_tab(tab)
            manager.recent_tab_bar_mouse_events.clear()
            set_tab_being_dragged()
            return
    _native_mouse_handler(manager, x, y, button, modifiers, action)


def install() -> None:
    """Install or refresh the close-button adapter after a config reload."""
    _handle_tab_bar_mouse._clickable_close_buttons = True  # type: ignore[attr-defined]
    _handle_tab_bar_mouse._native_tab_bar_mouse_handler = _native_mouse_handler  # type: ignore[attr-defined]
    TabManager.handle_tab_bar_mouse = _handle_tab_bar_mouse


install()
