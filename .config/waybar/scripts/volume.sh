#!/bin/bash

VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep MUTED)

if [[ $MUTED ]]; then
  ICON="󰝟" 
else
   if [ "$VOLUME" -lt 20 ]; then
    ICON=""
  elif [ "$VOLUME" -lt 80 ]; then
    ICON=""
  else
    ICON=""
  fi
fi

echo "{\"text\": \"$ICON\", \"tooltip\": \"Volume: $VOLUME%\"}"
