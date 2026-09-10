#!/bin/bash
title=""
artist=""
playing="false"

media-control stream | while IFS= read -r line; do
  payload_empty=$(jq -r 'if (.payload | length) == 0 then "true" else "false" end' <<< "$line")

  if [ "$payload_empty" = "true" ]; then
    title=""
    artist=""
    playing="false"
  else
    new_title=$(jq -r 'if .payload.title then .payload.title else empty end' <<< "$line")
    new_artist=$(jq -r 'if .payload.artist then .payload.artist else empty end' <<< "$line")
    new_playing=$(jq -r 'if .payload.playing != null then .payload.playing else empty end' <<< "$line")

    [ -n "$new_title" ] && [ "$new_title" != "null" ] && title="$new_title"
    [ -n "$new_artist" ] && [ "$new_artist" != "null" ] && artist="$new_artist"
    [ -n "$new_playing" ] && [ "$new_playing" != "null" ] && playing="$new_playing"
  fi

  sketchybar --trigger media_stream_changed title="$title" artist="$artist" playing="$playing"
done
