#!/bin/zsh

source ./utils.sh

setup_app_bundle() {
  clear
  echo "You need to specify the bundle name of the application whose profiles you want to work with."
  echo
  bold_text "$(reverse_text 'Select an option from the list and enter the corresponding number:')"
  echo "    [1] Find out the app Bundle name automatically"
  echo "    [2] Specify the app Bundle name manually"

  echo -n "📝 Enter a number from list: "
  read choice

  if [[ "$choice" =~ ^[1-2]$ ]]; then
    case "$choice" in
    1)
      echo
      echo
      underline_text "In order to automatically get the bundle name:"
      echo "    1. Enable debugging mode via ADB on the device"
      echo "    2. Connect the device to the computer"
      echo "    3. Launch the desired application"
      echo "    4. Press any button to continue"
      wait_for_any_key

      echo
      bundle=$(adb -s "$device" shell dumpsys window | grep -E 'mCurrentFocus|mFocusedApp' | grep -oE '[a-zA-Z0-9_.]+/[a-zA-Z0-9_.]+' | head -n1 | cut -d'/' -f1)
      echo "⏳ App with bundle name = '$bundle' is currently running on the $device device."
      echo "✅  Profiles will be read on the path /sdcard/Android/data/$bundle/files/profiles"

      if grep -q '^appBundleName:' "$config_file"; then
        sed -i '' "s/^appBundleName:.*/appBundleName:$bundle/" "$config_file"
      else
        echo ❌ devError: There is no key appBundleName in the file $config_file
      fi

      wait_for_any_key
      $command_to_run
      ;;
    2)
      clear
      echo -n "📝 Enter an app Bundle name: "
      read bundle

      if grep -q '^appBundleName:' "$config_file"; then
        sed -i '' "s/^appBundleName:.*/appBundleName:$bundle/" "$config_file"
      else
        echo ❌ devError: There is no key appBundleName in the file $config_file
      fi
      finalize
      ;;
    esac
  else
    clear
    red_bg "$(bold_text '❌ Error: Enter a number from 1 to 2 and press Enter↵')"
    red_bg "$(bold_text '==============================================================')"
    echo
    echo
    setup_app_bundle
  fi
}

choose_adb
clear

if ! grep -q '^appBundleName:' "$config_file"; then
  echo "appBundleName:null" >>"$config_file"
fi

app_bundle_name=$(grep '^appBundleName:' "$config_file" | cut -d':' -f2 | xargs)

if [[ "$app_bundle_name" == "null" ]]; then
  setup_app_bundle
else

  echo "⏳ Checking devices connected to ADB..."
  clear

  echo "✅ Script is ready to read profiles from the $device device on path /sdcard/Android/data/$app_bundle_name/files/profiles"
  echo
  bold_text "$(reverse_text 'Select an option from the list and enter the corresponding number:')"
  echo "    [1] Read profiles"
  echo "    [2] Set a different bundle name for reading profiles"
  echo "    [3] Close the script"

  echo -n "📝 Enter a number from list: "
  read choice

  if [[ "$choice" =~ ^[1-2]$ ]]; then
    case "$choice" in
    1)
      ./chooseProfile.sh "$device"
      ;;
    2)
      sed -i '' "s/^appBundleName:.*/appBundleName:null/" "$config_file"
      clear
      setup_app_bundle
      ;;
    3)
      exit 0
      ;;
    esac
  else
    clear
    red_bg "$(bold_text '❌ Error: Enter a number from 1 to 2 and press Enter↵')"
    red_bg "$(bold_text '==============================================================')"
    echo
    echo
    setup_app_bundle
  fi
fi
