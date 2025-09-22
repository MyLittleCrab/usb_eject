# usb_eject

This project provides a utility to "eject" USB devices that initially present themselves as a virtual CD-ROM drive containing drivers. This is a common practice by some manufacturers to simplify driver installation, but it can prevent the device from functioning as intended until the virtual CD-ROM is ejected. This tool automates that ejection process.

## Problem Solved

Many USB peripheral devices (like certain Wi-Fi adapters, modems, etc.) initially appear to the operating system as a USB CD-ROM drive. This virtual drive often contains the necessary drivers for the device. However, to use the device for its primary function (e.g., as a network adapter or modem), the virtual CD-ROM needs to be "ejected" first. This tool sends the necessary SCSI command to perform this ejection, allowing the device to switch to its intended operational mode.

## How to Use

### 1. Build the Project (macOS)

**Note for macOSx64 users**: A pre-compiled binary `usb_eject` is included in the repository. If you are on macOSx64, you can skip the build steps and directly use the provided binary by running `./usb_eject`.

To compile the `usb_eject` utility on macOS, you need `libusb`.

You can run the provided script to install dependencies:
```bash
bash install_dependencies_macos.sh
```

Alternatively, you can install dependencies manyally if you don't have it:

Install `Homebrew`:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then, install `libusb` using Homebrew:
```bash
brew install libusb
```

After dependencies are installed, compile the project:
```bash
bash compile_macos.sh
```
This will create an executable file named `usb_eject` in the project root directory.

### 2. Run the Utility

Execute the compiled program:
```bash
./usb_eject
```

The program will list all connected USB devices with their Vendor ID (VID) and Product ID (PID), along with their manufacturer and product names if available.

```
Connected USB devices:
 1) VID:PID = 046d:c52b | Manufacturer: Logitech | Product: USB Receiver
 2) VID:PID = 0bda:8179 | Manufacturer: Realtek | Product: 802.11n WLAN Adapter
Enter the number of device to eject:
```

### 3. Select a Device

Enter the number corresponding to the USB device you wish to eject (the one acting as a virtual CD-ROM). The tool will then send the ejection command to that device.

```
Enter the number of device to eject: 2
Ejecting device 0bda:8179 ...
Using interface 0: ep_out=0x02 ep_in=0x81
CBW sent (31 bytes)
Eject command successful, CSW status=0x00
```

After a successful ejection, your device should now be recognized by the system in its intended mode, and you can proceed with driver installation or usage.

# usb_eject (Русский)

Этот проект предоставляет утилиту для «извлечения» USB-устройств, которые изначально представляются как виртуальный CD-ROM привод, содержащий драйверы. Это распространенная практика некоторых производителей для упрощения установки драйверов, но она может помешать устройству функционировать по назначению до тех пор, пока виртуальный CD-ROM не будет извлечен. Этот инструмент автоматизирует процесс извлечения.

## Решаемая проблема

Многие периферийные USB-устройства (например, некоторые Wi-Fi адаптеры, модемы и т. д.) изначально представляются операционной системе как USB CD-ROM привод. Этот виртуальный привод часто содержит необходимые драйверы для устройства. Однако, чтобы использовать устройство по его основному назначению (например, в качестве сетевого адаптера или модема), виртуальный CD-ROM необходимо сначала «извлечь». Этот инструмент отправляет необходимую команду SCSI для выполнения этого извлечения, позволяя устройству переключиться в предполагаемый рабочий режим.

## Как пользоваться

### 1. Сборка проекта (macOS)

**Примечание для пользователей macOSx64**: Предварительно скомпилированный бинарный файл `usb_eject` включен в репозиторий. Если вы используете macOSx64, вы можете пропустить шаги сборки и напрямую использовать предоставленный бинарный файл, запустив `./usb_eject`.

Для компиляции утилиты `usb_eject` на macOS вам понадобится `libusb`.

Вы можете запустить предоставленный скрипт для установки зависимостей:
```bash
bash install_dependencies_macos.sh
```

В качестве альтернативы, вы можете установить зависимости вручную, если у вас их нет:

Установите `Homebrew`:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Затем установите `libusb` с помощью Homebrew:
```bash
brew install libusb
```

После установки зависимостей скомпилируйте проект:
```bash
bash compile_macos.sh
```
Это создаст исполняемый файл с именем `usb_eject` в корневом каталоге проекта.

### 2. Запуск утилиты

Запустите скомпилированную программу:
```bash
./usb_eject
```

Программа выведет список всех подключенных USB-устройств с их Vendor ID (VID) и Product ID (PID), а также названиями производителя и продукта, если они доступны.

```
Connected USB devices:
 1) VID:PID = 046d:c52b | Manufacturer: Logitech | Product: USB Receiver
 2) VID:PID = 0bda:8179 | Manufacturer: Realtek | Product: 802.11n WLAN Adapter
Enter the number of device to eject:
```

### 3. Выбор устройства

Введите номер, соответствующий USB-устройству, которое вы хотите извлечь (то, которое действует как виртуальный CD-ROM). Затем инструмент отправит команду извлечения этому устройству.

```
Enter the number of device to eject: 2
Ejecting device 0bda:8179 ...
Using interface 0: ep_out=0x02 ep_in=0x81
CBW sent (31 bytes)
Eject command successful, CSW status=0x00
```

После успешного извлечения ваше устройство должно быть распознано системой в его предполагаемом режиме, и вы сможете продолжить установку драйверов или использование.
