local icons = require("icons")
local colors = require("colors")

sbar.exec("pkill -f media-stream.sh 2>/dev/null; nohup $CONFIG_DIR/helpers/media-stream.sh >/dev/null 2>&1 &")

local media_cover = sbar.add("item", {
  position = "right",
  background = { color = colors.transparent },
  label = { drawing = false },
  icon = { drawing = false },
  popup = {
    align = "center",
    horizontal = true,
  }
})

local media_artist = sbar.add("item", {
  position = "right",
  padding_left = 3,
  padding_right = 0,
  width = 0,
  icon = { drawing = false },
  label = {
    font = { size = 9 },
    color = colors.with_alpha(colors.white, 0.6),
    max_chars = 18,
    y_offset = 6,
    string = "—",
  },
})

local media_title = sbar.add("item", {
  position = "right",
  padding_left = 3,
  padding_right = 0,
  icon = { drawing = false },
  label = {
    font = { size = 11 },
    max_chars = 16,
    y_offset = -5,
    string = "Nothing Playing",
  },
})


local function fetch_artwork()
  sbar.exec("media-control get 2>/dev/null | jq -r '.artworkData // empty' | base64 -d > /tmp/sketchybar_artwork_raw.jpg 2>/dev/null && sips -z 60 60 /tmp/sketchybar_artwork_raw.jpg --out /tmp/sketchybar_artwork.jpg >/dev/null 2>&1", function()
    media_cover:set({ background = { image = { drawing = true, string = "/tmp/sketchybar_artwork.jpg", scale = 0.5 } } })
  end)
end

local current_title = ""

local function set_media(title, artist)
  if title == "" or title == nil then
    media_title:set({ label = "Nothing Playing" })
    media_artist:set({ label = "—" })
    current_title = ""
    media_cover:set({ background = { image = { drawing = false } } })
  else
    media_title:set({ label = title })
    media_artist:set({ label = artist ~= "" and artist or "—" })
    if title ~= current_title then
      current_title = title
      fetch_artwork()
    end
  end
end

media_cover:subscribe("media_stream_changed", function(env)
  set_media(env.title, env.artist)
end)

-- Initial state
sbar.exec("media-control get 2>/dev/null | jq -r '.title, .artist'", function(result)
  local lines = {}
  for line in result:gmatch("[^\n]+") do lines[#lines + 1] = line end
  set_media(lines[1] or "", lines[2] or "")
end)
