#!/usr/bin/env bash
set -euo pipefail

MIN_CPU=2
MIN_MEM_GB=8

if command -v nproc >/dev/null 2>&1; then
  CPU_COUNT="$(nproc)"
else
  CPU_COUNT="$(getconf _NPROCESSORS_ONLN)"
fi

if [[ -r /proc/meminfo ]]; then
  MEM_KB="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
  MEM_GB="$(awk -v kb="${MEM_KB}" 'BEGIN {printf "%.2f", kb/1024/1024}')"
else
  echo "Could not read /proc/meminfo. Run this script on Linux VM."
  exit 1
fi

cpu_ok=0
mem_ok=0

if (( CPU_COUNT >= MIN_CPU )); then
  cpu_ok=1
fi

if awk -v mem="${MEM_GB}" -v min="${MIN_MEM_GB}" 'BEGIN {exit !(mem >= min)}'; then
  mem_ok=1
fi

echo "=== VM Requirement Check ==="
echo "Detected CPU cores : ${CPU_COUNT} (required: >= ${MIN_CPU})"
echo "Detected RAM (GB)  : ${MEM_GB} (required: >= ${MIN_MEM_GB})"

if (( cpu_ok == 1 && mem_ok == 1 )); then
  echo "Result: PASS"
  exit 0
fi

echo "Result: FAIL"
echo "Increase VM resources before proceeding."
exit 2
