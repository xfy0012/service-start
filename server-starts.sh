#!/bin/bash

echo "========================="
echo "Service Performance Stats"
echo "========================="
echo

# Detect platform
platform="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  platform="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  platform="macos"
fi

# ==== CPU USAGE ====
echo "=========================="
echo "-- CPU Usage --"
echo "=========================="
echo

if [ "$platform" = "linux" ]; then
  cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d. -f1)
  cpu_usage=$((100 - cpu_idle))
elif [ "$platform" = "macos" ]; then
  cpu_idle=$(top -l 1 | grep "CPU usage" | awk '{print $7}' | tr -d '%')
  cpu_usage=$(echo "scale=0; 100 - $cpu_idle" | bc)
else
  cpu_usage="N/A"
fi

echo "CPU Usage: $cpu_usage%"
echo

# ==== MEMORY USAGE ====
echo "=========================="
echo "-- Memory Usage --"
echo "=========================="
echo

if [ "$platform" = "linux" ]; then
  mem_total=$(free -m | awk '/Mem:/ {print $2}')
  mem_used=$(free -m | awk '/Mem:/ {print $3}')
  mem_free=$(free -m | awk '/Mem:/ {print $4}')
  mem_usage_percent=$((100 * mem_used / mem_total))
elif [ "$platform" = "macos" ]; then
  mem_stats=$(top -l 1 | grep PhysMem)
  mem_used=$(echo $mem_stats | awk '{print $2}' | sed 's/M//')
  mem_unused=$(echo $mem_stats | awk '{print $10}' | sed 's/M//')
  mem_total=$((mem_used + mem_unused))
  mem_usage_percent=$((100 * mem_used / mem_total))
else
  mem_total="N/A"
  mem_used="N/A"
  mem_usage_percent="N/A"
fi

echo "Total Memory: ${mem_total} MB"
echo "Used Memory: ${mem_used} MB"
echo "Memory Usage: ${mem_usage_percent}%"
echo

# ==== DISK USAGE ====
echo "=========================="
echo "-- Disk Usage --"
echo "=========================="
echo

disk_total=$(df -h / | awk 'NR==2 {print $2}')
disk_used=$(df -h / | awk 'NR==2 {print $3}')
disk_avail=$(df -h / | awk 'NR==2 {print $4}')
disk_usage_percent=$(df -h / | awk 'NR==2 {print $5}')

echo "Total Disk Space: $disk_total"
echo "Used Disk Space: $disk_used"
echo "Available: $disk_avail"
echo "Disk Usage: $disk_usage_percent"
echo

# ==== TOP 5 PROCESSES BY CPU ====
echo "=========================="
echo "-- Top 5 Processes by CPU Usage --"
echo "=========================="
echo

if [ "$platform" = "linux" ]; then
  ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
elif [ "$platform" = "macos" ]; then
  echo "PID   COMMAND         %CPU"
  ps aux | sort -nrk 3 | head -n 5 | awk '{printf "%-6s %-15s %s\n", $2, $11, $3}'
fi
echo


# ==== TOP 5 PROCESSES BY MEMORY ====
echo "=========================="
echo "-- Top 5 Processes by Memory Usage --"
echo "=========================="
echo

if [ "$platform" = "linux" ]; then
  ps -eo pid,comm,%mem --sort=-%mem | head -n 6
elif [ "$platform" = "macos" ]; then
  echo "PID   COMMAND         %MEM"
  ps aux | sort -nrk 4 | head -n 5 | awk '{printf "%-6s %-15s %s\n", $2, $11, $4}'
fi
echo
