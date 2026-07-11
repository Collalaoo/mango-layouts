# Mango Layouts

A [Noctalia](https://noctalia.dev) v5 plugin for switching [MangoWM](https://mangowm.github.io) tiling layouts directly from your bar, with live visual previews and bidirectional IPC sync via `mmsg`.

## Features

- **Bar widget** — shows current layout name and icon; left-click cycles the 3 main layouts (Tiling → Scroller → Dwindle)
- **Preview panel** — 10 MangoWM layouts with animated previews; main 3 (Tiling, Scroller, Dwindle) shown by default, rest under a "More" toggle
- **Pulse animation** — active layout card pulses; non-active cards have smooth opacity
- **Bidirectional sync** — the plugin watches `mmsg -w` stream and polls `mmsg -g -l`; changing layout via keybind updates the widget instantly
- **Control Center shortcut** — toggle the panel from the quick settings
- **No QML/Quickshell** — pure Luau, runs in Noctalia v5's own plugin runtime

## Requirements

| Dependency | Purpose |
|---|---|
| [Noctalia](https://noctalia.dev) v5.0.0+ | Plugin host |
| [MangoWM](https://mangowm.github.io) | Wayland compositor |
| `mmsg` | IPC tool (ships with MangoWM) |

## Installation

```bash
# Via plugin manager (recommended)
noctalia plugin add Collalaoo/mango-layouts

# Or manually:
git clone https://github.com/Collalaoo/mango-layouts.git
mkdir -p ~/.local/share/noctalia/plugins/Collalaoo
cp -r mango-layouts ~/.local/share/noctalia/plugins/Collalaoo/
noctalia msg plugins reload
noctalia msg plugins enable Collalaoo/mango-layouts
```

Then add the widget to your bar:

```toml
# ~/.config/noctalia/config.toml
[bar.main]
# append "switcher" to start/center/end
end = ["...", "switcher"]
```

And optionally add the shortcut in **Settings → Control Center → Shortcuts**.

## Usage

| Action | Result |
|---|---|
| **Left click** on bar widget | Cycle: Tiling → Scroller → Dwindle (wraps) |
| **Right click** on bar widget | Open the Layout Switcher panel |
| **Click a card** in the panel | Switch to that layout immediately (Overview toggles overview mode) |
| **Control Center** tile | Toggle panel |

### Widget settings

Open **Settings → Plugins → Mango Layouts → Switcher**:

- **Show glyph** — toggle the layout icon in the bar

## Panel layout previews

The panel shows the 3 main layouts (Tiling, Scroller, Dwindle) by default, with a **More** toggle that reveals the remaining 7. Each card has a miniature animated preview built from `ui.box` primitives.

| Section | Layouts |
|---|---|
| **Main** (always visible) | Tiling, Scroller, Dwindle |
| **More** (toggled) | Grid, Fair, Deck, Center Tile, Right Tile, Monocle, Overview (toggle) |

The active layout card pulses with a smooth `sin()` opacity animation.

## How it works

```
MangoWM ──mmsg -w──→ service.luau ──state.set("layout")──→ widget.luau
                │                                                │
                └──mmsg -g -l (poll)──┘                          │
                                                                  ▼
                                                          panel.luau ◄── shortcut.luau
```

- `service.luau` runs `mmsg -w` in stream mode and polls `mmsg -g -l` every 3 seconds
- Normalises layout codes (`T`, `S`, `G`...) and full names (`tile`, `scroller`...) to canonical IDs
- All entries share state via `noctalia.state.*` — no crossing VM boundaries

## License

GPLv3. See [LICENSE](LICENSE).
