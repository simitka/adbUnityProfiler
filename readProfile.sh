#!/bin/zsh

source utils.sh

device="$1"
selected_file="$2"
profiles_path="$3"
file_path="$profiles_path/$selected_file"

if [ -z "$1" ]; then
  echo "❌ Error: ADB device is not specified."
  echo "Usage: $0 <adb_device> <json_file_name> <profiles_path>"
  exit 13
fi

if [ -z "$2" ]; then
  echo "❌ Error: JSON file name is not specified."
  echo "Usage: $0 <adb_device> <json_file_name> <profiles_path>"
  exit 14
fi

if [ -z "$3" ]; then
  echo "❌ Error: Path to the profiles folder is not specified."
  echo "Usage: $0 <adb_device> <json_file_name> <profiles_path>"
  exit 15
fi

read_profile_on_keypress() {
  trap handle_interrupt INT
  update_count=0
  read_profile_state="true"
  while [[ "$read_profile_state" == "true" ]]; do
    update_count=$((update_count + 1))
    current_time=$(date "+%Y-%m-%d %H:%M:%S")
    echo "-------------------------------"
    bold_text "$(dim_text "Press any key to fetch the current file content")"
    bold_text "$(dim_text "or press Control⌃ + C to return to the menu.")"
    echo
    echo "📄 File path: $file_path"
    echo "⏰ Last updated: $current_time"
    echo "🔁 Update count: $update_count"
    echo
    adb -s "$device" shell "cat $file_path" | jq .
    dd bs=1 count=1 >/dev/null 2>&1
  done
}

read_profile_with_interval() {
  trap handle_interrupt INT
  update_count=0
  read_profile_state="true"
  while [[ "$read_profile_state" == "true" ]]; do
    update_count=$((update_count + 1))
    current_time=$(date "+%Y-%m-%d %H:%M:%S")
    echo "-------------------------------"
    bold_text "$(dim_text "Press Control⌃ + C to return to the menu.")"
    echo
    echo "📄 File path: $file_path"
    echo "🔃 Refresh interval: $interval seconds"
    echo "⏰ Last updated: $current_time"
    echo "🔁 Update count: $update_count"
    echo
    adb -s "$device" shell "cat $file_path" | jq .
    sleep "$interval"
  done
}

handle_interrupt() {
  trap - INT
  stty sane
  read_profile_state="false"
  echo
  echo "👋 Returning to the menu..."
  sleep 1
  $command_to_run
}

echo "-------------------------------"
echo "📝 Press Enter↵ to update the profile content manually by pressing any key"
echo -n "\033[3mOr enter a refresh interval in seconds for automatic updates: \033[0m"

read user_input
clear
echo

if [[ -z "$user_input" ]]; then
  interval=0
  read_profile_on_keypress
elif [[ "$user_input" =~ ^[0-9]+$ ]] && [ "$user_input" -gt 0 ]; then
  interval=$user_input
  read_profile_with_interval
else
  echo "❌ Error: Invalid input. Please enter update interval in seconds or leave empty for manual mode."
  wait_for_any_key
  ./chooseProfile.sh "$device"
fi
