#!/bin/zsh

config_file="settings.conf"
repository_name="adbUnityProfiler"
command_to_run="adbreadprofile"

#Для примера выхова функции в функции – bold_text "$(red_text 'Красный жирный текст')"

# Функция для вывода текста жирным
bold_text() {
    echo "$(tput bold)$1$(tput sgr0)"
}

# Функция для вывода тусклого текста
dim_text() {
    echo "$(tput dim)$1$(tput sgr0)"
}

# Функция для вывода подчеркнутого текста
underline_text() {
    echo "$(tput smul)$1$(tput sgr0)"
}

# Функция для инверсии цветов (фон ↔ текст)
reverse_text() {
    echo "$(tput rev)$1$(tput sgr0)"
}

# Функция для мигающего текста (не всегда работает)
blink_text() {
    echo "$(tput blink)$1$(tput sgr0)"
}

# Функция для невидимого текста (его можно скопировать и вставить)
invisible_text() {
    echo "$(tput invis)$1$(tput sgr0)"
}

#
#
#

# Функция для вывода текста красным цветом
red_text() {
    echo "$(tput setaf 1)$1$(tput sgr0)"
}

# Функция для вывода текста зеленым цветом
green_text() {
    echo "$(tput setaf 2)$1$(tput sgr0)"
}

# Функция для вывода текста желтым цветом
yellow_text() {
    echo "$(tput setaf 3)$1$(tput sgr0)"
}

# Функция для вывода текста синим цветом
blue_text() {
    echo "$(tput setaf 4)$1$(tput sgr0)"
}

# Функция для вывода текста пурпурным (фиолетовым) цветом
magenta_text() {
    echo "$(tput setaf 5)$1$(tput sgr0)"
}

# Функция для вывода текста бирюзовым (циановым) цветом
cyan_text() {
    echo "$(tput setaf 6)$1$(tput sgr0)"
}

# Функция для вывода текста белым цветом
white_text() {
    echo "$(tput setaf 7)$1$(tput sgr0)"
}

# Функция для вывода текста черным цветом (может быть невидимым в темных темах)
black_text() {
    echo "$(tput setaf 0)$1$(tput sgr0)"
}

#
#
#

# Функция для чёрного фона
black_bg() {
    echo "$(tput setab 0)$1$(tput sgr0)"
}

# Функция для красного фона
red_bg() {
    echo "$(tput setab 1)$1$(tput sgr0)"
}

# Функция для зелёного фона
green_bg() {
    echo "$(tput setab 2)$1$(tput sgr0)"
}

# Функция для жёлтого фона
yellow_bg() {
    echo "$(tput setab 3)$1$(tput sgr0)"
}

# Функция для синего фона
blue_bg() {
    echo "$(tput setab 4)$1$(tput sgr0)"
}

# Функция для пурпурного (фиолетового) фона
magenta_bg() {
    echo "$(tput setab 5)$1$(tput sgr0)"
}

# Функция для голубого (цианового) фона
cyan_bg() {
    echo "$(tput setab 6)$1$(tput sgr0)"
}

# Функция для белого фона
white_bg() {
    echo "$(tput setab 7)$1$(tput sgr0)"
}

show_text_styles() {
    echo "Примеры форматирования текста:"
    echo "---------------------------------"

    # Основные стили
    bold_text "Жирный текст"
    dim_text "Тусклый текст"
    underline_text "Подчеркнутый текст"
    blink_text "Мигающий текст (не всегда работает)"
    reverse_text "Инвертированный текст"
    invisible_text "Невидимый текст (копируй и вставляй)"

    echo "---------------------------------"

    # Цвета текста
    red_text "Красный текст"
    green_text "Зеленый текст"
    yellow_text "Желтый текст"
    blue_text "Синий текст"
    magenta_text "Пурпурный текст"
    cyan_text "Бирюзовый текст"
    white_text "Белый текст"
    black_text "Черный текст (может быть невидимым)"

    echo "---------------------------------"

    # Цвета фона
    red_bg "Красный фон"
    green_bg "Зеленый фон"
    yellow_bg "Желтый фон"
    blue_bg "Синий фон"
    magenta_bg "Пурпурный фон"
    cyan_bg "Бирюзовый фон"
    white_bg "Белый фон"
    black_bg "Черный фон"

    echo "---------------------------------"

    # Комбинации форматирования
    bold_text "$(underline_text "Жирный + Подчеркнутый")"
    red_text "$(bold_text "Красный + Жирный")"
    yellow_text "$(bold_text "$(underline_text "Жирный + Подчеркнутый + Желтый")")"
    cyan_bg "$(black_text "Черный текст на бирюзовом фоне")"

    echo "---------------------------------"

    echo "🎨 Все стили применены! 🚀"
}

#
#
#

# Функция для вывода сообщения и выполнения команды farmx
function finalize() {
    echo
    reverse_text "To continue, press any button..."
    stty -icanon
    dd bs=1 count=1 >/dev/null 2>&1
    stty icanon
    $command_to_run
}

function wait_for_any_key() {
    reverse_text "To continue, press any button..."
    read -k 1 -s
}

function choose_adb() {
    devices=($(adb devices | awk 'NR>1 && $2=="device" {print $1}'))
    device_count=${#devices[@]}

    if [[ $device_count -eq 0 ]]; then
        echo "❌ Error: There are no devices connected to ADB."
        finalize
        exit 5
    fi

    # Если одно устройство
    if [[ $device_count -eq 1 ]]; then
        device=${devices[1]}
    else

        # Если несколько устройств
        bold_text "$(reverse_text 'There are several devices connected to ADB. Select one from the list:')"

        for ((i = 0; i < device_count; i++)); do
            echo "    [$((i + 1))] ${devices[i + 1]}"
        done

        echo -n "📝 Enter a number from list: "
        read device_choice
        echo

        # Проверка корректности ввода
        if ! [[ $device_choice =~ ^[0-9]+$ ]] || [[ $device_choice -lt 1 ]] || [[ $device_choice -gt $device_count ]]; then
            echo "❌ Error: Incorrect device selection"
            finalize
            exit 6
        fi

        device=${devices[$((device_choice))]}
    fi
}
