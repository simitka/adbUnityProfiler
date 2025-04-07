#!/bin/zsh

source utils.sh

device="$1"
selected_file="$2"
profiles_path="$3"
file_path="$profiles_path/$selected_file"

if [ -z "$1" ]; then
  echo "❌ Error: ADB device is not specified"
  echo "Usage: $0 <adb_device> <json_file_name> <profiles_path>"
  exit 14
fi

if [ -z "$2" ]; then
  echo "❌ Error: JSON file name is not specified"
  echo "Usage: $0 <adb_device> <json_file_name> <profiles_path>"
  exit 15
fi

if [ -z "$3" ]; then
  echo "❌ Error: Path to profiles folder is not specified"
  echo "Usage: $0 <adb_device> <json_file_name> <profiles_path>"
  exit 16
fi

read_profile_on_keypress() {
  trap handle_interrupt SIGINT
  while true; do
    current_time=$(date "+%Y-%m-%d %H:%M:%S")
    echo "⏳ Reading file: $file_path"
    echo "Last updated: $current_time"
    echo "🔁 Press any key to refresh (Ctrl+C to exit)"
    bold_text "$(dim_text "Press Control⌃ + C to stop the script")"
    echo "-------------------------------"
    echo
    adb -s "$device" shell "cat $file_path" | jq .
    read -r -n 1
  done
}

read_profile_with_interval() {
  trap handle_interrupt SIGINT
  clear
  update_count=$((update_count + 1))
  current_time=$(date "+%Y-%m-%d %H:%M:%S")
  bold_text "$(dim_text "Press Control⌃ + C to stop the script")"
  echo ""
  echo "Refresh interval: $interval seconds"
  echo "Update count: $update_count"
  echo "Last updated: $current_time"
  echo "-------------------------------"
  echo
  echo "⏳ Reading file: $file_path"
  adb -s "$device" shell "cat $file_path" | jq .
  echo "-------------------------------"
  sleep "$interval"
}

handle_interrupt() {
  echo ""
  echo "👋 Exit triggered! Launching $command_to_run..."
  $command_to_run
  exit 0
}

echo "-------------------------------"
echo "📝 Enter refresh interval in seconds"
echo -e "\033[3mOr press Enter↵ to refresh only when a key is pressed\033[0m"

read -r user_input

if [[ -z "$user_input" ]]; then
  interval=0
elif [[ "$user_input" =~ ^[0-9]+$ ]] && [ "$user_input" -gt 0 ]; then
  interval=$user_input
else
  echo "❌ Invalid input. Interval must be a positive integer or empty"
  exit 20
fi

if [[ "$interval" == "0" ]]; then
  read_profile_on_keypress
elif [[ "$interval" =~ ^[1-9][0-9]*$ ]]; then
  update_count=0
  read_profile_with_interval
else
  echo "❌ Error: interval must be 0 or a positive integer"
  exit 20
fi
