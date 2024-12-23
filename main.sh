#!/bin/bash

CONFIG_FILE="/home/pzuser/Zomboid/Server/servertest.ini"

log_info() {
  echo "INFO: $1"
}

log_error() {
  echo "ERROR: $1" >&2
  exit 1
}

update_config() {
  local key="$1"
  local value="$2"
  if [ -n "$value" ]; then
    log_info "Updating $key to $value"
    sed -i "s/^$key=.*/$key=${value}/" "$CONFIG_FILE"
  fi
}

log_info "Starting configuration updates..."

log_info "SERVER_NAME=$SERVER_NAME"
log_info "SERVER_DESCRIPTION=$SERVER_DESCRIPTION"
log_info "SERVER_PASSWORD=$SERVER_PASSWORD"

update_config "PublicName" "$SERVER_NAME"
update_config "PublicDescription" "$SERVER_DESCRIPTION"
update_config "Password" "$SERVER_PASSWORD"

if [ -n "$SERVER_MODS_COLLECTION_URL" ]; then
  log_info "Fetching mods from $SERVER_MODS_COLLECTION_URL"
  RESPONSE=$(curl -s -X POST https://api.pzidgrabber.com/collection/getId \
    -H "Content-Type: application/json" \
    --data "{\"url\": \"$SERVER_MODS_COLLECTION_URL\"}") || log_error "Failed to fetch mods."

  MODS=$(echo "$RESPONSE" | jq -r '.mods')
  WORKSHOP_ITEMS=$(echo "$RESPONSE" | jq -r '.workshopItems')

  update_config "Mods" "$MODS"
  update_config "WorkshopItems" "$WORKSHOP_ITEMS"
fi

log_info "Configuration updates complete."

log_info "Logging the contents of the updated configuration file ($CONFIG_FILE):"
cat "$CONFIG_FILE"

cd /opt/pzserver && ./start-server.sh -adminpassword password
