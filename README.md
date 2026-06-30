# Mango Layouts

A [Noctalia](https://noctalia.dev) v5 plugin for switching [MangoWM](https://mangowm.github.io) tiling layouts directly from your bar, with live visual previews and bidirectional IPC sync via `mmsg`.

## Features

- **Bar widget** — shows current layout name and icon, cycles on click
- **Preview panel** — 15 tiling layouts with visual previews (Tile, Scroller, Grid, Monocle, Deck, Center Tile, etc.)
- **Pulse animation** — active layout card pulses gently so you instantly spot the current mode
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
# Clone the plugin
git clone https://github.com/Collalaoo/mango-layouts.git
mkdir -p ~/.local/share/noctalia/plugins/me
cp -r mango-layouts ~/.local/share/noctalia/plugins/me/

# Reload plugins in Noctalia
noctalia msg plugins reload

# Enable the plugin
noctalia msg plugins enable me/mango-layouts
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
| **Left click** on bar widget | Cycle to next layout (or open panel — toggle in widget settings) |
| **Right click** on bar widget | Open the Layout Switcher panel |
| **Click a card** in the panel | Switch to that layout immediately |
| **Control Center** tile | Toggle panel |

### Widget settings

Open **Settings → Plugins → Mango Layouts → Switcher**:

- **Cycle on click** — when on, left click cycles layouts; when off, left click opens the panel
- **Show glyph** — toggle the layout icon in the bar

## Panel layout previews

The panel shows 15 MangoWM layouts as interactive cards, each with a miniature preview built from Noctalia's `ui.box` primitives:

| Layout | Preview |
|---|---|
| Tile | Master-stack: large left, stacked right |
| Scroller | Horizontal strip of equal windows |
| Grid | 2×2 window grid |
| Monocle | Single full-surface window |
| Deck | Stacked card overlap |
| Center Tile | Centered master with stacks on both sides |
| Dwindle | Recursive binary split |
| *(and 8 more)* | |

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
