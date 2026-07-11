--!nonstrict
-- [[panel]]: visual layout picker with live tile previews + pulse animation.

local LAYOUTS = {
  { id = "tile",             name = "Tile",          glyph = "layout-distribute-horizontal" },
  { id = "scroller",         name = "Scroller",      glyph = "layout-rows" },
  { id = "grid",             name = "Grid",          glyph = "layout-grid" },
  { id = "monocle",          name = "Monocle",       glyph = "layout-single" },
  { id = "deck",             name = "Deck",          glyph = "layout-cards" },
  { id = "center_tile",      name = "Center Tile",   glyph = "layout-align-center" },
  { id = "right_tile",       name = "Right Tile",    glyph = "layout-align-right" },
  { id = "vertical_tile",    name = "V. Tile",       glyph = "layout-distribute-vertical" },
  { id = "vertical_scroller",name = "V. Scroller",   glyph = "layout-columns" },
  { id = "vertical_grid",    name = "V. Grid",       glyph = "layout-grid" },
  { id = "vertical_deck",    name = "V. Deck",       glyph = "layout-cards" },
  { id = "tgmix",            name = "TGMix",         glyph = "layout-distribute-horizontal" },
  { id = "dwindle",          name = "Dwindle",       glyph = "layout-distribute-horizontal" },
  { id = "fair",             name = "Fair",          glyph = "layout-distribute-horizontal" },
  { id = "vertical_fair",    name = "V. Fair",       glyph = "layout-distribute-vertical" },
}

local currentLayout = noctalia.state.get("layout") or "tile"
local pulsePhase = 0
local mmsgAvail = noctalia.state.get("mmsg_available")

noctalia.state.watch("layout", function(value)
  if value then
    currentLayout = value
    render()
  end
end)

noctalia.state.watch("mmsg_available", function(v)
  mmsgAvail = v
end)

local function previewTile()
  return ui.row({ gap = 4, flexGrow = 1 }, {
    ui.box({ fill = "primary_container", radius = 6, flexGrow = 2 }),
    ui.column({ gap = 4, flexGrow = 1 }, {
      ui.box({ fill = "surface_variant", radius = 6, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 6, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 6, flexGrow = 1 }),
    }),
  })
end

local function previewScroller()
  return ui.row({ gap = 4, flexGrow = 1, padding = 4 }, {
    ui.box({ fill = "primary_container",    radius = 6, flexGrow = 1 }),
    ui.box({ fill = "secondary_container",  radius = 6, flexGrow = 1 }),
    ui.box({ fill = "tertiary_container",   radius = 6, flexGrow = 1 }),
    ui.box({ fill = "surface_variant",      radius = 6, flexGrow = 1 }),
  })
end

local function previewGrid()
  return ui.column({ gap = 4, flexGrow = 1 }, {
    ui.row({ gap = 4, flexGrow = 1 }, {
      ui.box({ fill = "primary_container",   radius = 6, flexGrow = 1 }),
      ui.box({ fill = "secondary_container", radius = 6, flexGrow = 1 }),
    }),
    ui.row({ gap = 4, flexGrow = 1 }, {
      ui.box({ fill = "tertiary_container",  radius = 6, flexGrow = 1 }),
      ui.box({ fill = "surface_variant",     radius = 6, flexGrow = 1 }),
    }),
  })
end

local function previewMonocle()
  return ui.box({ fill = "primary_container", radius = 6, flexGrow = 1 })
end

local function previewDeck()
  return ui.column({ gap = 0, flexGrow = 1, align = "center", justify = "center" }, {
    ui.box({ fill = "surface_variant",    radius = 6, width = 80, height = 20 }),
    ui.box({ fill = "secondary_container",radius = 6, width = 80, height = 20 }),
    ui.box({ fill = "primary_container",  radius = 6, width = 80, height = 20 }),
  })
end

local function previewCenterTile()
  return ui.row({ gap = 4, flexGrow = 1 }, {
    ui.column({ gap = 4, flexGrow = 1 }, {
      ui.box({ fill = "surface_variant", radius = 6, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 6, flexGrow = 1 }),
    }),
    ui.box({ fill = "primary_container", radius = 6, flexGrow = 2 }),
    ui.column({ gap = 4, flexGrow = 1 }, {
      ui.box({ fill = "surface_variant", radius = 6, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 6, flexGrow = 1 }),
    }),
  })
end

local function previewVerticalScroller()
  return ui.column({ gap = 4, flexGrow = 1, padding = 4 }, {
    ui.box({ fill = "primary_container",    radius = 6, flexGrow = 1 }),
    ui.box({ fill = "secondary_container",  radius = 6, flexGrow = 1 }),
    ui.box({ fill = "tertiary_container",   radius = 6, flexGrow = 1 }),
    ui.box({ fill = "surface_variant",      radius = 6, flexGrow = 1 }),
  })
end

local function previewVerticalTile()
  return ui.column({ gap = 4, flexGrow = 1 }, {
    ui.box({ fill = "primary_container", radius = 6, flexGrow = 2 }),
    ui.row({ gap = 4, flexGrow = 1 }, {
      ui.box({ fill = "surface_variant", radius = 6, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 6, flexGrow = 1 }),
    }),
  })
end

local function previewVerticalGrid()
  return ui.column({ gap = 4, flexGrow = 1 }, {
    ui.row({ gap = 4, flexGrow = 1 }, {
      ui.box({ fill = "primary_container", radius = 6, flexGrow = 1 }),
      ui.box({ fill = "secondary_container", radius = 6, flexGrow = 1 }),
    }),
    ui.row({ gap = 4, flexGrow = 1 }, {
      ui.box({ fill = "tertiary_container", radius = 6, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 6, flexGrow = 1 }),
    }),
  })
end

local function previewDwindle()
  return ui.column({ gap = 4, flexGrow = 1 }, {
    ui.row({ gap = 4, flexGrow = 1 }, {
      ui.box({ fill = "primary_container", radius = 6, flexGrow = 3 }),
      ui.column({ gap = 4, flexGrow = 2 }, {
        ui.box({ fill = "secondary_container", radius = 6, flexGrow = 1 }),
        ui.box({ fill = "surface_variant", radius = 6, flexGrow = 1 }),
      }),
    }),
  })
end

local PREVIEWS = {
  tile              = previewTile,
  scroller          = previewScroller,
  grid              = previewGrid,
  monocle           = previewMonocle,
  deck              = previewDeck,
  center_tile       = previewCenterTile,
  right_tile        = previewVerticalTile,
  vertical_tile     = previewVerticalTile,
  vertical_scroller = previewVerticalScroller,
  vertical_grid     = previewVerticalGrid,
  vertical_deck     = previewDeck,
  tgmix             = previewGrid,
  dwindle           = previewDwindle,
  fair              = previewGrid,
  vertical_fair     = previewVerticalGrid,
}

-- Register per-layout click handlers
for _, l in ipairs(LAYOUTS) do
  _G["onCardClick_" .. l.id] = function()
    if mmsgAvail then
      noctalia.runAsync({"mmsg", "-s", "-l", l.id})
    end
  end
end

local function layoutCard(layout)
  local isActive = layout.id == currentLayout
  local pulse = isActive and 0.85 + 0.15 * math.abs(math.sin(pulsePhase * math.pi)) or 1.0
  local previewFn = PREVIEWS[layout.id] or previewGrid

  return ui.column({
    flexGrow = 1, gap = 8, padding = 10,
    fill = isActive and "primary_container" or "surface_container",
    radius = 12,
    border = isActive and "primary" or "transparent",
    borderWidth = isActive and 2 or 0,
    opacity = pulse,
    onClick = "onCardClick_" .. layout.id,
    minWidth = 150, minHeight = 110,
  }, {
    ui.row({ gap = 6, align = "center" }, {
      ui.glyph({ name = layout.glyph, size = 14, color = "primary" }),
      ui.label({ text = layout.name, fontSize = 12, fontWeight = "bold" }),
    }),
    ui.box({ flexGrow = 1, minHeight = 60, radius = 8, padding = 6, fill = "surface" }, {
      previewFn(),
    }),
  })
end

local function render()
  local rows = {}
  local row = {}
  for i, layout in ipairs(LAYOUTS) do
    table.insert(row, layoutCard(layout))
    if #row == 3 or i == #LAYOUTS then
      table.insert(rows, ui.row({ gap = 10, flexGrow = 1 }, row))
      row = {}
    end
  end

  panel.render(ui.column({ gap = 12, padding = 16, flexGrow = 1 }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.row({ gap = 8, align = "center" }, {
        ui.glyph({ name = "layout", size = 18, color = "primary" }),
        ui.label({ text = "Layout Switcher", fontSize = 16, fontWeight = "bold", color = "on_surface" }),
      }),
      ui.button({ glyph = "close", onClick = "onClose" }),
    }),
    ui.separator({ thickness = 1, color = "outline_variant", spacing = 4 }),
    if mmsgAvail then
      ui.scroll({ flexGrow = 1, gap = 10 }, rows)
    else
      ui.box({ flexGrow = 1, fill = "error_container", radius = 12 }, {
        ui.label({ text = "mmsg not found — install mangowm-utils", color = "on_error_container", fontSize = 13 }),
      })
    end,
  }))
end

function onClose()
  panel.close()
end

function onOpen(_context)
  currentLayout = noctalia.state.get("layout") or "tile"
  mmsgAvail = noctalia.state.get("mmsg_available")
  pulsePhase = 0
  panel.setWantsSecondTicks(true)
  render()
end

function update()
  pulsePhase = (pulsePhase + 0.08) % 1
  currentLayout = noctalia.state.get("layout") or currentLayout
  render()
end
