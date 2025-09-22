#!/bin/bash
set -e

# Проверяем наличие Homebrew
if ! command -v brew &>/dev/null; then
    echo "Homebrew не найден. Устанавливаем Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew уже установлен."
fi

# Обновляем Homebrew
echo "Обновляем Homebrew..."
brew update

# Проверяем наличие libusb
if ! brew list libusb &>/dev/null; then
    echo "libusb не найден. Устанавливаем libusb..."
    brew install libusb
else
    echo "libusb уже установлен."
fi

echo "Все зависимости установлены."

