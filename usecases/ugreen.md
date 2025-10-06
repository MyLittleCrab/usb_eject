# UGREEN USB Wi-Fi Dongle (AC650 and similar models based on Realtek 802.11ac) Use Case

This document describes a common use case for the `Eject2Net` utility when dealing with a UGREEN USB Wi-Fi dongle (featuring a Realtek 802.11ac chip) on macOS.

## Problem

UGREEN USB Wi-Fi dongles, like many other USB peripherals, sometimes initially present themselves as a virtual CD-ROM drive containing drivers. While there's a community-supported driver available for the Realtek 802.11ac chip (e.g., [chris1111/Wireless-USB-OC-Big-Sur-Adapter](https://github.com/chris1111/Wireless-USB-OC-Big-Sur-Adapter)), it cannot interact with the device as long as it's in the CD-ROM mode.

## Solution for macOS

To get your UGREEN USB Wi-Fi dongle working correctly on macOS, follow these steps:

### 1. Install the Community Driver

Follow the instructions provided by the community driver project for installation. This typically involves:

*   **Disabling `csrutil` (System Integrity Protection)**: This is often required for installing third-party kernel extensions (KEXTs) on macOS. Make sure to re-enable it after installation if you understand the security implications.
*   **Disabling Gatekeeper**: You might need to temporarily disable Gatekeeper to allow the installation of unsigned applications or drivers.

Refer to the specific driver's documentation for detailed installation steps. You will likely need to restart your computer after driver installation.

### 2. Install `Eject2Net` Dependencies

Ensure you have the `Eject2Net` utility built and ready to use. If you haven't already, follow the "How to Use" section in the main `README.md` to:

*   Install `libusb` and `pkg-config` using `make install-deps`.
*   Compile the `Eject2Net` program using `make`.

Alternatively, if you are on macOSx64, you can directly use the pre-compiled binary provided in the project root by running `./Eject2Net`.

### 3. Eject the Virtual CD-ROM After Each Connection

Because the device reverts to CD-ROM mode each time it's connected, you will need to run `Eject2Net` every time you plug in your Wi-Fi adapter:

1.  Connect your UGREEN USB Wi-Fi dongle to your Mac.
2.  Run the `Eject2Net` utility:
    ```bash
    ./Eject2Net
    ```
3.  From the list of detected USB devices, identify your UGREEN Wi-Fi dongle (by VID:PID, Manufacturer, or Product name) and enter its corresponding number to eject it.

Once ejected, your installed Wi-Fi driver should now be able to correctly detect and interact with the adapter, allowing you to use your Wi-Fi.

---

# Пример использования USB Wi-Fi адаптера UGREEN AC650 и аналогичные модели на базе Realtek 802.11ac

Этот документ описывает распространенный сценарий использования утилиты `Eject2Net` при работе с USB Wi-Fi адаптером UGREEN (с чипом Realtek 802.11ac) на macOS.

## Проблема

USB Wi-Fi адаптеры UGREEN, как и многие другие USB-периферийные устройства, иногда изначально представляются как виртуальный CD-ROM привод, содержащий драйверы. Хотя для чипа Realtek 802.11ac существует поддерживаемый сообществом драйвер (например, [chris1111/Wireless-USB-OC-Big-Sur-Adapter](https://github.com/chris1111/Wireless-USB-OC-Big-Sur-Adapter)), он не может взаимодействовать с устройством, пока оно находится в режиме CD-ROM.

## Решение для macOS

Чтобы ваш USB Wi-Fi адаптер UGREEN заработал правильно на macOS, выполните следующие шаги:

### 1. Установите драйвер сообщества

Следуйте инструкциям по установке, предоставленным проектом драйвера сообщества. Обычно это включает:

*   **Отключение `csrutil` (Защита целостности системы)**: Это часто требуется для установки сторонних расширений ядра (KEXT) на macOS. Обязательно включите его обратно после установки, если вы понимаете последствия для безопасности.
*   **Отключение Gatekeeper**: Возможно, вам придется временно отключить Gatekeeper, чтобы разрешить установку неподписанных приложений или драйверов.

Обратитесь к документации конкретного драйвера для получения подробных инструкций по установке. После установки драйвера вам, скорее всего, потребуется перезагрузить компьютер.

### 2. Установите зависимости для `Eject2Net`

Убедитесь, что утилита `Eject2Net` собрана и готова к использованию. Если вы еще этого не сделали, следуйте разделу «Как пользоваться» в основном файле `README.md`, чтобы:

*   Установить `libusb` и `pkg-config` с помощью `make install-deps`.
*   Скомпилировать программу `Eject2Net` с помощью `make`.

В качестве альтернативы, если вы используете macOSx64, вы можете напрямую использовать предварительно скомпилированный бинарный файл, предоставленный в корне проекта, запустив `./Eject2Net`.

### 3. Извлекайте виртуальный CD-ROM после каждого подключения

Поскольку устройство возвращается в режим CD-ROM при каждом подключении, вам потребуется запускать `Eject2Net` каждый раз, когда вы подключаете Wi-Fi адаптер к компьютеру:

1.  Подключите USB Wi-Fi адаптер UGREEN к вашему Mac.
2.  Запустите утилиту `Eject2Net`:
    ```bash
    ./Eject2Net
    ```
3.  Из списка обнаруженных USB-устройств идентифицируйте ваш Wi-Fi адаптер UGREEN (по VID:PID, производителю или названию продукта) и введите соответствующий номер для его извлечения.

После извлечения установленный драйвер Wi-Fi должен правильно обнаружить адаптер и взаимодействовать с ним, позволяя вам использовать Wi-Fi.
