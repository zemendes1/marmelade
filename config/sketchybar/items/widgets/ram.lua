local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Used memory = active + wired + compressed pages, as a percentage of total RAM
local ram_cmd = [[vm_stat | awk -v total=$(sysctl -n hw.memsize) '/page size of/ {ps=$8} /Pages active/ {a=$3} /Pages wired/ {w=$4} /occupied by compressor/ {c=$5} END {printf "%d", (a+w+c)*ps*100/total}']]

local ram = sbar.add("graph", "widgets.ram" , 42, {
  position = "right",
  graph = { color = colors.blue },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { string = icons.ram },
  label = {
    string = "ram ??%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    align = "right",
    padding_right = 0,
    width = 0,
    y_offset = 4
  },
  padding_right = settings.paddings + 6,
  update_freq = 5,
})

ram:subscribe({ "routine", "forced", "system_woke" }, function(env)
  sbar.exec(ram_cmd, function(result)
    local load = tonumber(result)
    if not load then return end
    ram:push({ load / 100. })

    local color = colors.blue
    if load > 60 then
      if load < 75 then
        color = colors.yellow
      elseif load < 90 then
        color = colors.orange
      else
        color = colors.red
      end
    end

    ram:set({
      graph = { color = color },
      label = "ram " .. load .. "%",
    })
  end)
end)

ram:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a 'Activity Monitor'")
end)

-- Background around the ram item
sbar.add("bracket", "widgets.ram.bracket", { ram.name }, {
  background = { color = colors.bg1 }
})

-- Background around the ram item
sbar.add("item", "widgets.ram.padding", {
  position = "right",
  width = settings.group_paddings
})
