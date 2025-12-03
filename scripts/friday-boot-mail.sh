#!/usr/bin/env bash
set -e

# Change this to the email where you want to receive boot reports
TO_EMAIL="you@example.com"

HOSTNAME=$(hostname)
UPTIME=$(uptime -p)
LOADAVG=$(awk '{print $1, $2, $3}' /proc/loadavg)
IP_ADDRS=$(hostname -I 2>/dev/null || echo "n/a")

MEM_INFO=$(free -h)
DISK_ROOT=$(df -h /)
SENSORS_OUT=$(sensors 2>/dev/null || echo "no sensor data")

{
  echo "server has booted."
  echo
  echo "Hostname: $HOSTNAME"
  echo "Uptime:   $UPTIME"
  echo "Load:     $LOADAVG"
  echo "IP(s):    $IP_ADDRS"
  echo
  echo "=== Memory ==="
  echo "$MEM_INFO"
  echo
  echo "=== Disk (/) ==="
  echo "$DISK_ROOT"
  echo
  echo "=== Sensors ==="
  echo "$SENSORS_OUT"
} | /usr/bin/mail -s "server booted: $HOSTNAME" "$TO_EMAIL"
