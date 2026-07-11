--!nonstrict
-- [[panel]]: interactive layout picker with main layouts + "More" section.

local MAIN_LAYOUTS = {
  { id = "tiling",  name = "Tiling",   glyph = "layout-distribute-horizontal" },
  { id = "scroller", name = "Scroller", glyph = "layout-rows" },
  { id = "dwindle",  name = "Dwindle",  glyph = "layout-distribute-horizontal" },
}

local MORE_LAYOUTS = {
  { id = "grid",        name = "Grid",        glyph = "layout-grid" },
  { id = "fair",        name = "Fair",        glyph = "layout-distribute-horizontal" },
  { id = "deck",        name = "Deck",        glyph = "layout-cards" },
  { id = "center_tile", name = "Center Tile", glyph = "layout-align-center" },
  { id = "right_tile",  name = "Right Tile",  glyph = "layout-align-right" },
  { id = "monocle",     name = "Monocle",     glyph = "layout-single" },
  { id = "overview",    name = "Overview",    glyph = "layout-grid", isToggle = true },
}

local ALL_LAYOUTS = {}
for _, l in ipairs(MAIN_LAYOUTS) do table.insert(ALL_LAYOUTS, l) end
for _, l in ipairs(MORE_LAYOUTS) do table.insert(ALL_LAYOUTS, l) end

local currentLayout = noctalia.state.get("layout") or "tiling"
local pulsePhase = 0
local mmsgAvail = noctalia.state.get("mmsg_available")
local showMore = false

noctalia.state.watch("layout", function(value)
  if value then currentLayout = value ; render() end
end)

noctalia.state.watch("mmsg_available", function(v)
  mmsgAvail = v
end)

-- ── Preview renderers ────────────────────────────────────────────────────────

local function previewTiling()
  return ui.row({ gap = 3, flexGrow = 1 }, {
    ui.box({ fill = "primary_container", radius = 4, flexGrow = 2 }),
    ui.column({ gap = 3, flexGrow = 1 }, {
      ui.box({ fill = "surface_variant", radius = 4, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 4, flexGrow = 1 }),
    }),
  })
end

local function previewScroller()
  return ui.row({ gap = 3, flexGrow = 1, padding = 2 }, {
    ui.box({ fill = "primary_container",   radius = 4, flexGrow = 1 }),
    ui.box({ fill = "secondary_container", radius = 4, flexGrow = 1 }),
    ui.box({ fill = "tertiary_container",  radius = 4, flexGrow = 1 }),
    ui.box({ fill = "surface_variant",     radius = 4, flexGrow = 1 }),
  })
end

local function previewGrid()
  return ui.column({ gap = 3, flexGrow = 1 }, {
    ui.row({ gap = 3, flexGrow = 1 }, {
      ui.box({ fill = "primary_container",   radius = 4, flexGrow = 1 }),
      ui.box({ fill = "secondary_container", radius = 4, flexGrow = 1 }),
    }),
    ui.row({ gap = 3, flexGrow = 1 }, {
      ui.box({ fill = "tertiary_container",  radius = 4, flexGrow = 1 }),
      ui.box({ fill = "surface_variant",     radius = 4, flexGrow = 1 }),
    }),
  })
end

local function previewFair()
  return ui.column({ gap = 3, flexGrow = 1 }, {
    ui.row({ gap = 3, flexGrow = 1 }, {
      ui.box({ fill = "primary_container", radius = 4, flexGrow = 1 }),
      ui.box({ fill = "secondary_container", radius = 4, flexGrow = 1 }),
    }),
    ui.row({ gap = 3, flexGrow = 1 }, {
      ui.box({ fill = "primary_container", radius = 4, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 4, flexGrow = 1 }),
    }),
    ui.row({ gap = 3, flexGrow = 1 }, {
      ui.box({ fill = "secondary_container", radius = 4, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 4, flexGrow = 1 }),
    }),
  })
end

local function previewDwindle()
  return ui.column({ gap = 3, flexGrow = 1 }, {
    ui.row({ gap = 3, flexGrow = 1 }, {
      ui.box({ fill = "primary_container", radius = 4, flexGrow = 3 }),
      ui.column({ gap = 3, flexGrow = 2 }, {
        ui.row({ gap = 3, flexGrow = 1 }, {
          ui.box({ fill = "secondary_container", radius = 4, flexGrow = 1 }),
          ui.box({ fill = "surface_variant", radius = 4, flexGrow = 1 }),
        }),
        ui.box({ fill = "surface_variant", radius = 4, flexGrow = 1 }),
      }),
    }),
    ui.row({ gap = 3, flexGrow = 1 }, {
      ui.box({ fill = "secondary_container", radius = 4, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 4, flexGrow = 1 }),
    }),
  })
end

local function previewDeck()
  return ui.column({ gap = 0, flexGrow = 1, align = "center", justify = "center" }, {
    ui.box({ fill = "surface_variant",    radius = 4, width = 70, height = 18 }),
    ui.box({ fill = "secondary_container",radius = 4, width = 70, height = 18 }),
    ui.box({ fill = "primary_container",  radius = 4, width = 70, height = 18 }),
  })
end

local function previewCenterTile()
  return ui.row({ gap = 3, flexGrow = 1 }, {
    ui.column({ gap = 3, flexGrow = 1 }, {
      ui.box({ fill = "surface_variant", radius = 4, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 4, flexGrow = 1 }),
    }),
    ui.box({ fill = "primary_container", radius = 4, flexGrow = 2 }),
    ui.column({ gap = 3, flexGrow = 1 }, {
      ui.box({ fill = "surface_variant", radius = 4, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 4, flexGrow = 1 }),
    }),
  })
end

local function previewRightTile()
  return ui.row({ gap = 3, flexGrow = 1 }, {
    ui.column({ gap = 3, flexGrow = 1 }, {
      ui.box({ fill = "surface_variant", radius = 4, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 4, flexGrow = 1 }),
    }),
    ui.box({ fill = "primary_container", radius = 4, flexGrow = 2 }),
  })
end

local function previewMonocle()
  return ui.box({ fill = "primary_container", radius = 4, flexGrow = 1 })
end

local function previewOverview()
  return ui.column({ gap = 2, flexGrow = 1 }, {
    ui.row({ gap = 2, flexGrow = 1 }, {
      ui.box({ fill = "primary_container",   radius = 3, flexGrow = 1 }),
      ui.box({ fill = "secondary_container", radius = 3, flexGrow = 1 }),
      ui.box({ fill = "tertiary_container",  radius = 3, flexGrow = 1 }),
    }),
    ui.row({ gap = 2, flexGrow = 1 }, {
      ui.box({ fill = "surface_variant", radius = 3, flexGrow = 1 }),
      ui.box({ fill = "primary_container",   radius = 3, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 3, flexGrow = 1 }),
    }),
    ui.row({ gap = 2, flexGrow = 1 }, {
      ui.box({ fill = "tertiary_container",  radius = 3, flexGrow = 1 }),
      ui.box({ fill = "surface_variant", radius = 3, flexGrow = 1 }),
      ui.box({ fill = "secondary_container", radius = 3, flexGrow = 1 }),
    }),
  })
end

local PREVIEWS = {
  tiling      = previewTiling,
  scroller    = previewScroller,
  grid        = previewGrid,
  fair        = previewFair,
  dwindle     = previewDwindle,
  deck        = previewDeck,
  center_tile = previewCenterTile,
  right_tile  = previewRightTile,
  monocle     = previewMonocle,
  overview    = previewOverview,
}

-- ── Card builder ─────────────────────────────────────────────────────────────

local function card(layout, opts)
  opts = opts or {}
  local isActive = layout.id == currentLayout and not layout.isToggle
  local p = isActive
    and 0.82 + 0.18 * math.abs(math.sin(pulsePhase * math.pi))
    or opts.fallbackOpacity or 1.0
  local previewFn = PREVIEWS[layout.id] or previewGrid
  return ui.column({
    gap = 6, padding = 8,
    fill = isActive and "primary_container" or "surface_container",
    radius = 10,
    border = isActive and "primary" or "transparent",
    borderWidth = isActive and 2 or 0,
    opacity = p,
    flexGrow = 1, basis = opts.basis,
    minWidth = 140, minHeight = 100,
    onClick = "onCardClick_" .. layout.id,
  }, {
    ui.row({ gap = 5, align = "center" }, {
      ui.glyph({ name = layout.glyph, size = 13, color = "primary" }),
      ui.label({ text = layout.name, fontSize = 12, fontWeight = "bold" }),
    }),
    ui.box({ flexGrow = 1, minHeight = 50, radius = 6, padding = 4, fill = "surface" }, {
      previewFn(),
    }),
  })
end

-- ── Click handlers ───────────────────────────────────────────────────────────

for _, l in ipairs(ALL_LAYOUTS) do
  if l.isToggle then
    _G["onCardClick_" .. l.id] = function()
      if mmsgAvail then
        noctalia.runAsync({"mmsg", "overview"})
      end
    end
  else
    _G["onCardClick_" .. l.id] = function()
      if mmsgAvail then
        noctalia.runAsync({"mmsg", "-s", "-l", l.id})
      end
    end
  end
end

-- ── Actions ──────────────────────────────────────────────────────────────────

function onToggleMore()
  showMore = not showMore
  render()
end

function onClose()
  panel.close()
end

-- ── Render ───────────────────────────────────────────────────────────────────

local function sectionLabel(text)
  return ui.row({ gap = 6, align = "center", padding = { top = 4 } }, {
    ui.glyph({ name = "layout", size = 12, color = "primary" }),
    ui.label({ text = text, fontSize = 12, fontWeight = "bold", color = "on_surface_variant" }),
    ui.separator({ flexGrow = 1, thickness = 1, color = "outline_variant", spacing = 4 }),
  })
end

local function layoutRow(layouts, maxCols)
  local rows = {}
  local row = {}
  for i, l in ipairs(layouts) do
    table.insert(row, card(l))
    if #row == maxCols or i == #layouts then
      table.insert(rows, ui.row({ gap = 8, flexGrow = 1 }, row))
      row = {}
    end
  end
  return rows
end

local function render()
  local children = {}

  table.insert(children, ui.row({ align = "center", justify = "space_between", gap = 8 }, {
    ui.row({ gap = 8, align = "center" }, {
      ui.glyph({ name = "layout", size = 18, color = "primary" }),
      ui.label({ text = "Layout Switcher", fontSize = 15, fontWeight = "bold", color = "on_surface" }),
    }),
    ui.button({ glyph = "close", onClick = "onClose" }),
  }))

  table.insert(children, ui.separator({ thickness = 1, color = "outline_variant", spacing = 4 }))

  if mmsgAvail then
    -- Main layouts
    table.insert(children, sectionLabel("Main"))
    for _, row in ipairs(layoutRow(MAIN_LAYOUTS, 3)) do
      table.insert(children, row)
    end

    -- More toggle
    table.insert(children, ui.button({
      text = showMore and "Less" or "More (" .. #MORE_LAYOUTS .. ")",
      glyph = showMore and "expand-less" or "expand-more",
      onClick = "onToggleMore",
      style = "text",
      align = "center",
      width = "fill",
    }))

    -- More layouts
    if showMore then
      for _, row in ipairs(layoutRow(MORE_LAYOUTS, 3)) do
        table.insert(children, row)
      end
    end
  else
    table.insert(children, ui.box({ flexGrow = 1, fill = "error_container", radius = 10 }, {
      ui.label({ text = "mmsg not found", color = "on_error_container", fontSize = 13 }),
    }))
  end

  panel.render(ui.scroll({ flexGrow = 1, gap = 10, padding = 14 }, children))
end

function onOpen(_context)
  currentLayout = noctalia.state.get("layout") or "tiling"
  mmsgAvail = noctalia.state.get("mmsg_available")
  pulsePhase = 0
  showMore = false
  panel.setWantsSecondTicks(true)
  render()
end

function update()
  pulsePhase = (pulsePhase + 0.06) % 1
  currentLayout = noctalia.state.get("layout") or currentLayout
  render()
end
