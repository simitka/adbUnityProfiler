#!/bin/zsh

check_and_install() {
    local package_number="$1"
    local package="$2"
    local install_command="$3"
    local version_command="$4"

    if ! command -v "$package" &>/dev/null; then
        echo
        echo "\033[1m❌ Error: $package is not installed.\033[0m"
        echo "To install $package, run the following command:"
        echo "$install_command"
        echo
        exit 4
    else
        echo "[$package_number] ✅ $package is installed: $(eval $version_command)"
    fi
}

download_repo() {
    echo "⏳ Downloading the repository..."
    if curl -L -o main.zip https://github.com/simitka/adbUnityProfiler/archive/refs/heads/main.zip; then
        echo "⏳ Download successful. Unpacking the archive..."

        if [[ -s main.zip ]]; then
            unzip main.zip -d .
            rm main.zip

            mv adbUnityProfiler-main/* ./
            rm -rf adbUnityProfiler-main

            if [[ -f setupScript.sh ]]; then
                echo "⏳ Removing setupScript.sh..."
                rm setupScript.sh
            fi
        else
            echo "❌ Error: The downloaded file is empty."
            exit 5
        fi
    else
        echo "❌ Error: Failed to download the repository."
        exit 6
    fi
    echo "✅ Repository downloaded and unpacked successfully."
}

move_to_actual_path() {
    if [[ ! -d "$actual_path" ]]; then
        echo "⏳ Folder '$actual_path' does not exist. Creating it..."
        mkdir -p "$actual_path" || {
            echo "❌ Error: Failed to create folder '$actual_path'."
            exit 7
        }
    else
        echo "⏳ Folder '$actual_path' exists. Moving to it..."
    fi

    setopt nullglob
    for item in * .[^.]*; do
        [[ "$item" == "." || "$item" == ".." ]] && continue

        if ! mv -- "$item" "$actual_path"/; then
            echo "❌ Error: Failed to move '$item' to '$actual_path'."
            exit 8
        else
            echo "✅ Moved: '$item' → '$actual_path/'"
        fi
    done
    unsetopt nullglob

    echo "✅ All files have been moved to '$actual_path'."

    current_dir=$(pwd)
    cd "$actual_path" ||
        {
            echo "❌ Error: Failed to change directory to '$actual_path'."
            exit 9
        }

    rmdir "$current_dir" || {
        echo "❌ Error: Failed to remove folder: '$current_dir'."
        exit 10
    }
}

rm /usr/local/bin/adbreadprofile

download_repo

source ./utils.sh

clear
echo
echo "\033[1m\033[4m$repository_name\033[0m\033[1m – A CLI tool to read Profile contents in the Unity application on Android\033[0m"
echo "any questions about how the script works – https://simitka.io"
echo
echo "⏳ Launching the setup assistant."
echo "⏳ Checking if all necessary packages are installed..."
echo "============================================================"

check_and_install "1" "brew" "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" "brew --version"
check_and_install "2" "jq" "brew install jq" "jq --version"
check_and_install "3" "adb" "brew install android-platform-tools" "adb --version"

echo "============================================================"
echo
echo "\033[1m📝 Enter the path to the folder where $repository_name will be installed:\033[0m"
echo "(or leave it blank and press Enter↵ to set to $default_path)"
read -r user_path

if [[ -z "$user_path" ]]; then
    actual_path="$default_path"
else
    actual_path="$user_path"
fi

move_to_actual_path

cat <<EOL >$config_file
actualPath:$actual_path
appBundleName:null
EOL

echo
echo
echo "\033[1m⏳ Creating the console command '$command_to_run' to run $repository_name\033[0m"
echo "(📝 enter the password from your MacOS user. The password is not displayed when you enter it)"

if [[ ! -d "/usr/local/bin" ]]; then
    echo "⏳ The '/usr/local/bin' folder does not exist. Creating it..."
    sudo mkdir -p /usr/local/bin
fi

temp_script="$HOME/${repository_name}_temp"
echo '#!/bin/zsh' >"$temp_script"
echo "cd $actual_path && ./start.sh" >>"$temp_script"

sudo mv "$temp_script" /usr/local/bin/$command_to_run
sudo chmod +x /usr/local/bin/$command_to_run

chmod +x start.sh
clear
$command_to_run
