#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: source demo/set_screenshot_prompt.sh <student_number> [vm_name]"
  echo "Example: source demo/set_screenshot_prompt.sh ssalimi19 elk-vm"
  return 1 2>/dev/null || exit 1
fi

STUDENT_NUMBER="$1"
VM_NAME="${2:-$(hostname)}"

export PS1="[${VM_NAME}] ${STUDENT_NUMBER} %D{%Y-%m-%d} %* $ "
echo "Prompt updated. Run 'date' before screenshots."
