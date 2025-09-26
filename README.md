# usb_eject

This utility automates the process of ejecting USB devices that initially appear as virtual CD-ROM drives containing drivers (such as some Wi-Fi adapters and modems), allowing the device to switch to its intended working mode without manual intervention.

## How to Use

### 1. Build the Project

**Note for macOSx64 users**: A pre-compiled binary `usb_eject` is included in the repository. If you are on macOSx64, you can skip the build steps and directly use the provided binary by running `./usb_eject`. (if you have the libusb library installed. If not -- look at the section **"installing dependencies".**)

To compile the `usb_eject` utility, a `Makefile` is provided for both **macOS** and **Debian-like Linux** distributions.

#### Install Dependencies

First, install the necessary dependencies for your operating system:

**macOS or Debian-like Linux (e.g., Ubuntu, Debian):**
```bash
make install-deps
```

This command will use `Homebrew` on macOS and `apt` on Linux to install `libusb` and `pkg-config`. It may require `sudo` for Linux.

#### Compile

After installing dependencies, compile the project using `make`:
```bash
make
```
This will create an executable file named `usb_eject` in the project root directory.

### 2. Run the Utility

Execute the compiled program:
```bash
sudo ./usb_eject
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

Эта утилита автоматически извлекает USB-устройства, которые изначально определяются как виртуальный CD-ROM с драйверами (например, некоторые Wi-Fi адаптеры и модемы), чтобы устройство сразу переходило в рабочий режим без ручных действий.

## Как пользоваться

### 1. Сборка проекта

**Примечание для пользователей macOSx64**: Предварительно скомпилированный бинарный файл `usb_eject` включен в репозиторий. Если вы используете macOSx64, вы можете пропустить шаги сборки и напрямую использовать предоставленный бинарный файл, запустив `./usb_eject` (при условии, что у вас установлена библиотека libusb. Если нет -- посмотрите на пункт **"установка зависимостей"**).

Для компиляции утилиты `usb_eject` предоставляется `Makefile` как для macOS, так и для дистрибутивов Linux на базе Debian.

#### Установка зависимостей

Сначала установите необходимые зависимости для вашей операционной системы:

**macOS или Debian-подобные дистрибутивы Linux (например, Ubuntu, Debian):**
```bash
make install-deps
```

Эта команда будет использовать `Homebrew` на macOS и `apt` в Linux для установки `libusb` и `pkg-config`. Для Linux может потребоваться `sudo`.

#### Компиляция

После установки зависимостей скомпилируйте проект с помощью `make`:
```bash
make
```
Это создаст исполняемый файл с именем `usb_eject` в корневом каталоге проекта.

### 2. Запуск утилиты

Запустите скомпилированную программу:
```bash
sudo ./usb_eject
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
