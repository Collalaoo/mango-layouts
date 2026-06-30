--!nonstrict
-- Bar [[widget]]: shows current layout glyph + name.
-- Left-click: toggle panel / cycle depending on setting.
-- Right-click: cycle to next layout.

local GLYPHS = {
  tile              = "layout-distribute-horizontal",
  scroller          = "layout-rows",
  grid              = "layout-grid",
  monocle           = "layout-single",
  deck              = "layout-cards",
  center_tile       = "layout-align-center",
  right_tile        = "layout-align-right",
  vertical_tile     = "layout-distribute-vertical",
  vertical_scroller = "layout-columns",
  vertical_grid     = "layout-grid",
  vertical_deck     = "layout-cards",
  tgmix             = "layout-distribute-horizontal",
  dwindle           = "layout-distribute-horizontal",
  fair              = "layout-distribute-horizontal",
  vertical_fair     = "layout-distribute-vertical",
}

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

local CYCLE_ORDER = {
  "tile", "scroller", "grid", "monocle", "deck",
  "center_tile", "vertical_tile", "vertical_scroller",
  "vertical_grid", "tgmix", "dwindle", "fair",
}

local currentLayout = noctalia.state.get("layout") or "tile"
local mmsgAvail = noctalia.state.get("mmsg_available")
local cycleOnClick = barWidget.getConfig("cycle_on_click")
local showGlyph = barWidget.getConfig("show_glyph")

local function render()
  if showGlyph then
    barWidget.setGlyph(GLYPHS[currentLayout] or "layout")
  end
  barWidget.setText(NAMES[currentLayout] or currentLayout)
  barWidget.setTooltip(`Layout: {currentLayout}`)
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

function update()
  noctalia.setUpdateInterval(0)
  render()
end

function onClick()
  if not mmsgAvail then return end
  if cycleOnClick then
    local idx = 1
    for i, name in CYCLE_ORDER do
      if name == currentLayout then
        idx = (i % #CYCLE_ORDER) + 1
        break
      end
    end
    local next = CYCLE_ORDER[idx]
    noctalia.runAsync({"mmsg", "-s", "-l", next})
    currentLayout = next
    render()
  else
    noctalia.togglePanel("me/mango-layouts:preview")
  end
end

function onRightClick()
  if mmsgAvail then
    noctalia.togglePanel("me/mango-layouts:preview")
  end
end
