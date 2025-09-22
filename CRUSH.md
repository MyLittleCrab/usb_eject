# CRUSH.md

## Build Commands

- **Build Project**: `bash compile_macos.sh`

## Dependencies

- **macOS**: `brew install libusb`
- **Install macOS Dependencies**: `bash install_dependencies_macos.sh`

## Code Style Guidelines

- **Language**: C (C99 or later)
- **Formatting**:
    - Indentation: 4 spaces
    - Brace style: K&R (opening brace on the same line as the control statement)
    - Spaces around operators and after commas.
- **Naming Conventions**:
    - Functions: `snake_case` (e.g., `eject_device`)
    - Variables: `snake_case` (e.g., `ep_out`, `dCBWSignature`)
    - Macros: `SCREAMING_SNAKE_CASE` (e.g., `CBW_SIGNATURE`)
    - Structs: `snake_case` (e.g., `cbw`, `csw`)
    - Type definitions: `snake_case` with `_t` suffix (e.g., `device_entry`)
- **Error Handling**:
    - Check return codes of `libusb` functions.
    - Print error messages to `stderr`.
    - Clean up `libusb` resources (close handles, exit context, free lists) on error and exit.
    - Use `goto cleanup;` for centralized cleanup in functions like `eject_device`.
- **Includes**: Standard C libraries and `libusb-1.0/libusb.h`.
- **Comments**: Used sparingly to explain complex logic or sections.
