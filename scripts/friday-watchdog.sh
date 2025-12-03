#!/usr/bin/env bash
set -e

# Email to receive alerts
TO_EMAIL="you@example.com"

# Thresholds
CPU_MAX=85        # percent
MEM_MAX=85        # percent
DISK_MAX=90       # percent (root filesystem)
TEMP_MAX=75       # Celsius

ALERTS=()

# CPU usage approximation (fallback-friendly)
CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {print 100-$8}' | cut -d. -f1)
CPU_USAGE=${CPU_USAGE:-0}

# Memory usage %
MEM_USAGE=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')

# Disk usage % for /
DISK_USAGE=$(df -P / | awk 'NR==2 {gsub(/%/,"",$5); print $5}')

# Temperature (first value from sensors)
TEMP_RAW=$(sensors 2>/dev/null | awk '/\+.*C/ {gsub(/\+|C/,""); print int($1); exit}')
TEMP=${TEMP_RAW:-0}

[[ "$CPU_USAGE" -ge "$CPU_MAX" ]]  && ALERTS+=("CPU usage ${CPU_USAGE}%")
[[ "$MEM_USAGE" -ge "$MEM_MAX" ]]  && ALERTS+=("Memory usage ${MEM_USAGE}%")
[[ "$DISK_USAGE" -ge "$DISK_MAX" ]] && ALERTS+=("Disk / usage ${DISK_USAGE}%")
[[ "$TEMP" -ge "$TEMP_MAX" && "$TEMP" -ne 0 ]] && ALERTS+=("CPU temp ${TEMP}°C")

# Exit quietly if nothing is wrong
if [[ ${#ALERTS[@]} -eq 0 ]]; then
  exit 0
fi

{
  echo "server resource alert"
  echo
  echo "Triggers:"
  for a in "${ALERTS[@]}"; do
    echo " - $a"
  done
  echo
  echo "=== Uptime / Load ==="
  uptime
  echo
  echo "=== Memory ==="
  free -h
  echo
  echo "=== Disk (/) ==="
  df -h /
  echo
  echo "=== Sensors ==="
  sensors 2>/dev/null || echo "no sensor data"
} | /usr/bin/mail -s "server resource alert" "$TO_EMAIL"
