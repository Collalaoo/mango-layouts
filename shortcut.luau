--!nonstrict
-- [[shortcut]]: toggle the layout preview panel from Control Center.

local NAMES = {
  tiling      = "Tiling",
  scroller    = "Scroller",
  grid        = "Grid",
  fair        = "Fair",
  dwindle     = "Dwindle",
  deck        = "Deck",
  center_tile = "Center",
  right_tile  = "R Tile",
  monocle     = "Monocle",
}

local currentLayout = noctalia.state.get("layout") or "tiling"

local function render()
  shortcut.setLabel(NAMES[currentLayout] or currentLayout)
  shortcut.setIcon("layout")
  shortcut.setActive(false)
  shortcut.setEnabled(true)
end

noctalia.state.watch("layout", function(value)
  if value then
    currentLayout = value
    render()
  end
end)

render()

function onClick()
  noctalia.togglePanel("Collalaoo/mango-layouts:preview")
end
