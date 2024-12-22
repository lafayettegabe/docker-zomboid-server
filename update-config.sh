#!/bin/bash

CONFIG_FILE="/home/pzuser/Zomboid/Server/servertest.ini"

if [ -n "$SERVER_NAME" ]; then
  sed -i "s/^PublicName=.*/PublicName=$SERVER_NAME/" "$CONFIG_FILE"
fi

if [ -n "$SERVER_DESCRIPTION" ]; then
  sed -i "s/^PublicDescription=.*/PublicDescription=$SERVER_DESCRIPTION/" "$CONFIG_FILE"
fi

if [ -n "$SERVER_PASSWORD" ]; then
  sed -i "s/^Password=.*/Password=$SERVER_PASSWORD/" "$CONFIG_FILE"
fi

if [ -n "$SERVER_MODS_COLLECTION_URL" ]; then
  echo "Fetching mods from: $SERVER_MODS_COLLECTION_URL"
  RESPONSE=$(curl -s -X POST https://api.pzidgrabber.com/collection/getId \
    -H "Content-Type: application/json" \
    --data "{\"url\": \"$SERVER_MODS_COLLECTION_URL\"}")

  MODS=$(echo "$RESPONSE" | jq -r '.mods')
  WORKSHOP_ITEMS=$(echo "$RESPONSE" | jq -r '.workshopItems')

  if [ -n "$MODS" ]; then
    sed -i "s/^Mods=.*/Mods=$MODS/" "$CONFIG_FILE"
    echo "Mods updated successfully!"
  else
    echo "Failed to fetch mods or no mods found."
  fi

  if [ -n "$WORKSHOP_ITEMS" ]; then
    sed -i "s/^WorkshopItems=.*/WorkshopItems=$WORKSHOP_ITEMS/" "$CONFIG_FILE"
    echo "WorkshopItems updated successfully!"
  else
    echo "Failed to fetch WorkshopItems or no items found."
  fi
fi

echo "Configuration updated successfully!"
