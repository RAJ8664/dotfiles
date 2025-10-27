#!/bin/bash

notif_icon="$HOME/.config/swaync/images/ja.png"

SSID="Fedora"
PASSWORD="Password@12345"
HOTSPOT_NAME="Fedora-hotspot"
WIFI_IFACE=$(nmcli device | awk '$2 == "wifi" && $1 !~ /^p2p/ {print $1; exit}')

if [ -z "$WIFI_IFACE" ]; then
    echo "❌ No valid Wi-Fi interface found."
    exit 1
fi

# Check if hotspot is active
HOTSPOT_ACTIVE=$(nmcli -t -f NAME,DEVICE connection show --active | grep "^$HOTSPOT_NAME:")

if [ -n "$HOTSPOT_ACTIVE" ]; then
    # Hotspot already active → disable it
    nmcli connection down "$HOTSPOT_NAME"
    notify-send -u low -i "$notif_icon" " 🔴 Hotspot Disabled"
    echo "✅ Hotspot disabled."
    exit 0
fi

# If connection exists but inactive, delete & recreate fresh
nmcli connection delete "$HOTSPOT_NAME" >/dev/null 2>&1

# Create hotspot
nmcli connection add type wifi ifname "$WIFI_IFACE" mode ap con-name "$HOTSPOT_NAME" ssid "$SSID"
nmcli connection modify "$HOTSPOT_NAME" wifi.band bg
nmcli connection modify "$HOTSPOT_NAME" wifi.channel 1
nmcli connection modify "$HOTSPOT_NAME" ipv4.method shared
nmcli connection modify "$HOTSPOT_NAME" wifi-sec.key-mgmt wpa-psk
nmcli connection modify "$HOTSPOT_NAME" wifi-sec.psk "$PASSWORD"

# Enable hotspot
nmcli connection up "$HOTSPOT_NAME"
notify-send -u low -i "$notif_icon" " 🟢 Hotspot Enabled"
echo "✅ Hotspot '$SSID' enabled on $WIFI_IFACE"
