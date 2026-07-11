--!nonstrict
-- [[service]]: polls mmsg for current layout, watches for changes.
-- Publishes state so widget/panel/shortcut stay in sync.

local LAYOUTS = {
  { id = "tiling",       code = "T"  },
  { id = "scroller",     code = "S"  },
  { id = "grid",         code = "G"  },
  { id = "fair",         code = "F"  },
  { id = "dwindle",      code = "DW" },
  { id = "deck",         code = "K"  },
  { id = "center_tile",  code = "CT" },
  { id = "right_tile",   code = "RT" },
  { id = "monocle",      code = "M"  },
}

local mmsgAvailable = noctalia.commandExists("mmsg")

local function normalize(raw)
  raw = noctalia.string.trim(raw or "")
  if raw == "" then return nil end
  for _, l in ipairs(LAYOUTS) do
    if raw == l.id or raw == l.code then return l.id end
  end
  local code = raw:match(":(%w+)$")
  if code then
    for _, l in ipairs(LAYOUTS) do
      if code == l.code then return l.id end
    end
  end
  for _, l in ipairs(LAYOUTS) do
    if raw:lower():find(l.id, 1, true) then return l.id end
  end
  return nil
end

local function poll()
  if not mmsgAvailable then
    noctalia.state.set("layout", nil)
    noctalia.state.set("mmsg_available", false)
    return
  end
  noctalia.runAsync({"mmsg", "-g", "-l"}, function(res)
    if res.exitCode == 0 and res.stdout and #res.stdout > 0 then
      local id = normalize(res.stdout)
      if id then
        noctalia.state.set("layout", id)
      end
    end
    noctalia.state.set("mmsg_available", true)
  end)
end

local function startWatcher()
  if not mmsgAvailable then return end
  noctalia.runStream({"mmsg", "-w"}, function(line)
    if line and #line > 0 then
      local id = normalize(line)
      if id then
        noctalia.state.set("layout", id)
      end
    end
  end)
end

noctalia.state.set("mmsg_available", mmsgAvailable)

if mmsgAvailable then
  startWatcher()
  poll()
  noctalia.setUpdateInterval(3000)
else
  noctalia.state.set("layout", "tiling")
  noctalia.setUpdateInterval(0)
end

function update()
  poll()
end
