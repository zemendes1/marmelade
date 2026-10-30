local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}
local brackets = {}

sbar.add("event", "aerospace_workspace_change")

for i = 1, 9, 1 do
  local space = sbar.add("item", "space." .. i, {
    icon = {
      font = { family = settings.font.numbers },
      string = i,
      padding_left = 15,
      padding_right = 8,
      color = colors.white,
      highlight_color = colors.red,
    },
    label = {
      padding_right = 20,
      color = colors.grey,
      highlight_color = colors.white,
      font = "sketchybar-app-font:Regular:16.0",
      y_offset = -1,
    },
    padding_right = 1,
    padding_left = 1,
    background = {
      color = colors.bg1,
      border_width = 1,
      height = 26,
      border_color = colors.black,
    },
    popup = { background = { border_width = 5, border_color = colors.black } }
  })

  spaces[i] = space

  -- Single item bracket for space items to achieve double border on highlight
  local space_bracket = sbar.add("bracket", { space.name }, {
    background = {
      color = colors.transparent,
      border_color = colors.bg2,
      height = 28,
      border_width = 2
    }
  })
  brackets[i] = space_bracket

  -- Padding space
  sbar.add("item", "space.padding." .. i, {
    script = "",
    width = settings.group_paddings,
  })

  space:subscribe("mouse.clicked", function(_)
    sbar.exec("aerospace workspace " .. i)
  end)
end

local space_window_observer = sbar.add("item", {
  drawing = false,
  updates = true,
})

local spaces_indicator = sbar.add("item", {
  padding_left = -3,
  padding_right = 0,
  icon = {
    padding_left = 8,
    padding_right = 9,
    color = colors.grey,
    string = icons.switch.on,
  },
  label = {
    width = 0,
    padding_left = 0,
    padding_right = 8,
    string = "Spaces",
    color = colors.bg1,
  },
  background = {
    color = colors.with_alpha(colors.grey, 0.0),
    border_color = colors.with_alpha(colors.bg1, 0.0),
  }
})

local function highlight(focused)
  for i, space in pairs(spaces) do
    local selected = tostring(i) == focused
    space:set({
      icon = { highlight = selected },
      label = { highlight = selected },
      background = { border_color = selected and colors.black or colors.bg2 }
    })
    brackets[i]:set({
      background = { border_color = selected and colors.grey or colors.bg2 }
    })
  end
end

local function update_icons()
  sbar.exec("aerospace list-windows --all --format '%{workspace}|%{app-name}'", function(out)
    local apps = {}
    for line in string.gmatch(out or "", "[^\n]+") do
      local ws, app = line:match("^(%d+)|(.*)$")
      if ws then
        apps[ws] = apps[ws] or {}
        apps[ws][app] = true
      end
    end
    for i, space in pairs(spaces) do
      local icon_line = ""
      for app, _ in pairs(apps[tostring(i)] or {}) do
        icon_line = icon_line .. (app_icons[app] or app_icons["Default"])
      end
      if icon_line == "" then icon_line = " —" end
      sbar.animate("tanh", 10, function()
        space:set({ label = icon_line })
      end)
    end
  end)
end

space_window_observer:subscribe("aerospace_workspace_change", function(env)
  highlight(env.FOCUSED_WORKSPACE)
  update_icons()
end)

space_window_observer:subscribe({ "front_app_switched", "space_windows_change", "system_woke" }, function(_)
  update_icons()
end)

sbar.exec("aerospace list-workspaces --focused", function(out)
  highlight((out or ""):gsub("%s+", ""))
end)
update_icons()

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
  local currently_on = spaces_indicator:query().icon.value == icons.switch.on
  spaces_indicator:set({
    icon = currently_on and icons.switch.off or icons.switch.on
  })
end)

spaces_indicator:subscribe("mouse.entered", function(env)
  sbar.animate("tanh", 30, function()
    spaces_indicator:set({
      background = {
        color = { alpha = 1.0 },
        border_color = { alpha = 1.0 },
      },
      icon = { color = colors.bg1 },
      label = { width = "dynamic" }
    })
  end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
  sbar.animate("tanh", 30, function()
    spaces_indicator:set({
      background = {
        color = { alpha = 0.0 },
        border_color = { alpha = 0.0 },
      },
      icon = { color = colors.grey },
      label = { width = 0, }
    })
  end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
  sbar.trigger("swap_menus_and_spaces")
end)
