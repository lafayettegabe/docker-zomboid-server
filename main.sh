#!/bin/bash

CONFIG_FILE="/root/Zomboid/Server/servertest.ini"

log_info() {
  echo "INFO: $1"
}

log_error() {
  echo "ERROR: $1" >&2
  exit 1
}

create_config_file() {
  if [ ! -f "$CONFIG_FILE" ]; then
    log_info "Configuration file not found. Creating a new one at $CONFIG_FILE."
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat >"$CONFIG_FILE" <<EOF
[General]
PublicName=DefaultServerName
PublicDescription=Default server description
Password=
Mods=
WorkshopItems=
Public=true
PVP=true
PauseEmpty=true
GlobalChat=true
Open=true
DisplayUserName=false
NoFire=false
AnnounceDeath=true
MinutesPerPage=0.1
PlayerSafehouse=true
SafehouseAllowTrepass=false
SafehouseAllowFire=false
SafehouseAllowLoot=false
SafehouseAllowRespawn=true
SafehouseDaySurvivedToClaim=0
SafeHouseRemovalTime=72
SleepAllowed=true
SleepNeeded=true
SteamScoreboard=admin
PlayerBumpPlayer=true
HoursForLootRespawn=1000
EOF
    chmod 644 "$CONFIG_FILE"
  fi
}

update_config() {
  local key="$1"
  local value="$2"
  if grep -q "^$key=" "$CONFIG_FILE"; then
    sed -i "s/^$key=.*/$key=${value}/" "$CONFIG_FILE"
  else
    echo "$key=$value" >> "$CONFIG_FILE"
  fi
}

disable_anticheats() {
  log_info "Disabling all anti-cheat protections..."
  for i in $(seq 1 22); do
    update_config "AntiCheatProtectionType$i" "false"
  done
}

log_info "Starting configuration updates..."
create_config_file

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

disable_anticheats

log_info "Configuration updates complete."
log_info "Logging the contents of the updated configuration file ($CONFIG_FILE):"
cat "$CONFIG_FILE"

cd /opt/pzserver && ./start-server.sh -adminpassword password
