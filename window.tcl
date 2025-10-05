package require Tk

# --- Главное окно ---
wm title . "Select Device"
wm geometry . 650x550

# --- Список устройств ---
listbox .list -selectmode single -height 5
pack .list -fill both -expand 1 -padx 10 -pady 10

# Получить список устройств через usb_eject --only-list
set devices [split [exec ./usb_eject --only-list] "\n"]
foreach line $devices {
    .list insert end $line
}

# --- Кнопки ---
frame .buttons
pack .buttons -fill x -padx 10 -pady 10

button .buttons.eject -text "Eject" -width 10 -command {
    set sel [.list curselection]
    if {$sel eq ""} {
        tk_messageBox -message "Please select a device first." -icon warning
    } else {
        set item [.list get $sel]
        # Парсим VID и PID из строки
        if {[regexp {VID:PID = ([0-9a-fA-F]+):([0-9a-fA-F]+)} $item -> vid pid]} {
            set result [exec sudo ./usb_eject $vid $pid]
            tk_messageBox -message "Ejecting: $item\n\n$result" -icon info
            exit
        } else {
            tk_messageBox -message "Could not parse VID/PID from: $item" -icon error
        }
    }
}

button .buttons.cancel -text "Cancel" -width 10 -command { exit }

pack .buttons.eject -side left -expand 1
pack .buttons.cancel -side right -expand 1
