--!nonstrict
-- Control Center [[shortcut]]: toggle the layout preview panel.

local currentLayout = noctalia.state.get("layout") or "tile"

noctalia.state.watch("layout", function(value)
  if value then
    currentLayout = value
    shortcut.setLabel(currentLayout)
  end
end)

local function render()
  shortcut.setLabel(currentLayout)
  shortcut.setIcon("layout")
  shortcut.setActive(false)
  shortcut.setEnabled(true)
end

render()

function onClick()
  noctalia.togglePanel("me/mango-layouts:preview")
end
