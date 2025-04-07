#!/bin/zsh

source ./utils.sh

app_bundle_name=$(grep '^appBundleName:' "settings.conf" | cut -d':' -f2 | xargs)
profiles_path="/sdcard/Android/data/$app_bundle_name/files/profiles"
device="$1"

clear

if ! adb -s "$device" shell "[ -d $profiles_path ]"; then
    echo "❌ Error: Folder $profiles_path does not exist."
    exit 11
fi

files=()
while IFS= read -r line; do
    [[ -n "$line" ]] && files+=("$line")
done < <(adb -s "$device" shell "ls -1 $profiles_path | grep '.json$'")

if [[ ${#files} -eq 0 ]]; then
    echo "❌ Error: No .json files found in $profiles_path"
    exit 12
fi

bold_text "$(reverse_text "Select a profile from the list below to read")"
for i in {1..$#files}; do
    echo "    [$i] $files[i]"
done

echo -n "📝 Enter the number of the profile from the list above: "
read profile_number

if [[ "$profile_number" =~ '^[0-9]+$' ]] && ((profile_number >= 1 && profile_number <= $#files)); then
    selected_file="$files[profile_number]"
    echo "📁 Selected file: $selected_file"
    ./readProfile.sh "$device" "$selected_file" "$profiles_path"
else
    echo "❌ Error: Invalid profile number entered."
    wait_for_any_key
    ./chooseProfile.sh "$device"
fi
