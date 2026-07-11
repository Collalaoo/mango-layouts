--!nonstrict
-- [[widget]]: shows current layout glyph + name.
-- Left-click: cycles main layouts (Tiling / Scroller / Dwindle)
-- Right-click: open preview panel.

local GLYPHS = {
  tiling       = "layout-distribute-horizontal",
  scroller     = "layout-rows",
  grid         = "layout-grid",
  fair         = "layout-distribute-horizontal",
  dwindle      = "layout-distribute-horizontal",
  deck         = "layout-cards",
  center_tile  = "layout-align-center",
  right_tile   = "layout-align-right",
  monocle      = "layout-single",
}

local NAMES = {
  tiling       = "Tiling",
  scroller     = "Scroller",
  grid         = "Grid",
  fair         = "Fair",
  dwindle      = "Dwindle",
  deck         = "Deck",
  center_tile  = "Center",
  right_tile   = "R Tile",
  monocle      = "Monocle",
}

local MAIN_CYCLE = { "tiling", "scroller", "dwindle" }

local function cycleNext(layout)
  for i, name in ipairs(MAIN_CYCLE) do
    if name == layout then
      return MAIN_CYCLE[(i % #MAIN_CYCLE) + 1]
    end
  end
  return MAIN_CYCLE[1]
end

local currentLayout = noctalia.state.get("layout") or "tiling"
local mmsgAvail = noctalia.state.get("mmsg_available")
local showGlyph = barWidget.getConfig("show_glyph")

local function render()
  if showGlyph then
    barWidget.setGlyph(GLYPHS[currentLayout] or "layout")
  end
  barWidget.setText(NAMES[currentLayout] or currentLayout)
  barWidget.setTooltip(string.format("Layout: %s", NAMES[currentLayout] or currentLayout))
end

noctalia.state.watch("layout", function(value)
  if value then
    currentLayout = value
    render()
  end
end)

noctalia.state.watch("mmsg_available", function(v)
  mmsgAvail = v
end)

function onClick()
  if not mmsgAvail then return end
  local next = cycleNext(currentLayout)
  noctalia.runAsync({"mmsg", "-s", "-l", next})
end

function onRightClick()
  if mmsgAvail then
    noctalia.togglePanel("Collalaoo/mango-layouts:preview")
  end
end
