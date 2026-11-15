local colors = require("colors")
local settings = require("settings")

-- Click to keep the Mac awake (display, idle and system sleep) until clicked
-- again. Uses macOS's built-in `caffeinate`; matching this exact command line
-- keeps the widget away from other caffeinate runs.
local pattern = "'caffeinate -dims'"
local status_cmd = "pgrep -fx " .. pattern
-- Stop it if running, otherwise start it; prints the new state.
local toggle_cmd = "pkill -fx " .. pattern .. " && echo off"
  .. " || { nohup caffeinate -dims >/dev/null 2>&1 & echo on; }"

-- Hack Nerd Font glyphs: md-coffee (U+F0176) and md-coffee_off_outline (U+F0FAB).
-- SF Symbols has cup.and.saucer, but its codepoint isn't known here.
local icon_on = utf8.char(0xF0176)
local icon_off = utf8.char(0xF0FAB)

local caffeine = sbar.add("item", "widgets.caffeine", {
  position = "right",
  icon = {
    string = icon_off,
    color = colors.grey,
    font = { family = "Hack Nerd Font", style = "Regular", size = 16.0 },
    padding_left = 8,
    padding_right = 8,
  },
  label = { drawing = false },
  update_freq = 120,
})

sbar.add("bracket", "widgets.caffeine.bracket", { caffeine.name }, {
  background = { color = colors.bg1 },
})

sbar.add("item", "widgets.caffeine.padding", {
  position = "right",
  width = settings.group_paddings,
})

local function render(on)
  caffeine:set({
    icon = {
      string = on and icon_on or icon_off,
      color = on and colors.yellow or colors.grey,
    },
  })
end

local function refresh()
  sbar.exec(status_cmd, function(out)
    render(out ~= nil and out ~= "")
  end)
end

caffeine:subscribe({ "routine", "forced", "system_woke" }, refresh)

caffeine:subscribe("mouse.clicked", function(_)
  sbar.exec(toggle_cmd, function(out)
    render((out or ""):find("on") ~= nil)
  end)
end)

refresh()
