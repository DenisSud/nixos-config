"""Best-effort reconstruction of edits made right after a commit.

While the corrections window is open the IBus engine keeps receiving every
key event for the focused client (it passes them through to the app).  We
replay the simple edits (typing, BackSpace, Delete) against a copy of the
committed text.  This is only a convenience for the dataset: the raw key
events are stored too, and the text is flagged unreliable as soon as the
cursor may have left the dictated segment (arrows, Home/End, selection,
Return, ...).

The numeric keyvals below are X11 values, which is what IBus uses.
"""

from __future__ import annotations

import time

KEY_BACKSPACE = 0xFF08
KEY_TAB = 0xFF09
KEY_RETURN = 0xFF0D
KEY_ESCAPE = 0xFF1B
KEY_HOME = 0xFF50
KEY_LEFT = 0xFF51
KEY_UP = 0xFF52
KEY_RIGHT = 0xFF53
KEY_DOWN = 0xFF54
KEY_END = 0xFF57
KEY_DELETE = 0xFFFF

# X11 modifier masks
MASK_SHIFT = 1 << 0
MASK_CONTROL = 1 << 2
MASK_MOD1 = 1 << 3
MASK_MOD4 = 1 << 6

_MODIFIER_KEYVALS = {
    0xFFE1,
    0xFFE2,
    0xFFE3,
    0xFFE4,
    0xFFE5,
    0xFFE6,
    0xFFE7,
    0xFFE8,
    0xFFE9,
    0xFFEA,
    0xFFEB,
    0xFFEC,
    0xFFED,
    0xFFEE,
}


class TextTracker:
    def __init__(self, text: str) -> None:
        self.initial = text
        self.chars: list[str] = list(text)
        self.cursor = len(self.chars)
        self.events: list[dict] = []
        self.reliable = True
        self.appended_chars = 0
        self.started = time.monotonic()

    # -- public API -----------------------------------------------------
    def feed(self, keyval: int, state: int, char: int) -> None:
        """Record one key event. ``char`` is IBus.keyval_to_unicode()."""
        mods = []
        if state & MASK_SHIFT:
            mods.append("shift")
        if state & MASK_CONTROL:
            mods.append("ctrl")
        if state & MASK_MOD1:
            mods.append("alt")
        if state & MASK_MOD4:
            mods.append("super")
        if len(self.events) < 500:
            self.events.append(
                {
                    "t": round((time.monotonic() - self.started) * 1000, 1),
                    "kv": keyval,
                    "ch": chr(char) if 32 <= char <= 0x10FFFF else None,
                    "m": "".join(m[0] for m in mods),
                }
            )

        if keyval in _MODIFIER_KEYVALS:
            return

        ctrl = bool(state & MASK_CONTROL)
        alt = bool(state & MASK_MOD1)
        super_ = bool(state & MASK_MOD4)

        if keyval == KEY_BACKSPACE:
            if ctrl:
                if self.cursor == 0:
                    self.reliable = False
                    return
                start = self.cursor
                while start > 0 and self.chars[start - 1].isspace():
                    start -= 1
                while start > 0 and not self.chars[start - 1].isspace():
                    start -= 1
                del self.chars[start : self.cursor]
                self.cursor = start
            else:
                if self.cursor == 0:
                    self.reliable = False
                else:
                    self.cursor -= 1
                    del self.chars[self.cursor]
            return

        if keyval == KEY_DELETE:
            if ctrl:
                self.reliable = False
                return
            if self.cursor >= len(self.chars):
                self.reliable = False
            else:
                del self.chars[self.cursor]
            return

        if keyval == KEY_LEFT:
            self.cursor = max(0, self.cursor - 1)
            return
        if keyval == KEY_RIGHT:
            self.cursor = min(len(self.chars), self.cursor + 1)
            return
        if keyval in (KEY_HOME, KEY_END, KEY_UP, KEY_DOWN, KEY_TAB, KEY_RETURN):
            # The cursor (or the application state) may leave our segment;
            # we cannot know the resulting buffer.
            self.reliable = False
            return
        if keyval == KEY_ESCAPE:
            self.reliable = False
            return

        if alt or super_ or ctrl:
            # Shortcuts (Ctrl+Z, Ctrl+V, ...) have unknown effects.
            self.reliable = False
            return

        if char and char >= 32 and char != 0x7F:
            ch = chr(char)
            self.chars.insert(self.cursor, ch)
            self.cursor += 1
            self.appended_chars += 1
            return

        # Compose/dead keys and anything else: unknown.
        self.reliable = False

    def final_text(self) -> str:
        return "".join(self.chars)

    def edited(self) -> bool:
        return self.final_text() != self.initial
