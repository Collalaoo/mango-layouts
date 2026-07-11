--!nonstrict
-- Control Center [[shortcut]]: toggle the layout preview panel.

local NAMES = {
  tile              = "Tile",
  scroller          = "Scroller",
  grid              = "Grid",
  monocle           = "Monocle",
  deck              = "Deck",
  center_tile       = "Ctr Tile",
  right_tile        = "R Tile",
  vertical_tile     = "V Tile",
  vertical_scroller = "V Scrll",
  vertical_grid     = "V Grid",
  vertical_deck     = "V Deck",
  tgmix             = "TGMix",
  dwindle           = "Dwindle",
  fair              = "Fair",
  vertical_fair     = "V Fair",
}

local currentLayout = noctalia.state.get("layout") or "tile"

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
