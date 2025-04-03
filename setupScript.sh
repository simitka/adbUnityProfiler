#!/bin/zsh

rm setupScript.sh

clear
echo
echo "\033[1m\033[4m$repository_name\033[0m\033[1m – helps to read the Profile contents in the Unity application on Android\033[0m"
echo "any questions about how the script works – https://simitka.io"
echo
echo "⏳ Launching the setup assistant."
echo "⏳ Check that all the necessary packages are installed..."
echo "============================================================"

check_and_install() {
    local package_number="$1"
    local package="$2"
    local install_command="$3"
    local version_command="$4"

    if ! command -v "$package" &>/dev/null; then
        echo
        echo "\033[1m❌ Error: $package is not installed.\033[0m"
        echo "To install the $package, enter the command:"
        echo "$install_command"
        echo
        exit 2
    else
        echo "[$package_number] ✅ $package is installed: $(eval $version_command)"
    fi
}

check_and_install "1" "brew" "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" "brew --version"
check_and_install "2" "jq" "brew install jq" "jq --version"
check_and_install "3" "adb" "brew install android-platform-tools" "adb --version"

default_path="$HOME/Documents/$repository_name"

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

mkdir -p "$actual_path"
cd "$actual_path" || {
    echo "❌ Error: couldn't create folder in $actual_path"
    exit 3
}

curl -O https://raw.githubusercontent.com/Simitka/adbUnityProfiler/main/start.sh

cat <<EOL >$config_file
actualPath:$actual_path
appBundleName:null
EOL

echo
echo
echo "\033[1m⏳ Creating the console command '$command_to_run', which will run $repository_name\033[0m"
echo "(📝 enter the password from your MacOS user. The password is not displayed when you enter it.)"

if [[ ! -d "/usr/local/bin" ]]; then
    echo "⏳ /usr/local/bin folder does not exist. Creating it..."
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
